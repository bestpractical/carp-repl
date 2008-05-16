package Devel::REPL::Plugin::Carp::REPL;
use Moose::Role;
use namespace::clean -except => [ 'meta' ];
use Devel::LexAlias;
use Data::Dump::Streamer;

with qw(Devel::REPL::Plugin::LexEnv);

has 'environments' => (
    isa => 'ArrayRef',
    is => 'rw',
    required => 1,
    default => sub { [{}] },
);

has 'packages' => (
    isa      => 'ArrayRef',
    is       => 'rw',
    required => 1,
    default  => sub { ['main'] },
);

has 'argses' => (
    isa      => 'ArrayRef',
    is       => 'rw',
    required => 1,
    default  => sub { [[]] },
);

has 'frame' => (
    isa      => 'Int',
    is       => 'rw',
    required => 1,
    default  => 0,
);

has 'backtrace' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
    default  => '',
);

around 'frame' => sub {
    my $orig = shift;
    my ($self, $frame) = @_;

    return $orig->(@_) if !defined($frame);

    if ($frame < 0) {
        warn "You're already at the bottom frame.\n";
    }
    elsif ($frame >= @{ $self->packages }) {
        warn "You're already at the top frame.\n";
    }
    else {
        my ($package, $file, $line) = @{$self->packages->[$frame]};
        print "Now at $file:$line (frame $frame).\n";
        $orig->(@_);
    }
};

# this is totally the wrong spot for this. oh well.
around 'read' => sub {
    my $orig = shift;
    my ($self, @rest) = @_;
    my $line = $self->$orig(@rest);

    return if !defined($line) || $line =~ /^\s*:q\s*/;

    if ($line =~ /^\s*:b?t\s*/) {
        print $self->backtrace;
        return '';
    }

    if ($line =~ /^\s*:up?\s*/) {
        $self->frame($self->frame + 1);
        return '';
    }

    if ($line =~ /^\s*:d(?:own)?\s*/) {
        $self->frame($self->frame - 1);
        return '';
    }

    if ($line =~ /^\s*:l(?:ist)?\s*/) {
        my ($package, $file, $num) = @{$self->packages->[$self->frame]};
        open my $handle, '<', $file or do {
            warn "Unable to open $file for reading: $!\n";
            return '';
        };
        my @code = <$handle>;

        my $min = $num - 6;
        my $max = $num + 4;
        $min = 0 if $min < 0;
        $max = $#code if $max > $#code;

        print "File $file:\n";
        for my $cur ($min .. $max) {
            next if !defined($code[$cur]);

            printf "%s%*d: %s",
                    $cur + 1 == $num ? '*' : ' ',
                    length($max),
                    $cur + 1,
                    $code[$cur];
        }

        return '';
    }

    if ($line =~ /^\s*:e?(?:nv)?\s*/) {
        Dump($self->environments->[$self->frame])->Names('Env')->Out;
        return '';
    }

    return $line;
};

around 'mangle_line' => sub {
    my $orig = shift;
    my ($self, @rest) = @_;
    my $line = $self->$orig(@rest);

    my $frame = $self->frame;
    my $package = $self->packages->[$frame][0];

    my $declarations = join "\n",
                       map {"my $_;"}
                       keys %{ $self->environments->[$frame] };

    my $aliases = << '    ALIASES';
    while (my ($k, $v) = each %{ $_REPL->environments->[$_REPL->frame] }) {
        Devel::LexAlias::lexalias 0, $k, $v;
    }
    my $_a; Devel::LexAlias::lexalias 0, '$_a', \$_REPL->argses->[$_REPL->frame];
    ALIASES

    return << "    CODE";
    package $package;
    no warnings 'misc'; # declaration in same scope masks earlier instance
    no strict 'vars';   # so we get all the global variables in our package
    $declarations
    $aliases
    $line
    CODE
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::Carp::REPL - Devel::REPL plugin for Carp::REPL

=head1 SYNOPSIS

This sets up the environment captured by L<Carp::REPL>. This plugin
isn't intended for use by anything else. There are plans to move some features
from this into a generic L<Devel::REPL> plugin.

This plugin also adds a few extra commands like :up and :down to move up and
down the stack.

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

Please report any bugs to a medium given by Carp::REPL.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Best Practical Solutions, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

