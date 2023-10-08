#!/usr/bin/env perl
#-*-perl-*-
#
#

## make this a module
package ISO::15924;

# use 5.006;
use strict;
use warnings;

use utf8;
use open ':locale';
use Pod::Usage;
use Unicode::UCD;
use ISO::639::3;
use Text::Iconv;

=head1 NAME

ISO::15924 - Language scripts

=head1 VERSION

Version 0.02

=cut

our $VERSION      = '0.02';

use Exporter 'import';
our @EXPORT = qw(
    script_name
    script_code
    script_of_string
    contains_script
    detect_chinese_script
    simplified_or_traditional_chinese
    language_scripts
    default_script
    languages_with_script
    language_territory
    language_territories
    default_territory
    primary_territories
    secondary_territories
    primary_languages_with_script
    secondary_languages_with_script
);
our %EXPORT_TAGS = ( all => \@EXPORT );

our $VERBOSE = 0;


=head1 SYNOPSIS

    use ISO::15924 qw/:all/;

=cut

our $ScriptCode2ScriptName;
our $ScriptName2ScriptCode;
our $ScriptId2ScriptCode;
our $ScriptCode2EnglishName;
our $ScriptCode2FrenchName;

our $ScriptCodeId;
our $ScriptCodeVersion;
our $ScriptCodeDate;


our $Lang2Territory;
our $Lang2Script;
our $Territory2Lang;
our $Script2Lang;
our $DefaultScript;
our $DefaultTerritory;


## for detecting Chinese scripts (traditional vs simplified)

our $ChineseScriptProportion = 0.8;

my $utf8big5_converter1 = Text::Iconv->new("UTF-8", "big5//TRANSLIT");
my $utf8big5_converter2 = Text::Iconv->new("UTF-8", "big5//IGNORE");

my $utf8gb2312_converter1 = Text::Iconv->new("UTF-8", "gb2312//TRANSLIT");
my $utf8gb2312_converter2 = Text::Iconv->new("UTF-8", "gb2312//IGNORE");

my $big5utf8_converter = Text::Iconv->new("big5", "UTF-8");
my $gb2312utf8_converter = Text::Iconv->new("gb2312", "UTF-8");

