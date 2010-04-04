#!perl
use strict;
use warnings;
use Test::More tests => 55;
use Test::Expect;

expect_run
(
    command => "$^X -Ilib -MCarp::REPL=noprofile t/scripts/07-frame.pl",
    prompt  => '$ ',
    quit    => 'exit',
);

# examine the stack trace
expect_like(qr{^can't do negatives! at t/scripts/07-frame\.pl line 8\.}m);
expect_like(qr{^Trace begun at t/scripts/07-frame\.pl line 8}m);
expect_like(qr{^main::fib\(-1\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{^main::fib\(0\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{^main::fib\(1\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{^main::fib\(2\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{^main::fib\(3\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{^main::fib\(4\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{^main::fib\(5\) called at t/scripts/07-frame\.pl line 12}m);

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
expect_like(qr{Trace begun at t/scripts/07-frame\.pl line 8}m);
expect_like(qr{main::fib\(-1\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{main::fib\(0\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{main::fib\(1\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{main::fib\(2\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{main::fib\(3\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{main::fib\(4\) called at t/scripts/07-frame\.pl line 9}m);
expect_like(qr{main::fib\(5\) called at t/scripts/07-frame\.pl line 12}m);

expect_send(':bottom');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:8 \(frame 0\)\.});

expect_send('$m');
expect_like(qr/^\s*\$m\s*$/m);

expect_send(':top');
expect_like(qr{\bNow at t/scripts/07-frame\.pl:12 \(frame 7\)\.});

