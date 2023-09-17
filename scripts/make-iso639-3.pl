#!/usr/bin/env perl
#-*-perl-*-
#
# use 5.006;

use strict;
use warnings;

use utf8;
use open ':locale';
use Data::Dumper;

our %TwoToThree   = ();
our %ThreeToTwo   = ();
our %ThreeToThree = ();
our %ThreeToMacro = ();
our %NameToTwo    = ();
our %NameToThree  = ();
our %TwoToName    = ();
our %ThreeToName  = ();


my @ISO639_TABLES = @ARGV ||
    qw(data/iso-639-3_Code_Tables_20200130/iso-639-3_20200130.tab
    data/iso-639-3_Code_Tables_20200130/iso-639-3-macrolanguages_20200130.tab
    data/non-standard.tab
    data/iso-639-3_Code_Tables_20200130/iso-639-3_Retirements_20200130.tab
    data/collective-language-codes.tab
    data/iso639-5.tsv);

&_read_iso639_codes(@ISO639_TABLES);


$Data::Dumper::Indent = 1;       # mild pretty print

print Data::Dumper->Dump([\%TwoToThree],    ['TwoToThree']);
print Data::Dumper->Dump([\%ThreeToTwo],    ['ThreeToTwo']);
print Data::Dumper->Dump([\%ThreeToThree],  ['ThreeToThree']);
print Data::Dumper->Dump([\%ThreeToMacro],  ['ThreeToMacro']);
print Data::Dumper->Dump([\%NameToTwo],     ['NameToTwo']);
print Data::Dumper->Dump([\%NameToThree],   ['NameToThree']);
print Data::Dumper->Dump([\%TwoToName],     ['TwoToName']);
print Data::Dumper->Dump([\%ThreeToName],   ['ThreeToName']);



####################################
# internal functions that
# read all codes from the data part
####################################

## read all codes
sub _read_iso639_codes{

    foreach (@_){
	open DATA,'<',$_ || die "cannot read $_\n";
	while (<DATA>){
	    chomp;
	    next unless($_);
	    my @f = split(/\t/);
	    if ($f[1] eq 'Part2B'){
		&_read_main_code_table();
	    }
	    elsif ($f[0] eq 'M_Id'){
		&_read_macrolanguage_table();
	    }
	    elsif ($f[0] eq 'NS_Id'){
		&_read_nonstandard_code_table();
	    }
	    elsif ($f[0] eq 'C_Id'){
		&_read_collective_language_table();
	    }
	    elsif ($f[0] eq 'URI'){
		&_read_iso639_5();
	    }
	    elsif ($f[4] eq 'Ret_Remedy'){
		&_read_retired_code_table();
	    }
	}
    }
}


sub _read_retired_code_table{    
    ## retired codes
    # print STDERR "read retired";
    while (<DATA>){
	chomp;
	last unless ($_);
	my @f = split(/\t/);
	next unless ($f[0]);
	unless (exists $ThreeToThree{$f[0]}){
	    $ThreeToName{$f[0]} = $f[1];
	    $ThreeToThree{$f[0]} = $f[3] if ($f[3]);
	    # $ThreeToThree{$f[0]} = $f[3] ? $f[3] : $f[0];
	}
    }
}

sub _read_macrolanguage_table{    
    ## macro-languages
    # print STDERR "read macrolanguages";
    while (<DATA>){
	chomp;
	last unless ($_);
	my @f = split(/\t/);
	next unless ($f[0]);
	# $ThreeToThree{$f[1]} = $f[1];
	$ThreeToMacro{$f[1]} = $f[0];
    }
}

sub _read_collective_language_table{
    ## collective languages from ISO639-2
    # print STDERR "read collective language codes";
    while (<DATA>){
	chomp;
	last unless ($_);
	my @f = split(/\t/);
	next unless ($f[0]);
	unless (exists $ThreeToThree{$f[0]}){
	    # $ThreeToThree{$f[0]} = $f[0];
	    if ($f[1]){
		$ThreeToTwo{$f[0]} = $f[1];
		$TwoToThree{$f[1]} = $f[0];
		if ($f[2]){
		    $TwoToName{$f[1]} = $f[2];
		    $NameToTwo{$f[2]} = $f[1];
		}
	    }
	    if ($f[2]){
		$ThreeToName{$f[0]} = $f[2];
		$NameToThree{lc($f[2])} = $f[0];
	    }
	}
    }
}

