#!perl
use strict;
use warnings;
use Test::More tests => 48;
use Test::Expect;

expect_run
(
    command => 'perl -Ilib -MCarp::REPL t/scripts/07-frame.pl',
    prompt  => '$ ',
    quit    => 'exit',
);

# examine the stack trace
expect_like(qr{^0: Carp::REPL::repl called at t/scripts/07-frame\.pl:8\.}m);
expect_like(qr{^   1: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   2: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   3: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   4: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   5: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   6: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   7: main::fib called at t/scripts/07-frame\.pl:12\.}m);

expect_send('1 + 1');
expect_like(qr/\b2\b/, 'in the REPL');

expect_send('$n');
expect_like(qr/-1\b/);

expect_send(':u');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:9 \(frame 1\)\.});

expect_send('$n');
expect_like(qr/\b0\b/);

expect_send(':up');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:9 \(frame 2\)\.});

expect_send('$n');
expect_like(qr/\b1\b/);

expect_send(':d');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:9 \(frame 1\)\.});

expect_send('$n');
expect_like(qr/\b0\b/);

expect_send(':down');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:8 \(frame 0\)\.});

expect_send('$n');
expect_like(qr/-1\b/);

expect_send(':d');
expect_like(qr{\bYou're already at the bottom frame\.});

expect_send('$n');
expect_like(qr/-1\b/);

expect_send('my $m = 10');
expect_like(qr/\b10\b/);

expect_send(':u');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:9 \(frame 1\)\.});

expect_send('$m');
expect_like(qr/^\s*\$m\s*$/m);

expect_send(':t');
# examine the stack trace
expect_like(qr{^0: Carp::REPL::repl called at t/scripts/07-frame\.pl:8\.}m);
expect_like(qr{^   1: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   2: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   3: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   4: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   5: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   6: main::fib called at t/scripts/07-frame\.pl:9\.}m);
expect_like(qr{^   7: main::fib called at t/scripts/07-frame\.pl:12\.}m);
