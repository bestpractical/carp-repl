#!perl
use strict;
use warnings;
use Test::More tests => 7;
use Test::Expect;

expect_run
(
    command => "$^X -Ilib t/scripts/11-warn.pl",
    prompt  => '$ ',
    quit    => 'exit',
);

expect_send('1 + 1');
expect_like(qr/2/);

expect_send('$a');
expect_like(qr/\b4\b/);

expect_send('$b');
expect_like(qr/\A\s*\$b\s*\Z/);