$ScriptCode2ScriptName = {
  'Gonm' => 'Masaram_Gondi',
  'Ahom' => 'Ahom',
  'Marc' => 'Marchen',
  'Soyo' => 'Soyombo',
  'Lepc' => 'Lepcha',
  'Egyd' => '',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Gujr' => 'Gujarati',
  'Laoo' => 'Lao',
  'Kits' => 'Khitan_Small_Script',
  'Qabx' => '',
  'Roro' => '',
  'Kore' => '',
  'Phnx' => 'Phoenician',
  'Armi' => 'Imperial_Aramaic',
  'Mroo' => 'Mro',
  'Brai' => 'Braille',
  'Kali' => 'Kayah_Li',
  'Toto' => '',
  'Phli' => 'Inscriptional_Pahlavi',
  'Elym' => 'Elymaic',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Shrd' => 'Sharada',
  'Tirh' => 'Tirhuta',
  'Sind' => 'Khudawadi',
  'Jamo' => '',
  'Lana' => 'Tai_Tham',
  'Latg' => '',
  'Sarb' => 'Old_South_Arabian',
  'Phlv' => '',
  'Loma' => '',
  'Batk' => 'Batak',
  'Sogd' => 'Sogdian',
  'Phag' => 'Phags_Pa',
  'Bali' => 'Balinese',
  'Zzzz' => 'Unknown',
  'Hans' => '',
  'Wole' => '',
  'Geor' => 'Georgian',
  'Cans' => 'Canadian_Aboriginal',
  'Hira' => 'Hiragana',
  'Mymr' => 'Myanmar',
  'Mahj' => 'Mahajani',
  'Hmng' => 'Pahawh_Hmong',
  'Bhks' => 'Bhaiksuki',
  'Cirt' => '',
  'Sora' => 'Sora_Sompeng',
  'Takr' => 'Takri',
  'Hung' => 'Old_Hungarian',
  'Diak' => 'Dives_Akuru',
  'Hano' => 'Hanunoo',
  'Sara' => '',
  'Prti' => 'Inscriptional_Parthian',
  'Kitl' => '',
  'Runr' => 'Runic',
  'Orkh' => 'Old_Turkic',
  'Xsux' => 'Cuneiform',
  'Cari' => 'Carian',
  'Copt' => 'Coptic',
  'Mlym' => 'Malayalam',
  'Teng' => '',
  'Syre' => '',
  'Elba' => 'Elbasan',
  'Buhd' => 'Buhid',
  'Nand' => 'Nandinagari',
  'Nkgb' => '',
  'Nkdb' => '',
  'Medf' => 'Medefaidrin',
  'Gong' => 'Gunjala_Gondi',
  'Sgnw' => 'SignWriting',
  'Thai' => 'Thai',
  'Knda' => 'Kannada',
  'Glag' => 'Glagolitic',
  'Hang' => 'Hangul',
  'Ethi' => 'Ethiopic',
  'Sylo' => 'Syloti_Nagri',
  'Modi' => 'Modi',
  'Perm' => 'Old_Permic',
  'Brah' => 'Brahmi',
  'Inds' => '',
  'Telu' => 'Telugu',
  'Hani' => 'Han',
  'Dsrt' => 'Deseret',
  'Sinh' => 'Sinhala',
  'Guru' => 'Gurmukhi',
  'Ital' => 'Old_Italic',
  'Egyh' => '',
  'Cher' => 'Cherokee',
  'Java' => 'Javanese',
  'Mult' => 'Multani',
  'Mend' => 'Mende_Kikakui',
  'Bamu' => 'Bamum',
  'Zsye' => '',
  'Rohg' => 'Hanifi_Rohingya',
  'Sogo' => 'Old_Sogdian',
  'Zsym' => '',
  'Grek' => 'Greek',
  'Saur' => 'Saurashtra',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Aghb' => 'Caucasian_Albanian',
  'Xpeo' => 'Old_Persian',
  'Tglg' => 'Tagalog',
  'Tang' => 'Tangut',
  'Samr' => 'Samaritan',
  'Nkoo' => 'Nko',
  'Leke' => '',
  'Narb' => 'Old_North_Arabian',
  'Tfng' => 'Tifinagh',
  'Khmr' => 'Khmer',
  'Shaw' => 'Shavian',
  'Hanb' => '',
  'Plrd' => 'Miao',
  'Maka' => 'Makasar',
  'Goth' => 'Gothic',
  'Syrj' => '',
  'Khoj' => 'Khojki',
  'Kthi' => 'Kaithi',
  'Avst' => 'Avestan',
  'Latf' => '',
  'Shui' => '',
  'Sund' => 'Sundanese',
  'Linb' => 'Linear_B',
  'Arab' => 'Arabic',
  'Syrn' => '',
  'Phlp' => 'Psalter_Pahlavi',
  'Armn' => 'Armenian',
  'Cprt' => 'Cypriot',
  'Moon' => '',
  'Geok' => 'Georgian',
  'Palm' => 'Palmyrene',
  'Kana' => 'Katakana',
  'Talu' => 'New_Tai_Lue',
  'Cakm' => 'Chakma',
  'Syrc' => 'Syriac',
  'Kpel' => '',
  'Wara' => 'Warang_Citi',
  'Tibt' => 'Tibetan',
  'Zanb' => 'Zanabazar_Square',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Dogr' => 'Dogra',
  'Adlm' => 'Adlam',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Mani' => 'Manichaean',
  'Sidd' => 'Siddham',
  'Gran' => 'Grantha',
  'Zxxx' => '',
  'Yiii' => 'Yi',
  'Cyrl' => 'Cyrillic',
  'Latn' => 'Latin',
  'Mand' => 'Mandaic',
  'Newa' => 'Newa',
  'Zinh' => 'Inherited',
  'Rjng' => 'Rejang',
  'Nshu' => 'Nushu',
  'Pauc' => 'Pau_Cin_Hau',
  'Merc' => 'Meroitic_Cursive',
  'Zmth' => '',
  'Nbat' => 'Nabataean',
  'Lydi' => 'Lydian',
  'Mtei' => 'Meetei_Mayek',
  'Aran' => '',
  'Lyci' => 'Lycian',
  'Bugi' => 'Buginese',
  'Jurc' => '',
  'Chrs' => 'Chorasmian',
  'Bass' => 'Bassa_Vah',
  'Lisu' => 'Lisu',
  'Orya' => 'Oriya',
  'Hatr' => 'Hatran',
  'Tavt' => 'Tai_Viet',
  'Vaii' => 'Vai',
  'Limb' => 'Limbu',
  'Thaa' => 'Thaana',
  'Ogam' => 'Ogham',
  'Zyyy' => 'Common',
  'Cpmn' => '',
  'Dupl' => 'Duployan',
  'Qaaa' => '',
  'Deva' => 'Devanagari',
  'Blis' => '',
  'Tale' => 'Tai_Le',
  'Osge' => 'Osage',
  'Maya' => '',
  'Hebr' => 'Hebrew',
  'Beng' => 'Bengali',
  'Ugar' => 'Ugaritic',
  'Jpan' => '',
  'Bopo' => 'Bopomofo',
  'Osma' => 'Osmanya',
  'Taml' => 'Tamil',
  'Mong' => 'Mongolian',
  'Tagb' => 'Tagbanwa',
  'Olck' => 'Ol_Chiki',
  'Piqd' => '',
  'Visp' => '',
  'Cham' => 'Cham',
  'Afak' => '',
  'Yezi' => 'Yezidi',
  'Hant' => '',
  'Lina' => 'Linear_A',
  'Cyrs' => '',
  'Wcho' => 'Wancho',
  'Khar' => 'Kharoshthi'
};
$ScriptName2ScriptCode = {
  'Balinese' => 'Bali',
  '' => 'Zxxx',
  'Ogham' => 'Ogam',
  'Old_Sogdian' => 'Sogo',
  'Glagolitic' => 'Glag',
  'Tai_Viet' => 'Tavt',
  'Wancho' => 'Wcho',
  'Hangul' => 'Hang',
  'Katakana' => 'Kana',
  'Ahom' => 'Ahom',
  'Limbu' => 'Limb',
  'Mahajani' => 'Mahj',
  'Yezidi' => 'Yezi',
  'Kannada' => 'Knda',
  'Bassa_Vah' => 'Bass',
  'Mandaic' => 'Mand',
  'Warang_Citi' => 'Wara',
  'Psalter_Pahlavi' => 'Phlp',
  'Chakma' => 'Cakm',
  'Grantha' => 'Gran',
  'Kayah_Li' => 'Kali',
  'Arabic' => 'Arab',
  'Buhid' => 'Buhd',
  'Telugu' => 'Telu',
  'Braille' => 'Brai',
  'Mongolian' => 'Mong',
  'Tai_Le' => 'Tale',
  'Rejang' => 'Rjng',
  'Nushu' => 'Nshu',
  'Makasar' => 'Maka',
  'Syloti_Nagri' => 'Sylo',
  'Gothic' => 'Goth',
  'Malayalam' => 'Mlym',
  'Old_South_Arabian' => 'Sarb',
  'Saurashtra' => 'Saur',
  'Meetei_Mayek' => 'Mtei',
  'Old_Turkic' => 'Orkh',
  'Kharoshthi' => 'Khar',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'New_Tai_Lue' => 'Talu',
  'Tibetan' => 'Tibt',
  'Sharada' => 'Shrd',
  'Nabataean' => 'Nbat',
  'Gujarati' => 'Gujr',
  'Tai_Tham' => 'Lana',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Duployan' => 'Dupl',
  'Dogra' => 'Dogr',
  'Nandinagari' => 'Nand',
  'Hanifi_Rohingya' => 'Rohg',
  'Runic' => 'Runr',
  'Dives_Akuru' => 'Diak',
  'Elymaic' => 'Elym',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Georgian' => 'Geor',
  'Phags_Pa' => 'Phag',
  'Kaithi' => 'Kthi',
  'Linear_A' => 'Lina',
  'Tifinagh' => 'Tfng',
  'Tagbanwa' => 'Tagb',
  'Miao' => 'Plrd',
  'Gunjala_Gondi' => 'Gong',
  'Tagalog' => 'Tglg',
  'Osmanya' => 'Osma',
  'Common' => 'Zyyy',
  'SignWriting' => 'Sgnw',
  'Zanabazar_Square' => 'Zanb',
  'Inherited' => 'Zinh',
  'Latin' => 'Latn',
  'Inscriptional_Pahlavi' => 'Phli',
  'Imperial_Aramaic' => 'Armi',
  'Lepcha' => 'Lepc',
  'Inscriptional_Parthian' => 'Prti',
  'Palmyrene' => 'Palm',
  'Khmer' => 'Khmr',
  'Lao' => 'Laoo',
  'Coptic' => 'Copt',
  'Nko' => 'Nkoo',
  'Manichaean' => 'Mani',
  'Caucasian_Albanian' => 'Aghb',
  'Myanmar' => 'Mymr',
  'Old_Italic' => 'Ital',
  'Samaritan' => 'Samr',
  'Medefaidrin' => 'Medf',
  'Mende_Kikakui' => 'Mend',
  'Hiragana' => 'Hira',
  'Bopomofo' => 'Bopo',
  'Avestan' => 'Avst',
  'Bhaiksuki' => 'Bhks',
  'Tirhuta' => 'Tirh',
  'Newa' => 'Newa',
  'Lydian' => 'Lydi',
  'Phoenician' => 'Phnx',
  'Cypriot' => 'Cprt',
  'Vai' => 'Vaii',
  'Hebrew' => 'Hebr',
  'Carian' => 'Cari',
  'Syriac' => 'Syrc',
  'Ol_Chiki' => 'Olck',
  'Lycian' => 'Lyci',
  'Thai' => 'Thai',
  'Bamum' => 'Bamu',
  'Greek' => 'Grek',
  'Lisu' => 'Lisu',
  'Pahawh_Hmong' => 'Hmng',
  'Sinhala' => 'Sinh',
  'Sora_Sompeng' => 'Sora',
  'Osage' => 'Osge',
  'Mro' => 'Mroo',
  'Khudawadi' => 'Sind',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Khitan_Small_Script' => 'Kits',
  'Old_Persian' => 'Xpeo',
  'Hatran' => 'Hatr',
  'Takri' => 'Takr',
  'Javanese' => 'Java',
  'Bengali' => 'Beng',
  'Old_Permic' => 'Perm',
  'Multani' => 'Mult',
  'Elbasan' => 'Elba',
  'Devanagari' => 'Deva',
  'Yi' => 'Yiii',
  'Khojki' => 'Khoj',
  'Masaram_Gondi' => 'Gonm',
  'Ugaritic' => 'Ugar',
  'Shavian' => 'Shaw',
  'Tamil' => 'Taml',
  'Cuneiform' => 'Xsux',
  'Armenian' => 'Armn',
  'Soyombo' => 'Soyo',
  'Thaana' => 'Thaa',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Meroitic_Cursive' => 'Merc',
  'Modi' => 'Modi',
  'Sogdian' => 'Sogd',
  'Old_North_Arabian' => 'Narb',
  'Batak' => 'Batk',
  'Marchen' => 'Marc',
  'Cyrillic' => 'Cyrl',
  'Linear_B' => 'Linb',
  'Chorasmian' => 'Chrs',
  'Gurmukhi' => 'Guru',
  'Tangut' => 'Tang',
  'Pau_Cin_Hau' => 'Pauc',
  'Unknown' => 'Zzzz',
  'Deseret' => 'Dsrt',
  'Canadian_Aboriginal' => 'Cans',
  'Adlam' => 'Adlm',
  'Brahmi' => 'Brah',
  'Ethiopic' => 'Ethi',
  'Hanunoo' => 'Hano',
  'Han' => 'Hani',
  'Cherokee' => 'Cher',
  'Buginese' => 'Bugi',
  'Siddham' => 'Sidd',
  'Cham' => 'Cham',
  'Sundanese' => 'Sund',
  'Oriya' => 'Orya',
  'Old_Hungarian' => 'Hung'
};
$ScriptId2ScriptCode = {
  '993' => 'Zsye',
  '293' => 'Piqd',
  '348' => 'Sinh',
  '334' => 'Bhks',
  '331' => 'Phag',
  '420' => 'Nkgb',
  '316' => 'Sylo',
  '100' => 'Mero',
  '030' => 'Xpeo',
  '480' => 'Wole',
  '352' => 'Thai',
  '345' => 'Knda',
  '503' => 'Hanb',
  '216' => 'Latg',
  '367' => 'Bugi',
  '501' => 'Hans',
  '175' => 'Orkh',
  '210' => 'Ital',
  '202' => 'Lyci',
  '090' => 'Maya',
  '333' => 'Newa',
  '310' => 'Guru',
  '437' => 'Loma',
  '106' => 'Narb',
  '291' => 'Cirt',
  '294' => 'Toto',
  '165' => 'Nkoo',
  '302' => 'Sidd',
  '994' => 'Zinh',
  '160' => 'Arab',
  '451' => 'Hmnp',
  '520' => 'Tang',
  '239' => 'Aghb',
  '218' => 'Moon',
  '315' => 'Deva',
  '095' => 'Sgnw',
  '403' => 'Cprt',
  '346' => 'Taml',
  '123' => 'Samr',
  '142' => 'Sogo',
  '339' => 'Zanb',
  '215' => 'Latn',
  '170' => 'Thaa',
  '318' => 'Sind',
  '262' => 'Wara',
  '176' => 'Hung',
  '340' => 'Telu',
  '372' => 'Buhd',
  '124' => 'Armi',
  '999' => 'Zzzz',
  '401' => 'Linb',
  '105' => 'Sarb',
  '362' => 'Sund',
  '399' => 'Lisu',
  '240' => 'Geor',
  '357' => 'Kali',
  '166' => 'Adlm',
  '510' => 'Jurc',
  '353' => 'Tale',
  '499' => 'Nshu',
  '285' => 'Bopo',
  '201' => 'Cari',
  '204' => 'Copt',
  '502' => 'Hant',
  '325' => 'Beng',
  '440' => 'Cans',
  '288' => 'Kits',
  '130' => 'Prti',
  '292' => 'Sara',
  '328' => 'Dogr',
  '225' => 'Glag',
  '439' => 'Afak',
  '332' => 'Marc',
  '050' => 'Egyp',
  '136' => 'Syrn',
  '127' => 'Hatr',
  '354' => 'Talu',
  '351' => 'Lana',
  '060' => 'Egyh',
  '371' => 'Hano',
  '286' => 'Hang',
  '402' => 'Cpmn',
  '264' => 'Mroo',
  '261' => 'Olck',
  '326' => 'Tirh',
  '337' => 'Mtei',
  '410' => 'Hira',
  '364' => 'Leke',
  '361' => 'Java',
  '070' => 'Egyd',
  '226' => 'Elba',
  '220' => 'Cyrl',
  '363' => 'Rjng',
  '359' => 'Tavt',
  '135' => 'Syrc',
  '445' => 'Cher',
  '141' => 'Sogd',
  '320' => 'Gujr',
  '263' => 'Pauc',
  '997' => 'Zxxx',
  '138' => 'Syre',
  '373' => 'Tagb',
  '259' => 'Bass',
  '280' => 'Visp',
  '284' => 'Jamo',
  '281' => 'Shaw',
  '140' => 'Mand',
  '317' => 'Kthi',
  '321' => 'Takr',
  '324' => 'Modi',
  '430' => 'Ethi',
  '413' => 'Jpan',
  '080' => 'Hluw',
  '305' => 'Khar',
  '020' => 'Xsux',
  '366' => 'Maka',
  '221' => 'Cyrs',
  '217' => 'Latf',
  '360' => 'Bali',
  '755' => 'Dupl',
  '358' => 'Cham',
  '115' => 'Phnx',
  '260' => 'Osma',
  '436' => 'Kpel',
  '323' => 'Mult',
  '411' => 'Kana',
  '283' => 'Wcho',
  '355' => 'Khmr',
  '139' => 'Mani',
  '342' => 'Diak',
  '370' => 'Tglg',
  '530' => 'Shui',
  '206' => 'Goth',
  '350' => 'Mymr',
  '265' => 'Medf',
  '133' => 'Phlv',
  '250' => 'Dsrt',
  '347' => 'Mlym',
  '329' => 'Soyo',
  '365' => 'Batk',
  '438' => 'Mend',
  '312' => 'Gong',
  '131' => 'Phli',
  '134' => 'Avst',
  '610' => 'Inds',
  '116' => 'Lydi',
  '300' => 'Brah',
  '085' => 'Nkdb',
  '435' => 'Bamu',
  '212' => 'Ogam',
  '145' => 'Mong',
  '900' => 'Qaaa',
  '200' => 'Grek',
  '356' => 'Laoo',
  '167' => 'Rohg',
  '241' => 'Geok',
  '040' => 'Ugar',
  '159' => 'Nbat',
  '335' => 'Lepc',
  '219' => 'Osge',
  '570' => 'Brai',
  '344' => 'Saur',
  '120' => 'Tfng',
  '400' => 'Lina',
  '412' => 'Hrkt',
  '338' => 'Ahom',
  '319' => 'Shrd',
  '322' => 'Khoj',
  '505' => 'Kitl',
  '109' => 'Chrs',
  '998' => 'Zyyy',
  '620' => 'Roro',
  '126' => 'Palm',
  '137' => 'Syrj',
  '343' => 'Gran',
  '282' => 'Plrd',
  '995' => 'Zmth',
  '161' => 'Aran',
  '398' => 'Sora',
  '450' => 'Hmng',
  '287' => 'Kore',
  '470' => 'Vaii',
  '290' => 'Teng',
  '132' => 'Phlp',
  '349' => 'Cakm',
  '336' => 'Limb',
  '311' => 'Nand',
  '314' => 'Mahj',
  '327' => 'Orya',
  '949' => 'Qabx',
  '460' => 'Yiii',
  '500' => 'Hani',
  '227' => 'Perm',
  '211' => 'Runr',
  '192' => 'Yezi',
  '230' => 'Armn',
  '125' => 'Hebr',
  '313' => 'Gonm',
  '330' => 'Tibt',
  '550' => 'Blis',
  '101' => 'Merc',
  '128' => 'Elym',
  '996' => 'Zsym'
};
$ScriptCode2EnglishName = {
  'Chrs' => 'Chorasmian',
  'Jurc' => 'Jurchen',
  'Bugi' => 'Buginese',
  'Lyci' => 'Lycian',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Bass' => 'Bassa Vah',
  'Tavt' => 'Tai Viet',
  'Hatr' => 'Hatran',
  'Orya' => 'Oriya (Odia)',
  'Lisu' => 'Lisu (Fraser)',
  'Ogam' => 'Ogham',
  'Thaa' => 'Thaana',
  'Limb' => 'Limbu',
  'Vaii' => 'Vai',
  'Nshu' => "N\x{fc}shu",
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Zinh' => 'Code for inherited script',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Pauc' => 'Pau Cin Hau',
  'Nbat' => 'Nabataean',
  'Zmth' => 'Mathematical notation',
  'Merc' => 'Meroitic Cursive',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Lydi' => 'Lydian',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Tagb' => 'Tagbanwa',
  'Mong' => 'Mongolian',
  'Taml' => 'Tamil',
  'Cham' => 'Cham',
  'Visp' => 'Visible Speech',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Hant' => 'Han (Traditional variant)',
  'Yezi' => 'Yezidi',
  'Afak' => 'Afaka',
  'Khar' => 'Kharoshthi',
  'Wcho' => 'Wancho',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Lina' => 'Linear A',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Cpmn' => 'Cypro-Minoan',
  'Zyyy' => 'Code for undetermined script',
  'Deva' => 'Devanagari (Nagari)',
  'Qaaa' => 'Reserved for private use (start)',
  'Ugar' => 'Ugaritic',
  'Beng' => 'Bengali (Bangla)',
  'Hebr' => 'Hebrew',
  'Maya' => 'Mayan hieroglyphs',
  'Osge' => 'Osage',
  'Tale' => 'Tai Le',
  'Blis' => 'Blissymbols',
  'Osma' => 'Osmanya',
  'Bopo' => 'Bopomofo',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Syrj' => 'Syriac (Western variant)',
  'Goth' => 'Gothic',
  'Latf' => 'Latin (Fraktur variant)',
  'Avst' => 'Avestan',
  'Kthi' => 'Kaithi',
  'Khoj' => 'Khojki',
  'Syrn' => 'Syriac (Eastern variant)',
  'Arab' => 'Arabic',
  'Linb' => 'Linear B',
  'Sund' => 'Sundanese',
  'Shui' => 'Shuishu',
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Xpeo' => 'Old Persian',
  'Aghb' => 'Caucasian Albanian',
  'Leke' => 'Leke',
  'Nkoo' => "N\x{2019}Ko",
  'Tang' => 'Tangut',
  'Samr' => 'Samaritan',
  'Shaw' => 'Shavian (Shaw)',
  'Khmr' => 'Khmer',
  'Tfng' => 'Tifinagh (Berber)',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Maka' => 'Makasar',
  'Plrd' => 'Miao (Pollard)',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Kpel' => 'Kpelle',
  'Syrc' => 'Syriac',
  'Dogr' => 'Dogra',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Tibt' => 'Tibetan',
  'Gran' => 'Grantha',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Egyp' => 'Egyptian hieroglyphs',
  'Mani' => 'Manichaean',
  'Adlm' => 'Adlam',
  'Mand' => 'Mandaic, Mandaean',
  'Latn' => 'Latin',
  'Cyrl' => 'Cyrillic',
  'Yiii' => 'Yi',
  'Zxxx' => 'Code for unwritten documents',
  'Phlp' => 'Psalter Pahlavi',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Cprt' => 'Cypriot syllabary',
  'Armn' => 'Armenian',
  'Palm' => 'Palmyrene',
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Cakm' => 'Chakma',
  'Talu' => 'New Tai Lue',
  'Kana' => 'Katakana',
  'Elba' => 'Elbasan',
  'Syre' => 'Syriac (Estrangelo variant)',
  'Nand' => 'Nandinagari',
  'Buhd' => 'Buhid',
  'Knda' => 'Kannada',
  'Thai' => 'Thai',
  'Sgnw' => 'SignWriting',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Gong' => 'Gunjala Gondi',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Glag' => 'Glagolitic',
  'Prti' => 'Inscriptional Parthian',
  'Sara' => 'Sarati',
  'Runr' => 'Runic',
  'Kitl' => 'Khitan large script',
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Teng' => 'Tengwar',
  'Mlym' => 'Malayalam',
  'Copt' => 'Coptic',
  'Cari' => 'Carian',
  'Cher' => 'Cherokee',
  'Egyh' => 'Egyptian hieratic',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Sogo' => 'Old Sogdian',
  'Rohg' => 'Hanifi Rohingya',
  'Zsye' => 'Symbols (Emoji variant)',
  'Bamu' => 'Bamum',
  'Mend' => 'Mende Kikakui',
  'Mult' => 'Multani',
  'Java' => 'Javanese',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Grek' => 'Greek',
  'Saur' => 'Saurashtra',
  'Zsym' => 'Symbols',
  'Perm' => 'Old Permic',
  'Sylo' => 'Syloti Nagri',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Telu' => 'Telugu',
  'Inds' => 'Indus (Harappan)',
  'Brah' => 'Brahmi',
  'Sinh' => 'Sinhala',
  'Dsrt' => 'Deseret (Mormon)',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Guru' => 'Gurmukhi',
  'Mroo' => 'Mro, Mru',
  'Toto' => 'Toto',
  'Kali' => 'Kayah Li',
  'Brai' => 'Braille',
  'Mero' => 'Meroitic Hieroglyphs',
  'Elym' => 'Elymaic',
  'Phli' => 'Inscriptional Pahlavi',
  'Lana' => 'Tai Tham (Lanna)',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Sind' => 'Khudawadi, Sindhi',
  'Tirh' => 'Tirhuta',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Marc' => 'Marchen',
  'Ahom' => 'Ahom, Tai Ahom',
  'Gonm' => 'Masaram Gondi',
  'Kits' => 'Khitan small script',
  'Laoo' => 'Lao',
  'Gujr' => 'Gujarati',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Egyd' => 'Egyptian demotic',
  'Soyo' => 'Soyombo',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Qabx' => 'Reserved for private use (end)',
  'Armi' => 'Imperial Aramaic',
  'Phnx' => 'Phoenician',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Roro' => 'Rongorongo',
  'Hira' => 'Hiragana',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Mymr' => 'Myanmar (Burmese)',
  'Bhks' => 'Bhaiksuki',
  'Hmng' => 'Pahawh Hmong',
  'Mahj' => 'Mahajani',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Diak' => 'Dives Akuru',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Sora' => 'Sora Sompeng',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Cirt' => 'Cirth',
  'Batk' => 'Batak',
  'Loma' => 'Loma',
  'Phlv' => 'Book Pahlavi',
  'Sarb' => 'Old South Arabian',
  'Latg' => 'Latin (Gaelic variant)',
  'Phag' => 'Phags-pa',
  'Sogd' => 'Sogdian',
  'Hans' => 'Han (Simplified variant)',
  'Zzzz' => 'Code for uncoded script',
  'Bali' => 'Balinese',
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Wole' => 'Woleai'
};
$ScriptCode2FrenchName = {
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Bali' => 'balinais',
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Wole' => "wol\x{e9}a\x{ef}",
  'Loma' => 'loma',
  'Batk' => 'batik',
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Phlv' => 'pehlevi des livres',
  'Sarb' => 'sud-arabique, himyarite',
  'Sogd' => 'sogdien',
  'Phag' => "\x{2019}phags pa",
  'Hmng' => 'pahawh hmong',
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Hano' => "hanoun\x{f3}o",
  'Diak' => 'dives akuru',
  'Sora' => 'sora sompeng',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Cirt' => 'cirth',
  'Hira' => 'hiragana',
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Mymr' => 'birman',
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Phnx' => "ph\x{e9}nicien",
  'Roro' => 'rongorongo',
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Ahom' => "\x{e2}hom",
  'Marc' => 'marchen',
  'Gonm' => "masaram gond\x{ee}",
  'Laoo' => 'laotien',
  'Kits' => "petite \x{e9}criture khitan",
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Soyo' => 'soyombo',
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Phli' => 'pehlevi des inscriptions',
  'Lana' => "ta\x{ef} tham (lanna)",
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Shrd' => 'charada, shard',
  'Tirh' => 'tirhouta',
  'Mroo' => 'mro',
  'Toto' => 'toto',
  'Kali' => 'kayah li',
  'Brai' => 'braille',
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Sinh' => 'singhalais',
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Guru' => "gourmoukh\x{ee}",
  'Perm' => 'ancien permien',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Modi' => "mod\x{ee}",
  'Telu' => "t\x{e9}lougou",
  'Inds' => 'indus',
  'Brah' => 'brahma',
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Saur' => 'saurachtra',
  'Grek' => 'grec',
  'Zsym' => 'symboles',
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Rohg' => 'hanifi rohingya',
  'Sogo' => 'ancien sogdien',
  'Bamu' => 'bamoum',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Mult' => "multan\x{ee}",
  'Java' => 'javanais',
  'Mend' => "mend\x{e9} kikakui",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Orkh' => 'orkhon',
  'Teng' => 'tengwar',
  'Copt' => 'copte',
  'Mlym' => "malay\x{e2}lam",
  'Cari' => 'carien',
  'Prti' => 'parthe des inscriptions',
  'Sara' => 'sarati',
  'Runr' => 'runique',
  'Kitl' => "grande \x{e9}criture khitan",
  'Knda' => 'kannara (canara)',
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Thai' => "tha\x{ef}",
  'Nkdb' => 'naxi dongba',
  'Nkgb' => 'naxi geba, nakhi geba',
  'Gong' => "gunjala gond\x{ee}",
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Glag' => 'glagolitique',
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Elba' => 'elbasan',
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Buhd' => 'bouhide',
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Palm' => "palmyr\x{e9}nien",
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Cakm' => 'chakma',
  'Kana' => 'katakana',
  'Talu' => "nouveau ta\x{ef}-lue",
  'Phlp' => 'pehlevi des psautiers',
  'Moon' => "\x{e9}criture Moon",
  'Cprt' => 'syllabaire chypriote',
  'Armn' => "arm\x{e9}nien",
  'Gran' => 'grantha',
  'Sidd' => 'siddham',
  'Adlm' => 'adlam',
  'Mani' => "manich\x{e9}en",
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Mand' => "mand\x{e9}en",
  'Cyrl' => 'cyrillique',
  'Latn' => 'latin',
  'Yiii' => 'yi',
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Wara' => 'warang citi',
  'Syrc' => 'syriaque',
  'Hmnp' => 'nyiakeng puachue hmong',
  'Dogr' => 'dogra',
  'Zanb' => 'zanabazar quadratique',
  'Tibt' => "tib\x{e9}tain",
  'Shaw' => 'shavien (Shaw)',
  'Khmr' => 'khmer',
  'Narb' => 'nord-arabique',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Maka' => 'makassar',
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Plrd' => 'miao (Pollard)',
  'Tglg' => 'tagal (baybayin, alibata)',
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Aghb' => 'aghbanien',
  'Leke' => "l\x{e9}k\x{e9}",
  'Tang' => 'tangoute',
  'Samr' => 'samaritain',
  'Nkoo' => "n\x{2019}ko",
  'Latf' => "latin (variante bris\x{e9}e)",
  'Avst' => 'avestique',
  'Khoj' => "khojk\x{ee}",
  'Kthi' => "kaith\x{ee}",
  'Syrn' => 'syriaque (variante orientale)',
  'Linb' => "lin\x{e9}aire B",
  'Arab' => 'arabe',
  'Sund' => 'sundanais',
  'Shui' => 'shuishu',
  'Syrj' => 'syriaque (variante occidentale)',
  'Goth' => 'gotique',
  'Hebr' => "h\x{e9}breu",
  'Ugar' => 'ougaritique',
  'Beng' => "bengal\x{ee} (bangla)",
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Tale' => "ta\x{ef}-le",
  'Blis' => 'symboles Bliss',
  'Osge' => 'osage',
  'Osma' => 'osmanais',
  'Bopo' => 'bopomofo',
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Cpmn' => 'syllabaire chypro-minoen',
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Yezi' => "y\x{e9}zidi",
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Afak' => 'afaka',
  'Khar' => "kharochth\x{ee}",
  'Wcho' => 'wantcho',
  'Lina' => "lin\x{e9}aire A",
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Olck' => 'ol tchiki',
  'Tagb' => 'tagbanoua',
  'Mong' => 'mongol',
  'Taml' => 'tamoul',
  'Cham' => "cham (\x{10d}am, tcham)",
  'Visp' => 'parole visible',
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Nbat' => "nabat\x{e9}en",
  'Zmth' => "notation math\x{e9}matique",
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Mtei' => 'meitei mayek',
  'Lydi' => 'lydien',
  'Nshu' => "n\x{fc}shu",
  'Rjng' => 'redjang (kaganga)',
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Pauc' => 'paou chin haou',
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Orya' => "oriy\x{e2} (odia)",
  'Hatr' => "hatr\x{e9}nien",
  'Lisu' => 'lisu (Fraser)',
  'Ogam' => 'ogam',
  'Thaa' => "th\x{e2}na",
  'Vaii' => "va\x{ef}",
  'Limb' => 'limbou',
  'Jurc' => 'jurchen',
  'Chrs' => 'chorasmien',
  'Lyci' => 'lycien',
  'Bugi' => 'bouguis',
  'Aran' => 'arabe (variante nastalique)',
  'Bass' => 'bassa'
};
$ScriptCodeVersion = {
  'Latn' => '1.1',
  'Cyrl' => '1.1',
  'Mand' => '6.0',
  'Zxxx' => '',
  'Yiii' => '3.0',
  'Gran' => '7.0',
  'Egyp' => '5.2',
  'Mani' => '7.0',
  'Adlm' => '9.0',
  'Sidd' => '7.0',
  'Dogr' => '11.0',
  'Hmnp' => '12.0',
  'Tibt' => '2.0',
  'Zanb' => '10.0',
  'Syrc' => '3.0',
  'Wara' => '7.0',
  'Kpel' => '',
  'Cakm' => '6.1',
  'Talu' => '4.1',
  'Kana' => '1.1',
  'Palm' => '7.0',
  'Geok' => '1.1',
  'Cprt' => '4.0',
  'Moon' => '',
  'Armn' => '1.1',
  'Phlp' => '7.0',
  'Syrn' => '3.0',
  'Sund' => '5.1',
  'Shui' => '',
  'Arab' => '1.1',
  'Linb' => '4.0',
  'Avst' => '5.2',
  'Latf' => '1.1',
  'Kthi' => '5.2',
  'Khoj' => '7.0',
  'Syrj' => '3.0',
  'Goth' => '3.1',
  'Plrd' => '6.1',
  'Hanb' => '1.1',
  'Maka' => '11.0',
  'Khmr' => '3.0',
  'Shaw' => '4.0',
  'Tfng' => '4.1',
  'Narb' => '7.0',
  'Leke' => '',
  'Nkoo' => '5.0',
  'Samr' => '5.2',
  'Tang' => '9.0',
  'Xpeo' => '4.1',
  'Tglg' => '3.2',
  'Aghb' => '7.0',
  'Wcho' => '12.0',
  'Khar' => '4.1',
  'Cyrs' => '1.1',
  'Lina' => '7.0',
  'Hant' => '1.1',
  'Yezi' => '13.0',
  'Afak' => '',
  'Visp' => '',
  'Cham' => '5.1',
  'Piqd' => '',
  'Tagb' => '3.2',
  'Olck' => '5.1',
  'Taml' => '1.1',
  'Mong' => '3.0',
  'Osma' => '4.0',
  'Jpan' => '1.1',
  'Bopo' => '1.1',
  'Beng' => '1.1',
  'Ugar' => '4.0',
  'Hebr' => '1.1',
  'Osge' => '9.0',
  'Blis' => '',
  'Tale' => '4.0',
  'Maya' => '',
  'Deva' => '1.1',
  'Qaaa' => '',
  'Dupl' => '7.0',
  'Cpmn' => '',
  'Zyyy' => '',
  'Thaa' => '3.0',
  'Ogam' => '3.0',
  'Vaii' => '5.1',
  'Limb' => '4.0',
  'Tavt' => '5.2',
  'Lisu' => '5.2',
  'Hatr' => '8.0',
  'Orya' => '1.1',
  'Bass' => '7.0',
  'Lyci' => '5.1',
  'Bugi' => '4.1',
  'Chrs' => '13.0',
  'Jurc' => '',
  'Aran' => '1.1',
  'Mtei' => '5.2',
  'Lydi' => '5.1',
  'Nbat' => '7.0',
  'Merc' => '6.1',
  'Zmth' => '3.2',
  'Pauc' => '7.0',
  'Rjng' => '5.1',
  'Nshu' => '10.0',
  'Newa' => '9.0',
  'Zinh' => '',
  'Diak' => '13.0',
  'Hano' => '3.2',
  'Hung' => '8.0',
  'Cirt' => '',
  'Takr' => '6.1',
  'Sora' => '6.1',
  'Bhks' => '9.0',
  'Hmng' => '7.0',
  'Mahj' => '7.0',
  'Mymr' => '3.0',
  'Hira' => '1.1',
  'Cans' => '3.0',
  'Geor' => '1.1',
  'Wole' => '',
  'Hans' => '1.1',
  'Bali' => '5.0',
  'Zzzz' => '',
  'Phag' => '5.0',
  'Sogd' => '11.0',
  'Batk' => '6.0',
  'Loma' => '',
  'Sarb' => '5.2',
  'Phlv' => '',
  'Latg' => '1.1',
  'Lana' => '5.2',
  'Tirh' => '7.0',
  'Shrd' => '6.1',
  'Jamo' => '1.1',
  'Sind' => '7.0',
  'Phli' => '5.2',
  'Mero' => '6.1',
  'Elym' => '12.0',
  'Kali' => '5.1',
  'Toto' => '',
  'Brai' => '3.0',
  'Mroo' => '7.0',
  'Phnx' => '5.0',
  'Armi' => '5.2',
  'Roro' => '',
  'Kore' => '1.1',
  'Qabx' => '',
  'Hluw' => '8.0',
  'Gujr' => '1.1',
  'Egyd' => '',
  'Kits' => '13.0',
  'Laoo' => '1.1',
  'Soyo' => '10.0',
  'Lepc' => '5.1',
  'Marc' => '9.0',
  'Ahom' => '8.0',
  'Gonm' => '10.0',
  'Hrkt' => '1.1',
  'Zsym' => '1.1',
  'Saur' => '5.1',
  'Grek' => '1.1',
  'Sogo' => '11.0',
  'Rohg' => '11.0',
  'Mend' => '7.0',
  'Mult' => '8.0',
  'Java' => '5.2',
  'Zsye' => '6.0',
  'Bamu' => '5.2',
  'Egyh' => '5.2',
  'Cher' => '3.0',
  'Ital' => '3.1',
  'Guru' => '1.1',
  'Sinh' => '3.0',
  'Dsrt' => '3.1',
  'Hani' => '1.1',
  'Telu' => '1.1',
  'Brah' => '6.0',
  'Inds' => '',
  'Perm' => '7.0',
  'Sylo' => '4.1',
  'Modi' => '7.0',
  'Ethi' => '3.0',
  'Hang' => '1.1',
  'Glag' => '4.1',
  'Knda' => '1.1',
  'Nkgb' => '',
  'Nkdb' => '',
  'Medf' => '11.0',
  'Gong' => '11.0',
  'Thai' => '1.1',
  'Sgnw' => '8.0',
  'Nand' => '12.0',
  'Buhd' => '3.2',
  'Elba' => '7.0',
  'Syre' => '3.0',
  'Mlym' => '1.1',
  'Copt' => '4.1',
  'Teng' => '',
  'Cari' => '5.1',
  'Xsux' => '5.0',
  'Orkh' => '5.2',
  'Runr' => '3.0',
  'Kitl' => '',
  'Prti' => '5.2',
  'Sara' => ''
};
$ScriptCodeDate = {
  'Bass' => '2014-11-15',
  'Aran' => '2014-11-15',
  'Chrs' => '2019-08-19',
  'Jurc' => '2010-12-21',
  'Lyci' => '2007-07-02',
  'Bugi' => '2006-06-21',
  'Vaii' => '2007-07-02',
  'Limb' => '2004-05-29',
  'Ogam' => '2004-05-01',
  'Thaa' => '2004-05-01',
  'Hatr' => '2015-07-07',
  'Orya' => '2016-12-05',
  'Lisu' => '2009-06-01',
  'Tavt' => '2009-06-01',
  'Pauc' => '2014-11-15',
  'Zinh' => '2009-02-23',
  'Newa' => '2016-12-05',
  'Nshu' => '2017-07-26',
  'Rjng' => '2009-02-23',
  'Mtei' => '2009-06-01',
  'Lydi' => '2007-07-02',
  'Zmth' => '2007-11-26',
  'Merc' => '2012-02-06',
  'Nbat' => '2014-11-15',
  'Piqd' => '2015-12-16',
  'Cham' => '2009-11-11',
  'Visp' => '2004-05-01',
  'Mong' => '2004-05-01',
  'Taml' => '2004-05-01',
  'Olck' => '2007-07-02',
  'Tagb' => '2004-05-01',
  'Cyrs' => '2004-05-01',
  'Lina' => '2014-11-15',
  'Khar' => '2006-06-21',
  'Wcho' => '2017-07-26',
  'Afak' => '2010-12-21',
  'Hant' => '2004-05-29',
  'Yezi' => '2019-08-19',
  'Deva' => '2004-05-01',
  'Qaaa' => '2004-05-29',
  'Cpmn' => '2017-07-26',
  'Zyyy' => '2004-05-29',
  'Dupl' => '2014-11-15',
  'Bopo' => '2004-05-01',
  'Jpan' => '2006-06-21',
  'Osma' => '2004-05-01',
  'Maya' => '2004-05-01',
  'Osge' => '2016-12-05',
  'Blis' => '2004-05-01',
  'Tale' => '2004-10-25',
  'Ugar' => '2004-05-01',
  'Beng' => '2016-12-05',
  'Hebr' => '2004-05-01',
  'Goth' => '2004-05-01',
  'Syrj' => '2004-05-01',
  'Arab' => '2004-05-01',
  'Linb' => '2004-05-29',
  'Shui' => '2017-07-26',
  'Sund' => '2007-07-02',
  'Syrn' => '2004-05-01',
  'Kthi' => '2009-06-01',
  'Khoj' => '2014-11-15',
  'Latf' => '2004-05-01',
  'Avst' => '2009-06-01',
  'Nkoo' => '2006-10-10',
  'Samr' => '2009-06-01',
  'Tang' => '2016-12-05',
  'Leke' => '2015-07-07',
  'Aghb' => '2014-11-15',
  'Tglg' => '2009-02-23',
  'Xpeo' => '2006-06-21',
  'Maka' => '2016-12-05',
  'Plrd' => '2012-02-06',
  'Hanb' => '2016-01-19',
  'Tfng' => '2006-06-21',
  'Narb' => '2014-11-15',
  'Shaw' => '2004-05-01',
  'Khmr' => '2004-05-29',
  'Zanb' => '2017-07-26',
  'Tibt' => '2004-05-01',
  'Hmnp' => '2017-07-26',
  'Dogr' => '2016-12-05',
  'Wara' => '2014-11-15',
  'Kpel' => '2010-03-26',
  'Syrc' => '2004-05-01',
  'Yiii' => '2004-05-01',
  'Zxxx' => '2011-06-21',
  'Mand' => '2010-07-23',
  'Latn' => '2004-05-01',
  'Cyrl' => '2004-05-01',
  'Sidd' => '2014-11-15',
  'Mani' => '2014-11-15',
  'Egyp' => '2009-06-01',
  'Adlm' => '2016-12-05',
  'Gran' => '2014-11-15',
  'Armn' => '2004-05-01',
  'Moon' => '2006-12-11',
  'Cprt' => '2017-07-26',
  'Phlp' => '2014-11-15',
  'Talu' => '2006-06-21',
  'Kana' => '2004-05-01',
  'Cakm' => '2012-02-06',
  'Geok' => '2012-10-16',
  'Palm' => '2014-11-15',
  'Nand' => '2018-08-26',
  'Buhd' => '2004-05-01',
  'Syre' => '2004-05-01',
  'Elba' => '2014-11-15',
  'Hang' => '2004-05-29',
  'Glag' => '2006-06-21',
  'Ethi' => '2004-10-25',
  'Thai' => '2004-05-01',
  'Sgnw' => '2015-07-07',
  'Nkdb' => '2017-07-26',
  'Nkgb' => '2017-07-26',
  'Medf' => '2016-12-05',
  'Gong' => '2016-12-05',
  'Knda' => '2004-05-29',
  'Kitl' => '2015-07-15',
  'Runr' => '2004-05-01',
  'Sara' => '2004-05-29',
  'Prti' => '2009-06-01',
  'Cari' => '2007-07-02',
  'Teng' => '2004-05-01',
  'Mlym' => '2004-05-01',
  'Copt' => '2006-06-21',
  'Orkh' => '2009-06-01',
  'Xsux' => '2006-10-10',
  'Zsye' => '2015-12-16',
  'Bamu' => '2009-06-01',
  'Mend' => '2014-11-15',
  'Mult' => '2015-07-07',
  'Java' => '2009-06-01',
  'Sogo' => '2017-11-21',
  'Rohg' => '2017-11-21',
  'Cher' => '2004-05-01',
  'Egyh' => '2004-05-01',
  'Ital' => '2004-05-29',
  'Saur' => '2007-07-02',
  'Grek' => '2004-05-01',
  'Zsym' => '2007-11-26',
  'Hrkt' => '2011-06-21',
  'Inds' => '2004-05-01',
  'Brah' => '2010-07-23',
  'Telu' => '2004-05-01',
  'Sylo' => '2006-06-21',
  'Modi' => '2014-11-15',
  'Perm' => '2014-11-15',
  'Guru' => '2004-05-01',
  'Hani' => '2009-02-23',
  'Sinh' => '2004-05-01',
  'Dsrt' => '2004-05-01',
  'Brai' => '2004-05-01',
  'Toto' => '2020-04-16',
  'Kali' => '2007-07-02',
  'Mroo' => '2016-12-05',
  'Jamo' => '2016-01-19',
  'Sind' => '2014-11-15',
  'Tirh' => '2014-11-15',
  'Shrd' => '2012-02-06',
  'Lana' => '2009-06-01',
  'Mero' => '2012-02-06',
  'Elym' => '2018-08-26',
  'Phli' => '2009-06-01',
  'Soyo' => '2017-07-26',
  'Lepc' => '2007-07-02',
  'Kits' => '2015-07-15',
  'Laoo' => '2004-05-01',
  'Gujr' => '2004-05-01',
  'Hluw' => '2015-07-07',
  'Egyd' => '2004-05-01',
  'Gonm' => '2017-07-26',
  'Marc' => '2016-12-05',
  'Ahom' => '2015-07-07',
  'Roro' => '2004-05-01',
  'Kore' => '2007-06-13',
  'Armi' => '2009-06-01',
  'Phnx' => '2006-10-10',
  'Qabx' => '2004-05-29',
  'Mymr' => '2004-05-01',
  'Cans' => '2004-05-29',
  'Hira' => '2004-05-01',
  'Sora' => '2012-02-06',
  'Takr' => '2012-02-06',
  'Cirt' => '2004-05-01',
  'Diak' => '2019-08-19',
  'Hano' => '2004-05-29',
  'Hung' => '2015-07-07',
  'Mahj' => '2014-11-15',
  'Bhks' => '2016-12-05',
  'Hmng' => '2014-11-15',
  'Sogd' => '2017-11-21',
  'Phag' => '2006-10-10',
  'Phlv' => '2007-07-15',
  'Sarb' => '2009-06-01',
  'Latg' => '2004-05-01',
  'Batk' => '2010-07-23',
  'Loma' => '2010-03-26',
  'Wole' => '2010-12-21',
  'Geor' => '2016-12-05',
  'Zzzz' => '2006-10-10',
  'Bali' => '2006-10-10',
  'Hans' => '2004-05-29'
};
$ScriptCodeId = {
  'Cham' => '358',
  'Visp' => '280',
  'Piqd' => '293',
  'Olck' => '261',
  'Tagb' => '373',
  'Mong' => '145',
  'Taml' => '346',
  'Khar' => '305',
  'Wcho' => '283',
  'Lina' => '400',
  'Cyrs' => '221',
  'Yezi' => '192',
  'Hant' => '502',
  'Afak' => '439',
  'Qaaa' => '900',
  'Deva' => '315',
  'Dupl' => '755',
  'Zyyy' => '998',
  'Cpmn' => '402',
  'Osma' => '260',
  'Bopo' => '285',
  'Jpan' => '413',
  'Hebr' => '125',
  'Ugar' => '040',
  'Beng' => '325',
  'Maya' => '090',
  'Blis' => '550',
  'Tale' => '353',
  'Osge' => '219',
  'Bass' => '259',
  'Jurc' => '510',
  'Chrs' => '109',
  'Lyci' => '202',
  'Bugi' => '367',
  'Aran' => '161',
  'Ogam' => '212',
  'Thaa' => '170',
  'Vaii' => '470',
  'Limb' => '336',
  'Tavt' => '359',
  'Orya' => '327',
  'Hatr' => '127',
  'Lisu' => '399',
  'Pauc' => '263',
  'Nshu' => '499',
  'Rjng' => '363',
  'Zinh' => '994',
  'Newa' => '333',
  'Lydi' => '116',
  'Mtei' => '337',
  'Nbat' => '159',
  'Zmth' => '995',
  'Merc' => '101',
  'Hmnp' => '451',
  'Dogr' => '328',
  'Zanb' => '339',
  'Tibt' => '330',
  'Kpel' => '436',
  'Wara' => '262',
  'Syrc' => '135',
  'Mand' => '140',
  'Cyrl' => '220',
  'Latn' => '215',
  'Yiii' => '460',
  'Zxxx' => '997',
  'Gran' => '343',
  'Sidd' => '302',
  'Adlm' => '166',
  'Mani' => '139',
  'Egyp' => '050',
  'Moon' => '218',
  'Cprt' => '403',
  'Armn' => '230',
  'Phlp' => '132',
  'Cakm' => '349',
  'Talu' => '354',
  'Kana' => '411',
  'Palm' => '126',
  'Geok' => '241',
  'Syrj' => '137',
  'Goth' => '206',
  'Syrn' => '136',
  'Linb' => '401',
  'Arab' => '160',
  'Sund' => '362',
  'Shui' => '530',
  'Latf' => '217',
  'Avst' => '134',
  'Khoj' => '322',
  'Kthi' => '317',
  'Leke' => '364',
  'Tang' => '520',
  'Samr' => '123',
  'Nkoo' => '165',
  'Tglg' => '370',
  'Xpeo' => '030',
  'Aghb' => '239',
  'Maka' => '366',
  'Hanb' => '503',
  'Plrd' => '282',
  'Shaw' => '281',
  'Khmr' => '355',
  'Narb' => '106',
  'Tfng' => '120',
  'Rohg' => '167',
  'Sogo' => '142',
  'Bamu' => '435',
  'Zsye' => '993',
  'Java' => '361',
  'Mult' => '323',
  'Mend' => '438',
  'Ital' => '210',
  'Egyh' => '060',
  'Cher' => '445',
  'Hrkt' => '412',
  'Saur' => '344',
  'Grek' => '200',
  'Zsym' => '996',
  'Telu' => '340',
  'Inds' => '610',
  'Brah' => '300',
  'Perm' => '227',
  'Sylo' => '316',
  'Modi' => '324',
  'Guru' => '310',
  'Dsrt' => '250',
  'Sinh' => '348',
  'Hani' => '500',
  'Buhd' => '372',
  'Nand' => '311',
  'Elba' => '226',
  'Syre' => '138',
  'Ethi' => '430',
  'Glag' => '225',
  'Hang' => '286',
  'Knda' => '345',
  'Sgnw' => '095',
  'Thai' => '352',
  'Nkgb' => '420',
  'Nkdb' => '085',
  'Medf' => '265',
  'Gong' => '312',
  'Runr' => '211',
  'Kitl' => '505',
  'Prti' => '130',
  'Sara' => '292',
  'Teng' => '290',
  'Copt' => '204',
  'Mlym' => '347',
  'Cari' => '201',
  'Xsux' => '020',
  'Orkh' => '175',
  'Mymr' => '350',
  'Hira' => '410',
  'Cans' => '440',
  'Hung' => '176',
  'Diak' => '342',
  'Hano' => '371',
  'Takr' => '321',
  'Sora' => '398',
  'Cirt' => '291',
  'Hmng' => '450',
  'Bhks' => '334',
  'Mahj' => '314',
  'Phag' => '331',
  'Sogd' => '141',
  'Loma' => '437',
  'Batk' => '365',
  'Latg' => '216',
  'Phlv' => '133',
  'Sarb' => '105',
  'Geor' => '240',
  'Wole' => '480',
  'Hans' => '501',
  'Zzzz' => '999',
  'Bali' => '360',
  'Toto' => '294',
  'Kali' => '357',
  'Brai' => '570',
  'Mroo' => '264',
  'Lana' => '351',
  'Sind' => '318',
  'Jamo' => '284',
  'Shrd' => '319',
  'Tirh' => '326',
  'Elym' => '128',
  'Mero' => '100',
  'Phli' => '131',
  'Laoo' => '356',
  'Kits' => '288',
  'Egyd' => '070',
  'Gujr' => '320',
  'Hluw' => '080',
  'Soyo' => '329',
  'Lepc' => '335',
  'Ahom' => '338',
  'Marc' => '332',
  'Gonm' => '313',
  'Armi' => '124',
  'Phnx' => '115',
  'Roro' => '620',
  'Kore' => '287',
  'Qabx' => '949'
};
$Lang2Territory = {
  'tyv' => {
    'RU' => 2
  },
  'laj' => {
    'UG' => 2
  },
  'pan' => {
    'PK' => 2,
    'IN' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'koi' => {
    'RU' => 2
  },
  'fra' => {
    'FR' => 1,
    'RO' => 2,
    'BL' => 1,
    'RW' => 1,
    'CI' => 1,
    'BE' => 1,
    'PM' => 1,
    'PT' => 2,
    'DE' => 2,
    'NL' => 2,
    'WF' => 1,
    'NE' => 1,
    'MC' => 1,
    'SC' => 1,
    'MA' => 1,
    'US' => 2,
    'DZ' => 1,
    'CM' => 1,
    'CA' => 1,
    'MQ' => 1,
    'RE' => 1,
    'TG' => 1,
    'KM' => 1,
    'YT' => 1,
    'CG' => 1,
    'LU' => 1,
    'HT' => 1,
    'GN' => 1,
    'MG' => 1,
    'BF' => 1,
    'GP' => 1,
    'GF' => 1,
    'VU' => 1,
    'SY' => 1,
    'GQ' => 1,
    'BI' => 1,
    'CH' => 1,
    'ML' => 1,
    'GA' => 1,
    'IT' => 2,
    'NC' => 1,
    'TD' => 1,
    'SN' => 1,
    'CD' => 1,
    'PF' => 1,
    'GB' => 2,
    'MF' => 1,
    'MU' => 1,
    'BJ' => 1,
    'TN' => 1,
    'CF' => 1,
    'TF' => 2,
    'DJ' => 1
  },
  'slv' => {
    'SI' => 1,
    'AT' => 2
  },
  'krc' => {
    'RU' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'hil' => {
    'PH' => 2
  },
  'mag' => {
    'IN' => 2
  },
  'haw' => {
    'US' => 2
  },
  'vls' => {
    'BE' => 2
  },
  'bem' => {
    'ZM' => 2
  },
  'kbd' => {
    'RU' => 2
  },
  'khm' => {
    'KH' => 1
  },
  'kaz' => {
    'KZ' => 1,
    'CN' => 2
  },
  'sag' => {
    'CF' => 1
  },
  'mak' => {
    'ID' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'mdh' => {
    'PH' => 2
  },
  'lez' => {
    'RU' => 2
  },
  'lua' => {
    'CD' => 2
  },
  'war' => {
    'PH' => 2
  },
  'hrv' => {
    'BA' => 1,
    'RS' => 2,
    'HR' => 1,
    'AT' => 2,
    'SI' => 2
  },
  'nym' => {
    'TZ' => 2
  },
  'srd' => {
    'IT' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'glg' => {
    'ES' => 2
  },
  'tum' => {
    'MW' => 2
  },
  'arq' => {
    'DZ' => 2
  },
  'sqi' => {
    'AL' => 1,
    'RS' => 2,
    'XK' => 1,
    'MK' => 2
  },
  'swb' => {
    'YT' => 2
  },
  'que' => {
    'EC' => 1,
    'BO' => 1,
    'PE' => 1
  },
  'tah' => {
    'PF' => 1
  },
  'lmn' => {
    'IN' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'glk' => {
    'IR' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'sme' => {
    'NO' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'ell' => {
    'CY' => 1,
    'GR' => 1
  },
  'bjj' => {
    'IN' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'buc' => {
    'YT' => 2
  },
  'bod' => {
    'CN' => 2
  },
  'ewe' => {
    'GH' => 2,
    'TG' => 2
  },
  'snd' => {
    'PK' => 2,
    'IN' => 2
  },
  'aym' => {
    'BO' => 1
  },
  'kok' => {
    'IN' => 2
  },
  'sef' => {
    'CI' => 2
  },
  'mfe' => {
    'MU' => 2
  },
  'run' => {
    'BI' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'hno' => {
    'PK' => 2
  },
  'tam' => {
    'MY' => 2,
    'LK' => 1,
    'SG' => 1,
    'IN' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'tet' => {
    'TL' => 1
  },
  'tig' => {
    'ER' => 2
  },
  'haz' => {
    'AF' => 2
  },
  'est' => {
    'EE' => 1
  },
  'ita' => {
    'MT' => 2,
    'IT' => 1,
    'CH' => 1,
    'DE' => 2,
    'US' => 2,
    'SM' => 1,
    'VA' => 1,
    'FR' => 2,
    'HR' => 2
  },
  'tur' => {
    'DE' => 2,
    'TR' => 1,
    'CY' => 1
  },
  'ach' => {
    'UG' => 2
  },
  'kir' => {
    'KG' => 1
  },
  'ron' => {
    'RO' => 1,
    'MD' => 1,
    'RS' => 2
  },
  'ful' => {
    'NE' => 2,
    'ML' => 2,
    'SN' => 2,
    'NG' => 2,
    'GN' => 2
  },
  'cat' => {
    'AD' => 1,
    'ES' => 2
  },
  'mai' => {
    'NP' => 2,
    'IN' => 2
  },
  'tcy' => {
    'IN' => 2
  },
  'arz' => {
    'EG' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'gle' => {
    'IE' => 1,
    'GB' => 2
  },
  'wol' => {
    'SN' => 1
  },
  'suk' => {
    'TZ' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'men' => {
    'SL' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'bos' => {
    'BA' => 1
  },
  'xog' => {
    'UG' => 2
  },
  'doi' => {
    'IN' => 2
  },
  'mlt' => {
    'MT' => 1
  },
  'swa' => {
    'TZ' => 1,
    'KE' => 1,
    'UG' => 1,
    'CD' => 2
  },
  'hau' => {
    'NG' => 2,
    'NE' => 2
  },
  'heb' => {
    'IL' => 1
  },
  'raj' => {
    'IN' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'hbs' => {
    'ME' => 1,
    'AT' => 2,
    'XK' => 1,
    'BA' => 1,
    'RS' => 1,
    'HR' => 1,
    'SI' => 2
  },
  'mya' => {
    'MM' => 1
  },
  'kea' => {
    'CV' => 2
  },
  'myx' => {
    'UG' => 2
  },
  'nod' => {
    'TH' => 2
  },
  'bjn' => {
    'ID' => 2
  },
  'gcr' => {
    'GF' => 2
  },
  'sou' => {
    'TH' => 2
  },
  'bin' => {
    'NG' => 2
  },
  'vmw' => {
    'MZ' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'unr' => {
    'IN' => 2
  },
  'inh' => {
    'RU' => 2
  },
  'lao' => {
    'LA' => 1
  },
  'srn' => {
    'SR' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'brh' => {
    'PK' => 2
  },
  'bew' => {
    'ID' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'som' => {
    'DJ' => 2,
    'ET' => 2,
    'SO' => 1
  },
  'fuq' => {
    'NE' => 2
  },
  'bho' => {
    'NP' => 2,
    'IN' => 2,
    'MU' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'sah' => {
    'RU' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'ban' => {
    'ID' => 2
  },
  'shi' => {
    'MA' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'nob' => {
    'NO' => 1,
    'SJ' => 1
  },
  'swv' => {
    'IN' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'lin' => {
    'CD' => 2
  },
  'eus' => {
    'ES' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'nbl' => {
    'ZA' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'ady' => {
    'RU' => 2
  },
  'gon' => {
    'IN' => 2
  },
  'gbm' => {
    'IN' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'nep' => {
    'IN' => 2,
    'NP' => 1
  },
  'kom' => {
    'RU' => 2
  },
  'bsc' => {
    'SN' => 2
  },
  'kal' => {
    'DK' => 2,
    'GL' => 1
  },
  'eng' => {
    'AR' => 2,
    'PR' => 1,
    'RW' => 1,
    'IE' => 1,
    'BS' => 1,
    'CK' => 1,
    'SC' => 1,
    'PT' => 2,
    'AT' => 2,
    'DE' => 2,
    'NL' => 2,
    'AC' => 2,
    'IL' => 2,
    'LS' => 1,
    'AI' => 1,
    'GY' => 1,
    'CM' => 1,
    'SI' => 2,
    'IO' => 1,
    'GH' => 1,
    'PK' => 1,
    'BZ' => 1,
    'EG' => 2,
    'SK' => 2,
    'CA' => 1,
    'CC' => 1,
    'BW' => 1,
    'CX' => 1,
    'ET' => 2,
    'HR' => 2,
    'ER' => 1,
    'WS' => 1,
    'AG' => 1,
    'PG' => 1,
    'SX' => 1,
    'SG' => 1,
    'NF' => 1,
    'NU' => 1,
    'SB' => 1,
    'HK' => 1,
    'KN' => 1,
    'MY' => 2,
    'MW' => 1,
    'UM' => 1,
    'CL' => 2,
    'HU' => 2,
    'DK' => 2,
    'MH' => 1,
    'IQ' => 2,
    'MS' => 1,
    'DM' => 1,
    'ZM' => 1,
    'TZ' => 1,
    'IM' => 1,
    'NR' => 1,
    'IT' => 2,
    'TH' => 2,
    'SE' => 2,
    'PL' => 2,
    'NA' => 1,
    'AE' => 2,
    'SL' => 1,
    'ZA' => 1,
    'KZ' => 2,
    'DG' => 1,
    'NG' => 1,
    'KY' => 1,
    'AU' => 1,
    'EE' => 2,
    'SD' => 1,
    'UG' => 1,
    'BE' => 2,
    'FR' => 2,
    'RO' => 2,
    'FM' => 1,
    'LV' => 2,
    'MT' => 1,
    'MA' => 2,
    'TK' => 1,
    'ZW' => 1,
    'US' => 1,
    'DZ' => 2,
    'TR' => 2,
    'FI' => 2,
    'NZ' => 1,
    'TA' => 2,
    'VG' => 1,
    'TC' => 1,
    'TT' => 1,
    'FK' => 1,
    'JO' => 2,
    'VC' => 1,
    'GD' => 1,
    'LU' => 2,
    'FJ' => 1,
    'BD' => 2,
    'KI' => 1,
    'MG' => 1,
    'MX' => 2,
    'IN' => 1,
    'VI' => 1,
    'GU' => 1,
    'JE' => 1,
    'PW' => 1,
    'VU' => 1,
    'GI' => 1,
    'LR' => 1,
    'SZ' => 1,
    'LT' => 2,
    'SH' => 1,
    'LC' => 1,
    'PH' => 1,
    'BI' => 1,
    'SS' => 1,
    'BA' => 2,
    'CZ' => 2,
    'GR' => 2,
    'CY' => 2,
    'TV' => 1,
    'GM' => 1,
    'TO' => 1,
    'AS' => 1,
    'BM' => 1,
    'BR' => 2,
    'CH' => 2,
    'LK' => 2,
    'JM' => 1,
    'PN' => 1,
    'GG' => 1,
    'BB' => 1,
    'MU' => 1,
    'BG' => 2,
    'MP' => 1,
    'GB' => 1,
    'YE' => 2,
    'ES' => 2,
    'LB' => 2,
    'KE' => 1
  },
  'nds' => {
    'NL' => 2,
    'DE' => 2
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'lat' => {
    'VA' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'rus' => {
    'LT' => 2,
    'UA' => 1,
    'RU' => 1,
    'DE' => 2,
    'BG' => 2,
    'SJ' => 2,
    'KZ' => 1,
    'LV' => 2,
    'UZ' => 2,
    'BY' => 1,
    'PL' => 2,
    'TJ' => 2,
    'KG' => 1,
    'EE' => 2
  },
  'skr' => {
    'PK' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'kor' => {
    'KR' => 1,
    'US' => 2,
    'CN' => 2,
    'KP' => 1
  },
  'kam' => {
    'KE' => 2
  },
  'gan' => {
    'CN' => 2
  },
  'rmt' => {
    'IR' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'uzb' => {
    'AF' => 2,
    'UZ' => 1
  },
  'sna' => {
    'ZW' => 1
  },
  'kur' => {
    'TR' => 2,
    'IQ' => 2,
    'IR' => 2,
    'SY' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'tir' => {
    'ET' => 2,
    'ER' => 1
  },
  'kik' => {
    'KE' => 2
  },
  'tuk' => {
    'TM' => 1,
    'AF' => 2,
    'IR' => 2
  },
  'fil' => {
    'PH' => 1,
    'US' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'rkt' => {
    'IN' => 2,
    'BD' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'dje' => {
    'NE' => 2
  },
  'fry' => {
    'NL' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'ckb' => {
    'IQ' => 2,
    'IR' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'dnj' => {
    'CI' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'rif' => {
    'MA' => 2
  },
  'bjt' => {
    'SN' => 2
  },
  'ssw' => {
    'ZA' => 2,
    'SZ' => 1
  },
  'tzm' => {
    'MA' => 1
  },
  'wuu' => {
    'CN' => 2
  },
  'kde' => {
    'TZ' => 2
  },
  'bis' => {
    'VU' => 1
  },
  'gaa' => {
    'GH' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'spa' => {
    'BO' => 1,
    'BZ' => 2,
    'PE' => 1,
    'IC' => 1,
    'GT' => 1,
    'US' => 2,
    'DO' => 1,
    'CR' => 1,
    'CO' => 1,
    'PT' => 2,
    'GQ' => 1,
    'DE' => 2,
    'PA' => 1,
    'PH' => 2,
    'CL' => 1,
    'RO' => 2,
    'FR' => 2,
    'PY' => 1,
    'HN' => 1,
    'NI' => 1,
    'SV' => 1,
    'GI' => 2,
    'UY' => 1,
    'AR' => 1,
    'PR' => 1,
    'CU' => 1,
    'ES' => 1,
    'VE' => 1,
    'MX' => 1,
    'AD' => 2,
    'EA' => 1,
    'EC' => 1
  },
  'ibo' => {
    'NG' => 2
  },
  'bqi' => {
    'IR' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'yue' => {
    'HK' => 2,
    'CN' => 2
  },
  'mdf' => {
    'RU' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'iku' => {
    'CA' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'mni' => {
    'IN' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'msa' => {
    'TH' => 2,
    'CC' => 2,
    'BN' => 1,
    'MY' => 1,
    'SG' => 1,
    'ID' => 2
  },
  'mad' => {
    'ID' => 2
  },
  'hif' => {
    'FJ' => 1
  },
  'gil' => {
    'KI' => 1
  },
  'tiv' => {
    'NG' => 2
  },
  'ary' => {
    'MA' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'hoc' => {
    'IN' => 2
  },
  'bej' => {
    'SD' => 2
  },
  'bgc' => {
    'IN' => 2
  },
  'mzn' => {
    'IR' => 2
  },
  'smo' => {
    'WS' => 1,
    'AS' => 1
  },
  'tts' => {
    'TH' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'wbr' => {
    'IN' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'oci' => {
    'FR' => 2
  },
  'orm' => {
    'ET' => 2
  },
  'bak' => {
    'RU' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'awa' => {
    'IN' => 2
  },
  'hin' => {
    'IN' => 1,
    'ZA' => 2,
    'FJ' => 2
  },
  'guz' => {
    'KE' => 2
  },
  'sas' => {
    'ID' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'noe' => {
    'IN' => 2
  },
  'nno' => {
    'NO' => 1
  },
  'sat' => {
    'IN' => 2
  },
  'zha' => {
    'CN' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'pam' => {
    'PH' => 2
  },
  'pol' => {
    'UA' => 2,
    'PL' => 1
  },
  'ltz' => {
    'LU' => 1
  },
  'por' => {
    'ST' => 1,
    'TL' => 1,
    'GQ' => 1,
    'PT' => 1,
    'BR' => 1,
    'CV' => 1,
    'AO' => 1,
    'MZ' => 1,
    'MO' => 1,
    'GW' => 1
  },
  'sot' => {
    'ZA' => 2,
    'LS' => 1
  },
  'jav' => {
    'ID' => 2
  },
  'nld' => {
    'SX' => 1,
    'SR' => 1,
    'BQ' => 1,
    'BE' => 1,
    'CW' => 1,
    'AW' => 1,
    'NL' => 1,
    'DE' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'hsn' => {
    'CN' => 2
  },
  'aeb' => {
    'TN' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'sav' => {
    'SN' => 2
  },
  'min' => {
    'ID' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'slk' => {
    'CZ' => 2,
    'RS' => 2,
    'SK' => 1
  },
  'snk' => {
    'ML' => 2
  },
  'ben' => {
    'BD' => 1,
    'IN' => 2
  },
  'kfy' => {
    'IN' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'sus' => {
    'GN' => 2
  },
  'srp' => {
    'XK' => 1,
    'BA' => 1,
    'ME' => 1,
    'RS' => 1
  },
  'uig' => {
    'CN' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'khn' => {
    'IN' => 2
  },
  'tso' => {
    'ZA' => 2,
    'MZ' => 2
  },
  'mer' => {
    'KE' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'bug' => {
    'ID' => 2
  },
  'mfv' => {
    'SN' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'seh' => {
    'MZ' => 2
  },
  'nyn' => {
    'UG' => 2
  },
  'crs' => {
    'SC' => 2
  },
  'kha' => {
    'IN' => 2
  },
  'hne' => {
    'IN' => 2
  },
  'ukr' => {
    'UA' => 1,
    'RS' => 2
  },
  'tnr' => {
    'SN' => 2
  },
  'ceb' => {
    'PH' => 2
  },
  'kin' => {
    'RW' => 1
  },
  'nya' => {
    'MW' => 1,
    'ZM' => 2
  },
  'lah' => {
    'PK' => 2
  },
  'shn' => {
    'MM' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'ilo' => {
    'PH' => 2
  },
  'zdj' => {
    'KM' => 1
  },
  'ljp' => {
    'ID' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'ton' => {
    'TO' => 1
  },
  'fon' => {
    'BJ' => 2
  },
  'glv' => {
    'IM' => 1
  },
  'mwr' => {
    'IN' => 2
  },
  'hmo' => {
    'PG' => 1
  },
  'syl' => {
    'BD' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'tem' => {
    'SL' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'brx' => {
    'IN' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'tpi' => {
    'PG' => 1
  },
  'urd' => {
    'IN' => 2,
    'PK' => 1
  },
  'fas' => {
    'PK' => 2,
    'IR' => 1,
    'AF' => 1
  },
  'sck' => {
    'IN' => 2
  },
  'tat' => {
    'RU' => 2
  },
  'gsw' => {
    'CH' => 1,
    'LI' => 1,
    'DE' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'gor' => {
    'ID' => 2
  },
  'lug' => {
    'UG' => 2
  },
  'dzo' => {
    'BT' => 1
  },
  'mfa' => {
    'TH' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'kmb' => {
    'AO' => 2
  },
  'ori' => {
    'IN' => 2
  },
  'deu' => {
    'BE' => 1,
    'KZ' => 2,
    'FR' => 2,
    'DK' => 2,
    'HU' => 2,
    'LU' => 1,
    'NL' => 2,
    'GB' => 2,
    'AT' => 1,
    'DE' => 1,
    'CZ' => 2,
    'US' => 2,
    'LI' => 1,
    'SI' => 2,
    'PL' => 2,
    'SK' => 2,
    'CH' => 1,
    'BR' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'fuv' => {
    'NG' => 2
  },
  'tsn' => {
    'ZA' => 2,
    'BW' => 1
  },
  'ces' => {
    'CZ' => 1,
    'SK' => 2
  },
  'bgn' => {
    'PK' => 2
  },
  'dyu' => {
    'BF' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'aze' => {
    'IR' => 2,
    'IQ' => 2,
    'RU' => 2,
    'AZ' => 1
  },
  'bar' => {
    'DE' => 2,
    'AT' => 2
  },
  'bal' => {
    'PK' => 2,
    'IR' => 2,
    'AF' => 2
  },
  'rej' => {
    'ID' => 2
  },
  'man' => {
    'GM' => 2,
    'GN' => 2
  },
  'xho' => {
    'ZA' => 2
  },
  'fij' => {
    'FJ' => 1
  },
  'hun' => {
    'RS' => 2,
    'HU' => 1,
    'RO' => 2,
    'AT' => 2
  },
  'san' => {
    'IN' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'zgh' => {
    'MA' => 2
  },
  'bhi' => {
    'IN' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'amh' => {
    'ET' => 1
  },
  'luz' => {
    'IR' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'bum' => {
    'CM' => 2
  },
  'pau' => {
    'PW' => 1
  },
  'aln' => {
    'XK' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'zho' => {
    'CN' => 1,
    'US' => 2,
    'MY' => 2,
    'TW' => 1,
    'MO' => 1,
    'SG' => 1,
    'ID' => 2,
    'TH' => 2,
    'VN' => 2,
    'HK' => 1
  },
  'ibb' => {
    'NG' => 2
  },
  'swe' => {
    'SE' => 1,
    'AX' => 1,
    'FI' => 1
  },
  'fud' => {
    'WF' => 2
  },
  'hye' => {
    'RU' => 2,
    'AM' => 1
  },
  'udm' => {
    'RU' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'afr' => {
    'ZA' => 2,
    'NA' => 2
  },
  'bul' => {
    'BG' => 1
  },
  'tvl' => {
    'TV' => 1
  },
  'yor' => {
    'NG' => 1
  },
  'fvr' => {
    'SD' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'fao' => {
    'FO' => 1
  },
  'sun' => {
    'ID' => 2
  },
  'pap' => {
    'CW' => 1,
    'AW' => 1,
    'BQ' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'mon' => {
    'MN' => 1,
    'CN' => 2
  },
  'bam' => {
    'ML' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'tha' => {
    'TH' => 1
  },
  'fin' => {
    'EE' => 2,
    'SE' => 2,
    'FI' => 1
  },
  'iii' => {
    'CN' => 2
  },
  'hoj' => {
    'IN' => 2
  },
  'und' => {
    'HM' => 2,
    'BV' => 2,
    'CP' => 2,
    'GS' => 2,
    'AQ' => 2
  },
  'che' => {
    'RU' => 2
  },
  'dan' => {
    'DE' => 2,
    'DK' => 1
  },
  'nor' => {
    'NO' => 1,
    'SJ' => 1
  },
  'gom' => {
    'IN' => 2
  },
  'div' => {
    'MV' => 1
  },
  'sid' => {
    'ET' => 2
  },
  'kon' => {
    'CD' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'ara' => {
    'MR' => 1,
    'SO' => 1,
    'SY' => 1,
    'LY' => 1,
    'IQ' => 1,
    'IL' => 1,
    'OM' => 1,
    'SA' => 1,
    'MA' => 2,
    'IR' => 2,
    'PS' => 1,
    'QA' => 1,
    'DZ' => 2,
    'SS' => 2,
    'BH' => 1,
    'AE' => 1,
    'EG' => 2,
    'TD' => 1,
    'KW' => 1,
    'EH' => 1,
    'KM' => 1,
    'JO' => 1,
    'ER' => 1,
    'SD' => 1,
    'TN' => 1,
    'YE' => 1,
    'LB' => 1,
    'DJ' => 1
  },
  'niu' => {
    'NU' => 1
  },
  'grn' => {
    'PY' => 1
  },
  'tel' => {
    'IN' => 2
  },
  'kab' => {
    'DZ' => 2
  }
};
$Lang2Script = {
  'lui' => {
    'Latn' => 2
  },
  'xmn' => {
    'Mani' => 2
  },
  'kht' => {
    'Mymr' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'nde' => {
    'Latn' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'pnt' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Grek' => 1
  },
  'fia' => {
    'Arab' => 1
  },
  'sun' => {
    'Latn' => 1,
    'Sund' => 2
  },
  'xnr' => {
    'Deva' => 1
  },
  'mon' => {
    'Cyrl' => 1,
    'Phag' => 2,
    'Mong' => 2
  },
  'ttj' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'fvr' => {
    'Latn' => 1
  },
  'wbp' => {
    'Latn' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'udm' => {
    'Latn' => 2,
    'Cyrl' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'gba' => {
    'Latn' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'mua' => {
    'Latn' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'lki' => {
    'Arab' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'sid' => {
    'Latn' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'kon' => {
    'Latn' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'frp' => {
    'Latn' => 1
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'fin' => {
    'Latn' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'vmf' => {
    'Latn' => 1
  },
  'vic' => {
    'Latn' => 1
  },
  'bra' => {
    'Deva' => 1
  },
  'deu' => {
    'Runr' => 2,
    'Latn' => 1
  },
  'fuv' => {
    'Latn' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'gor' => {
    'Latn' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'urd' => {
    'Arab' => 1
  },
  'tgk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'sck' => {
    'Deva' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'bum' => {
    'Latn' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'ibb' => {
    'Latn' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'hun' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'mdt' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'was' => {
    'Latn' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'aze' => {
    'Arab' => 1,
    'Latn' => 1,
    'Cyrl' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'rej' => {
    'Latn' => 1,
    'Rjng' => 2
  },
  'bal' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'mer' => {
    'Latn' => 1
  },
  'bug' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'yap' => {
    'Latn' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'uig' => {
    'Cyrl' => 1,
    'Latn' => 2,
    'Arab' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'kri' => {
    'Latn' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'pam' => {
    'Latn' => 1
  },
  'zha' => {
    'Hans' => 2,
    'Latn' => 1
  },
  'kao' => {
    'Latn' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'jav' => {
    'Latn' => 1,
    'Java' => 2
  },
  'hsn' => {
    'Hans' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'ltg' => {
    'Latn' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'cop' => {
    'Grek' => 2,
    'Arab' => 2,
    'Copt' => 2
  },
  'cjm' => {
    'Arab' => 2,
    'Cham' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'arc' => {
    'Armi' => 2,
    'Nbat' => 2,
    'Palm' => 2
  },
  'hmo' => {
    'Latn' => 1
  },
  'bfq' => {
    'Taml' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'grt' => {
    'Beng' => 1
  },
  'byn' => {
    'Ethi' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'gag' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'mri' => {
    'Latn' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'lzz' => {
    'Latn' => 1,
    'Geor' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'aoz' => {
    'Latn' => 1
  },
  'msa' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'kas' => {
    'Arab' => 1,
    'Deva' => 1
  },
  'mni' => {
    'Mtei' => 2,
    'Beng' => 1
  },
  'dsb' => {
    'Latn' => 1
  },
  'frr' => {
    'Latn' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'ind' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'yue' => {
    'Hant' => 1,
    'Hans' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'kat' => {
    'Geor' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'iku' => {
    'Cans' => 1,
    'Latn' => 1
  },
  'tdd' => {
    'Tale' => 1
  },
  'sat' => {
    'Latn' => 2,
    'Deva' => 2,
    'Olck' => 1,
    'Beng' => 2,
    'Orya' => 2
  },
  'sas' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'ava' => {
    'Cyrl' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'mas' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'wbr' => {
    'Deva' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'fil' => {
    'Latn' => 1,
    'Tglg' => 2
  },
  'nnh' => {
    'Latn' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'kik' => {
    'Latn' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'non' => {
    'Runr' => 2
  },
  'rng' => {
    'Latn' => 1
  },
  'dyo' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'uzb' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'kur' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'kor' => {
    'Kore' => 1
  },
  'kam' => {
    'Latn' => 1
  },
  'bez' => {
    'Latn' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'kjg' => {
    'Laoo' => 1,
    'Latn' => 2
  },
  'cho' => {
    'Latn' => 1
  },
  'wae' => {
    'Latn' => 1
  },
  'crh' => {
    'Cyrl' => 1
  },
  'jpn' => {
    'Jpan' => 1
  },
  'kln' => {
    'Latn' => 1
  },
  'bto' => {
    'Latn' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'skr' => {
    'Arab' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'sam' => {
    'Samr' => 2,
    'Hebr' => 2
  },
  'btv' => {
    'Deva' => 1
  },
  'ndo' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'luo' => {
    'Latn' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'pms' => {
    'Latn' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'ban' => {
    'Bali' => 2,
    'Latn' => 1
  },
  'xum' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'shi' => {
    'Arab' => 1,
    'Tfng' => 1,
    'Latn' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'sah' => {
    'Cyrl' => 1
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'bew' => {
    'Latn' => 1
  },
  'fuq' => {
    'Latn' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'inh' => {
    'Latn' => 2,
    'Cyrl' => 1,
    'Arab' => 2
  },
  'xal' => {
    'Cyrl' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'khq' => {
    'Latn' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'gon' => {
    'Deva' => 1,
    'Telu' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'saq' => {
    'Latn' => 1
  },
  'ale' => {
    'Latn' => 1
  },
  'ron' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'mai' => {
    'Tirh' => 2,
    'Deva' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'ett' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'crk' => {
    'Cans' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'mro' => {
    'Latn' => 1,
    'Mroo' => 2
  },
  'nav' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'tur' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'snd' => {
    'Deva' => 1,
    'Arab' => 1,
    'Khoj' => 2,
    'Sind' => 2
  },
  'ewe' => {
    'Latn' => 1
  },
  'run' => {
    'Latn' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'zap' => {
    'Latn' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'tkr' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'anp' => {
    'Deva' => 1
  },
  'sou' => {
    'Thai' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'swa' => {
    'Latn' => 1
  },
  'wln' => {
    'Latn' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'wol' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'men' => {
    'Mend' => 2,
    'Latn' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'bos' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'mak' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'gay' => {
    'Latn' => 1
  },
  'bft' => {
    'Arab' => 1,
    'Tibt' => 2
  },
  'mdh' => {
    'Latn' => 1
  },
  'lcp' => {
    'Thai' => 1
  },
  'nym' => {
    'Latn' => 1
  },
  'hrv' => {
    'Latn' => 1
  },
  'lez' => {
    'Cyrl' => 1,
    'Aghb' => 2
  },
  'pdt' => {
    'Latn' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'bem' => {
    'Latn' => 1
  },
  'ain' => {
    'Latn' => 2,
    'Kana' => 2
  },
  'guc' => {
    'Latn' => 1
  },
  'kaz' => {
    'Cyrl' => 1,
    'Arab' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'cay' => {
    'Latn' => 1
  },
  'mtr' => {
    'Deva' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'fra' => {
    'Latn' => 1,
    'Dupl' => 2
  },
  'mrd' => {
    'Deva' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'bjj' => {
    'Deva' => 1
  },
  'tdg' => {
    'Deva' => 1,
    'Tibt' => 2
  },
  'thq' => {
    'Deva' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'bfd' => {
    'Latn' => 1
  },
  'maz' => {
    'Latn' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'sme' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'sqi' => {
    'Latn' => 1,
    'Elba' => 2
  },
  'swb' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'hai' => {
    'Latn' => 1
  },
  'den' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'srd' => {
    'Latn' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'chp' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'bam' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'fao' => {
    'Latn' => 1
  },
  'kyu' => {
    'Kali' => 1
  },
  'kaj' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'afr' => {
    'Latn' => 1
  },
  'yor' => {
    'Latn' => 1
  },
  'tvl' => {
    'Latn' => 1
  },
  'mxc' => {
    'Latn' => 1
  },
  'xpr' => {
    'Prti' => 2
  },
  'grn' => {
    'Latn' => 1
  },
  'swg' => {
    'Latn' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'osa' => {
    'Osge' => 1,
    'Latn' => 2
  },
  'ssy' => {
    'Latn' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'tbw' => {
    'Latn' => 1,
    'Tagb' => 2
  },
  'lim' => {
    'Latn' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'lag' => {
    'Latn' => 1
  },
  'nzi' => {
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'rug' => {
    'Latn' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'aii' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'ori' => {
    'Orya' => 1
  },
  'kmb' => {
    'Latn' => 1
  },
  'gju' => {
    'Arab' => 1
  },
  'sdc' => {
    'Latn' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'rcf' => {
    'Latn' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'byv' => {
    'Latn' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'ina' => {
    'Latn' => 2
  },
  'goh' => {
    'Latn' => 2
  },
  'maf' => {
    'Latn' => 1
  },
  'nsk' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'kan' => {
    'Knda' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'tem' => {
    'Latn' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'fas' => {
    'Arab' => 1
  },
  'tru' => {
    'Latn' => 1,
    'Syrc' => 2
  },
  'gsw' => {
    'Latn' => 1
  },
  'pau' => {
    'Latn' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'aln' => {
    'Latn' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'zho' => {
    'Bopo' => 2,
    'Hant' => 1,
    'Phag' => 2,
    'Hans' => 1
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'san' => {
    'Gran' => 2,
    'Sinh' => 2,
    'Deva' => 2,
    'Sidd' => 2,
    'Shrd' => 2
  },
  'chu' => {
    'Cyrl' => 2
  },
  'zgh' => {
    'Tfng' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'bhi' => {
    'Deva' => 1
  },
  'hmn' => {
    'Latn' => 1,
    'Plrd' => 1,
    'Hmng' => 2,
    'Laoo' => 1
  },
  'amh' => {
    'Ethi' => 1
  },
  'man' => {
    'Nkoo' => 1,
    'Latn' => 1
  },
  'crj' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'dty' => {
    'Deva' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'egy' => {
    'Egyp' => 2
  },
  'sxn' => {
    'Latn' => 1
  },
  'nyn' => {
    'Latn' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'kfy' => {
    'Deva' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'sus' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'srp' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'tso' => {
    'Latn' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'slk' => {
    'Latn' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'mgp' => {
    'Deva' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'sot' => {
    'Latn' => 1
  },
  'taj' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'grc' => {
    'Cprt' => 2,
    'Grek' => 2,
    'Linb' => 2
  },
  'nld' => {
    'Latn' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'xav' => {
    'Latn' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'syl' => {
    'Beng' => 1,
    'Sylo' => 2
  },
  'syr' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'tab' => {
    'Cyrl' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'osc' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'nog' => {
    'Cyrl' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'bku' => {
    'Latn' => 1,
    'Buhd' => 2
  },
  'kin' => {
    'Latn' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'unx' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'lah' => {
    'Arab' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'kha' => {
    'Beng' => 2,
    'Latn' => 1
  },
  'kgp' => {
    'Latn' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'rom' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'bej' => {
    'Arab' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'rar' => {
    'Latn' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'uga' => {
    'Ugar' => 2
  },
  'bbc' => {
    'Batk' => 2,
    'Latn' => 1
  },
  'xsa' => {
    'Sarb' => 2
  },
  'rgn' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'gil' => {
    'Latn' => 1
  },
  'ttt' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 2
  },
  'nau' => {
    'Latn' => 1
  },
  'ary' => {
    'Arab' => 1
  },
  'bmq' => {
    'Latn' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'hif' => {
    'Deva' => 1,
    'Latn' => 1
  },
  'bqi' => {
    'Arab' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'tsd' => {
    'Grek' => 1
  },
  'pal' => {
    'Phlp' => 2,
    'Phli' => 2
  },
  'guz' => {
    'Latn' => 1
  },
  'hin' => {
    'Mahj' => 2,
    'Latn' => 2,
    'Deva' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'orm' => {
    'Latn' => 1,
    'Ethi' => 2
  },
  'oci' => {
    'Latn' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'zza' => {
    'Latn' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'tuk' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'phn' => {
    'Phnx' => 2
  },
  'crl' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'kiu' => {
    'Latn' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'tog' => {
    'Latn' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'tir' => {
    'Ethi' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'stq' => {
    'Latn' => 1
  },
  'bua' => {
    'Cyrl' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'vie' => {
    'Hani' => 2,
    'Latn' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'rif' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'gaa' => {
    'Latn' => 1
  },
  'bis' => {
    'Latn' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'tzm' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'ssw' => {
    'Latn' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'moh' => {
    'Latn' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'srb' => {
    'Sora' => 2,
    'Latn' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'thl' => {
    'Deva' => 1
  },
  'lad' => {
    'Latn' => 2,
    'Hebr' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'rkt' => {
    'Beng' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'ave' => {
    'Avst' => 2
  },
  'jml' => {
    'Deva' => 1
  },
  'lmo' => {
    'Latn' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'tly' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'brh' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'som' => {
    'Osma' => 2,
    'Latn' => 1,
    'Arab' => 2
  },
  'bho' => {
    'Deva' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'lao' => {
    'Laoo' => 1
  },
  'hnn' => {
    'Latn' => 1,
    'Hano' => 2
  },
  'ccp' => {
    'Beng' => 1,
    'Cakm' => 1
  },
  'pko' => {
    'Latn' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'eng' => {
    'Shaw' => 2,
    'Dsrt' => 2,
    'Latn' => 1
  },
  'sga' => {
    'Ogam' => 2,
    'Latn' => 2
  },
  'pli' => {
    'Thai' => 2,
    'Sinh' => 2,
    'Deva' => 2
  },
  'frs' => {
    'Latn' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'kom' => {
    'Perm' => 2,
    'Cyrl' => 1
  },
  'avk' => {
    'Latn' => 2
  },
  'kum' => {
    'Cyrl' => 1
  },
  'srx' => {
    'Deva' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'amo' => {
    'Latn' => 1
  },
  'ful' => {
    'Adlm' => 2,
    'Latn' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'fur' => {
    'Latn' => 1
  },
  'arz' => {
    'Arab' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'liv' => {
    'Latn' => 2
  },
  'kvx' => {
    'Arab' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'ach' => {
    'Latn' => 1
  },
  'kir' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'zea' => {
    'Latn' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'nus' => {
    'Latn' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'yao' => {
    'Latn' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'lfn' => {
    'Latn' => 2,
    'Cyrl' => 2
  },
  'aym' => {
    'Latn' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'vmw' => {
    'Latn' => 1
  },
  'unr' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'myx' => {
    'Latn' => 1
  },
  'nod' => {
    'Lana' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'hau' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'hbs' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'arg' => {
    'Latn' => 1
  },
  'doi' => {
    'Takr' => 2,
    'Arab' => 1,
    'Deva' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'war' => {
    'Latn' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'lua' => {
    'Latn' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'xsr' => {
    'Deva' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'ven' => {
    'Latn' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'hil' => {
    'Latn' => 1
  },
  'cja' => {
    'Cham' => 2,
    'Arab' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'pan' => {
    'Guru' => 1,
    'Arab' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'mdr' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'koi' => {
    'Cyrl' => 1
  },
  'bzx' => {
    'Latn' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'krc' => {
    'Cyrl' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'kca' => {
    'Cyrl' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'dtm' => {
    'Latn' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'gos' => {
    'Latn' => 1
  },
  'ikt' => {
    'Latn' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'vai' => {
    'Latn' => 1,
    'Vaii' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'tum' => {
    'Latn' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'nov' => {
    'Latn' => 2
  },
  'sly' => {
    'Latn' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'atj' => {
    'Latn' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'glg' => {
    'Latn' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'lit' => {
    'Latn' => 1
  }
};
$Territory2Lang = {
  'BY' => {
    'bel' => 1,
    'rus' => 1
  },
  'AQ' => {
    'und' => 2
  },
  'GH' => {
    'ewe' => 2,
    'eng' => 1,
    'aka' => 2,
    'abr' => 2,
    'gaa' => 2
  },
  'BW' => {
    'tsn' => 1,
    'eng' => 1
  },
  'BZ' => {
    'spa' => 2,
    'eng' => 1
  },
  'GY' => {
    'eng' => 1
  },
  'CM' => {
    'bum' => 2,
    'eng' => 1,
    'fra' => 1
  },
  'LS' => {
    'eng' => 1,
    'sot' => 1
  },
  'BH' => {
    'ara' => 1
  },
  'GW' => {
    'por' => 1
  },
  'IO' => {
    'eng' => 1
  },
  'SI' => {
    'eng' => 2,
    'hbs' => 2,
    'deu' => 2,
    'slv' => 1,
    'hrv' => 2
  },
  'SA' => {
    'ara' => 1
  },
  'CK' => {
    'eng' => 1
  },
  'SC' => {
    'fra' => 1,
    'crs' => 2,
    'eng' => 1
  },
  'ST' => {
    'por' => 1
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'PA' => {
    'spa' => 1
  },
  'IL' => {
    'ara' => 1,
    'heb' => 1,
    'eng' => 2
  },
  'PT' => {
    'spa' => 2,
    'por' => 1,
    'fra' => 2,
    'eng' => 2
  },
  'PR' => {
    'eng' => 1,
    'spa' => 1
  },
  'AM' => {
    'hye' => 1
  },
  'SR' => {
    'srn' => 2,
    'nld' => 1
  },
  'RW' => {
    'fra' => 1,
    'eng' => 1,
    'kin' => 1
  },
  'NU' => {
    'eng' => 1,
    'niu' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'HK' => {
    'zho' => 1,
    'eng' => 1,
    'yue' => 2
  },
  'NP' => {
    'mai' => 2,
    'bho' => 2,
    'nep' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'SX' => {
    'eng' => 1,
    'nld' => 1
  },
  'GN' => {
    'man' => 2,
    'ful' => 2,
    'sus' => 2,
    'fra' => 1
  },
  'ER' => {
    'tir' => 1,
    'ara' => 1,
    'tig' => 2,
    'eng' => 1
  },
  'ET' => {
    'orm' => 2,
    'aar' => 2,
    'som' => 2,
    'tir' => 2,
    'amh' => 1,
    'sid' => 2,
    'eng' => 2,
    'wal' => 2
  },
  'CG' => {
    'fra' => 1
  },
  'EA' => {
    'spa' => 1
  },
  'EC' => {
    'spa' => 1,
    'que' => 1
  },
  'HM' => {
    'und' => 2
  },
  'IC' => {
    'spa' => 1
  },
  'PL' => {
    'deu' => 2,
    'lit' => 2,
    'csb' => 2,
    'rus' => 2,
    'pol' => 1,
    'eng' => 2
  },
  'IT' => {
    'ita' => 1,
    'eng' => 2,
    'fra' => 2,
    'srd' => 2
  },
  'SE' => {
    'fin' => 2,
    'eng' => 2,
    'swe' => 1
  },
  'SL' => {
    'men' => 2,
    'kri' => 2,
    'eng' => 1,
    'tem' => 2
  },
  'PE' => {
    'spa' => 1,
    'que' => 1
  },
  'CV' => {
    'por' => 1,
    'kea' => 2
  },
  'DM' => {
    'eng' => 1
  },
  'ZM' => {
    'nya' => 2,
    'eng' => 1,
    'bem' => 2
  },
  'MS' => {
    'eng' => 1
  },
  'IR' => {
    'sdh' => 2,
    'kur' => 2,
    'bal' => 2,
    'luz' => 2,
    'ara' => 2,
    'fas' => 1,
    'aze' => 2,
    'lrc' => 2,
    'glk' => 2,
    'bqi' => 2,
    'rmt' => 2,
    'ckb' => 2,
    'tuk' => 2,
    'mzn' => 2
  },
  'UA' => {
    'ukr' => 1,
    'pol' => 2,
    'rus' => 1
  },
  'HU' => {
    'hun' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'DK' => {
    'eng' => 2,
    'dan' => 1,
    'deu' => 2,
    'kal' => 2
  },
  'VN' => {
    'zho' => 2,
    'vie' => 1
  },
  'KN' => {
    'eng' => 1
  },
  'SO' => {
    'ara' => 1,
    'som' => 1
  },
  'DJ' => {
    'aar' => 2,
    'ara' => 1,
    'fra' => 1,
    'som' => 2
  },
  'CP' => {
    'und' => 2
  },
  'CU' => {
    'spa' => 1
  },
  'EE' => {
    'eng' => 2,
    'fin' => 2,
    'rus' => 2,
    'est' => 1
  },
  'AD' => {
    'spa' => 2,
    'cat' => 1
  },
  'XK' => {
    'srp' => 1,
    'hbs' => 1,
    'sqi' => 1,
    'aln' => 2
  },
  'AU' => {
    'eng' => 1
  },
  'KH' => {
    'khm' => 1
  },
  'PF' => {
    'fra' => 1,
    'tah' => 1
  },
  'DG' => {
    'eng' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'CD' => {
    'lin' => 2,
    'swa' => 2,
    'lua' => 2,
    'kon' => 2,
    'fra' => 1,
    'lub' => 2
  },
  'KZ' => {
    'deu' => 2,
    'kaz' => 1,
    'eng' => 2,
    'rus' => 1
  },
  'NG' => {
    'ful' => 2,
    'ibo' => 2,
    'bin' => 2,
    'tiv' => 2,
    'hau' => 2,
    'ibb' => 2,
    'eng' => 1,
    'efi' => 2,
    'fuv' => 2,
    'pcm' => 2,
    'yor' => 1
  },
  'KY' => {
    'eng' => 1
  },
  'TT' => {
    'eng' => 1
  },
  'TA' => {
    'eng' => 2
  },
  'VG' => {
    'eng' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'BV' => {
    'und' => 2
  },
  'DZ' => {
    'fra' => 1,
    'ara' => 2,
    'kab' => 2,
    'eng' => 2,
    'arq' => 2
  },
  'KG' => {
    'rus' => 1,
    'kir' => 1
  },
  'US' => {
    'eng' => 1,
    'zho' => 2,
    'ita' => 2,
    'fra' => 2,
    'haw' => 2,
    'spa' => 2,
    'kor' => 2,
    'vie' => 2,
    'fil' => 2,
    'deu' => 2
  },
  'ZW' => {
    'eng' => 1,
    'sna' => 1,
    'nde' => 1
  },
  'NZ' => {
    'mri' => 1,
    'eng' => 1
  },
  'FI' => {
    'swe' => 1,
    'eng' => 2,
    'fin' => 1
  },
  'TR' => {
    'zza' => 2,
    'eng' => 2,
    'tur' => 1,
    'kur' => 2
  },
  'JP' => {
    'jpn' => 1
  },
  'MC' => {
    'fra' => 1
  },
  'MA' => {
    'rif' => 2,
    'tzm' => 1,
    'zgh' => 2,
    'shi' => 2,
    'eng' => 2,
    'ary' => 2,
    'ara' => 2,
    'fra' => 1
  },
  'MT' => {
    'mlt' => 1,
    'eng' => 1,
    'ita' => 2
  },
  'IS' => {
    'isl' => 1
  },
  'MR' => {
    'ara' => 1
  },
  'FR' => {
    'oci' => 2,
    'deu' => 2,
    'fra' => 1,
    'spa' => 2,
    'eng' => 2,
    'ita' => 2
  },
  'GU' => {
    'cha' => 1,
    'eng' => 1
  },
  'GP' => {
    'fra' => 1
  },
  'MX' => {
    'spa' => 1,
    'eng' => 2
  },
  'RU' => {
    'lez' => 2,
    'chv' => 2,
    'ava' => 2,
    'kbd' => 2,
    'ady' => 2,
    'kom' => 2,
    'lbe' => 2,
    'sah' => 2,
    'bak' => 2,
    'kum' => 2,
    'che' => 2,
    'hye' => 2,
    'myv' => 2,
    'udm' => 2,
    'inh' => 2,
    'tyv' => 2,
    'tat' => 2,
    'krc' => 2,
    'mdf' => 2,
    'rus' => 1,
    'aze' => 2,
    'koi' => 2
  },
  'BD' => {
    'rkt' => 2,
    'syl' => 2,
    'eng' => 2,
    'ben' => 1
  },
  'YT' => {
    'buc' => 2,
    'swb' => 2,
    'fra' => 1
  },
  'KM' => {
    'fra' => 1,
    'zdj' => 1,
    'ara' => 1,
    'wni' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'ME' => {
    'hbs' => 1,
    'srp' => 1
  },
  'CH' => {
    'gsw' => 1,
    'fra' => 1,
    'roh' => 2,
    'ita' => 1,
    'eng' => 2,
    'deu' => 1
  },
  'ML' => {
    'ffm' => 2,
    'bam' => 2,
    'fra' => 1,
    'snk' => 2,
    'ful' => 2
  },
  'BM' => {
    'eng' => 1
  },
  'CZ' => {
    'eng' => 2,
    'ces' => 1,
    'deu' => 2,
    'slk' => 2
  },
  'CW' => {
    'nld' => 1,
    'pap' => 1
  },
  'SS' => {
    'eng' => 1,
    'ara' => 2
  },
  'CY' => {
    'eng' => 2,
    'tur' => 1,
    'ell' => 1
  },
  'LI' => {
    'deu' => 1,
    'gsw' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'GM' => {
    'eng' => 1,
    'man' => 2
  },
  'TO' => {
    'eng' => 1,
    'ton' => 1
  },
  'LC' => {
    'eng' => 1
  },
  'KP' => {
    'kor' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'LT' => {
    'lit' => 1,
    'rus' => 2,
    'eng' => 2
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'GQ' => {
    'spa' => 1,
    'por' => 1,
    'fan' => 2,
    'fra' => 1
  },
  'AZ' => {
    'aze' => 1
  },
  'AW' => {
    'pap' => 1,
    'nld' => 1
  },
  'MO' => {
    'zho' => 1,
    'por' => 1
  },
  'VU' => {
    'bis' => 1,
    'fra' => 1,
    'eng' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'BQ' => {
    'pap' => 2,
    'nld' => 1
  },
  'HN' => {
    'spa' => 1
  },
  'FO' => {
    'fao' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'ES' => {
    'spa' => 1,
    'ast' => 2,
    'glg' => 2,
    'eng' => 2,
    'eus' => 2,
    'cat' => 2
  },
  'YE' => {
    'eng' => 2,
    'ara' => 1
  },
  'CN' => {
    'hsn' => 2,
    'kaz' => 2,
    'uig' => 2,
    'mon' => 2,
    'yue' => 2,
    'iii' => 2,
    'bod' => 2,
    'hak' => 2,
    'zha' => 2,
    'gan' => 2,
    'zho' => 1,
    'nan' => 2,
    'wuu' => 2,
    'kor' => 2
  },
  'BJ' => {
    'fra' => 1,
    'fon' => 2
  },
  'MF' => {
    'fra' => 1
  },
  'GB' => {
    'gle' => 2,
    'deu' => 2,
    'sco' => 2,
    'eng' => 1,
    'cym' => 2,
    'fra' => 2,
    'gla' => 2
  },
  'BG' => {
    'eng' => 2,
    'rus' => 2,
    'bul' => 1
  },
  'JM' => {
    'eng' => 1,
    'jam' => 2
  },
  'BB' => {
    'eng' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'PK' => {
    'eng' => 1,
    'lah' => 2,
    'hno' => 2,
    'brh' => 2,
    'fas' => 2,
    'snd' => 2,
    'bal' => 2,
    'skr' => 2,
    'pan' => 2,
    'bgn' => 2,
    'pus' => 2,
    'urd' => 1
  },
  'SK' => {
    'ces' => 2,
    'deu' => 2,
    'slk' => 1,
    'eng' => 2
  },
  'CA' => {
    'iku' => 2,
    'fra' => 1,
    'ikt' => 2,
    'eng' => 1
  },
  'CC' => {
    'eng' => 1,
    'msa' => 2
  },
  'EG' => {
    'eng' => 2,
    'arz' => 2,
    'ara' => 2
  },
  'CR' => {
    'spa' => 1
  },
  'RS' => {
    'ron' => 2,
    'sqi' => 2,
    'hun' => 2,
    'slk' => 2,
    'hrv' => 2,
    'srp' => 1,
    'ukr' => 2,
    'hbs' => 1
  },
  'DO' => {
    'spa' => 1
  },
  'AI' => {
    'eng' => 1
  },
  'NO' => {
    'nor' => 1,
    'nno' => 1,
    'sme' => 2,
    'nob' => 1
  },
  'BS' => {
    'eng' => 1
  },
  'NE' => {
    'fra' => 1,
    'tmh' => 2,
    'hau' => 2,
    'fuq' => 2,
    'ful' => 2,
    'dje' => 2
  },
  'AC' => {
    'eng' => 2
  },
  'NL' => {
    'deu' => 2,
    'nds' => 2,
    'eng' => 2,
    'fry' => 2,
    'nld' => 1,
    'fra' => 2
  },
  'AT' => {
    'deu' => 1,
    'hun' => 2,
    'slv' => 2,
    'hrv' => 2,
    'eng' => 2,
    'bar' => 2,
    'hbs' => 2
  },
  'DE' => {
    'eng' => 2,
    'nds' => 2,
    'spa' => 2,
    'dan' => 2,
    'vmf' => 2,
    'deu' => 1,
    'rus' => 2,
    'bar' => 2,
    'nld' => 2,
    'ita' => 2,
    'gsw' => 2,
    'tur' => 2,
    'fra' => 2
  },
  'AR' => {
    'eng' => 2,
    'spa' => 1
  },
  'PM' => {
    'fra' => 1
  },
  'GS' => {
    'und' => 2
  },
  'CI' => {
    'bci' => 2,
    'dnj' => 2,
    'sef' => 2,
    'fra' => 1
  },
  'LY' => {
    'ara' => 1
  },
  'SM' => {
    'ita' => 1
  },
  'NF' => {
    'eng' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'AX' => {
    'swe' => 1
  },
  'PG' => {
    'tpi' => 1,
    'hmo' => 1,
    'eng' => 1
  },
  'WS' => {
    'eng' => 1,
    'smo' => 1
  },
  'SG' => {
    'eng' => 1,
    'zho' => 1,
    'msa' => 1,
    'tam' => 1
  },
  'HT' => {
    'hat' => 1,
    'fra' => 1
  },
  'SJ' => {
    'rus' => 2,
    'nob' => 1,
    'nor' => 1
  },
  'CX' => {
    'eng' => 1
  },
  'ID' => {
    'jav' => 2,
    'ljp' => 2,
    'bjn' => 2,
    'rej' => 2,
    'sun' => 2,
    'sas' => 2,
    'ind' => 1,
    'ace' => 2,
    'zho' => 2,
    'bew' => 2,
    'gor' => 2,
    'bug' => 2,
    'mad' => 2,
    'bbc' => 2,
    'mak' => 2,
    'msa' => 2,
    'ban' => 2,
    'min' => 2
  },
  'HR' => {
    'hrv' => 1,
    'eng' => 2,
    'hbs' => 1,
    'ita' => 2
  },
  'NC' => {
    'fra' => 1
  },
  'AL' => {
    'sqi' => 1
  },
  'NA' => {
    'kua' => 2,
    'eng' => 1,
    'afr' => 2,
    'ndo' => 2
  },
  'TH' => {
    'tts' => 2,
    'eng' => 2,
    'zho' => 2,
    'nod' => 2,
    'sou' => 2,
    'mfa' => 2,
    'msa' => 2,
    'kxm' => 2,
    'tha' => 1
  },
  'ZA' => {
    'ssw' => 2,
    'xho' => 2,
    'ven' => 2,
    'eng' => 1,
    'nbl' => 2,
    'tsn' => 2,
    'hin' => 2,
    'nso' => 2,
    'sot' => 2,
    'afr' => 2,
    'zul' => 2,
    'tso' => 2
  },
  'AE' => {
    'eng' => 2,
    'ara' => 1
  },
  'QA' => {
    'ara' => 1
  },
  'CO' => {
    'spa' => 1
  },
  'IM' => {
    'eng' => 1,
    'glv' => 1
  },
  'TW' => {
    'zho' => 1
  },
  'NR' => {
    'eng' => 1,
    'nau' => 1
  },
  'TZ' => {
    'swa' => 1,
    'kde' => 2,
    'nym' => 2,
    'eng' => 1,
    'suk' => 2
  },
  'CL' => {
    'spa' => 1,
    'eng' => 2
  },
  'MH' => {
    'eng' => 1,
    'mah' => 1
  },
  'IQ' => {
    'eng' => 2,
    'ckb' => 2,
    'aze' => 2,
    'ara' => 1,
    'kur' => 2
  },
  'AO' => {
    'umb' => 2,
    'por' => 1,
    'kmb' => 2
  },
  'MY' => {
    'tam' => 2,
    'eng' => 2,
    'zho' => 2,
    'msa' => 1
  },
  'UM' => {
    'eng' => 1
  },
  'MZ' => {
    'mgh' => 2,
    'ndc' => 2,
    'tso' => 2,
    'seh' => 2,
    'ngl' => 2,
    'vmw' => 2,
    'por' => 1
  },
  'SV' => {
    'spa' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'MW' => {
    'tum' => 2,
    'eng' => 1,
    'nya' => 1
  },
  'CF' => {
    'fra' => 1,
    'sag' => 1
  },
  'UG' => {
    'teo' => 2,
    'laj' => 2,
    'cgg' => 2,
    'swa' => 1,
    'eng' => 1,
    'myx' => 2,
    'lug' => 2,
    'nyn' => 2,
    'xog' => 2,
    'ach' => 2
  },
  'SD' => {
    'fvr' => 2,
    'eng' => 1,
    'bej' => 2,
    'ara' => 1
  },
  'TN' => {
    'fra' => 1,
    'ara' => 1,
    'aeb' => 2
  },
  'AF' => {
    'tuk' => 2,
    'pus' => 1,
    'uzb' => 2,
    'fas' => 1,
    'bal' => 2,
    'haz' => 2
  },
  'MN' => {
    'mon' => 1
  },
  'RE' => {
    'fra' => 1,
    'rcf' => 2
  },
  'MQ' => {
    'fra' => 1
  },
  'MK' => {
    'mkd' => 1,
    'sqi' => 2
  },
  'FK' => {
    'eng' => 1
  },
  'BO' => {
    'spa' => 1,
    'aym' => 1,
    'que' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'GE' => {
    'kat' => 1,
    'abk' => 2,
    'oss' => 2
  },
  'WF' => {
    'fra' => 1,
    'wls' => 2,
    'fud' => 2
  },
  'GL' => {
    'kal' => 1
  },
  'TK' => {
    'eng' => 1,
    'tkl' => 1
  },
  'OM' => {
    'ara' => 1
  },
  'BE' => {
    'eng' => 2,
    'nld' => 1,
    'deu' => 1,
    'fra' => 1,
    'vls' => 2
  },
  'UY' => {
    'spa' => 1
  },
  'UZ' => {
    'uzb' => 1,
    'rus' => 2
  },
  'MM' => {
    'shn' => 2,
    'mya' => 1
  },
  'LV' => {
    'eng' => 2,
    'lav' => 1,
    'rus' => 2
  },
  'RO' => {
    'ron' => 1,
    'eng' => 2,
    'hun' => 2,
    'spa' => 2,
    'fra' => 2
  },
  'FM' => {
    'chk' => 2,
    'pon' => 2,
    'eng' => 1
  },
  'BL' => {
    'fra' => 1
  },
  'VI' => {
    'eng' => 1
  },
  'GF' => {
    'fra' => 1,
    'gcr' => 2
  },
  'JE' => {
    'eng' => 1
  },
  'TJ' => {
    'rus' => 2,
    'tgk' => 1
  },
  'BF' => {
    'mos' => 2,
    'fra' => 1,
    'dyu' => 2
  },
  'KI' => {
    'gil' => 1,
    'eng' => 1
  },
  'IN' => {
    'guj' => 2,
    'hoj' => 2,
    'doi' => 2,
    'swv' => 2,
    'kha' => 2,
    'hne' => 2,
    'wbr' => 2,
    'rkt' => 2,
    'asm' => 2,
    'raj' => 2,
    'lmn' => 2,
    'awa' => 2,
    'bhi' => 2,
    'nep' => 2,
    'wtm' => 2,
    'wbq' => 2,
    'hin' => 1,
    'gom' => 2,
    'gon' => 2,
    'bhb' => 2,
    'gbm' => 2,
    'san' => 2,
    'noe' => 2,
    'eng' => 1,
    'unr' => 2,
    'bjj' => 2,
    'tel' => 2,
    'sat' => 2,
    'mwr' => 2,
    'snd' => 2,
    'sck' => 2,
    'kru' => 2,
    'kok' => 2,
    'pan' => 2,
    'brx' => 2,
    'urd' => 2,
    'mtr' => 2,
    'mag' => 2,
    'bho' => 2,
    'mni' => 2,
    'kas' => 2,
    'kan' => 2,
    'tam' => 2,
    'mal' => 2,
    'dcc' => 2,
    'hoc' => 2,
    'mar' => 2,
    'khn' => 2,
    'ben' => 2,
    'kfy' => 2,
    'xnr' => 2,
    'bgc' => 2,
    'ori' => 2,
    'mai' => 2,
    'tcy' => 2
  },
  'MG' => {
    'fra' => 1,
    'mlg' => 1,
    'eng' => 1
  },
  'LU' => {
    'eng' => 2,
    'ltz' => 1,
    'fra' => 1,
    'deu' => 1
  },
  'FJ' => {
    'fij' => 1,
    'eng' => 1,
    'hin' => 2,
    'hif' => 1
  },
  'KR' => {
    'kor' => 1
  },
  'JO' => {
    'ara' => 1,
    'eng' => 2
  },
  'VA' => {
    'lat' => 2,
    'ita' => 1
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'VC' => {
    'eng' => 1
  },
  'GT' => {
    'quc' => 2,
    'spa' => 1
  },
  'GA' => {
    'fra' => 1
  },
  'LK' => {
    'sin' => 1,
    'eng' => 2,
    'tam' => 1
  },
  'BR' => {
    'por' => 1,
    'deu' => 2,
    'eng' => 2
  },
  'BT' => {
    'dzo' => 1
  },
  'BA' => {
    'hrv' => 1,
    'bos' => 1,
    'hbs' => 1,
    'eng' => 2,
    'srp' => 1
  },
  'TV' => {
    'eng' => 1,
    'tvl' => 1
  },
  'GR' => {
    'ell' => 1,
    'eng' => 2
  },
  'AS' => {
    'smo' => 1,
    'eng' => 1
  },
  'SH' => {
    'eng' => 1
  },
  'PH' => {
    'ceb' => 2,
    'ilo' => 2,
    'pam' => 2,
    'fil' => 1,
    'bik' => 2,
    'tsg' => 2,
    'eng' => 1,
    'pag' => 2,
    'hil' => 2,
    'mdh' => 2,
    'spa' => 2,
    'bhk' => 2,
    'war' => 2
  },
  'BI' => {
    'fra' => 1,
    'run' => 1,
    'eng' => 1
  },
  'PW' => {
    'pau' => 1,
    'eng' => 1
  },
  'SY' => {
    'kur' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'GI' => {
    'spa' => 2,
    'eng' => 1
  },
  'SZ' => {
    'eng' => 1,
    'ssw' => 1
  },
  'MV' => {
    'div' => 1
  },
  'PY' => {
    'grn' => 1,
    'spa' => 1
  },
  'KE' => {
    'kik' => 2,
    'guz' => 2,
    'swa' => 1,
    'kam' => 2,
    'luo' => 2,
    'luy' => 2,
    'eng' => 1,
    'mer' => 2,
    'kln' => 2
  },
  'LB' => {
    'eng' => 2,
    'ara' => 1
  },
  'VE' => {
    'spa' => 1
  },
  'MD' => {
    'ron' => 1
  },
  'MU' => {
    'eng' => 1,
    'fra' => 1,
    'mfe' => 2,
    'bho' => 2
  },
  'MP' => {
    'eng' => 1
  },
  'PN' => {
    'eng' => 1
  },
  'EH' => {
    'ara' => 1
  },
  'TD' => {
    'ara' => 1,
    'fra' => 1
  },
  'SN' => {
    'mey' => 2,
    'knf' => 2,
    'bsc' => 2,
    'tnr' => 2,
    'fra' => 1,
    'wol' => 1,
    'dyo' => 2,
    'mfv' => 2,
    'snf' => 2,
    'bjt' => 2,
    'ful' => 2,
    'srr' => 2,
    'sav' => 2
  }
};
$Script2Lang = {
  'Khoj' => {
    'snd' => 2
  },
  'Phli' => {
    'pal' => 2
  },
  'Avst' => {
    'ave' => 2
  },
  'Tirh' => {
    'mai' => 2
  },
  'Sund' => {
    'sun' => 2
  },
  'Shrd' => {
    'san' => 2
  },
  'Arab' => {
    'ckb' => 1,
    'arq' => 1,
    'swb' => 1,
    'hau' => 1,
    'raj' => 1,
    'lah' => 1,
    'gbz' => 1,
    'wol' => 2,
    'pus' => 1,
    'bgn' => 1,
    'aze' => 1,
    'hnd' => 1,
    'doi' => 1,
    'bal' => 1,
    'cjm' => 2,
    'cop' => 2,
    'lki' => 1,
    'kxp' => 1,
    'zdj' => 1,
    'glk' => 1,
    'ara' => 1,
    'luz' => 1,
    'aeb' => 1,
    'kas' => 1,
    'brh' => 1,
    'hno' => 1,
    'msa' => 1,
    'khw' => 1,
    'cja' => 1,
    'rmt' => 1,
    'mvy' => 1,
    'som' => 2,
    'haz' => 1,
    'wni' => 1,
    'pan' => 1,
    'urd' => 1,
    'tgk' => 1,
    'bqi' => 1,
    'ars' => 1,
    'inh' => 2,
    'ind' => 2,
    'lrc' => 1,
    'snd' => 1,
    'fas' => 1,
    'skr' => 1,
    'sdh' => 1,
    'bej' => 1,
    'tuk' => 1,
    'mzn' => 1,
    'gju' => 1,
    'bft' => 1,
    'shi' => 1,
    'arz' => 1,
    'gjk' => 1,
    'tly' => 1,
    'mfa' => 1,
    'prd' => 1,
    'fia' => 1,
    'dyo' => 2,
    'sus' => 2,
    'ttt' => 2,
    'kvx' => 1,
    'uzb' => 1,
    'ary' => 1,
    'kir' => 1,
    'tur' => 2,
    'uig' => 1,
    'kaz' => 1,
    'kur' => 1,
    'dcc' => 1
  },
  'Sind' => {
    'snd' => 2
  },
  'Linb' => {
    'grc' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Goth' => {
    'got' => 2
  },
  'Mroo' => {
    'mro' => 2
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Tfng' => {
    'shi' => 1,
    'rif' => 1,
    'zgh' => 1,
    'tzm' => 1,
    'zen' => 2
  },
  'Narb' => {
    'xna' => 2
  },
  'Khmr' => {
    'khm' => 1
  },
  'Shaw' => {
    'eng' => 2
  },
  'Kore' => {
    'kor' => 1
  },
  'Plrd' => {
    'hmd' => 1,
    'hmn' => 1
  },
  'Phnx' => {
    'phn' => 2
  },
  'Armi' => {
    'arc' => 2
  },
  'Aghb' => {
    'lez' => 2
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Tglg' => {
    'fil' => 2
  },
  'Nkoo' => {
    'man' => 1,
    'nqo' => 1,
    'bam' => 1
  },
  'Lepc' => {
    'lep' => 1
  },
  'Samr' => {
    'sam' => 2,
    'smp' => 2
  },
  'Gujr' => {
    'guj' => 1
  },
  'Laoo' => {
    'lao' => 1,
    'hnj' => 1,
    'kjg' => 1,
    'hmn' => 1
  },
  'Mani' => {
    'xmn' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Egyp' => {
    'egy' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Sidd' => {
    'san' => 2
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Gran' => {
    'san' => 2
  },
  'Yiii' => {
    'iii' => 1
  },
  'Sora' => {
    'srb' => 2
  },
  'Takr' => {
    'doi' => 2
  },
  'Latn' => {
    'mdh' => 1,
    'war' => 1,
    'arw' => 2,
    'hrv' => 1,
    'nym' => 1,
    'pdt' => 1,
    'lua' => 1,
    'mak' => 1,
    'bas' => 1,
    'gay' => 1,
    'guc' => 1,
    'ain' => 2,
    'sag' => 1,
    'arp' => 1,
    'bem' => 1,
    'hil' => 1,
    'nch' => 1,
    'zag' => 1,
    'vls' => 1,
    'haw' => 1,
    'teo' => 1,
    'ven' => 1,
    'chn' => 2,
    'bqv' => 1,
    'sgs' => 1,
    'mdr' => 1,
    'bzx' => 1,
    'fra' => 1,
    'slv' => 1,
    'nij' => 1,
    'ang' => 2,
    'laj' => 1,
    'cay' => 1,
    'cre' => 2,
    'umb' => 1,
    'vro' => 1,
    'dtm' => 1,
    'ipk' => 1,
    'zmi' => 1,
    'szl' => 1,
    'cha' => 1,
    'ksh' => 1,
    'tsg' => 1,
    'eka' => 1,
    'scn' => 1,
    'maz' => 1,
    'moe' => 1,
    'sme' => 1,
    'csb' => 2,
    'gos' => 1,
    'kau' => 1,
    'ikt' => 1,
    'vai' => 1,
    'bfd' => 1,
    'rob' => 1,
    'tah' => 1,
    'que' => 1,
    'ext' => 1,
    'sqi' => 1,
    'nov' => 2,
    'sly' => 1,
    'tum' => 1,
    'cos' => 1,
    'lun' => 1,
    'pdc' => 1,
    'atj' => 1,
    'swb' => 2,
    'glg' => 1,
    'lit' => 1,
    'agq' => 1,
    'hai' => 1,
    'den' => 1,
    'srd' => 1,
    'lub' => 1,
    'saq' => 1,
    'amo' => 1,
    'dak' => 1,
    'ron' => 1,
    'ale' => 1,
    'enm' => 2,
    'ful' => 1,
    'fur' => 1,
    'mgo' => 1,
    'cat' => 1,
    'ita' => 1,
    'mro' => 1,
    'nav' => 1,
    'tur' => 1,
    'zea' => 1,
    'ach' => 1,
    'kir' => 1,
    'asa' => 1,
    'ada' => 1,
    'ett' => 2,
    'est' => 1,
    'liv' => 2,
    'nus' => 1,
    'bre' => 1,
    'yao' => 1,
    'egl' => 1,
    'tet' => 1,
    'jgo' => 1,
    'cgg' => 1,
    'tmh' => 1,
    'ffm' => 1,
    'aym' => 1,
    'lfn' => 2,
    'mgy' => 1,
    'ewe' => 1,
    'run' => 1,
    'mfe' => 1,
    'sef' => 1,
    'buc' => 1,
    'oji' => 2,
    'yav' => 1,
    'tkl' => 1,
    'rmf' => 1,
    'hop' => 1,
    'pon' => 1,
    'tkr' => 1,
    'bin' => 1,
    'rwk' => 1,
    'nia' => 1,
    'zap' => 1,
    'vmw' => 1,
    'bjn' => 1,
    'kea' => 1,
    'myx' => 1,
    'cch' => 1,
    'gcr' => 1,
    'cad' => 1,
    'hbs' => 1,
    'wln' => 1,
    'tsi' => 1,
    'mlt' => 1,
    'qug' => 1,
    'hau' => 1,
    'swa' => 1,
    'cym' => 1,
    'bos' => 1,
    'arg' => 1,
    'xog' => 1,
    'mls' => 1,
    'rof' => 1,
    'wol' => 1,
    'gle' => 1,
    'suk' => 1,
    'hup' => 1,
    'men' => 1,
    'xum' => 2,
    'shi' => 1,
    'ban' => 1,
    'prg' => 2,
    'tly' => 1,
    'ace' => 1,
    'yrl' => 1,
    'cic' => 1,
    'bew' => 1,
    'bss' => 1,
    'lkt' => 1,
    'som' => 1,
    'mah' => 1,
    'fuq' => 1,
    'brh' => 2,
    'aka' => 1,
    'njo' => 1,
    'rmo' => 1,
    'frc' => 1,
    'ndc' => 1,
    'srn' => 1,
    'hnn' => 1,
    'inh' => 2,
    'vol' => 2,
    'pko' => 1,
    'mwv' => 1,
    'khq' => 1,
    'sga' => 2,
    'eng' => 1,
    'nds' => 1,
    'scs' => 1,
    'kal' => 1,
    'avk' => 2,
    'frs' => 1,
    'lav' => 1,
    'vec' => 1,
    'nbl' => 1,
    'uli' => 1,
    'dtp' => 1,
    'lbw' => 1,
    'ngl' => 1,
    'eus' => 1,
    'lin' => 1,
    'nob' => 1,
    'lut' => 2,
    'chy' => 1,
    'crl' => 2,
    'nnh' => 1,
    'fil' => 1,
    'kik' => 1,
    'tuk' => 1,
    'gub' => 1,
    'sna' => 1,
    'uzb' => 1,
    'kur' => 1,
    'kiu' => 1,
    'gwi' => 1,
    'tog' => 1,
    'rng' => 1,
    'yua' => 1,
    'dyo' => 1,
    'bez' => 1,
    'stq' => 1,
    'ebu' => 1,
    'dum' => 2,
    'kam' => 1,
    'lat' => 2,
    'kln' => 1,
    'trv' => 1,
    'pcm' => 1,
    'bto' => 1,
    'vie' => 1,
    'kjg' => 2,
    'wae' => 1,
    'cho' => 1,
    'luy' => 1,
    'sco' => 1,
    'jam' => 1,
    'spa' => 1,
    'rif' => 1,
    'kde' => 1,
    'bis' => 1,
    'gaa' => 1,
    'ssw' => 1,
    'tzm' => 1,
    'fro' => 2,
    'ses' => 1,
    'abr' => 1,
    'ndo' => 1,
    'krj' => 1,
    'zul' => 1,
    'nso' => 1,
    'srb' => 1,
    'moh' => 1,
    'ria' => 1,
    'dnj' => 1,
    'bci' => 1,
    'ast' => 1,
    'wls' => 1,
    'dje' => 1,
    'fry' => 1,
    'pms' => 1,
    'lmo' => 1,
    'ctd' => 1,
    'lij' => 1,
    'luo' => 1,
    'smo' => 1,
    'bbc' => 1,
    'bvb' => 1,
    'rgn' => 1,
    'del' => 1,
    'rom' => 1,
    'rar' => 1,
    'ife' => 1,
    'nau' => 1,
    'aoz' => 1,
    'bmq' => 1,
    'sad' => 1,
    'tiv' => 1,
    'kpe' => 1,
    'gil' => 1,
    'dav' => 1,
    'ttt' => 1,
    'twq' => 1,
    'mad' => 1,
    'frr' => 1,
    'sli' => 1,
    'hif' => 1,
    'lol' => 1,
    'msa' => 1,
    'lam' => 1,
    'dsb' => 1,
    'aro' => 1,
    'din' => 1,
    'fan' => 1,
    'iku' => 1,
    'ibo' => 1,
    'ind' => 1,
    'sat' => 2,
    'nno' => 1,
    'sas' => 1,
    'vot' => 2,
    'hin' => 2,
    'guz' => 1,
    'pfl' => 1,
    'kac' => 1,
    'hsb' => 1,
    'zza' => 1,
    'cps' => 1,
    'orm' => 1,
    'mas' => 1,
    'oci' => 1,
    'her' => 1,
    'ksf' => 1,
    'akz' => 1,
    'pcd' => 1,
    'bug' => 1,
    'sbp' => 1,
    'isl' => 1,
    'mer' => 1,
    'nyn' => 1,
    'seh' => 1,
    'hat' => 1,
    'sxn' => 1,
    'srp' => 1,
    'sms' => 1,
    'yap' => 1,
    'mos' => 1,
    'tso' => 1,
    'uig' => 2,
    'snk' => 1,
    'jut' => 2,
    'kge' => 1,
    'sus' => 1,
    'kri' => 1,
    'kfo' => 1,
    'slk' => 1,
    'mus' => 1,
    'min' => 1,
    'nld' => 1,
    'jav' => 1,
    'kvr' => 1,
    'xav' => 1,
    'naq' => 1,
    'pol' => 1,
    'ltz' => 1,
    'zha' => 1,
    'mlg' => 1,
    'pam' => 1,
    'kao' => 1,
    'sot' => 1,
    'por' => 1,
    'hmo' => 1,
    'roh' => 1,
    'nap' => 1,
    'ltg' => 1,
    'mwl' => 1,
    'glv' => 1,
    'fon' => 1,
    'kos' => 1,
    'ljp' => 1,
    'ton' => 1,
    'quc' => 1,
    'ilo' => 1,
    'frm' => 2,
    'osc' => 2,
    'mri' => 1,
    'nmg' => 1,
    'ewo' => 1,
    'bku' => 1,
    'ceb' => 1,
    'fit' => 1,
    'kin' => 1,
    'ksb' => 1,
    'gag' => 1,
    'nya' => 1,
    'kut' => 1,
    'lzz' => 1,
    'esu' => 1,
    'crs' => 1,
    'izh' => 1,
    'jmc' => 1,
    'kgp' => 1,
    'kha' => 1,
    'fuv' => 1,
    'smj' => 1,
    'rcf' => 1,
    'ces' => 1,
    'tsn' => 1,
    'kmb' => 1,
    'sdc' => 1,
    'vmf' => 1,
    'see' => 1,
    'vic' => 1,
    'deu' => 1,
    'rup' => 1,
    'cor' => 1,
    'goh' => 2,
    'maf' => 1,
    'nyo' => 1,
    'bkm' => 1,
    'byv' => 1,
    'gur' => 1,
    'nhe' => 1,
    'ina' => 2,
    'saf' => 1,
    'gor' => 1,
    'lug' => 1,
    'gmh' => 2,
    'grb' => 1,
    'nsk' => 2,
    'kkj' => 1,
    'sei' => 1,
    'gsw' => 1,
    'tru' => 1,
    'tgk' => 1,
    'tpi' => 1,
    'tem' => 1,
    'krl' => 1,
    'kck' => 1,
    'ibb' => 1,
    'swe' => 1,
    'dua' => 1,
    'pau' => 1,
    'srr' => 1,
    'bum' => 1,
    'aln' => 1,
    'chk' => 1,
    'mgh' => 1,
    'efi' => 1,
    'tli' => 1,
    'hmn' => 1,
    'mdt' => 1,
    'gla' => 1,
    'hun' => 1,
    'syi' => 1,
    'nhw' => 1,
    'fij' => 1,
    'nxq' => 1,
    'loz' => 1,
    'man' => 1,
    'kcg' => 1,
    'crj' => 2,
    'xho' => 1,
    'bar' => 1,
    'pag' => 1,
    'aze' => 1,
    'rej' => 1,
    'bal' => 2,
    'was' => 1,
    'vun' => 1,
    'dyu' => 1,
    'nde' => 1,
    'kua' => 1,
    'pnt' => 1,
    'lui' => 2,
    'vep' => 1,
    'chp' => 1,
    'bam' => 1,
    'puu' => 1,
    'smn' => 1,
    'ttj' => 1,
    'sun' => 1,
    'pap' => 1,
    'ybb' => 1,
    'fao' => 1,
    'wbp' => 1,
    'bze' => 1,
    'bik' => 1,
    'fvr' => 1,
    'aar' => 1,
    'zun' => 1,
    'afr' => 1,
    'yor' => 1,
    'gba' => 1,
    'tvl' => 1,
    'fud' => 1,
    'arn' => 1,
    'udm' => 2,
    'kaj' => 1,
    'iba' => 1,
    'pro' => 2,
    'mua' => 1,
    'kab' => 1,
    'ter' => 1,
    'osa' => 2,
    'mxc' => 1,
    'rmu' => 1,
    'swg' => 1,
    'grn' => 1,
    'epo' => 1,
    'mwk' => 1,
    'sid' => 1,
    'niu' => 1,
    'rap' => 1,
    'kon' => 1,
    'rtm' => 1,
    'ssy' => 1,
    'mic' => 1,
    'dgr' => 1,
    'lag' => 1,
    'nzi' => 1,
    'bbj' => 1,
    'nor' => 1,
    'car' => 1,
    'dan' => 1,
    'lim' => 1,
    'tbw' => 1,
    'fin' => 1,
    'iii' => 2,
    'frp' => 1,
    'sma' => 1,
    'rug' => 1,
    'bla' => 1
  },
  'Cyrl' => {
    'kir' => 1,
    'dar' => 1,
    'lbe' => 1,
    'uig' => 1,
    'kaz' => 1,
    'kur' => 1,
    'srp' => 1,
    'mrj' => 1,
    'uzb' => 1,
    'sah' => 1,
    'mon' => 1,
    'ttt' => 1,
    'kbd' => 1,
    'tly' => 1,
    'ckt' => 1,
    'lez' => 1,
    'pnt' => 1,
    'dng' => 1,
    'rom' => 2,
    'tuk' => 1,
    'ron' => 2,
    'krc' => 1,
    'mkd' => 1,
    'tat' => 1,
    'koi' => 1,
    'sel' => 2,
    'bul' => 1,
    'crh' => 1,
    'lfn' => 2,
    'rus' => 1,
    'mdf' => 1,
    'kjh' => 1,
    'udm' => 1,
    'xal' => 1,
    'yrk' => 1,
    'tyv' => 1,
    'tgk' => 1,
    'inh' => 1,
    'bua' => 1,
    'chm' => 1,
    'oss' => 1,
    'kom' => 1,
    'sme' => 2,
    'alt' => 1,
    'nog' => 1,
    'chu' => 2,
    'ady' => 1,
    'chv' => 1,
    'ava' => 1,
    'syr' => 1,
    'tab' => 1,
    'tkr' => 1,
    'kaa' => 1,
    'cjs' => 1,
    'abk' => 1,
    'evn' => 1,
    'mns' => 1,
    'kca' => 1,
    'aii' => 1,
    'gld' => 1,
    'aze' => 1,
    'kpy' => 1,
    'rue' => 1,
    'bos' => 1,
    'ukr' => 1,
    'myv' => 1,
    'ude' => 1,
    'abq' => 1,
    'hbs' => 1,
    'bel' => 1,
    'gag' => 2,
    'bak' => 1,
    'che' => 1,
    'kum' => 1
  },
  'Mand' => {
    'myz' => 2
  },
  'Hano' => {
    'hnn' => 2
  },
  'Syrc' => {
    'tru' => 2,
    'syr' => 2,
    'ara' => 2,
    'aii' => 2
  },
  'Cans' => {
    'den' => 2,
    'crj' => 1,
    'crm' => 1,
    'crk' => 1,
    'oji' => 1,
    'chp' => 2,
    'nsk' => 1,
    'cre' => 1,
    'csw' => 1,
    'crl' => 1,
    'iku' => 1
  },
  'Wara' => {
    'hoc' => 2
  },
  'Tibt' => {
    'dzo' => 1,
    'tdg' => 2,
    'tsj' => 1,
    'bft' => 2,
    'bod' => 1,
    'taj' => 2
  },
  'Mymr' => {
    'mya' => 1,
    'kht' => 1,
    'shn' => 1,
    'mnw' => 1
  },
  'Bali' => {
    'ban' => 2
  },
  'Palm' => {
    'arc' => 2
  },
  'Hans' => {
    'wuu' => 1,
    'hak' => 1,
    'zha' => 2,
    'hsn' => 1,
    'lzh' => 2,
    'gan' => 1,
    'yue' => 1,
    'zho' => 1,
    'nan' => 1
  },
  'Talu' => {
    'khb' => 1
  },
  'Kana' => {
    'ryu' => 1,
    'ain' => 2
  },
  'Geor' => {
    'lzz' => 1,
    'xmf' => 1,
    'kat' => 1
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Batk' => {
    'bbc' => 2
  },
  'Phlp' => {
    'pal' => 2
  },
  'Armn' => {
    'hye' => 1
  },
  'Cprt' => {
    'grc' => 2
  },
  'Phag' => {
    'zho' => 2,
    'mon' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Thai' => {
    'tts' => 1,
    'kdt' => 1,
    'lcp' => 1,
    'pli' => 2,
    'sou' => 1,
    'lwl' => 1,
    'kxm' => 1,
    'tha' => 1
  },
  'Orya' => {
    'sat' => 2,
    'ori' => 1
  },
  'Tavt' => {
    'blt' => 1
  },
  'Knda' => {
    'kan' => 1,
    'tcy' => 1
  },
  'Limb' => {
    'lif' => 1
  },
  'Vaii' => {
    'vai' => 1
  },
  'Thaa' => {
    'div' => 1
  },
  'Ogam' => {
    'sga' => 2
  },
  'Ethi' => {
    'gez' => 2,
    'byn' => 1,
    'orm' => 2,
    'tig' => 1,
    'wal' => 1,
    'tir' => 1,
    'amh' => 1
  },
  'Bugi' => {
    'bug' => 2,
    'mdr' => 2,
    'mak' => 2
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Buhd' => {
    'bku' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Orkh' => {
    'otk' => 2
  },
  'Nbat' => {
    'arc' => 2
  },
  'Xsux' => {
    'hit' => 2,
    'akk' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Mlym' => {
    'mal' => 1
  },
  'Copt' => {
    'cop' => 2
  },
  'Mtei' => {
    'mni' => 2
  },
  'Lydi' => {
    'xld' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Prti' => {
    'xpr' => 2
  },
  'Runr' => {
    'non' => 2,
    'deu' => 2
  },
  'Hant' => {
    'yue' => 1,
    'zho' => 1
  },
  'Saur' => {
    'saz' => 1
  },
  'Lina' => {
    'lab' => 2
  },
  'Grek' => {
    'pnt' => 1,
    'bgx' => 1,
    'cop' => 2,
    'ell' => 1,
    'grc' => 2,
    'tsd' => 1
  },
  'Cher' => {
    'chr' => 1
  },
  'Taml' => {
    'bfq' => 1,
    'tam' => 1
  },
  'Ital' => {
    'xum' => 2,
    'osc' => 2,
    'ett' => 2
  },
  'Mong' => {
    'mnc' => 2,
    'mon' => 2
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Olck' => {
    'sat' => 1
  },
  'Mend' => {
    'men' => 2
  },
  'Java' => {
    'jav' => 2
  },
  'Bamu' => {
    'bax' => 1
  },
  'Cham' => {
    'cjm' => 1,
    'cja' => 2
  },
  'Osge' => {
    'osa' => 1
  },
  'Tale' => {
    'tdd' => 1
  },
  'Hani' => {
    'vie' => 2
  },
  'Ugar' => {
    'uga' => 2
  },
  'Sinh' => {
    'san' => 2,
    'pli' => 2,
    'sin' => 1
  },
  'Beng' => {
    'syl' => 1,
    'unx' => 1,
    'unr' => 1,
    'sat' => 2,
    'lus' => 1,
    'mni' => 1,
    'bpy' => 1,
    'grt' => 1,
    'ben' => 1,
    'asm' => 1,
    'rkt' => 1,
    'ccp' => 1,
    'kha' => 2
  },
  'Hebr' => {
    'yid' => 1,
    'sam' => 2,
    'jpr' => 1,
    'lad' => 1,
    'jrb' => 1,
    'heb' => 1
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Guru' => {
    'pan' => 1
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Bopo' => {
    'zho' => 2
  },
  'Osma' => {
    'som' => 2
  },
  'Modi' => {
    'mar' => 2
  },
  'Sylo' => {
    'syl' => 2
  },
  'Dupl' => {
    'fra' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Deva' => {
    'bap' => 1,
    'rjs' => 1,
    'kas' => 1,
    'mag' => 1,
    'tkt' => 1,
    'bho' => 1,
    'hif' => 1,
    'mgp' => 1,
    'gvr' => 1,
    'brx' => 1,
    'bfy' => 1,
    'taj' => 1,
    'mtr' => 1,
    'sck' => 1,
    'snd' => 1,
    'kru' => 1,
    'kok' => 1,
    'bgc' => 1,
    'mai' => 1,
    'bra' => 1,
    'kfy' => 1,
    'xnr' => 1,
    'xsr' => 1,
    'lif' => 1,
    'hoc' => 1,
    'mar' => 1,
    'khn' => 1,
    'srx' => 1,
    'thr' => 1,
    'thl' => 1,
    'dty' => 1,
    'unx' => 1,
    'raj' => 1,
    'awa' => 1,
    'hne' => 1,
    'wbr' => 1,
    'swv' => 1,
    'jml' => 1,
    'hoj' => 1,
    'doi' => 1,
    'kfr' => 1,
    'mrd' => 1,
    'new' => 1,
    'mwr' => 1,
    'unr' => 1,
    'tdg' => 1,
    'bjj' => 1,
    'thq' => 1,
    'tdh' => 1,
    'pli' => 2,
    'sat' => 2,
    'hin' => 1,
    'gbm' => 1,
    'bhb' => 1,
    'san' => 2,
    'noe' => 1,
    'gom' => 1,
    'gon' => 1,
    'wtm' => 1,
    'nep' => 1,
    'bhi' => 1,
    'anp' => 1,
    'btv' => 1
  },
  'Telu' => {
    'lmn' => 1,
    'gon' => 1,
    'wbq' => 1,
    'tel' => 1
  }
};
$DefaultScript = {
  'frs' => 'Latn',
  'kxp' => 'Arab',
  'lav' => 'Latn',
  'gbm' => 'Deva',
  'vec' => 'Latn',
  'ady' => 'Cyrl',
  'nep' => 'Deva',
  'bax' => 'Bamu',
  'scs' => 'Latn',
  'kal' => 'Latn',
  'kom' => 'Cyrl',
  'kfr' => 'Deva',
  'new' => 'Deva',
  'cjs' => 'Cyrl',
  'khq' => 'Latn',
  'mwv' => 'Latn',
  'nds' => 'Latn',
  'eng' => 'Latn',
  'tdh' => 'Deva',
  'crm' => 'Cans',
  'myv' => 'Cyrl',
  'nob' => 'Latn',
  'swv' => 'Deva',
  'kum' => 'Cyrl',
  'lus' => 'Beng',
  'lbw' => 'Latn',
  'srx' => 'Deva',
  'ngl' => 'Latn',
  'eus' => 'Latn',
  'lin' => 'Latn',
  'nbl' => 'Latn',
  'nan' => 'Hans',
  'uli' => 'Latn',
  'dtp' => 'Latn',
  'ace' => 'Latn',
  'sah' => 'Cyrl',
  'mal' => 'Mlym',
  'mar' => 'Deva',
  'lbe' => 'Cyrl',
  'lwl' => 'Thai',
  'ban' => 'Latn',
  'lao' => 'Laoo',
  'inh' => 'Cyrl',
  'hnn' => 'Latn',
  'xal' => 'Cyrl',
  'pko' => 'Latn',
  'ndc' => 'Latn',
  'srn' => 'Latn',
  'brh' => 'Arab',
  'aka' => 'Latn',
  'rmo' => 'Latn',
  'khw' => 'Arab',
  'njo' => 'Latn',
  'frc' => 'Latn',
  'cic' => 'Latn',
  'yrl' => 'Latn',
  'bss' => 'Latn',
  'bew' => 'Latn',
  'mvy' => 'Arab',
  'som' => 'Latn',
  'mah' => 'Latn',
  'lkt' => 'Latn',
  'bho' => 'Deva',
  'fuq' => 'Latn',
  'nso' => 'Latn',
  'chv' => 'Cyrl',
  'srb' => 'Latn',
  'dnj' => 'Latn',
  'ria' => 'Latn',
  'moh' => 'Latn',
  'wtm' => 'Deva',
  'abr' => 'Latn',
  'krj' => 'Latn',
  'btv' => 'Deva',
  'ndo' => 'Latn',
  'zul' => 'Latn',
  'gaa' => 'Latn',
  'kde' => 'Latn',
  'wuu' => 'Hans',
  'bis' => 'Latn',
  'ses' => 'Latn',
  'ssw' => 'Latn',
  'luy' => 'Latn',
  'jam' => 'Latn',
  'jrb' => 'Hebr',
  'sco' => 'Latn',
  'spa' => 'Latn',
  'pus' => 'Arab',
  'rkt' => 'Beng',
  'luo' => 'Latn',
  'lij' => 'Latn',
  'fry' => 'Latn',
  'guj' => 'Gujr',
  'dje' => 'Latn',
  'pms' => 'Latn',
  'jml' => 'Deva',
  'lmo' => 'Latn',
  'ctd' => 'Latn',
  'thr' => 'Deva',
  'ckb' => 'Arab',
  'thl' => 'Deva',
  'lad' => 'Hebr',
  'bci' => 'Latn',
  'ast' => 'Latn',
  'wls' => 'Latn',
  'kiu' => 'Latn',
  'gwi' => 'Latn',
  'rng' => 'Latn',
  'yua' => 'Latn',
  'tog' => 'Latn',
  'kmr' => 'Latn',
  'dyo' => 'Latn',
  'sna' => 'Latn',
  'mrj' => 'Cyrl',
  'tir' => 'Ethi',
  'dcc' => 'Arab',
  'dar' => 'Cyrl',
  'eky' => 'Kali',
  'fil' => 'Latn',
  'nnh' => 'Latn',
  'gub' => 'Latn',
  'kik' => 'Latn',
  'chy' => 'Latn',
  'crl' => 'Cans',
  'vie' => 'Latn',
  'kjg' => 'Laoo',
  'yid' => 'Hebr',
  'cho' => 'Latn',
  'wae' => 'Latn',
  'crh' => 'Cyrl',
  'rus' => 'Cyrl',
  'jpn' => 'Jpan',
  'kln' => 'Latn',
  'trv' => 'Latn',
  'pcm' => 'Latn',
  'bto' => 'Latn',
  'skr' => 'Arab',
  'hnj' => 'Laoo',
  'kor' => 'Kore',
  'kam' => 'Latn',
  'stq' => 'Latn',
  'bua' => 'Cyrl',
  'bez' => 'Latn',
  'ebu' => 'Latn',
  'rmt' => 'Arab',
  'gan' => 'Hans',
  'gos' => 'Latn',
  'kau' => 'Latn',
  'bhb' => 'Deva',
  'ikt' => 'Latn',
  'glk' => 'Arab',
  'bfd' => 'Latn',
  'scn' => 'Latn',
  'eka' => 'Latn',
  'maz' => 'Latn',
  'sme' => 'Latn',
  'moe' => 'Latn',
  'ksh' => 'Latn',
  'kca' => 'Cyrl',
  'mrd' => 'Deva',
  'ell' => 'Grek',
  'tsg' => 'Latn',
  'bjj' => 'Deva',
  'tdg' => 'Deva',
  'zmi' => 'Latn',
  'thq' => 'Deva',
  'dtm' => 'Latn',
  'vro' => 'Latn',
  'ipk' => 'Latn',
  'szl' => 'Latn',
  'cha' => 'Latn',
  'abq' => 'Cyrl',
  'hai' => 'Latn',
  'den' => 'Latn',
  'kxm' => 'Thai',
  'srd' => 'Latn',
  'hnd' => 'Arab',
  'kpy' => 'Cyrl',
  'glg' => 'Latn',
  'agq' => 'Latn',
  'lit' => 'Latn',
  'sqi' => 'Latn',
  'arq' => 'Arab',
  'tum' => 'Latn',
  'lis' => 'Lisu',
  'cos' => 'Latn',
  'sly' => 'Latn',
  'pdc' => 'Latn',
  'lun' => 'Latn',
  'swb' => 'Arab',
  'atj' => 'Latn',
  'tah' => 'Latn',
  'rob' => 'Latn',
  'que' => 'Latn',
  'ext' => 'Latn',
  'saz' => 'Saur',
  'lmn' => 'Telu',
  'arp' => 'Latn',
  'ckt' => 'Cyrl',
  'bem' => 'Latn',
  'kbd' => 'Cyrl',
  'xsr' => 'Deva',
  'guc' => 'Latn',
  'sag' => 'Latn',
  'khm' => 'Khmr',
  'mak' => 'Latn',
  'bas' => 'Latn',
  'gay' => 'Latn',
  'bft' => 'Arab',
  'mdh' => 'Latn',
  'wal' => 'Ethi',
  'lcp' => 'Thai',
  'nym' => 'Latn',
  'war' => 'Latn',
  'hrv' => 'Latn',
  'lua' => 'Latn',
  'lez' => 'Cyrl',
  'pdt' => 'Latn',
  'yrk' => 'Cyrl',
  'laj' => 'Latn',
  'tyv' => 'Cyrl',
  'cay' => 'Latn',
  'gvr' => 'Deva',
  'umb' => 'Latn',
  'mtr' => 'Deva',
  'mdr' => 'Latn',
  'koi' => 'Cyrl',
  'bzx' => 'Latn',
  'sdh' => 'Arab',
  'slv' => 'Latn',
  'krc' => 'Cyrl',
  'nij' => 'Latn',
  'fra' => 'Latn',
  'teo' => 'Latn',
  'sgs' => 'Latn',
  'bqv' => 'Latn',
  'ven' => 'Latn',
  'mag' => 'Deva',
  'nqo' => 'Nkoo',
  'cja' => 'Arab',
  'hil' => 'Latn',
  'zag' => 'Latn',
  'nch' => 'Latn',
  'vls' => 'Latn',
  'haw' => 'Latn',
  'cad' => 'Latn',
  'bjn' => 'Latn',
  'myx' => 'Latn',
  'nod' => 'Lana',
  'kea' => 'Latn',
  'anp' => 'Deva',
  'sou' => 'Thai',
  'gcr' => 'Latn',
  'cch' => 'Latn',
  'bin' => 'Latn',
  'mns' => 'Cyrl',
  'rwk' => 'Latn',
  'abk' => 'Cyrl',
  'nia' => 'Latn',
  'vmw' => 'Latn',
  'zap' => 'Latn',
  'yav' => 'Latn',
  'tkl' => 'Latn',
  'pon' => 'Latn',
  'rmf' => 'Latn',
  'hop' => 'Latn',
  'suk' => 'Latn',
  'wol' => 'Latn',
  'gle' => 'Latn',
  'hup' => 'Latn',
  'men' => 'Latn',
  'hak' => 'Hans',
  'cym' => 'Latn',
  'arg' => 'Latn',
  'doi' => 'Arab',
  'mls' => 'Latn',
  'xog' => 'Latn',
  'rof' => 'Latn',
  'mlt' => 'Latn',
  'qug' => 'Latn',
  'swa' => 'Latn',
  'bel' => 'Cyrl',
  'wln' => 'Latn',
  'tsi' => 'Latn',
  'raj' => 'Deva',
  'heb' => 'Hebr',
  'mya' => 'Mymr',
  'gbz' => 'Arab',
  'ryu' => 'Kana',
  'ada' => 'Latn',
  'lep' => 'Lepc',
  'crk' => 'Cans',
  'est' => 'Latn',
  'ita' => 'Latn',
  'mro' => 'Latn',
  'nav' => 'Latn',
  'kvx' => 'Arab',
  'asa' => 'Latn',
  'ach' => 'Latn',
  'tur' => 'Latn',
  'zea' => 'Latn',
  'amo' => 'Latn',
  'saq' => 'Latn',
  'ful' => 'Latn',
  'ron' => 'Latn',
  'dak' => 'Latn',
  'ale' => 'Latn',
  'tcy' => 'Knda',
  'fur' => 'Latn',
  'mai' => 'Deva',
  'cat' => 'Latn',
  'mgo' => 'Latn',
  'arz' => 'Arab',
  'lub' => 'Latn',
  'buc' => 'Latn',
  'bfy' => 'Deva',
  'bod' => 'Tibt',
  'oji' => 'Cans',
  'kjh' => 'Cyrl',
  'mgy' => 'Latn',
  'aym' => 'Latn',
  'ewe' => 'Latn',
  'run' => 'Latn',
  'mfe' => 'Latn',
  'kok' => 'Deva',
  'sef' => 'Latn',
  'hno' => 'Arab',
  'rjs' => 'Deva',
  'cgg' => 'Latn',
  'ffm' => 'Latn',
  'tmh' => 'Latn',
  'tam' => 'Taml',
  'bre' => 'Latn',
  'tig' => 'Ethi',
  'nus' => 'Latn',
  'tet' => 'Latn',
  'yao' => 'Latn',
  'egl' => 'Latn',
  'jgo' => 'Latn',
  'haz' => 'Arab',
  'hun' => 'Latn',
  'syi' => 'Latn',
  'mgh' => 'Latn',
  'zgh' => 'Tfng',
  'tli' => 'Latn',
  'bhi' => 'Deva',
  'hmn' => 'Latn',
  'efi' => 'Latn',
  'mdt' => 'Latn',
  'amh' => 'Ethi',
  'luz' => 'Arab',
  'gla' => 'Latn',
  'pau' => 'Latn',
  'bum' => 'Latn',
  'srr' => 'Latn',
  'chk' => 'Latn',
  'aln' => 'Latn',
  'evn' => 'Cyrl',
  'ibb' => 'Latn',
  'swe' => 'Latn',
  'kck' => 'Latn',
  'kaa' => 'Cyrl',
  'dua' => 'Latn',
  'bgn' => 'Arab',
  'vun' => 'Latn',
  'was' => 'Latn',
  'dyu' => 'Latn',
  'bar' => 'Latn',
  'rue' => 'Cyrl',
  'pag' => 'Latn',
  'rej' => 'Latn',
  'bal' => 'Arab',
  'loz' => 'Latn',
  'kcg' => 'Latn',
  'crj' => 'Cans',
  'dty' => 'Deva',
  'xho' => 'Latn',
  'nhw' => 'Latn',
  'fij' => 'Latn',
  'nxq' => 'Latn',
  'prd' => 'Arab',
  'mfa' => 'Arab',
  'byv' => 'Latn',
  'gjk' => 'Arab',
  'bkm' => 'Latn',
  'dzo' => 'Tibt',
  'gur' => 'Latn',
  'nhe' => 'Latn',
  'rup' => 'Latn',
  'kdt' => 'Thai',
  'cor' => 'Latn',
  'maf' => 'Latn',
  'nyo' => 'Latn',
  'ori' => 'Orya',
  'gju' => 'Arab',
  'kmb' => 'Latn',
  'sdc' => 'Latn',
  'vmf' => 'Latn',
  'vic' => 'Latn',
  'see' => 'Latn',
  'bra' => 'Deva',
  'deu' => 'Latn',
  'smj' => 'Latn',
  'fuv' => 'Latn',
  'rcf' => 'Latn',
  'csw' => 'Cans',
  'ces' => 'Latn',
  'tsn' => 'Latn',
  'tpi' => 'Latn',
  'urd' => 'Arab',
  'brx' => 'Deva',
  'wni' => 'Arab',
  'tem' => 'Latn',
  'krl' => 'Latn',
  'sck' => 'Deva',
  'fas' => 'Arab',
  'gsw' => 'Latn',
  'tru' => 'Latn',
  'tat' => 'Cyrl',
  'kkj' => 'Latn',
  'nsk' => 'Cans',
  'kan' => 'Knda',
  'sei' => 'Latn',
  'saf' => 'Latn',
  'gor' => 'Latn',
  'bgx' => 'Grek',
  'lug' => 'Latn',
  'grb' => 'Latn',
  'lki' => 'Arab',
  'ssy' => 'Latn',
  'rtm' => 'Latn',
  'mic' => 'Latn',
  'div' => 'Thaa',
  'gom' => 'Deva',
  'sid' => 'Latn',
  'mwk' => 'Latn',
  'niu' => 'Latn',
  'wbq' => 'Telu',
  'ara' => 'Arab',
  'kon' => 'Latn',
  'rap' => 'Latn',
  'mxc' => 'Latn',
  'swg' => 'Latn',
  'grn' => 'Latn',
  'rmu' => 'Latn',
  'jpr' => 'Hebr',
  'epo' => 'Latn',
  'tel' => 'Telu',
  'iba' => 'Latn',
  'mua' => 'Latn',
  'kab' => 'Latn',
  'ter' => 'Latn',
  'osa' => 'Osge',
  'frp' => 'Latn',
  'sma' => 'Latn',
  'rug' => 'Latn',
  'tha' => 'Thai',
  'bla' => 'Latn',
  'iii' => 'Yiii',
  'fin' => 'Latn',
  'hoj' => 'Deva',
  'xmf' => 'Geor',
  'aii' => 'Cyrl',
  'dan' => 'Latn',
  'car' => 'Latn',
  'che' => 'Cyrl',
  'tbw' => 'Latn',
  'lim' => 'Latn',
  'lag' => 'Latn',
  'dgr' => 'Latn',
  'nzi' => 'Latn',
  'nor' => 'Latn',
  'bbj' => 'Latn',
  'fia' => 'Arab',
  'sun' => 'Latn',
  'xnr' => 'Deva',
  'pap' => 'Latn',
  'mon' => 'Cyrl',
  'smn' => 'Latn',
  'ttj' => 'Latn',
  'tsj' => 'Tibt',
  'vep' => 'Latn',
  'chp' => 'Latn',
  'kht' => 'Mymr',
  'puu' => 'Latn',
  'nde' => 'Latn',
  'kua' => 'Latn',
  'fud' => 'Latn',
  'kyu' => 'Kali',
  'arn' => 'Latn',
  'kaj' => 'Latn',
  'udm' => 'Cyrl',
  'hye' => 'Armn',
  'bul' => 'Cyrl',
  'afr' => 'Latn',
  'lrc' => 'Arab',
  'yor' => 'Latn',
  'tvl' => 'Latn',
  'gba' => 'Latn',
  'bik' => 'Latn',
  'bze' => 'Latn',
  'aar' => 'Latn',
  'fvr' => 'Latn',
  'zun' => 'Latn',
  'ybb' => 'Latn',
  'tkt' => 'Deva',
  'fao' => 'Latn',
  'wbp' => 'Latn',
  'sas' => 'Latn',
  'guz' => 'Latn',
  'pfl' => 'Latn',
  'hin' => 'Deva',
  'noe' => 'Deva',
  'kac' => 'Latn',
  'ava' => 'Cyrl',
  'hsb' => 'Latn',
  'bpy' => 'Beng',
  'chr' => 'Cher',
  'alt' => 'Cyrl',
  'nno' => 'Latn',
  'tsd' => 'Grek',
  'tdd' => 'Tale',
  'sat' => 'Olck',
  'ksf' => 'Latn',
  'akz' => 'Latn',
  'asm' => 'Beng',
  'wbr' => 'Deva',
  'khb' => 'Talu',
  'pcd' => 'Latn',
  'gld' => 'Cyrl',
  'her' => 'Latn',
  'mnw' => 'Mymr',
  'mas' => 'Latn',
  'orm' => 'Latn',
  'bak' => 'Cyrl',
  'oci' => 'Latn',
  'cps' => 'Latn',
  'zza' => 'Latn',
  'awa' => 'Deva',
  'tiv' => 'Latn',
  'kpe' => 'Latn',
  'gil' => 'Latn',
  'hmd' => 'Plrd',
  'dav' => 'Latn',
  'nau' => 'Latn',
  'ary' => 'Arab',
  'bmq' => 'Latn',
  'sad' => 'Latn',
  'hoc' => 'Deva',
  'aoz' => 'Latn',
  'rom' => 'Latn',
  'bgc' => 'Deva',
  'mzn' => 'Arab',
  'bej' => 'Arab',
  'rar' => 'Latn',
  'ife' => 'Latn',
  'tts' => 'Thai',
  'smo' => 'Latn',
  'dng' => 'Cyrl',
  'bbc' => 'Latn',
  'del' => 'Latn',
  'rgn' => 'Latn',
  'bvb' => 'Latn',
  'bqi' => 'Arab',
  'ibo' => 'Latn',
  'ind' => 'Latn',
  'mdf' => 'Cyrl',
  'kru' => 'Deva',
  'fan' => 'Latn',
  'kat' => 'Geor',
  'lol' => 'Latn',
  'lam' => 'Latn',
  'mni' => 'Beng',
  'dsb' => 'Latn',
  'din' => 'Latn',
  'aro' => 'Latn',
  'twq' => 'Latn',
  'frr' => 'Latn',
  'mad' => 'Latn',
  'sli' => 'Latn',
  'ilo' => 'Latn',
  'zdj' => 'Arab',
  'nog' => 'Cyrl',
  'ljp' => 'Latn',
  'kos' => 'Latn',
  'grt' => 'Beng',
  'ton' => 'Latn',
  'quc' => 'Latn',
  'mwl' => 'Latn',
  'ltg' => 'Latn',
  'cjm' => 'Cham',
  'mwr' => 'Deva',
  'glv' => 'Latn',
  'fon' => 'Latn',
  'syl' => 'Beng',
  'hmo' => 'Latn',
  'bfq' => 'Taml',
  'nap' => 'Latn',
  'tab' => 'Cyrl',
  'roh' => 'Latn',
  'ude' => 'Cyrl',
  'crs' => 'Latn',
  'jmc' => 'Latn',
  'izh' => 'Latn',
  'kgp' => 'Latn',
  'hne' => 'Deva',
  'kha' => 'Latn',
  'ukr' => 'Cyrl',
  'kut' => 'Latn',
  'esu' => 'Latn',
  'bku' => 'Latn',
  'kin' => 'Latn',
  'fit' => 'Latn',
  'byn' => 'Ethi',
  'ceb' => 'Latn',
  'nya' => 'Latn',
  'gag' => 'Latn',
  'ksb' => 'Latn',
  'mri' => 'Latn',
  'shn' => 'Mymr',
  'nmg' => 'Latn',
  'ewo' => 'Latn',
  'lah' => 'Arab',
  'sin' => 'Sinh',
  'kfy' => 'Deva',
  'snk' => 'Latn',
  'no' => 'Latn',
  'ben' => 'Beng',
  'kge' => 'Latn',
  'sus' => 'Latn',
  'tso' => 'Latn',
  'khn' => 'Deva',
  'mos' => 'Latn',
  'yap' => 'Latn',
  'sms' => 'Latn',
  'sxn' => 'Latn',
  'blt' => 'Tavt',
  'bug' => 'Latn',
  'sbp' => 'Latn',
  'mer' => 'Latn',
  'isl' => 'Latn',
  'nyn' => 'Latn',
  'hat' => 'Latn',
  'seh' => 'Latn',
  'ltz' => 'Latn',
  'pol' => 'Latn',
  'ars' => 'Arab',
  'mgp' => 'Deva',
  'pam' => 'Latn',
  'mlg' => 'Latn',
  'zha' => 'Latn',
  'sot' => 'Latn',
  'taj' => 'Deva',
  'kao' => 'Latn',
  'por' => 'Latn',
  'nld' => 'Latn',
  'kvr' => 'Latn',
  'jav' => 'Latn',
  'hsn' => 'Hans',
  'naq' => 'Latn',
  'xav' => 'Latn',
  'mkd' => 'Cyrl',
  'bap' => 'Deva',
  'oss' => 'Cyrl',
  'aeb' => 'Arab',
  'mus' => 'Latn',
  'chm' => 'Cyrl',
  'min' => 'Latn',
  'kri' => 'Latn',
  'slk' => 'Latn',
  'kfo' => 'Latn'
};
$DefaultTerritory = {
  'nl' => 'NL',
  'wol' => 'SN',
  'suk' => 'TZ',
  'gle' => 'IE',
  'hak' => 'CN',
  'men' => 'SL',
  'mk' => 'MK',
  'cym' => 'GB',
  'bos' => 'BA',
  'fi' => 'FI',
  'arg' => 'ES',
  'rof' => 'TZ',
  'xog' => 'UG',
  'doi' => 'IN',
  'ti' => 'ET',
  'ku' => 'TR',
  'da' => 'DK',
  'mlt' => 'MT',
  'hau_Arab' => 'NG',
  'hau' => 'NG',
  'swa' => 'TZ',
  'bel' => 'BY',
  'heb' => 'IL',
  'raj' => 'IN',
  'wln' => 'BE',
  'km' => 'KH',
  'mya' => 'MM',
  'mon_Mong' => 'CN',
  'bos_Cyrl' => 'BA',
  'cad' => 'US',
  'bjn' => 'ID',
  'kea' => 'CV',
  'myx' => 'UG',
  'nod' => 'TH',
  'bs_Latn' => 'BA',
  'cch' => 'NG',
  'gcr' => 'GF',
  'ko' => 'KR',
  'sou' => 'TH',
  'bin' => 'NG',
  'rwk' => 'TZ',
  'sk' => 'SK',
  'abk' => 'GE',
  'vmw' => 'MZ',
  'unr' => 'IN',
  'yav' => 'CM',
  'tkl' => 'TK',
  'pon' => 'FM',
  'nn' => 'NO',
  'buc' => 'YT',
  'kk' => 'KZ',
  'ken' => 'CM',
  'bod' => 'CN',
  'aym' => 'BO',
  'ewe' => 'GH',
  'snd_Arab' => 'PK',
  'mfe' => 'MU',
  'run' => 'BI',
  'kok' => 'IN',
  'sef' => 'CI',
  'rw' => 'RW',
  'cgg' => 'UG',
  'bn' => 'BD',
  'hno' => 'PK',
  'ffm' => 'ML',
  'tam' => 'IN',
  'tmh' => 'NE',
  'os' => 'GE',
  'zu' => 'ZA',
  'tig' => 'ER',
  'nus' => 'SS',
  'bre' => 'FR',
  'tet' => 'TL',
  'haz' => 'AF',
  'so' => 'SO',
  'qu' => 'PE',
  'jgo' => 'CM',
  'ig' => 'NG',
  'est' => 'EE',
  'ha' => 'NG',
  'ita' => 'IT',
  'th' => 'TH',
  'tur' => 'TR',
  'ach' => 'UG',
  'kir' => 'KG',
  'asa' => 'TZ',
  'saq' => 'KE',
  'ron' => 'RO',
  'mai' => 'IN',
  'tcy' => 'IN',
  'sq' => 'AL',
  'fur' => 'IT',
  'mni_Mtei' => 'IN',
  'mgo' => 'CM',
  'cat' => 'ES',
  'ff_Adlm' => 'GN',
  'aze_Latn' => 'AZ',
  'arz' => 'EG',
  'lub' => 'CD',
  'bg' => 'BG',
  'kxm' => 'TH',
  'srd' => 'IT',
  'an' => 'ES',
  'mn_Mong' => 'CN',
  'ha_Arab' => 'NG',
  'glg' => 'ES',
  'lit' => 'LT',
  'agq' => 'CM',
  'arq' => 'DZ',
  'sqi' => 'AL',
  'cos' => 'FR',
  'tum' => 'MW',
  'sun_Latn' => 'ID',
  'swb' => 'YT',
  'tah' => 'PF',
  'que' => 'PE',
  'lmn' => 'IN',
  'br' => 'FR',
  'hu' => 'HU',
  'glk' => 'IR',
  'bhb' => 'IN',
  'ikt' => 'CA',
  'sa' => 'IN',
  'bam_Nkoo' => 'ML',
  'scn' => 'IT',
  'sme' => 'NO',
  'csb' => 'PL',
  'ksh' => 'DE',
  'lv' => 'LV',
  'ell' => 'GR',
  'tsg' => 'PH',
  'bjj' => 'IN',
  'ja' => 'JP',
  'szl' => 'PL',
  'az_Latn' => 'AZ',
  'cha' => 'GU',
  'laj' => 'UG',
  'tyv' => 'RU',
  'pan_Arab' => 'PK',
  'ee' => 'GH',
  'gl' => 'ES',
  'mtr' => 'IN',
  'umb' => 'AO',
  'koi' => 'RU',
  'sdh' => 'IR',
  'zh_Hant' => 'TW',
  'fra' => 'FR',
  'krc' => 'RU',
  'slv' => 'SI',
  'teo' => 'UG',
  'ven' => 'ZA',
  'ka' => 'GE',
  'nqo' => 'GN',
  'hil' => 'PH',
  'mag' => 'IN',
  'vls' => 'BE',
  'haw' => 'US',
  'nb' => 'NO',
  'ful_Adlm' => 'GN',
  'bem' => 'ZM',
  'kbd' => 'RU',
  'khm' => 'KH',
  'sag' => 'CF',
  'kaz' => 'KZ',
  'bas' => 'CM',
  'mak' => 'ID',
  'nr' => 'ZA',
  'mdh' => 'PH',
  'gn' => 'PY',
  'wal' => 'ET',
  'war' => 'PH',
  'tt' => 'RU',
  'hrv' => 'HR',
  'nym' => 'TZ',
  'ts' => 'ZA',
  'lua' => 'CD',
  'lez' => 'RU',
  'pus' => 'AF',
  'xh' => 'ZA',
  'luo' => 'KE',
  'guj' => 'IN',
  'dje' => 'NE',
  'fry' => 'NL',
  'ne' => 'NP',
  'knf' => 'SN',
  'ki' => 'KE',
  'ckb' => 'IQ',
  'ks_Arab' => 'IN',
  'ast' => 'ES',
  'bci' => 'CI',
  'iu_Latn' => 'CA',
  'wls' => 'WF',
  'nso' => 'ZA',
  'moh' => 'CA',
  'dnj' => 'CI',
  'snd_Deva' => 'IN',
  'chv' => 'RU',
  'lg' => 'UG',
  'abr' => 'GH',
  'wtm' => 'IN',
  'lb' => 'LU',
  'rn' => 'BI',
  'ndo' => 'NA',
  'to' => 'TO',
  'zul' => 'ZA',
  'bjt' => 'SN',
  'rif' => 'MA',
  'shi_Tfng' => 'MA',
  'bis' => 'VU',
  'wuu' => 'CN',
  'kde' => 'TZ',
  'gaa' => 'GH',
  'fo' => 'FO',
  'tzm' => 'MA',
  'ssw' => 'ZA',
  'ses' => 'ML',
  'luy' => 'KE',
  'sco' => 'GB',
  'iku_Latn' => 'CA',
  'jam' => 'JM',
  'sr_Latn' => 'RS',
  'spa' => 'ES',
  'vie' => 'VN',
  'uzb_Cyrl' => 'UZ',
  'tk' => 'TM',
  'wae' => 'CH',
  'rus' => 'RU',
  'lat' => 'VA',
  'jpn' => 'JP',
  'kln' => 'KE',
  'skr' => 'PK',
  'trv' => 'TW',
  'pcm' => 'NG',
  'ms_Arab' => 'MY',
  'kor' => 'KR',
  'mi' => 'NZ',
  'kam' => 'KE',
  'hin_Latn' => 'IN',
  'bez' => 'TZ',
  'pl' => 'PL',
  'ebu' => 'KE',
  'gan' => 'CN',
  'rmt' => 'IR',
  'si' => 'LK',
  'be' => 'BY',
  'pa_Guru' => 'IN',
  'dyo' => 'SN',
  'sna' => 'ZW',
  'sd_Arab' => 'PK',
  'uzb_Arab' => 'AF',
  'kur' => 'TR',
  'dcc' => 'IN',
  'tir' => 'ET',
  'nnh' => 'CM',
  'dz' => 'BT',
  'fil' => 'PH',
  'kik' => 'KE',
  'tuk' => 'TM',
  'uz_Latn' => 'UZ',
  'wo' => 'SN',
  'ny' => 'MW',
  'snf' => 'SN',
  'wa' => 'BE',
  'myv' => 'RU',
  'vi' => 'VN',
  'ur' => 'PK',
  'cy' => 'GB',
  'nob' => 'NO',
  'st' => 'ZA',
  'swv' => 'IN',
  'ss' => 'ZA',
  'cv' => 'RU',
  'kum' => 'RU',
  'ngl' => 'MZ',
  'ug' => 'CN',
  'lin' => 'CD',
  'eus' => 'ES',
  'nan' => 'CN',
  'nbl' => 'ZA',
  'srp_Latn' => 'RS',
  'lav' => 'LV',
  'hi' => 'IN',
  'gbm' => 'IN',
  'ady' => 'RU',
  'gon' => 'IN',
  'nep' => 'NP',
  'mey' => 'SN',
  'bsc' => 'SN',
  'kal' => 'GL',
  'kom' => 'RU',
  'om' => 'ET',
  'mt' => 'MT',
  'khq' => 'ML',
  'eng' => 'US',
  'ms' => 'MY',
  'nds' => 'DE',
  'gv' => 'IM',
  'inh' => 'RU',
  'lao' => 'LA',
  'ccp' => 'BD',
  'ndc' => 'MZ',
  'el' => 'GR',
  'srn' => 'SR',
  'fa' => 'IR',
  'aka' => 'GH',
  'brh' => 'PK',
  'ta' => 'IN',
  'cic' => 'US',
  'bew' => 'ID',
  'bss' => 'CM',
  'fuq' => 'NE',
  'mah' => 'MH',
  'som' => 'SO',
  'lkt' => 'US',
  'ace' => 'ID',
  'sah' => 'RU',
  'mal' => 'IN',
  'mar' => 'IN',
  'lbe' => 'RU',
  'gez' => 'ET',
  'en' => 'US',
  'ln' => 'CD',
  'ban' => 'ID',
  'ce' => 'RU',
  'shi' => 'MA',
  'crs' => 'SC',
  'sn' => 'ZW',
  'jmc' => 'TZ',
  'en_Dsrt' => 'US',
  'hne' => 'IN',
  'kha' => 'IN',
  'vai_Vaii' => 'LR',
  'ukr' => 'UA',
  'ml' => 'IN',
  'hr' => 'HR',
  'bo' => 'CN',
  'shi_Latn' => 'MA',
  'tnr' => 'SN',
  'byn' => 'ER',
  'ceb' => 'PH',
  'kin' => 'RW',
  'ksb' => 'TZ',
  'nya' => 'MW',
  'lah' => 'PK',
  'shn' => 'MM',
  'mri' => 'NZ',
  'ewo' => 'CM',
  'nmg' => 'CM',
  'ilo' => 'PH',
  'ff_Latn' => 'SN',
  'zdj' => 'KM',
  'fy' => 'NL',
  'ljp' => 'ID',
  'ton' => 'TO',
  'aa' => 'ET',
  'quc' => 'GT',
  'yo' => 'NG',
  'glv' => 'IM',
  'af' => 'ZA',
  'mwr' => 'IN',
  'mn' => 'MN',
  'fon' => 'BJ',
  'hmo' => 'PG',
  'bm' => 'ML',
  'syl' => 'BD',
  'roh' => 'CH',
  'syr' => 'IQ',
  'sl' => 'SI',
  'srp_Cyrl' => 'RS',
  'ltz' => 'LU',
  'pol' => 'PL',
  'zha' => 'CN',
  'mlg' => 'MG',
  'te' => 'IN',
  'pam' => 'PH',
  'sot' => 'ZA',
  'por' => 'PT',
  'nld' => 'NL',
  'jav' => 'ID',
  'hsn' => 'CN',
  'kl' => 'GL',
  'mkd' => 'MK',
  'naq' => 'NA',
  'oss' => 'GE',
  'mni_Beng' => 'IN',
  'hi_Latn' => 'IN',
  'mus' => 'US',
  'aeb' => 'TN',
  'sav' => 'SN',
  'min' => 'ID',
  'kri' => 'SL',
  'ga' => 'IE',
  'slk' => 'SK',
  'kfy' => 'IN',
  'sin' => 'LK',
  'no' => 'NO',
  'snk' => 'ML',
  'ben' => 'BD',
  'sus' => 'GN',
  'uz_Arab' => 'AF',
  'sms' => 'FI',
  'mos' => 'BF',
  'khn' => 'IN',
  'tso' => 'ZA',
  'uig' => 'CN',
  'ca' => 'ES',
  'kn' => 'IN',
  'oc' => 'FR',
  'blt' => 'VN',
  'lt' => 'LT',
  'mfv' => 'SN',
  'bug' => 'ID',
  'mer' => 'KE',
  'isl' => 'IS',
  'sbp' => 'TZ',
  'nyn' => 'UG',
  'et' => 'EE',
  'es' => 'ES',
  'seh' => 'MZ',
  'hat' => 'HT',
  'ksf' => 'CM',
  'asm' => 'IN',
  'wbr' => 'IN',
  'yue_Hans' => 'CN',
  'bak' => 'RU',
  'mas' => 'KE',
  'orm' => 'ET',
  'co' => 'FR',
  'oci' => 'FR',
  'gu' => 'IN',
  'zza' => 'TR',
  'awa' => 'IN',
  'uzb_Latn' => 'UZ',
  'sas' => 'ID',
  'hin' => 'IN',
  'guz' => 'KE',
  'ava' => 'RU',
  'noe' => 'IN',
  'hsb' => 'DE',
  'cu' => 'RU',
  'chr' => 'US',
  'uz_Cyrl' => 'UZ',
  'nno' => 'NO',
  'ak' => 'GH',
  'sat' => 'IN',
  'bqi' => 'IR',
  'ibo' => 'NG',
  'ind' => 'ID',
  'mdf' => 'RU',
  'fan' => 'GQ',
  'yue_Hant' => 'HK',
  'kat' => 'GE',
  'iku' => 'CA',
  'kru' => 'IN',
  'msa_Arab' => 'MY',
  'sg' => 'CF',
  'msa' => 'MY',
  'kas_Arab' => 'IN',
  'mni' => 'IN',
  'dsb' => 'DE',
  'kas' => 'IN',
  'mad' => 'ID',
  'twq' => 'NE',
  'hif' => 'FJ',
  'tiv' => 'NG',
  'gil' => 'KI',
  'kpe' => 'LR',
  'dav' => 'KE',
  'am' => 'ET',
  'mg' => 'MG',
  'sr_Cyrl' => 'RS',
  'ps' => 'AF',
  'ary' => 'MA',
  'nau' => 'NR',
  'pt' => 'PT',
  'hoc' => 'IN',
  'iu' => 'CA',
  'bgc' => 'IN',
  'mzn' => 'IR',
  'bej' => 'SD',
  'ba' => 'RU',
  'ife' => 'TG',
  'tts' => 'TH',
  'mr' => 'IN',
  'bbc' => 'ID',
  'is' => 'IS',
  'sma' => 'SE',
  'it' => 'IT',
  'tha' => 'TH',
  'as' => 'IN',
  'fin' => 'FI',
  'iii' => 'CN',
  'id' => 'ID',
  'hoj' => 'IN',
  'kw' => 'GB',
  'che' => 'RU',
  'dan' => 'DK',
  'or' => 'IN',
  'lag' => 'TZ',
  'nor' => 'NO',
  'ssy' => 'ER',
  'div' => 'MV',
  'gom' => 'IN',
  'pa_Arab' => 'PK',
  'sid' => 'ET',
  'ks_Deva' => 'IN',
  'niu' => 'NU',
  'kon' => 'CD',
  'bhk' => 'PH',
  'wbq' => 'IN',
  'ky' => 'KG',
  'se' => 'NO',
  'grn' => 'PY',
  'tel' => 'IN',
  'mua' => 'CM',
  'kab' => 'DZ',
  'osa' => 'US',
  'fud' => 'WF',
  'sv' => 'SE',
  'cs' => 'CZ',
  'arn' => 'CL',
  'hye' => 'AM',
  'udm' => 'RU',
  'kaj' => 'NG',
  'rm' => 'CH',
  'afr' => 'ZA',
  'bul' => 'BG',
  'lrc' => 'IR',
  'yor' => 'NG',
  'ru' => 'RU',
  'tvl' => 'TV',
  'sd_Deva' => 'IN',
  'bik' => 'PH',
  'vai_Latn' => 'LR',
  'fvr' => 'SD',
  'aar' => 'ET',
  'jv' => 'ID',
  'fao' => 'FO',
  'wbp' => 'AU',
  'sun' => 'ID',
  'xnr' => 'IN',
  'az_Cyrl' => 'AZ',
  'smn' => 'FI',
  'mon' => 'MN',
  'tn' => 'ZA',
  'ro' => 'RO',
  'uk' => 'UA',
  'bam' => 'ML',
  'my' => 'MM',
  'nde' => 'ZW',
  'gd' => 'GB',
  'kua' => 'NA',
  'sw' => 'TZ',
  'pan_Guru' => 'IN',
  'bgn' => 'PK',
  'hy' => 'AM',
  'de' => 'DE',
  'vun' => 'TZ',
  'ful_Latn' => 'SN',
  'dyu' => 'BF',
  'pag' => 'PH',
  'aze_Arab' => 'IR',
  'rej' => 'ID',
  'su_Latn' => 'ID',
  'eu' => 'ES',
  'kcg' => 'NG',
  'eng_Dsrt' => 'US',
  'lu' => 'CD',
  'xho' => 'ZA',
  'fij' => 'FJ',
  'aze_Cyrl' => 'AZ',
  'tg' => 'TJ',
  'hun' => 'HU',
  'fr' => 'FR',
  'san' => 'IN',
  'chu' => 'RU',
  'az_Arab' => 'IR',
  'bm_Nkoo' => 'ML',
  'sc' => 'IT',
  'mgh' => 'MZ',
  'efi' => 'NG',
  'bhi' => 'IN',
  'zgh' => 'MA',
  'lo' => 'LA',
  'gla' => 'GB',
  'luz' => 'IR',
  'amh' => 'ET',
  'pau' => 'PW',
  'srr' => 'SN',
  'bum' => 'CM',
  'aln' => 'XK',
  'chk' => 'FM',
  'swe' => 'SE',
  'ibb' => 'NG',
  'kas_Deva' => 'IN',
  'zho_Hant' => 'TW',
  'nd' => 'ZW',
  'tr' => 'TR',
  'dua' => 'CM',
  'tgk' => 'TJ',
  'tpi' => 'PG',
  'urd' => 'PK',
  'tem' => 'SL',
  'brx' => 'IN',
  'wni' => 'KM',
  'sck' => 'IN',
  'fas' => 'IR',
  'tat' => 'RU',
  'gsw' => 'CH',
  'kkj' => 'CM',
  'sat_Olck' => 'IN',
  'sat_Deva' => 'IN',
  've' => 'ZA',
  'kan' => 'IN',
  'gor' => 'ID',
  'lug' => 'UG',
  'mfa' => 'TH',
  'dzo' => 'BT',
  'zho_Hans' => 'CN',
  'cor' => 'GB',
  'ii' => 'CN',
  'kmb' => 'AO',
  'ori' => 'IN',
  'he' => 'IL',
  'dv' => 'MV',
  'vmf' => 'DE',
  'bs_Cyrl' => 'BA',
  'deu' => 'DE',
  'fuv' => 'NG',
  'smj' => 'SE',
  'zh_Hans' => 'CN',
  'rcf' => 'RE',
  'ces' => 'CZ',
  'bos_Latn' => 'BA',
  'tsn' => 'ZA'
};
#-*-perl-*-


our $UnicodeScripts = &Unicode::UCD::charscripts();
our $UnicodeAliases = {};
our $UnicodeScriptCode = {};
foreach my $s (keys %{$UnicodeScripts}){
    my $ScriptCode = exists $$ScriptName2ScriptCode{$s} ? $$ScriptName2ScriptCode{$s} : undef;
    foreach my $a (Unicode::UCD::prop_value_aliases('script', $s)){
	$$UnicodeAliases{$a} = $s;
	unless ($ScriptCode){
	    $ScriptCode = $a if (exists $$ScriptCode2ScriptName{$a});
	}
    }
    if ($ScriptCode){
	$$UnicodeScriptCode{$s} = $ScriptCode; 
	$$UnicodeScriptCode{$ScriptCode} = $ScriptCode; 
    }
}


=head1 SUBROUTINES

=head2 $val = contains_script( $script, $string [, $count]  )

Returns 1 if the string in $string contains a valid Unicode character from script $script.
If $count is set to 1 then it returns the number of matching characters.

=cut


sub contains_script{
    if ((exists $$UnicodeScripts{$_[0]}) || (exists $$UnicodeAliases{$_[0]})){
	# my $regex = "\\p\{$_[0]\}";
	my $exists = 0;
	eval { $exists = $_[1]=~/\p{$_[0]}/; };
	if ($@) {
	    warn "Something went wrong! [$@]\n" if ($VERBOSE);
	    return 0;
	}
	if ($exists){
	    if ($_[2]){
		my $count = 0;
		while ($_[1] =~ m/\p{$_[0]}/gs) {$count++};
		return $count;
	    }
	    return 1;
	}
	return 0;
    }
    if ($_[0] eq 'Jpan'){
	return 1 if (contains_script('Hira', $_[1], $_[2]));
	return 1 if (contains_script('Kana', $_[1], $_[2]));
	return 1 if (contains_script('Han', $_[1], $_[2]));
    }
    if ($_[0] eq 'Hans' || $_[0] eq 'Hant'){
	my $script = &simplified_or_traditional_chinese($_[1]);
	if ($script eq $_[0]){
	    return contains_script('Han', $_[1], $_[2]) if ($_[2]);
	    return 1;
	}
	return 0;
    }
    print STDERR "unsupported script $_[0]\n" if ($VERBOSE);
    return undef;
}


=head2 $val = contains_simplified_chinese( $string [, $count] )

Returns 1 if the string in $string contains valid Han characters in its simplified form.
If $count is set to 1 then it returns the number of matching characters.

=cut

## TODO: is this good enough?
sub contains_simplified_chinese{
    my $test1 = $utf8gb2312_converter1->convert($_[0]);
    # my $test2 = $utf8gb2312_converter2->convert($_[0]);
    return length($test1);
}


=head2 $val = contains_traditional_chinese( $string [, $count] )

Returns 1 if the string in $string contains valid Han characters in its traditional form.
If $count is set to 1 then it returns the number of matching characters.

=cut

## TODO: is this good enough?
sub contains_traditional_chinese{
    my $test1 = $utf8big5_converter1->convert($_[0]);
    # my $test2 = $utf8big5_converter2->convert($_[0]);
    return length($test1);
}


=head2 detect_chinese_script( $string )

Returns the script of some Chinese text (Hans, Hant, ...)

=cut

sub detect_chinese_script{

    my $script = &simplified_or_traditional_chinese($_[0]);
    return $script if ($script);

    foreach $script (language_scripts('zho')){
	next if ($script eq 'Hans');
	next if ($script eq 'Hant');
	return $script if (contains_script($script, $_[0]));
    }
    return 'Zyyy';
}


=head2 simplified_or_traditional_chinese( $string )

Returns the script of some Chinese text (Hans or Hant)

=cut

sub simplified_or_traditional_chinese{

    my $test1 = $utf8big5_converter1->convert($_[0]) || "";
    my $test2 = $utf8big5_converter2->convert($_[0]) || "";

    return 'Hant' if ($test1 eq $test2);

    my $test3 = $utf8gb2312_converter1->convert($_[0]) || "";
    my $test4 = $utf8gb2312_converter2->convert($_[0]) || "";

    return 'Hans' if ($test3 eq $test4);

    if ( (length($test3) * $ChineseScriptProportion < length($test4)) || 
	 (length($test4) * $ChineseScriptProportion < length($test3)) ) {
	return 'Hans';
    }
    elsif ( (length($test1) * $ChineseScriptProportion < length($test2)) || 
	    (length($test2) * $ChineseScriptProportion < length($test1)) ){
	return 'Hant';
    }
    return undef;
}


=head2 script_of_string( $string [, $lang]  )

Returns 1 if the string in $string contains a valid Unicode character from script $script.
If $count is set to 1 then it returns the number of matching characters.

=cut


sub script_of_string{
    my ($str, $lang, $allow_non_standard) = @_;

    my @scripts = language_scripts($lang) if ($lang);
    @scripts = keys %{$UnicodeScripts} unless (@scripts);

    my %char = ();
    my $covered = 0;
    ## always include common characters
    push(@scripts, 'Zyyy') unless (grep ($_ eq 'Zyyy',@scripts));
    foreach my $s (@scripts){
	my $count = undef;
	if ($count = contains_script($s, $str, 1)){
	    my $script = exists $$UnicodeScriptCode{$s} ? $$UnicodeScriptCode{$s} : $s;
	    $char{$script} = $count;
	    $covered += $count;
	}
	# return undef if (not defined $count);
	## stop if we know enough
	unless (wantarray){
	    last if ($covered >= length($str)/2 );
	}
    }

    ## if a language is given return the best acceptable script
    ## unless we look for all scripts that we can detect
    ##        or non-standard scripts are also allowed
    if ((not wantarray) && $lang && (not $allow_non_standard)){
	## skip common characters if there are other ones detected
	delete $char{'Zyyy'} if ( (exists $char{'Zyyy'}) && (scalar keys %char > 1) );
	my ($MostFreq) = sort { $char{$b} <=> $char{$a} } keys %char;
	return $MostFreq
    }

    ## if we have matched less characters than length of the string
    ## then continue looking for other kinds of scripts
    ## TODO: this is an approximate condition as we can have property overlaps!
    if ( (wantarray && ($covered < length($str))) || 
	 ((not wantarray) && ($covered < length($str)/2)) ){
	foreach my $s (keys %{$UnicodeScripts}){
	    unless (grep($_ eq $s, @scripts)){
		if (my $count = contains_script($s, $str, 1)){
		    $char{$$UnicodeScriptCode{$s}} = $count;
		    $covered += $count;
		}
	    }
	    ## TODO: should we continue anyway?
	    last if ($covered >= length($str));
	}
    }

    ## return all counts
    return %char if (wantarray);
    
    ## skip common characters if there are other ones detected
    delete $char{'Zyyy'} if ( (exists $char{'Zyyy'}) && (scalar keys %char > 1) );

    ## return the most frequently present script
    my ($MostFreq) = sort { $char{$b} <=> $char{$a} } keys %char;
    return $MostFreq
}



sub script_code{
    return undef unless(@_);
    return $$ScriptName2ScriptCode{$_[0]} if (exists $$ScriptName2ScriptCode{$_[0]});
    print STDERR "unknown script $_[0]\n" if ($VERBOSE);
    return undef;
}

sub script_name{
    return undef unless(@_);
    return $$ScriptCode2ScriptName{$_[0]} if (exists $$ScriptCode2ScriptName{$_[0]});
    print STDERR "unknown script $_[0]\n" if ($VERBOSE);
    return undef;
}

sub language_scripts{
    return () unless(@_);
    return sort keys %{$$Lang2Script{$_[0]}} if (exists $$Lang2Script{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0]);
    return sort keys %{$$Lang2Script{$langcode}} if (exists $$Lang2Script{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode);
    return sort keys %{$$Lang2Script{$langcode}} if (exists $$Lang2Script{$langcode});
    print STDERR "unknown language $_[0]\n" if ($VERBOSE);
    return ();
}

sub default_script{
    return undef unless(@_);
    return $$DefaultScript{$_[0]} if (exists $$DefaultScript{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0]);
    return $$DefaultScript{$langcode} if (exists $$DefaultScript{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode);
    return $$DefaultScript{$langcode} if (exists $$DefaultScript{$langcode});
    return undef;
}

sub languages_with_script{
    return () unless(@_);
    return sort keys %{$$Script2Lang{$_[0]}} if (exists $$Script2Lang{$_[0]});
    my $code = script_code($_[0]);
    return sort keys %{$$Script2Lang{$code}} if (exists $$Script2Lang{$code});
    print STDERR "unknown script $_[0]\n" if ($VERBOSE);
    return ();
}

sub primary_languages_with_script{
    return () unless(@_);
    if (exists $$Script2Lang{$_[0]}){
	return grep($$Script2Lang{$_[0]}{$_} == 1, keys %{$$Script2Lang{$_[0]}});
    }
    my $code = script_code($_[0]);
    if (exists $$Script2Lang{$code}){
	return grep($$Script2Lang{$code}{$_} == 1, keys %{$$Script2Lang{$code}});
    }
    print STDERR "unknown script $_[0]\n" if ($VERBOSE);
    return ();
}

sub secondary_languages_with_script{
    return () unless(@_);
    if (exists $$Script2Lang{$_[0]}){
	return grep($$Script2Lang{$_[0]}{$_} == 2, keys %{$$Script2Lang{$_[0]}});
    }
    my $code = script_code($_[0]);
    if (exists $$Script2Lang{$code}){
	return grep($$Script2Lang{$code}{$_} == 2, keys %{$$Script2Lang{$code}});
    }
    print STDERR "unknown script $_[0]\n" if ($VERBOSE);
    return ();
}



sub language_territories{
    return undef unless(@_);
    return keys %{$$Lang2Territory{$_[0]}} if (exists $$Lang2Territory{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0]);
    return sort keys %{$$Lang2Territory{$langcode}} if (exists $$Lang2Territory{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode);
    return sort keys %{$$Lang2Territory{$langcode}} if (exists $$Lang2Territory{$langcode});
    # print STDERR "no territory found for language $_[0]\n";
    return ();
}

sub language_territory{
    return undef unless(@_);
    if ($_[0]=~/\_([a-zA-Z]{2})$/){
	my $region = uc($1);
	return $region if (exists $$Territory2Lang{$region});
    }
    ## if there is only one region 
    my @regions = language_territories($_[0]);
    return $regions[0] if ($#regions == 0);
    return default_territory($_[0]) if ($_[1]);
    return 'XX';
}

sub default_territory{
    return undef unless(@_);
    return $$DefaultTerritory{$_[0]} if (exists $$DefaultTerritory{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0]);
    return $$DefaultTerritory{$langcode} if (exists $$DefaultTerritory{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode);
    return $$DefaultTerritory{$langcode} if (exists $$DefaultTerritory{$langcode});
    return 'XX';
}

sub primary_territories{
    return () unless(@_);
    if (exists $$Lang2Territory{$_[0]}){
	return grep($$Lang2Territory{$_[0]}{$_} == 1, keys %{$$Lang2Territory{$_[0]}});
    }
    my $langcode = ISO::639::3::get_iso639_3($_[0]);
    if (exists $$Lang2Territory{$langcode}){
	return grep($$Lang2Territory{$langcode}{$_} == 1, keys %{$$Lang2Territory{$langcode}});
    }
    $langcode = ISO::639::3::get_macro_language($langcode);
    if (exists $$Lang2Territory{$langcode}){
	return grep($$Lang2Territory{$langcode}{$_} == 1, keys %{$$Lang2Territory{$langcode}});
    }
    # print STDERR "no primary territory found for language $_[0]\n";
    return ();
}

sub secondary_territories{
    return () unless(@_);
    if (exists $$Lang2Territory{$_[0]}){
	return grep($$Lang2Territory{$_[0]}{$_} == 2, keys %{$$Lang2Territory{$_[0]}});
    }
    my $langcode = ISO::639::3::get_iso639_3($_[0]);
    if (exists $$Lang2Territory{$langcode}){
	return grep($$Lang2Territory{$langcode}{$_} == 2, keys %{$$Lang2Territory{$langcode}});
    }
    $langcode = ISO::639::3::get_macro_language($langcode);
    if (exists $$Lang2Territory{$langcode}){
	return grep($$Lang2Territory{$langcode}{$_} == 2, keys %{$$Lang2Territory{$langcode}});
    }
    # print STDERR "no secondary territory found for language $_[0]\n";
    return ();
}


=head1 AUTHOR

Joerg Tiedemann, C<< <tiedemann at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-iso-15924 at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=ISO-15924>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISO::15924


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=ISO-15924>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ISO-15924>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/ISO-15924>

=item * Search CPAN

L<https://metacpan.org/release/ISO-15924>

=back


=head1 ACKNOWLEDGEMENTS


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

1; # End of ISO::15924


