#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

# use lib '../lib';
# use ISO::639::5;

BEGIN {
    use_ok( 'ISO::639::5' ) || print "Bail out!\n";
}

my %iso2glott = ('afa',     'afro1255',
		 'alg',     'algo1256',
		 'alv',     'atla1278',
		 'apa',     'apac1239',
		 'aqa',     'kawe1237',
		 'aql',     'algi1248');


foreach (keys %iso2glott){
    is (iso2glottolog($_), $iso2glott{$_}, "get glottolog ID for $_");
}

foreach (keys %iso2glott){
    is (glottolog2iso($iso2glott{$_}), $_, "get ISO code for $_");
}

done_testing();
