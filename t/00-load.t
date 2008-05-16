#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Carp::REPL' );
	use_ok( 'Devel::REPL::Plugin::Carp::REPL' );
}

diag( "Testing Carp::REPL $Carp::REPL::VERSION, Perl $], $^X" );
