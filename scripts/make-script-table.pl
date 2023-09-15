#!/usr/bin/env perl

use utf8;
use open ':locale';

# use strict;
use lib 'ISO-639-3/lib';
use ISO::639::3 qw/:all/;
use Data::Dumper;

use XML::Parser;

# binmode(STDOUT,":utf8");

my $iso15924     = shift(@ARGV) || 'data/iso15924-utf8-20200424.txt';
my $cldrData     = shift(@ARGV) || 'data/cldr/common/supplemental/supplementalData.xml';
my $cldrMetaData = shift(@ARGV) || 'data/cldr/common/supplemental/supplementalMetadata.xml';

read_iso15924($iso15924);

my $DataParser = new XML::Parser(Handlers => {Start => \&cldrDataTag});
read_cldr_data($DataParser,$cldrData);

my $MetaDataParser = new XML::Parser(Handlers => {Start => \&cldrMetaDataTag});
read_cldr_data($MetaDataParser,$cldrMetaData);

set_default_scripts();
set_default_territories();

$Data::Dumper::Indent = 1;       # mild pretty print

print Data::Dumper->Dump([\%Code2Name],        ['ScriptCode2ScriptName']);
print Data::Dumper->Dump([\%Name2Code],        ['ScriptName2ScriptCode']);
print Data::Dumper->Dump([\%Id2Code],          ['ScriptId2ScriptCode']);
print Data::Dumper->Dump([\%Code2English],     ['ScriptCode2EnglishName']);
print Data::Dumper->Dump([\%Code2French],      ['ScriptCode2FrenchName']);
print Data::Dumper->Dump([\%CodeVersion],      ['ScriptCodeVersion']);
print Data::Dumper->Dump([\%CodeDate],         ['ScriptCodeDate']);
print Data::Dumper->Dump([\%CodeId],           ['ScriptCodeId']);

print Data::Dumper->Dump([\%Lang2Territory],   ['Lang2Territory']);
print Data::Dumper->Dump([\%Lang2Script],      ['Lang2Script']);
print Data::Dumper->Dump([\%Territory2Lang],   ['Territory2Lang']);
print Data::Dumper->Dump([\%Script2Lang],      ['Script2Lang']);
print Data::Dumper->Dump([\%DefaultScript],    ['DefaultScript']);
print Data::Dumper->Dump([\%DefaultTerritory], ['DefaultTerritory']);

# print Data::Dumper->Dump([\%Lang2PrimaryTerritory], ['Lang2PrimaryTerritory']);
# print Data::Dumper->Dump([\%Lang2PrimaryScript],    ['Lang2PrimaryScript']);
# print Data::Dumper->Dump([\%Territory2PrimaryLang], ['Territory2PrimaryLang']);
# print Data::Dumper->Dump([\%Script2PrimaryLang],    ['Script2PrimaryLang']);

# print Data::Dumper->Dump([\%Lang2SecondaryTerritory], ['Lang2SecondaryTerritory']);
# print Data::Dumper->Dump([\%Lang2SecondaryScript],    ['Lang2SecondaryScript']);
# print Data::Dumper->Dump([\%Territory2SecondaryLang], ['Territory2SecondaryLang']);
# print Data::Dumper->Dump([\%Script2SecondaryLang],    ['Script2SecondaryLang']);


