#!/usr/bin/env perl

use utf8;
use open ':locale';

# use strict;
use lib 'ISO-639_3/lib';
use ISO::639_3 qw/:all/;
use Data::Dumper;

use XML::Parser;

my $cldrLanguageGroups = shift(@ARGV) || 'data/cldr/common/supplemental/languageGroup.xml';

my $DataParser = new XML::Parser(Handlers => { Start => \&cldrDataStartTag,
					       End   => \&cldrDataEndTag,
					       Char  => \&cldrDataChar });
read_cldr_data($DataParser,$cldrLanguageGroups);


$Data::Dumper::Indent = 1;       # mild pretty print

print Data::Dumper->Dump([\%LanguageGroup],    ['LanguageGroup']);
print Data::Dumper->Dump([\%LanguageParent],   ['LanguageParent']);





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

