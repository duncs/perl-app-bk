#!perl

use strict;
use warnings;
use Test::More;
use Test::Trap;
use FindBin qw($Bin);

my $result;

use_ok("App::bk");

chdir($Bin) || bail_out( 'Failed to cd into ', $Bin );

unlink <file1.txt.*>;

local @ARGV = ('no_such_file.txt');

$result = trap { App::bk::backup_files(); };

like(
    $trap->stderr,
    qr/WARNING: File no_such_file.txt not found/,
    'correct stderr output'
);
is( $trap->stdout,  '',       'no stdout output' );
is( $trap->exit,    undef,    'correct exit' );
is( $trap->leaveby, 'return', 'returned correctly' );
is( $trap->die,     undef,    'no death output' );
is( $result,        1,        'got correct return value' );

local @ARGV = ('file1.txt');

$result = trap { App::bk::backup_files(); };

is( $trap->stderr, '', 'no stderr output' );
like(
    $trap->stdout,
    qr!Backed up file1.txt to ./file1.txt.\w+\.\d{8}\s$!,
    'got correct backup filename'
);
is( $trap->exit,    undef,    'correct exit' );
is( $trap->leaveby, 'return', 'returned correctly' );
is( $trap->die,     undef,    'no death output' );
is( $result,        1,        'got correct return value' );

$result = trap { App::bk::backup_files(); };

is( $trap->stderr, '', 'no stderr output' );
like(
    $trap->stdout,
    qr!Backed up file1.txt to ./file1.txt.\w+\.\d{8}\.\d{6}\s$!,
    'got correct backup filename'
);
is( $trap->exit,    undef,    'correct exit' );
is( $trap->leaveby, 'return', 'returned correctly' );
is( $trap->die,     undef,    'no death output' );
is( $result,        1,        'got correct return value' );

done_testing();
