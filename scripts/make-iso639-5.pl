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
my $iso639_5_glottolog = shift(@ARGV) || 'data/iso639-5_to_iso639-3.tsv';

my $DataParser = new XML::Parser(Handlers => { Start => \&cldrDataStartTag,
					       End   => \&cldrDataEndTag,
					       Char  => \&cldrDataChar });

read_cldr_data($DataParser,$cldrLanguageGroups);
read_iso639_5($iso639_5_hierarchy,$iso639_5_languages,$iso639_5_glottolog);


$Data::Dumper::Indent = 1;       # mild pretty print

print Data::Dumper->Dump([\%LanguageGroup],    ['LanguageGroup']);
print Data::Dumper->Dump([\%LanguageParent],   ['LanguageParent']);
print Data::Dumper->Dump([\%ISO2Glottolog],    ['ISO2Glottolog']);
print Data::Dumper->Dump([\%Glottolog2ISO],    ['Glottolog2ISO']);


sub read_iso639_5{
    my $hierarchy = shift;
    my $languages = shift;
    my $glottolog = shift;

    my %langs = ();
    open F,"<$hierarchy" || die "cannot read from $hierarchy!\n";
    while (<F>){
	chomp;
	s/ //g;
	my @parents = split(/\:/);
	my $code = pop(@parents);
	while (@parents){
	    my $parent = pop(@parents);
	    $LanguageParent{$code} = $parent unless ($code eq $parent);
	    $langs{$parent}{$code}++;
	    my $macro = get_macro_language($code,1);
	    $LanguageParent{$macro} = $parent
		if (($macro ne $code) && ($macro ne $parent));
	    $code = $parent;
	}
	$LanguageParent{$code} = 'mul';
    }
    close F;
    
    open F,"<$languages" || die "cannot read from $languages!\n";
    while (<F>){
	next if (/^#/);
	chomp;
	my ($code,$langstr) = split(/\t/);
	my @langs = split(/\s+/,$langstr);
	foreach (@langs){
	    $LanguageParent{$_} = $code unless ($code eq $_);
	    $langs{$code}{$_}++;
	    my $macro = get_macro_language($_,1);
	    $LanguageParent{$macro} = $code
		if (($macro ne $_) && ($macro ne $code));
	}
    }
    close F;

    ## read language list from glottolog
    if (-e $glottolog){
	open F,"<$glottolog" || die "cannot read from $glottolog!\n";
	while (<F>){
	    next if (/^#/);
	    chomp;
	    my ($code,$glottolog,$langstr) = split(/\t/);
	    if ($glottolog){
		my @glottoIDs = split(/\s+/,$glottolog);
		foreach (@glottoIDs){
		    $ISO2Glottolog{$code} = $_;
		    $Glottolog2ISO{$_} = $code;
		}
	    }
	    my @langs = split(/\s+/,$langstr);
	    foreach (@langs){
		my $parent = exists $LanguageParent{$_} ?
		    $LanguageParent{$_} : undef;
		if ($parent){
		    next if ($code eq $parent);
		    next if (is_ancestor($code, $parent));
		    delete $langs{$parent}{$_};
		}
		$LanguageParent{$_} = $code unless ($code eq $_);
		$langs{$code}{$_}++;
		my $macro = get_macro_language($_,1);
		$LanguageParent{$macro} = $code
		    if (($macro ne $_) && ($macro ne $code));
	    }
	}
	close F;
    }

    foreach my $c (keys %LanguageGroup){
	foreach my $i (@{$LanguageGroup{$c}}){
	    $langs{$c}{$i}++;
	}
    }
    foreach my $c (keys %langs){
	@{$LanguageGroup{$c}} = sort keys %{$langs{$c}};
    }
}


sub is_ancestor{
    my ($lang1,$lang2) = @_;
    if (exists $LanguageParent{$lang2}){
	return 1 if ($LanguageParent{$lang2} eq $lang1);
	return is_ancestor($lang1,$LanguageParent{$lang2});
    }
    return 0;
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


    ## fix a problem in the data: remove creole language sub-groups from romance language group
    ## remove xmm (Manado Malay) and srm (Saramaccan) from Portuguese Creole (cpp)
    ## TODO: is there a better way then this hard-coded fix?
    @{$LanguageGroup{'roa'}} = grep ($_!~/^(cpp|cpf)$/,@{$LanguageGroup{'roa'}});
    @{$LanguageGroup{'cpp'}} = grep ($_!~/^(xmm|srm)$/,@{$LanguageGroup{'cpp'}});

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
		$LanguageParent{$iso} = $parent unless ($iso eq $parent);
		my $macro = get_macro_language($iso,1);
		$LanguageParent{$macro} = $parent
		    if (($macro ne $iso) && ($macro ne $parent));
	    }
	    @{$LanguageGroup{$parent}} = @groupISO;
	    delete $p->{languageGroupParent};
	    delete $p->{languageGroup};
	}
    }
}

