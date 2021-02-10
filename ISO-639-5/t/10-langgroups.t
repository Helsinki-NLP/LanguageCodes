#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

BEGIN {
    use_ok( 'ISO::639::5' ) || print "Bail out!\n";
}


my %children  = ( 'gem' => 'gme gmq gmw',
		  'gmq' => 'dan fao isl jut nno nob non nrn ovd qer rmg swe');
my %parent    = ( 'deu' => 'gmw',
		  'gmw' => 'gem',
		  'gem' => 'ine');
my %langgroup = ('cel' => 'bre cor cym ghc gla gle glv mga nrc obt owl sga wlm xbm xcb xce xcg xga xlp xpi xtg xve',
		 'bat' => 'lav lit ltg ndf olt prg sgs svx sxl xcu xgl xsv xzm');


foreach (keys %children){
    my $codes = join(' ',sort {$a cmp $b} language_group_children($_));
    is  ($codes, $children{$_}, "test children of $_");
}

foreach (keys %parent){
    my $p = language_parent($_);
    is  ($p, $parent{$_}, "test parent of $_");
}

foreach (keys %langgroup){
    my $codes = join(' ',sort {$a cmp $b} language_group($_));
    is  ($codes, $langgroup{$_}, "test language group of $_");

}

done_testing();
