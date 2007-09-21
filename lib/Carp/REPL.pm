package Carp::REPL;
use strict;
use warnings;
use 5.6.0;
our $noprofile = 0;

sub import
{
    my $nodie = grep {$_ eq 'nodie'} @_;
    my $warn  = grep {$_ eq 'warn' } @_;
    $noprofile = grep {$_ eq 'noprofile'} @_;

    $SIG{__DIE__} = \&repl unless $nodie;
    $SIG{__WARN__} = \&repl if $warn;
}

=head1 NAME

Carp::REPL - read-eval-print-loop on die and/or warn

=head1 VERSION

Version 0.11 released 20 Sep 07

=cut

our $VERSION = '0.11';

=head1 SYNOPSIS

The intended way to use this module is through the command line.

    perl tps-report.pl
        Can't call method "cover_sheet" without a package or object reference at tps-report.pl line 6019.

    perl -MCarp::REPL tps-report.pl
        Can't call method "cover_sheet" without a package or object reference at tps-report.pl line 6019.

        $ map {"$_\n"} $form, $subform
        27B/6
        Report::TPS::Subreport=HASH(0x86da61c)

=head1 USAGE

    -MCarp::REPL

Works as command line argument. This automatically installs the die handler for
you, so if you receive a fatal error you get a REPL before the universe
explodes.

    use Carp::REPL;

Same as above.

    use Carp::REPL 'nodie';

Loads the module without installing the die handler. Use this if you just want to
run C<Carp::REPL::repl> on your own terms.

    use Carp::REPL 'warn';

Same as C<Carp::REPL> but also installs REPL to be invoked whenever a warning
is generated.

    use Carp::REPL 'warn', 'nodie';

I don't see why you would want to do this, but it's available. :)

    use Carp::REPL 'noprofile';

Don't load any per-user L<Devel::REPL> configuration (really only useful for
testing).

=head1 FUNCTIONS

=head2 repl

This module's interface consists of exactly one function: repl. This is
provided so you may install your own C<$SIG{__DIE__}> handler if you have no
alternatives.

It takes the same arguments as die, and returns no useful value. In fact, don't
even depend on it returning at all!

One useful place for calling this manually is if you just want to check the
state of things without having to throw a fake error. You can also change any
variables and those changes will be seen by the rest of your program.

    use Carp::REPL;

    sub involved_calculation
    {
        # ...
        $d = maybe_zero();
        # ...
        Carp::REPL::repl; # $d = 1
        $sum += $n / $d;
        # ...
    }

Unfortunately if you instead go with the usual C<-MCarp::REPL>, then
C<$SIG{__DIE__}> will be invoked and there's no general way to recover. But you
can still change variables to poke at things.

=cut

sub repl
{
    warn @_, "\n"; # tell the user what blew up

    require PadWalker;
    require Devel::REPL::Script;

    my (@packages, @environments, @argses, $backtrace);

    my $frame = 0;
    while (1)
    {
        package DB;
        my ($package, $file, $line, $subroutine) = caller($frame)
            or last;
        $package = 'main' if !defined($package);

        eval
        {
            # PadWalker has 0 mean 'current'
            # caller has 0 mean 'immediate caller'
            push @environments, PadWalker::peek_my($frame+1);
        };
        Carp::carp($@), last if $@;

        push @argses, [@DB::args];
        push @packages, [$package, $file, $line];

        $backtrace .= sprintf "%s%d: %s called at %s:%s.\n",
            $frame == 0 ? '' : '   ',
            $frame,
            $subroutine,
            $file,
            $line;
        ++$frame;
    }

    warn $backtrace;

    my ($runner, $repl);

    if ($noprofile)
    {
        $repl = $runner = Devel::REPL->new;
        $repl->load_plugin('LexEnv');
    }
    else
    {
        $runner = Devel::REPL::Script->new;
        $repl = $runner->_repl;
    }

    $repl->load_plugin('LexEnvCarp');

    $repl->environments(\@environments);
    $repl->packages(\@packages);
    $repl->argses(\@argses);
    $repl->backtrace($backtrace);
    $repl->frame(0);
    $runner->run;
}

=head1 COMMANDS

Note that this is not supposed to be a full-fledged debugger. A few commands
are provided to aid you in finding out what went awry. See
L<Devel::ebug> if you're looking for a serious debugger.

=over 4

=item * :u

Moves one frame up in the stack.

=item * :d

Moves one frame down in the stack.

=item * :t

Redisplay the stack trace.

=item * :e

Display the current lexical environment.

=item * :q

Close the REPL. (C<^D> also works)

=back

=head1 VARIABLES

=over 4

=item * $_REPL

This represents the Devel::REPL object (with the LexEnvCarp plugin, among
others, mixed in).

=item * $_a

This represents the arguments passed to the subroutine at the current frame in
the call stack. Modifications are ignored (how would that work anyway?
Re-invoke the sub?)

=back

=head1 CAVEATS

Dynamic scope probably produces unexpected results. I don't see any easy (or
even difficult!) solution to this. Therefore it's a caveat and not a bug. :)

=head1 SEE ALSO

L<Devel::REPL>, L<Devel::ebug>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

No known bugs at this point. To expect that to stay true is laughably naive. :)

Please report any bugs or feature requests to
C<bug-carp-repl at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Carp-REPL>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Carp::REPL

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Carp-REPL>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Carp-REPL>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Carp-REPL>

=item * Search CPAN

L<http://search.cpan.org/dist/Carp-REPL>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Nelson Elhage and Jesse Vincent for the idea.

Thanks to Matt Trout and Stevan Little for their advice.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Best Practical Solutions, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Carp::REPL

