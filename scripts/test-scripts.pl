

use utf8;
use lib 'ISO-639-3/lib';
use Unicode::UCD 'prop_value_aliases';
use ISO::15924 qw/:all/;


my @scripts = qw/Adlm Afak Aghb Ahom Arab Aran Armi Armn Avst Bali Bamu Bass Batk Beng Bhks Blis Bopo Brah Brai Bugi Buhd Cakm Cans Cari Cham Cher Chrs Cirt Copt Cpmn Cprt Cyrl Cyrs Deva Diak Dogr Dsrt Dupl Egyd Egyh Egyp Elba Elym Ethi Geok Geor Glag Gong Gonm Goth Gran Grek Gujr Guru Hanb Hang Hani Hano Hans Hant Hatr Hebr Hira Hluw Hmng Hmnp Hrkt Hung Inds Ital Jamo Java Jpan Jurc Kali Kana Khar Khmr Khoj Kitl Kits Knda Kore Kpel Kthi Lana Laoo Latf Latg Latn Leke Lepc Limb Lina Linb Lisu Loma Lyci Lydi Mahj Maka Mand Mani Marc Maya Medf Mend Merc Mero Mlym Modi Mong Moon Mroo Mtei Mult Mymr Nand Narb Nbat Newa Nkdb Nkgb Nkoo Nshu Ogam Olck Orkh Orya Osge Osma Palm Pauc Perm Phag Phli Phlp Phlv Phnx Plrd Piqd Prti Qaaa Qabx Rjng Rohg Roro Runr Samr Sara Sarb Saur Sgnw Shaw Shrd Shui Sidd Sind Sinh Sogd Sogo Sora Soyo Sund Sylo Syrc Syre Syrj Syrn Tagb Takr Tale Talu Taml Tang Tavt Telu Teng Tfng Tglg Thaa Thai Tibt Tirh Toto Ugar Vaii Visp Wara Wcho Wole Xpeo Xsux Yezi Yiii Zanb Zinh Zmth Zsye Zsym Zxxx Zyyy Zzzz/;


my $text = "asdмифологический персонаж, asперсонификация полдня как опасного для человека погрasdаничного";


# %s = script_of_string($text);
# $b = script_of_string($text);


$a = Unicode::UCD::charscripts();
$b = Unicode::UCD::charblocks();


foreach my $s (@scripts){
    $exists = exists $$a{$s};
    unless ($exists){
	@k = prop_value_aliases('script', $s);
	if ( grep ($_ eq $s, @k)){
	    # print "$s exists as alias!\n";
	    $exists = 1;
	}
    }

    if ($exists){
	my $regex = "\\p\{$s\}";
	# my $regex = "\\p\{Script_Extensions=$s\}";
	# if ($text=~/$regex/){
	if ($text=~/\p{$s}/){
	    my $count = 0;
	    while ($text =~ m/$regex/gs) {$count++};
	    print "$count character from script $s detected!\n";
	}
    }
    else{
	print "script $s is not supported\n"
    }

    unless ($exists){
	$exists = exists $$b{$s};
	unless ($exists){
	    @k = prop_value_aliases('block', $s);
	    if ( grep ($_ eq $s, @k)){
		print "$s exists as alias!\n";
		$exists = 1;
	    }
	}
	else{
	    print "$s exists as block!\n";
	}
    }


}

