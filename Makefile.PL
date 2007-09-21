# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name            'Carp-REPL';
all_from        'lib/Carp/REPL.pm';

# Specific dependencies
requires        'Devel::LexAlias'      => 0;
requires        'Devel::REPL'          => 0;
requires        'Moose'                => 0;
requires        'Moose::Role'          => 0;
requires        'namespace::clean'     => 0;
requires        'PadWalker'            => 0;
requires        'Data::Dump::Streamer' => 0;

build_requires  'Test::Expect'         => 0;
build_requires  'Test::More'           => 0;

no_index package => 'DB';
no_index package => 'Devel::REPL::Plugin::LexEnvCarp';

auto_install;
WriteAll;

