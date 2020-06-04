#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'ISO::15924' ) || print "Bail out!\n";
}

diag( "Testing ISO::15924 $ISO::15924::VERSION, Perl $], $^X" );