sub _read_nonstandard_code_table{    
    ## non-standard codes
    # print STDERR "read non-standard codes";
    while (<DATA>){
	chomp;
	last unless ($_);
	my @f = split(/\t/);
	next unless ($f[0]);
	unless (exists $ThreeToThree{$f[0]}){
	    # $ThreeToThree{$f[0]} = $f[1] ? $f[1] : $f[0];
	    $ThreeToThree{$f[0]} = $f[1] if ($f[1]);
	    if ($f[2]){
		$ThreeToTwo{$f[0]}   = $f[2];
	    }
	    $ThreeToMacro{$f[0]} = $f[3] if ($f[3]);
	    if ($f[4]){
		$ThreeToName{$f[0]}     = $f[4];
	    }
	}
	if ($f[4]){
	    $NameToThree{lc($f[4])} = $f[0] unless (exists $NameToThree{$f[4]});
	    if ($f[2]){
		$NameToTwo{lc($f[4])} = $f[2] unless (exists $NameToTwo{$f[4]});
	    }
	}
	if ($f[2]){
	    $TwoToThree{$f[2]} = $f[1] ? $f[1] : $f[0] unless (exists $TwoToThree{$f[2]});
	    if ($f[4]){
		$TwoToName{$f[2]} = $f[4] unless (exists $TwoToName{$f[2]});
	    }
	}
    }
}


sub _read_main_code_table{
    while (<DATA>){
	chomp;
	return unless ($_);
	my @f = split(/\t/);
	next unless ($f[0]);
	$ThreeToName{$f[0]} = $f[6];
	# $ThreeToThree{$f[0]} = $f[0];
	$NameToThree{lc($f[6])} = $f[0];
	if ($f[3]){
	    $ThreeToTwo{$f[0]}    = $f[3];
	    $TwoToThree{$f[3]}    = $f[0];
	    $TwoToName{$f[3]}     = $f[6];
	    $NameToTwo{lc($f[6])} = $f[3];
	}
	if ($f[1]){
	    $ThreeToThree{$f[1]} = $f[0];
	    $ThreeToName{$f[1]} = $f[6];
	    if ($f[3]){
		$ThreeToTwo{$f[1]} = $f[3];
	    }
	}
	if ($f[2]){
	    $ThreeToThree{$f[2]} = $f[0];
	    $ThreeToName{$f[2]} = $f[6];
	    if ($f[3]){
		$ThreeToTwo{$f[2]} = $f[3];
	    }
	}
    }
}

sub _read_iso639_5{
    ## collective languages from ISO639-2
    # print STDERR "read collective language codes";
    while (<DATA>){
	chomp;
	return unless ($_);
	## URI code English-name French-name
	my @f = split(/\t/);
	next unless ($f[0]);
	$ThreeToName{$f[1]} = $f[2];
	$NameToThree{lc($f[2])} = $f[1];
    }
}


=head1 AUTHOR

Joerg Tiedemann, C<< <tiedemann at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-iso-639-3 at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=ISO-639-3>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 ACKNOWLEDGEMENTS

The language codes are taken from SIL International L<https://iso639-3.sil.org>. Please, check the terms of use listed at L<https://iso639-3.sil.org/code_tables/download_tables>. The current version uses the UTF-8 tables distributed in C< iso-639-3_Code_Tables_20200130.zip> from that website. This module adds some non-standard codes that are not specified in the original tables to be compatible with some ad-hoc solutions in some resources and tools.


=head1 LICENSE AND COPYRIGHT

 ---------------------------------------------------------------------------
 Copyright (c) 2020 Joerg Tiedemann

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 ---------------------------------------------------------------------------

=cut
