#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::bk' ) || print "Bail out!
";
}

diag( "Testing App::bk $App::bk::VERSION, Perl $], $^X" );
