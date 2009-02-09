use inc::Module::Install;

name     'Carp-REPL';
all_from 'lib/Carp/REPL.pm';

requires 'Devel::StackTrace::WithLexicals' => 0;
requires 'Devel::LexAlias'                 => 0;
requires 'Devel::REPL'                     => 0;
requires 'namespace::clean'                => 0;
requires 'Data::Dump::Streamer'            => 0;
requires 'Lexical::Persistence'            => 0;

build_requires  'Test::Expect' => 0;
build_requires  'Test::More'   => 0;

no_index package => 'DB';
no_index package => 'Devel::REPL::Plugin::Carp::REPL';

WriteAll;

