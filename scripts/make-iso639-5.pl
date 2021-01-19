#!/usr/bin/env perl

use utf8;
use open ':locale';

# use strict;
use lib 'ISO-639-3/lib';
use ISO::639::3 qw/:all/;
use Data::Dumper;

use XML::Parser;

my $cldrLanguageGroups = shift(@ARGV) || 'data/cldr/common/supplemental/languageGroup.xml';
my $iso639_5_hierarchy = shift(@ARGV) || 'data/iso639-5-hierarchy.tsv';
my $iso639_5_languages = shift(@ARGV) || 'data/iso639-5-languages.tsv';

my $DataParser = new XML::Parser(Handlers => { Start => \&cldrDataStartTag,
					       End   => \&cldrDataEndTag,
					       Char  => \&cldrDataChar });

read_cldr_data($DataParser,$cldrLanguageGroups);
read_iso639_5($iso639_5_hierarchy,$iso639_5_languages);


$Data::Dumper::Indent = 1;       # mild pretty print

print Data::Dumper->Dump([\%LanguageGroup],    ['LanguageGroup']);
print Data::Dumper->Dump([\%LanguageParent],   ['LanguageParent']);


sub read_iso639_5{
    my $hierarchy = shift;
    my $languages = shift;
    open F,"<$hierarchy" || die "cannot read from $hierarchy!\n";
    while (<F>){
	chomp;
	my @fields = split(/\t/);
	my $code = $fields[0];
	my $rel = $fields[5];
	$rel=~s/ //g;
	my @parents = split(/\:/,$rel);
	my $code = pop(@parents);
	foreach (@parents){
	    $LanguageParent{$code} = $parent;
	    my $macro = get_macro_language($code,1);
	    $LanguageParent{$macro} = $parent if ($macro ne $code);
	    $code = $parent;
	}
    }
    close F;

    my %langs = ();
    open F,"<$languages" || die "cannot read from $languages!\n";
    while (<F>){
	chomp;
	my ($code,$langstr) = split(/\t/);
	my @langs = split(/\s+/,$langstr);
	foreach (@langs){
	    $LanguageParent{$_} = $code;
	    $langs{$code}{$_}++;
	    my $macro = get_macro_language($_,1);
	    $LanguageParent{$macro} = $code if ($macro ne $_);
	}
    }
    close F;

    foreach my $c (keys %LanguageGroup){
	foreach my $i (@{$LanguageGroup{$c}}){
	    $langs{$c}{$i}++;
	}
    }
    foreach my $c (keys %langs){
	@{$LanguageGroup{$c}} = sort keys %{$langs{$c}};
    }
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



sub cldrDataStartTag{
    my ($p,$e,%a) = @_;

    if ($e eq 'languageGroup'){
	$p->{languageGroupParent} = $a{parent};
	$p->{languageGroup} = '';
    }
}

sub cldrDataChar{
    my ($p,$c) = @_;
    if (exists $p->{languageGroupParent}){
	$p->{languageGroup} .= $c;
    }
}

sub cldrDataEndTag{
    my ($p,$e) = @_;
    if ($e eq 'languageGroup'){
	if (exists $p->{languageGroupParent}){

	    my $parent  = get_iso639_3($p->{languageGroupParent},1);
	    my @group = split(/\s+/,$p->{languageGroup});
	    my @groupISO = ();
	    foreach (@group){
		my $iso = get_iso639_3($_,1);
		push(@groupISO,$iso);
		$LanguageParent{$iso} = $parent;
		my $macro = get_macro_language($iso,1);
		$LanguageParent{$macro} = $parent if ($macro ne $iso);
	    }
	    @{$LanguageGroup{$parent}} = @groupISO;
	    delete $p->{languageGroupParent};
	    delete $p->{languageGroup};
	}
    }
}

