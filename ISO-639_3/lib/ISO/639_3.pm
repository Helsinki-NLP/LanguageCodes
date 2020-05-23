#!/usr/bin/env perl
#-*-perl-*-
#
# convert between 2-letter and 3-letter language codes
#
# USAGE: ./iso639 [-2|-3|-m] [langcode]*
#
# convert to 3-letter-code if 2-letter code is given and vice versa
# -2 ... print 2-letter code (even if the input is a 2-letter code)
# -3 ... print 3-letter code (even if the input is a 3-letter code)
# -m ... print macro language instead of local language variants
# -n ... don't print a final new-line
#

## make this a module
package ISO::639_3;

# use 5.006;
use strict;
use warnings;

use utf8;
use open ':locale';
use vars qw($opt_2 $opt_3 $opt_m $opt_n);
use Getopt::Std;

=head1 NAME

ISO::639_3 - Language codes and names from ISO::639

=head1 VERSION

Version 0.01

=cut

our $VERSION      = '0.01';

use Exporter 'import';
our @EXPORT = qw(
    convert_iso639
    get_iso639_1
    get_iso639_3
    get_macro_language
    get_language_name
);
our %EXPORT_TAGS = ( all => \@EXPORT );


=head1 SYNOPSIS

The module provides simple functions for retrieving language names and codes from the ISO-639 standards. The main purpose is to convert between different variants of codes and to get the English names of languages from codes. The module contains basic functions. There is no object-oriented interface. All functions can be exported.

    use ISO::639_3 qw/:all/;

    print convert_iso639( 'iso639-1', 'fra' );
    print convert_iso639( 'iso639-3', 'de' );
    print convert_iso639( 'name', 'fa' );

    print get_iso639_1( 'deu' );
    print get_iso639_3( 'de' );
    print get_language_name( 'de' );
    print get_language_name( 'eng' );
    print get_macro_language( 'yue' );

The module can be run as a script:

  perl ISO/639_3.pm [OPTIONS] LANGCODE*

This converts all language codes given as LANGCODE to corresponding language names. OPTIONS can be set to convert between different variants of language codes or to convert from language names to codes.

=head2 OPTIONS

  -2: convert to two-letter code (ISO 639-1)
  -3: convert to three-letter code (ISO 639-3)
  -m: convert to three-letter code but return the macro-language if available (ISO 639-3)

=back

=cut

our %TwoToThree   = ();
our %ThreeToTwo   = ();
our %ThreeToThree = ();
our %ThreeToMacro = ();
our %NameToTwo    = ();
our %NameToThree  = ();
our %TwoToName    = ();
our %ThreeToName  = ();

&_read_iso639_codes;

## run the script if not called as a module
__PACKAGE__->run() unless caller();

## function to run if this is used as a script
sub run{
    &getopts('23mn');
    my $type = $opt_2 ? 'iso639-1' : $opt_3 ? 'iso639-3' : $opt_m ? 'macro' : 'name';
    my @converted = map($_ = convert_iso639($type,$_), @ARGV);
    if ($type eq 'name' and @converted){
	print '"',join('" "',@converted),'"';
    }
    else{
	print join(' ',@converted);
    }
    print "\n" unless ($opt_n);
}


=head1 SUBROUTINES

=head2 $converted = convert_iso639( $type, $id )

Convert the language code or language name given in C<$id>. The C<$type> specifies the output type that is generated. Possible types are C<iso639-1> (two-letter code), C<iso639-3> (three-letter-code), C<macro> (three-letter code of the corresponding macro language) or C<name> (language name). Default is to return the language name. Regional codes are stripped from the input language ID.

=cut

sub convert_iso639{
    my $code = lc($_[1]);
    $code=~s/[\-\_].*$//;
    return get_iso639_1($code)       if ($_[0] eq 'iso639-1');
    return get_iso639_3($code)       if ($_[0] eq 'iso639-3');
    return get_macro_language($code) if ($_[0] eq 'macro');
    return get_language_name($code);
}


=head2 $iso639_1 = get_iso639_1( $id )

Return the ISO 639-1 code for a given language or three-letter code. Returns the same code if it is a ISO 639-1 code or 'xx' if it is not recognized.

=cut

sub get_iso639_1{
    return $ThreeToTwo{$_[0]}    if (exists $ThreeToTwo{$_[0]});
    return $NameToTwo{lc($_[0])} if (exists $NameToTwo{lc($_[0])});
    return $_[0]                 if (exists $TwoToThree{$_[0]});
    ## TODO: is it OK to fallback to macro language in this conversion?
    ##       (should we add some regional code?)
    if (exists $ThreeToMacro{$_[0]}){
	return $ThreeToTwo{$ThreeToMacro{$_[0]}} 
	if (exists $ThreeToTwo{$ThreeToMacro{$_[0]}});
    }
    return 'xx';
}

=head2 $iso639_3 = get_iso639_3( $id )

Return the ISO 639-3 code for a given language or any ISO 639 code. Returns 'xxx' if the code is not recognized.

=cut

sub get_iso639_3{
    return $TwoToThree{$_[0]}      if (exists $TwoToThree{$_[0]});
    return $NameToThree{lc($_[0])} if (exists $NameToThree{lc($_[0])});
    return $ThreeToThree{$_[0]}    if (exists $ThreeToThree{$_[0]});
    return 'xxx';
}


=head2 $macro_language = get_macro_language( $id )

Return the ISO 639-3 code of the macro language for a given language or any ISO 639 code. Returns 'xxx' if the code is not recognized.

=cut


sub get_macro_language{
    my $code = get_iso639_3($_[0]);
    return $ThreeToMacro{$code} if (exists $ThreeToMacro{$code});
    return $code;
}

=head2 $language = get_language_name( $id )

Return the name of the language that corresponds to the given language code (any ISO639 code)

=cut

sub get_language_name{
    return $TwoToName{$_[0]}   if (exists $TwoToName{$_[0]});
    return $ThreeToName{$_[0]} if (exists $ThreeToName{$_[0]});
    return $_[0]               if (exists $NameToThree{$_[0]});
    return 'unknown';
}








####################################
# internal functions that
# read all codes from the data part
####################################

## read all codes
sub _read_iso639_codes{
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
	elsif ($f[4] eq 'Ret_Remedy'){
	    &_read_retired_code_table();
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
	    $ThreeToThree{$f[0]} = $f[2] ? $f[2] : $f[0];
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
	$ThreeToThree{$f[1]} = $f[1];
	$ThreeToMacro{$f[1]} = $f[0];
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
	    $ThreeToThree{$f[0]} = $f[1] ? $f[1] : $f[0];
	    if ($f[2]){
		$ThreeToTwo{$f[0]}   = $f[2];
		$TwoToThree{$f[2]}   = $f[0];
	    }
	    $ThreeToMacro{$f[0]} = $f[3] if ($f[3]);
	    if ($f[4]){
		$ThreeToName{$f[0]}     = $f[4];
		$NameToThree{lc($f[4])} = $f[0];
		$NameToTwo{lc($f[4])}   = $f[2] if ($f[2]);
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
	$ThreeToThree{$f[0]} = $f[0];
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

=head1 AUTHOR

Joerg Tiedemann, C<< <tiedemann at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-iso-639_3 at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=ISO-639_3>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISO::639_3


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=ISO-639_3>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ISO-639_3>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/ISO-639_3>

=item * Search CPAN

L<https://metacpan.org/release/ISO-639_3>

=back


=head1 ACKNOWLEDGEMENTS

The language codes are taken from SIL International L<https://iso639-3.sil.org>. Please, check the terms of use listed at L<https://iso639-3.sil.org/code_tables/download_tables>. The current version uses the UTF-8 tables distributed in C< iso-639-3_Code_Tables_20200130.zip> from that website. This module adds some non-standard codes that are not specified in the original tables to be compatible with some ad-hoc solutions in some resources and tools.


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by Joerg Tiedemann.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of ISO::639_3

__DATA__

Id	Part2B	Part2T	Part1	Scope	Language_Type	Ref_Name	Comment
aaa				I	L	Ghotuo	
aab				I	L	Alumu-Tesu	
aac				I	L	Ari	
aad				I	L	Amal	
aae				I	L	Arbëreshë Albanian	
aaf				I	L	Aranadan	
aag				I	L	Ambrak	
aah				I	L	Abu' Arapesh	
aai				I	L	Arifama-Miniafia	
aak				I	L	Ankave	
aal				I	L	Afade	
aan				I	L	Anambé	
aao				I	L	Algerian Saharan Arabic	
aap				I	L	Pará Arára	
aaq				I	E	Eastern Abnaki	
aar	aar	aar	aa	I	L	Afar	
aas				I	L	Aasáx	
aat				I	L	Arvanitika Albanian	
aau				I	L	Abau	
aaw				I	L	Solong	
aax				I	L	Mandobo Atas	
aaz				I	L	Amarasi	
aba				I	L	Abé	
abb				I	L	Bankon	
abc				I	L	Ambala Ayta	
abd				I	L	Manide	
abe				I	L	Western Abnaki	
abf				I	L	Abai Sungai	
abg				I	L	Abaga	
abh				I	L	Tajiki Arabic	
abi				I	L	Abidji	
abj				I	E	Aka-Bea	
abk	abk	abk	ab	I	L	Abkhazian	
abl				I	L	Lampung Nyo	
abm				I	L	Abanyom	
abn				I	L	Abua	
abo				I	L	Abon	
abp				I	L	Abellen Ayta	
abq				I	L	Abaza	
abr				I	L	Abron	
abs				I	L	Ambonese Malay	
abt				I	L	Ambulas	
abu				I	L	Abure	
abv				I	L	Baharna Arabic	
abw				I	L	Pal	
abx				I	L	Inabaknon	
aby				I	L	Aneme Wake	
abz				I	L	Abui	
aca				I	L	Achagua	
acb				I	L	Áncá	
acd				I	L	Gikyode	
ace	ace	ace		I	L	Achinese	
acf				I	L	Saint Lucian Creole French	
ach	ach	ach		I	L	Acoli	
aci				I	E	Aka-Cari	
ack				I	E	Aka-Kora	
acl				I	E	Akar-Bale	
acm				I	L	Mesopotamian Arabic	
acn				I	L	Achang	
acp				I	L	Eastern Acipa	
acq				I	L	Ta'izzi-Adeni Arabic	
acr				I	L	Achi	
acs				I	E	Acroá	
act				I	L	Achterhoeks	
acu				I	L	Achuar-Shiwiar	
acv				I	L	Achumawi	
acw				I	L	Hijazi Arabic	
acx				I	L	Omani Arabic	
acy				I	L	Cypriot Arabic	
acz				I	L	Acheron	
ada	ada	ada		I	L	Adangme	
adb				I	L	Atauran	
add				I	L	Lidzonka	
ade				I	L	Adele	
adf				I	L	Dhofari Arabic	
adg				I	L	Andegerebinha	
adh				I	L	Adhola	
adi				I	L	Adi	
adj				I	L	Adioukrou	
adl				I	L	Galo	
adn				I	L	Adang	
ado				I	L	Abu	
adq				I	L	Adangbe	
adr				I	L	Adonara	
ads				I	L	Adamorobe Sign Language	
adt				I	L	Adnyamathanha	
adu				I	L	Aduge	
adw				I	L	Amundava	
adx				I	L	Amdo Tibetan	
ady	ady	ady		I	L	Adyghe	
adz				I	L	Adzera	
aea				I	E	Areba	
aeb				I	L	Tunisian Arabic	
aec				I	L	Saidi Arabic	
aed				I	L	Argentine Sign Language	
aee				I	L	Northeast Pashai	
aek				I	L	Haeke	
ael				I	L	Ambele	
aem				I	L	Arem	
aen				I	L	Armenian Sign Language	
aeq				I	L	Aer	
aer				I	L	Eastern Arrernte	
aes				I	E	Alsea	
aeu				I	L	Akeu	
aew				I	L	Ambakich	
aey				I	L	Amele	
aez				I	L	Aeka	
afb				I	L	Gulf Arabic	
afd				I	L	Andai	
afe				I	L	Putukwam	
afg				I	L	Afghan Sign Language	
afh	afh	afh		I	C	Afrihili	
afi				I	L	Akrukay	
afk				I	L	Nanubae	
afn				I	L	Defaka	
afo				I	L	Eloyi	
afp				I	L	Tapei	
afr	afr	afr	af	I	L	Afrikaans	
afs				I	L	Afro-Seminole Creole	
aft				I	L	Afitti	
afu				I	L	Awutu	
afz				I	L	Obokuitai	
aga				I	E	Aguano	
agb				I	L	Legbo	
agc				I	L	Agatu	
agd				I	L	Agarabi	
age				I	L	Angal	
agf				I	L	Arguni	
agg				I	L	Angor	
agh				I	L	Ngelima	
agi				I	L	Agariya	
agj				I	L	Argobba	
agk				I	L	Isarog Agta	
agl				I	L	Fembe	
agm				I	L	Angaataha	
agn				I	L	Agutaynen	
ago				I	L	Tainae	
agq				I	L	Aghem	
agr				I	L	Aguaruna	
ags				I	L	Esimbi	
agt				I	L	Central Cagayan Agta	
agu				I	L	Aguacateco	
agv				I	L	Remontado Dumagat	
agw				I	L	Kahua	
agx				I	L	Aghul	
agy				I	L	Southern Alta	
agz				I	L	Mt. Iriga Agta	
aha				I	L	Ahanta	
ahb				I	L	Axamb	
ahg				I	L	Qimant	
ahh				I	L	Aghu	
ahi				I	L	Tiagbamrin Aizi	
ahk				I	L	Akha	
ahl				I	L	Igo	
ahm				I	L	Mobumrin Aizi	
ahn				I	L	Àhàn	
aho				I	E	Ahom	
ahp				I	L	Aproumu Aizi	
ahr				I	L	Ahirani	
ahs				I	L	Ashe	
aht				I	L	Ahtena	
aia				I	L	Arosi	
aib				I	L	Ainu (China)	
aic				I	L	Ainbai	
aid				I	E	Alngith	
aie				I	L	Amara	
aif				I	L	Agi	
aig				I	L	Antigua and Barbuda Creole English	
aih				I	L	Ai-Cham	
aii				I	L	Assyrian Neo-Aramaic	
aij				I	L	Lishanid Noshan	
aik				I	L	Ake	
ail				I	L	Aimele	
aim				I	L	Aimol	
ain	ain	ain		I	L	Ainu (Japan)	
aio				I	L	Aiton	
aip				I	L	Burumakok	
aiq				I	L	Aimaq	
air				I	L	Airoran	
ait				I	E	Arikem	
aiw				I	L	Aari	
aix				I	L	Aighon	
aiy				I	L	Ali	
aja				I	L	Aja (South Sudan)	
ajg				I	L	Aja (Benin)	
aji				I	L	Ajië	
ajn				I	L	Andajin	
ajp				I	L	South Levantine Arabic	
ajt				I	L	Judeo-Tunisian Arabic	
aju				I	L	Judeo-Moroccan Arabic	
ajw				I	E	Ajawa	
ajz				I	L	Amri Karbi	
aka	aka	aka	ak	M	L	Akan	
akb				I	L	Batak Angkola	
akc				I	L	Mpur	
akd				I	L	Ukpet-Ehom	
ake				I	L	Akawaio	
akf				I	L	Akpa	
akg				I	L	Anakalangu	
akh				I	L	Angal Heneng	
aki				I	L	Aiome	
akj				I	E	Aka-Jeru	
akk	akk	akk		I	A	Akkadian	
akl				I	L	Aklanon	
akm				I	E	Aka-Bo	
ako				I	L	Akurio	
akp				I	L	Siwu	
akq				I	L	Ak	
akr				I	L	Araki	
aks				I	L	Akaselem	
akt				I	L	Akolet	
aku				I	L	Akum	
akv				I	L	Akhvakh	
akw				I	L	Akwa	
akx				I	E	Aka-Kede	
aky				I	E	Aka-Kol	
akz				I	L	Alabama	
ala				I	L	Alago	
alc				I	L	Qawasqar	
ald				I	L	Alladian	
ale	ale	ale		I	L	Aleut	
alf				I	L	Alege	
alh				I	L	Alawa	
ali				I	L	Amaimon	
alj				I	L	Alangan	
alk				I	L	Alak	
all				I	L	Allar	
alm				I	L	Amblong	
aln				I	L	Gheg Albanian	
alo				I	L	Larike-Wakasihu	
alp				I	L	Alune	
alq				I	L	Algonquin	
alr				I	L	Alutor	
als				I	L	Tosk Albanian	
alt	alt	alt		I	L	Southern Altai	
alu				I	L	'Are'are	
alw				I	L	Alaba-K’abeena	
alx				I	L	Amol	
aly				I	L	Alyawarr	
alz				I	L	Alur	
ama				I	E	Amanayé	
amb				I	L	Ambo	
amc				I	L	Amahuaca	
ame				I	L	Yanesha'	
amf				I	L	Hamer-Banna	
amg				I	L	Amurdak	
amh	amh	amh	am	I	L	Amharic	
ami				I	L	Amis	
amj				I	L	Amdang	
amk				I	L	Ambai	
aml				I	L	War-Jaintia	
amm				I	L	Ama (Papua New Guinea)	
amn				I	L	Amanab	
amo				I	L	Amo	
amp				I	L	Alamblak	
amq				I	L	Amahai	
amr				I	L	Amarakaeri	
ams				I	L	Southern Amami-Oshima	
amt				I	L	Amto	
amu				I	L	Guerrero Amuzgo	
amv				I	L	Ambelau	
amw				I	L	Western Neo-Aramaic	
amx				I	L	Anmatyerre	
amy				I	L	Ami	
amz				I	E	Atampaya	
ana				I	E	Andaqui	
anb				I	E	Andoa	
anc				I	L	Ngas	
and				I	L	Ansus	
ane				I	L	Xârâcùù	
anf				I	L	Animere	
ang	ang	ang		I	H	Old English (ca. 450-1100)	
anh				I	L	Nend	
ani				I	L	Andi	
anj				I	L	Anor	
ank				I	L	Goemai	
anl				I	L	Anu-Hkongso Chin	
anm				I	L	Anal	
ann				I	L	Obolo	
ano				I	L	Andoque	
anp	anp	anp		I	L	Angika	
anq				I	L	Jarawa (India)	
anr				I	L	Andh	
ans				I	E	Anserma	
ant				I	L	Antakarinya	
anu				I	L	Anuak	
anv				I	L	Denya	
anw				I	L	Anaang	
anx				I	L	Andra-Hus	
any				I	L	Anyin	
anz				I	L	Anem	
aoa				I	L	Angolar	
aob				I	L	Abom	
aoc				I	L	Pemon	
aod				I	L	Andarum	
aoe				I	L	Angal Enen	
aof				I	L	Bragat	
aog				I	L	Angoram	
aoi				I	L	Anindilyakwa	
aoj				I	L	Mufian	
aok				I	L	Arhö	
aol				I	L	Alor	
aom				I	L	Ömie	
aon				I	L	Bumbita Arapesh	
aor				I	E	Aore	
aos				I	L	Taikat	
aot				I	L	Atong (India)	
aou				I	L	A'ou	
aox				I	L	Atorada	
aoz				I	L	Uab Meto	
apb				I	L	Sa'a	
apc				I	L	North Levantine Arabic	
apd				I	L	Sudanese Arabic	
ape				I	L	Bukiyip	
apf				I	L	Pahanan Agta	
apg				I	L	Ampanang	
aph				I	L	Athpariya	
api				I	L	Apiaká	
apj				I	L	Jicarilla Apache	
apk				I	L	Kiowa Apache	
apl				I	L	Lipan Apache	
apm				I	L	Mescalero-Chiricahua Apache	
apn				I	L	Apinayé	
apo				I	L	Ambul	
app				I	L	Apma	
apq				I	L	A-Pucikwar	
apr				I	L	Arop-Lokep	
aps				I	L	Arop-Sissano	
apt				I	L	Apatani	
apu				I	L	Apurinã	
apv				I	E	Alapmunte	
apw				I	L	Western Apache	
apx				I	L	Aputai	
apy				I	L	Apalaí	
apz				I	L	Safeyoka	
aqc				I	L	Archi	
aqd				I	L	Ampari Dogon	
aqg				I	L	Arigidi	
aqm				I	L	Atohwaim	
aqn				I	L	Northern Alta	
aqp				I	E	Atakapa	
aqr				I	L	Arhâ	
aqt				I	L	Angaité	
aqz				I	L	Akuntsu	
ara	ara	ara	ar	M	L	Arabic	
arb				I	L	Standard Arabic	
arc	arc	arc		I	A	Official Aramaic (700-300 BCE)	
ard				I	E	Arabana	
are				I	L	Western Arrarnta	
arg	arg	arg	an	I	L	Aragonese	
arh				I	L	Arhuaco	
ari				I	L	Arikara	
arj				I	E	Arapaso	
ark				I	L	Arikapú	
arl				I	L	Arabela	
arn	arn	arn		I	L	Mapudungun	
aro				I	L	Araona	
arp	arp	arp		I	L	Arapaho	
arq				I	L	Algerian Arabic	
arr				I	L	Karo (Brazil)	
ars				I	L	Najdi Arabic	
aru				I	E	Aruá (Amazonas State)	
arv				I	L	Arbore	
arw	arw	arw		I	L	Arawak	
arx				I	L	Aruá (Rodonia State)	
ary				I	L	Moroccan Arabic	
arz				I	L	Egyptian Arabic	
asa				I	L	Asu (Tanzania)	
asb				I	L	Assiniboine	
asc				I	L	Casuarina Coast Asmat	
ase				I	L	American Sign Language	
asf				I	L	Auslan	
asg				I	L	Cishingini	
ash				I	E	Abishira	
asi				I	L	Buruwai	
asj				I	L	Sari	
ask				I	L	Ashkun	
asl				I	L	Asilulu	
asm	asm	asm	as	I	L	Assamese	
asn				I	L	Xingú Asuriní	
aso				I	L	Dano	
asp				I	L	Algerian Sign Language	
asq				I	L	Austrian Sign Language	
asr				I	L	Asuri	
ass				I	L	Ipulo	
ast	ast	ast		I	L	Asturian	
asu				I	L	Tocantins Asurini	
asv				I	L	Asoa	
asw				I	L	Australian Aborigines Sign Language	
asx				I	L	Muratayak	
asy				I	L	Yaosakor Asmat	
asz				I	L	As	
ata				I	L	Pele-Ata	
atb				I	L	Zaiwa	
atc				I	E	Atsahuaca	
atd				I	L	Ata Manobo	
ate				I	L	Atemble	
atg				I	L	Ivbie North-Okpela-Arhe	
ati				I	L	Attié	
atj				I	L	Atikamekw	
atk				I	L	Ati	
atl				I	L	Mt. Iraya Agta	
atm				I	L	Ata	
atn				I	L	Ashtiani	
ato				I	L	Atong (Cameroon)	
atp				I	L	Pudtol Atta	
atq				I	L	Aralle-Tabulahan	
atr				I	L	Waimiri-Atroari	
ats				I	L	Gros Ventre	
att				I	L	Pamplona Atta	
atu				I	L	Reel	
atv				I	L	Northern Altai	
atw				I	L	Atsugewi	
atx				I	L	Arutani	
aty				I	L	Aneityum	
atz				I	L	Arta	
aua				I	L	Asumboa	
aub				I	L	Alugu	
auc				I	L	Waorani	
aud				I	L	Anuta	
aug				I	L	Aguna	
auh				I	L	Aushi	
aui				I	L	Anuki	
auj				I	L	Awjilah	
auk				I	L	Heyo	
aul				I	L	Aulua	
aum				I	L	Asu (Nigeria)	
aun				I	L	Molmo One	
auo				I	E	Auyokawa	
aup				I	L	Makayam	
auq				I	L	Anus	
aur				I	L	Aruek	
aut				I	L	Austral	
auu				I	L	Auye	
auw				I	L	Awyi	
aux				I	E	Aurá	
auy				I	L	Awiyaana	
auz				I	L	Uzbeki Arabic	
ava	ava	ava	av	I	L	Avaric	
avb				I	L	Avau	
avd				I	L	Alviri-Vidari	
ave	ave	ave	ae	I	A	Avestan	
avi				I	L	Avikam	
avk				I	C	Kotava	
avl				I	L	Eastern Egyptian Bedawi Arabic	
avm				I	E	Angkamuthi	
avn				I	L	Avatime	
avo				I	E	Agavotaguerra	
avs				I	E	Aushiri	
avt				I	L	Au	
avu				I	L	Avokaya	
avv				I	L	Avá-Canoeiro	
awa	awa	awa		I	L	Awadhi	
awb				I	L	Awa (Papua New Guinea)	
awc				I	L	Cicipu	
awe				I	L	Awetí	
awg				I	E	Anguthimri	
awh				I	L	Awbono	
awi				I	L	Aekyom	
awk				I	E	Awabakal	
awm				I	L	Arawum	
awn				I	L	Awngi	
awo				I	L	Awak	
awr				I	L	Awera	
aws				I	L	South Awyu	
awt				I	L	Araweté	
awu				I	L	Central Awyu	
awv				I	L	Jair Awyu	
aww				I	L	Awun	
awx				I	L	Awara	
awy				I	L	Edera Awyu	
axb				I	E	Abipon	
axe				I	E	Ayerrerenge	
axg				I	E	Mato Grosso Arára	
axk				I	L	Yaka (Central African Republic)	
axl				I	E	Lower Southern Aranda	
axm				I	H	Middle Armenian	
axx				I	L	Xârâgurè	
aya				I	L	Awar	
ayb				I	L	Ayizo Gbe	
ayc				I	L	Southern Aymara	
ayd				I	E	Ayabadhu	
aye				I	L	Ayere	
ayg				I	L	Ginyanga	
ayh				I	L	Hadrami Arabic	
ayi				I	L	Leyigha	
ayk				I	L	Akuku	
ayl				I	L	Libyan Arabic	
aym	aym	aym	ay	M	L	Aymara	
ayn				I	L	Sanaani Arabic	
ayo				I	L	Ayoreo	
ayp				I	L	North Mesopotamian Arabic	
ayq				I	L	Ayi (Papua New Guinea)	
ayr				I	L	Central Aymara	
ays				I	L	Sorsogon Ayta	
ayt				I	L	Magbukun Ayta	
ayu				I	L	Ayu	
ayz				I	L	Mai Brat	
aza				I	L	Azha	
azb				I	L	South Azerbaijani	
azd				I	L	Eastern Durango Nahuatl	
aze	aze	aze	az	M	L	Azerbaijani	
azg				I	L	San Pedro Amuzgos Amuzgo	
azj				I	L	North Azerbaijani	
azm				I	L	Ipalapa Amuzgo	
azn				I	L	Western Durango Nahuatl	
azo				I	L	Awing	
azt				I	L	Faire Atta	
azz				I	L	Highland Puebla Nahuatl	
baa				I	L	Babatana	
bab				I	L	Bainouk-Gunyuño	
bac				I	L	Badui	
bae				I	E	Baré	
baf				I	L	Nubaca	
bag				I	L	Tuki	
bah				I	L	Bahamas Creole English	
baj				I	L	Barakai	
bak	bak	bak	ba	I	L	Bashkir	
bal	bal	bal		M	L	Baluchi	
bam	bam	bam	bm	I	L	Bambara	
ban	ban	ban		I	L	Balinese	
bao				I	L	Waimaha	
bap				I	L	Bantawa	
bar				I	L	Bavarian	
bas	bas	bas		I	L	Basa (Cameroon)	
bau				I	L	Bada (Nigeria)	
bav				I	L	Vengo	
baw				I	L	Bambili-Bambui	
bax				I	L	Bamun	
bay				I	L	Batuley	
bba				I	L	Baatonum	
bbb				I	L	Barai	
bbc				I	L	Batak Toba	
bbd				I	L	Bau	
bbe				I	L	Bangba	
bbf				I	L	Baibai	
bbg				I	L	Barama	
bbh				I	L	Bugan	
bbi				I	L	Barombi	
bbj				I	L	Ghomálá'	
bbk				I	L	Babanki	
bbl				I	L	Bats	
bbm				I	L	Babango	
bbn				I	L	Uneapa	
bbo				I	L	Northern Bobo Madaré	
bbp				I	L	West Central Banda	
bbq				I	L	Bamali	
bbr				I	L	Girawa	
bbs				I	L	Bakpinka	
bbt				I	L	Mburku	
bbu				I	L	Kulung (Nigeria)	
bbv				I	L	Karnai	
bbw				I	L	Baba	
bbx				I	L	Bubia	
bby				I	L	Befang	
bca				I	L	Central Bai	
bcb				I	L	Bainouk-Samik	
bcc				I	L	Southern Balochi	
bcd				I	L	North Babar	
bce				I	L	Bamenyam	
bcf				I	L	Bamu	
bcg				I	L	Baga Pokur	
bch				I	L	Bariai	
bci				I	L	Baoulé	
bcj				I	L	Bardi	
bck				I	L	Bunuba	
bcl				I	L	Central Bikol	
bcm				I	L	Bannoni	
bcn				I	L	Bali (Nigeria)	
bco				I	L	Kaluli	
bcp				I	L	Bali (Democratic Republic of Congo)	
bcq				I	L	Bench	
bcr				I	L	Babine	
bcs				I	L	Kohumono	
bct				I	L	Bendi	
bcu				I	L	Awad Bing	
bcv				I	L	Shoo-Minda-Nye	
bcw				I	L	Bana	
bcy				I	L	Bacama	
bcz				I	L	Bainouk-Gunyaamolo	
bda				I	L	Bayot	
bdb				I	L	Basap	
bdc				I	L	Emberá-Baudó	
bdd				I	L	Bunama	
bde				I	L	Bade	
bdf				I	L	Biage	
bdg				I	L	Bonggi	
bdh				I	L	Baka (South Sudan)	
bdi				I	L	Burun	
bdj				I	L	Bai (South Sudan)	
bdk				I	L	Budukh	
bdl				I	L	Indonesian Bajau	
bdm				I	L	Buduma	
bdn				I	L	Baldemu	
bdo				I	L	Morom	
bdp				I	L	Bende	
bdq				I	L	Bahnar	
bdr				I	L	West Coast Bajau	
bds				I	L	Burunge	
bdt				I	L	Bokoto	
bdu				I	L	Oroko	
bdv				I	L	Bodo Parja	
bdw				I	L	Baham	
bdx				I	L	Budong-Budong	
bdy				I	L	Bandjalang	
bdz				I	L	Badeshi	
bea				I	L	Beaver	
beb				I	L	Bebele	
bec				I	L	Iceve-Maci	
bed				I	L	Bedoanas	
bee				I	L	Byangsi	
bef				I	L	Benabena	
beg				I	L	Belait	
beh				I	L	Biali	
bei				I	L	Bekati'	
bej	bej	bej		I	L	Beja	
bek				I	L	Bebeli	
bel	bel	bel	be	I	L	Belarusian	
bem	bem	bem		I	L	Bemba (Zambia)	
ben	ben	ben	bn	I	L	Bengali	
beo				I	L	Beami	
bep				I	L	Besoa	
beq				I	L	Beembe	
bes				I	L	Besme	
bet				I	L	Guiberoua Béte	
beu				I	L	Blagar	
bev				I	L	Daloa Bété	
bew				I	L	Betawi	
bex				I	L	Jur Modo	
bey				I	L	Beli (Papua New Guinea)	
bez				I	L	Bena (Tanzania)	
bfa				I	L	Bari	
bfb				I	L	Pauri Bareli	
bfc				I	L	Panyi Bai	
bfd				I	L	Bafut	
bfe				I	L	Betaf	
bff				I	L	Bofi	
bfg				I	L	Busang Kayan	
bfh				I	L	Blafe	
bfi				I	L	British Sign Language	
bfj				I	L	Bafanji	
bfk				I	L	Ban Khor Sign Language	
bfl				I	L	Banda-Ndélé	
bfm				I	L	Mmen	
bfn				I	L	Bunak	
bfo				I	L	Malba Birifor	
bfp				I	L	Beba	
bfq				I	L	Badaga	
bfr				I	L	Bazigar	
bfs				I	L	Southern Bai	
bft				I	L	Balti	
bfu				I	L	Gahri	
bfw				I	L	Bondo	
bfx				I	L	Bantayanon	
bfy				I	L	Bagheli	
bfz				I	L	Mahasu Pahari	
bga				I	L	Gwamhi-Wuri	
bgb				I	L	Bobongko	
bgc				I	L	Haryanvi	
bgd				I	L	Rathwi Bareli	
bge				I	L	Bauria	
bgf				I	L	Bangandu	
bgg				I	L	Bugun	
bgi				I	L	Giangan	
bgj				I	L	Bangolan	
bgk				I	L	Bit	
bgl				I	L	Bo (Laos)	
bgn				I	L	Western Balochi	
bgo				I	L	Baga Koga	
bgp				I	L	Eastern Balochi	
bgq				I	L	Bagri	
bgr				I	L	Bawm Chin	
bgs				I	L	Tagabawa	
bgt				I	L	Bughotu	
bgu				I	L	Mbongno	
bgv				I	L	Warkay-Bipim	
bgw				I	L	Bhatri	
bgx				I	L	Balkan Gagauz Turkish	
bgy				I	L	Benggoi	
bgz				I	L	Banggai	
bha				I	L	Bharia	
bhb				I	L	Bhili	
bhc				I	L	Biga	
bhd				I	L	Bhadrawahi	
bhe				I	L	Bhaya	
bhf				I	L	Odiai	
bhg				I	L	Binandere	
bhh				I	L	Bukharic	
bhi				I	L	Bhilali	
bhj				I	L	Bahing	
bhl				I	L	Bimin	
bhm				I	L	Bathari	
bhn				I	L	Bohtan Neo-Aramaic	
bho	bho	bho		I	L	Bhojpuri	
bhp				I	L	Bima	
bhq				I	L	Tukang Besi South	
bhr				I	L	Bara Malagasy	
bhs				I	L	Buwal	
bht				I	L	Bhattiyali	
bhu				I	L	Bhunjia	
bhv				I	L	Bahau	
bhw				I	L	Biak	
bhx				I	L	Bhalay	
bhy				I	L	Bhele	
bhz				I	L	Bada (Indonesia)	
bia				I	L	Badimaya	
bib				I	L	Bissa	
bic				I	L	Bikaru	
bid				I	L	Bidiyo	
bie				I	L	Bepour	
bif				I	L	Biafada	
big				I	L	Biangai	
bij				I	L	Vaghat-Ya-Bijim-Legeri	
bik	bik	bik		M	L	Bikol	
bil				I	L	Bile	
bim				I	L	Bimoba	
bin	bin	bin		I	L	Bini	
bio				I	L	Nai	
bip				I	L	Bila	
biq				I	L	Bipi	
bir				I	L	Bisorio	
bis	bis	bis	bi	I	L	Bislama	
bit				I	L	Berinomo	
biu				I	L	Biete	
biv				I	L	Southern Birifor	
biw				I	L	Kol (Cameroon)	
bix				I	L	Bijori	
biy				I	L	Birhor	
biz				I	L	Baloi	
bja				I	L	Budza	
bjb				I	E	Banggarla	
bjc				I	L	Bariji	
bje				I	L	Biao-Jiao Mien	
bjf				I	L	Barzani Jewish Neo-Aramaic	
bjg				I	L	Bidyogo	
bjh				I	L	Bahinemo	
bji				I	L	Burji	
bjj				I	L	Kanauji	
bjk				I	L	Barok	
bjl				I	L	Bulu (Papua New Guinea)	
bjm				I	L	Bajelani	
bjn				I	L	Banjar	
bjo				I	L	Mid-Southern Banda	
bjp				I	L	Fanamaket	
bjr				I	L	Binumarien	
bjs				I	L	Bajan	
bjt				I	L	Balanta-Ganja	
bju				I	L	Busuu	
bjv				I	L	Bedjond	
bjw				I	L	Bakwé	
bjx				I	L	Banao Itneg	
bjy				I	E	Bayali	
bjz				I	L	Baruga	
bka				I	L	Kyak	
bkc				I	L	Baka (Cameroon)	
bkd				I	L	Binukid	
bkf				I	L	Beeke	
bkg				I	L	Buraka	
bkh				I	L	Bakoko	
bki				I	L	Baki	
bkj				I	L	Pande	
bkk				I	L	Brokskat	
bkl				I	L	Berik	
bkm				I	L	Kom (Cameroon)	
bkn				I	L	Bukitan	
bko				I	L	Kwa'	
bkp				I	L	Boko (Democratic Republic of Congo)	
bkq				I	L	Bakairí	
bkr				I	L	Bakumpai	
bks				I	L	Northern Sorsoganon	
bkt				I	L	Boloki	
bku				I	L	Buhid	
bkv				I	L	Bekwarra	
bkw				I	L	Bekwel	
bkx				I	L	Baikeno	
bky				I	L	Bokyi	
bkz				I	L	Bungku	
bla	bla	bla		I	L	Siksika	
blb				I	L	Bilua	
blc				I	L	Bella Coola	
bld				I	L	Bolango	
ble				I	L	Balanta-Kentohe	
blf				I	L	Buol	
blg				I	L	Balau	
blh				I	L	Kuwaa	
bli				I	L	Bolia	
blj				I	L	Bolongan	
blk				I	L	Pa'o Karen	
bll				I	E	Biloxi	
blm				I	L	Beli (South Sudan)	
bln				I	L	Southern Catanduanes Bikol	
blo				I	L	Anii	
blp				I	L	Blablanga	
blq				I	L	Baluan-Pam	
blr				I	L	Blang	
bls				I	L	Balaesang	
blt				I	L	Tai Dam	
blv				I	L	Kibala	
blw				I	L	Balangao	
blx				I	L	Mag-Indi Ayta	
bly				I	L	Notre	
blz				I	L	Balantak	
bma				I	L	Lame	
bmb				I	L	Bembe	
bmc				I	L	Biem	
bmd				I	L	Baga Manduri	
bme				I	L	Limassa	
bmf				I	L	Bom-Kim	
bmg				I	L	Bamwe	
bmh				I	L	Kein	
bmi				I	L	Bagirmi	
bmj				I	L	Bote-Majhi	
bmk				I	L	Ghayavi	
bml				I	L	Bomboli	
bmm				I	L	Northern Betsimisaraka Malagasy	
bmn				I	E	Bina (Papua New Guinea)	
bmo				I	L	Bambalang	
bmp				I	L	Bulgebi	
bmq				I	L	Bomu	
bmr				I	L	Muinane	
bms				I	L	Bilma Kanuri	
bmt				I	L	Biao Mon	
bmu				I	L	Somba-Siawari	
bmv				I	L	Bum	
bmw				I	L	Bomwali	
bmx				I	L	Baimak	
bmz				I	L	Baramu	
bna				I	L	Bonerate	
bnb				I	L	Bookan	
bnc				M	L	Bontok	
bnd				I	L	Banda (Indonesia)	
bne				I	L	Bintauna	
bnf				I	L	Masiwang	
bng				I	L	Benga	
bni				I	L	Bangi	
bnj				I	L	Eastern Tawbuid	
bnk				I	L	Bierebo	
bnl				I	L	Boon	
bnm				I	L	Batanga	
bnn				I	L	Bunun	
bno				I	L	Bantoanon	
bnp				I	L	Bola	
bnq				I	L	Bantik	
bnr				I	L	Butmas-Tur	
bns				I	L	Bundeli	
bnu				I	L	Bentong	
bnv				I	L	Bonerif	
bnw				I	L	Bisis	
bnx				I	L	Bangubangu	
bny				I	L	Bintulu	
bnz				I	L	Beezen	
boa				I	L	Bora	
bob				I	L	Aweer	
bod	tib	bod	bo	I	L	Tibetan	
boe				I	L	Mundabli	
bof				I	L	Bolon	
bog				I	L	Bamako Sign Language	
boh				I	L	Boma	
boi				I	E	Barbareño	
boj				I	L	Anjam	
bok				I	L	Bonjo	
bol				I	L	Bole	
bom				I	L	Berom	
bon				I	L	Bine	
boo				I	L	Tiemacèwè Bozo	
bop				I	L	Bonkiman	
boq				I	L	Bogaya	
bor				I	L	Borôro	
bos	bos	bos	bs	I	L	Bosnian	
bot				I	L	Bongo	
bou				I	L	Bondei	
bov				I	L	Tuwuli	
bow				I	E	Rema	
box				I	L	Buamu	
boy				I	L	Bodo (Central African Republic)	
boz				I	L	Tiéyaxo Bozo	
bpa				I	L	Daakaka	
bpd				I	L	Banda-Banda	
bpg				I	L	Bonggo	
bph				I	L	Botlikh	
bpi				I	L	Bagupi	
bpj				I	L	Binji	
bpk				I	L	Orowe	
bpl				I	L	Broome Pearling Lugger Pidgin	
bpm				I	L	Biyom	
bpn				I	L	Dzao Min	
bpo				I	L	Anasi	
bpp				I	L	Kaure	
bpq				I	L	Banda Malay	
bpr				I	L	Koronadal Blaan	
bps				I	L	Sarangani Blaan	
bpt				I	E	Barrow Point	
bpu				I	L	Bongu	
bpv				I	L	Bian Marind	
bpw				I	L	Bo (Papua New Guinea)	
bpx				I	L	Palya Bareli	
bpy				I	L	Bishnupriya	
bpz				I	L	Bilba	
bqa				I	L	Tchumbuli	
bqb				I	L	Bagusa	
bqc				I	L	Boko (Benin)	
bqd				I	L	Bung	
bqf				I	E	Baga Kaloum	
bqg				I	L	Bago-Kusuntu	
bqh				I	L	Baima	
bqi				I	L	Bakhtiari	
bqj				I	L	Bandial	
bqk				I	L	Banda-Mbrès	
bql				I	L	Bilakura	
bqm				I	L	Wumboko	
bqn				I	L	Bulgarian Sign Language	
bqo				I	L	Balo	
bqp				I	L	Busa	
bqq				I	L	Biritai	
bqr				I	L	Burusu	
bqs				I	L	Bosngun	
bqt				I	L	Bamukumbit	
bqu				I	L	Boguru	
bqv				I	L	Koro Wachi	
bqw				I	L	Buru (Nigeria)	
bqx				I	L	Baangi	
bqy				I	L	Bengkala Sign Language	
bqz				I	L	Bakaka	
bra	bra	bra		I	L	Braj	
brb				I	L	Lave	
brc				I	E	Berbice Creole Dutch	
brd				I	L	Baraamu	
bre	bre	bre	br	I	L	Breton	
brf				I	L	Bira	
brg				I	L	Baure	
brh				I	L	Brahui	
bri				I	L	Mokpwe	
brj				I	L	Bieria	
brk				I	E	Birked	
brl				I	L	Birwa	
brm				I	L	Barambu	
brn				I	L	Boruca	
bro				I	L	Brokkat	
brp				I	L	Barapasi	
brq				I	L	Breri	
brr				I	L	Birao	
brs				I	L	Baras	
brt				I	L	Bitare	
bru				I	L	Eastern Bru	
brv				I	L	Western Bru	
brw				I	L	Bellari	
brx				I	L	Bodo (India)	
bry				I	L	Burui	
brz				I	L	Bilbil	
bsa				I	L	Abinomn	
bsb				I	L	Brunei Bisaya	
bsc				I	L	Bassari	
bse				I	L	Wushi	
bsf				I	L	Bauchi	
bsg				I	L	Bashkardi	
bsh				I	L	Kati	
bsi				I	L	Bassossi	
bsj				I	L	Bangwinji	
bsk				I	L	Burushaski	
bsl				I	E	Basa-Gumna	
bsm				I	L	Busami	
bsn				I	L	Barasana-Eduria	
bso				I	L	Buso	
bsp				I	L	Baga Sitemu	
bsq				I	L	Bassa	
bsr				I	L	Bassa-Kontagora	
bss				I	L	Akoose	
bst				I	L	Basketo	
bsu				I	L	Bahonsuai	
bsv				I	E	Baga Sobané	
bsw				I	L	Baiso	
bsx				I	L	Yangkam	
bsy				I	L	Sabah Bisaya	
bta				I	L	Bata	
btc				I	L	Bati (Cameroon)	
btd				I	L	Batak Dairi	
bte				I	E	Gamo-Ningi	
btf				I	L	Birgit	
btg				I	L	Gagnoa Bété	
bth				I	L	Biatah Bidayuh	
bti				I	L	Burate	
btj				I	L	Bacanese Malay	
btm				I	L	Batak Mandailing	
btn				I	L	Ratagnon	
bto				I	L	Rinconada Bikol	
btp				I	L	Budibud	
btq				I	L	Batek	
btr				I	L	Baetora	
bts				I	L	Batak Simalungun	
btt				I	L	Bete-Bendi	
btu				I	L	Batu	
btv				I	L	Bateri	
btw				I	L	Butuanon	
btx				I	L	Batak Karo	
bty				I	L	Bobot	
btz				I	L	Batak Alas-Kluet	
bua	bua	bua		M	L	Buriat	
bub				I	L	Bua	
buc				I	L	Bushi	
bud				I	L	Ntcham	
bue				I	E	Beothuk	
buf				I	L	Bushoong	
bug	bug	bug		I	L	Buginese	
buh				I	L	Younuo Bunu	
bui				I	L	Bongili	
buj				I	L	Basa-Gurmana	
buk				I	L	Bugawac	
bul	bul	bul	bg	I	L	Bulgarian	
bum				I	L	Bulu (Cameroon)	
bun				I	L	Sherbro	
buo				I	L	Terei	
bup				I	L	Busoa	
buq				I	L	Brem	
bus				I	L	Bokobaru	
but				I	L	Bungain	
buu				I	L	Budu	
buv				I	L	Bun	
buw				I	L	Bubi	
bux				I	L	Boghom	
buy				I	L	Bullom So	
buz				I	L	Bukwen	
bva				I	L	Barein	
bvb				I	L	Bube	
bvc				I	L	Baelelea	
bvd				I	L	Baeggu	
bve				I	L	Berau Malay	
bvf				I	L	Boor	
bvg				I	L	Bonkeng	
bvh				I	L	Bure	
bvi				I	L	Belanda Viri	
bvj				I	L	Baan	
bvk				I	L	Bukat	
bvl				I	L	Bolivian Sign Language	
bvm				I	L	Bamunka	
bvn				I	L	Buna	
bvo				I	L	Bolgo	
bvp				I	L	Bumang	
bvq				I	L	Birri	
bvr				I	L	Burarra	
bvt				I	L	Bati (Indonesia)	
bvu				I	L	Bukit Malay	
bvv				I	E	Baniva	
bvw				I	L	Boga	
bvx				I	L	Dibole	
bvy				I	L	Baybayanon	
bvz				I	L	Bauzi	
bwa				I	L	Bwatoo	
bwb				I	L	Namosi-Naitasiri-Serua	
bwc				I	L	Bwile	
bwd				I	L	Bwaidoka	
bwe				I	L	Bwe Karen	
bwf				I	L	Boselewa	
bwg				I	L	Barwe	
bwh				I	L	Bishuo	
bwi				I	L	Baniwa	
bwj				I	L	Láá Láá Bwamu	
bwk				I	L	Bauwaki	
bwl				I	L	Bwela	
bwm				I	L	Biwat	
bwn				I	L	Wunai Bunu	
bwo				I	L	Boro (Ethiopia)	
bwp				I	L	Mandobo Bawah	
bwq				I	L	Southern Bobo Madaré	
bwr				I	L	Bura-Pabir	
bws				I	L	Bomboma	
bwt				I	L	Bafaw-Balong	
bwu				I	L	Buli (Ghana)	
bww				I	L	Bwa	
bwx				I	L	Bu-Nao Bunu	
bwy				I	L	Cwi Bwamu	
bwz				I	L	Bwisi	
bxa				I	L	Tairaha	
bxb				I	L	Belanda Bor	
bxc				I	L	Molengue	
bxd				I	L	Pela	
bxe				I	L	Birale	
bxf				I	L	Bilur	
bxg				I	L	Bangala	
bxh				I	L	Buhutu	
bxi				I	E	Pirlatapa	
bxj				I	L	Bayungu	
bxk				I	L	Bukusu	
bxl				I	L	Jalkunan	
bxm				I	L	Mongolia Buriat	
bxn				I	L	Burduna	
bxo				I	L	Barikanchi	
bxp				I	L	Bebil	
bxq				I	L	Beele	
bxr				I	L	Russia Buriat	
bxs				I	L	Busam	
bxu				I	L	China Buriat	
bxv				I	L	Berakou	
bxw				I	L	Bankagooma	
bxz				I	L	Binahari	
bya				I	L	Batak	
byb				I	L	Bikya	
byc				I	L	Ubaghara	
byd				I	L	Benyadu'	
bye				I	L	Pouye	
byf				I	L	Bete	
byg				I	E	Baygo	
byh				I	L	Bhujel	
byi				I	L	Buyu	
byj				I	L	Bina (Nigeria)	
byk				I	L	Biao	
byl				I	L	Bayono	
bym				I	L	Bidjara	
byn	byn	byn		I	L	Bilin	
byo				I	L	Biyo	
byp				I	L	Bumaji	
byq				I	E	Basay	
byr				I	L	Baruya	
bys				I	L	Burak	
byt				I	E	Berti	
byv				I	L	Medumba	
byw				I	L	Belhariya	
byx				I	L	Qaqet	
byz				I	L	Banaro	
bza				I	L	Bandi	
bzb				I	L	Andio	
bzc				I	L	Southern Betsimisaraka Malagasy	
bzd				I	L	Bribri	
bze				I	L	Jenaama Bozo	
bzf				I	L	Boikin	
bzg				I	L	Babuza	
bzh				I	L	Mapos Buang	
bzi				I	L	Bisu	
bzj				I	L	Belize Kriol English	
bzk				I	L	Nicaragua Creole English	
bzl				I	L	Boano (Sulawesi)	
bzm				I	L	Bolondo	
bzn				I	L	Boano (Maluku)	
bzo				I	L	Bozaba	
bzp				I	L	Kemberano	
bzq				I	L	Buli (Indonesia)	
bzr				I	E	Biri	
bzs				I	L	Brazilian Sign Language	
bzt				I	C	Brithenig	
bzu				I	L	Burmeso	
bzv				I	L	Naami	
bzw				I	L	Basa (Nigeria)	
bzx				I	L	Kɛlɛngaxo Bozo	
bzy				I	L	Obanliku	
bzz				I	L	Evant	
caa				I	L	Chortí	
cab				I	L	Garifuna	
cac				I	L	Chuj	
cad	cad	cad		I	L	Caddo	
cae				I	L	Lehar	
caf				I	L	Southern Carrier	
cag				I	L	Nivaclé	
cah				I	L	Cahuarano	
caj				I	E	Chané	
cak				I	L	Kaqchikel	
cal				I	L	Carolinian	
cam				I	L	Cemuhî	
can				I	L	Chambri	
cao				I	L	Chácobo	
cap				I	L	Chipaya	
caq				I	L	Car Nicobarese	
car	car	car		I	L	Galibi Carib	
cas				I	L	Tsimané	
cat	cat	cat	ca	I	L	Catalan	
cav				I	L	Cavineña	
caw				I	L	Callawalla	
cax				I	L	Chiquitano	
cay				I	L	Cayuga	
caz				I	E	Canichana	
cbb				I	L	Cabiyarí	
cbc				I	L	Carapana	
cbd				I	L	Carijona	
cbg				I	L	Chimila	
cbi				I	L	Chachi	
cbj				I	L	Ede Cabe	
cbk				I	L	Chavacano	
cbl				I	L	Bualkhaw Chin	
cbn				I	L	Nyahkur	
cbo				I	L	Izora	
cbq				I	L	Tsucuba	
cbr				I	L	Cashibo-Cacataibo	
cbs				I	L	Cashinahua	
cbt				I	L	Chayahuita	
cbu				I	L	Candoshi-Shapra	
cbv				I	L	Cacua	
cbw				I	L	Kinabalian	
cby				I	L	Carabayo	
ccc				I	L	Chamicuro	
ccd				I	L	Cafundo Creole	
cce				I	L	Chopi	
ccg				I	L	Samba Daka	
cch				I	L	Atsam	
ccj				I	L	Kasanga	
ccl				I	L	Cutchi-Swahili	
ccm				I	L	Malaccan Creole Malay	
cco				I	L	Comaltepec Chinantec	
ccp				I	L	Chakma	
ccr				I	E	Cacaopera	
cda				I	L	Choni	
cde				I	L	Chenchu	
cdf				I	L	Chiru	
cdh				I	L	Chambeali	
cdi				I	L	Chodri	
cdj				I	L	Churahi	
cdm				I	L	Chepang	
cdn				I	L	Chaudangsi	
cdo				I	L	Min Dong Chinese	
cdr				I	L	Cinda-Regi-Tiyal	
cds				I	L	Chadian Sign Language	
cdy				I	L	Chadong	
cdz				I	L	Koda	
cea				I	E	Lower Chehalis	
ceb	ceb	ceb		I	L	Cebuano	
ceg				I	L	Chamacoco	
cek				I	L	Eastern Khumi Chin	
cen				I	L	Cen	
ces	cze	ces	cs	I	L	Czech	
cet				I	L	Centúúm	
cey				I	L	Ekai Chin	
cfa				I	L	Dijim-Bwilim	
cfd				I	L	Cara	
cfg				I	L	Como Karim	
cfm				I	L	Falam Chin	
cga				I	L	Changriwa	
cgc				I	L	Kagayanen	
cgg				I	L	Chiga	
cgk				I	L	Chocangacakha	
cha	cha	cha	ch	I	L	Chamorro	
chb	chb	chb		I	E	Chibcha	
chc				I	E	Catawba	
chd				I	L	Highland Oaxaca Chontal	
che	che	che	ce	I	L	Chechen	
chf				I	L	Tabasco Chontal	
chg	chg	chg		I	E	Chagatai	
chh				I	E	Chinook	
chj				I	L	Ojitlán Chinantec	
chk	chk	chk		I	L	Chuukese	
chl				I	L	Cahuilla	
chm	chm	chm		M	L	Mari (Russia)	
chn	chn	chn		I	L	Chinook jargon	
cho	cho	cho		I	L	Choctaw	
chp	chp	chp		I	L	Chipewyan	
chq				I	L	Quiotepec Chinantec	
chr	chr	chr		I	L	Cherokee	
cht				I	E	Cholón	
chu	chu	chu	cu	I	A	Church Slavic	
chv	chv	chv	cv	I	L	Chuvash	
chw				I	L	Chuwabu	
chx				I	L	Chantyal	
chy	chy	chy		I	L	Cheyenne	
chz				I	L	Ozumacín Chinantec	
cia				I	L	Cia-Cia	
cib				I	L	Ci Gbe	
cic				I	L	Chickasaw	
cid				I	E	Chimariko	
cie				I	L	Cineni	
cih				I	L	Chinali	
cik				I	L	Chitkuli Kinnauri	
cim				I	L	Cimbrian	
cin				I	L	Cinta Larga	
cip				I	L	Chiapanec	
cir				I	L	Tiri	
ciw				I	L	Chippewa	
ciy				I	L	Chaima	
cja				I	L	Western Cham	
cje				I	L	Chru	
cjh				I	E	Upper Chehalis	
cji				I	L	Chamalal	
cjk				I	L	Chokwe	
cjm				I	L	Eastern Cham	
cjn				I	L	Chenapian	
cjo				I	L	Ashéninka Pajonal	
cjp				I	L	Cabécar	
cjs				I	L	Shor	
cjv				I	L	Chuave	
cjy				I	L	Jinyu Chinese	
ckb				I	L	Central Kurdish	
ckh				I	L	Chak	
ckl				I	L	Cibak	
ckm				I	L	Chakavian	
ckn				I	L	Kaang Chin	
cko				I	L	Anufo	
ckq				I	L	Kajakse	
ckr				I	L	Kairak	
cks				I	L	Tayo	
ckt				I	L	Chukot	
cku				I	L	Koasati	
ckv				I	L	Kavalan	
ckx				I	L	Caka	
cky				I	L	Cakfem-Mushere	
ckz				I	L	Cakchiquel-Quiché Mixed Language	
cla				I	L	Ron	
clc				I	L	Chilcotin	
cld				I	L	Chaldean Neo-Aramaic	
cle				I	L	Lealao Chinantec	
clh				I	L	Chilisso	
cli				I	L	Chakali	
clj				I	L	Laitu Chin	
clk				I	L	Idu-Mishmi	
cll				I	L	Chala	
clm				I	L	Clallam	
clo				I	L	Lowland Oaxaca Chontal	
clt				I	L	Lautu Chin	
clu				I	L	Caluyanun	
clw				I	L	Chulym	
cly				I	L	Eastern Highland Chatino	
cma				I	L	Maa	
cme				I	L	Cerma	
cmg				I	H	Classical Mongolian	
cmi				I	L	Emberá-Chamí	
cml				I	L	Campalagian	
cmm				I	E	Michigamea	
cmn				I	L	Mandarin Chinese	
cmo				I	L	Central Mnong	
cmr				I	L	Mro-Khimi Chin	
cms				I	A	Messapic	
cmt				I	L	Camtho	
cna				I	L	Changthang	
cnb				I	L	Chinbon Chin	
cnc				I	L	Côông	
cng				I	L	Northern Qiang	
cnh				I	L	Hakha Chin	
cni				I	L	Asháninka	
cnk				I	L	Khumi Chin	
cnl				I	L	Lalana Chinantec	
cno				I	L	Con	
cnp				I	L	Northern Ping Chinese	
cnr	cnr	cnr		I	L	Montenegrin	
cns				I	L	Central Asmat	
cnt				I	L	Tepetotutla Chinantec	
cnu				I	L	Chenoua	
cnw				I	L	Ngawn Chin	
cnx				I	H	Middle Cornish	
coa				I	L	Cocos Islands Malay	
cob				I	E	Chicomuceltec	
coc				I	L	Cocopa	
cod				I	L	Cocama-Cocamilla	
coe				I	L	Koreguaje	
cof				I	L	Colorado	
cog				I	L	Chong	
coh				I	L	Chonyi-Dzihana-Kauma	
coj				I	E	Cochimi	
cok				I	L	Santa Teresa Cora	
col				I	L	Columbia-Wenatchi	
com				I	L	Comanche	
con				I	L	Cofán	
coo				I	L	Comox	
cop	cop	cop		I	E	Coptic	
coq				I	E	Coquille	
cor	cor	cor	kw	I	L	Cornish	
cos	cos	cos	co	I	L	Corsican	
cot				I	L	Caquinte	
cou				I	L	Wamey	
cov				I	L	Cao Miao	
cow				I	E	Cowlitz	
cox				I	L	Nanti	
coz				I	L	Chochotec	
cpa				I	L	Palantla Chinantec	
cpb				I	L	Ucayali-Yurúa Ashéninka	
cpc				I	L	Ajyíninka Apurucayali	
cpg				I	E	Cappadocian Greek	
cpi				I	L	Chinese Pidgin English	
cpn				I	L	Cherepon	
cpo				I	L	Kpeego	
cps				I	L	Capiznon	
cpu				I	L	Pichis Ashéninka	
cpx				I	L	Pu-Xian Chinese	
cpy				I	L	South Ucayali Ashéninka	
cqd				I	L	Chuanqiandian Cluster Miao	
cra				I	L	Chara	
crb				I	E	Island Carib	
crc				I	L	Lonwolwol	
crd				I	L	Coeur d'Alene	
cre	cre	cre	cr	M	L	Cree	
crf				I	E	Caramanta	
crg				I	L	Michif	
crh	crh	crh		I	L	Crimean Tatar	
cri				I	L	Sãotomense	
crj				I	L	Southern East Cree	
crk				I	L	Plains Cree	
crl				I	L	Northern East Cree	
crm				I	L	Moose Cree	
crn				I	L	El Nayar Cora	
cro				I	L	Crow	
crq				I	L	Iyo'wujwa Chorote	
crr				I	E	Carolina Algonquian	
crs				I	L	Seselwa Creole French	
crt				I	L	Iyojwa'ja Chorote	
crv				I	L	Chaura	
crw				I	L	Chrau	
crx				I	L	Carrier	
cry				I	L	Cori	
crz				I	E	Cruzeño	
csa				I	L	Chiltepec Chinantec	
csb	csb	csb		I	L	Kashubian	
csc				I	L	Catalan Sign Language	
csd				I	L	Chiangmai Sign Language	
cse				I	L	Czech Sign Language	
csf				I	L	Cuba Sign Language	
csg				I	L	Chilean Sign Language	
csh				I	L	Asho Chin	
csi				I	E	Coast Miwok	
csj				I	L	Songlai Chin	
csk				I	L	Jola-Kasa	
csl				I	L	Chinese Sign Language	
csm				I	L	Central Sierra Miwok	
csn				I	L	Colombian Sign Language	
cso				I	L	Sochiapam Chinantec	
csp				I	L	Southern Ping Chinese	
csq				I	L	Croatia Sign Language	
csr				I	L	Costa Rican Sign Language	
css				I	E	Southern Ohlone	
cst				I	L	Northern Ohlone	
csv				I	L	Sumtu Chin	
csw				I	L	Swampy Cree	
csy				I	L	Siyin Chin	
csz				I	L	Coos	
cta				I	L	Tataltepec Chatino	
ctc				I	E	Chetco	
ctd				I	L	Tedim Chin	
cte				I	L	Tepinapa Chinantec	
ctg				I	L	Chittagonian	
cth				I	L	Thaiphum Chin	
ctl				I	L	Tlacoatzintepec Chinantec	
ctm				I	E	Chitimacha	
ctn				I	L	Chhintange	
cto				I	L	Emberá-Catío	
ctp				I	L	Western Highland Chatino	
cts				I	L	Northern Catanduanes Bikol	
ctt				I	L	Wayanad Chetti	
ctu				I	L	Chol	
ctz				I	L	Zacatepec Chatino	
cua				I	L	Cua	
cub				I	L	Cubeo	
cuc				I	L	Usila Chinantec	
cug				I	L	Chungmboko	
cuh				I	L	Chuka	
cui				I	L	Cuiba	
cuj				I	L	Mashco Piro	
cuk				I	L	San Blas Kuna	
cul				I	L	Culina	
cuo				I	E	Cumanagoto	
cup				I	E	Cupeño	
cuq				I	L	Cun	
cur				I	L	Chhulung	
cut				I	L	Teutila Cuicatec	
cuu				I	L	Tai Ya	
cuv				I	L	Cuvok	
cuw				I	L	Chukwa	
cux				I	L	Tepeuxila Cuicatec	
cuy				I	L	Cuitlatec	
cvg				I	L	Chug	
cvn				I	L	Valle Nacional Chinantec	
cwa				I	L	Kabwa	
cwb				I	L	Maindo	
cwd				I	L	Woods Cree	
cwe				I	L	Kwere	
cwg				I	L	Chewong	
cwt				I	L	Kuwaataay	
cya				I	L	Nopala Chatino	
cyb				I	E	Cayubaba	
cym	wel	cym	cy	I	L	Welsh	
cyo				I	L	Cuyonon	
czh				I	L	Huizhou Chinese	
czk				I	E	Knaanic	
czn				I	L	Zenzontepec Chatino	
czo				I	L	Min Zhong Chinese	
czt				I	L	Zotung Chin	
daa				I	L	Dangaléat	
dac				I	L	Dambi	
dad				I	L	Marik	
dae				I	L	Duupa	
dag				I	L	Dagbani	
dah				I	L	Gwahatike	
dai				I	L	Day	
daj				I	L	Dar Fur Daju	
dak	dak	dak		I	L	Dakota	
dal				I	L	Dahalo	
dam				I	L	Damakawa	
dan	dan	dan	da	I	L	Danish	
dao				I	L	Daai Chin	
daq				I	L	Dandami Maria	
dar	dar	dar		I	L	Dargwa	
das				I	L	Daho-Doo	
dau				I	L	Dar Sila Daju	
dav				I	L	Taita	
daw				I	L	Davawenyo	
dax				I	L	Dayi	
daz				I	L	Dao	
dba				I	L	Bangime	
dbb				I	L	Deno	
dbd				I	L	Dadiya	
dbe				I	L	Dabe	
dbf				I	L	Edopi	
dbg				I	L	Dogul Dom Dogon	
dbi				I	L	Doka	
dbj				I	L	Ida'an	
dbl				I	L	Dyirbal	
dbm				I	L	Duguri	
dbn				I	L	Duriankere	
dbo				I	L	Dulbu	
dbp				I	L	Duwai	
dbq				I	L	Daba	
dbr				I	L	Dabarre	
dbt				I	L	Ben Tey Dogon	
dbu				I	L	Bondum Dom Dogon	
dbv				I	L	Dungu	
dbw				I	L	Bankan Tey Dogon	
dby				I	L	Dibiyaso	
dcc				I	L	Deccan	
dcr				I	E	Negerhollands	
dda				I	E	Dadi Dadi	
ddd				I	L	Dongotono	
dde				I	L	Doondo	
ddg				I	L	Fataluku	
ddi				I	L	West Goodenough	
ddj				I	L	Jaru	
ddn				I	L	Dendi (Benin)	
ddo				I	L	Dido	
ddr				I	E	Dhudhuroa	
dds				I	L	Donno So Dogon	
ddw				I	L	Dawera-Daweloor	
dec				I	L	Dagik	
ded				I	L	Dedua	
dee				I	L	Dewoin	
def				I	L	Dezfuli	
deg				I	L	Degema	
deh				I	L	Dehwari	
dei				I	L	Demisa	
dek				I	L	Dek	
del	del	del		M	L	Delaware	
dem				I	L	Dem	
den	den	den		M	L	Slave (Athapascan)	
dep				I	E	Pidgin Delaware	
deq				I	L	Dendi (Central African Republic)	
der				I	L	Deori	
des				I	L	Desano	
deu	ger	deu	de	I	L	German	
dev				I	L	Domung	
dez				I	L	Dengese	
dga				I	L	Southern Dagaare	
dgb				I	L	Bunoge Dogon	
dgc				I	L	Casiguran Dumagat Agta	
dgd				I	L	Dagaari Dioula	
dge				I	L	Degenan	
dgg				I	L	Doga	
dgh				I	L	Dghwede	
dgi				I	L	Northern Dagara	
dgk				I	L	Dagba	
dgl				I	L	Andaandi	
dgn				I	E	Dagoman	
dgo				I	L	Dogri (individual language)	
dgr	dgr	dgr		I	L	Dogrib	
dgs				I	L	Dogoso	
dgt				I	E	Ndra'ngith	
dgw				I	E	Daungwurrung	
dgx				I	L	Doghoro	
dgz				I	L	Daga	
dhd				I	L	Dhundari	
dhg				I	L	Dhangu-Djangu	
dhi				I	L	Dhimal	
dhl				I	L	Dhalandji	
dhm				I	L	Zemba	
dhn				I	L	Dhanki	
dho				I	L	Dhodia	
dhr				I	L	Dhargari	
dhs				I	L	Dhaiso	
dhu				I	E	Dhurga	
dhv				I	L	Dehu	
dhw				I	L	Dhanwar (Nepal)	
dhx				I	L	Dhungaloo	
dia				I	L	Dia	
dib				I	L	South Central Dinka	
dic				I	L	Lakota Dida	
did				I	L	Didinga	
dif				I	E	Dieri	
dig				I	L	Digo	
dih				I	L	Kumiai	
dii				I	L	Dimbong	
dij				I	L	Dai	
dik				I	L	Southwestern Dinka	
dil				I	L	Dilling	
dim				I	L	Dime	
din	din	din		M	L	Dinka	
dio				I	L	Dibo	
dip				I	L	Northeastern Dinka	
diq				I	L	Dimli (individual language)	
dir				I	L	Dirim	
dis				I	L	Dimasa	
diu				I	L	Diriku	
div	div	div	dv	I	L	Dhivehi	
diw				I	L	Northwestern Dinka	
dix				I	L	Dixon Reef	
diy				I	L	Diuwe	
diz				I	L	Ding	
dja				I	E	Djadjawurrung	
djb				I	L	Djinba	
djc				I	L	Dar Daju Daju	
djd				I	L	Djamindjung	
dje				I	L	Zarma	
djf				I	E	Djangun	
dji				I	L	Djinang	
djj				I	L	Djeebbana	
djk				I	L	Eastern Maroon Creole	
djm				I	L	Jamsay Dogon	
djn				I	L	Jawoyn	
djo				I	L	Jangkang	
djr				I	L	Djambarrpuyngu	
dju				I	L	Kapriman	
djw				I	E	Djawi	
dka				I	L	Dakpakha	
dkk				I	L	Dakka	
dkr				I	L	Kuijau	
dks				I	L	Southeastern Dinka	
dkx				I	L	Mazagway	
dlg				I	L	Dolgan	
dlk				I	L	Dahalik	
dlm				I	E	Dalmatian	
dln				I	L	Darlong	
dma				I	L	Duma	
dmb				I	L	Mombo Dogon	
dmc				I	L	Gavak	
dmd				I	E	Madhi Madhi	
dme				I	L	Dugwor	
dmf				I	E	Medefaidrin	
dmg				I	L	Upper Kinabatangan	
dmk				I	L	Domaaki	
dml				I	L	Dameli	
dmm				I	L	Dama	
dmo				I	L	Kemedzung	
dmr				I	L	East Damar	
dms				I	L	Dampelas	
dmu				I	L	Dubu	
dmv				I	L	Dumpas	
dmw				I	L	Mudburra	
dmx				I	L	Dema	
dmy				I	L	Demta	
dna				I	L	Upper Grand Valley Dani	
dnd				I	L	Daonda	
dne				I	L	Ndendeule	
dng				I	L	Dungan	
dni				I	L	Lower Grand Valley Dani	
dnj				I	L	Dan	
dnk				I	L	Dengka	
dnn				I	L	Dzùùngoo	
dno				I	L	Ndrulo	
dnr				I	L	Danaru	
dnt				I	L	Mid Grand Valley Dani	
dnu				I	L	Danau	
dnv				I	L	Danu	
dnw				I	L	Western Dani	
dny				I	L	Dení	
doa				I	L	Dom	
dob				I	L	Dobu	
doc				I	L	Northern Dong	
doe				I	L	Doe	
dof				I	L	Domu	
doh				I	L	Dong	
doi	doi	doi		M	L	Dogri (macrolanguage)	
dok				I	L	Dondo	
dol				I	L	Doso	
don				I	L	Toura (Papua New Guinea)	
doo				I	L	Dongo	
dop				I	L	Lukpa	
doq				I	L	Dominican Sign Language	
dor				I	L	Dori'o	
dos				I	L	Dogosé	
dot				I	L	Dass	
dov				I	L	Dombe	
dow				I	L	Doyayo	
dox				I	L	Bussa	
doy				I	L	Dompo	
doz				I	L	Dorze	
dpp				I	L	Papar	
drb				I	L	Dair	
drc				I	L	Minderico	
drd				I	L	Darmiya	
dre				I	L	Dolpo	
drg				I	L	Rungus	
dri				I	L	C'Lela	
drl				I	L	Paakantyi	
drn				I	L	West Damar	
dro				I	L	Daro-Matu Melanau	
drq				I	E	Dura	
drs				I	L	Gedeo	
drt				I	L	Drents	
dru				I	L	Rukai	
dry				I	L	Darai	
dsb	dsb	dsb		I	L	Lower Sorbian	
dse				I	L	Dutch Sign Language	
dsh				I	L	Daasanach	
dsi				I	L	Disa	
dsl				I	L	Danish Sign Language	
dsn				I	E	Dusner	
dso				I	L	Desiya	
dsq				I	L	Tadaksahak	
dta				I	L	Daur	
dtb				I	L	Labuk-Kinabatangan Kadazan	
dtd				I	L	Ditidaht	
dth				I	E	Adithinngithigh	
dti				I	L	Ana Tinga Dogon	
dtk				I	L	Tene Kan Dogon	
dtm				I	L	Tomo Kan Dogon	
dtn				I	L	Daatsʼíin	
dto				I	L	Tommo So Dogon	
dtp				I	L	Kadazan Dusun	
dtr				I	L	Lotud	
dts				I	L	Toro So Dogon	
dtt				I	L	Toro Tegu Dogon	
dtu				I	L	Tebul Ure Dogon	
dty				I	L	Dotyali	
dua	dua	dua		I	L	Duala	
dub				I	L	Dubli	
duc				I	L	Duna	
due				I	L	Umiray Dumaget Agta	
duf				I	L	Dumbea	
dug				I	L	Duruma	
duh				I	L	Dungra Bhil	
dui				I	L	Dumun	
duk				I	L	Uyajitaya	
dul				I	L	Alabat Island Agta	
dum	dum	dum		I	H	Middle Dutch (ca. 1050-1350)	
dun				I	L	Dusun Deyah	
duo				I	L	Dupaninan Agta	
dup				I	L	Duano	
duq				I	L	Dusun Malang	
dur				I	L	Dii	
dus				I	L	Dumi	
duu				I	L	Drung	
duv				I	L	Duvle	
duw				I	L	Dusun Witu	
dux				I	L	Duungooma	
duy				I	E	Dicamay Agta	
duz				I	E	Duli-Gey	
dva				I	L	Duau	
dwa				I	L	Diri	
dwk				I	L	Dawik Kui	
dwr				I	L	Dawro	
dws				I	C	Dutton World Speedwords	
dwu				I	L	Dhuwal	
dww				I	L	Dawawa	
dwy				I	L	Dhuwaya	
dwz				I	L	Dewas Rai	
dya				I	L	Dyan	
dyb				I	E	Dyaberdyaber	
dyd				I	E	Dyugun	
dyg				I	E	Villa Viciosa Agta	
dyi				I	L	Djimini Senoufo	
dym				I	L	Yanda Dom Dogon	
dyn				I	L	Dyangadi	
dyo				I	L	Jola-Fonyi	
dyu	dyu	dyu		I	L	Dyula	
dyy				I	L	Djabugay	
dza				I	L	Tunzu	
dze				I	E	Djiwarli	
dzg				I	L	Dazaga	
dzl				I	L	Dzalakha	
dzn				I	L	Dzando	
dzo	dzo	dzo	dz	I	L	Dzongkha	
eaa				I	E	Karenggapa	
ebc				I	L	Beginci	
ebg				I	L	Ebughu	
ebk				I	L	Eastern Bontok	
ebo				I	L	Teke-Ebo	
ebr				I	L	Ebrié	
ebu				I	L	Embu	
ecr				I	A	Eteocretan	
ecs				I	L	Ecuadorian Sign Language	
ecy				I	A	Eteocypriot	
eee				I	L	E	
efa				I	L	Efai	
efe				I	L	Efe	
efi	efi	efi		I	L	Efik	
ega				I	L	Ega	
egl				I	L	Emilian	
ego				I	L	Eggon	
egy	egy	egy		I	A	Egyptian (Ancient)	
ehu				I	L	Ehueun	
eip				I	L	Eipomek	
eit				I	L	Eitiep	
eiv				I	L	Askopan	
eja				I	L	Ejamat	
eka	eka	eka		I	L	Ekajuk	
eke				I	L	Ekit	
ekg				I	L	Ekari	
eki				I	L	Eki	
ekk				I	L	Standard Estonian	
ekl				I	L	Kol (Bangladesh)	
ekm				I	L	Elip	
eko				I	L	Koti	
ekp				I	L	Ekpeye	
ekr				I	L	Yace	
eky				I	L	Eastern Kayah	
ele				I	L	Elepi	
elh				I	L	El Hugeirat	
eli				I	E	Nding	
elk				I	L	Elkei	
ell	gre	ell	el	I	L	Modern Greek (1453-)	
elm				I	L	Eleme	
elo				I	L	El Molo	
elu				I	L	Elu	
elx	elx	elx		I	A	Elamite	
ema				I	L	Emai-Iuleha-Ora	
emb				I	L	Embaloh	
eme				I	L	Emerillon	
emg				I	L	Eastern Meohang	
emi				I	L	Mussau-Emira	
emk				I	L	Eastern Maninkakan	
emm				I	E	Mamulique	
emn				I	L	Eman	
emp				I	L	Northern Emberá	
ems				I	L	Pacific Gulf Yupik	
emu				I	L	Eastern Muria	
emw				I	L	Emplawas	
emx				I	L	Erromintxela	
emy				I	A	Epigraphic Mayan	
ena				I	L	Apali	
enb				I	L	Markweeta	
enc				I	L	En	
end				I	L	Ende	
enf				I	L	Forest Enets	
eng	eng	eng	en	I	L	English	
enh				I	L	Tundra Enets	
enl				I	L	Enlhet	
enm	enm	enm		I	H	Middle English (1100-1500)	
enn				I	L	Engenni	
eno				I	L	Enggano	
enq				I	L	Enga	
enr				I	L	Emumu	
enu				I	L	Enu	
env				I	L	Enwan (Edu State)	
enw				I	L	Enwan (Akwa Ibom State)	
enx				I	L	Enxet	
eot				I	L	Beti (Côte d'Ivoire)	
epi				I	L	Epie	
epo	epo	epo	eo	I	C	Esperanto	
era				I	L	Eravallan	
erg				I	L	Sie	
erh				I	L	Eruwa	
eri				I	L	Ogea	
erk				I	L	South Efate	
ero				I	L	Horpa	
err				I	E	Erre	
ers				I	L	Ersu	
ert				I	L	Eritai	
erw				I	L	Erokwanas	
ese				I	L	Ese Ejja	
esg				I	L	Aheri Gondi	
esh				I	L	Eshtehardi	
esi				I	L	North Alaskan Inupiatun	
esk				I	L	Northwest Alaska Inupiatun	
esl				I	L	Egypt Sign Language	
esm				I	E	Esuma	
esn				I	L	Salvadoran Sign Language	
eso				I	L	Estonian Sign Language	
esq				I	E	Esselen	
ess				I	L	Central Siberian Yupik	
est	est	est	et	M	L	Estonian	
esu				I	L	Central Yupik	
esy				I	L	Eskayan	
etb				I	L	Etebi	
etc				I	E	Etchemin	
eth				I	L	Ethiopian Sign Language	
etn				I	L	Eton (Vanuatu)	
eto				I	L	Eton (Cameroon)	
etr				I	L	Edolo	
ets				I	L	Yekhee	
ett				I	A	Etruscan	
etu				I	L	Ejagham	
etx				I	L	Eten	
etz				I	L	Semimi	
eus	baq	eus	eu	I	L	Basque	
eve				I	L	Even	
evh				I	L	Uvbie	
evn				I	L	Evenki	
ewe	ewe	ewe	ee	I	L	Ewe	
ewo	ewo	ewo		I	L	Ewondo	
ext				I	L	Extremaduran	
eya				I	E	Eyak	
eyo				I	L	Keiyo	
eza				I	L	Ezaa	
eze				I	L	Uzekwe	
faa				I	L	Fasu	
fab				I	L	Fa d'Ambu	
fad				I	L	Wagi	
faf				I	L	Fagani	
fag				I	L	Finongan	
fah				I	L	Baissa Fali	
fai				I	L	Faiwol	
faj				I	L	Faita	
fak				I	L	Fang (Cameroon)	
fal				I	L	South Fali	
fam				I	L	Fam	
fan	fan	fan		I	L	Fang (Equatorial Guinea)	
fao	fao	fao	fo	I	L	Faroese	
fap				I	L	Paloor	
far				I	L	Fataleka	
fas	per	fas	fa	M	L	Persian	
fat	fat	fat		I	L	Fanti	
fau				I	L	Fayu	
fax				I	L	Fala	
fay				I	L	Southwestern Fars	
faz				I	L	Northwestern Fars	
fbl				I	L	West Albay Bikol	
fcs				I	L	Quebec Sign Language	
fer				I	L	Feroge	
ffi				I	L	Foia Foia	
ffm				I	L	Maasina Fulfulde	
fgr				I	L	Fongoro	
fia				I	L	Nobiin	
fie				I	L	Fyer	
fij	fij	fij	fj	I	L	Fijian	
fil	fil	fil		I	L	Filipino	
fin	fin	fin	fi	I	L	Finnish	
fip				I	L	Fipa	
fir				I	L	Firan	
fit				I	L	Tornedalen Finnish	
fiw				I	L	Fiwaga	
fkk				I	L	Kirya-Konzəl	
fkv				I	L	Kven Finnish	
fla				I	L	Kalispel-Pend d'Oreille	
flh				I	L	Foau	
fli				I	L	Fali	
fll				I	L	North Fali	
fln				I	E	Flinders Island	
flr				I	L	Fuliiru	
fly				I	L	Flaaitaal	
fmp				I	L	Fe'fe'	
fmu				I	L	Far Western Muria	
fnb				I	L	Fanbak	
fng				I	L	Fanagalo	
fni				I	L	Fania	
fod				I	L	Foodo	
foi				I	L	Foi	
fom				I	L	Foma	
fon	fon	fon		I	L	Fon	
for				I	L	Fore	
fos				I	E	Siraya	
fpe				I	L	Fernando Po Creole English	
fqs				I	L	Fas	
fra	fre	fra	fr	I	L	French	
frc				I	L	Cajun French	
frd				I	L	Fordata	
frk				I	H	Frankish	
frm	frm	frm		I	H	Middle French (ca. 1400-1600)	
fro	fro	fro		I	H	Old French (842-ca. 1400)	
frp				I	L	Arpitan	
frq				I	L	Forak	
frr	frr	frr		I	L	Northern Frisian	
frs	frs	frs		I	L	Eastern Frisian	
frt				I	L	Fortsenal	
fry	fry	fry	fy	I	L	Western Frisian	
fse				I	L	Finnish Sign Language	
fsl				I	L	French Sign Language	
fss				I	L	Finland-Swedish Sign Language	
fub				I	L	Adamawa Fulfulde	
fuc				I	L	Pulaar	
fud				I	L	East Futuna	
fue				I	L	Borgu Fulfulde	
fuf				I	L	Pular	
fuh				I	L	Western Niger Fulfulde	
fui				I	L	Bagirmi Fulfulde	
fuj				I	L	Ko	
ful	ful	ful	ff	M	L	Fulah	
fum				I	L	Fum	
fun				I	L	Fulniô	
fuq				I	L	Central-Eastern Niger Fulfulde	
fur	fur	fur		I	L	Friulian	
fut				I	L	Futuna-Aniwa	
fuu				I	L	Furu	
fuv				I	L	Nigerian Fulfulde	
fuy				I	L	Fuyug	
fvr				I	L	Fur	
fwa				I	L	Fwâi	
fwe				I	L	Fwe	
gaa	gaa	gaa		I	L	Ga	
gab				I	L	Gabri	
gac				I	L	Mixed Great Andamanese	
gad				I	L	Gaddang	
gae				I	L	Guarequena	
gaf				I	L	Gende	
gag				I	L	Gagauz	
gah				I	L	Alekano	
gai				I	L	Borei	
gaj				I	L	Gadsup	
gak				I	L	Gamkonora	
gal				I	L	Galolen	
gam				I	L	Kandawo	
gan				I	L	Gan Chinese	
gao				I	L	Gants	
gap				I	L	Gal	
gaq				I	L	Gata'	
gar				I	L	Galeya	
gas				I	L	Adiwasi Garasia	
gat				I	L	Kenati	
gau				I	L	Mudhili Gadaba	
gaw				I	L	Nobonob	
gax				I	L	Borana-Arsi-Guji Oromo	
gay	gay	gay		I	L	Gayo	
gaz				I	L	West Central Oromo	
gba	gba	gba		M	L	Gbaya (Central African Republic)	
gbb				I	L	Kaytetye	
gbd				I	L	Karajarri	
gbe				I	L	Niksek	
gbf				I	L	Gaikundi	
gbg				I	L	Gbanziri	
gbh				I	L	Defi Gbe	
gbi				I	L	Galela	
gbj				I	L	Bodo Gadaba	
gbk				I	L	Gaddi	
gbl				I	L	Gamit	
gbm				I	L	Garhwali	
gbn				I	L	Mo'da	
gbo				I	L	Northern Grebo	
gbp				I	L	Gbaya-Bossangoa	
gbq				I	L	Gbaya-Bozoum	
gbr				I	L	Gbagyi	
gbs				I	L	Gbesi Gbe	
gbu				I	L	Gagadu	
gbv				I	L	Gbanu	
gbw				I	L	Gabi-Gabi	
gbx				I	L	Eastern Xwla Gbe	
gby				I	L	Gbari	
gbz				I	L	Zoroastrian Dari	
gcc				I	L	Mali	
gcd				I	E	Ganggalida	
gce				I	E	Galice	
gcf				I	L	Guadeloupean Creole French	
gcl				I	L	Grenadian Creole English	
gcn				I	L	Gaina	
gcr				I	L	Guianese Creole French	
gct				I	L	Colonia Tovar German	
gda				I	L	Gade Lohar	
gdb				I	L	Pottangi Ollar Gadaba	
gdc				I	E	Gugu Badhun	
gdd				I	L	Gedaged	
gde				I	L	Gude	
gdf				I	L	Guduf-Gava	
gdg				I	L	Ga'dang	
gdh				I	L	Gadjerawang	
gdi				I	L	Gundi	
gdj				I	L	Gurdjar	
gdk				I	L	Gadang	
gdl				I	L	Dirasha	
gdm				I	L	Laal	
gdn				I	L	Umanakaina	
gdo				I	L	Ghodoberi	
gdq				I	L	Mehri	
gdr				I	L	Wipi	
gds				I	L	Ghandruk Sign Language	
gdt				I	E	Kungardutyi	
gdu				I	L	Gudu	
gdx				I	L	Godwari	
gea				I	L	Geruma	
geb				I	L	Kire	
gec				I	L	Gboloo Grebo	
ged				I	L	Gade	
gef				I	L	Gerai	
geg				I	L	Gengle	
geh				I	L	Hutterite German	
gei				I	L	Gebe	
gej				I	L	Gen	
gek				I	L	Ywom	
gel				I	L	ut-Ma'in	
geq				I	L	Geme	
ges				I	L	Geser-Gorom	
gev				I	L	Eviya	
gew				I	L	Gera	
gex				I	L	Garre	
gey				I	L	Enya	
gez	gez	gez		I	A	Geez	
gfk				I	L	Patpatar	
gft				I	E	Gafat	
gga				I	L	Gao	
ggb				I	L	Gbii	
ggd				I	E	Gugadj	
gge				I	L	Gurr-goni	
ggg				I	L	Gurgula	
ggk				I	E	Kungarakany	
ggl				I	L	Ganglau	
ggt				I	L	Gitua	
ggu				I	L	Gagu	
ggw				I	L	Gogodala	
gha				I	L	Ghadamès	
ghc				I	H	Hiberno-Scottish Gaelic	
ghe				I	L	Southern Ghale	
ghh				I	L	Northern Ghale	
ghk				I	L	Geko Karen	
ghl				I	L	Ghulfan	
ghn				I	L	Ghanongga	
gho				I	E	Ghomara	
ghr				I	L	Ghera	
ghs				I	L	Guhu-Samane	
ght				I	L	Kuke	
gia				I	L	Kija	
gib				I	L	Gibanawa	
gic				I	L	Gail	
gid				I	L	Gidar	
gie				I	L	Gaɓogbo	
gig				I	L	Goaria	
gih				I	L	Githabul	
gil	gil	gil		I	L	Gilbertese	
gim				I	L	Gimi (Eastern Highlands)	
gin				I	L	Hinukh	
gip				I	L	Gimi (West New Britain)	
giq				I	L	Green Gelao	
gir				I	L	Red Gelao	
gis				I	L	North Giziga	
git				I	L	Gitxsan	
giu				I	L	Mulao	
giw				I	L	White Gelao	
gix				I	L	Gilima	
giy				I	L	Giyug	
giz				I	L	South Giziga	
gji				I	L	Geji	
gjk				I	L	Kachi Koli	
gjm				I	E	Gunditjmara	
gjn				I	L	Gonja	
gjr				I	L	Gurindji Kriol	
gju				I	L	Gujari	
gka				I	L	Guya	
gkd				I	L	Magɨ (Madang Province)	
gke				I	L	Ndai	
gkn				I	L	Gokana	
gko				I	E	Kok-Nar	
gkp				I	L	Guinea Kpelle	
gku				I	E	ǂUngkue	
gla	gla	gla	gd	I	L	Scottish Gaelic	
glc				I	L	Bon Gula	
gld				I	L	Nanai	
gle	gle	gle	ga	I	L	Irish	
glg	glg	glg	gl	I	L	Galician	
glh				I	L	Northwest Pashai	
glj				I	L	Gula Iro	
glk				I	L	Gilaki	
gll				I	E	Garlali	
glo				I	L	Galambu	
glr				I	L	Glaro-Twabo	
glu				I	L	Gula (Chad)	
glv	glv	glv	gv	I	L	Manx	
glw				I	L	Glavda	
gly				I	E	Gule	
gma				I	E	Gambera	
gmb				I	L	Gula'alaa	
gmd				I	L	Mághdì	
gmg				I	L	Magɨyi	
gmh	gmh	gmh		I	H	Middle High German (ca. 1050-1500)	
gml				I	H	Middle Low German	
gmm				I	L	Gbaya-Mbodomo	
gmn				I	L	Gimnime	
gmr				I	L	Mirning	
gmu				I	L	Gumalu	
gmv				I	L	Gamo	
gmx				I	L	Magoma	
gmy				I	A	Mycenaean Greek	
gmz				I	L	Mgbolizhia	
gna				I	L	Kaansa	
gnb				I	L	Gangte	
gnc				I	E	Guanche	
gnd				I	L	Zulgo-Gemzek	
gne				I	L	Ganang	
gng				I	L	Ngangam	
gnh				I	L	Lere	
gni				I	L	Gooniyandi	
gnj				I	L	Ngen	
gnk				I	L	ǁGana	
gnl				I	E	Gangulu	
gnm				I	L	Ginuman	
gnn				I	L	Gumatj	
gno				I	L	Northern Gondi	
gnq				I	L	Gana	
gnr				I	E	Gureng Gureng	
gnt				I	L	Guntai	
gnu				I	L	Gnau	
gnw				I	L	Western Bolivian Guaraní	
gnz				I	L	Ganzi	
goa				I	L	Guro	
gob				I	L	Playero	
goc				I	L	Gorakor	
god				I	L	Godié	
goe				I	L	Gongduk	
gof				I	L	Gofa	
gog				I	L	Gogo	
goh	goh	goh		I	H	Old High German (ca. 750-1050)	
goi				I	L	Gobasi	
goj				I	L	Gowlan	
gok				I	L	Gowli	
gol				I	L	Gola	
gom				I	L	Goan Konkani	
gon	gon	gon		M	L	Gondi	
goo				I	L	Gone Dau	
gop				I	L	Yeretuar	
goq				I	L	Gorap	
gor	gor	gor		I	L	Gorontalo	
gos				I	L	Gronings	
got	got	got		I	A	Gothic	
gou				I	L	Gavar	
gow				I	L	Gorowa	
gox				I	L	Gobu	
goy				I	L	Goundo	
goz				I	L	Gozarkhani	
gpa				I	L	Gupa-Abawa	
gpe				I	L	Ghanaian Pidgin English	
gpn				I	L	Taiap	
gqa				I	L	Ga'anda	
gqi				I	L	Guiqiong	
gqn				I	E	Guana (Brazil)	
gqr				I	L	Gor	
gqu				I	L	Qau	
gra				I	L	Rajput Garasia	
grb	grb	grb		M	L	Grebo	
grc	grc	grc		I	H	Ancient Greek (to 1453)	
grd				I	L	Guruntum-Mbaaru	
grg				I	L	Madi	
grh				I	L	Gbiri-Niragu	
gri				I	L	Ghari	
grj				I	L	Southern Grebo	
grm				I	L	Kota Marudu Talantang	
grn	grn	grn	gn	M	L	Guarani	
gro				I	L	Groma	
grq				I	L	Gorovu	
grr				I	L	Taznatit	
grs				I	L	Gresi	
grt				I	L	Garo	
gru				I	L	Kistane	
grv				I	L	Central Grebo	
grw				I	L	Gweda	
grx				I	L	Guriaso	
gry				I	L	Barclayville Grebo	
grz				I	L	Guramalum	
gse				I	L	Ghanaian Sign Language	
gsg				I	L	German Sign Language	
gsl				I	L	Gusilay	
gsm				I	L	Guatemalan Sign Language	
gsn				I	L	Nema	
gso				I	L	Southwest Gbaya	
gsp				I	L	Wasembo	
gss				I	L	Greek Sign Language	
gsw	gsw	gsw		I	L	Swiss German	
gta				I	L	Guató	
gtu				I	E	Aghu-Tharnggala	
gua				I	L	Shiki	
gub				I	L	Guajajára	
guc				I	L	Wayuu	
gud				I	L	Yocoboué Dida	
gue				I	L	Gurindji	
guf				I	L	Gupapuyngu	
gug				I	L	Paraguayan Guaraní	
guh				I	L	Guahibo	
gui				I	L	Eastern Bolivian Guaraní	
guj	guj	guj	gu	I	L	Gujarati	
guk				I	L	Gumuz	
gul				I	L	Sea Island Creole English	
gum				I	L	Guambiano	
gun				I	L	Mbyá Guaraní	
guo				I	L	Guayabero	
gup				I	L	Gunwinggu	
guq				I	L	Aché	
gur				I	L	Farefare	
gus				I	L	Guinean Sign Language	
gut				I	L	Maléku Jaíka	
guu				I	L	Yanomamö	
guw				I	L	Gun	
gux				I	L	Gourmanchéma	
guz				I	L	Gusii	
gva				I	L	Guana (Paraguay)	
gvc				I	L	Guanano	
gve				I	L	Duwet	
gvf				I	L	Golin	
gvj				I	L	Guajá	
gvl				I	L	Gulay	
gvm				I	L	Gurmana	
gvn				I	L	Kuku-Yalanji	
gvo				I	L	Gavião Do Jiparaná	
gvp				I	L	Pará Gavião	
gvr				I	L	Gurung	
gvs				I	L	Gumawana	
gvy				I	E	Guyani	
gwa				I	L	Mbato	
gwb				I	L	Gwa	
gwc				I	L	Gawri	
gwd				I	L	Gawwada	
gwe				I	L	Gweno	
gwf				I	L	Gowro	
gwg				I	L	Moo	
gwi	gwi	gwi		I	L	Gwichʼin	
gwj				I	L	ǀGwi	
gwm				I	E	Awngthim	
gwn				I	L	Gwandara	
gwr				I	L	Gwere	
gwt				I	L	Gawar-Bati	
gwu				I	E	Guwamu	
gww				I	L	Kwini	
gwx				I	L	Gua	
gxx				I	L	Wè Southern	
gya				I	L	Northwest Gbaya	
gyb				I	L	Garus	
gyd				I	L	Kayardild	
gye				I	L	Gyem	
gyf				I	E	Gungabula	
gyg				I	L	Gbayi	
gyi				I	L	Gyele	
gyl				I	L	Gayil	
gym				I	L	Ngäbere	
gyn				I	L	Guyanese Creole English	
gyo				I	L	Gyalsumdo	
gyr				I	L	Guarayu	
gyy				I	E	Gunya	
gza				I	L	Ganza	
gzi				I	L	Gazi	
gzn				I	L	Gane	
haa				I	L	Han	
hab				I	L	Hanoi Sign Language	
hac				I	L	Gurani	
had				I	L	Hatam	
hae				I	L	Eastern Oromo	
haf				I	L	Haiphong Sign Language	
hag				I	L	Hanga	
hah				I	L	Hahon	
hai	hai	hai		M	L	Haida	
haj				I	L	Hajong	
hak				I	L	Hakka Chinese	
hal				I	L	Halang	
ham				I	L	Hewa	
han				I	L	Hangaza	
hao				I	L	Hakö	
hap				I	L	Hupla	
haq				I	L	Ha	
har				I	L	Harari	
has				I	L	Haisla	
hat	hat	hat	ht	I	L	Haitian	
hau	hau	hau	ha	I	L	Hausa	
hav				I	L	Havu	
haw	haw	haw		I	L	Hawaiian	
hax				I	L	Southern Haida	
hay				I	L	Haya	
haz				I	L	Hazaragi	
hba				I	L	Hamba	
hbb				I	L	Huba	
hbn				I	L	Heiban	
hbo				I	H	Ancient Hebrew	
hbs			sh	M	L	Serbo-Croatian	Code element for 639-1 has been deprecated
hbu				I	L	Habu	
hca				I	L	Andaman Creole Hindi	
hch				I	L	Huichol	
hdn				I	L	Northern Haida	
hds				I	L	Honduras Sign Language	
hdy				I	L	Hadiyya	
hea				I	L	Northern Qiandong Miao	
heb	heb	heb	he	I	L	Hebrew	
hed				I	L	Herdé	
heg				I	L	Helong	
heh				I	L	Hehe	
hei				I	L	Heiltsuk	
hem				I	L	Hemba	
her	her	her	hz	I	L	Herero	
hgm				I	L	Haiǁom	
hgw				I	L	Haigwai	
hhi				I	L	Hoia Hoia	
hhr				I	L	Kerak	
hhy				I	L	Hoyahoya	
hia				I	L	Lamang	
hib				I	E	Hibito	
hid				I	L	Hidatsa	
hif				I	L	Fiji Hindi	
hig				I	L	Kamwe	
hih				I	L	Pamosu	
hii				I	L	Hinduri	
hij				I	L	Hijuk	
hik				I	L	Seit-Kaitetu	
hil	hil	hil		I	L	Hiligaynon	
hin	hin	hin	hi	I	L	Hindi	
hio				I	L	Tsoa	
hir				I	L	Himarimã	
hit	hit	hit		I	A	Hittite	
hiw				I	L	Hiw	
hix				I	L	Hixkaryána	
hji				I	L	Haji	
hka				I	L	Kahe	
hke				I	L	Hunde	
hkk				I	L	Hunjara-Kaina Ke	
hkn				I	L	Mel-Khaonh	
hks				I	L	Hong Kong Sign Language	
hla				I	L	Halia	
hlb				I	L	Halbi	
hld				I	L	Halang Doan	
hle				I	L	Hlersu	
hlt				I	L	Matu Chin	
hlu				I	A	Hieroglyphic Luwian	
hma				I	L	Southern Mashan Hmong	
hmb				I	L	Humburi Senni Songhay	
hmc				I	L	Central Huishui Hmong	
hmd				I	L	Large Flowery Miao	
hme				I	L	Eastern Huishui Hmong	
hmf				I	L	Hmong Don	
hmg				I	L	Southwestern Guiyang Hmong	
hmh				I	L	Southwestern Huishui Hmong	
hmi				I	L	Northern Huishui Hmong	
hmj				I	L	Ge	
hmk				I	A	Maek	
hml				I	L	Luopohe Hmong	
hmm				I	L	Central Mashan Hmong	
hmn	hmn	hmn		M	L	Hmong	
hmo	hmo	hmo	ho	I	L	Hiri Motu	
hmp				I	L	Northern Mashan Hmong	
hmq				I	L	Eastern Qiandong Miao	
hmr				I	L	Hmar	
hms				I	L	Southern Qiandong Miao	
hmt				I	L	Hamtai	
hmu				I	L	Hamap	
hmv				I	L	Hmong Dô	
hmw				I	L	Western Mashan Hmong	
hmy				I	L	Southern Guiyang Hmong	
hmz				I	L	Hmong Shua	
hna				I	L	Mina (Cameroon)	
hnd				I	L	Southern Hindko	
hne				I	L	Chhattisgarhi	
hng				I	L	Hungu
hnh				I	L	ǁAni	
hni				I	L	Hani	
hnj				I	L	Hmong Njua	
hnn				I	L	Hanunoo	
hno				I	L	Northern Hindko	
hns				I	L	Caribbean Hindustani	
hnu				I	L	Hung	
hoa				I	L	Hoava	
hob				I	L	Mari (Madang Province)	
hoc				I	L	Ho	
hod				I	E	Holma	
hoe				I	L	Horom	
hoh				I	L	Hobyót	
hoi				I	L	Holikachuk	
hoj				I	L	Hadothi	
hol				I	L	Holu	
hom				I	E	Homa	
hoo				I	L	Holoholo	
hop				I	L	Hopi	
hor				I	E	Horo	
hos				I	L	Ho Chi Minh City Sign Language	
hot				I	L	Hote	
hov				I	L	Hovongan	
how				I	L	Honi	
hoy				I	L	Holiya	
hoz				I	L	Hozo	
hpo				I	E	Hpon	
hps				I	L	Hawai'i Sign Language (HSL)	
hra				I	L	Hrangkhol	
hrc				I	L	Niwer Mil	
hre				I	L	Hre	
hrk				I	L	Haruku	
hrm				I	L	Horned Miao	
hro				I	L	Haroi	
hrp				I	E	Nhirrpi	
hrt				I	L	Hértevin	
hru				I	L	Hruso	
hrv	hrv	hrv	hr	I	L	Croatian	
hrw				I	L	Warwar Feni	
hrx				I	L	Hunsrik	
hrz				I	L	Harzani	
hsb	hsb	hsb		I	L	Upper Sorbian	
hsh				I	L	Hungarian Sign Language	
hsl				I	L	Hausa Sign Language	
hsn				I	L	Xiang Chinese	
hss				I	L	Harsusi	
hti				I	E	Hoti	
hto				I	L	Minica Huitoto	
hts				I	L	Hadza	
htu				I	L	Hitu	
htx				I	A	Middle Hittite	
hub				I	L	Huambisa	
huc				I	L	ǂHua	
hud				I	L	Huaulu	
hue				I	L	San Francisco Del Mar Huave	
huf				I	L	Humene	
hug				I	L	Huachipaeri	
huh				I	L	Huilliche	
hui				I	L	Huli	
huj				I	L	Northern Guiyang Hmong	
huk				I	E	Hulung	
hul				I	L	Hula	
hum				I	L	Hungana	
hun	hun	hun	hu	I	L	Hungarian	
huo				I	L	Hu	
hup	hup	hup		I	L	Hupa	
huq				I	L	Tsat	
hur				I	L	Halkomelem	
hus				I	L	Huastec	
hut				I	L	Humla	
huu				I	L	Murui Huitoto	
huv				I	L	San Mateo Del Mar Huave	
huw				I	E	Hukumina	
hux				I	L	Nüpode Huitoto	
huy				I	L	Hulaulá	
huz				I	L	Hunzib	
hvc				I	L	Haitian Vodoun Culture Language	
hve				I	L	San Dionisio Del Mar Huave	
hvk				I	L	Haveke	
hvn				I	L	Sabu	
hvv				I	L	Santa María Del Mar Huave	
hwa				I	L	Wané	
hwc				I	L	Hawai'i Creole English	
hwo				I	L	Hwana	
hya				I	L	Hya	
hye	arm	hye	hy	I	L	Armenian	
hyw				I	L	Western Armenian	
iai				I	L	Iaai	
ian				I	L	Iatmul	
iar				I	L	Purari	
iba	iba	iba		I	L	Iban	
ibb				I	L	Ibibio	
ibd				I	L	Iwaidja	
ibe				I	L	Akpes	
ibg				I	L	Ibanag	
ibh				I	L	Bih	
ibl				I	L	Ibaloi	
ibm				I	L	Agoi	
ibn				I	L	Ibino	
ibo	ibo	ibo	ig	I	L	Igbo	
ibr				I	L	Ibuoro	
ibu				I	L	Ibu	
iby				I	L	Ibani	
ica				I	L	Ede Ica	
ich				I	L	Etkywan	
icl				I	L	Icelandic Sign Language	
icr				I	L	Islander Creole English	
ida				I	L	Idakho-Isukha-Tiriki	
idb				I	L	Indo-Portuguese	
idc				I	L	Idon	
idd				I	L	Ede Idaca	
ide				I	L	Idere	
idi				I	L	Idi	
ido	ido	ido	io	I	C	Ido	
idr				I	L	Indri	
ids				I	L	Idesa	
idt				I	L	Idaté	
idu				I	L	Idoma	
ifa				I	L	Amganad Ifugao	
ifb				I	L	Batad Ifugao	
ife				I	L	Ifè	
iff				I	E	Ifo	
ifk				I	L	Tuwali Ifugao	
ifm				I	L	Teke-Fuumu	
ifu				I	L	Mayoyao Ifugao	
ify				I	L	Keley-I Kallahan	
igb				I	L	Ebira	
ige				I	L	Igede	
igg				I	L	Igana	
igl				I	L	Igala	
igm				I	L	Kanggape	
ign				I	L	Ignaciano	
igo				I	L	Isebe	
igs				I	C	Interglossa	
igw				I	L	Igwe	
ihb				I	L	Iha Based Pidgin	
ihi				I	L	Ihievbe	
ihp				I	L	Iha	
ihw				I	E	Bidhawal	
iii	iii	iii	ii	I	L	Sichuan Yi	
iin				I	E	Thiin	
ijc				I	L	Izon	
ije				I	L	Biseni	
ijj				I	L	Ede Ije	
ijn				I	L	Kalabari	
ijs				I	L	Southeast Ijo	
ike				I	L	Eastern Canadian Inuktitut	
iki				I	L	Iko	
ikk				I	L	Ika	
ikl				I	L	Ikulu	
iko				I	L	Olulumo-Ikom	
ikp				I	L	Ikpeshi	
ikr				I	E	Ikaranggal	
iks				I	L	Inuit Sign Language	
ikt				I	L	Inuinnaqtun	
iku	iku	iku	iu	M	L	Inuktitut	
ikv				I	L	Iku-Gora-Ankwa	
ikw				I	L	Ikwere	
ikx				I	L	Ik	
ikz				I	L	Ikizu	
ila				I	L	Ile Ape	
ilb				I	L	Ila	
ile	ile	ile	ie	I	C	Interlingue	
ilg				I	E	Garig-Ilgar	
ili				I	L	Ili Turki	
ilk				I	L	Ilongot	
ilm				I	L	Iranun (Malaysia)	
ilo	ilo	ilo		I	L	Iloko	
ilp				I	L	Iranun (Philippines)	
ils				I	L	International Sign	
ilu				I	L	Ili'uun	
ilv				I	L	Ilue	
ima				I	L	Mala Malasar	
imi				I	L	Anamgura	
iml				I	E	Miluk	
imn				I	L	Imonda	
imo				I	L	Imbongu	
imr				I	L	Imroing	
ims				I	A	Marsian	
imy				I	A	Milyan	
ina	ina	ina	ia	I	C	Interlingua (International Auxiliary Language Association)	
inb				I	L	Inga	
ind	ind	ind	id	I	L	Indonesian	
ing				I	L	Degexit'an	
inh	inh	inh		I	L	Ingush	
inj				I	L	Jungle Inga	
inl				I	L	Indonesian Sign Language	
inm				I	A	Minaean	
inn				I	L	Isinai	
ino				I	L	Inoke-Yate	
inp				I	L	Iñapari	
ins				I	L	Indian Sign Language	
int				I	L	Intha	
inz				I	E	Ineseño	
ior				I	L	Inor	
iou				I	L	Tuma-Irumu	
iow				I	E	Iowa-Oto	
ipi				I	L	Ipili	
ipk	ipk	ipk	ik	M	L	Inupiaq	
ipo				I	L	Ipiko	
iqu				I	L	Iquito	
iqw				I	L	Ikwo	
ire				I	L	Iresim	
irh				I	L	Irarutu	
iri				I	L	Rigwe	
irk				I	L	Iraqw	
irn				I	L	Irántxe	
irr				I	L	Ir	
iru				I	L	Irula	
irx				I	L	Kamberau	
iry				I	L	Iraya	
isa				I	L	Isabi	
isc				I	L	Isconahua	
isd				I	L	Isnag	
ise				I	L	Italian Sign Language	
isg				I	L	Irish Sign Language	
ish				I	L	Esan	
isi				I	L	Nkem-Nkum	
isk				I	L	Ishkashimi	
isl	ice	isl	is	I	L	Icelandic	
ism				I	L	Masimasi	
isn				I	L	Isanzu	
iso				I	L	Isoko	
isr				I	L	Israeli Sign Language	
ist				I	L	Istriot	
isu				I	L	Isu (Menchum Division)	
ita	ita	ita	it	I	L	Italian	
itb				I	L	Binongan Itneg	
itd				I	L	Southern Tidung	
ite				I	E	Itene	
iti				I	L	Inlaod Itneg	
itk				I	L	Judeo-Italian	
itl				I	L	Itelmen	
itm				I	L	Itu Mbon Uzo	
ito				I	L	Itonama	
itr				I	L	Iteri	
its				I	L	Isekiri	
itt				I	L	Maeng Itneg	
itv				I	L	Itawit	
itw				I	L	Ito	
itx				I	L	Itik	
ity				I	L	Moyadan Itneg	
itz				I	L	Itzá	
ium				I	L	Iu Mien	
ivb				I	L	Ibatan	
ivv				I	L	Ivatan	
iwk				I	L	I-Wak	
iwm				I	L	Iwam	
iwo				I	L	Iwur	
iws				I	L	Sepik Iwam	
ixc				I	L	Ixcatec	
ixl				I	L	Ixil	
iya				I	L	Iyayu	
iyo				I	L	Mesaka	
iyx				I	L	Yaka (Congo)	
izh				I	L	Ingrian	
izr				I	L	Izere	
izz				I	L	Izii	
jaa				I	L	Jamamadí	
jab				I	L	Hyam	
jac				I	L	Popti'	
jad				I	L	Jahanka	
jae				I	L	Yabem	
jaf				I	L	Jara	
jah				I	L	Jah Hut	
jaj				I	L	Zazao	
jak				I	L	Jakun	
jal				I	L	Yalahatan	
jam				I	L	Jamaican Creole English	
jan				I	E	Jandai	
jao				I	L	Yanyuwa	
jaq				I	L	Yaqay	
jas				I	L	New Caledonian Javanese	
jat				I	L	Jakati	
jau				I	L	Yaur	
jav	jav	jav	jv	I	L	Javanese	
jax				I	L	Jambi Malay	
jay				I	L	Yan-nhangu	
jaz				I	L	Jawe	
jbe				I	L	Judeo-Berber	
jbi				I	E	Badjiri	
jbj				I	L	Arandai	
jbk				I	L	Barikewa	
jbn				I	L	Nafusi	
jbo	jbo	jbo		I	C	Lojban	
jbr				I	L	Jofotek-Bromnya	
jbt				I	L	Jabutí	
jbu				I	L	Jukun Takum	
jbw				I	E	Yawijibaya	
jcs				I	L	Jamaican Country Sign Language	
jct				I	L	Krymchak	
jda				I	L	Jad	
jdg				I	L	Jadgali	
jdt				I	L	Judeo-Tat	
jeb				I	L	Jebero	
jee				I	L	Jerung	
jeh				I	L	Jeh	
jei				I	L	Yei	
jek				I	L	Jeri Kuo	
jel				I	L	Yelmek	
jen				I	L	Dza	
jer				I	L	Jere	
jet				I	L	Manem	
jeu				I	L	Jonkor Bourmataguil	
jgb				I	E	Ngbee	
jge				I	L	Judeo-Georgian	
jgk				I	L	Gwak	
jgo				I	L	Ngomba	
jhi				I	L	Jehai	
jhs				I	L	Jhankot Sign Language	
jia				I	L	Jina	
jib				I	L	Jibu	
jic				I	L	Tol	
jid				I	L	Bu	
jie				I	L	Jilbe	
jig				I	L	Jingulu	
jih				I	L	sTodsde	
jii				I	L	Jiiddu	
jil				I	L	Jilim	
jim				I	L	Jimi (Cameroon)	
jio				I	L	Jiamao	
jiq				I	L	Guanyinqiao	
jit				I	L	Jita	
jiu				I	L	Youle Jinuo	
jiv				I	L	Shuar	
jiy				I	L	Buyuan Jinuo	
jje				I	L	Jejueo	
jjr				I	L	Bankal	
jka				I	L	Kaera	
jkm				I	L	Mobwa Karen	
jko				I	L	Kubo	
jkp				I	L	Paku Karen	
jkr				I	L	Koro (India)	
jku				I	L	Labir	
jle				I	L	Ngile	
jls				I	L	Jamaican Sign Language	
jma				I	L	Dima	
jmb				I	L	Zumbun	
jmc				I	L	Machame	
jmd				I	L	Yamdena	
jmi				I	L	Jimi (Nigeria)	
jml				I	L	Jumli	
jmn				I	L	Makuri Naga	
jmr				I	L	Kamara	
jms				I	L	Mashi (Nigeria)	
jmw				I	L	Mouwase	
jmx				I	L	Western Juxtlahuaca Mixtec	
jna				I	L	Jangshung	
jnd				I	L	Jandavra	
jng				I	E	Yangman	
jni				I	L	Janji	
jnj				I	L	Yemsa	
jnl				I	L	Rawat	
jns				I	L	Jaunsari	
job				I	L	Joba	
jod				I	L	Wojenaka	
jog				I	L	Jogi	
jor				I	E	Jorá	
jos				I	L	Jordanian Sign Language	
jow				I	L	Jowulu	
jpa				I	H	Jewish Palestinian Aramaic	
jpn	jpn	jpn	ja	I	L	Japanese	
jpr	jpr	jpr		I	L	Judeo-Persian	
jqr				I	L	Jaqaru	
jra				I	L	Jarai	
jrb	jrb	jrb		M	L	Judeo-Arabic	
jrr				I	L	Jiru	
jrt				I	L	Jorto	
jru				I	L	Japrería	
jsl				I	L	Japanese Sign Language	
jua				I	L	Júma	
jub				I	L	Wannu	
juc				I	E	Jurchen	
jud				I	L	Worodougou	
juh				I	L	Hõne	
jui				I	E	Ngadjuri	
juk				I	L	Wapan	
jul				I	L	Jirel	
jum				I	L	Jumjum	
jun				I	L	Juang	
juo				I	L	Jiba	
jup				I	L	Hupdë	
jur				I	L	Jurúna	
jus				I	L	Jumla Sign Language	
jut				I	H	Jutish	
juu				I	L	Ju	
juw				I	L	Wãpha	
juy				I	L	Juray	
jvd				I	L	Javindo	
jvn				I	L	Caribbean Javanese	
jwi				I	L	Jwira-Pepesa	
jya				I	L	Jiarong	
jye				I	L	Judeo-Yemeni Arabic	
jyy				I	L	Jaya	
kaa	kaa	kaa		I	L	Kara-Kalpak	
kab	kab	kab		I	L	Kabyle	
kac	kac	kac		I	L	Kachin	
kad				I	L	Adara	
kae				I	E	Ketangalan	
kaf				I	L	Katso	
kag				I	L	Kajaman	
kah				I	L	Kara (Central African Republic)	
kai				I	L	Karekare	
kaj				I	L	Jju	
kak				I	L	Kalanguya	
kal	kal	kal	kl	I	L	Kalaallisut	
kam	kam	kam		I	L	Kamba (Kenya)	
kan	kan	kan	kn	I	L	Kannada	
kao				I	L	Xaasongaxango	
kap				I	L	Bezhta	
kaq				I	L	Capanahua	
kas	kas	kas	ks	I	L	Kashmiri	
kat	geo	kat	ka	I	L	Georgian	
kau	kau	kau	kr	M	L	Kanuri	
kav				I	L	Katukína	
kaw	kaw	kaw		I	A	Kawi	
kax				I	L	Kao	
kay				I	L	Kamayurá	
kaz	kaz	kaz	kk	I	L	Kazakh	
kba				I	E	Kalarko	
kbb				I	E	Kaxuiâna	
kbc				I	L	Kadiwéu	
kbd	kbd	kbd		I	L	Kabardian	
kbe				I	L	Kanju	
kbg				I	L	Khamba	
kbh				I	L	Camsá	
kbi				I	L	Kaptiau	
kbj				I	L	Kari	
kbk				I	L	Grass Koiari	
kbl				I	L	Kanembu	
kbm				I	L	Iwal	
kbn				I	L	Kare (Central African Republic)	
kbo				I	L	Keliko	
kbp				I	L	Kabiyè	
kbq				I	L	Kamano	
kbr				I	L	Kafa	
kbs				I	L	Kande	
kbt				I	L	Abadi	
kbu				I	L	Kabutra	
kbv				I	L	Dera (Indonesia)	
kbw				I	L	Kaiep	
kbx				I	L	Ap Ma	
kby				I	L	Manga Kanuri	
kbz				I	L	Duhwa	
kca				I	L	Khanty	
kcb				I	L	Kawacha	
kcc				I	L	Lubila	
kcd				I	L	Ngkâlmpw Kanum	
kce				I	L	Kaivi	
kcf				I	L	Ukaan	
kcg				I	L	Tyap	
kch				I	L	Vono	
kci				I	L	Kamantan	
kcj				I	L	Kobiana	
kck				I	L	Kalanga	
kcl				I	L	Kela (Papua New Guinea)	
kcm				I	L	Gula (Central African Republic)	
kcn				I	L	Nubi	
kco				I	L	Kinalakna	
kcp				I	L	Kanga	
kcq				I	L	Kamo	
kcr				I	L	Katla	
kcs				I	L	Koenoem	
kct				I	L	Kaian	
kcu				I	L	Kami (Tanzania)	
kcv				I	L	Kete	
kcw				I	L	Kabwari	
kcx				I	L	Kachama-Ganjule	
kcy				I	L	Korandje	
kcz				I	L	Konongo	
kda				I	E	Worimi	
kdc				I	L	Kutu	
kdd				I	L	Yankunytjatjara	
kde				I	L	Makonde	
kdf				I	L	Mamusi	
kdg				I	L	Seba	
kdh				I	L	Tem	
kdi				I	L	Kumam	
kdj				I	L	Karamojong	
kdk				I	L	Numèè	
kdl				I	L	Tsikimba	
kdm				I	L	Kagoma	
kdn				I	L	Kunda	
kdp				I	L	Kaningdon-Nindem	
kdq				I	L	Koch	
kdr				I	L	Karaim	
kdt				I	L	Kuy	
kdu				I	L	Kadaru	
kdw				I	L	Koneraw	
kdx				I	L	Kam	
kdy				I	L	Keder	
kdz				I	L	Kwaja	
kea				I	L	Kabuverdianu	
keb				I	L	Kélé	
kec				I	L	Keiga	
ked				I	L	Kerewe	
kee				I	L	Eastern Keres	
kef				I	L	Kpessi	
keg				I	L	Tese	
keh				I	L	Keak	
kei				I	L	Kei	
kej				I	L	Kadar	
kek				I	L	Kekchí	
kel				I	L	Kela (Democratic Republic of Congo)	
kem				I	L	Kemak	
ken				I	L	Kenyang	
keo				I	L	Kakwa	
kep				I	L	Kaikadi	
keq				I	L	Kamar	
ker				I	L	Kera	
kes				I	L	Kugbo	
ket				I	L	Ket	
keu				I	L	Akebu	
kev				I	L	Kanikkaran	
kew				I	L	West Kewa	
kex				I	L	Kukna	
key				I	L	Kupia	
kez				I	L	Kukele	
kfa				I	L	Kodava	
kfb				I	L	Northwestern Kolami	
kfc				I	L	Konda-Dora	
kfd				I	L	Korra Koraga	
kfe				I	L	Kota (India)	
kff				I	L	Koya	
kfg				I	L	Kudiya	
kfh				I	L	Kurichiya	
kfi				I	L	Kannada Kurumba	
kfj				I	L	Kemiehua	
kfk				I	L	Kinnauri	
kfl				I	L	Kung	
kfm				I	L	Khunsari	
kfn				I	L	Kuk	
kfo				I	L	Koro (Côte d'Ivoire)	
kfp				I	L	Korwa	
kfq				I	L	Korku	
kfr				I	L	Kachhi	
kfs				I	L	Bilaspuri	
kft				I	L	Kanjari	
kfu				I	L	Katkari	
kfv				I	L	Kurmukar	
kfw				I	L	Kharam Naga	
kfx				I	L	Kullu Pahari	
kfy				I	L	Kumaoni	
kfz				I	L	Koromfé	
kga				I	L	Koyaga	
kgb				I	L	Kawe	
kge				I	L	Komering	
kgf				I	L	Kube	
kgg				I	L	Kusunda	
kgi				I	L	Selangor Sign Language	
kgj				I	L	Gamale Kham	
kgk				I	L	Kaiwá	
kgl				I	E	Kunggari	
kgm				I	E	Karipúna	
kgn				I	L	Karingani	
kgo				I	L	Krongo	
kgp				I	L	Kaingang	
kgq				I	L	Kamoro	
kgr				I	L	Abun	
kgs				I	L	Kumbainggar	
kgt				I	L	Somyev	
kgu				I	L	Kobol	
kgv				I	L	Karas	
kgw				I	L	Karon Dori	
kgx				I	L	Kamaru	
kgy				I	L	Kyerung	
kha	kha	kha		I	L	Khasi	
khb				I	L	Lü	
khc				I	L	Tukang Besi North	
khd				I	L	Bädi Kanum	
khe				I	L	Korowai	
khf				I	L	Khuen	
khg				I	L	Khams Tibetan	
khh				I	L	Kehu	
khj				I	L	Kuturmi	
khk				I	L	Halh Mongolian	
khl				I	L	Lusi	
khm	khm	khm	km	I	L	Khmer	
khn				I	L	Khandesi	
kho	kho	kho		I	A	Khotanese	
khp				I	L	Kapori	
khq				I	L	Koyra Chiini Songhay	
khr				I	L	Kharia	
khs				I	L	Kasua	
kht				I	L	Khamti	
khu				I	L	Nkhumbi	
khv				I	L	Khvarshi	
khw				I	L	Khowar	
khx				I	L	Kanu	
khy				I	L	Kele (Democratic Republic of Congo)	
khz				I	L	Keapara	
kia				I	L	Kim	
kib				I	L	Koalib	
kic				I	L	Kickapoo	
kid				I	L	Koshin	
kie				I	L	Kibet	
kif				I	L	Eastern Parbate Kham	
kig				I	L	Kimaama	
kih				I	L	Kilmeri	
kii				I	E	Kitsai	
kij				I	L	Kilivila	
kik	kik	kik	ki	I	L	Kikuyu	
kil				I	L	Kariya	
kim				I	L	Karagas	
kin	kin	kin	rw	I	L	Kinyarwanda	
kio				I	L	Kiowa	
kip				I	L	Sheshi Kham	
kiq				I	L	Kosadle	
kir	kir	kir	ky	I	L	Kirghiz	
kis				I	L	Kis	
kit				I	L	Agob	
kiu				I	L	Kirmanjki (individual language)	
kiv				I	L	Kimbu	
kiw				I	L	Northeast Kiwai	
kix				I	L	Khiamniungan Naga	
kiy				I	L	Kirikiri	
kiz				I	L	Kisi	
kja				I	L	Mlap	
kjb				I	L	Q'anjob'al	
kjc				I	L	Coastal Konjo	
kjd				I	L	Southern Kiwai	
kje				I	L	Kisar	
kjg				I	L	Khmu	
kjh				I	L	Khakas	
kji				I	L	Zabana	
kjj				I	L	Khinalugh	
kjk				I	L	Highland Konjo	
kjl				I	L	Western Parbate Kham	
kjm				I	L	Kháng	
kjn				I	L	Kunjen	
kjo				I	L	Harijan Kinnauri	
kjp				I	L	Pwo Eastern Karen	
kjq				I	L	Western Keres	
kjr				I	L	Kurudu	
kjs				I	L	East Kewa	
kjt				I	L	Phrae Pwo Karen	
kju				I	L	Kashaya	
kjv				I	H	Kaikavian Literary Language	
kjx				I	L	Ramopa	
kjy				I	L	Erave	
kjz				I	L	Bumthangkha	
kka				I	L	Kakanda	
kkb				I	L	Kwerisa	
kkc				I	L	Odoodee	
kkd				I	L	Kinuku	
kke				I	L	Kakabe	
kkf				I	L	Kalaktang Monpa	
kkg				I	L	Mabaka Valley Kalinga	
kkh				I	L	Khün	
kki				I	L	Kagulu	
kkj				I	L	Kako	
kkk				I	L	Kokota	
kkl				I	L	Kosarek Yale	
kkm				I	L	Kiong	
kkn				I	L	Kon Keu	
kko				I	L	Karko	
kkp				I	L	Gugubera	
kkq				I	L	Kaeku	
kkr				I	L	Kir-Balar	
kks				I	L	Giiwo	
kkt				I	L	Koi	
kku				I	L	Tumi	
kkv				I	L	Kangean	
kkw				I	L	Teke-Kukuya	
kkx				I	L	Kohin	
kky				I	L	Guugu Yimidhirr	
kkz				I	L	Kaska	
kla				I	E	Klamath-Modoc	
klb				I	L	Kiliwa	
klc				I	L	Kolbila	
kld				I	L	Gamilaraay	
kle				I	L	Kulung (Nepal)	
klf				I	L	Kendeje	
klg				I	L	Tagakaulo	
klh				I	L	Weliki	
kli				I	L	Kalumpang	
klj				I	L	Khalaj	
klk				I	L	Kono (Nigeria)	
kll				I	L	Kagan Kalagan	
klm				I	L	Migum	
kln				M	L	Kalenjin	
klo				I	L	Kapya	
klp				I	L	Kamasa	
klq				I	L	Rumu	
klr				I	L	Khaling	
kls				I	L	Kalasha	
klt				I	L	Nukna	
klu				I	L	Klao	
klv				I	L	Maskelynes	
klw				I	L	Tado	
klx				I	L	Koluwawa	
kly				I	L	Kalao	
klz				I	L	Kabola	
kma				I	L	Konni	
kmb	kmb	kmb		I	L	Kimbundu	
kmc				I	L	Southern Dong	
kmd				I	L	Majukayang Kalinga	
kme				I	L	Bakole	
kmf				I	L	Kare (Papua New Guinea)	
kmg				I	L	Kâte	
kmh				I	L	Kalam	
kmi				I	L	Kami (Nigeria)	
kmj				I	L	Kumarbhag Paharia	
kmk				I	L	Limos Kalinga	
kml				I	L	Tanudan Kalinga	
kmm				I	L	Kom (India)	
kmn				I	L	Awtuw	
kmo				I	L	Kwoma	
kmp				I	L	Gimme	
kmq				I	L	Kwama	
kmr				I	L	Northern Kurdish	
kms				I	L	Kamasau	
kmt				I	L	Kemtuik	
kmu				I	L	Kanite	
kmv				I	L	Karipúna Creole French	
kmw				I	L	Komo (Democratic Republic of Congo)	
kmx				I	L	Waboda	
kmy				I	L	Koma	
kmz				I	L	Khorasani Turkish	
kna				I	L	Dera (Nigeria)	
knb				I	L	Lubuagan Kalinga	
knc				I	L	Central Kanuri	
knd				I	L	Konda	
kne				I	L	Kankanaey	
knf				I	L	Mankanya	
kng				I	L	Koongo	
kni				I	L	Kanufi	
knj				I	L	Western Kanjobal	
knk				I	L	Kuranko	
knl				I	L	Keninjal	
knm				I	L	Kanamarí	
knn				I	L	Konkani (individual language)	
kno				I	L	Kono (Sierra Leone)	
knp				I	L	Kwanja	
knq				I	L	Kintaq	
knr				I	L	Kaningra	
kns				I	L	Kensiu	
knt				I	L	Panoan Katukína	
knu				I	L	Kono (Guinea)	
knv				I	L	Tabo	
knw				I	L	Kung-Ekoka	
knx				I	L	Kendayan	
kny				I	L	Kanyok	
knz				I	L	Kalamsé	
koa				I	L	Konomala	
koc				I	E	Kpati	
kod				I	L	Kodi	
koe				I	L	Kacipo-Balesi	
kof				I	E	Kubi	
kog				I	L	Cogui	
koh				I	L	Koyo	
koi				I	L	Komi-Permyak	
kok	kok	kok		M	L	Konkani (macrolanguage)	
kol				I	L	Kol (Papua New Guinea)	
kom	kom	kom	kv	M	L	Komi	
kon	kon	kon	kg	M	L	Kongo	
koo				I	L	Konzo	
kop				I	L	Waube	
koq				I	L	Kota (Gabon)	
kor	kor	kor	ko	I	L	Korean	
kos	kos	kos		I	L	Kosraean	
kot				I	L	Lagwan	
kou				I	L	Koke	
kov				I	L	Kudu-Camo	
kow				I	L	Kugama	
koy				I	L	Koyukon	
koz				I	L	Korak	
kpa				I	L	Kutto	
kpb				I	L	Mullu Kurumba	
kpc				I	L	Curripaco	
kpd				I	L	Koba	
kpe	kpe	kpe		M	L	Kpelle	
kpf				I	L	Komba	
kpg				I	L	Kapingamarangi	
kph				I	L	Kplang	
kpi				I	L	Kofei	
kpj				I	L	Karajá	
kpk				I	L	Kpan	
kpl				I	L	Kpala	
kpm				I	L	Koho	
kpn				I	E	Kepkiriwát	
kpo				I	L	Ikposo	
kpq				I	L	Korupun-Sela	
kpr				I	L	Korafe-Yegha	
kps				I	L	Tehit	
kpt				I	L	Karata	
kpu				I	L	Kafoa	
kpv				I	L	Komi-Zyrian	
kpw				I	L	Kobon	
kpx				I	L	Mountain Koiali	
kpy				I	L	Koryak	
kpz				I	L	Kupsabiny	
kqa				I	L	Mum	
kqb				I	L	Kovai	
kqc				I	L	Doromu-Koki	
kqd				I	L	Koy Sanjaq Surat	
kqe				I	L	Kalagan	
kqf				I	L	Kakabai	
kqg				I	L	Khe	
kqh				I	L	Kisankasa	
kqi				I	L	Koitabu	
kqj				I	L	Koromira	
kqk				I	L	Kotafon Gbe	
kql				I	L	Kyenele	
kqm				I	L	Khisa	
kqn				I	L	Kaonde	
kqo				I	L	Eastern Krahn	
kqp				I	L	Kimré	
kqq				I	L	Krenak	
kqr				I	L	Kimaragang	
kqs				I	L	Northern Kissi	
kqt				I	L	Klias River Kadazan	
kqu				I	E	Seroa	
kqv				I	L	Okolod	
kqw				I	L	Kandas	
kqx				I	L	Mser	
kqy				I	L	Koorete	
kqz				I	E	Korana	
kra				I	L	Kumhali	
krb				I	E	Karkin	
krc	krc	krc		I	L	Karachay-Balkar	
krd				I	L	Kairui-Midiki	
kre				I	L	Panará	
krf				I	L	Koro (Vanuatu)	
krh				I	L	Kurama	
kri				I	L	Krio	
krj				I	L	Kinaray-A	
krk				I	E	Kerek	
krl	krl	krl		I	L	Karelian	
krn				I	L	Sapo	
krp				I	L	Korop	
krr				I	L	Krung	
krs				I	L	Gbaya (Sudan)	
krt				I	L	Tumari Kanuri	
kru	kru	kru		I	L	Kurukh	
krv				I	L	Kavet	
krw				I	L	Western Krahn	
krx				I	L	Karon	
kry				I	L	Kryts	
krz				I	L	Sota Kanum	
ksa				I	L	Shuwa-Zamani	
ksb				I	L	Shambala	
ksc				I	L	Southern Kalinga	
ksd				I	L	Kuanua	
kse				I	L	Kuni	
ksf				I	L	Bafia	
ksg				I	L	Kusaghe	
ksh				I	L	Kölsch	
ksi				I	L	Krisa	
ksj				I	L	Uare	
ksk				I	L	Kansa	
ksl				I	L	Kumalu	
ksm				I	L	Kumba	
ksn				I	L	Kasiguranin	
kso				I	L	Kofa	
ksp				I	L	Kaba	
ksq				I	L	Kwaami	
ksr				I	L	Borong	
kss				I	L	Southern Kisi	
kst				I	L	Winyé	
ksu				I	L	Khamyang	
ksv				I	L	Kusu	
ksw				I	L	S'gaw Karen	
ksx				I	L	Kedang	
ksy				I	L	Kharia Thar	
ksz				I	L	Kodaku	
kta				I	L	Katua	
ktb				I	L	Kambaata	
ktc				I	L	Kholok	
ktd				I	L	Kokata	
kte				I	L	Nubri	
ktf				I	L	Kwami	
ktg				I	E	Kalkutung	
kth				I	L	Karanga	
kti				I	L	North Muyu	
ktj				I	L	Plapo Krumen	
ktk				I	E	Kaniet	
ktl				I	L	Koroshi	
ktm				I	L	Kurti	
ktn				I	L	Karitiâna	
kto				I	L	Kuot	
ktp				I	L	Kaduo	
ktq				I	E	Katabaga	
kts				I	L	South Muyu	
ktt				I	L	Ketum	
ktu				I	L	Kituba (Democratic Republic of Congo)	
ktv				I	L	Eastern Katu	
ktw				I	E	Kato	
ktx				I	L	Kaxararí	
kty				I	L	Kango (Bas-Uélé District)	
ktz				I	L	Juǀʼhoan	
kua	kua	kua	kj	I	L	Kuanyama	
kub				I	L	Kutep	
kuc				I	L	Kwinsu	
kud				I	L	'Auhelawa	
kue				I	L	Kuman (Papua New Guinea)	
kuf				I	L	Western Katu	
kug				I	L	Kupa	
kuh				I	L	Kushi	
kui				I	L	Kuikúro-Kalapálo	
kuj				I	L	Kuria	
kuk				I	L	Kepo'	
kul				I	L	Kulere	
kum	kum	kum		I	L	Kumyk	
kun				I	L	Kunama	
kuo				I	L	Kumukio	
kup				I	L	Kunimaipa	
kuq				I	L	Karipuna	
kur	kur	kur	ku	M	L	Kurdish	
kus				I	L	Kusaal	
kut	kut	kut		I	L	Kutenai	
kuu				I	L	Upper Kuskokwim	
kuv				I	L	Kur	
kuw				I	L	Kpagua	
kux				I	L	Kukatja	
kuy				I	L	Kuuku-Ya'u	
kuz				I	E	Kunza	
kva				I	L	Bagvalal	
kvb				I	L	Kubu	
kvc				I	L	Kove	
kvd				I	L	Kui (Indonesia)	
kve				I	L	Kalabakan	
kvf				I	L	Kabalai	
kvg				I	L	Kuni-Boazi	
kvh				I	L	Komodo	
kvi				I	L	Kwang	
kvj				I	L	Psikye	
kvk				I	L	Korean Sign Language	
kvl				I	L	Kayaw	
kvm				I	L	Kendem	
kvn				I	L	Border Kuna	
kvo				I	L	Dobel	
kvp				I	L	Kompane	
kvq				I	L	Geba Karen	
kvr				I	L	Kerinci	
kvt				I	L	Lahta Karen	
kvu				I	L	Yinbaw Karen	
kvv				I	L	Kola	
kvw				I	L	Wersing	
kvx				I	L	Parkari Koli	
kvy				I	L	Yintale Karen	
kvz				I	L	Tsakwambo	
kwa				I	L	Dâw	
kwb				I	L	Kwa	
kwc				I	L	Likwala	
kwd				I	L	Kwaio	
kwe				I	L	Kwerba	
kwf				I	L	Kwara'ae	
kwg				I	L	Sara Kaba Deme	
kwh				I	L	Kowiai	
kwi				I	L	Awa-Cuaiquer	
kwj				I	L	Kwanga	
kwk				I	L	Kwakiutl	
kwl				I	L	Kofyar	
kwm				I	L	Kwambi	
kwn				I	L	Kwangali	
kwo				I	L	Kwomtari	
kwp				I	L	Kodia	
kwr				I	L	Kwer	
kws				I	L	Kwese	
kwt				I	L	Kwesten	
kwu				I	L	Kwakum	
kwv				I	L	Sara Kaba Náà	
kww				I	L	Kwinti	
kwx				I	L	Khirwar	
kwy				I	L	San Salvador Kongo	
kwz				I	E	Kwadi	
kxa				I	L	Kairiru	
kxb				I	L	Krobu	
kxc				I	L	Konso	
kxd				I	L	Brunei	
kxf				I	L	Manumanaw Karen	
kxh				I	L	Karo (Ethiopia)	
kxi				I	L	Keningau Murut	
kxj				I	L	Kulfa	
kxk				I	L	Zayein Karen	
kxm				I	L	Northern Khmer	
kxn				I	L	Kanowit-Tanjong Melanau	
kxo				I	E	Kanoé	
kxp				I	L	Wadiyara Koli	
kxq				I	L	Smärky Kanum	
kxr				I	L	Koro (Papua New Guinea)	
kxs				I	L	Kangjia	
kxt				I	L	Koiwat	
kxv				I	L	Kuvi	
kxw				I	L	Konai	
kxx				I	L	Likuba	
kxy				I	L	Kayong	
kxz				I	L	Kerewo	
kya				I	L	Kwaya	
kyb				I	L	Butbut Kalinga	
kyc				I	L	Kyaka	
kyd				I	L	Karey	
kye				I	L	Krache	
kyf				I	L	Kouya	
kyg				I	L	Keyagana	
kyh				I	L	Karok	
kyi				I	L	Kiput	
kyj				I	L	Karao	
kyk				I	L	Kamayo	
kyl				I	L	Kalapuya	
kym				I	L	Kpatili	
kyn				I	L	Northern Binukidnon	
kyo				I	L	Kelon	
kyp				I	L	Kang	
kyq				I	L	Kenga	
kyr				I	L	Kuruáya	
kys				I	L	Baram Kayan	
kyt				I	L	Kayagar	
kyu				I	L	Western Kayah	
kyv				I	L	Kayort	
kyw				I	L	Kudmali	
kyx				I	L	Rapoisi	
kyy				I	L	Kambaira	
kyz				I	L	Kayabí	
kza				I	L	Western Karaboro	
kzb				I	L	Kaibobo	
kzc				I	L	Bondoukou Kulango	
kzd				I	L	Kadai	
kze				I	L	Kosena	
kzf				I	L	Da'a Kaili	
kzg				I	L	Kikai	
kzi				I	L	Kelabit	
kzk				I	E	Kazukuru	
kzl				I	L	Kayeli	
kzm				I	L	Kais	
kzn				I	L	Kokola	
kzo				I	L	Kaningi	
kzp				I	L	Kaidipang	
kzq				I	L	Kaike	
kzr				I	L	Karang	
kzs				I	L	Sugut Dusun	
kzu				I	L	Kayupulau	
kzv				I	L	Komyandaret	
kzw				I	E	Karirí-Xocó	
kzx				I	E	Kamarian	
kzy				I	L	Kango (Tshopo District)	
kzz				I	L	Kalabra	
laa				I	L	Southern Subanen	
lab				I	A	Linear A	
lac				I	L	Lacandon	
lad	lad	lad		I	L	Ladino	
lae				I	L	Pattani	
laf				I	L	Lafofa	
lag				I	L	Langi	
lah	lah	lah		M	L	Lahnda	
lai				I	L	Lambya	
laj				I	L	Lango (Uganda)	
lak				I	L	Laka (Nigeria)	
lal				I	L	Lalia	
lam	lam	lam		I	L	Lamba	
lan				I	L	Laru	
lao	lao	lao	lo	I	L	Lao	
lap				I	L	Laka (Chad)	
laq				I	L	Qabiao	
lar				I	L	Larteh	
las				I	L	Lama (Togo)	
lat	lat	lat	la	I	A	Latin	
lau				I	L	Laba	
lav	lav	lav	lv	M	L	Latvian	
law				I	L	Lauje	
lax				I	L	Tiwa	
lay				I	L	Lama Bai	
laz				I	E	Aribwatsa	
lbb				I	L	Label	
lbc				I	L	Lakkia	
lbe				I	L	Lak	
lbf				I	L	Tinani	
lbg				I	L	Laopang	
lbi				I	L	La'bi	
lbj				I	L	Ladakhi	
lbk				I	L	Central Bontok	
lbl				I	L	Libon Bikol	
lbm				I	L	Lodhi	
lbn				I	L	Rmeet	
lbo				I	L	Laven	
lbq				I	L	Wampar	
lbr				I	L	Lohorung	
lbs				I	L	Libyan Sign Language	
lbt				I	L	Lachi	
lbu				I	L	Labu	
lbv				I	L	Lavatbura-Lamusong	
lbw				I	L	Tolaki	
lbx				I	L	Lawangan	
lby				I	E	Lamalama	
lbz				I	L	Lardil	
lcc				I	L	Legenyem	
lcd				I	L	Lola	
lce				I	L	Loncong	
lcf				I	L	Lubu	
lch				I	L	Luchazi	
lcl				I	L	Lisela	
lcm				I	L	Tungag	
lcp				I	L	Western Lawa	
lcq				I	L	Luhu	
lcs				I	L	Lisabata-Nuniali	
lda				I	L	Kla-Dan	
ldb				I	L	Dũya	
ldd				I	L	Luri	
ldg				I	L	Lenyima	
ldh				I	L	Lamja-Dengsa-Tola	
ldi				I	L	Laari	
ldj				I	L	Lemoro	
ldk				I	L	Leelau	
ldl				I	L	Kaan	
ldm				I	L	Landoma	
ldn				I	C	Láadan	
ldo				I	L	Loo	
ldp				I	L	Tso	
ldq				I	L	Lufu	
lea				I	L	Lega-Shabunda	
leb				I	L	Lala-Bisa	
lec				I	L	Leco	
led				I	L	Lendu	
lee				I	L	Lyélé	
lef				I	L	Lelemi	
leh				I	L	Lenje	
lei				I	L	Lemio	
lej				I	L	Lengola	
lek				I	L	Leipon	
lel				I	L	Lele (Democratic Republic of Congo)	
lem				I	L	Nomaande	
len				I	E	Lenca	
leo				I	L	Leti (Cameroon)	
lep				I	L	Lepcha	
leq				I	L	Lembena	
ler				I	L	Lenkau	
les				I	L	Lese	
let				I	L	Lesing-Gelimi	
leu				I	L	Kara (Papua New Guinea)	
lev				I	L	Lamma	
lew				I	L	Ledo Kaili	
lex				I	L	Luang	
ley				I	L	Lemolang	
lez	lez	lez		I	L	Lezghian	
lfa				I	L	Lefa	
lfn				I	C	Lingua Franca Nova	
lga				I	L	Lungga	
lgb				I	L	Laghu	
lgg				I	L	Lugbara	
lgh				I	L	Laghuu	
lgi				I	L	Lengilu	
lgk				I	L	Lingarak	
lgl				I	L	Wala	
lgm				I	L	Lega-Mwenga	
lgn				I	L	T'apo	
lgq				I	L	Logba	
lgr				I	L	Lengo	
lgt				I	L	Pahi	
lgu				I	L	Longgu	
lgz				I	L	Ligenza	
lha				I	L	Laha (Viet Nam)	
lhh				I	L	Laha (Indonesia)	
lhi				I	L	Lahu Shi	
lhl				I	L	Lahul Lohar	
lhm				I	L	Lhomi	
lhn				I	L	Lahanan	
lhp				I	L	Lhokpu	
lhs				I	E	Mlahsö	
lht				I	L	Lo-Toga	
lhu				I	L	Lahu	
lia				I	L	West-Central Limba	
lib				I	L	Likum	
lic				I	L	Hlai	
lid				I	L	Nyindrou	
lie				I	L	Likila	
lif				I	L	Limbu	
lig				I	L	Ligbi	
lih				I	L	Lihir	
lij				I	L	Ligurian	
lik				I	L	Lika	
lil				I	L	Lillooet	
lim	lim	lim	li	I	L	Limburgan	
lin	lin	lin	ln	I	L	Lingala	
lio				I	L	Liki	
lip				I	L	Sekpele	
liq				I	L	Libido	
lir				I	L	Liberian English	
lis				I	L	Lisu	
lit	lit	lit	lt	I	L	Lithuanian	
liu				I	L	Logorik	
liv				I	L	Liv	
liw				I	L	Col	
lix				I	L	Liabuku	
liy				I	L	Banda-Bambari	
liz				I	L	Libinza	
lja				I	E	Golpa	
lje				I	L	Rampi	
lji				I	L	Laiyolo	
ljl				I	L	Li'o	
ljp				I	L	Lampung Api	
ljw				I	L	Yirandali	
ljx				I	E	Yuru	
lka				I	L	Lakalei	
lkb				I	L	Kabras	
lkc				I	L	Kucong	
lkd				I	L	Lakondê	
lke				I	L	Kenyi	
lkh				I	L	Lakha	
lki				I	L	Laki	
lkj				I	L	Remun	
lkl				I	L	Laeko-Libuat	
lkm				I	E	Kalaamaya	
lkn				I	L	Lakon	
lko				I	L	Khayo	
lkr				I	L	Päri	
lks				I	L	Kisa	
lkt				I	L	Lakota	
lku				I	E	Kungkari	
lky				I	L	Lokoya	
lla				I	L	Lala-Roba	
llb				I	L	Lolo	
llc				I	L	Lele (Guinea)	
lld				I	L	Ladin	
lle				I	L	Lele (Papua New Guinea)	
llf				I	E	Hermit	
llg				I	L	Lole	
llh				I	L	Lamu	
lli				I	L	Teke-Laali	
llj				I	E	Ladji Ladji	
llk				I	E	Lelak	
lll				I	L	Lilau	
llm				I	L	Lasalimu	
lln				I	L	Lele (Chad)	
llp				I	L	North Efate	
llq				I	L	Lolak	
lls				I	L	Lithuanian Sign Language	
llu				I	L	Lau	
llx				I	L	Lauan	
lma				I	L	East Limba	
lmb				I	L	Merei	
lmc				I	E	Limilngan	
lmd				I	L	Lumun	
lme				I	L	Pévé	
lmf				I	L	South Lembata	
lmg				I	L	Lamogai	
lmh				I	L	Lambichhong	
lmi				I	L	Lombi	
lmj				I	L	West Lembata	
lmk				I	L	Lamkang	
lml				I	L	Hano	
lmn				I	L	Lambadi	
lmo				I	L	Lombard	
lmp				I	L	Limbum	
lmq				I	L	Lamatuka	
lmr				I	L	Lamalera	
lmu				I	L	Lamenu	
lmv				I	L	Lomaiviti	
lmw				I	L	Lake Miwok	
lmx				I	L	Laimbue	
lmy				I	L	Lamboya	
lna				I	L	Langbashe	
lnb				I	L	Mbalanhu	
lnd				I	L	Lundayeh	
lng				I	A	Langobardic	
lnh				I	L	Lanoh	
lni				I	L	Daantanai'	
lnj				I	E	Leningitij	
lnl				I	L	South Central Banda	
lnm				I	L	Langam	
lnn				I	L	Lorediakarkar	
lno				I	L	Lango (South Sudan)	
lns				I	L	Lamnso'	
lnu				I	L	Longuda	
lnw				I	E	Lanima	
lnz				I	L	Lonzo	
loa				I	L	Loloda	
lob				I	L	Lobi	
loc				I	L	Inonhan	
loe				I	L	Saluan	
lof				I	L	Logol	
log				I	L	Logo	
loh				I	L	Narim	
loi				I	L	Loma (Côte d'Ivoire)	
loj				I	L	Lou	
lok				I	L	Loko	
lol	lol	lol		I	L	Mongo	
lom				I	L	Loma (Liberia)	
lon				I	L	Malawi Lomwe	
loo				I	L	Lombo	
lop				I	L	Lopa	
loq				I	L	Lobala	
lor				I	L	Téén	
los				I	L	Loniu	
lot				I	L	Otuho	
lou				I	L	Louisiana Creole	
lov				I	L	Lopi	
low				I	L	Tampias Lobu	
lox				I	L	Loun	
loy				I	L	Loke	
loz	loz	loz		I	L	Lozi	
lpa				I	L	Lelepa	
lpe				I	L	Lepki	
lpn				I	L	Long Phuri Naga	
lpo				I	L	Lipo	
lpx				I	L	Lopit	
lra				I	L	Rara Bakati'	
lrc				I	L	Northern Luri	
lre				I	E	Laurentian	
lrg				I	E	Laragia	
lri				I	L	Marachi	
lrk				I	L	Loarki	
lrl				I	L	Lari	
lrm				I	L	Marama	
lrn				I	L	Lorang	
lro				I	L	Laro	
lrr				I	L	Southern Yamphu	
lrt				I	L	Larantuka Malay	
lrv				I	L	Larevat	
lrz				I	L	Lemerig	
lsa				I	L	Lasgerdi	
lsd				I	L	Lishana Deni	
lse				I	L	Lusengo	
lsh				I	L	Lish	
lsi				I	L	Lashi	
lsl				I	L	Latvian Sign Language	
lsm				I	L	Saamia	
lsn				I	L	Tibetan Sign Language	
lso				I	L	Laos Sign Language	
lsp				I	L	Panamanian Sign Language	
lsr				I	L	Aruop	
lss				I	L	Lasi	
lst				I	L	Trinidad and Tobago Sign Language	
lsv				I	L	Sivia Sign Language	
lsy				I	L	Mauritian Sign Language	
ltc				I	H	Late Middle Chinese	
ltg				I	L	Latgalian	
lth				I	L	Thur	
lti				I	L	Leti (Indonesia)	
ltn				I	L	Latundê	
lto				I	L	Tsotso	
lts				I	L	Tachoni	
ltu				I	L	Latu	
ltz	ltz	ltz	lb	I	L	Luxembourgish	
lua	lua	lua		I	L	Luba-Lulua	
lub	lub	lub	lu	I	L	Luba-Katanga	
luc				I	L	Aringa	
lud				I	L	Ludian	
lue				I	L	Luvale	
luf				I	L	Laua	
lug	lug	lug	lg	I	L	Ganda	
lui	lui	lui		I	E	Luiseno	
luj				I	L	Luna	
luk				I	L	Lunanakha	
lul				I	L	Olu'bo	
lum				I	L	Luimbi	
lun	lun	lun		I	L	Lunda	
luo	luo	luo		I	L	Luo (Kenya and Tanzania)	
lup				I	L	Lumbu	
luq				I	L	Lucumi	
lur				I	L	Laura	
lus	lus	lus		I	L	Lushai	
lut				I	L	Lushootseed	
luu				I	L	Lumba-Yakkha	
luv				I	L	Luwati	
luw				I	L	Luo (Cameroon)	
luy				M	L	Luyia	
luz				I	L	Southern Luri	
lva				I	L	Maku'a	
lvi				I	L	Lavi	
lvk				I	L	Lavukaleve	
lvs				I	L	Standard Latvian	
lvu				I	L	Levuka	
lwa				I	L	Lwalu	
lwe				I	L	Lewo Eleng	
lwg				I	L	Wanga	
lwh				I	L	White Lachi	
lwl				I	L	Eastern Lawa	
lwm				I	L	Laomian	
lwo				I	L	Luwo	
lws				I	L	Malawian Sign Language	
lwt				I	L	Lewotobi	
lwu				I	L	Lawu	
lww				I	L	Lewo	
lya				I	L	Layakha	
lyg				I	L	Lyngngam	
lyn				I	L	Luyana	
lzh				I	H	Literary Chinese	
lzl				I	L	Litzlitz	
lzn				I	L	Leinong Naga	
lzz				I	L	Laz	
maa				I	L	San Jerónimo Tecóatl Mazatec	
mab				I	L	Yutanduchi Mixtec	
mad	mad	mad		I	L	Madurese	
mae				I	L	Bo-Rukul	
maf				I	L	Mafa	
mag	mag	mag		I	L	Magahi	
mah	mah	mah	mh	I	L	Marshallese	
mai	mai	mai		I	L	Maithili	
maj				I	L	Jalapa De Díaz Mazatec	
mak	mak	mak		I	L	Makasar	
mal	mal	mal	ml	I	L	Malayalam	
mam				I	L	Mam	
man	man	man		M	L	Mandingo	
maq				I	L	Chiquihuitlán Mazatec	
mar	mar	mar	mr	I	L	Marathi	
mas	mas	mas		I	L	Masai	
mat				I	L	San Francisco Matlatzinca	
mau				I	L	Huautla Mazatec	
mav				I	L	Sateré-Mawé	
maw				I	L	Mampruli	
max				I	L	North Moluccan Malay	
maz				I	L	Central Mazahua	
mba				I	L	Higaonon	
mbb				I	L	Western Bukidnon Manobo	
mbc				I	L	Macushi	
mbd				I	L	Dibabawon Manobo	
mbe				I	E	Molale	
mbf				I	L	Baba Malay	
mbh				I	L	Mangseng	
mbi				I	L	Ilianen Manobo	
mbj				I	L	Nadëb	
mbk				I	L	Malol	
mbl				I	L	Maxakalí	
mbm				I	L	Ombamba	
mbn				I	L	Macaguán	
mbo				I	L	Mbo (Cameroon)	
mbp				I	L	Malayo	
mbq				I	L	Maisin	
mbr				I	L	Nukak Makú	
mbs				I	L	Sarangani Manobo	
mbt				I	L	Matigsalug Manobo	
mbu				I	L	Mbula-Bwazza	
mbv				I	L	Mbulungish	
mbw				I	L	Maring	
mbx				I	L	Mari (East Sepik Province)	
mby				I	L	Memoni	
mbz				I	L	Amoltepec Mixtec	
mca				I	L	Maca	
mcb				I	L	Machiguenga	
mcc				I	L	Bitur	
mcd				I	L	Sharanahua	
mce				I	L	Itundujia Mixtec	
mcf				I	L	Matsés	
mcg				I	L	Mapoyo	
mch				I	L	Maquiritari	
mci				I	L	Mese	
mcj				I	L	Mvanip	
mck				I	L	Mbunda	
mcl				I	E	Macaguaje	
mcm				I	L	Malaccan Creole Portuguese	
mcn				I	L	Masana	
mco				I	L	Coatlán Mixe	
mcp				I	L	Makaa	
mcq				I	L	Ese	
mcr				I	L	Menya	
mcs				I	L	Mambai	
mct				I	L	Mengisa	
mcu				I	L	Cameroon Mambila	
mcv				I	L	Minanibai	
mcw				I	L	Mawa (Chad)	
mcx				I	L	Mpiemo	
mcy				I	L	South Watut	
mcz				I	L	Mawan	
mda				I	L	Mada (Nigeria)	
mdb				I	L	Morigi	
mdc				I	L	Male (Papua New Guinea)	
mdd				I	L	Mbum	
mde				I	L	Maba (Chad)	
mdf	mdf	mdf		I	L	Moksha	
mdg				I	L	Massalat	
mdh				I	L	Maguindanaon	
mdi				I	L	Mamvu	
mdj				I	L	Mangbetu	
mdk				I	L	Mangbutu	
mdl				I	L	Maltese Sign Language	
mdm				I	L	Mayogo	
mdn				I	L	Mbati	
mdp				I	L	Mbala	
mdq				I	L	Mbole	
mdr	mdr	mdr		I	L	Mandar	
mds				I	L	Maria (Papua New Guinea)	
mdt				I	L	Mbere	
mdu				I	L	Mboko	
mdv				I	L	Santa Lucía Monteverde Mixtec	
mdw				I	L	Mbosi	
mdx				I	L	Dizin	
mdy				I	L	Male (Ethiopia)	
mdz				I	L	Suruí Do Pará	
mea				I	L	Menka	
meb				I	L	Ikobi	
mec				I	L	Marra	
med				I	L	Melpa	
mee				I	L	Mengen	
mef				I	L	Megam	
meh				I	L	Southwestern Tlaxiaco Mixtec	
mei				I	L	Midob	
mej				I	L	Meyah	
mek				I	L	Mekeo	
mel				I	L	Central Melanau	
mem				I	E	Mangala	
men	men	men		I	L	Mende (Sierra Leone)	
meo				I	L	Kedah Malay	
mep				I	L	Miriwoong	
meq				I	L	Merey	
mer				I	L	Meru	
mes				I	L	Masmaje	
met				I	L	Mato	
meu				I	L	Motu	
mev				I	L	Mano	
mew				I	L	Maaka	
mey				I	L	Hassaniyya	
mez				I	L	Menominee	
mfa				I	L	Pattani Malay	
mfb				I	L	Bangka	
mfc				I	L	Mba	
mfd				I	L	Mendankwe-Nkwen	
mfe				I	L	Morisyen	
mff				I	L	Naki	
mfg				I	L	Mogofin	
mfh				I	L	Matal	
mfi				I	L	Wandala	
mfj				I	L	Mefele	
mfk				I	L	North Mofu	
mfl				I	L	Putai	
mfm				I	L	Marghi South	
mfn				I	L	Cross River Mbembe	
mfo				I	L	Mbe	
mfp				I	L	Makassar Malay	
mfq				I	L	Moba	
mfr				I	L	Marrithiyel	
mfs				I	L	Mexican Sign Language	
mft				I	L	Mokerang	
mfu				I	L	Mbwela	
mfv				I	L	Mandjak	
mfw				I	E	Mulaha	
mfx				I	L	Melo	
mfy				I	L	Mayo	
mfz				I	L	Mabaan	
mga	mga	mga		I	H	Middle Irish (900-1200)	
mgb				I	L	Mararit	
mgc				I	L	Morokodo	
mgd				I	L	Moru	
mge				I	L	Mango	
mgf				I	L	Maklew	
mgg				I	L	Mpumpong	
mgh				I	L	Makhuwa-Meetto	
mgi				I	L	Lijili	
mgj				I	L	Abureni	
mgk				I	L	Mawes	
mgl				I	L	Maleu-Kilenge	
mgm				I	L	Mambae	
mgn				I	L	Mbangi	
mgo				I	L	Meta'	
mgp				I	L	Eastern Magar	
mgq				I	L	Malila	
mgr				I	L	Mambwe-Lungu	
mgs				I	L	Manda (Tanzania)	
mgt				I	L	Mongol	
mgu				I	L	Mailu	
mgv				I	L	Matengo	
mgw				I	L	Matumbi	
mgy				I	L	Mbunga	
mgz				I	L	Mbugwe	
mha				I	L	Manda (India)	
mhb				I	L	Mahongwe	
mhc				I	L	Mocho	
mhd				I	L	Mbugu	
mhe				I	L	Besisi	
mhf				I	L	Mamaa	
mhg				I	L	Margu	
mhi				I	L	Ma'di	
mhj				I	L	Mogholi	
mhk				I	L	Mungaka	
mhl				I	L	Mauwake	
mhm				I	L	Makhuwa-Moniga	
mhn				I	L	Mócheno	
mho				I	L	Mashi (Zambia)	
mhp				I	L	Balinese Malay	
mhq				I	L	Mandan	
mhr				I	L	Eastern Mari	
mhs				I	L	Buru (Indonesia)	
mht				I	L	Mandahuaca	
mhu				I	L	Digaro-Mishmi	
mhw				I	L	Mbukushu	
mhx				I	L	Maru	
mhy				I	L	Ma'anyan	
mhz				I	L	Mor (Mor Islands)	
mia				I	L	Miami	
mib				I	L	Atatláhuca Mixtec	
mic	mic	mic		I	L	Mi'kmaq	
mid				I	L	Mandaic	
mie				I	L	Ocotepec Mixtec	
mif				I	L	Mofu-Gudur	
mig				I	L	San Miguel El Grande Mixtec	
mih				I	L	Chayuco Mixtec	
mii				I	L	Chigmecatitlán Mixtec	
mij				I	L	Abar	
mik				I	L	Mikasuki	
mil				I	L	Peñoles Mixtec	
mim				I	L	Alacatlatzala Mixtec	
min	min	min		I	L	Minangkabau	
mio				I	L	Pinotepa Nacional Mixtec	
mip				I	L	Apasco-Apoala Mixtec	
miq				I	L	Mískito	
mir				I	L	Isthmus Mixe	
mis	mis	mis		S	S	Uncoded languages	
mit				I	L	Southern Puebla Mixtec	
miu				I	L	Cacaloxtepec Mixtec	
miw				I	L	Akoye	
mix				I	L	Mixtepec Mixtec	
miy				I	L	Ayutla Mixtec	
miz				I	L	Coatzospan Mixtec	
mjb				I	L	Makalero	
mjc				I	L	San Juan Colorado Mixtec	
mjd				I	L	Northwest Maidu	
mje				I	E	Muskum	
mjg				I	L	Tu	
mjh				I	L	Mwera (Nyasa)	
mji				I	L	Kim Mun	
mjj				I	L	Mawak	
mjk				I	L	Matukar	
mjl				I	L	Mandeali	
mjm				I	L	Medebur	
mjn				I	L	Ma (Papua New Guinea)	
mjo				I	L	Malankuravan	
mjp				I	L	Malapandaram	
mjq				I	E	Malaryan	
mjr				I	L	Malavedan	
mjs				I	L	Miship	
mjt				I	L	Sauria Paharia	
mju				I	L	Manna-Dora	
mjv				I	L	Mannan	
mjw				I	L	Karbi	
mjx				I	L	Mahali	
mjy				I	E	Mahican	
mjz				I	L	Majhi	
mka				I	L	Mbre	
mkb				I	L	Mal Paharia	
mkc				I	L	Siliput	
mkd	mac	mkd	mk	I	L	Macedonian	
mke				I	L	Mawchi	
mkf				I	L	Miya	
mkg				I	L	Mak (China)	
mki				I	L	Dhatki	
mkj				I	L	Mokilese	
mkk				I	L	Byep	
mkl				I	L	Mokole	
mkm				I	L	Moklen	
mkn				I	L	Kupang Malay	
mko				I	L	Mingang Doso	
mkp				I	L	Moikodi	
mkq				I	E	Bay Miwok	
mkr				I	L	Malas	
mks				I	L	Silacayoapan Mixtec	
mkt				I	L	Vamale	
mku				I	L	Konyanka Maninka	
mkv				I	L	Mafea	
mkw				I	L	Kituba (Congo)	
mkx				I	L	Kinamiging Manobo	
mky				I	L	East Makian	
mkz				I	L	Makasae	
mla				I	L	Malo	
mlb				I	L	Mbule	
mlc				I	L	Cao Lan	
mle				I	L	Manambu	
mlf				I	L	Mal	
mlg	mlg	mlg	mg	M	L	Malagasy	
mlh				I	L	Mape	
mli				I	L	Malimpung	
mlj				I	L	Miltu	
mlk				I	L	Ilwana	
mll				I	L	Malua Bay	
mlm				I	L	Mulam	
mln				I	L	Malango	
mlo				I	L	Mlomp	
mlp				I	L	Bargam	
mlq				I	L	Western Maninkakan	
mlr				I	L	Vame	
mls				I	L	Masalit	
mlt	mlt	mlt	mt	I	L	Maltese	
mlu				I	L	To'abaita	
mlv				I	L	Motlav	
mlw				I	L	Moloko	
mlx				I	L	Malfaxal	
mlz				I	L	Malaynon	
mma				I	L	Mama	
mmb				I	L	Momina	
mmc				I	L	Michoacán Mazahua	
mmd				I	L	Maonan	
mme				I	L	Mae	
mmf				I	L	Mundat	
mmg				I	L	North Ambrym	
mmh				I	L	Mehináku	
mmi				I	L	Musar	
mmj				I	L	Majhwar	
mmk				I	L	Mukha-Dora	
mml				I	L	Man Met	
mmm				I	L	Maii	
mmn				I	L	Mamanwa	
mmo				I	L	Mangga Buang	
mmp				I	L	Siawi	
mmq				I	L	Musak	
mmr				I	L	Western Xiangxi Miao	
mmt				I	L	Malalamai	
mmu				I	L	Mmaala	
mmv				I	E	Miriti	
mmw				I	L	Emae	
mmx				I	L	Madak	
mmy				I	L	Migaama	
mmz				I	L	Mabaale	
mna				I	L	Mbula	
mnb				I	L	Muna	
mnc	mnc	mnc		I	L	Manchu	
mnd				I	L	Mondé	
mne				I	L	Naba	
mnf				I	L	Mundani	
mng				I	L	Eastern Mnong	
mnh				I	L	Mono (Democratic Republic of Congo)	
mni	mni	mni		I	L	Manipuri	
mnj				I	L	Munji	
mnk				I	L	Mandinka	
mnl				I	L	Tiale	
mnm				I	L	Mapena	
mnn				I	L	Southern Mnong	
mnp				I	L	Min Bei Chinese	
mnq				I	L	Minriq	
mnr				I	L	Mono (USA)	
mns				I	L	Mansi	
mnu				I	L	Mer	
mnv				I	L	Rennell-Bellona	
mnw				I	L	Mon	
mnx				I	L	Manikion	
mny				I	L	Manyawa	
mnz				I	L	Moni	
moa				I	L	Mwan	
moc				I	L	Mocoví	
mod				I	E	Mobilian	
moe				I	L	Innu	
mog				I	L	Mongondow	
moh	moh	moh		I	L	Mohawk	
moi				I	L	Mboi	
moj				I	L	Monzombo	
mok				I	L	Morori	
mom				I	E	Mangue	
mon	mon	mon	mn	M	L	Mongolian	
moo				I	L	Monom	
mop				I	L	Mopán Maya	
moq				I	L	Mor (Bomberai Peninsula)	
mor				I	L	Moro	
mos	mos	mos		I	L	Mossi	
mot				I	L	Barí	
mou				I	L	Mogum	
mov				I	L	Mohave	
mow				I	L	Moi (Congo)	
mox				I	L	Molima	
moy				I	L	Shekkacho	
moz				I	L	Mukulu	
mpa				I	L	Mpoto	
mpb				I	L	Malak Malak	
mpc				I	L	Mangarrayi	
mpd				I	L	Machinere	
mpe				I	L	Majang	
mpg				I	L	Marba	
mph				I	L	Maung	
mpi				I	L	Mpade	
mpj				I	L	Martu Wangka	
mpk				I	L	Mbara (Chad)	
mpl				I	L	Middle Watut	
mpm				I	L	Yosondúa Mixtec	
mpn				I	L	Mindiri	
mpo				I	L	Miu	
mpp				I	L	Migabac	
mpq				I	L	Matís	
mpr				I	L	Vangunu	
mps				I	L	Dadibi	
mpt				I	L	Mian	
mpu				I	L	Makuráp	
mpv				I	L	Mungkip	
mpw				I	L	Mapidian	
mpx				I	L	Misima-Panaeati	
mpy				I	L	Mapia	
mpz				I	L	Mpi	
mqa				I	L	Maba (Indonesia)	
mqb				I	L	Mbuko	
mqc				I	L	Mangole	
mqe				I	L	Matepi	
mqf				I	L	Momuna	
mqg				I	L	Kota Bangun Kutai Malay	
mqh				I	L	Tlazoyaltepec Mixtec	
mqi				I	L	Mariri	
mqj				I	L	Mamasa	
mqk				I	L	Rajah Kabunsuwan Manobo	
mql				I	L	Mbelime	
mqm				I	L	South Marquesan	
mqn				I	L	Moronene	
mqo				I	L	Modole	
mqp				I	L	Manipa	
mqq				I	L	Minokok	
mqr				I	L	Mander	
mqs				I	L	West Makian	
mqt				I	L	Mok	
mqu				I	L	Mandari	
mqv				I	L	Mosimo	
mqw				I	L	Murupi	
mqx				I	L	Mamuju	
mqy				I	L	Manggarai	
mqz				I	L	Pano	
mra				I	L	Mlabri	
mrb				I	L	Marino	
mrc				I	L	Maricopa	
mrd				I	L	Western Magar	
mre				I	E	Martha's Vineyard Sign Language	
mrf				I	L	Elseng	
mrg				I	L	Mising	
mrh				I	L	Mara Chin	
mri	mao	mri	mi	I	L	Maori	
mrj				I	L	Western Mari	
mrk				I	L	Hmwaveke	
mrl				I	L	Mortlockese	
mrm				I	L	Merlav	
mrn				I	L	Cheke Holo	
mro				I	L	Mru	
mrp				I	L	Morouas	
mrq				I	L	North Marquesan	
mrr				I	L	Maria (India)	
mrs				I	L	Maragus	
mrt				I	L	Marghi Central	
mru				I	L	Mono (Cameroon)	
mrv				I	L	Mangareva	
mrw				I	L	Maranao	
mrx				I	L	Maremgi	
mry				I	L	Mandaya	
mrz				I	L	Marind	
msa	may	msa	ms	M	L	Malay (macrolanguage)	
msb				I	L	Masbatenyo	
msc				I	L	Sankaran Maninka	
msd				I	L	Yucatec Maya Sign Language	
mse				I	L	Musey	
msf				I	L	Mekwei	
msg				I	L	Moraid	
msh				I	L	Masikoro Malagasy	
msi				I	L	Sabah Malay	
msj				I	L	Ma (Democratic Republic of Congo)	
msk				I	L	Mansaka	
msl				I	L	Molof	
msm				I	L	Agusan Manobo	
msn				I	L	Vurës	
mso				I	L	Mombum	
msp				I	E	Maritsauá	
msq				I	L	Caac	
msr				I	L	Mongolian Sign Language	
mss				I	L	West Masela	
msu				I	L	Musom	
msv				I	L	Maslam	
msw				I	L	Mansoanka	
msx				I	L	Moresada	
msy				I	L	Aruamu	
msz				I	L	Momare	
mta				I	L	Cotabato Manobo	
mtb				I	L	Anyin Morofo	
mtc				I	L	Munit	
mtd				I	L	Mualang	
mte				I	L	Mono (Solomon Islands)	
mtf				I	L	Murik (Papua New Guinea)	
mtg				I	L	Una	
mth				I	L	Munggui	
mti				I	L	Maiwa (Papua New Guinea)	
mtj				I	L	Moskona	
mtk				I	L	Mbe'	
mtl				I	L	Montol	
mtm				I	E	Mator	
mtn				I	E	Matagalpa	
mto				I	L	Totontepec Mixe	
mtp				I	L	Wichí Lhamtés Nocten	
mtq				I	L	Muong	
mtr				I	L	Mewari	
mts				I	L	Yora	
mtt				I	L	Mota	
mtu				I	L	Tututepec Mixtec	
mtv				I	L	Asaro'o	
mtw				I	L	Southern Binukidnon	
mtx				I	L	Tidaá Mixtec	
mty				I	L	Nabi	
mua				I	L	Mundang	
mub				I	L	Mubi	
muc				I	L	Ajumbu	
mud				I	L	Mednyj Aleut	
mue				I	L	Media Lengua	
mug				I	L	Musgu	
muh				I	L	Mündü	
mui				I	L	Musi	
muj				I	L	Mabire	
muk				I	L	Mugom	
mul	mul	mul		S	S	Multiple languages	
mum				I	L	Maiwala	
muo				I	L	Nyong	
mup				I	L	Malvi	
muq				I	L	Eastern Xiangxi Miao	
mur				I	L	Murle	
mus	mus	mus		I	L	Creek	
mut				I	L	Western Muria	
muu				I	L	Yaaku	
muv				I	L	Muthuvan	
mux				I	L	Bo-Ung	
muy				I	L	Muyang	
muz				I	L	Mursi	
mva				I	L	Manam	
mvb				I	E	Mattole	
mvd				I	L	Mamboru	
mve				I	L	Marwari (Pakistan)	
mvf				I	L	Peripheral Mongolian	
mvg				I	L	Yucuañe Mixtec	
mvh				I	L	Mulgi	
mvi				I	L	Miyako	
mvk				I	L	Mekmek	
mvl				I	E	Mbara (Australia)	
mvm				I	L	Muya	
mvn				I	L	Minaveha	
mvo				I	L	Marovo	
mvp				I	L	Duri	
mvq				I	L	Moere	
mvr				I	L	Marau	
mvs				I	L	Massep	
mvt				I	L	Mpotovoro	
mvu				I	L	Marfa	
mvv				I	L	Tagal Murut	
mvw				I	L	Machinga	
mvx				I	L	Meoswar	
mvy				I	L	Indus Kohistani	
mvz				I	L	Mesqan	
mwa				I	L	Mwatebu	
mwb				I	L	Juwal	
mwc				I	L	Are	
mwe				I	L	Mwera (Chimwera)	
mwf				I	L	Murrinh-Patha	
mwg				I	L	Aiklep	
mwh				I	L	Mouk-Aria	
mwi				I	L	Labo	
mwk				I	L	Kita Maninkakan	
mwl	mwl	mwl		I	L	Mirandese	
mwm				I	L	Sar	
mwn				I	L	Nyamwanga	
mwo				I	L	Central Maewo	
mwp				I	L	Kala Lagaw Ya	
mwq				I	L	Mün Chin	
mwr	mwr	mwr		M	L	Marwari	
mws				I	L	Mwimbi-Muthambi	
mwt				I	L	Moken	
mwu				I	E	Mittu	
mwv				I	L	Mentawai	
mww				I	L	Hmong Daw	
mwz				I	L	Moingi	
mxa				I	L	Northwest Oaxaca Mixtec	
mxb				I	L	Tezoatlán Mixtec	
mxc				I	L	Manyika	
mxd				I	L	Modang	
mxe				I	L	Mele-Fila	
mxf				I	L	Malgbe	
mxg				I	L	Mbangala	
mxh				I	L	Mvuba	
mxi				I	H	Mozarabic	
mxj				I	L	Miju-Mishmi	
mxk				I	L	Monumbo	
mxl				I	L	Maxi Gbe	
mxm				I	L	Meramera	
mxn				I	L	Moi (Indonesia)	
mxo				I	L	Mbowe	
mxp				I	L	Tlahuitoltepec Mixe	
mxq				I	L	Juquila Mixe	
mxr				I	L	Murik (Malaysia)	
mxs				I	L	Huitepec Mixtec	
mxt				I	L	Jamiltepec Mixtec	
mxu				I	L	Mada (Cameroon)	
mxv				I	L	Metlatónoc Mixtec	
mxw				I	L	Namo	
mxx				I	L	Mahou	
mxy				I	L	Southeastern Nochixtlán Mixtec	
mxz				I	L	Central Masela	
mya	bur	mya	my	I	L	Burmese	
myb				I	L	Mbay	
myc				I	L	Mayeka	
mye				I	L	Myene	
myf				I	L	Bambassi	
myg				I	L	Manta	
myh				I	L	Makah	
myj				I	L	Mangayat	
myk				I	L	Mamara Senoufo	
myl				I	L	Moma	
mym				I	L	Me'en	
myo				I	L	Anfillo	
myp				I	L	Pirahã	
myr				I	L	Muniche	
mys				I	E	Mesmes	
myu				I	L	Mundurukú	
myv	myv	myv		I	L	Erzya	
myw				I	L	Muyuw	
myx				I	L	Masaaba	
myy				I	L	Macuna	
myz				I	H	Classical Mandaic	
mza				I	L	Santa María Zacatepec Mixtec	
mzb				I	L	Tumzabt	
mzc				I	L	Madagascar Sign Language	
mzd				I	L	Malimba	
mze				I	L	Morawa	
mzg				I	L	Monastic Sign Language	
mzh				I	L	Wichí Lhamtés Güisnay	
mzi				I	L	Ixcatlán Mazatec	
mzj				I	L	Manya	
mzk				I	L	Nigeria Mambila	
mzl				I	L	Mazatlán Mixe	
mzm				I	L	Mumuye	
mzn				I	L	Mazanderani	
mzo				I	E	Matipuhy	
mzp				I	L	Movima	
mzq				I	L	Mori Atas	
mzr				I	L	Marúbo	
mzs				I	L	Macanese	
mzt				I	L	Mintil	
mzu				I	L	Inapang	
mzv				I	L	Manza	
mzw				I	L	Deg	
mzx				I	L	Mawayana	
mzy				I	L	Mozambican Sign Language	
mzz				I	L	Maiadomu	
naa				I	L	Namla	
nab				I	L	Southern Nambikuára	
nac				I	L	Narak	
nae				I	E	Naka'ela	
naf				I	L	Nabak	
nag				I	L	Naga Pidgin	
naj				I	L	Nalu	
nak				I	L	Nakanai	
nal				I	L	Nalik	
nam				I	L	Ngan'gityemerri	
nan				I	L	Min Nan Chinese	
nao				I	L	Naaba	
nap	nap	nap		I	L	Neapolitan	
naq				I	L	Khoekhoe	
nar				I	L	Iguta	
nas				I	L	Naasioi	
nat				I	L	Ca̱hungwa̱rya̱	
nau	nau	nau	na	I	L	Nauru	
nav	nav	nav	nv	I	L	Navajo	
naw				I	L	Nawuri	
nax				I	L	Nakwi	
nay				I	E	Ngarrindjeri	
naz				I	L	Coatepec Nahuatl	
nba				I	L	Nyemba	
nbb				I	L	Ndoe	
nbc				I	L	Chang Naga	
nbd				I	L	Ngbinda	
nbe				I	L	Konyak Naga	
nbg				I	L	Nagarchal	
nbh				I	L	Ngamo	
nbi				I	L	Mao Naga	
nbj				I	L	Ngarinyman	
nbk				I	L	Nake	
nbl	nbl	nbl	nr	I	L	South Ndebele	
nbm				I	L	Ngbaka Ma'bo	
nbn				I	L	Kuri	
nbo				I	L	Nkukoli	
nbp				I	L	Nnam	
nbq				I	L	Nggem	
nbr				I	L	Numana	
nbs				I	L	Namibian Sign Language	
nbt				I	L	Na	
nbu				I	L	Rongmei Naga	
nbv				I	L	Ngamambo	
nbw				I	L	Southern Ngbandi	
nby				I	L	Ningera	
nca				I	L	Iyo	
ncb				I	L	Central Nicobarese	
ncc				I	L	Ponam	
ncd				I	L	Nachering	
nce				I	L	Yale	
ncf				I	L	Notsi	
ncg				I	L	Nisga'a	
nch				I	L	Central Huasteca Nahuatl	
nci				I	H	Classical Nahuatl	
ncj				I	L	Northern Puebla Nahuatl	
nck				I	L	Na-kara	
ncl				I	L	Michoacán Nahuatl	
ncm				I	L	Nambo	
ncn				I	L	Nauna	
nco				I	L	Sibe	
ncq				I	L	Northern Katang	
ncr				I	L	Ncane	
ncs				I	L	Nicaraguan Sign Language	
nct				I	L	Chothe Naga	
ncu				I	L	Chumburung	
ncx				I	L	Central Puebla Nahuatl	
ncz				I	E	Natchez	
nda				I	L	Ndasa	
ndb				I	L	Kenswei Nsei	
ndc				I	L	Ndau	
ndd				I	L	Nde-Nsele-Nta	
nde	nde	nde	nd	I	L	North Ndebele	
ndf				I	H	Nadruvian	
ndg				I	L	Ndengereko	
ndh				I	L	Ndali	
ndi				I	L	Samba Leko	
ndj				I	L	Ndamba	
ndk				I	L	Ndaka	
ndl				I	L	Ndolo	
ndm				I	L	Ndam	
ndn				I	L	Ngundi	
ndo	ndo	ndo	ng	I	L	Ndonga	
ndp				I	L	Ndo	
ndq				I	L	Ndombe	
ndr				I	L	Ndoola	
nds	nds	nds		I	L	Low German	
ndt				I	L	Ndunga	
ndu				I	L	Dugun	
ndv				I	L	Ndut	
ndw				I	L	Ndobo	
ndx				I	L	Nduga	
ndy				I	L	Lutos	
ndz				I	L	Ndogo	
nea				I	L	Eastern Ngad'a	
neb				I	L	Toura (Côte d'Ivoire)	
nec				I	L	Nedebang	
ned				I	L	Nde-Gbite	
nee				I	L	Nêlêmwa-Nixumwak	
nef				I	L	Nefamese	
neg				I	L	Negidal	
neh				I	L	Nyenkha	
nei				I	A	Neo-Hittite	
nej				I	L	Neko	
nek				I	L	Neku	
nem				I	L	Nemi	
nen				I	L	Nengone	
neo				I	L	Ná-Meo	
nep	nep	nep	ne	M	L	Nepali (macrolanguage)	
neq				I	L	North Central Mixe	
ner				I	L	Yahadian	
nes				I	L	Bhoti Kinnauri	
net				I	L	Nete	
neu				I	C	Neo	
nev				I	L	Nyaheun	
new	new	new		I	L	Newari	
nex				I	L	Neme	
ney				I	L	Neyo	
nez				I	L	Nez Perce	
nfa				I	L	Dhao	
nfd				I	L	Ahwai	
nfl				I	L	Ayiwo	
nfr				I	L	Nafaanra	
nfu				I	L	Mfumte	
nga				I	L	Ngbaka	
ngb				I	L	Northern Ngbandi	
ngc				I	L	Ngombe (Democratic Republic of Congo)	
ngd				I	L	Ngando (Central African Republic)	
nge				I	L	Ngemba	
ngg				I	L	Ngbaka Manza	
ngh				I	L	Nǁng	
ngi				I	L	Ngizim	
ngj				I	L	Ngie	
ngk				I	L	Dalabon	
ngl				I	L	Lomwe	
ngm				I	L	Ngatik Men's Creole	
ngn				I	L	Ngwo	
ngo				I	L	Ngoni	
ngp				I	L	Ngulu	
ngq				I	L	Ngurimi	
ngr				I	L	Engdewu	
ngs				I	L	Gvoko	
ngt				I	L	Kriang	
ngu				I	L	Guerrero Nahuatl	
ngv				I	E	Nagumi	
ngw				I	L	Ngwaba	
ngx				I	L	Nggwahyi	
ngy				I	L	Tibea	
ngz				I	L	Ngungwel	
nha				I	L	Nhanda	
nhb				I	L	Beng	
nhc				I	E	Tabasco Nahuatl	
nhd				I	L	Chiripá	
nhe				I	L	Eastern Huasteca Nahuatl	
nhf				I	L	Nhuwala	
nhg				I	L	Tetelcingo Nahuatl	
nhh				I	L	Nahari	
nhi				I	L	Zacatlán-Ahuacatlán-Tepetzintla Nahuatl	
nhk				I	L	Isthmus-Cosoleacaque Nahuatl	
nhm				I	L	Morelos Nahuatl	
nhn				I	L	Central Nahuatl	
nho				I	L	Takuu	
nhp				I	L	Isthmus-Pajapan Nahuatl	
nhq				I	L	Huaxcaleca Nahuatl	
nhr				I	L	Naro	
nht				I	L	Ometepec Nahuatl	
nhu				I	L	Noone	
nhv				I	L	Temascaltepec Nahuatl	
nhw				I	L	Western Huasteca Nahuatl	
nhx				I	L	Isthmus-Mecayapan Nahuatl	
nhy				I	L	Northern Oaxaca Nahuatl	
nhz				I	L	Santa María La Alta Nahuatl	
nia	nia	nia		I	L	Nias	
nib				I	L	Nakame	
nid				I	E	Ngandi	
nie				I	L	Niellim	
nif				I	L	Nek	
nig				I	E	Ngalakgan	
nih				I	L	Nyiha (Tanzania)	
nii				I	L	Nii	
nij				I	L	Ngaju	
nik				I	L	Southern Nicobarese	
nil				I	L	Nila	
nim				I	L	Nilamba	
nin				I	L	Ninzo	
nio				I	L	Nganasan	
niq				I	L	Nandi	
nir				I	L	Nimboran	
nis				I	L	Nimi	
nit				I	L	Southeastern Kolami	
niu	niu	niu		I	L	Niuean	
niv				I	L	Gilyak	
niw				I	L	Nimo	
nix				I	L	Hema	
niy				I	L	Ngiti	
niz				I	L	Ningil	
nja				I	L	Nzanyi	
njb				I	L	Nocte Naga	
njd				I	L	Ndonde Hamba	
njh				I	L	Lotha Naga	
nji				I	L	Gudanji	
njj				I	L	Njen	
njl				I	L	Njalgulgule	
njm				I	L	Angami Naga	
njn				I	L	Liangmai Naga	
njo				I	L	Ao Naga	
njr				I	L	Njerep	
njs				I	L	Nisa	
njt				I	L	Ndyuka-Trio Pidgin	
nju				I	L	Ngadjunmaya	
njx				I	L	Kunyi	
njy				I	L	Njyem	
njz				I	L	Nyishi	
nka				I	L	Nkoya	
nkb				I	L	Khoibu Naga	
nkc				I	L	Nkongho	
nkd				I	L	Koireng	
nke				I	L	Duke	
nkf				I	L	Inpui Naga	
nkg				I	L	Nekgini	
nkh				I	L	Khezha Naga	
nki				I	L	Thangal Naga	
nkj				I	L	Nakai	
nkk				I	L	Nokuku	
nkm				I	L	Namat	
nkn				I	L	Nkangala	
nko				I	L	Nkonya	
nkp				I	E	Niuatoputapu	
nkq				I	L	Nkami	
nkr				I	L	Nukuoro	
nks				I	L	North Asmat	
nkt				I	L	Nyika (Tanzania)	
nku				I	L	Bouna Kulango	
nkv				I	L	Nyika (Malawi and Zambia)	
nkw				I	L	Nkutu	
nkx				I	L	Nkoroo	
nkz				I	L	Nkari	
nla				I	L	Ngombale	
nlc				I	L	Nalca	
nld	dut	nld	nl	I	L	Dutch	
nle				I	L	East Nyala	
nlg				I	L	Gela	
nli				I	L	Grangali	
nlj				I	L	Nyali	
nlk				I	L	Ninia Yali	
nll				I	L	Nihali	
nlm				I	L	Mankiyali	
nlo				I	L	Ngul	
nlq				I	L	Lao Naga	
nlu				I	L	Nchumbulu	
nlv				I	L	Orizaba Nahuatl	
nlw				I	E	Walangama	
nlx				I	L	Nahali	
nly				I	L	Nyamal	
nlz				I	L	Nalögo	
nma				I	L	Maram Naga	
nmb				I	L	Big Nambas	
nmc				I	L	Ngam	
nmd				I	L	Ndumu	
nme				I	L	Mzieme Naga	
nmf				I	L	Tangkhul Naga (India)	
nmg				I	L	Kwasio	
nmh				I	L	Monsang Naga	
nmi				I	L	Nyam	
nmj				I	L	Ngombe (Central African Republic)	
nmk				I	L	Namakura	
nml				I	L	Ndemli	
nmm				I	L	Manangba	
nmn				I	L	ǃXóõ	
nmo				I	L	Moyon Naga	
nmp				I	E	Nimanbur	
nmq				I	L	Nambya	
nmr				I	E	Nimbari	
nms				I	L	Letemboi	
nmt				I	L	Namonuito	
nmu				I	L	Northeast Maidu	
nmv				I	E	Ngamini	
nmw				I	L	Nimoa	
nmx				I	L	Nama (Papua New Guinea)	
nmy				I	L	Namuyi	
nmz				I	L	Nawdm	
nna				I	L	Nyangumarta	
nnb				I	L	Nande	
nnc				I	L	Nancere	
nnd				I	L	West Ambae	
nne				I	L	Ngandyera	
nnf				I	L	Ngaing	
nng				I	L	Maring Naga	
nnh				I	L	Ngiemboon	
nni				I	L	North Nuaulu	
nnj				I	L	Nyangatom	
nnk				I	L	Nankina	
nnl				I	L	Northern Rengma Naga	
nnm				I	L	Namia	
nnn				I	L	Ngete	
nno	nno	nno	nn	I	L	Norwegian Nynorsk	
nnp				I	L	Wancho Naga	
nnq				I	L	Ngindo	
nnr				I	E	Narungga	
nnt				I	E	Nanticoke	
nnu				I	L	Dwang	
nnv				I	E	Nugunu (Australia)	
nnw				I	L	Southern Nuni	
nny				I	E	Nyangga	
nnz				I	L	Nda'nda'	
noa				I	L	Woun Meu	
nob	nob	nob	nb	I	L	Norwegian Bokmål	
noc				I	L	Nuk	
nod				I	L	Northern Thai	
noe				I	L	Nimadi	
nof				I	L	Nomane	
nog	nog	nog		I	L	Nogai	
noh				I	L	Nomu	
noi				I	L	Noiri	
noj				I	L	Nonuya	
nok				I	E	Nooksack	
nol				I	E	Nomlaki	
nom				I	E	Nocamán	
non	non	non		I	H	Old Norse	
nop				I	L	Numanggang	
noq				I	L	Ngongo	
nor	nor	nor	no	M	L	Norwegian	
nos				I	L	Eastern Nisu	
not				I	L	Nomatsiguenga	
nou				I	L	Ewage-Notu	
nov				I	C	Novial	
now				I	L	Nyambo	
noy				I	L	Noy	
noz				I	L	Nayi	
npa				I	L	Nar Phu	
npb				I	L	Nupbikha	
npg				I	L	Ponyo-Gongwang Naga	
nph				I	L	Phom Naga	
npi				I	L	Nepali (individual language)	
npl				I	L	Southeastern Puebla Nahuatl	
npn				I	L	Mondropolon	
npo				I	L	Pochuri Naga	
nps				I	L	Nipsan	
npu				I	L	Puimei Naga	
npx				I	L	Noipx	
npy				I	L	Napu	
nqg				I	L	Southern Nago	
nqk				I	L	Kura Ede Nago	
nql				I	L	Ngendelengo	
nqm				I	L	Ndom	
nqn				I	L	Nen	
nqo	nqo	nqo		I	L	N'Ko	
nqq				I	L	Kyan-Karyaw Naga	
nqy				I	L	Akyaung Ari Naga	
nra				I	L	Ngom	
nrb				I	L	Nara	
nrc				I	A	Noric	
nre				I	L	Southern Rengma Naga	
nrf				I	L	Jèrriais	
nrg				I	L	Narango	
nri				I	L	Chokri Naga	
nrk				I	L	Ngarla	
nrl				I	L	Ngarluma	
nrm				I	L	Narom	
nrn				I	E	Norn	
nrp				I	A	North Picene	
nrr				I	E	Norra	
nrt				I	E	Northern Kalapuya	
nru				I	L	Narua	
nrx				I	E	Ngurmbur	
nrz				I	L	Lala	
nsa				I	L	Sangtam Naga	
nsb				I	E	Lower Nossob	
nsc				I	L	Nshi	
nsd				I	L	Southern Nisu	
nse				I	L	Nsenga	
nsf				I	L	Northwestern Nisu	
nsg				I	L	Ngasa	
nsh				I	L	Ngoshie	
nsi				I	L	Nigerian Sign Language	
nsk				I	L	Naskapi	
nsl				I	L	Norwegian Sign Language	
nsm				I	L	Sumi Naga	
nsn				I	L	Nehan	
nso	nso	nso		I	L	Pedi	
nsp				I	L	Nepalese Sign Language	
nsq				I	L	Northern Sierra Miwok	
nsr				I	L	Maritime Sign Language	
nss				I	L	Nali	
nst				I	L	Tase Naga	
nsu				I	L	Sierra Negra Nahuatl	
nsv				I	L	Southwestern Nisu	
nsw				I	L	Navut	
nsx				I	L	Nsongo	
nsy				I	L	Nasal	
nsz				I	L	Nisenan	
ntd				I	L	Northern Tidung	
nte				I	L	Nathembo	
ntg				I	E	Ngantangarra	
nti				I	L	Natioro	
ntj				I	L	Ngaanyatjarra	
ntk				I	L	Ikoma-Nata-Isenye	
ntm				I	L	Nateni	
nto				I	L	Ntomba	
ntp				I	L	Northern Tepehuan	
ntr				I	L	Delo	
ntu				I	L	Natügu	
ntw				I	E	Nottoway	
ntx				I	L	Tangkhul Naga (Myanmar)	
nty				I	L	Mantsi	
ntz				I	L	Natanzi	
nua				I	L	Yuanga	
nuc				I	E	Nukuini	
nud				I	L	Ngala	
nue				I	L	Ngundu	
nuf				I	L	Nusu	
nug				I	E	Nungali	
nuh				I	L	Ndunda	
nui				I	L	Ngumbi	
nuj				I	L	Nyole	
nuk				I	L	Nuu-chah-nulth	
nul				I	E	Nusa Laut	
num				I	L	Niuafo'ou	
nun				I	L	Anong	
nuo				I	L	Nguôn	
nup				I	L	Nupe-Nupe-Tako	
nuq				I	L	Nukumanu	
nur				I	L	Nukuria	
nus				I	L	Nuer	
nut				I	L	Nung (Viet Nam)	
nuu				I	L	Ngbundu	
nuv				I	L	Northern Nuni	
nuw				I	L	Nguluwan	
nux				I	L	Mehek	
nuy				I	L	Nunggubuyu	
nuz				I	L	Tlamacazapa Nahuatl	
nvh				I	L	Nasarian	
nvm				I	L	Namiae	
nvo				I	L	Nyokon	
nwa				I	E	Nawathinehena	
nwb				I	L	Nyabwa	
nwc	nwc	nwc		I	H	Classical Newari	
nwe				I	L	Ngwe	
nwg				I	E	Ngayawung	
nwi				I	L	Southwest Tanna	
nwm				I	L	Nyamusa-Molo	
nwo				I	E	Nauo	
nwr				I	L	Nawaru	
nwx				I	H	Middle Newar	
nwy				I	E	Nottoway-Meherrin	
nxa				I	L	Nauete	
nxd				I	L	Ngando (Democratic Republic of Congo)	
nxe				I	L	Nage	
nxg				I	L	Ngad'a	
nxi				I	L	Nindi	
nxk				I	L	Koki Naga	
nxl				I	L	South Nuaulu	
nxm				I	A	Numidian	
nxn				I	E	Ngawun	
nxo				I	L	Ndambomo	
nxq				I	L	Naxi	
nxr				I	L	Ninggerum	
nxx				I	L	Nafri	
nya	nya	nya	ny	I	L	Nyanja	
nyb				I	L	Nyangbo	
nyc				I	L	Nyanga-li	
nyd				I	L	Nyore	
nye				I	L	Nyengo	
nyf				I	L	Giryama	
nyg				I	L	Nyindu	
nyh				I	L	Nyikina	
nyi				I	L	Ama (Sudan)	
nyj				I	L	Nyanga	
nyk				I	L	Nyaneka	
nyl				I	L	Nyeu	
nym	nym	nym		I	L	Nyamwezi	
nyn	nyn	nyn		I	L	Nyankole	
nyo	nyo	nyo		I	L	Nyoro	
nyp				I	E	Nyang'i	
nyq				I	L	Nayini	
nyr				I	L	Nyiha (Malawi)	
nys				I	L	Nyungar	
nyt				I	E	Nyawaygi	
nyu				I	L	Nyungwe	
nyv				I	E	Nyulnyul	
nyw				I	L	Nyaw	
nyx				I	E	Nganyaywana	
nyy				I	L	Nyakyusa-Ngonde	
nza				I	L	Tigon Mbembe	
nzb				I	L	Njebi	
nzd				I	L	Nzadi	
nzi	nzi	nzi		I	L	Nzima	
nzk				I	L	Nzakara	
nzm				I	L	Zeme Naga	
nzs				I	L	New Zealand Sign Language	
nzu				I	L	Teke-Nzikou	
nzy				I	L	Nzakambay	
nzz				I	L	Nanga Dama Dogon	
oaa				I	L	Orok	
oac				I	L	Oroch	
oar				I	A	Old Aramaic (up to 700 BCE)	
oav				I	H	Old Avar	
obi				I	E	Obispeño	
obk				I	L	Southern Bontok	
obl				I	L	Oblo	
obm				I	A	Moabite	
obo				I	L	Obo Manobo	
obr				I	H	Old Burmese	
obt				I	H	Old Breton	
obu				I	L	Obulom	
oca				I	L	Ocaina	
och				I	A	Old Chinese	
oci	oci	oci	oc	I	L	Occitan (post 1500)	
oco				I	H	Old Cornish	
ocu				I	L	Atzingo Matlatzinca	
oda				I	L	Odut	
odk				I	L	Od	
odt				I	H	Old Dutch	
odu				I	L	Odual	
ofo				I	E	Ofo	
ofs				I	H	Old Frisian	
ofu				I	L	Efutop	
ogb				I	L	Ogbia	
ogc				I	L	Ogbah	
oge				I	H	Old Georgian	
ogg				I	L	Ogbogolo	
ogo				I	L	Khana	
ogu				I	L	Ogbronuagum	
oht				I	A	Old Hittite	
ohu				I	H	Old Hungarian	
oia				I	L	Oirata	
oin				I	L	Inebu One	
ojb				I	L	Northwestern Ojibwa	
ojc				I	L	Central Ojibwa	
ojg				I	L	Eastern Ojibwa	
oji	oji	oji	oj	M	L	Ojibwa	
ojp				I	H	Old Japanese	
ojs				I	L	Severn Ojibwa	
ojv				I	L	Ontong Java	
ojw				I	L	Western Ojibwa	
oka				I	L	Okanagan	
okb				I	L	Okobo	
okd				I	L	Okodia	
oke				I	L	Okpe (Southwestern Edo)	
okg				I	E	Koko Babangk	
okh				I	L	Koresh-e Rostam	
oki				I	L	Okiek	
okj				I	E	Oko-Juwoi	
okk				I	L	Kwamtim One	
okl				I	E	Old Kentish Sign Language	
okm				I	H	Middle Korean (10th-16th cent.)	
okn				I	L	Oki-No-Erabu	
oko				I	H	Old Korean (3rd-9th cent.)	
okr				I	L	Kirike	
oks				I	L	Oko-Eni-Osayen	
oku				I	L	Oku	
okv				I	L	Orokaiva	
okx				I	L	Okpe (Northwestern Edo)	
ola				I	L	Walungge	
old				I	L	Mochi	
ole				I	L	Olekha	
olk				I	E	Olkol	
olm				I	L	Oloma	
olo				I	L	Livvi	
olr				I	L	Olrat	
olt				I	H	Old Lithuanian	
olu				I	L	Kuvale	
oma				I	L	Omaha-Ponca	
omb				I	L	East Ambae	
omc				I	E	Mochica	
omg				I	L	Omagua	
omi				I	L	Omi	
omk				I	E	Omok	
oml				I	L	Ombo	
omn				I	A	Minoan	
omo				I	L	Utarmbung	
omp				I	H	Old Manipuri	
omr				I	H	Old Marathi	
omt				I	L	Omotik	
omu				I	E	Omurano	
omw				I	L	South Tairora	
omx				I	H	Old Mon	
ona				I	L	Ona	
onb				I	L	Lingao	
one				I	L	Oneida	
ong				I	L	Olo	
oni				I	L	Onin	
onj				I	L	Onjob	
onk				I	L	Kabore One	
onn				I	L	Onobasulu	
ono				I	L	Onondaga	
onp				I	L	Sartang	
onr				I	L	Northern One	
ons				I	L	Ono	
ont				I	L	Ontenu	
onu				I	L	Unua	
onw				I	H	Old Nubian	
onx				I	L	Onin Based Pidgin	
ood				I	L	Tohono O'odham	
oog				I	L	Ong	
oon				I	L	Önge	
oor				I	L	Oorlams	
oos				I	A	Old Ossetic	
opa				I	L	Okpamheri	
opk				I	L	Kopkaka	
opm				I	L	Oksapmin	
opo				I	L	Opao	
opt				I	E	Opata	
opy				I	L	Ofayé	
ora				I	L	Oroha	
orc				I	L	Orma	
ore				I	L	Orejón	
org				I	L	Oring	
orh				I	L	Oroqen	
ori	ori	ori	or	M	L	Oriya (macrolanguage)	
orm	orm	orm	om	M	L	Oromo	
orn				I	L	Orang Kanaq	
oro				I	L	Orokolo	
orr				I	L	Oruma	
ors				I	L	Orang Seletar	
ort				I	L	Adivasi Oriya	
oru				I	L	Ormuri	
orv				I	H	Old Russian	
orw				I	L	Oro Win	
orx				I	L	Oro	
ory				I	L	Odia	
orz				I	L	Ormu	
osa	osa	osa		I	L	Osage	
osc				I	A	Oscan	
osi				I	L	Osing	
oso				I	L	Ososo	
osp				I	H	Old Spanish	
oss	oss	oss	os	I	L	Ossetian	
ost				I	L	Osatu	
osu				I	L	Southern One	
osx				I	H	Old Saxon	
ota	ota	ota		I	H	Ottoman Turkish (1500-1928)	
otb				I	H	Old Tibetan	
otd				I	L	Ot Danum	
ote				I	L	Mezquital Otomi	
oti				I	E	Oti	
otk				I	H	Old Turkish	
otl				I	L	Tilapa Otomi	
otm				I	L	Eastern Highland Otomi	
otn				I	L	Tenango Otomi	
otq				I	L	Querétaro Otomi	
otr				I	L	Otoro	
ots				I	L	Estado de México Otomi	
ott				I	L	Temoaya Otomi	
otu				I	E	Otuke	
otw				I	L	Ottawa	
otx				I	L	Texcatepec Otomi	
oty				I	A	Old Tamil	
otz				I	L	Ixtenco Otomi	
oua				I	L	Tagargrent	
oub				I	L	Glio-Oubi	
oue				I	L	Oune	
oui				I	H	Old Uighur	
oum				I	E	Ouma	
ovd				I	L	Elfdalian	
owi				I	L	Owiniga	
owl				I	H	Old Welsh	
oyb				I	L	Oy	
oyd				I	L	Oyda	
oym				I	L	Wayampi	
oyy				I	L	Oya'oya	
ozm				I	L	Koonzime	
pab				I	L	Parecís	
pac				I	L	Pacoh	
pad				I	L	Paumarí	
pae				I	L	Pagibete	
paf				I	E	Paranawát	
pag	pag	pag		I	L	Pangasinan	
pah				I	L	Tenharim	
pai				I	L	Pe	
pak				I	L	Parakanã	
pal	pal	pal		I	A	Pahlavi	
pam	pam	pam		I	L	Pampanga	
pan	pan	pan	pa	I	L	Panjabi	
pao				I	L	Northern Paiute	
pap	pap	pap		I	L	Papiamento	
paq				I	L	Parya	
par				I	L	Panamint	
pas				I	L	Papasena	
pat				I	L	Papitalai	
pau	pau	pau		I	L	Palauan	
pav				I	L	Pakaásnovos	
paw				I	L	Pawnee	
pax				I	E	Pankararé	
pay				I	L	Pech	
paz				I	E	Pankararú	
pbb				I	L	Páez	
pbc				I	L	Patamona	
pbe				I	L	Mezontla Popoloca	
pbf				I	L	Coyotepec Popoloca	
pbg				I	E	Paraujano	
pbh				I	L	E'ñapa Woromaipu	
pbi				I	L	Parkwa	
pbl				I	L	Mak (Nigeria)	
pbm				I	L	Puebla Mazatec	
pbn				I	L	Kpasam	
pbo				I	L	Papel	
pbp				I	L	Badyara	
pbr				I	L	Pangwa	
pbs				I	L	Central Pame	
pbt				I	L	Southern Pashto	
pbu				I	L	Northern Pashto	
pbv				I	L	Pnar	
pby				I	L	Pyu (Papua New Guinea)	
pca				I	L	Santa Inés Ahuatempan Popoloca	
pcb				I	L	Pear	
pcc				I	L	Bouyei	
pcd				I	L	Picard	
pce				I	L	Ruching Palaung	
pcf				I	L	Paliyan	
pcg				I	L	Paniya	
pch				I	L	Pardhan	
pci				I	L	Duruwa	
pcj				I	L	Parenga	
pck				I	L	Paite Chin	
pcl				I	L	Pardhi	
pcm				I	L	Nigerian Pidgin	
pcn				I	L	Piti	
pcp				I	L	Pacahuara	
pcw				I	L	Pyapun	
pda				I	L	Anam	
pdc				I	L	Pennsylvania German	
pdi				I	L	Pa Di	
pdn				I	L	Podena	
pdo				I	L	Padoe	
pdt				I	L	Plautdietsch	
pdu				I	L	Kayan	
pea				I	L	Peranakan Indonesian	
peb				I	E	Eastern Pomo	
ped				I	L	Mala (Papua New Guinea)	
pee				I	L	Taje	
pef				I	E	Northeastern Pomo	
peg				I	L	Pengo	
peh				I	L	Bonan	
pei				I	L	Chichimeca-Jonaz	
pej				I	E	Northern Pomo	
pek				I	L	Penchal	
pel				I	L	Pekal	
pem				I	L	Phende	
peo	peo	peo		I	H	Old Persian (ca. 600-400 B.C.)	
pep				I	L	Kunja	
peq				I	L	Southern Pomo	
pes				I	L	Iranian Persian	
pev				I	L	Pémono	
pex				I	L	Petats	
pey				I	L	Petjo	
pez				I	L	Eastern Penan	
pfa				I	L	Pááfang	
pfe				I	L	Pere	
pfl				I	L	Pfaelzisch	
pga				I	L	Sudanese Creole Arabic	
pgd				I	H	Gāndhārī	
pgg				I	L	Pangwali	
pgi				I	L	Pagi	
pgk				I	L	Rerep	
pgl				I	A	Primitive Irish	
pgn				I	A	Paelignian	
pgs				I	L	Pangseng	
pgu				I	L	Pagu	
pgz				I	L	Papua New Guinean Sign Language	
pha				I	L	Pa-Hng	
phd				I	L	Phudagi	
phg				I	L	Phuong	
phh				I	L	Phukha	
phk				I	L	Phake	
phl				I	L	Phalura	
phm				I	L	Phimbi	
phn	phn	phn		I	A	Phoenician	
pho				I	L	Phunoi	
phq				I	L	Phana'	
phr				I	L	Pahari-Potwari	
pht				I	L	Phu Thai	
phu				I	L	Phuan	
phv				I	L	Pahlavani	
phw				I	L	Phangduwali	
pia				I	L	Pima Bajo	
pib				I	L	Yine	
pic				I	L	Pinji	
pid				I	L	Piaroa	
pie				I	E	Piro	
pif				I	L	Pingelapese	
pig				I	L	Pisabo	
pih				I	L	Pitcairn-Norfolk	
pii				I	L	Pini	
pij				I	E	Pijao	
pil				I	L	Yom	
pim				I	E	Powhatan	
pin				I	L	Piame	
pio				I	L	Piapoco	
pip				I	L	Pero	
pir				I	L	Piratapuyo	
pis				I	L	Pijin	
pit				I	E	Pitta Pitta	
piu				I	L	Pintupi-Luritja	
piv				I	L	Pileni	
piw				I	L	Pimbwe	
pix				I	L	Piu	
piy				I	L	Piya-Kwonci	
piz				I	L	Pije	
pjt				I	L	Pitjantjatjara	
pka				I	H	Ardhamāgadhī Prākrit	
pkb				I	L	Pokomo	
pkc				I	A	Paekche	
pkg				I	L	Pak-Tong	
pkh				I	L	Pankhu	
pkn				I	L	Pakanha	
pko				I	L	Pökoot	
pkp				I	L	Pukapuka	
pkr				I	L	Attapady Kurumba	
pks				I	L	Pakistan Sign Language	
pkt				I	L	Maleng	
pku				I	L	Paku	
pla				I	L	Miani	
plb				I	L	Polonombauk	
plc				I	L	Central Palawano	
pld				I	L	Polari	
ple				I	L	Palu'e	
plg				I	L	Pilagá	
plh				I	L	Paulohi	
pli	pli	pli	pi	I	A	Pali	
plj				I	L	Polci	
plk				I	L	Kohistani Shina	
pll				I	L	Shwe Palaung	
pln				I	L	Palenquero	
plo				I	L	Oluta Popoluca	
plq				I	A	Palaic	
plr				I	L	Palaka Senoufo	
pls				I	L	San Marcos Tlacoyalco Popoloca	
plt				I	L	Plateau Malagasy	
plu				I	L	Palikúr	
plv				I	L	Southwest Palawano	
plw				I	L	Brooke's Point Palawano	
ply				I	L	Bolyu	
plz				I	L	Paluan	
pma				I	L	Paama	
pmb				I	L	Pambia	
pmd				I	E	Pallanganmiddang	
pme				I	L	Pwaamei	
pmf				I	L	Pamona	
pmh				I	H	Māhārāṣṭri Prākrit	
pmi				I	L	Northern Pumi	
pmj				I	L	Southern Pumi	
pmk				I	E	Pamlico	
pml				I	E	Lingua Franca	
pmm				I	L	Pomo	
pmn				I	L	Pam	
pmo				I	L	Pom	
pmq				I	L	Northern Pame	
pmr				I	L	Paynamar	
pms				I	L	Piemontese	
pmt				I	L	Tuamotuan	
pmw				I	L	Plains Miwok	
pmx				I	L	Poumei Naga	
pmy				I	L	Papuan Malay	
pmz				I	E	Southern Pame	
pna				I	L	Punan Bah-Biau	
pnb				I	L	Western Panjabi	
pnc				I	L	Pannei	
pnd				I	L	Mpinda	
pne				I	L	Western Penan	
png				I	L	Pongu	
pnh				I	L	Penrhyn	
pni				I	L	Aoheng	
pnj				I	E	Pinjarup	
pnk				I	L	Paunaka	
pnl				I	L	Paleni	
pnm				I	L	Punan Batu 1	
pnn				I	L	Pinai-Hagahai	
pno				I	E	Panobo	
pnp				I	L	Pancana	
pnq				I	L	Pana (Burkina Faso)	
pnr				I	L	Panim	
pns				I	L	Ponosakan	
pnt				I	L	Pontic	
pnu				I	L	Jiongnai Bunu	
pnv				I	L	Pinigura	
pnw				I	L	Banyjima	
pnx				I	L	Phong-Kniang	
pny				I	L	Pinyin	
pnz				I	L	Pana (Central African Republic)	
poc				I	L	Poqomam	
poe				I	L	San Juan Atzingo Popoloca	
pof				I	L	Poke	
pog				I	E	Potiguára	
poh				I	L	Poqomchi'	
poi				I	L	Highland Popoluca	
pok				I	L	Pokangá	
pol	pol	pol	pl	I	L	Polish	
pom				I	L	Southeastern Pomo	
pon	pon	pon		I	L	Pohnpeian	
poo				I	E	Central Pomo	
pop				I	L	Pwapwâ	
poq				I	L	Texistepec Popoluca	
por	por	por	pt	I	L	Portuguese	
pos				I	L	Sayula Popoluca	
pot				I	L	Potawatomi	
pov				I	L	Upper Guinea Crioulo	
pow				I	L	San Felipe Otlaltepec Popoloca	
pox				I	E	Polabian	
poy				I	L	Pogolo	
ppe				I	L	Papi	
ppi				I	L	Paipai	
ppk				I	L	Uma	
ppl				I	L	Pipil	
ppm				I	L	Papuma	
ppn				I	L	Papapana	
ppo				I	L	Folopa	
ppp				I	L	Pelende	
ppq				I	L	Pei	
pps				I	L	San Luís Temalacayuca Popoloca	
ppt				I	L	Pare	
ppu				I	E	Papora	
pqa				I	L	Pa'a	
pqm				I	L	Malecite-Passamaquoddy	
prc				I	L	Parachi	
prd				I	L	Parsi-Dari	
pre				I	L	Principense	
prf				I	L	Paranan	
prg				I	L	Prussian	
prh				I	L	Porohanon	
pri				I	L	Paicî	
prk				I	L	Parauk	
prl				I	L	Peruvian Sign Language	
prm				I	L	Kibiri	
prn				I	L	Prasuni	
pro	pro	pro		I	H	Old Provençal (to 1500)	
prp				I	L	Parsi	
prq				I	L	Ashéninka Perené	
prr				I	E	Puri	
prs				I	L	Dari	
prt				I	L	Phai	
pru				I	L	Puragi	
prw				I	L	Parawen	
prx				I	L	Purik	
prz				I	L	Providencia Sign Language	
psa				I	L	Asue Awyu	
psc				I	L	Persian Sign Language	
psd				I	L	Plains Indian Sign Language	
pse				I	L	Central Malay	
psg				I	L	Penang Sign Language	
psh				I	L	Southwest Pashai	
psi				I	L	Southeast Pashai	
psl				I	L	Puerto Rican Sign Language	
psm				I	E	Pauserna	
psn				I	L	Panasuan	
pso				I	L	Polish Sign Language	
psp				I	L	Philippine Sign Language	
psq				I	L	Pasi	
psr				I	L	Portuguese Sign Language	
pss				I	L	Kaulong	
pst				I	L	Central Pashto	
psu				I	H	Sauraseni Prākrit	
psw				I	L	Port Sandwich	
psy				I	E	Piscataway	
pta				I	L	Pai Tavytera	
pth				I	E	Pataxó Hã-Ha-Hãe	
pti				I	L	Pindiini	
ptn				I	L	Patani	
pto				I	L	Zo'é	
ptp				I	L	Patep	
ptq				I	L	Pattapu	
ptr				I	L	Piamatsina	
ptt				I	L	Enrekang	
ptu				I	L	Bambam	
ptv				I	L	Port Vato	
ptw				I	E	Pentlatch	
pty				I	L	Pathiya	
pua				I	L	Western Highland Purepecha	
pub				I	L	Purum	
puc				I	L	Punan Merap	
pud				I	L	Punan Aput	
pue				I	E	Puelche	
puf				I	L	Punan Merah	
pug				I	L	Phuie	
pui				I	L	Puinave	
puj				I	L	Punan Tubu	
pum				I	L	Puma	
puo				I	L	Puoc	
pup				I	L	Pulabu	
puq				I	E	Puquina	
pur				I	L	Puruborá	
pus	pus	pus	ps	M	L	Pushto	
put				I	L	Putoh	
puu				I	L	Punu	
puw				I	L	Puluwatese	
pux				I	L	Puare	
puy				I	E	Purisimeño	
pwa				I	L	Pawaia	
pwb				I	L	Panawa	
pwg				I	L	Gapapaiwa	
pwi				I	E	Patwin	
pwm				I	L	Molbog	
pwn				I	L	Paiwan	
pwo				I	L	Pwo Western Karen	
pwr				I	L	Powari	
pww				I	L	Pwo Northern Karen	
pxm				I	L	Quetzaltepec Mixe	
pye				I	L	Pye Krumen	
pym				I	L	Fyam	
pyn				I	L	Poyanáwa	
pys				I	L	Paraguayan Sign Language	
pyu				I	L	Puyuma	
pyx				I	A	Pyu (Myanmar)	
pyy				I	L	Pyen	
pzn				I	L	Para Naga	
qua				I	L	Quapaw	
qub				I	L	Huallaga Huánuco Quechua	
quc				I	L	K'iche'	
qud				I	L	Calderón Highland Quichua	
que	que	que	qu	M	L	Quechua	
quf				I	L	Lambayeque Quechua	
qug				I	L	Chimborazo Highland Quichua	
quh				I	L	South Bolivian Quechua	
qui				I	L	Quileute	
quk				I	L	Chachapoyas Quechua	
qul				I	L	North Bolivian Quechua	
qum				I	L	Sipacapense	
qun				I	E	Quinault	
qup				I	L	Southern Pastaza Quechua	
quq				I	L	Quinqui	
qur				I	L	Yanahuanca Pasco Quechua	
qus				I	L	Santiago del Estero Quichua	
quv				I	L	Sacapulteco	
quw				I	L	Tena Lowland Quichua	
qux				I	L	Yauyos Quechua	
quy				I	L	Ayacucho Quechua	
quz				I	L	Cusco Quechua	
qva				I	L	Ambo-Pasco Quechua	
qvc				I	L	Cajamarca Quechua	
qve				I	L	Eastern Apurímac Quechua	
qvh				I	L	Huamalíes-Dos de Mayo Huánuco Quechua	
qvi				I	L	Imbabura Highland Quichua	
qvj				I	L	Loja Highland Quichua	
qvl				I	L	Cajatambo North Lima Quechua	
qvm				I	L	Margos-Yarowilca-Lauricocha Quechua	
qvn				I	L	North Junín Quechua	
qvo				I	L	Napo Lowland Quechua	
qvp				I	L	Pacaraos Quechua	
qvs				I	L	San Martín Quechua	
qvw				I	L	Huaylla Wanca Quechua	
qvy				I	L	Queyu	
qvz				I	L	Northern Pastaza Quichua	
qwa				I	L	Corongo Ancash Quechua	
qwc				I	H	Classical Quechua	
qwh				I	L	Huaylas Ancash Quechua	
qwm				I	E	Kuman (Russia)	
qws				I	L	Sihuas Ancash Quechua	
qwt				I	E	Kwalhioqua-Tlatskanai	
qxa				I	L	Chiquián Ancash Quechua	
qxc				I	L	Chincha Quechua	
qxh				I	L	Panao Huánuco Quechua	
qxl				I	L	Salasaca Highland Quichua	
qxn				I	L	Northern Conchucos Ancash Quechua	
qxo				I	L	Southern Conchucos Ancash Quechua	
qxp				I	L	Puno Quechua	
qxq				I	L	Qashqa'i	
qxr				I	L	Cañar Highland Quichua	
qxs				I	L	Southern Qiang	
qxt				I	L	Santa Ana de Tusi Pasco Quechua	
qxu				I	L	Arequipa-La Unión Quechua	
qxw				I	L	Jauja Wanca Quechua	
qya				I	C	Quenya	
qyp				I	E	Quiripi	
raa				I	L	Dungmali	
rab				I	L	Camling	
rac				I	L	Rasawa	
rad				I	L	Rade	
raf				I	L	Western Meohang	
rag				I	L	Logooli	
rah				I	L	Rabha	
rai				I	L	Ramoaaina	
raj	raj	raj		M	L	Rajasthani	
rak				I	L	Tulu-Bohuai	
ral				I	L	Ralte	
ram				I	L	Canela	
ran				I	L	Riantana	
rao				I	L	Rao	
rap	rap	rap		I	L	Rapanui	
raq				I	L	Saam	
rar	rar	rar		I	L	Rarotongan	
ras				I	L	Tegali	
rat				I	L	Razajerdi	
rau				I	L	Raute	
rav				I	L	Sampang	
raw				I	L	Rawang	
rax				I	L	Rang	
ray				I	L	Rapa	
raz				I	L	Rahambuu	
rbb				I	L	Rumai Palaung	
rbk				I	L	Northern Bontok	
rbl				I	L	Miraya Bikol	
rbp				I	E	Barababaraba	
rcf				I	L	Réunion Creole French	
rdb				I	L	Rudbari	
rea				I	L	Rerau	
reb				I	L	Rembong	
ree				I	L	Rejang Kayan	
reg				I	L	Kara (Tanzania)	
rei				I	L	Reli	
rej				I	L	Rejang	
rel				I	L	Rendille	
rem				I	E	Remo	
ren				I	L	Rengao	
rer				I	E	Rer Bare	
res				I	L	Reshe	
ret				I	L	Retta	
rey				I	L	Reyesano	
rga				I	L	Roria	
rge				I	L	Romano-Greek	
rgk				I	E	Rangkas	
rgn				I	L	Romagnol	
rgr				I	L	Resígaro	
rgs				I	L	Southern Roglai	
rgu				I	L	Ringgou	
rhg				I	L	Rohingya	
rhp				I	L	Yahang	
ria				I	L	Riang (India)	
rif				I	L	Tarifit	
ril				I	L	Riang Lang	
rim				I	L	Nyaturu	
rin				I	L	Nungu	
rir				I	L	Ribun	
rit				I	L	Ritharrngu	
riu				I	L	Riung	
rjg				I	L	Rajong	
rji				I	L	Raji	
rjs				I	L	Rajbanshi	
rka				I	L	Kraol	
rkb				I	L	Rikbaktsa	
rkh				I	L	Rakahanga-Manihiki	
rki				I	L	Rakhine	
rkm				I	L	Marka	
rkt				I	L	Rangpuri	
rkw				I	E	Arakwal	
rma				I	L	Rama	
rmb				I	L	Rembarrnga	
rmc				I	L	Carpathian Romani	
rmd				I	E	Traveller Danish	
rme				I	L	Angloromani	
rmf				I	L	Kalo Finnish Romani	
rmg				I	L	Traveller Norwegian	
rmh				I	L	Murkim	
rmi				I	L	Lomavren	
rmk				I	L	Romkun	
rml				I	L	Baltic Romani	
rmm				I	L	Roma	
rmn				I	L	Balkan Romani	
rmo				I	L	Sinte Romani	
rmp				I	L	Rempi	
rmq				I	L	Caló	
rms				I	L	Romanian Sign Language	
rmt				I	L	Domari	
rmu				I	L	Tavringer Romani	
rmv				I	C	Romanova	
rmw				I	L	Welsh Romani	
rmx				I	L	Romam	
rmy				I	L	Vlax Romani	
rmz				I	L	Marma	
rnd				I	L	Ruund	
rng				I	L	Ronga	
rnl				I	L	Ranglong	
rnn				I	L	Roon	
rnp				I	L	Rongpo	
rnr				I	E	Nari Nari	
rnw				I	L	Rungwa	
rob				I	L	Tae'	
roc				I	L	Cacgia Roglai	
rod				I	L	Rogo	
roe				I	L	Ronji	
rof				I	L	Rombo	
rog				I	L	Northern Roglai	
roh	roh	roh	rm	I	L	Romansh	
rol				I	L	Romblomanon	
rom	rom	rom		M	L	Romany	
ron	rum	ron	ro	I	L	Romanian	
roo				I	L	Rotokas	
rop				I	L	Kriol	
ror				I	L	Rongga	
rou				I	L	Runga	
row				I	L	Dela-Oenale	
rpn				I	L	Repanbitip	
rpt				I	L	Rapting	
rri				I	L	Ririo	
rro				I	L	Waima	
rrt				I	E	Arritinngithigh	
rsb				I	L	Romano-Serbian	
rsl				I	L	Russian Sign Language	
rsm				I	L	Miriwoong Sign Language	
rtc				I	L	Rungtu Chin	
rth				I	L	Ratahan	
rtm				I	L	Rotuman	
rts				I	E	Yurats	
rtw				I	L	Rathawi	
rub				I	L	Gungu	
ruc				I	L	Ruuli	
rue				I	L	Rusyn	
ruf				I	L	Luguru	
rug				I	L	Roviana	
ruh				I	L	Ruga	
rui				I	L	Rufiji	
ruk				I	L	Che	
run	run	run	rn	I	L	Rundi	
ruo				I	L	Istro Romanian	
rup	rup	rup		I	L	Macedo-Romanian	
ruq				I	L	Megleno Romanian	
rus	rus	rus	ru	I	L	Russian	
rut				I	L	Rutul	
ruu				I	L	Lanas Lobu	
ruy				I	L	Mala (Nigeria)	
ruz				I	L	Ruma	
rwa				I	L	Rawo	
rwk				I	L	Rwa	
rwm				I	L	Amba (Uganda)	
rwo				I	L	Rawa	
rwr				I	L	Marwari (India)	
rxd				I	L	Ngardi	
rxw				I	E	Karuwali	
ryn				I	L	Northern Amami-Oshima	
rys				I	L	Yaeyama	
ryu				I	L	Central Okinawan	
rzh				I	L	Rāziḥī	
saa				I	L	Saba	
sab				I	L	Buglere	
sac				I	L	Meskwaki	
sad	sad	sad		I	L	Sandawe	
sae				I	L	Sabanê	
saf				I	L	Safaliba	
sag	sag	sag	sg	I	L	Sango	
sah	sah	sah		I	L	Yakut	
saj				I	L	Sahu	
sak				I	L	Sake	
sam	sam	sam		I	E	Samaritan Aramaic	
san	san	san	sa	I	A	Sanskrit	
sao				I	L	Sause	
saq				I	L	Samburu	
sar				I	E	Saraveca	
sas	sas	sas		I	L	Sasak	
sat	sat	sat		I	L	Santali	
sau				I	L	Saleman	
sav				I	L	Saafi-Saafi	
saw				I	L	Sawi	
sax				I	L	Sa	
say				I	L	Saya	
saz				I	L	Saurashtra	
sba				I	L	Ngambay	
sbb				I	L	Simbo	
sbc				I	L	Kele (Papua New Guinea)	
sbd				I	L	Southern Samo	
sbe				I	L	Saliba	
sbf				I	L	Chabu	
sbg				I	L	Seget	
sbh				I	L	Sori-Harengan	
sbi				I	L	Seti	
sbj				I	L	Surbakhal	
sbk				I	L	Safwa	
sbl				I	L	Botolan Sambal	
sbm				I	L	Sagala	
sbn				I	L	Sindhi Bhil	
sbo				I	L	Sabüm	
sbp				I	L	Sangu (Tanzania)	
sbq				I	L	Sileibi	
sbr				I	L	Sembakung Murut	
sbs				I	L	Subiya	
sbt				I	L	Kimki	
sbu				I	L	Stod Bhoti	
sbv				I	A	Sabine	
sbw				I	L	Simba	
sbx				I	L	Seberuang	
sby				I	L	Soli	
sbz				I	L	Sara Kaba	
scb				I	L	Chut	
sce				I	L	Dongxiang	
scf				I	L	San Miguel Creole French	
scg				I	L	Sanggau	
sch				I	L	Sakachep	
sci				I	L	Sri Lankan Creole Malay	
sck				I	L	Sadri	
scl				I	L	Shina	
scn	scn	scn		I	L	Sicilian	
sco	sco	sco		I	L	Scots	
scp				I	L	Hyolmo	
scq				I	L	Sa'och	
scs				I	L	North Slavey	
sct				I	L	Southern Katang	
scu				I	L	Shumcho	
scv				I	L	Sheni	
scw				I	L	Sha	
scx				I	A	Sicel	
sda				I	L	Toraja-Sa'dan	
sdb				I	L	Shabak	
sdc				I	L	Sassarese Sardinian	
sde				I	L	Surubu	
sdf				I	L	Sarli	
sdg				I	L	Savi	
sdh				I	L	Southern Kurdish	
sdj				I	L	Suundi	
sdk				I	L	Sos Kundi	
sdl				I	L	Saudi Arabian Sign Language	
sdn				I	L	Gallurese Sardinian	
sdo				I	L	Bukar-Sadung Bidayuh	
sdp				I	L	Sherdukpen	
sdq				I	L	Semandang	
sdr				I	L	Oraon Sadri	
sds				I	E	Sened	
sdt				I	E	Shuadit	
sdu				I	L	Sarudu	
sdx				I	L	Sibu Melanau	
sdz				I	L	Sallands	
sea				I	L	Semai	
seb				I	L	Shempire Senoufo	
sec				I	L	Sechelt	
sed				I	L	Sedang	
see				I	L	Seneca	
sef				I	L	Cebaara Senoufo	
seg				I	L	Segeju	
seh				I	L	Sena	
sei				I	L	Seri	
sej				I	L	Sene	
sek				I	L	Sekani	
sel	sel	sel		I	L	Selkup	
sen				I	L	Nanerigé Sénoufo	
seo				I	L	Suarmin	
sep				I	L	Sìcìté Sénoufo	
seq				I	L	Senara Sénoufo	
ser				I	L	Serrano	
ses				I	L	Koyraboro Senni Songhai	
set				I	L	Sentani	
seu				I	L	Serui-Laut	
sev				I	L	Nyarafolo Senoufo	
sew				I	L	Sewa Bay	
sey				I	L	Secoya	
sez				I	L	Senthang Chin	
sfb				I	L	Langue des signes de Belgique Francophone	
sfe				I	L	Eastern Subanen	
sfm				I	L	Small Flowery Miao	
sfs				I	L	South African Sign Language	
sfw				I	L	Sehwi	
sga	sga	sga		I	H	Old Irish (to 900)	
sgb				I	L	Mag-antsi Ayta	
sgc				I	L	Kipsigis	
sgd				I	L	Surigaonon	
sge				I	L	Segai	
sgg				I	L	Swiss-German Sign Language	
sgh				I	L	Shughni	
sgi				I	L	Suga	
sgj				I	L	Surgujia	
sgk				I	L	Sangkong	
sgm				I	E	Singa	
sgp				I	L	Singpho	
sgr				I	L	Sangisari	
sgs				I	L	Samogitian	
sgt				I	L	Brokpake	
sgu				I	L	Salas	
sgw				I	L	Sebat Bet Gurage	
sgx				I	L	Sierra Leone Sign Language	
sgy				I	L	Sanglechi	
sgz				I	L	Sursurunga	
sha				I	L	Shall-Zwall	
shb				I	L	Ninam	
shc				I	L	Sonde	
shd				I	L	Kundal Shahi	
she				I	L	Sheko	
shg				I	L	Shua	
shh				I	L	Shoshoni	
shi				I	L	Tachelhit	
shj				I	L	Shatt	
shk				I	L	Shilluk	
shl				I	L	Shendu	
shm				I	L	Shahrudi	
shn	shn	shn		I	L	Shan	
sho				I	L	Shanga	
shp				I	L	Shipibo-Conibo	
shq				I	L	Sala	
shr				I	L	Shi	
shs				I	L	Shuswap	
sht				I	E	Shasta	
shu				I	L	Chadian Arabic	
shv				I	L	Shehri	
shw				I	L	Shwai	
shx				I	L	She	
shy				I	L	Tachawit	
shz				I	L	Syenara Senoufo	
sia				I	E	Akkala Sami	
sib				I	L	Sebop	
sid	sid	sid		I	L	Sidamo	
sie				I	L	Simaa	
sif				I	L	Siamou	
sig				I	L	Paasaal	
sih				I	L	Zire	
sii				I	L	Shom Peng	
sij				I	L	Numbami	
sik				I	L	Sikiana	
sil				I	L	Tumulung Sisaala	
sim				I	L	Mende (Papua New Guinea)	
sin	sin	sin	si	I	L	Sinhala	
sip				I	L	Sikkimese	
siq				I	L	Sonia	
sir				I	L	Siri	
sis				I	E	Siuslaw	
siu				I	L	Sinagen	
siv				I	L	Sumariup	
siw				I	L	Siwai	
six				I	L	Sumau	
siy				I	L	Sivandi	
siz				I	L	Siwi	
sja				I	L	Epena	
sjb				I	L	Sajau Basap	
sjd				I	L	Kildin Sami	
sje				I	L	Pite Sami	
sjg				I	L	Assangori	
sjk				I	E	Kemi Sami	
sjl				I	L	Sajalong	
sjm				I	L	Mapun	
sjn				I	C	Sindarin	
sjo				I	L	Xibe	
sjp				I	L	Surjapuri	
sjr				I	L	Siar-Lak	
sjs				I	E	Senhaja De Srair	
sjt				I	L	Ter Sami	
sju				I	L	Ume Sami	
sjw				I	L	Shawnee	
ska				I	L	Skagit	
skb				I	L	Saek	
skc				I	L	Ma Manda	
skd				I	L	Southern Sierra Miwok	
ske				I	L	Seke (Vanuatu)	
skf				I	L	Sakirabiá	
skg				I	L	Sakalava Malagasy	
skh				I	L	Sikule	
ski				I	L	Sika	
skj				I	L	Seke (Nepal)	
skm				I	L	Kutong	
skn				I	L	Kolibugan Subanon	
sko				I	L	Seko Tengah	
skp				I	L	Sekapan	
skq				I	L	Sininkere	
skr				I	L	Saraiki	
sks				I	L	Maia	
skt				I	L	Sakata	
sku				I	L	Sakao	
skv				I	L	Skou	
skw				I	E	Skepi Creole Dutch	
skx				I	L	Seko Padang	
sky				I	L	Sikaiana	
skz				I	L	Sekar	
slc				I	L	Sáliba	
sld				I	L	Sissala	
sle				I	L	Sholaga	
slf				I	L	Swiss-Italian Sign Language	
slg				I	L	Selungai Murut	
slh				I	L	Southern Puget Sound Salish	
sli				I	L	Lower Silesian	
slj				I	L	Salumá	
slk	slo	slk	sk	I	L	Slovak	
sll				I	L	Salt-Yui	
slm				I	L	Pangutaran Sama	
sln				I	E	Salinan	
slp				I	L	Lamaholot	
slq				I	E	Salchuq	
slr				I	L	Salar	
sls				I	L	Singapore Sign Language	
slt				I	L	Sila	
slu				I	L	Selaru	
slv	slv	slv	sl	I	L	Slovenian	
slw				I	L	Sialum	
slx				I	L	Salampasu	
sly				I	L	Selayar	
slz				I	L	Ma'ya	
sma	sma	sma		I	L	Southern Sami	
smb				I	L	Simbari	
smc				I	E	Som	
smd				I	L	Sama	
sme	sme	sme	se	I	L	Northern Sami	
smf				I	L	Auwe	
smg				I	L	Simbali	
smh				I	L	Samei	
smj	smj	smj		I	L	Lule Sami	
smk				I	L	Bolinao	
sml				I	L	Central Sama	
smm				I	L	Musasa	
smn	smn	smn		I	L	Inari Sami	
smo	smo	smo	sm	I	L	Samoan	
smp				I	E	Samaritan	
smq				I	L	Samo	
smr				I	L	Simeulue	
sms	sms	sms		I	L	Skolt Sami	
smt				I	L	Simte	
smu				I	E	Somray	
smv				I	L	Samvedi	
smw				I	L	Sumbawa	
smx				I	L	Samba	
smy				I	L	Semnani	
smz				I	L	Simeku	
sna	sna	sna	sn	I	L	Shona	
snb				I	L	Sebuyau	
snc				I	L	Sinaugoro	
snd	snd	snd	sd	I	L	Sindhi	
sne				I	L	Bau Bidayuh	
snf				I	L	Noon	
sng				I	L	Sanga (Democratic Republic of Congo)	
sni				I	E	Sensi	
snj				I	L	Riverain Sango	
snk	snk	snk		I	L	Soninke	
snl				I	L	Sangil	
snm				I	L	Southern Ma'di	
snn				I	L	Siona	
sno				I	L	Snohomish	
snp				I	L	Siane	
snq				I	L	Sangu (Gabon)	
snr				I	L	Sihan	
sns				I	L	South West Bay	
snu				I	L	Senggi	
snv				I	L	Sa'ban	
snw				I	L	Selee	
snx				I	L	Sam	
sny				I	L	Saniyo-Hiyewe	
snz				I	L	Kou	
soa				I	L	Thai Song	
sob				I	L	Sobei	
soc				I	L	So (Democratic Republic of Congo)	
sod				I	L	Songoora	
soe				I	L	Songomeno	
sog	sog	sog		I	A	Sogdian	
soh				I	L	Aka	
soi				I	L	Sonha	
soj				I	L	Soi	
sok				I	L	Sokoro	
sol				I	L	Solos	
som	som	som	so	I	L	Somali	
soo				I	L	Songo	
sop				I	L	Songe	
soq				I	L	Kanasi	
sor				I	L	Somrai	
sos				I	L	Seeku	
sot	sot	sot	st	I	L	Southern Sotho	
sou				I	L	Southern Thai	
sov				I	L	Sonsorol	
sow				I	L	Sowanda	
sox				I	L	Swo	
soy				I	L	Miyobe	
soz				I	L	Temi	
spa	spa	spa	es	I	L	Spanish	
spb				I	L	Sepa (Indonesia)	
spc				I	L	Sapé	
spd				I	L	Saep	
spe				I	L	Sepa (Papua New Guinea)	
spg				I	L	Sian	
spi				I	L	Saponi	
spk				I	L	Sengo	
spl				I	L	Selepet	
spm				I	L	Akukem	
spn				I	L	Sanapaná	
spo				I	L	Spokane	
spp				I	L	Supyire Senoufo	
spq				I	L	Loreto-Ucayali Spanish	
spr				I	L	Saparua	
sps				I	L	Saposa	
spt				I	L	Spiti Bhoti	
spu				I	L	Sapuan	
spv				I	L	Sambalpuri	
spx				I	A	South Picene	
spy				I	L	Sabaot	
sqa				I	L	Shama-Sambuga	
sqh				I	L	Shau	
sqi	alb	sqi	sq	M	L	Albanian	
sqk				I	L	Albanian Sign Language	
sqm				I	L	Suma	
sqn				I	E	Susquehannock	
sqo				I	L	Sorkhei	
sqq				I	L	Sou	
sqr				I	H	Siculo Arabic	
sqs				I	L	Sri Lankan Sign Language	
sqt				I	L	Soqotri	
squ				I	L	Squamish	
sra				I	L	Saruga	
srb				I	L	Sora	
src				I	L	Logudorese Sardinian	
srd	srd	srd	sc	M	L	Sardinian	
sre				I	L	Sara	
srf				I	L	Nafi	
srg				I	L	Sulod	
srh				I	L	Sarikoli	
sri				I	L	Siriano	
srk				I	L	Serudung Murut	
srl				I	L	Isirawa	
srm				I	L	Saramaccan	
srn	srn	srn		I	L	Sranan Tongo	
sro				I	L	Campidanese Sardinian	
srp	srp	srp	sr	I	L	Serbian	
srq				I	L	Sirionó	
srr	srr	srr		I	L	Serer	
srs				I	L	Sarsi	
srt				I	L	Sauri	
sru				I	L	Suruí	
srv				I	L	Southern Sorsoganon	
srw				I	L	Serua	
srx				I	L	Sirmauri	
sry				I	L	Sera	
srz				I	L	Shahmirzadi	
ssb				I	L	Southern Sama	
ssc				I	L	Suba-Simbiti	
ssd				I	L	Siroi	
sse				I	L	Balangingi	
ssf				I	E	Thao	
ssg				I	L	Seimat	
ssh				I	L	Shihhi Arabic	
ssi				I	L	Sansi	
ssj				I	L	Sausi	
ssk				I	L	Sunam	
ssl				I	L	Western Sisaala	
ssm				I	L	Semnam	
ssn				I	L	Waata	
sso				I	L	Sissano	
ssp				I	L	Spanish Sign Language	
ssq				I	L	So'a	
ssr				I	L	Swiss-French Sign Language	
sss				I	L	Sô	
sst				I	L	Sinasina	
ssu				I	L	Susuami	
ssv				I	L	Shark Bay	
ssw	ssw	ssw	ss	I	L	Swati	
ssx				I	L	Samberigi	
ssy				I	L	Saho	
ssz				I	L	Sengseng	
sta				I	L	Settla	
stb				I	L	Northern Subanen	
std				I	L	Sentinel	
ste				I	L	Liana-Seti	
stf				I	L	Seta	
stg				I	L	Trieng	
sth				I	L	Shelta	
sti				I	L	Bulo Stieng	
stj				I	L	Matya Samo	
stk				I	L	Arammba	
stl				I	L	Stellingwerfs	
stm				I	L	Setaman	
stn				I	L	Owa	
sto				I	L	Stoney	
stp				I	L	Southeastern Tepehuan	
stq				I	L	Saterfriesisch	
str				I	L	Straits Salish	
sts				I	L	Shumashti	
stt				I	L	Budeh Stieng	
stu				I	L	Samtao	
stv				I	L	Silt'e	
stw				I	L	Satawalese	
sty				I	L	Siberian Tatar	
sua				I	L	Sulka	
sub				I	L	Suku	
suc				I	L	Western Subanon	
sue				I	L	Suena	
sug				I	L	Suganga	
sui				I	L	Suki	
suj				I	L	Shubi	
suk	suk	suk		I	L	Sukuma	
sun	sun	sun	su	I	L	Sundanese	
suq				I	L	Suri	
sur				I	L	Mwaghavul	
sus	sus	sus		I	L	Susu	
sut				I	E	Subtiaba	
suv				I	L	Puroik	
suw				I	L	Sumbwa	
sux	sux	sux		I	A	Sumerian	
suy				I	L	Suyá	
suz				I	L	Sunwar	
sva				I	L	Svan	
svb				I	L	Ulau-Suain	
svc				I	L	Vincentian Creole English	
sve				I	L	Serili	
svk				I	L	Slovakian Sign Language	
svm				I	L	Slavomolisano	
svs				I	L	Savosavo	
svx				I	H	Skalvian	
swa	swa	swa	sw	M	L	Swahili (macrolanguage)	
swb				I	L	Maore Comorian	
swc				I	L	Congo Swahili	
swe	swe	swe	sv	I	L	Swedish	
swf				I	L	Sere	
swg				I	L	Swabian	
swh				I	L	Swahili (individual language)	
swi				I	L	Sui	
swj				I	L	Sira	
swk				I	L	Malawi Sena	
swl				I	L	Swedish Sign Language	
swm				I	L	Samosa	
swn				I	L	Sawknah	
swo				I	L	Shanenawa	
swp				I	L	Suau	
swq				I	L	Sharwa	
swr				I	L	Saweru	
sws				I	L	Seluwasan	
swt				I	L	Sawila	
swu				I	L	Suwawa	
swv				I	L	Shekhawati	
sww				I	E	Sowa	
swx				I	L	Suruahá	
swy				I	L	Sarua	
sxb				I	L	Suba	
sxc				I	A	Sicanian	
sxe				I	L	Sighu	
sxg				I	L	Shuhi	
sxk				I	E	Southern Kalapuya	
sxl				I	E	Selian	
sxm				I	L	Samre	
sxn				I	L	Sangir	
sxo				I	A	Sorothaptic	
sxr				I	L	Saaroa	
sxs				I	L	Sasaru	
sxu				I	L	Upper Saxon	
sxw				I	L	Saxwe Gbe	
sya				I	L	Siang	
syb				I	L	Central Subanen	
syc	syc	syc		I	H	Classical Syriac	
syi				I	L	Seki	
syk				I	L	Sukur	
syl				I	L	Sylheti	
sym				I	L	Maya Samo	
syn				I	L	Senaya	
syo				I	L	Suoy	
syr	syr	syr		M	L	Syriac	
sys				I	L	Sinyar	
syw				I	L	Kagate	
syx				I	L	Samay	
syy				I	L	Al-Sayyid Bedouin Sign Language	
sza				I	L	Semelai	
szb				I	L	Ngalum	
szc				I	L	Semaq Beri	
szd				I	E	Seru	
sze				I	L	Seze	
szg				I	L	Sengele	
szl				I	L	Silesian	
szn				I	L	Sula	
szp				I	L	Suabo	
szs				I	L	Solomon Islands Sign Language	
szv				I	L	Isu (Fako Division)	
szw				I	L	Sawai	
szy				I	L	Sakizaya	
taa				I	L	Lower Tanana	
tab				I	L	Tabassaran	
tac				I	L	Lowland Tarahumara	
tad				I	L	Tause	
tae				I	L	Tariana	
taf				I	L	Tapirapé	
tag				I	L	Tagoi	
tah	tah	tah	ty	I	L	Tahitian	
taj				I	L	Eastern Tamang	
tak				I	L	Tala	
tal				I	L	Tal	
tam	tam	tam	ta	I	L	Tamil	
tan				I	L	Tangale	
tao				I	L	Yami	
tap				I	L	Taabwa	
taq				I	L	Tamasheq	
tar				I	L	Central Tarahumara	
tas				I	E	Tay Boi	
tat	tat	tat	tt	I	L	Tatar	
tau				I	L	Upper Tanana	
tav				I	L	Tatuyo	
taw				I	L	Tai	
tax				I	L	Tamki	
tay				I	L	Atayal	
taz				I	L	Tocho	
tba				I	L	Aikanã	
tbc				I	L	Takia	
tbd				I	L	Kaki Ae	
tbe				I	L	Tanimbili	
tbf				I	L	Mandara	
tbg				I	L	North Tairora	
tbh				I	E	Dharawal	
tbi				I	L	Gaam	
tbj				I	L	Tiang	
tbk				I	L	Calamian Tagbanwa	
tbl				I	L	Tboli	
tbm				I	L	Tagbu	
tbn				I	L	Barro Negro Tunebo	
tbo				I	L	Tawala	
tbp				I	L	Taworta	
tbr				I	L	Tumtum	
tbs				I	L	Tanguat	
tbt				I	L	Tembo (Kitembo)	
tbu				I	E	Tubar	
tbv				I	L	Tobo	
tbw				I	L	Tagbanwa	
tbx				I	L	Kapin	
tby				I	L	Tabaru	
tbz				I	L	Ditammari	
tca				I	L	Ticuna	
tcb				I	L	Tanacross	
tcc				I	L	Datooga	
tcd				I	L	Tafi	
tce				I	L	Southern Tutchone	
tcf				I	L	Malinaltepec Me'phaa	
tcg				I	L	Tamagario	
tch				I	L	Turks And Caicos Creole English	
tci				I	L	Wára	
tck				I	L	Tchitchege	
tcl				I	E	Taman (Myanmar)	
tcm				I	L	Tanahmerah	
tcn				I	L	Tichurong	
tco				I	L	Taungyo	
tcp				I	L	Tawr Chin	
tcq				I	L	Kaiy	
tcs				I	L	Torres Strait Creole	
tct				I	L	T'en	
tcu				I	L	Southeastern Tarahumara	
tcw				I	L	Tecpatlán Totonac	
tcx				I	L	Toda	
tcy				I	L	Tulu	
tcz				I	L	Thado Chin	
tda				I	L	Tagdal	
tdb				I	L	Panchpargania	
tdc				I	L	Emberá-Tadó	
tdd				I	L	Tai Nüa	
tde				I	L	Tiranige Diga Dogon	
tdf				I	L	Talieng	
tdg				I	L	Western Tamang	
tdh				I	L	Thulung	
tdi				I	L	Tomadino	
tdj				I	L	Tajio	
tdk				I	L	Tambas	
tdl				I	L	Sur	
tdm				I	L	Taruma	
tdn				I	L	Tondano	
tdo				I	L	Teme	
tdq				I	L	Tita	
tdr				I	L	Todrah	
tds				I	L	Doutai	
tdt				I	L	Tetun Dili	
tdv				I	L	Toro	
tdx				I	L	Tandroy-Mahafaly Malagasy	
tdy				I	L	Tadyawan	
tea				I	L	Temiar	
teb				I	E	Tetete	
tec				I	L	Terik	
ted				I	L	Tepo Krumen	
tee				I	L	Huehuetla Tepehua	
tef				I	L	Teressa	
teg				I	L	Teke-Tege	
teh				I	L	Tehuelche	
tei				I	L	Torricelli	
tek				I	L	Ibali Teke	
tel	tel	tel	te	I	L	Telugu	
tem	tem	tem		I	L	Timne	
ten				I	E	Tama (Colombia)	
teo				I	L	Teso	
tep				I	E	Tepecano	
teq				I	L	Temein	
ter	ter	ter		I	L	Tereno	
tes				I	L	Tengger	
tet	tet	tet		I	L	Tetum	
teu				I	L	Soo	
tev				I	L	Teor	
tew				I	L	Tewa (USA)	
tex				I	L	Tennet	
tey				I	L	Tulishi	
tez				I	L	Tetserret	
tfi				I	L	Tofin Gbe	
tfn				I	L	Tanaina	
tfo				I	L	Tefaro	
tfr				I	L	Teribe	
tft				I	L	Ternate	
tga				I	L	Sagalla	
tgb				I	L	Tobilung	
tgc				I	L	Tigak	
tgd				I	L	Ciwogai	
tge				I	L	Eastern Gorkha Tamang	
tgf				I	L	Chalikha	
tgh				I	L	Tobagonian Creole English	
tgi				I	L	Lawunuia	
tgj				I	L	Tagin	
tgk	tgk	tgk	tg	I	L	Tajik	
tgl	tgl	tgl	tl	I	L	Tagalog	
tgn				I	L	Tandaganon	
tgo				I	L	Sudest	
tgp				I	L	Tangoa	
tgq				I	L	Tring	
tgr				I	L	Tareng	
tgs				I	L	Nume	
tgt				I	L	Central Tagbanwa	
tgu				I	L	Tanggu	
tgv				I	E	Tingui-Boto	
tgw				I	L	Tagwana Senoufo	
tgx				I	L	Tagish	
tgy				I	E	Togoyo	
tgz				I	E	Tagalaka	
tha	tha	tha	th	I	L	Thai	
thd				I	L	Kuuk Thaayorre	
the				I	L	Chitwania Tharu	
thf				I	L	Thangmi	
thh				I	L	Northern Tarahumara	
thi				I	L	Tai Long	
thk				I	L	Tharaka	
thl				I	L	Dangaura Tharu	
thm				I	L	Aheu	
thn				I	L	Thachanadan	
thp				I	L	Thompson	
thq				I	L	Kochila Tharu	
thr				I	L	Rana Tharu	
ths				I	L	Thakali	
tht				I	L	Tahltan	
thu				I	L	Thuri	
thv				I	L	Tahaggart Tamahaq	
thw				I	L	Thudam	
thy				I	L	Tha	
thz				I	L	Tayart Tamajeq	
tia				I	L	Tidikelt Tamazight	
tic				I	L	Tira	
tif				I	L	Tifal	
tig	tig	tig		I	L	Tigre	
tih				I	L	Timugon Murut	
tii				I	L	Tiene	
tij				I	L	Tilung	
tik				I	L	Tikar	
til				I	E	Tillamook	
tim				I	L	Timbe	
tin				I	L	Tindi	
tio				I	L	Teop	
tip				I	L	Trimuris	
tiq				I	L	Tiéfo	
tir	tir	tir	ti	I	L	Tigrinya	
tis				I	L	Masadiit Itneg	
tit				I	L	Tinigua	
tiu				I	L	Adasen	
tiv	tiv	tiv		I	L	Tiv	
tiw				I	L	Tiwi	
tix				I	L	Southern Tiwa	
tiy				I	L	Tiruray	
tiz				I	L	Tai Hongjin	
tja				I	L	Tajuasohn	
tjg				I	L	Tunjung	
tji				I	L	Northern Tujia	
tjj				I	L	Tjungundji	
tjl				I	L	Tai Laing	
tjm				I	E	Timucua	
tjn				I	E	Tonjon	
tjo				I	L	Temacine Tamazight	
tjp				I	L	Tjupany	
tjs				I	L	Southern Tujia	
tju				I	E	Tjurruru	
tjw				I	L	Djabwurrung	
tka				I	E	Truká	
tkb				I	L	Buksa	
tkd				I	L	Tukudede	
tke				I	L	Takwane	
tkf				I	E	Tukumanféd	
tkg				I	L	Tesaka Malagasy	
tkl	tkl	tkl		I	L	Tokelau	
tkm				I	E	Takelma	
tkn				I	L	Toku-No-Shima	
tkp				I	L	Tikopia	
tkq				I	L	Tee	
tkr				I	L	Tsakhur	
tks				I	L	Takestani	
tkt				I	L	Kathoriya Tharu	
tku				I	L	Upper Necaxa Totonac	
tkv				I	L	Mur Pano	
tkw				I	L	Teanu	
tkx				I	L	Tangko	
tkz				I	L	Takua	
tla				I	L	Southwestern Tepehuan	
tlb				I	L	Tobelo	
tlc				I	L	Yecuatla Totonac	
tld				I	L	Talaud	
tlf				I	L	Telefol	
tlg				I	L	Tofanma	
tlh	tlh	tlh		I	C	Klingon	
tli	tli	tli		I	L	Tlingit	
tlj				I	L	Talinga-Bwisi	
tlk				I	L	Taloki	
tll				I	L	Tetela	
tlm				I	L	Tolomako	
tln				I	L	Talondo'	
tlo				I	L	Talodi	
tlp				I	L	Filomena Mata-Coahuitlán Totonac	
tlq				I	L	Tai Loi	
tlr				I	L	Talise	
tls				I	L	Tambotalo	
tlt				I	L	Sou Nama	
tlu				I	L	Tulehu	
tlv				I	L	Taliabu	
tlx				I	L	Khehek	
tly				I	L	Talysh	
tma				I	L	Tama (Chad)	
tmb				I	L	Katbol	
tmc				I	L	Tumak	
tmd				I	L	Haruai	
tme				I	E	Tremembé	
tmf				I	L	Toba-Maskoy	
tmg				I	E	Ternateño	
tmh	tmh	tmh		M	L	Tamashek	
tmi				I	L	Tutuba	
tmj				I	L	Samarokena	
tmk				I	L	Northwestern Tamang	
tml				I	L	Tamnim Citak	
tmm				I	L	Tai Thanh	
tmn				I	L	Taman (Indonesia)	
tmo				I	L	Temoq	
tmq				I	L	Tumleo	
tmr				I	E	Jewish Babylonian Aramaic (ca. 200-1200 CE)	
tms				I	L	Tima	
tmt				I	L	Tasmate	
tmu				I	L	Iau	
tmv				I	L	Tembo (Motembo)	
tmw				I	L	Temuan	
tmy				I	L	Tami	
tmz				I	E	Tamanaku	
tna				I	L	Tacana	
tnb				I	L	Western Tunebo	
tnc				I	L	Tanimuca-Retuarã	
tnd				I	L	Angosturas Tunebo	
tng				I	L	Tobanga	
tnh				I	L	Maiani	
tni				I	L	Tandia	
tnk				I	L	Kwamera	
tnl				I	L	Lenakel	
tnm				I	L	Tabla	
tnn				I	L	North Tanna	
tno				I	L	Toromono	
tnp				I	L	Whitesands	
tnq				I	E	Taino	
tnr				I	L	Ménik	
tns				I	L	Tenis	
tnt				I	L	Tontemboan	
tnu				I	L	Tay Khang	
tnv				I	L	Tangchangya	
tnw				I	L	Tonsawang	
tnx				I	L	Tanema	
tny				I	L	Tongwe	
tnz				I	L	Ten'edn	
tob				I	L	Toba	
toc				I	L	Coyutla Totonac	
tod				I	L	Toma	
tof				I	L	Gizrra	
tog	tog	tog		I	L	Tonga (Nyasa)	
toh				I	L	Gitonga	
toi				I	L	Tonga (Zambia)	
toj				I	L	Tojolabal	
tol				I	E	Tolowa	
tom				I	L	Tombulu	
ton	ton	ton	to	I	L	Tonga (Tonga Islands)	
too				I	L	Xicotepec De Juárez Totonac	
top				I	L	Papantla Totonac	
toq				I	L	Toposa	
tor				I	L	Togbo-Vara Banda	
tos				I	L	Highland Totonac	
tou				I	L	Tho	
tov				I	L	Upper Taromi	
tow				I	L	Jemez	
tox				I	L	Tobian	
toy				I	L	Topoiyo	
toz				I	L	To	
tpa				I	L	Taupota	
tpc				I	L	Azoyú Me'phaa	
tpe				I	L	Tippera	
tpf				I	L	Tarpia	
tpg				I	L	Kula	
tpi	tpi	tpi		I	L	Tok Pisin	
tpj				I	L	Tapieté	
tpk				I	E	Tupinikin	
tpl				I	L	Tlacoapa Me'phaa	
tpm				I	L	Tampulma	
tpn				I	E	Tupinambá	
tpo				I	L	Tai Pao	
tpp				I	L	Pisaflores Tepehua	
tpq				I	L	Tukpa	
tpr				I	L	Tuparí	
tpt				I	L	Tlachichilco Tepehua	
tpu				I	L	Tampuan	
tpv				I	L	Tanapag	
tpw				I	E	Tupí	
tpx				I	L	Acatepec Me'phaa	
tpy				I	L	Trumai	
tpz				I	L	Tinputz	
tqb				I	L	Tembé	
tql				I	L	Lehali	
tqm				I	L	Turumsa	
tqn				I	L	Tenino	
tqo				I	L	Toaripi	
tqp				I	L	Tomoip	
tqq				I	L	Tunni	
tqr				I	E	Torona	
tqt				I	L	Western Totonac	
tqu				I	L	Touo	
tqw				I	E	Tonkawa	
tra				I	L	Tirahi	
trb				I	L	Terebu	
trc				I	L	Copala Triqui	
trd				I	L	Turi	
tre				I	L	East Tarangan	
trf				I	L	Trinidadian Creole English	
trg				I	L	Lishán Didán	
trh				I	L	Turaka	
tri				I	L	Trió	
trj				I	L	Toram	
trl				I	L	Traveller Scottish	
trm				I	L	Tregami	
trn				I	L	Trinitario	
tro				I	L	Tarao Naga	
trp				I	L	Kok Borok	
trq				I	L	San Martín Itunyoso Triqui	
trr				I	L	Taushiro	
trs				I	L	Chicahuaxtla Triqui	
trt				I	L	Tunggare	
tru				I	L	Turoyo	
trv				I	L	Taroko	
trw				I	L	Torwali	
trx				I	L	Tringgus-Sembaan Bidayuh	
try				I	E	Turung	
trz				I	E	Torá	
tsa				I	L	Tsaangi	
tsb				I	L	Tsamai	
tsc				I	L	Tswa	
tsd				I	L	Tsakonian	
tse				I	L	Tunisian Sign Language	
tsg				I	L	Tausug	
tsh				I	L	Tsuvan	
tsi	tsi	tsi		I	L	Tsimshian	
tsj				I	L	Tshangla	
tsk				I	L	Tseku	
tsl				I	L	Ts'ün-Lao	
tsm				I	L	Turkish Sign Language	
tsn	tsn	tsn	tn	I	L	Tswana	
tso	tso	tso	ts	I	L	Tsonga	
tsp				I	L	Northern Toussian	
tsq				I	L	Thai Sign Language	
tsr				I	L	Akei	
tss				I	L	Taiwan Sign Language	
tst				I	L	Tondi Songway Kiini	
tsu				I	L	Tsou	
tsv				I	L	Tsogo	
tsw				I	L	Tsishingini	
tsx				I	L	Mubami	
tsy				I	L	Tebul Sign Language	
tsz				I	L	Purepecha	
tta				I	E	Tutelo	
ttb				I	L	Gaa	
ttc				I	L	Tektiteko	
ttd				I	L	Tauade	
tte				I	L	Bwanabwana	
ttf				I	L	Tuotomb	
ttg				I	L	Tutong	
tth				I	L	Upper Ta'oih	
tti				I	L	Tobati	
ttj				I	L	Tooro	
ttk				I	L	Totoro	
ttl				I	L	Totela	
ttm				I	L	Northern Tutchone	
ttn				I	L	Towei	
tto				I	L	Lower Ta'oih	
ttp				I	L	Tombelala	
ttq				I	L	Tawallammat Tamajaq	
ttr				I	L	Tera	
tts				I	L	Northeastern Thai	
ttt				I	L	Muslim Tat	
ttu				I	L	Torau	
ttv				I	L	Titan	
ttw				I	L	Long Wat	
tty				I	L	Sikaritai	
ttz				I	L	Tsum	
tua				I	L	Wiarumus	
tub				I	E	Tübatulabal	
tuc				I	L	Mutu	
tud				I	E	Tuxá	
tue				I	L	Tuyuca	
tuf				I	L	Central Tunebo	
tug				I	L	Tunia	
tuh				I	L	Taulil	
tui				I	L	Tupuri	
tuj				I	L	Tugutil	
tuk	tuk	tuk	tk	I	L	Turkmen	
tul				I	L	Tula	
tum	tum	tum		I	L	Tumbuka	
tun				I	L	Tunica	
tuo				I	L	Tucano	
tuq				I	L	Tedaga	
tur	tur	tur	tr	I	L	Turkish	
tus				I	L	Tuscarora	
tuu				I	L	Tututni	
tuv				I	L	Turkana	
tux				I	E	Tuxináwa	
tuy				I	L	Tugen	
tuz				I	L	Turka	
tva				I	L	Vaghua	
tvd				I	L	Tsuvadi	
tve				I	L	Te'un	
tvk				I	L	Southeast Ambrym	
tvl	tvl	tvl		I	L	Tuvalu	
tvm				I	L	Tela-Masbuar	
tvn				I	L	Tavoyan	
tvo				I	L	Tidore	
tvs				I	L	Taveta	
tvt				I	L	Tutsa Naga	
tvu				I	L	Tunen	
tvw				I	L	Sedoa	
tvx				I	E	Taivoan	
tvy				I	E	Timor Pidgin	
twa				I	E	Twana	
twb				I	L	Western Tawbuid	
twc				I	E	Teshenawa	
twd				I	L	Twents	
twe				I	L	Tewa (Indonesia)	
twf				I	L	Northern Tiwa	
twg				I	L	Tereweng	
twh				I	L	Tai Dón	
twi	twi	twi	tw	I	L	Twi	
twl				I	L	Tawara	
twm				I	L	Tawang Monpa	
twn				I	L	Twendi	
two				I	L	Tswapong	
twp				I	L	Ere	
twq				I	L	Tasawaq	
twr				I	L	Southwestern Tarahumara	
twt				I	E	Turiwára	
twu				I	L	Termanu	
tww				I	L	Tuwari	
twx				I	L	Tewe	
twy				I	L	Tawoyan	
txa				I	L	Tombonuo	
txb				I	A	Tokharian B	
txc				I	E	Tsetsaut	
txe				I	L	Totoli	
txg				I	A	Tangut	
txh				I	A	Thracian	
txi				I	L	Ikpeng	
txj				I	L	Tarjumo	
txm				I	L	Tomini	
txn				I	L	West Tarangan	
txo				I	L	Toto	
txq				I	L	Tii	
txr				I	A	Tartessian	
txs				I	L	Tonsea	
txt				I	L	Citak	
txu				I	L	Kayapó	
txx				I	L	Tatana	
txy				I	L	Tanosy Malagasy	
tya				I	L	Tauya	
tye				I	L	Kyanga	
tyh				I	L	O'du	
tyi				I	L	Teke-Tsaayi	
tyj				I	L	Tai Do	
tyl				I	L	Thu Lao	
tyn				I	L	Kombai	
typ				I	E	Thaypan	
tyr				I	L	Tai Daeng	
tys				I	L	Tày Sa Pa	
tyt				I	L	Tày Tac	
tyu				I	L	Kua	
tyv	tyv	tyv		I	L	Tuvinian	
tyx				I	L	Teke-Tyee	
tyz				I	L	Tày	
tza				I	L	Tanzanian Sign Language	
tzh				I	L	Tzeltal	
tzj				I	L	Tz'utujil	
tzl				I	C	Talossan	
tzm				I	L	Central Atlas Tamazight	
tzn				I	L	Tugun	
tzo				I	L	Tzotzil	
tzx				I	L	Tabriak	
uam				I	E	Uamué	
uan				I	L	Kuan	
uar				I	L	Tairuma	
uba				I	L	Ubang	
ubi				I	L	Ubi	
ubl				I	L	Buhi'non Bikol	
ubr				I	L	Ubir	
ubu				I	L	Umbu-Ungu	
uby				I	E	Ubykh	
uda				I	L	Uda	
ude				I	L	Udihe	
udg				I	L	Muduga	
udi				I	L	Udi	
udj				I	L	Ujir	
udl				I	L	Wuzlam	
udm	udm	udm		I	L	Udmurt	
udu				I	L	Uduk	
ues				I	L	Kioko	
ufi				I	L	Ufim	
uga	uga	uga		I	A	Ugaritic	
ugb				I	E	Kuku-Ugbanh	
uge				I	L	Ughele	
ugn				I	L	Ugandan Sign Language	
ugo				I	L	Ugong	
ugy				I	L	Uruguayan Sign Language	
uha				I	L	Uhami	
uhn				I	L	Damal	
uig	uig	uig	ug	I	L	Uighur	
uis				I	L	Uisai	
uiv				I	L	Iyive	
uji				I	L	Tanjijili	
uka				I	L	Kaburi	
ukg				I	L	Ukuriguma	
ukh				I	L	Ukhwejo	
uki				I	L	Kui (India)	
ukk				I	L	Muak Sa-aak	
ukl				I	L	Ukrainian Sign Language	
ukp				I	L	Ukpe-Bayobiri	
ukq				I	L	Ukwa	
ukr	ukr	ukr	uk	I	L	Ukrainian	
uks				I	L	Urubú-Kaapor Sign Language	
uku				I	L	Ukue	
ukv				I	L	Kuku	
ukw				I	L	Ukwuani-Aboh-Ndoni	
uky				I	E	Kuuk-Yak	
ula				I	L	Fungwa	
ulb				I	L	Ulukwumi	
ulc				I	L	Ulch	
ule				I	E	Lule	
ulf				I	L	Usku	
uli				I	L	Ulithian	
ulk				I	L	Meriam Mir	
ull				I	L	Ullatan	
ulm				I	L	Ulumanda'	
uln				I	L	Unserdeutsch	
ulu				I	L	Uma' Lung	
ulw				I	L	Ulwa	
uma				I	L	Umatilla	
umb	umb	umb		I	L	Umbundu	
umc				I	A	Marrucinian	
umd				I	E	Umbindhamu	
umg				I	E	Morrobalama	
umi				I	L	Ukit	
umm				I	L	Umon	
umn				I	L	Makyan Naga	
umo				I	E	Umotína	
ump				I	L	Umpila	
umr				I	E	Umbugarla	
ums				I	L	Pendau	
umu				I	L	Munsee	
una				I	L	North Watut	
und	und	und		S	S	Undetermined	
une				I	L	Uneme	
ung				I	L	Ngarinyin	
unk				I	L	Enawené-Nawé	
unm				I	E	Unami	
unn				I	L	Kurnai	
unr				I	L	Mundari	
unu				I	L	Unubahe	
unx				I	L	Munda	
unz				I	L	Unde Kaili	
upi				I	L	Umeda	
upv				I	L	Uripiv-Wala-Rano-Atchin	
ura				I	L	Urarina	
urb				I	L	Urubú-Kaapor	
urc				I	E	Urningangg	
urd	urd	urd	ur	I	L	Urdu	
ure				I	L	Uru	
urf				I	E	Uradhi	
urg				I	L	Urigina	
urh				I	L	Urhobo	
uri				I	L	Urim	
urk				I	L	Urak Lawoi'	
url				I	L	Urali	
urm				I	L	Urapmin	
urn				I	L	Uruangnirin	
uro				I	L	Ura (Papua New Guinea)	
urp				I	L	Uru-Pa-In	
urr				I	L	Lehalurup	
urt				I	L	Urat	
uru				I	E	Urumi	
urv				I	E	Uruava	
urw				I	L	Sop	
urx				I	L	Urimo	
ury				I	L	Orya	
urz				I	L	Uru-Eu-Wau-Wau	
usa				I	L	Usarufa	
ush				I	L	Ushojo	
usi				I	L	Usui	
usk				I	L	Usaghade	
usp				I	L	Uspanteco	
uss				I	L	us-Saare	
usu				I	L	Uya	
uta				I	L	Otank	
ute				I	L	Ute-Southern Paiute	
uth				I	L	ut-Hun	
utp				I	L	Amba (Solomon Islands)	
utr				I	L	Etulo	
utu				I	L	Utu	
uum				I	L	Urum	
uun				I	L	Kulon-Pazeh	
uur				I	L	Ura (Vanuatu)	
uuu				I	L	U	
uve				I	L	West Uvean	
uvh				I	L	Uri	
uvl				I	L	Lote	
uwa				I	L	Kuku-Uwanh	
uya				I	L	Doko-Uyanga	
uzb	uzb	uzb	uz	M	L	Uzbek	
uzn				I	L	Northern Uzbek	
uzs				I	L	Southern Uzbek	
vaa				I	L	Vaagri Booli	
vae				I	L	Vale	
vaf				I	L	Vafsi	
vag				I	L	Vagla	
vah				I	L	Varhadi-Nagpuri	
vai	vai	vai		I	L	Vai	
vaj				I	L	Sekele	
val				I	L	Vehes	
vam				I	L	Vanimo	
van				I	L	Valman	
vao				I	L	Vao	
vap				I	L	Vaiphei	
var				I	L	Huarijio	
vas				I	L	Vasavi	
vau				I	L	Vanuma	
vav				I	L	Varli	
vay				I	L	Wayu	
vbb				I	L	Southeast Babar	
vbk				I	L	Southwestern Bontok	
vec				I	L	Venetian	
ved				I	L	Veddah	
vel				I	L	Veluws	
vem				I	L	Vemgo-Mabas	
ven	ven	ven	ve	I	L	Venda	
veo				I	E	Ventureño	
vep				I	L	Veps	
ver				I	L	Mom Jango	
vgr				I	L	Vaghri	
vgt				I	L	Vlaamse Gebarentaal	
vic				I	L	Virgin Islands Creole English	
vid				I	L	Vidunda	
vie	vie	vie	vi	I	L	Vietnamese	
vif				I	L	Vili	
vig				I	L	Viemo	
vil				I	L	Vilela	
vin				I	L	Vinza	
vis				I	L	Vishavan	
vit				I	L	Viti	
viv				I	L	Iduna	
vka				I	E	Kariyarra	
vki				I	L	Ija-Zuba	
vkj				I	L	Kujarge	
vkk				I	L	Kaur	
vkl				I	L	Kulisusu	
vkm				I	E	Kamakan	
vko				I	L	Kodeoha	
vkp				I	L	Korlai Creole Portuguese	
vkt				I	L	Tenggarong Kutai Malay	
vku				I	L	Kurrama	
vlp				I	L	Valpei	
vls				I	L	Vlaams	
vma				I	L	Martuyhunira	
vmb				I	E	Barbaram	
vmc				I	L	Juxtlahuaca Mixtec	
vmd				I	L	Mudu Koraga	
vme				I	L	East Masela	
vmf				I	L	Mainfränkisch	
vmg				I	L	Lungalunga	
vmh				I	L	Maraghei	
vmi				I	E	Miwa	
vmj				I	L	Ixtayutla Mixtec	
vmk				I	L	Makhuwa-Shirima	
vml				I	E	Malgana	
vmm				I	L	Mitlatongo Mixtec	
vmp				I	L	Soyaltepec Mazatec	
vmq				I	L	Soyaltepec Mixtec	
vmr				I	L	Marenje	
vms				I	E	Moksela	
vmu				I	E	Muluridyi	
vmv				I	E	Valley Maidu	
vmw				I	L	Makhuwa	
vmx				I	L	Tamazola Mixtec	
vmy				I	L	Ayautla Mazatec	
vmz				I	L	Mazatlán Mazatec	
vnk				I	L	Vano	
vnm				I	L	Vinmavis	
vnp				I	L	Vunapu	
vol	vol	vol	vo	I	C	Volapük	
vor				I	L	Voro	
vot	vot	vot		I	L	Votic	
vra				I	L	Vera'a	
vro				I	L	Võro	
vrs				I	L	Varisi	
vrt				I	L	Burmbar	
vsi				I	L	Moldova Sign Language	
vsl				I	L	Venezuelan Sign Language	
vsv				I	L	Valencian Sign Language	
vto				I	L	Vitou	
vum				I	L	Vumbu	
vun				I	L	Vunjo	
vut				I	L	Vute	
vwa				I	L	Awa (China)	
waa				I	L	Walla Walla	
wab				I	L	Wab	
wac				I	E	Wasco-Wishram	
wad				I	L	Wandamen	
wae				I	L	Walser	
waf				I	E	Wakoná	
wag				I	L	Wa'ema	
wah				I	L	Watubela	
wai				I	L	Wares	
waj				I	L	Waffa	
wal	wal	wal		I	L	Wolaytta	
wam				I	E	Wampanoag	
wan				I	L	Wan	
wao				I	E	Wappo	
wap				I	L	Wapishana	
waq				I	L	Wagiman	
war	war	war		I	L	Waray (Philippines)	
was	was	was		I	L	Washo	
wat				I	L	Kaninuwa	
wau				I	L	Waurá	
wav				I	L	Waka	
waw				I	L	Waiwai	
wax				I	L	Watam	
way				I	L	Wayana	
waz				I	L	Wampur	
wba				I	L	Warao	
wbb				I	L	Wabo	
wbe				I	L	Waritai	
wbf				I	L	Wara	
wbh				I	L	Wanda	
wbi				I	L	Vwanji	
wbj				I	L	Alagwa	
wbk				I	L	Waigali	
wbl				I	L	Wakhi	
wbm				I	L	Wa	
wbp				I	L	Warlpiri	
wbq				I	L	Waddar	
wbr				I	L	Wagdi	
wbs				I	L	West Bengal Sign Language	
wbt				I	L	Warnman	
wbv				I	L	Wajarri	
wbw				I	L	Woi	
wca				I	L	Yanomámi	
wci				I	L	Waci Gbe	
wdd				I	L	Wandji	
wdg				I	L	Wadaginam	
wdj				I	L	Wadjiginy	
wdk				I	E	Wadikali	
wdu				I	E	Wadjigu	
wdy				I	E	Wadjabangayi	
wea				I	E	Wewaw	
wec				I	L	Wè Western	
wed				I	L	Wedau	
weg				I	L	Wergaia	
weh				I	L	Weh	
wei				I	L	Kiunum	
wem				I	L	Weme Gbe	
weo				I	L	Wemale	
wep				I	L	Westphalien	
wer				I	L	Weri	
wes				I	L	Cameroon Pidgin	
wet				I	L	Perai	
weu				I	L	Rawngtu Chin	
wew				I	L	Wejewa	
wfg				I	L	Yafi	
wga				I	E	Wagaya	
wgb				I	L	Wagawaga	
wgg				I	E	Wangkangurru	
wgi				I	L	Wahgi	
wgo				I	L	Waigeo	
wgu				I	E	Wirangu	
wgy				I	L	Warrgamay	
wha				I	L	Sou Upaa	
whg				I	L	North Wahgi	
whk				I	L	Wahau Kenyah	
whu				I	L	Wahau Kayan	
wib				I	L	Southern Toussian	
wic				I	E	Wichita	
wie				I	E	Wik-Epa	
wif				I	E	Wik-Keyangan	
wig				I	L	Wik Ngathan	
wih				I	L	Wik-Me'anha	
wii				I	L	Minidien	
wij				I	L	Wik-Iiyanh	
wik				I	L	Wikalkan	
wil				I	E	Wilawila	
wim				I	L	Wik-Mungkan	
win				I	L	Ho-Chunk	
wir				I	E	Wiraféd	
wiu				I	L	Wiru	
wiv				I	L	Vitu	
wiy				I	E	Wiyot	
wja				I	L	Waja	
wji				I	L	Warji	
wka				I	E	Kw'adza	
wkb				I	L	Kumbaran	
wkd				I	L	Wakde	
wkl				I	L	Kalanadi	
wkr				I	L	Keerray-Woorroong	
wku				I	L	Kunduvadi	
wkw				I	E	Wakawaka	
wky				I	E	Wangkayutyuru	
wla				I	L	Walio	
wlc				I	L	Mwali Comorian	
wle				I	L	Wolane	
wlg				I	L	Kunbarlang	
wlh				I	L	Welaun	
wli				I	L	Waioli	
wlk				I	E	Wailaki	
wll				I	L	Wali (Sudan)	
wlm				I	H	Middle Welsh	
wln	wln	wln	wa	I	L	Walloon	
wlo				I	L	Wolio	
wlr				I	L	Wailapa	
wls				I	L	Wallisian	
wlu				I	E	Wuliwuli	
wlv				I	L	Wichí Lhamtés Vejoz	
wlw				I	L	Walak	
wlx				I	L	Wali (Ghana)	
wly				I	E	Waling	
wma				I	E	Mawa (Nigeria)	
wmb				I	L	Wambaya	
wmc				I	L	Wamas	
wmd				I	L	Mamaindé	
wme				I	L	Wambule	
wmh				I	L	Waima'a	
wmi				I	E	Wamin	
wmm				I	L	Maiwa (Indonesia)	
wmn				I	E	Waamwang	
wmo				I	L	Wom (Papua New Guinea)	
wms				I	L	Wambon	
wmt				I	L	Walmajarri	
wmw				I	L	Mwani	
wmx				I	L	Womo	
wnb				I	L	Wanambre	
wnc				I	L	Wantoat	
wnd				I	E	Wandarang	
wne				I	L	Waneci	
wng				I	L	Wanggom	
wni				I	L	Ndzwani Comorian	
wnk				I	L	Wanukaka	
wnm				I	E	Wanggamala	
wnn				I	E	Wunumara	
wno				I	L	Wano	
wnp				I	L	Wanap	
wnu				I	L	Usan	
wnw				I	L	Wintu	
wny				I	L	Wanyi	
woa				I	L	Kuwema	
wob				I	L	Wè Northern	
woc				I	L	Wogeo	
wod				I	L	Wolani	
woe				I	L	Woleaian	
wof				I	L	Gambian Wolof	
wog				I	L	Wogamusin	
woi				I	L	Kamang	
wok				I	L	Longto	
wol	wol	wol	wo	I	L	Wolof	
wom				I	L	Wom (Nigeria)	
won				I	L	Wongo	
woo				I	L	Manombai	
wor				I	L	Woria	
wos				I	L	Hanga Hundi	
wow				I	L	Wawonii	
woy				I	E	Weyto	
wpc				I	L	Maco	
wra				I	L	Warapu	
wrb				I	E	Waluwarra	
wrd				I	L	Warduji	
wrg				I	E	Warungu	
wrh				I	E	Wiradjuri	
wri				I	E	Wariyangga	
wrk				I	L	Garrwa	
wrl				I	L	Warlmanpa	
wrm				I	L	Warumungu	
wrn				I	L	Warnang	
wro				I	E	Worrorra	
wrp				I	L	Waropen	
wrr				I	L	Wardaman	
wrs				I	L	Waris	
wru				I	L	Waru	
wrv				I	L	Waruna	
wrw				I	E	Gugu Warra	
wrx				I	L	Wae Rana	
wry				I	L	Merwari	
wrz				I	E	Waray (Australia)	
wsa				I	L	Warembori	
wsg				I	L	Adilabad Gondi	
wsi				I	L	Wusi	
wsk				I	L	Waskia	
wsr				I	L	Owenia	
wss				I	L	Wasa	
wsu				I	E	Wasu	
wsv				I	E	Wotapuri-Katarqalai	
wtf				I	L	Watiwa	
wth				I	E	Wathawurrung	
wti				I	L	Berta	
wtk				I	L	Watakataui	
wtm				I	L	Mewati	
wtw				I	L	Wotu	
wua				I	L	Wikngenchera	
wub				I	L	Wunambal	
wud				I	L	Wudu	
wuh				I	L	Wutunhua	
wul				I	L	Silimo	
wum				I	L	Wumbvu	
wun				I	L	Bungu	
wur				I	E	Wurrugu	
wut				I	L	Wutung	
wuu				I	L	Wu Chinese	
wuv				I	L	Wuvulu-Aua	
wux				I	L	Wulna	
wuy				I	L	Wauyai	
wwa				I	L	Waama	
wwb				I	E	Wakabunga	
wwo				I	L	Wetamut	
wwr				I	E	Warrwa	
www				I	L	Wawa	
wxa				I	L	Waxianghua	
wxw				I	E	Wardandi	
wya				I	L	Wyandot	
wyb				I	L	Wangaaybuwan-Ngiyambaa	
wyi				I	E	Woiwurrung	
wym				I	L	Wymysorys	
wyr				I	L	Wayoró	
wyy				I	L	Western Fijian	
xaa				I	H	Andalusian Arabic	
xab				I	L	Sambe	
xac				I	L	Kachari	
xad				I	E	Adai	
xae				I	A	Aequian	
xag				I	A	Aghwan	
xai				I	E	Kaimbé	
xaj				I	E	Ararandewára	
xak				I	E	Máku	
xal	xal	xal		I	L	Kalmyk	
xam				I	E	ǀXam	
xan				I	L	Xamtanga	
xao				I	L	Khao	
xap				I	E	Apalachee	
xaq				I	A	Aquitanian	
xar				I	E	Karami	
xas				I	E	Kamas	
xat				I	L	Katawixi	
xau				I	L	Kauwera	
xav				I	L	Xavánte	
xaw				I	L	Kawaiisu	
xay				I	L	Kayan Mahakam	
xbb				I	E	Lower Burdekin	
xbc				I	A	Bactrian	
xbd				I	E	Bindal	
xbe				I	E	Bigambal	
xbg				I	E	Bunganditj	
xbi				I	L	Kombio	
xbj				I	E	Birrpayi	
xbm				I	H	Middle Breton	
xbn				I	E	Kenaboi	
xbo				I	H	Bolgarian	
xbp				I	E	Bibbulman	
xbr				I	L	Kambera	
xbw				I	E	Kambiwá	
xby				I	L	Batjala	
xcb				I	H	Cumbric	
xcc				I	A	Camunic	
xce				I	A	Celtiberian	
xcg				I	A	Cisalpine Gaulish	
xch				I	E	Chemakum	
xcl				I	H	Classical Armenian	
xcm				I	E	Comecrudo	
xcn				I	E	Cotoname	
xco				I	A	Chorasmian	
xcr				I	A	Carian	
xct				I	H	Classical Tibetan	
xcu				I	H	Curonian	
xcv				I	E	Chuvantsy	
xcw				I	E	Coahuilteco	
xcy				I	E	Cayuse	
xda				I	L	Darkinyung	
xdc				I	A	Dacian	
xdk				I	E	Dharuk	
xdm				I	A	Edomite	
xdo				I	L	Kwandu	
xdy				I	L	Malayic Dayak	
xeb				I	A	Eblan	
xed				I	L	Hdi	
xeg				I	E	ǁXegwi	
xel				I	L	Kelo	
xem				I	L	Kembayan	
xep				I	A	Epi-Olmec	
xer				I	L	Xerénte	
xes				I	L	Kesawai	
xet				I	L	Xetá	
xeu				I	L	Keoru-Ahia	
xfa				I	A	Faliscan	
xga				I	A	Galatian	
xgb				I	E	Gbin	
xgd				I	E	Gudang	
xgf				I	E	Gabrielino-Fernandeño	
xgg				I	E	Goreng	
xgi				I	E	Garingbal	
xgl				I	H	Galindan	
xgm				I	E	Dharumbal	
xgr				I	E	Garza	
xgu				I	L	Unggumi	
xgw				I	E	Guwa	
xha				I	A	Harami	
xhc				I	A	Hunnic	
xhd				I	A	Hadrami	
xhe				I	L	Khetrani	
xho	xho	xho	xh	I	L	Xhosa	
xhr				I	A	Hernican	
xht				I	A	Hattic	
xhu				I	A	Hurrian	
xhv				I	L	Khua	
xib				I	A	Iberian	
xii				I	L	Xiri	
xil				I	A	Illyrian	
xin				I	E	Xinca	
xir				I	E	Xiriâna	
xis				I	L	Kisan	
xiv				I	A	Indus Valley Language	
xiy				I	L	Xipaya	
xjb				I	E	Minjungbal	
xjt				I	E	Jaitmatang	
xka				I	L	Kalkoti	
xkb				I	L	Northern Nago	
xkc				I	L	Kho'ini	
xkd				I	L	Mendalam Kayan	
xke				I	L	Kereho	
xkf				I	L	Khengkha	
xkg				I	L	Kagoro	
xki				I	L	Kenyan Sign Language	
xkj				I	L	Kajali	
xkk				I	L	Kaco'	
xkl				I	L	Mainstream Kenyah	
xkn				I	L	Kayan River Kayan	
xko				I	L	Kiorr	
xkp				I	L	Kabatei	
xkq				I	L	Koroni	
xkr				I	E	Xakriabá	
xks				I	L	Kumbewaha	
xkt				I	L	Kantosi	
xku				I	L	Kaamba	
xkv				I	L	Kgalagadi	
xkw				I	L	Kembra	
xkx				I	L	Karore	
xky				I	L	Uma' Lasan	
xkz				I	L	Kurtokha	
xla				I	L	Kamula	
xlb				I	E	Loup B	
xlc				I	A	Lycian	
xld				I	A	Lydian	
xle				I	A	Lemnian	
xlg				I	A	Ligurian (Ancient)	
xli				I	A	Liburnian	
xln				I	A	Alanic	
xlo				I	E	Loup A	
xlp				I	A	Lepontic	
xls				I	A	Lusitanian	
xlu				I	A	Cuneiform Luwian	
xly				I	A	Elymian	
xma				I	L	Mushungulu	
xmb				I	L	Mbonga	
xmc				I	L	Makhuwa-Marrevone	
xmd				I	L	Mbudum	
xme				I	A	Median	
xmf				I	L	Mingrelian	
xmg				I	L	Mengaka	
xmh				I	L	Kugu-Muminh	
xmj				I	L	Majera	
xmk				I	A	Ancient Macedonian	
xml				I	L	Malaysian Sign Language	
xmm				I	L	Manado Malay	
xmn				I	H	Manichaean Middle Persian	
xmo				I	L	Morerebi	
xmp				I	E	Kuku-Mu'inh	
xmq				I	E	Kuku-Mangk	
xmr				I	A	Meroitic	
xms				I	L	Moroccan Sign Language	
xmt				I	L	Matbat	
xmu				I	E	Kamu	
xmv				I	L	Antankarana Malagasy	
xmw				I	L	Tsimihety Malagasy	
xmx				I	L	Maden	
xmy				I	L	Mayaguduna	
xmz				I	L	Mori Bawah	
xna				I	A	Ancient North Arabian	
xnb				I	L	Kanakanabu	
xng				I	H	Middle Mongolian	
xnh				I	L	Kuanhua	
xni				I	E	Ngarigu	
xnk				I	E	Nganakarti	
xnm				I	E	Ngumbarl	
xnn				I	L	Northern Kankanay	
xno				I	H	Anglo-Norman	
xnr				I	L	Kangri	
xns				I	L	Kanashi	
xnt				I	E	Narragansett	
xnu				I	E	Nukunul	
xny				I	L	Nyiyaparli	
xnz				I	L	Kenzi	
xoc				I	E	O'chi'chi'	
xod				I	L	Kokoda	
xog				I	L	Soga	
xoi				I	L	Kominimung	
xok				I	L	Xokleng	
xom				I	L	Komo (Sudan)	
xon				I	L	Konkomba	
xoo				I	E	Xukurú	
xop				I	L	Kopar	
xor				I	L	Korubo	
xow				I	L	Kowaki	
xpa				I	E	Pirriya	
xpb				I	E	Northeastern Tasmanian	
xpc				I	H	Pecheneg	
xpd				I	E	Oyster Bay Tasmanian	
xpe				I	L	Liberia Kpelle	
xpf				I	E	Southeast Tasmanian	
xpg				I	A	Phrygian	
xph				I	E	North Midlands Tasmanian	
xpi				I	H	Pictish	
xpj				I	E	Mpalitjanh	
xpk				I	L	Kulina Pano	
xpl				I	E	Port Sorell Tasmanian	
xpm				I	E	Pumpokol	
xpn				I	E	Kapinawá	
xpo				I	E	Pochutec	
xpp				I	A	Puyo-Paekche	
xpq				I	E	Mohegan-Pequot	
xpr				I	A	Parthian	
xps				I	A	Pisidian	
xpt				I	E	Punthamara	
xpu				I	A	Punic	
xpv				I	E	Northern Tasmanian	
xpw				I	E	Northwestern Tasmanian	
xpx				I	E	Southwestern Tasmanian	
xpy				I	A	Puyo	
xpz				I	E	Bruny Island Tasmanian	
xqa				I	H	Karakhanid	
xqt				I	A	Qatabanian	
xra				I	L	Krahô	
xrb				I	L	Eastern Karaboro	
xrd				I	E	Gundungurra	
xre				I	L	Kreye	
xrg				I	E	Minang	
xri				I	L	Krikati-Timbira	
xrm				I	A	Armazic	
xrn				I	E	Arin	
xrr				I	A	Raetic	
xrt				I	E	Aranama-Tamique	
xru				I	L	Marriammu	
xrw				I	L	Karawa	
xsa				I	A	Sabaean	
xsb				I	L	Sambal	
xsc				I	A	Scythian	
xsd				I	A	Sidetic	
xse				I	L	Sempan	
xsh				I	L	Shamang	
xsi				I	L	Sio	
xsj				I	L	Subi	
xsl				I	L	South Slavey	
xsm				I	L	Kasem	
xsn				I	L	Sanga (Nigeria)	
xso				I	E	Solano	
xsp				I	L	Silopi	
xsq				I	L	Makhuwa-Saka	
xsr				I	L	Sherpa	
xss				I	E	Assan	
xsu				I	L	Sanumá	
xsv				I	E	Sudovian	
xsy				I	L	Saisiyat	
xta				I	L	Alcozauca Mixtec	
xtb				I	L	Chazumba Mixtec	
xtc				I	L	Katcha-Kadugli-Miri	
xtd				I	L	Diuxi-Tilantongo Mixtec	
xte				I	L	Ketengban	
xtg				I	A	Transalpine Gaulish	
xth				I	E	Yitha Yitha	
xti				I	L	Sinicahua Mixtec	
xtj				I	L	San Juan Teita Mixtec	
xtl				I	L	Tijaltepec Mixtec	
xtm				I	L	Magdalena Peñasco Mixtec	
xtn				I	L	Northern Tlaxiaco Mixtec	
xto				I	A	Tokharian A	
xtp				I	L	San Miguel Piedras Mixtec	
xtq				I	H	Tumshuqese	
xtr				I	A	Early Tripuri	
xts				I	L	Sindihui Mixtec	
xtt				I	L	Tacahua Mixtec	
xtu				I	L	Cuyamecalco Mixtec	
xtv				I	E	Thawa	
xtw				I	L	Tawandê	
xty				I	L	Yoloxochitl Mixtec	
xua				I	L	Alu Kurumba	
xub				I	L	Betta Kurumba	
xud				I	E	Umiida	
xug				I	L	Kunigami	
xuj				I	L	Jennu Kurumba	
xul				I	E	Ngunawal	
xum				I	A	Umbrian	
xun				I	E	Unggaranggu	
xuo				I	L	Kuo	
xup				I	E	Upper Umpqua	
xur				I	A	Urartian	
xut				I	E	Kuthant	
xuu				I	L	Kxoe	
xve				I	A	Venetic	
xvi				I	L	Kamviri	
xvn				I	A	Vandalic	
xvo				I	A	Volscian	
xvs				I	A	Vestinian	
xwa				I	L	Kwaza	
xwc				I	E	Woccon	
xwd				I	E	Wadi Wadi	
xwe				I	L	Xwela Gbe	
xwg				I	L	Kwegu	
xwj				I	E	Wajuk	
xwk				I	E	Wangkumara	
xwl				I	L	Western Xwla Gbe	
xwo				I	E	Written Oirat	
xwr				I	L	Kwerba Mamberamo	
xwt				I	E	Wotjobaluk	
xww				I	E	Wemba Wemba	
xxb				I	E	Boro (Ghana)	
xxk				I	L	Ke'o	
xxm				I	E	Minkin	
xxr				I	E	Koropó	
xxt				I	E	Tambora	
xya				I	E	Yaygir	
xyb				I	E	Yandjibara	
xyj				I	E	Mayi-Yapi	
xyk				I	E	Mayi-Kulan	
xyl				I	E	Yalakalore	
xyt				I	E	Mayi-Thakurti	
xyy				I	L	Yorta Yorta	
xzh				I	A	Zhang-Zhung	
xzm				I	E	Zemgalian	
xzp				I	H	Ancient Zapotec	
yaa				I	L	Yaminahua	
yab				I	L	Yuhup	
yac				I	L	Pass Valley Yali	
yad				I	L	Yagua	
yae				I	L	Pumé	
yaf				I	L	Yaka (Democratic Republic of Congo)	
yag				I	L	Yámana	
yah				I	L	Yazgulyam	
yai				I	L	Yagnobi	
yaj				I	L	Banda-Yangere	
yak				I	L	Yakama	
yal				I	L	Yalunka	
yam				I	L	Yamba	
yan				I	L	Mayangna	
yao	yao	yao		I	L	Yao	
yap	yap	yap		I	L	Yapese	
yaq				I	L	Yaqui	
yar				I	L	Yabarana	
yas				I	L	Nugunu (Cameroon)	
yat				I	L	Yambeta	
yau				I	L	Yuwana	
yav				I	L	Yangben	
yaw				I	L	Yawalapití	
yax				I	L	Yauma	
yay				I	L	Agwagwune	
yaz				I	L	Lokaa	
yba				I	L	Yala	
ybb				I	L	Yemba	
ybe				I	L	West Yugur	
ybh				I	L	Yakha	
ybi				I	L	Yamphu	
ybj				I	L	Hasha	
ybk				I	L	Bokha	
ybl				I	L	Yukuben	
ybm				I	L	Yaben	
ybn				I	E	Yabaâna	
ybo				I	L	Yabong	
ybx				I	L	Yawiyo	
yby				I	L	Yaweyuha	
ych				I	L	Chesu	
ycl				I	L	Lolopo	
ycn				I	L	Yucuna	
ycp				I	L	Chepya	
yda				I	E	Yanda	
ydd				I	L	Eastern Yiddish	
yde				I	L	Yangum Dey	
ydg				I	L	Yidgha	
ydk				I	L	Yoidik	
yea				I	L	Ravula	
yec				I	L	Yeniche	
yee				I	L	Yimas	
yei				I	E	Yeni	
yej				I	L	Yevanic	
yel				I	L	Yela	
yer				I	L	Tarok	
yes				I	L	Nyankpa	
yet				I	L	Yetfa	
yeu				I	L	Yerukula	
yev				I	L	Yapunda	
yey				I	L	Yeyi	
yga				I	E	Malyangapa	
ygi				I	E	Yiningayi	
ygl				I	L	Yangum Gel	
ygm				I	L	Yagomi	
ygp				I	L	Gepo	
ygr				I	L	Yagaria	
ygs				I	L	Yolŋu Sign Language	
ygu				I	L	Yugul	
ygw				I	L	Yagwoia	
yha				I	L	Baha Buyang	
yhd				I	L	Judeo-Iraqi Arabic	
yhl				I	L	Hlepho Phowa	
yhs				I	L	Yan-nhaŋu Sign Language	
yia				I	L	Yinggarda	
yid	yid	yid	yi	M	L	Yiddish	
yif				I	L	Ache	
yig				I	L	Wusa Nasu	
yih				I	L	Western Yiddish	
yii				I	L	Yidiny	
yij				I	L	Yindjibarndi	
yik				I	L	Dongshanba Lalo	
yil				I	E	Yindjilandji	
yim				I	L	Yimchungru Naga	
yin				I	L	Riang Lai	
yip				I	L	Pholo	
yiq				I	L	Miqie	
yir				I	L	North Awyu	
yis				I	L	Yis	
yit				I	L	Eastern Lalu	
yiu				I	L	Awu	
yiv				I	L	Northern Nisu	
yix				I	L	Axi Yi	
yiz				I	L	Azhe	
yka				I	L	Yakan	
ykg				I	L	Northern Yukaghir	
yki				I	L	Yoke	
ykk				I	L	Yakaikeke	
ykl				I	L	Khlula	
ykm				I	L	Kap	
ykn				I	L	Kua-nsi	
yko				I	L	Yasa	
ykr				I	L	Yekora	
ykt				I	L	Kathu	
yku				I	L	Kuamasi	
yky				I	L	Yakoma	
yla				I	L	Yaul	
ylb				I	L	Yaleba	
yle				I	L	Yele	
ylg				I	L	Yelogu	
yli				I	L	Angguruk Yali	
yll				I	L	Yil	
ylm				I	L	Limi	
yln				I	L	Langnian Buyang	
ylo				I	L	Naluo Yi	
ylr				I	E	Yalarnnga	
ylu				I	L	Aribwaung	
yly				I	L	Nyâlayu	
ymb				I	L	Yambes	
ymc				I	L	Southern Muji	
ymd				I	L	Muda	
yme				I	E	Yameo	
ymg				I	L	Yamongeri	
ymh				I	L	Mili	
ymi				I	L	Moji	
ymk				I	L	Makwe	
yml				I	L	Iamalele	
ymm				I	L	Maay	
ymn				I	L	Yamna	
ymo				I	L	Yangum Mon	
ymp				I	L	Yamap	
ymq				I	L	Qila Muji	
ymr				I	L	Malasar	
yms				I	A	Mysian	
ymx				I	L	Northern Muji	
ymz				I	L	Muzi	
yna				I	L	Aluo	
ynd				I	E	Yandruwandha	
yne				I	L	Lang'e	
yng				I	L	Yango	
ynk				I	L	Naukan Yupik	
ynl				I	L	Yangulam	
ynn				I	E	Yana	
yno				I	L	Yong	
ynq				I	L	Yendang	
yns				I	L	Yansi	
ynu				I	E	Yahuna	
yob				I	E	Yoba	
yog				I	L	Yogad	
yoi				I	L	Yonaguni	
yok				I	L	Yokuts	
yol				I	E	Yola	
yom				I	L	Yombe	
yon				I	L	Yongkom	
yor	yor	yor	yo	I	L	Yoruba	
yot				I	L	Yotti	
yox				I	L	Yoron	
yoy				I	L	Yoy	
ypa				I	L	Phala	
ypb				I	L	Labo Phowa	
ypg				I	L	Phola	
yph				I	L	Phupha	
ypm				I	L	Phuma	
ypn				I	L	Ani Phowa	
ypo				I	L	Alo Phola	
ypp				I	L	Phupa	
ypz				I	L	Phuza	
yra				I	L	Yerakai	
yrb				I	L	Yareba	
yre				I	L	Yaouré	
yrk				I	L	Nenets	
yrl				I	L	Nhengatu	
yrm				I	L	Yirrk-Mel	
yrn				I	L	Yerong	
yro				I	L	Yaroamë	
yrs				I	L	Yarsun	
yrw				I	L	Yarawata	
yry				I	L	Yarluyandi	
ysc				I	E	Yassic	
ysd				I	L	Samatao	
ysg				I	L	Sonaga	
ysl				I	L	Yugoslavian Sign Language	
ysn				I	L	Sani	
yso				I	L	Nisi (China)	
ysp				I	L	Southern Lolopo	
ysr				I	E	Sirenik Yupik	
yss				I	L	Yessan-Mayo	
ysy				I	L	Sanie	
yta				I	L	Talu	
ytl				I	L	Tanglang	
ytp				I	L	Thopho	
ytw				I	L	Yout Wam	
yty				I	E	Yatay	
yua				I	L	Yucateco	
yub				I	E	Yugambal	
yuc				I	L	Yuchi	
yud				I	L	Judeo-Tripolitanian Arabic	
yue				I	L	Yue Chinese	
yuf				I	L	Havasupai-Walapai-Yavapai	
yug				I	E	Yug	
yui				I	L	Yurutí	
yuj				I	L	Karkar-Yuri	
yuk				I	E	Yuki	
yul				I	L	Yulu	
yum				I	L	Quechan	
yun				I	L	Bena (Nigeria)	
yup				I	L	Yukpa	
yuq				I	L	Yuqui	
yur				I	E	Yurok	
yut				I	L	Yopno	
yuw				I	L	Yau (Morobe Province)	
yux				I	L	Southern Yukaghir	
yuy				I	L	East Yugur	
yuz				I	L	Yuracare	
yva				I	L	Yawa	
yvt				I	E	Yavitero	
ywa				I	L	Kalou	
ywg				I	L	Yinhawangka	
ywl				I	L	Western Lalu	
ywn				I	L	Yawanawa	
ywq				I	L	Wuding-Luquan Yi	
ywr				I	L	Yawuru	
ywt				I	L	Xishanba Lalo	
ywu				I	L	Wumeng Nasu	
yww				I	E	Yawarawarga	
yxa				I	E	Mayawali	
yxg				I	E	Yagara	
yxl				I	E	Yardliyawarra	
yxm				I	E	Yinwum	
yxu				I	E	Yuyu	
yxy				I	E	Yabula Yabula	
yyr				I	E	Yir Yoront	
yyu				I	L	Yau (Sandaun Province)	
yyz				I	L	Ayizi	
yzg				I	L	E'ma Buyang	
yzk				I	L	Zokhuo	
zaa				I	L	Sierra de Juárez Zapotec	
zab				I	L	Western Tlacolula Valley Zapotec	
zac				I	L	Ocotlán Zapotec	
zad				I	L	Cajonos Zapotec	
zae				I	L	Yareni Zapotec	
zaf				I	L	Ayoquesco Zapotec	
zag				I	L	Zaghawa	
zah				I	L	Zangwal	
zai				I	L	Isthmus Zapotec	
zaj				I	L	Zaramo	
zak				I	L	Zanaki	
zal				I	L	Zauzou	
zam				I	L	Miahuatlán Zapotec	
zao				I	L	Ozolotepec Zapotec	
zap	zap	zap		M	L	Zapotec	
zaq				I	L	Aloápam Zapotec	
zar				I	L	Rincón Zapotec	
zas				I	L	Santo Domingo Albarradas Zapotec	
zat				I	L	Tabaa Zapotec	
zau				I	L	Zangskari	
zav				I	L	Yatzachi Zapotec	
zaw				I	L	Mitla Zapotec	
zax				I	L	Xadani Zapotec	
zay				I	L	Zayse-Zergulla	
zaz				I	L	Zari	
zba				I	C	Balaibalan	
zbc				I	L	Central Berawan	
zbe				I	L	East Berawan	
zbl	zbl	zbl		I	C	Blissymbols	
zbt				I	L	Batui	
zbw				I	L	West Berawan	
zca				I	L	Coatecas Altas Zapotec	
zch				I	L	Central Hongshuihe Zhuang	
zdj				I	L	Ngazidja Comorian	
zea				I	L	Zeeuws	
zeg				I	L	Zenag	
zeh				I	L	Eastern Hongshuihe Zhuang	
zen	zen	zen		I	L	Zenaga	
zga				I	L	Kinga	
zgb				I	L	Guibei Zhuang	
zgh	zgh	zgh		I	L	Standard Moroccan Tamazight	
zgm				I	L	Minz Zhuang	
zgn				I	L	Guibian Zhuang	
zgr				I	L	Magori	
zha	zha	zha	za	M	L	Zhuang	
zhb				I	L	Zhaba	
zhd				I	L	Dai Zhuang	
zhi				I	L	Zhire	
zhn				I	L	Nong Zhuang	
zho	chi	zho	zh	M	L	Chinese	
zhw				I	L	Zhoa	
zia				I	L	Zia	
zib				I	L	Zimbabwe Sign Language	
zik				I	L	Zimakani	
zil				I	L	Zialo	
zim				I	L	Mesme	
zin				I	L	Zinza		
ziw				I	L	Zigula	
ziz				I	L	Zizilivakan	
zka				I	L	Kaimbulawa	
zkb				I	E	Koibal	
zkd				I	L	Kadu	
zkg				I	A	Koguryo	
zkh				I	H	Khorezmian	
zkk				I	E	Karankawa	
zkn				I	L	Kanan	
zko				I	E	Kott	
zkp				I	E	São Paulo Kaingáng	
zkr				I	L	Zakhring	
zkt				I	H	Kitan	
zku				I	L	Kaurna	
zkv				I	E	Krevinian	
zkz				I	H	Khazar	
zlj				I	L	Liujiang Zhuang	
zlm				I	L	Malay (individual language)	
zln				I	L	Lianshan Zhuang	
zlq				I	L	Liuqian Zhuang	
zma				I	L	Manda (Australia)	
zmb				I	L	Zimba	
zmc				I	E	Margany	
zmd				I	L	Maridan	
zme				I	E	Mangerr	
zmf				I	L	Mfinu	
zmg				I	L	Marti Ke	
zmh				I	E	Makolkol	
zmi				I	L	Negeri Sembilan Malay	
zmj				I	L	Maridjabin	
zmk				I	E	Mandandanyi	
zml				I	E	Matngala	
zmm				I	L	Marimanindji	
zmn				I	L	Mbangwe	
zmo				I	L	Molo	
zmp				I	L	Mpuono	
zmq				I	L	Mituku	
zmr				I	L	Maranunggu	
zms				I	L	Mbesa	
zmt				I	L	Maringarr	
zmu				I	E	Muruwari	
zmv				I	E	Mbariman-Gudhinma	
zmw				I	L	Mbo (Democratic Republic of Congo)	
zmx				I	L	Bomitaba	
zmy				I	L	Mariyedi	
zmz				I	L	Mbandja	
zna				I	L	Zan Gula	
zne				I	L	Zande (individual language)	
zng				I	L	Mang	
znk				I	E	Manangkari	
zns				I	L	Mangas	
zoc				I	L	Copainalá Zoque	
zoh				I	L	Chimalapa Zoque	
zom				I	L	Zou	
zoo				I	L	Asunción Mixtepec Zapotec	
zoq				I	L	Tabasco Zoque	
zor				I	L	Rayón Zoque	
zos				I	L	Francisco León Zoque	
zpa				I	L	Lachiguiri Zapotec	
zpb				I	L	Yautepec Zapotec	
zpc				I	L	Choapan Zapotec	
zpd				I	L	Southeastern Ixtlán Zapotec	
zpe				I	L	Petapa Zapotec	
zpf				I	L	San Pedro Quiatoni Zapotec	
zpg				I	L	Guevea De Humboldt Zapotec	
zph				I	L	Totomachapan Zapotec	
zpi				I	L	Santa María Quiegolani Zapotec	
zpj				I	L	Quiavicuzas Zapotec	
zpk				I	L	Tlacolulita Zapotec	
zpl				I	L	Lachixío Zapotec	
zpm				I	L	Mixtepec Zapotec	
zpn				I	L	Santa Inés Yatzechi Zapotec	
zpo				I	L	Amatlán Zapotec	
zpp				I	L	El Alto Zapotec	
zpq				I	L	Zoogocho Zapotec	
zpr				I	L	Santiago Xanica Zapotec	
zps				I	L	Coatlán Zapotec	
zpt				I	L	San Vicente Coatlán Zapotec	
zpu				I	L	Yalálag Zapotec	
zpv				I	L	Chichicapan Zapotec	
zpw				I	L	Zaniza Zapotec	
zpx				I	L	San Baltazar Loxicha Zapotec	
zpy				I	L	Mazaltepec Zapotec	
zpz				I	L	Texmelucan Zapotec	
zqe				I	L	Qiubei Zhuang	
zra				I	A	Kara (Korea)	
zrg				I	L	Mirgan	
zrn				I	L	Zerenkel	
zro				I	L	Záparo	
zrp				I	E	Zarphatic	
zrs				I	L	Mairasi	
zsa				I	L	Sarasira	
zsk				I	A	Kaskean	
zsl				I	L	Zambian Sign Language	
zsm				I	L	Standard Malay	
zsr				I	L	Southern Rincon Zapotec	
zsu				I	L	Sukurum	
zte				I	L	Elotepec Zapotec	
ztg				I	L	Xanaguía Zapotec	
ztl				I	L	Lapaguía-Guivini Zapotec	
ztm				I	L	San Agustín Mixtepec Zapotec	
ztn				I	L	Santa Catarina Albarradas Zapotec	
ztp				I	L	Loxicha Zapotec	
ztq				I	L	Quioquitani-Quierí Zapotec	
zts				I	L	Tilquiapan Zapotec	
ztt				I	L	Tejalapan Zapotec	
ztu				I	L	Güilá Zapotec	
ztx				I	L	Zaachila Zapotec	
zty				I	L	Yatee Zapotec	
zua				I	L	Zeem	
zuh				I	L	Tokano	
zul	zul	zul	zu	I	L	Zulu	
zum				I	L	Kumzari	
zun	zun	zun		I	L	Zuni	
zuy				I	L	Zumaya	
zwa				I	L	Zay	
zxx	zxx	zxx		S	S	No linguistic content	
zyb				I	L	Yongbei Zhuang	
zyg				I	L	Yang Zhuang	
zyj				I	L	Youjiang Zhuang	
zyn				I	L	Yongnan Zhuang	
zyp				I	L	Zyphe Chin	
zza	zza	zza		M	L	Zaza	
zzj				I	L	Zuojiang Zhuang	

M_Id	I_Id	I_Status
aka	fat	A
aka	twi	A
ara	aao	A
ara	abh	A
ara	abv	A
ara	acm	A
ara	acq	A
ara	acw	A
ara	acx	A
ara	acy	A
ara	adf	A
ara	aeb	A
ara	aec	A
ara	afb	A
ara	ajp	A
ara	apc	A
ara	apd	A
ara	arb	A
ara	arq	A
ara	ars	A
ara	ary	A
ara	arz	A
ara	auz	A
ara	avl	A
ara	ayh	A
ara	ayl	A
ara	ayn	A
ara	ayp	A
ara	bbz	R
ara	pga	A
ara	shu	A
ara	ssh	A
aym	ayc	A
aym	ayr	A
aze	azb	A
aze	azj	A
bal	bcc	A
bal	bgn	A
bal	bgp	A
bik	bcl	A
bik	bhk	R
bik	bln	A
bik	bto	A
bik	cts	A
bik	fbl	A
bik	lbl	A
bik	rbl	A
bik	ubl	A
bnc	ebk	A
bnc	lbk	A
bnc	obk	A
bnc	rbk	A
bnc	vbk	A
bua	bxm	A
bua	bxr	A
bua	bxu	A
chm	mhr	A
chm	mrj	A
cre	crj	A
cre	crk	A
cre	crl	A
cre	crm	A
cre	csw	A
cre	cwd	A
del	umu	A
del	unm	A
den	scs	A
den	xsl	A
din	dib	A
din	dik	A
din	dip	A
din	diw	A
din	dks	A
doi	dgo	A
doi	xnr	A
est	ekk	A
est	vro	A
fas	pes	A
fas	prs	A
ful	ffm	A
ful	fub	A
ful	fuc	A
ful	fue	A
ful	fuf	A
ful	fuh	A
ful	fui	A
ful	fuq	A
ful	fuv	A
gba	bdt	A
gba	gbp	A
gba	gbq	A
gba	gmm	A
gba	gso	A
gba	gya	A
gba	mdo	R
gon	esg	A
gon	ggo	R
gon	gno	A
gon	wsg	A
grb	gbo	A
grb	gec	A
grb	grj	A
grb	grv	A
grb	gry	A
grn	gnw	A
grn	gug	A
grn	gui	A
grn	gun	A
grn	nhd	A
hai	hax	A
hai	hdn	A
hbs	bos	A
hbs	cnr	A
hbs	hrv	A
hbs	srp	A
hmn	blu	R
hmn	cqd	A
hmn	hea	A
hmn	hma	A
hmn	hmc	A
hmn	hmd	A
hmn	hme	A
hmn	hmg	A
hmn	hmh	A
hmn	hmi	A
hmn	hmj	A
hmn	hml	A
hmn	hmm	A
hmn	hmp	A
hmn	hmq	A
hmn	hms	A
hmn	hmw	A
hmn	hmy	A
hmn	hmz	A
hmn	hnj	A
hmn	hrm	A
hmn	huj	A
hmn	mmr	A
hmn	muq	A
hmn	mww	A
hmn	sfm	A
iku	ike	A
iku	ikt	A
ipk	esi	A
ipk	esk	A
jrb	ajt	A
jrb	aju	A
jrb	jye	A
jrb	yhd	A
jrb	yud	A
kau	kby	A
kau	knc	A
kau	krt	A
kln	enb	A
kln	eyo	A
kln	niq	A
kln	oki	A
kln	pko	A
kln	sgc	A
kln	spy	A
kln	tec	A
kln	tuy	A
kok	gom	A
kok	knn	A
kom	koi	A
kom	kpv	A
kon	kng	A
kon	kwy	A
kon	ldi	A
kpe	gkp	A
kpe	xpe	A
kur	ckb	A
kur	kmr	A
kur	sdh	A
lah	hnd	A
lah	hno	A
lah	jat	A
lah	phr	A
lah	pmu	R
lah	pnb	A
lah	skr	A
lah	xhe	A
lav	ltg	A
lav	lvs	A
luy	bxk	A
luy	ida	A
luy	lkb	A
luy	lko	A
luy	lks	A
luy	lri	A
luy	lrm	A
luy	lsm	A
luy	lto	A
luy	lts	A
luy	lwg	A
luy	nle	A
luy	nyd	A
luy	rag	A
man	emk	A
man	mku	A
man	mlq	A
man	mnk	A
man	msc	A
man	mwk	A
man	myq	R
mlg	bhr	A
mlg	bjq	R
mlg	bmm	A
mlg	bzc	A
mlg	msh	A
mlg	plt	A
mlg	skg	A
mlg	tdx	A
mlg	tkg	A
mlg	txy	A
mlg	xmv	A
mlg	xmw	A
mon	khk	A
mon	mvf	A
msa	bjn	A
msa	btj	A
msa	bve	A
msa	bvu	A
msa	coa	A
msa	dup	A
msa	hji	A
msa	ind	A
msa	jak	A
msa	jax	A
msa	kvb	A
msa	kvr	A
msa	kxd	A
msa	lce	A
msa	lcf	A
msa	liw	A
msa	max	A
msa	meo	A
msa	mfa	A
msa	mfb	A
msa	min	A
msa	mly	R
msa	mqg	A
msa	msi	A
msa	mui	A
msa	orn	A
msa	ors	A
msa	pel	A
msa	pse	A
msa	tmw	A
msa	urk	A
msa	vkk	A
msa	vkt	A
msa	xmm	A
msa	zlm	A
msa	zmi	A
msa	zsm	A
mwr	dhd	A
mwr	mtr	A
mwr	mve	A
mwr	rwr	A
mwr	swv	A
mwr	wry	A
nep	dty	A
nep	npi	A
nor	nno	A
nor	nob	A
oji	ciw	A
oji	ojb	A
oji	ojc	A
oji	ojg	A
oji	ojs	A
oji	ojw	A
oji	otw	A
ori	ory	A
ori	spv	A
orm	gax	A
orm	gaz	A
orm	hae	A
orm	orc	A
pus	pbt	A
pus	pbu	A
pus	pst	A
que	cqu	R
que	qub	A
que	qud	A
que	quf	A
que	qug	A
que	quh	A
que	quk	A
que	qul	A
que	qup	A
que	qur	A
que	qus	A
que	quw	A
que	qux	A
que	quy	A
que	quz	A
que	qva	A
que	qvc	A
que	qve	A
que	qvh	A
que	qvi	A
que	qvj	A
que	qvl	A
que	qvm	A
que	qvn	A
que	qvo	A
que	qvp	A
que	qvs	A
que	qvw	A
que	qvz	A
que	qwa	A
que	qwc	A
que	qwh	A
que	qws	A
que	qxa	A
que	qxc	A
que	qxh	A
que	qxl	A
que	qxn	A
que	qxo	A
que	qxp	A
que	qxr	A
que	qxt	A
que	qxu	A
que	qxw	A
raj	bgq	A
raj	gda	A
raj	gju	A
raj	hoj	A
raj	mup	A
raj	wbr	A
rom	rmc	A
rom	rmf	A
rom	rml	A
rom	rmn	A
rom	rmo	A
rom	rmw	A
rom	rmy	A
sqi	aae	A
sqi	aat	A
sqi	aln	A
sqi	als	A
srd	sdc	A
srd	sdn	A
srd	src	A
srd	sro	A
swa	swc	A
swa	swh	A
syr	aii	A
syr	cld	A
tmh	taq	A
tmh	thv	A
tmh	thz	A
tmh	ttq	A
uzb	uzn	A
uzb	uzs	A
yid	ydd	A
yid	yih	A
zap	zaa	A
zap	zab	A
zap	zac	A
zap	zad	A
zap	zae	A
zap	zaf	A
zap	zai	A
zap	zam	A
zap	zao	A
zap	zaq	A
zap	zar	A
zap	zas	A
zap	zat	A
zap	zav	A
zap	zaw	A
zap	zax	A
zap	zca	A
zap	zoo	A
zap	zpa	A
zap	zpb	A
zap	zpc	A
zap	zpd	A
zap	zpe	A
zap	zpf	A
zap	zpg	A
zap	zph	A
zap	zpi	A
zap	zpj	A
zap	zpk	A
zap	zpl	A
zap	zpm	A
zap	zpn	A
zap	zpo	A
zap	zpp	A
zap	zpq	A
zap	zpr	A
zap	zps	A
zap	zpt	A
zap	zpu	A
zap	zpv	A
zap	zpw	A
zap	zpx	A
zap	zpy	A
zap	zpz	A
zap	zsr	A
zap	ztc	R
zap	zte	A
zap	ztg	A
zap	ztl	A
zap	ztm	A
zap	ztn	A
zap	ztp	A
zap	ztq	A
zap	zts	A
zap	ztt	A
zap	ztu	A
zap	ztx	A
zap	zty	A
zha	ccx	R
zha	ccy	R
zha	zch	A
zha	zeh	A
zha	zgb	A
zha	zgm	A
zha	zgn	A
zha	zhd	A
zha	zhn	A
zha	zlj	A
zha	zln	A
zha	zlq	A
zha	zqe	A
zha	zyb	A
zha	zyg	A
zha	zyj	A
zha	zyn	A
zha	zzj	A
zho	cdo	A
zho	cjy	A
zho	cmn	A
zho	cnp	A
zho	cpx	A
zho	csp	A
zho	czh	A
zho	czo	A
zho	gan	A
zho	hak	A
zho	hsn	A
zho	lzh	A
zho	mnp	A
zho	nan	A
zho	wuu	A
zho	yue	A
zza	diq	A
zza	kiu	A

NS_Id	Id	Part1	M_Id	Ref_Name
pob		pt_br	por	Brazilian Portuguese


Id	Ref_Name	Ret_Reason	Change_To	Ret_Remedy	Effective
fri	Western Frisian	C	fry		2007-02-01
auv	Auvergnat	M	oci		2007-03-14
gsc	Gascon	M	oci		2007-03-14
lms	Limousin	M	oci		2007-03-14
lnc	Languedocien	M	oci		2007-03-14
prv	Provençal	M	oci		2007-03-14
amd	Amapá Creole	N			2007-07-18
bgh	Bogan	D	bbh		2007-07-18
bnh	Banawá	M	jaa		2007-07-18
bvs	Belgian Sign Language	S		Split into Langue des signes de Belgique Francophone [sfb], and Vlaamse Gebarentaal [vgt]	2007-07-18
ccy	Southern Zhuang	S		Split into five languages: Nong Zhuang [zhn];  Yang Zhuang [zyg]; Yongnan Zhuang [zyn]; Zuojiang Zhuang [zzj]; Dai Zhuang [zhd].	2007-07-18
cit	Chittagonian	S		Split into Rohingya [rhg], and Chittagonian (new identifier [ctg])	2007-07-18
flm	Falam Chin	S		Split into Ranglong [rnl], and Falam Chin (new identifier [cfm]).	2007-07-18
jap	Jaruára	M	jaa		2007-07-18
kob	Kohoroxitari	M	xsu		2007-07-18
mob	Moinba	S		Split into five languages: Chug [cvg]; Lish [lsh];  Kalaktang Monpa [kkf]; Tawang Monpa [twm]; Sartang [onp]	2007-07-18
mzf	Aiku	S		Split into four languages: Ambrak [aag]; Yangum Dey [yde]; Yangum Gel [ygl]; Yangum Mon [ymo]	2007-07-18
nhj	Tlalitzlipa Nahuatl	M	nhi		2007-07-18
nhs	Southeastern Puebla Nahuatl	S		Split into Sierra Negra Nahuatl [nsu] and Southeastern Puebla Nahuatl [npl]	2007-07-18
occ	Occidental	D	ile		2007-07-18
tmx	Tomyang	M	ybi		2007-07-18
tot	Patla-Chicontla Totonac	S		Split into Upper Necaxa Totonac [tku] and Tecpatlán Totonac [tcw]	2007-07-18
xmi	Miarrã	N			2007-07-18
yib	Yinglish	M	eng		2007-07-18
ztc	Lachirioag Zapotec	M	zty		2007-07-18
atf	Atuence	N			2007-08-10
bqe	Navarro-Labourdin Basque	M	eus		2007-08-10
bsz	Souletin Basque	M	eus		2007-08-10
aex	Amerax	M	eng		2008-01-14
ahe	Ahe	M	knx		2008-01-14
aiz	Aari	S		Split into Aari [aiw] (new identifier) and Gayil [gyl]	2008-01-14
akn	Amikoana	N			2008-01-14
arf	Arafundi	S		Split into three languages: Andai [afd]; Nanubae [afk]; Tapei [afp]	2008-01-14
azr	Adzera	S		Split into three languages: Adzera [adz] (new identifier), Sukurum [zsu] and Sarasira [zsa]	2008-01-14
bcx	Pamona	S		Split into Pamona [pmf] (new identifier) and Batui [zbt]	2008-01-14
bii	Bisu	S		Split into Bisu [bzi] (new identifier) and Laomian [lwm]	2008-01-14
bke	Bengkulu	M	pse		2008-01-14
blu	Hmong Njua	S		Split into four languages: Hmong Njua [hnj] (new identifier); Chuanqiandian Cluster Miao [cqd]; Horned Miao [hrm]; Small Flowery Miao [sfm]	2008-01-14
boc	Bakung Kenyah	M	xkl		2008-01-14
bsd	Sarawak Bisaya	M	bsb		2008-01-14
bwv	Bahau River Kenyah	N			2008-01-14
bxt	Buxinhua	D	bgk		2008-01-14
byu	Buyang	S		Split into three languages: E'ma Buyang [yzg]; Langnian Buyang [yln]; Baha Buyang [yha]	2008-01-14
ccx	Northern Zhuang	S		Split into ten languages: Guibian Zh [zgn]; Liujiang Zh [zlj]; Qiubei Zh [zqe]; Guibei Zh [zgb]; Youjiang Zh [zyj]; Central Hongshuihe Zh [zch]; Eastern Hongshuihe Zh [zeh]; Liuqian Zh [zlq]; Yongbei Zh [zyb]; Lianshan Zh [zln].	2008-01-14
cru	Carútana	M	bwi		2008-01-14
dat	Darang Deng	D	mhu		2008-01-14
dyk	Land Dayak	N			2008-01-14
eni	Enim	M	pse		2008-01-14
fiz	Izere	S		Split into Ganang [gne] and Izere [izr] (new identifier)	2008-01-14
gen	Geman Deng	D	mxj		2008-01-14
ggh	Garreh-Ajuran	S		Split between Borana [gax] and Somali [som]	2008-01-14
itu	Itutang	M	mzu		2008-01-14
kds	Lahu Shi	S		Split into Kucong [lkc] and Lahu Shi [lhi] (new identifier)	2008-01-14
knh	Kayan River Kenyah	N			2008-01-14
krg	North Korowai	M	khe		2008-01-14
krq	Krui	M	ljp		2008-01-14
kxg	Katingan	M	nij		2008-01-14
lmt	Lematang	M	mui		2008-01-14
lnt	Lintang	M	pse		2008-01-14
lod	Berawan	S		Split into three languages: West Berawan [zbw], Central Berawan [zbc], and East Berawan [zbe]	2008-01-14
mbg	Northern Nambikuára	S		Split into six languages: Alapmunte [apv]; Lakondê [lkd]; Latundê [ltn]; Mamaindé [wmd]; Tawandê [xtw]; Yalakalore [xyl]	2008-01-14
mdo	Southwest Gbaya	S		Split into Southwest Gbaya [gso] (new identifier) and Gbaya-Mbodomo [gmm]	2008-01-14
mhv	Arakanese	S		Split into Marma [rmz] and Rakhine [rki]	2008-01-14
miv	Mimi	M	amj		2008-01-14
mqd	Madang	M	xkl		2008-01-14
nky	Khiamniungan Naga	S		Split into three languages: Khiamniungan Naga [kix] (new identifier); Para Naga [pzn]; Makuri Naga [jmn]	2008-01-14
nxj	Nyadu	M	byd		2008-01-14
ogn	Ogan	M	pse		2008-01-14
ork	Orokaiva	S		Split into Orokaiva [okv] (new identifier), Aeka [aez] and Hunjara-Kaina Ke [hkk]	2008-01-14
paj	Ipeka-Tapuia	M	kpc		2008-01-14
pec	Southern Pesisir	M	ljp		2008-01-14
pen	Penesak	M	mui		2008-01-14
plm	Palembang	M	mui		2008-01-14
poj	Lower Pokomo	M	pkb		2008-01-14
pun	Pubian	M	ljp		2008-01-14
rae	Ranau	M	ljp		2008-01-14
rjb	Rajbanshi	S		Split into Kamta (India) / Rangpuri (Bangladesh) [rkt] and Rajbanshi (Nepal) [rjs]	2008-01-14
rws	Rawas	M	mui		2008-01-14
sdd	Semendo	M	pse		2008-01-14
sdi	Sindang Kelingi	M	liw		2008-01-14
skl	Selako	M	knx		2008-01-14
slb	Kahumamahon Saluan	M	loe		2008-01-14
srj	Serawai	M	pse		2008-01-14
suf	Tarpia	S		Split into Tarpia [tpf] (new identifier) and Kaptiau [kbi]	2008-01-14
suh	Suba	S		Split into Suba [sxb] (Kenya) and Suba-Simbita [ssc] (Tanzania)	2008-01-14
suu	Sungkai	M	ljp		2008-01-14
szk	Sizaki	M	ikz		2008-01-14
tle	Southern Marakwet	M	enb		2008-01-14
tnj	Tanjong	M	kxn		2008-01-14
ttx	Tutong 1	M	bsb		2008-01-14
ubm	Upper Baram Kenyah	N			2008-01-14
vky	Kayu Agung	M	kge		2008-01-14
vmo	Muko-Muko	M	min		2008-01-14
wre	Ware	N			2008-01-14
xah	Kahayan	M	nij		2008-01-14
xkm	Mahakam Kenyah	N			2008-01-14
xuf	Kunfal	M	awn		2008-01-14
yio	Dayao Yi	M	lpo		2008-01-14
ymj	Muji Yi	S		Split into five languages: Muji, Southern [ymc], Mojii [ymi], Qila Muji [ymq], Northern Muji [ymx], and Muzi [ymz]	2008-01-14
ypl	Pula Yi	S		Split into three languages: Phola [ypg], Phala [ypa] and Alo Phola [ypo]	2008-01-14
ypw	Puwa Yi	S		Split into three languages: Hlepho Phowa [yhl], Labo Phowa [ypb], and Ani Phowa [ypn]	2008-01-14
ywm	Wumeng Yi	M	ywu		2008-01-14
yym	Yuanjiang-Mojiang Yi	S		Split into Southern Nisu [nsd] and Southwestern Nisu [nsv]	2008-01-14
mly	Malay (individual language)	S		Split into four languages: Standard Malay [zsm], Haji [hji], Papuan Malay [pmy] and Malay (individual language) [zlm]	2008-02-18
muw	Mundari	S		Split into Munda [unx] and Mundari [unr] (new identifier)	2008-02-18
xst	Silt'e	S		Split into Wolane [wle] and Silt'e [stv] (new identifier)	2008-02-28
ope	Old Persian	D	peo		2008-04-18
scc	Serbian	D	srp		2008-06-28
scr	Croatian	D	hrv		2008-06-28
xsk	Sakan	D	kho		2008-10-23
mol	Moldavian	M	ron		2008-11-03
aay	Aariya	N			2009-01-16
acc	Cubulco Achí	M	acr		2009-01-16
cbm	Yepocapa Southwestern Cakchiquel	M	cak		2009-01-16
chs	Chumash	S		Chumash is actually a family name, not a language name. Language family members already have code elements: Barbareño [boi], Cruzeño [crz], Ineseño [inz], Obispeño [obi], Purisimeño [puy], and Ventureño [veo]	2009-01-16
ckc	Northern Cakchiquel	M	cak		2009-01-16
ckd	South Central Cakchiquel	M	cak		2009-01-16
cke	Eastern Cakchiquel	M	cak		2009-01-16
ckf	Southern Cakchiquel	M	cak		2009-01-16
cki	Santa María De Jesús Cakchiquel	M	cak		2009-01-16
ckj	Santo Domingo Xenacoj Cakchiquel	M	cak		2009-01-16
ckk	Acatenango Southwestern Cakchiquel	M	cak		2009-01-16
ckw	Western Cakchiquel	M	cak		2009-01-16
cnm	Ixtatán Chuj	M	cac		2009-01-16
cti	Tila Chol	M	ctu		2009-01-16
cun	Cunén Quiché	M	quc		2009-01-16
eml	Emiliano-Romagnolo	S		Split into Emilian [egl] and Romagnol [rgn]	2009-01-16
eur	Europanto	N			2009-01-16
gmo	Gamo-Gofa-Dawro	S		Split into three languages: Gamo [gmv], Gofa [gof], and Dawro [dwr]	2009-01-16
hsf	Southeastern Huastec	M	hus		2009-01-16
hva	San Luís Potosí Huastec	M	hus		2009-01-16
ixi	Nebaj Ixil	M	ixl		2009-01-16
ixj	Chajul Ixil	M	ixl		2009-01-16
jai	Western Jacalteco	M	jac		2009-01-16
mms	Southern Mam	M	mam		2009-01-16
mpf	Tajumulco Mam	M	mam		2009-01-16
mtz	Tacanec	M	mam		2009-01-16
mvc	Central Mam	M	mam		2009-01-16
mvj	Todos Santos Cuchumatán Mam	M	mam		2009-01-16
poa	Eastern Pokomam	M	poc		2009-01-16
pob	Western Pokomchí	M	poh		2009-01-16
pou	Southern Pokomam	M	poc		2009-01-16
ppv	Papavô	N			2009-01-16
quj	Joyabaj Quiché	M	quc		2009-01-16
qut	West Central Quiché	M	quc		2009-01-16
quu	Eastern Quiché	M	quc		2009-01-16
qxi	San Andrés Quiché	M	quc		2009-01-16
sic	Malinguat	S		Split into Keak [keh] and Sos Kundi [sdk]	2009-01-16
stc	Santa Cruz	S		Split into Natügu [ntu] and Nalögo [nlz]	2009-01-16
tlz	Toala'	M	rob		2009-01-16
tzb	Bachajón Tzeltal	M	tzh		2009-01-16
tzc	Chamula Tzotzil	M	tzo		2009-01-16
tze	Chenalhó Tzotzil	M	tzo		2009-01-16
tzs	San Andrés Larrainzar Tzotzil	M	tzo		2009-01-16
tzt	Western Tzutujil	M	tzj		2009-01-16
tzu	Huixtán Tzotzil	M	tzo		2009-01-16
tzz	Zinacantán Tzotzil	M	tzo		2009-01-16
vlr	Vatrata	S		Split into Vera'a [vra] and Lemerig [lrz]	2009-01-16
yus	Chan Santa Cruz Maya	M	yua		2009-01-16
nfg	Nyeng	M	nfd		2009-01-26
nfk	Shakara	M	nfd		2009-01-26
agp	Paranan	S		Split into Pahanan Agta [apf] and Paranan [prf] (new identifier)	2010-01-18
bhk	Albay Bicolano	S		Split into Buhi'non Bikol [ubl]; Libon Bikol [lbl]; Miraya Bikol [rbl]; West Albay Bikol [fbl]	2010-01-18
bkb	Finallig	S		Split into Eastern Bontok [ebk] and Southern Bontok [obk]	2010-01-18
btb	Beti (Cameroon)	S		Beti is a group name, not an individual language name. Member languages are Bebele [beb], Bebil [bxp], Bulu [bum], Eton [eto], Ewondo [ewo], Fang [fan], and Mengisa [mct], all of which already have their own code elements.	2010-01-18
cjr	Chorotega	M	mom		2010-01-18
cmk	Chimakum	D	xch		2010-01-18
drh	Darkhat	M	khk		2010-01-18
drw	Darwazi	M	prs		2010-01-18
gav	Gabutamon	M	dev		2010-01-18
mof	Mohegan-Montauk-Narragansett	S		split into Mohegan-Pequot [xpq] and Narragansett [xnt]	2010-01-18
mst	Cataelano Mandaya	M	mry		2010-01-18
myt	Sangab Mandaya	M	mry		2010-01-18
rmr	Caló	S		split into Caló [rmq] and Erromintxela [emx]	2010-01-18
sgl	Sanglechi-Ishkashimi	S		split into Sanglechi [sgy] and Ishkashimi [isk]	2010-01-18
sul	Surigaonon	S		Split into Tandaganon [tgn] and Surigaonon [sgd] (new identifier)	2010-01-18
sum	Sumo-Mayangna	S		Split into Mayangna [yan] and Ulwa [ulw]	2010-01-18
tnf	Tangshewi	M	prs		2010-01-18
wgw	Wagawaga	S		Split into Yaleba [ylb] and Wagawaga [wgb] (new identifier)	2010-01-18
ayx	Ayi (China)	D	nun		2011-05-18
bjq	Southern Betsimisaraka Malagasy	S		split into Southern Betsimisaraka [bzc] and Tesaka Malagasy [tkg]	2011-05-18
dha	Dhanwar (India)	N			2011-05-18
dkl	Kolum So Dogon	S		split into Ampari Dogon [aqd] and Mombo Dogon [dmb]	2011-05-18
mja	Mahei	N			2011-05-18
nbf	Naxi	S		split into Naxi [nxq] and Narua [nru]	2011-05-18
noo	Nootka	S		Split into [dtd] Ditidaht and [nuk] Nuu-chah-nulth	2011-05-18
tie	Tingal	M	ras		2011-05-18
tkk	Takpa	D	twm		2011-05-18
baz	Tunen	S		Split Tunen [baz]  into Tunen [tvu] and Nyokon [nvo]	2012-02-03
bjd	Bandjigali	M	drl		2012-02-03
ccq	Chaungtha	M	rki		2012-02-03
cka	Khumi Awa Chin	M	cmr		2012-02-03
dap	Nisi (India)	S		Split into Nyishi [njz] and Tagin [tgj]	2012-02-03
dwl	Walo Kumbe Dogon	S		Split into Dogon, Bankan Tey (Walo) [dbw]  and Dogon, Ben Tey (Beni) [dbt]	2012-02-03
elp	Elpaputih	N			2012-02-03
gbc	Garawa	S		Split into Garrwa [wrk] and Wanyi [wny]	2012-02-03
gio	Gelao	S		split into Qau [gqu] and A'ou [aou] with some going to Green Gelao [gig], some to Red Gelao [gir], and some to White Gelao [giw]	2012-02-03
hrr	Horuru	M	jal		2012-02-03
ibi	Ibilo	M	opa		2012-02-03
jar	Jarawa (Nigeria)	S		split into Gwak [jgk] and Bankal [jjr]	2012-02-03
kdv	Kado	S		split into Kadu [zkd] and Kanan [zkn]	2012-02-03
kgh	Upper Tanudan Kalinga	M	kml		2012-02-03
kpp	Paku Karen	S		Split into Paku Karen [jkp] and Mobwa Karen [jkm]	2012-02-03
kzh	Kenuzi-Dongola	S		Split into Andaandi (Dongolawi) [dgl] and Kenzi (Mattoki) [xnz]	2012-02-03
lcq	Luhu	M	ppr		2012-02-03
mgx	Omati	S		Split into Barikewa [jbk] and Mouwase [jmw]	2012-02-03
nln	Durango Nahuatl	S		Split into Eastern Durango Nahuatl [azd] and Western Durango Nahuatl [azn]	2012-02-03
pbz	Palu	N			2012-02-03
pgy	Pongyong	N			2012-02-03
sca	Sansu	M	hle		2012-02-03
tlw	South Wemale	M	weo		2012-02-03
unp	Worora	S		Split into Worrorra [wro] and Unggumi [xgu].	2012-02-03
wiw	Wirangu	S		Split into Wirangu [wgu] and Nauo [nwo]	2012-02-03
ybd	Yangbye	M	rki		2012-02-03
yen	Yendang	S		Split into Yendang [ynq] and Yotti [yot]	2012-02-03
yma	Yamphe	M	lrr		2012-02-03
daf	Dan	S		Split into Dan [dnj] and Kla-Dan [lda]	2013-01-23
djl	Djiwarli	S		Split into Djiwarli [dze] and Thiin [iin]	2013-01-23
ggr	Aghu Tharnggalu	S		Split into Aghu-Tharnggala [gtu], Gugu-Mini [ggm], and Ikarranggal [ikr]	2013-01-23
ilw	Talur	M	gal		2013-01-23
izi	Izi-Ezaa-Ikwo-Mgbo	S		Split into Izii [izz], Ezaa [eza], Ikwo [iqw], Mgbolizhia [gmz]	2013-01-23
meg	Mea	M	cir		2013-01-23
mld	Malakhel	N			2013-01-23
mnt	Maykulan	S		Split into Mayi-Kulan [xyk], Mayi-Thakurti [xyt], Mayi-Yapi [xyj], and Wunumara [wnn]	2013-01-23
mwd	Mudbura	S		Split into Karranga [xrq] and Mudburra [dmw]	2013-01-23
myq	Forest Maninka	N			2013-01-23
nbx	Ngura	S		Split into Eastern Karnic [ekc], Garlali [gll], Punthamara [xpt], Wangkumara [xwk], and Badjiri [jbi]	2013-01-23
nlr	Ngarla	S		Split into Ngarla [nrk] and Yinhawangka [ywg]	2013-01-23
pcr	Panang	M	adx		2013-01-23
ppr	Piru	M	lcq		2013-01-23
tgg	Tangga	S		Split into Fanamaket [bjp], Niwer Mil [hrc], and Warwar Feni [hrw]	2013-01-23
wit	Wintu	S		Split into Wintu [wnw], Nomlaki [nol], and Patwin [pwi]	2013-01-23
xia	Xiandao	M	acn		2013-01-23
yiy	Yir Yoront	S		Split into Yir Yoront [yyr] and Yirrk-Mel [yrm]	2013-01-23
yos	Yos	M	zom		2013-01-23
emo	Emok	N			2014-02-03
ggm	Gugu Mini	N			2014-02-03
leg	Lengua	S		Split into Enlhet [enl] and Enxet [enx]	2014-02-03
lmm	Lamam	M	rmx		2014-02-03
mhh	Maskoy Pidgin	N			2014-02-03
puz	Purum Naga	M	pub		2014-02-03
sap	Sanapaná	S		Split into Sanapaná [spn] and Angaité [aqt]	2014-02-03
yuu	Yugh	M	yug		2014-02-03
aam	Aramanik	M	aas		2015-01-12
adp	Adap	M	dzo		2015-01-12
aue	ǂKxʼauǁʼein	D	ktz		2015-01-12
bmy	Bemba (Democratic Republic of Congo)	N			2015-01-12
bxx	Borna (Democratic Republic of Congo)	N			2015-01-12
byy	Buya	N			2015-01-12
dzd	Daza	N			2015-01-12
gfx	Mangetti Dune ǃXung	M	vaj		2015-01-12
gti	Gbati-ri	M	nyc		2015-01-12
ime	Imeraguen	N			2015-01-12
kbf	Kakauhua	N			2015-01-12
koj	Sara Dunjo	M	kwv		2015-01-12
kwq	Kwak	M	yam		2015-01-12
kxe	Kakihum	M	tvd		2015-01-12
lii	Lingkhim	M	raq		2015-01-12
mwj	Maligo	M	vaj		2015-01-12
nnx	Ngong	M	ngv		2015-01-12
oun	ǃOǃung	M	vaj		2015-01-12
pmu	Mirpur Panjabi	M	phr		2015-01-12
sgo	Songa	N			2015-01-12
thx	The	D	oyb		2015-01-12
tsf	Southwestern Tamang	M	taj		2015-01-12
uok	Uokha	M	ema		2015-01-12
xsj	Subi	D	suj		2015-01-12
yds	Yiddish Sign Language	N			2015-01-12
ymt	Mator-Taygi-Karagas	D	ymt		2015-01-12
ynh	Yangho	N			2015-01-12
bgm	Baga Mboteni	D	bcg		2016-01-15
btl	Bhatola	N			2016-01-15
cbe	Chipiajes	N			2016-01-15
cbh	Cagua	N			2016-01-15
coy	Coyaima	M	pij		2016-01-15
cqu	Chilean Quechua	M	quh		2016-01-15
cum	Cumeral	N			2016-01-15
duj	Dhuwal	S		split into [dwu] Dhuwal and [dwy] Dhuwaya	2016-01-15
ggn	Eastern Gurung	M	gvr		2016-01-15
ggo	Southern Gondi	S		split into [esg] Aheri Gondi and [wsg] Adilabad Gondi	2016-01-15
guv	Gey	M	guv		2016-01-15
iap	Iapama	N			2016-01-15
ill	Iranun	S		Split into Iranun (Philippines) [ilp] and Iranun (Malaysia) [ilm]	2016-01-15
kgc	Kasseng	D	tdf		2016-01-15
kox	Coxima	N			2016-01-15
ktr	Kota Marudu Tinagas	M	dtp		2016-01-15
kvs	Kunggara	D	gdj		2016-01-15
kzj	Coastal Kadazan	M	dtp		2016-01-15
kzt	Tambunan Dusun	M	dtp		2016-01-15
nad	Nijadali	D	xny		2016-01-15
nts	Natagaimas	M	pij		2016-01-15
ome	Omejes	N			2016-01-15
pmc	Palumata	D	huw		2016-01-15
pod	Ponares	N			2016-01-15
ppa	Pao	M	bfy		2016-01-15
pry	Pray 3	D	prt		2016-01-15
rna	Runa	N			2016-01-15
svr	Savara	N			2016-01-15
tdu	Tempasuk Dusun	M	dtp		2016-01-15
thc	Tai Hang Tong	M	tpo		2016-01-15
tid	Tidong	S		Split into Northern Tidung [ntd] and Southern Tidung [itd]	2016-01-15
tmp	Tai Mène	M	tyj		2016-01-15
tne	Tinoc Kallahan	M	kak		2016-01-15
toe	Tomedes	N			2016-01-15
xba	Kamba (Brazil)	D	cax		2016-01-15
xbx	Kabixí	N			2016-01-15
xip	Xipináwa	N			2016-01-15
xkh	Karahawyana	D	waw		2016-01-15
yri	Yarí	N			2016-01-15
jeg	Jeng	M	oyb		2017-01-31
kgd	Kataang	S		Split into [ncq] Northern Katang and [sct] Southern Katang	2017-01-31
krm	Krim	M	bmf		2017-01-31
prb	Lua'	N			2017-01-31
puk	Pu Ko	N			2017-01-31
rie	Rien	N			2017-01-31
rsi	Rennellese Sign Language	N			2017-01-31
skk	Sok	M	oyb		2017-01-31
snh	Shinabo	N			2017-01-31
lsg	Lyons Sign Language	N			2018-01-23
mwx	Mediak	N			2018-01-23
mwy	Mosiro	N			2018-01-23
ncp	Ndaktup	M	kdz		2018-01-23
ais	Nataoran Amis	S		Split by part going to Amis [ami] and creating Sakizaya [szy] with the remaining part	2019-01-25
asd	Asas	M	snz		2019-01-25
dit	Dirari	M	dif		2019-01-25
dud	Hun-Saare	S		Split into ut-Hun [uth] and us-Saare [uss]	2019-01-25
lba	Lui	N			2019-01-25
llo	Khlor	D	ngt		2019-01-25
myd	Maramba	M	aog		2019-01-25
myi	Mina (India)	N			2019-01-25
nns	Ningye	M	nbr		2019-01-25
aoh	Arma	N			2020-01-23
ayy	Tayabas Ayta	N			2020-01-23
bbz	Babalia Creole Arabic	N			2020-01-23
bpb	Barbacoas	N			2020-01-23
cca	Cauca	N			2020-01-23
cdg	Chamari	N			2020-01-23
dgu	Degaru	N			2020-01-23
drr	Dororo	M	kzk		2020-01-23
ekc	Eastern Karnic	N			2020-01-23
gli	Guliguli	M	kzk		2020-01-23
kjf	Khalaj	N			2020-01-23
kxl	Nepali Kurux	M	kru		2020-01-23
kxu	Kui (India)	S		Split into [dwk] Dawik Kui and [uki] Kui (India)	2020-01-23
lmz	Lumbee	N			2020-01-23
nxu	Narau	M	bpp		2020-01-23
plp	Palpa	N			2020-01-23
sdm	Semandang	S		Split into Semandang [sdq], Beginci [ebc] and Gerai [gef]	2020-01-23
tbb	Tapeba	N			2020-01-23
xrq	Karranga	M	dmw		2020-01-23
xtz	Tasmanian	S		Split into [xpv] Northern Tasman,  [xph] North Midlands Tasman, [xpb] Northeastern Tasman, [xpd] Oyster Bay Tasmanian, [xpf] Southeast Tasma, [xpx] Southwestern Tasman, [xpw] Northwestern Tasman., [xpl] Port Sorell Tasman. and [xpz] Bruny Island Tasman.	2020-01-23
zir	Ziriya	D	scv		2020-01-23