sub read_iso15924{
    my $file = shift;
    open F,"<$file" || die "cannot read from $file\n";
    # binmode(F,":utf8");
    while (<F>){
	next if (/^\#/);
	next unless (/\S/);
	my ($code, $id, $english, $french, $name, $version, $date) = split(/\;/);
	$Code2English{$code} = $english;
	$Code2French{$code} = $french;
	$Code2Name{$code} = $name;
	$CodeVersion{$code} = $version;
	$CodeDate{$code} = $date;
	$CodeId{$code} = $id;
	$Name2Code{$name} = $code;
	$Id2Code{$id} = $code;
    }
}


sub set_default_territories{
    foreach my $l (keys %Lang2Territory){
	next if (exists $DefaultTerritory{$l});
	my @regions = keys %{$Lang2Territory{$l}};
	if ($#regions == 0){ $DefaultTerritory{$l} = $regions[0]; }
    }
    ## somehow macro-norwegian is missing
    $DefaultTerritory{'no'} = 'NO';
    $DefaultTerritory{'nor'} = 'NO';
    ## TODO: why is it going to BR otherwise?
    $DefaultTerritory{pt} = 'PT';
    $DefaultTerritory{por} = 'PT';
}

sub set_default_scripts{
    foreach my $l (keys %Lang2Script){
	next if (exists $DefaultScript{$l});
	my @scripts = keys %{$Lang2Scripts{$l}};
	if ($#scripts == 0){ $DefaultScripts{$l} = $scripts[0]; }
    }
    ## somehow macro-norwegian is missing
    $DefaultScript{'nor'} = 'Latn';
    $DefaultScript{'no'} = 'Latn';
}


sub read_cldr_data{
    my $parser = shift;
    my $file = shift;

    my $XmlReader = $parser->parse_start;
    open F,"<$file" || die "cannot read from $file\n";
    while (<F>){
	eval { $XmlReader->parse_more($_); };
	if ($@){
	    warn $@;
	    print STDERR $_;
	}
    }
    close F;
}



sub cldrMetaDataTag{
    my ($p,$e,%a) = @_;

    if ($e eq 'defaultContent'){
	if (exists $a{locales}){
	    $a{locales}=~s/^\s*//s;
	    $a{locales}=~s/\s*$//s;
	    my @locales = split(/\s+/,$a{locales});
	    foreach (@locales){
		my @parts = split(/\_/);
		my $region = pop(@parts);
		next unless ($region=~/^[A-Z]{2}$/);
		my $key = join('_',@parts);
		$DefaultTerritory{$key} = $region;
		$parts[0] = get_iso639_3($parts[0]);
		$key = join('_',@parts);
		$DefaultTerritory{$key} = $region;
	    }
	}
    }
}


sub cldrDataTag{
    my ($p,$e,%a) = @_;

    if ($e eq 'language'){

	my $lang  = get_iso639_3($a{type});
	my $macro = get_macro_language($a{type});
	my $status = 1;
	if (exists $a{alt}){
	    $status = 2 if ($a{alt} eq 'secondary');
	}
	my @territories = ();
	my @scripts = ();
	if (exists $a{territories}){
	    @territories = split(/\s+/,$a{territories});
	}
	if (exists $a{scripts}){
	    @scripts = split(/\s+/,$a{scripts});
	}
	foreach (@territories){
	    $Lang2Territory{$lang}{$_} = $status;
	    $Territory2Lang{$_}{$lang} = $status;
	    if ($macro ne $lang){
		$Lang2Territory{$macro}{$_} = $status;
		$Territory2Lang{$_}{$macro} = $status;
	    }
# 	    if ($status == 2){
# 		$Lang2SecondaryTerritory{$lang}{$_} = 1;
# 		$Territory2SecondaryLang{$_}{$lang} = 1;
# 	    }
# 	    else{
# 		$Lang2PrimaryTerritory{$lang}{$_} = 1;
# 		$Territory2PrimaryLang{$_}{$lang} = 1;
# 	    }
	}

	## set default script per language
	if ( ($#scripts == 0) && ($status == 1) ){
	    $DefaultScript{$lang} = $scripts[0] unless (exists $DefaultScript{$lang});
	}

	foreach my $s (@scripts){
	    $Lang2Script{$lang}{$s} = $status;
	    $Script2Lang{$s}{$lang} = $status;
	    if ($macro ne $lang){
		$Lang2Script{$macro}{$s} = $status;
		$Script2Lang{$s}{$macro} = $status;
	    }
	    my $region = $DefaultTerritory{$lang} if (exists $DefaultTerritory{$lang});
	    if ($#scripts == 0){
		foreach my $t (@territories){
		    $ScriptInRegion{$lang}{$t} = $s;
		    unless (exists $DefaultScript{$lang}){
			$DefaultScript{$lang} = $s if ($region eq $t);
		    }
		}
	    }
# 	    if ($status == 2){
# 		$Lang2SecondaryScript{$lang}{$s} = 1;
# 		$Script2SecondaryLang{$s}{$lang} = 1;
# 	    }
# 	    else{
# 		$Lang2PrimaryScript{$lang}{$s} = 1;
# 		$Script2PrimaryLang{$s}{$lang} = 1;
# 	    }
#	    foreach my $t (@territories){
#		$LangTerritory2Script{$lang}{$t}{$s} = 1;
#		$LangTerritory2Script{$lang}{$t}{$s} = 1;
#	    }
	}
    }
}
