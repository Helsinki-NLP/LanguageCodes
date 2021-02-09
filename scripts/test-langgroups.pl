
use FindBin qw($Bin);
use lib "$Bin/../ISO-639-5/lib";
use lib "$Bin/../ISO-639-3/lib";

use ISO::639::5 qw/:all/;
use ISO::639::3 qw/:all/;

my $codefile = "$Bin/../data/iso639-5.tsv";
open F,"<$codefile" || die "cannot read $codefile\n";

<F>;
while (<F>){
    my @fields = split(/\t/);
    unless (exists $$ISO::639::5::LanguageGroup{$fields[1]}){
	print "language group $fields[1] ($fields[2]) does not exist!\n";
    }
}

foreach my $l (sort keys %ISO::639::3::ThreeToName){
    unless (exists $$ISO::639::5::LanguageParent{$l}){
	print "language $l ($ISO::639::3::ThreeToName{$l}) has no parent in ISO639-5!\n";
    }
#    else{
#	print "language $l ($ISO::639::3::ThreeToName{$l}) has parent $$ISO::639::5::LanguageParent{$l} in ISO639-5!\n";
#    }
}
