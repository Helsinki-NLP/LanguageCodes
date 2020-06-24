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

Version 0.01

=cut

our $VERSION      = '0.01';

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
  'Sidd' => 'Siddham',
  'Lana' => 'Tai_Tham',
  'Batk' => 'Batak',
  'Osge' => 'Osage',
  'Xpeo' => 'Old_Persian',
  'Inds' => '',
  'Olck' => 'Ol_Chiki',
  'Kana' => 'Katakana',
  'Bamu' => 'Bamum',
  'Geok' => 'Georgian',
  'Gujr' => 'Gujarati',
  'Hmng' => 'Pahawh_Hmong',
  'Sora' => 'Sora_Sompeng',
  'Aran' => '',
  'Merc' => 'Meroitic_Cursive',
  'Perm' => 'Old_Permic',
  'Qabx' => '',
  'Cyrs' => '',
  'Nshu' => 'Nushu',
  'Lyci' => 'Lycian',
  'Armi' => 'Imperial_Aramaic',
  'Gran' => 'Grantha',
  'Lina' => 'Linear_A',
  'Narb' => 'Old_North_Arabian',
  'Hatr' => 'Hatran',
  'Taml' => 'Tamil',
  'Egyd' => '',
  'Latg' => '',
  'Ahom' => 'Ahom',
  'Nkgb' => '',
  'Yiii' => 'Yi',
  'Laoo' => 'Lao',
  'Hano' => 'Hanunoo',
  'Teng' => '',
  'Zmth' => '',
  'Mani' => 'Manichaean',
  'Mymr' => 'Myanmar',
  'Sgnw' => 'SignWriting',
  'Gong' => 'Gunjala_Gondi',
  'Guru' => 'Gurmukhi',
  'Thaa' => 'Thaana',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Bass' => 'Bassa_Vah',
  'Limb' => 'Limbu',
  'Kthi' => 'Kaithi',
  'Modi' => 'Modi',
  'Buhd' => 'Buhid',
  'Kits' => 'Khitan_Small_Script',
  'Bugi' => 'Buginese',
  'Mend' => 'Mende_Kikakui',
  'Soyo' => 'Soyombo',
  'Shrd' => 'Sharada',
  'Latf' => '',
  'Xsux' => 'Cuneiform',
  'Mroo' => 'Mro',
  'Runr' => 'Runic',
  'Bhks' => 'Bhaiksuki',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Talu' => 'New_Tai_Lue',
  'Sind' => 'Khudawadi',
  'Hira' => 'Hiragana',
  'Qaaa' => '',
  'Avst' => 'Avestan',
  'Tavt' => 'Tai_Viet',
  'Kitl' => '',
  'Nkoo' => 'Nko',
  'Samr' => 'Samaritan',
  'Pauc' => 'Pau_Cin_Hau',
  'Orya' => 'Oriya',
  'Lisu' => 'Lisu',
  'Syre' => '',
  'Ugar' => 'Ugaritic',
  'Khoj' => 'Khojki',
  'Bopo' => 'Bopomofo',
  'Sara' => '',
  'Piqd' => '',
  'Zinh' => 'Inherited',
  'Dupl' => 'Duployan',
  'Tglg' => 'Tagalog',
  'Knda' => 'Kannada',
  'Copt' => 'Coptic',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Tagb' => 'Tagbanwa',
  'Cyrl' => 'Cyrillic',
  'Nbat' => 'Nabataean',
  'Gonm' => 'Masaram_Gondi',
  'Lepc' => 'Lepcha',
  'Bali' => 'Balinese',
  'Hung' => 'Old_Hungarian',
  'Grek' => 'Greek',
  'Zanb' => 'Zanabazar_Square',
  'Leke' => '',
  'Roro' => '',
  'Tibt' => 'Tibetan',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Wole' => '',
  'Mong' => 'Mongolian',
  'Khmr' => 'Khmer',
  'Lydi' => 'Lydian',
  'Jpan' => '',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Phlv' => '',
  'Tang' => 'Tangut',
  'Adlm' => 'Adlam',
  'Cprt' => 'Cypriot',
  'Syrj' => '',
  'Cher' => 'Cherokee',
  'Yezi' => 'Yezidi',
  'Cakm' => 'Chakma',
  'Beng' => 'Bengali',
  'Loma' => '',
  'Shaw' => 'Shavian',
  'Hebr' => 'Hebrew',
  'Zxxx' => '',
  'Cari' => 'Carian',
  'Cans' => 'Canadian_Aboriginal',
  'Dsrt' => 'Deseret',
  'Takr' => 'Takri',
  'Afak' => '',
  'Shui' => '',
  'Toto' => '',
  'Hanb' => '',
  'Kpel' => '',
  'Cpmn' => '',
  'Phnx' => 'Phoenician',
  'Telu' => 'Telugu',
  'Zsym' => '',
  'Sogd' => 'Sogdian',
  'Ogam' => 'Ogham',
  'Mand' => 'Mandaic',
  'Mlym' => 'Malayalam',
  'Blis' => '',
  'Aghb' => 'Caucasian_Albanian',
  'Visp' => '',
  'Latn' => 'Latin',
  'Sinh' => 'Sinhala',
  'Orkh' => 'Old_Turkic',
  'Diak' => 'Dives_Akuru',
  'Vaii' => 'Vai',
  'Saur' => 'Saurashtra',
  'Armn' => 'Armenian',
  'Marc' => 'Marchen',
  'Brah' => 'Brahmi',
  'Tfng' => 'Tifinagh',
  'Mtei' => 'Meetei_Mayek',
  'Moon' => '',
  'Rohg' => 'Hanifi_Rohingya',
  'Mult' => 'Multani',
  'Glag' => 'Glagolitic',
  'Sarb' => 'Old_South_Arabian',
  'Hant' => '',
  'Thai' => 'Thai',
  'Nkdb' => '',
  'Elym' => 'Elymaic',
  'Ethi' => 'Ethiopic',
  'Cirt' => '',
  'Syrc' => 'Syriac',
  'Sylo' => 'Syloti_Nagri',
  'Arab' => 'Arabic',
  'Kore' => '',
  'Deva' => 'Devanagari',
  'Ital' => 'Old_Italic',
  'Hans' => '',
  'Geor' => 'Georgian',
  'Kali' => 'Kayah_Li',
  'Palm' => 'Palmyrene',
  'Khar' => 'Kharoshthi',
  'Cham' => 'Cham',
  'Dogr' => 'Dogra',
  'Rjng' => 'Rejang',
  'Syrn' => '',
  'Phli' => 'Inscriptional_Pahlavi',
  'Maka' => 'Makasar',
  'Sund' => 'Sundanese',
  'Phag' => 'Phags_Pa',
  'Hani' => 'Han',
  'Tale' => 'Tai_Le',
  'Medf' => 'Medefaidrin',
  'Mahj' => 'Mahajani',
  'Java' => 'Javanese',
  'Hang' => 'Hangul',
  'Tirh' => 'Tirhuta',
  'Sogo' => 'Old_Sogdian',
  'Zyyy' => 'Common',
  'Elba' => 'Elbasan',
  'Jurc' => '',
  'Phlp' => 'Psalter_Pahlavi',
  'Goth' => 'Gothic',
  'Chrs' => 'Chorasmian',
  'Newa' => 'Newa',
  'Maya' => '',
  'Nand' => 'Nandinagari',
  'Wara' => 'Warang_Citi',
  'Zsye' => '',
  'Prti' => 'Inscriptional_Parthian',
  'Brai' => 'Braille',
  'Zzzz' => 'Unknown',
  'Plrd' => 'Miao',
  'Linb' => 'Linear_B',
  'Osma' => 'Osmanya',
  'Wcho' => 'Wancho',
  'Jamo' => '',
  'Egyh' => ''
};
$ScriptName2ScriptCode = {
  'Wancho' => 'Wcho',
  'Nabataean' => 'Nbat',
  'Hanifi_Rohingya' => 'Rohg',
  'Katakana' => 'Kana',
  'Syloti_Nagri' => 'Sylo',
  'Arabic' => 'Arab',
  'Unknown' => 'Zzzz',
  'Ugaritic' => 'Ugar',
  'Tai_Le' => 'Tale',
  'Mahajani' => 'Mahj',
  'Phoenician' => 'Phnx',
  'Old_Persian' => 'Xpeo',
  'Deseret' => 'Dsrt',
  '' => 'Zxxx',
  'Mro' => 'Mroo',
  'Braille' => 'Brai',
  'Adlam' => 'Adlm',
  'Tibetan' => 'Tibt',
  'Inscriptional_Pahlavi' => 'Phli',
  'Lepcha' => 'Lepc',
  'Pahawh_Hmong' => 'Hmng',
  'Soyombo' => 'Soyo',
  'Gurmukhi' => 'Guru',
  'Old_Sogdian' => 'Sogo',
  'Lao' => 'Laoo',
  'Glagolitic' => 'Glag',
  'Chorasmian' => 'Chrs',
  'Han' => 'Hani',
  'Rejang' => 'Rjng',
  'Tai_Tham' => 'Lana',
  'Psalter_Pahlavi' => 'Phlp',
  'Coptic' => 'Copt',
  'Saurashtra' => 'Saur',
  'Tagbanwa' => 'Tagb',
  'Sora_Sompeng' => 'Sora',
  'Malayalam' => 'Mlym',
  'Sinhala' => 'Sinh',
  'Avestan' => 'Avst',
  'Tangut' => 'Tang',
  'Newa' => 'Newa',
  'Mandaic' => 'Mand',
  'Dogra' => 'Dogr',
  'Mende_Kikakui' => 'Mend',
  'Khmer' => 'Khmr',
  'Carian' => 'Cari',
  'Georgian' => 'Geor',
  'Manichaean' => 'Mani',
  'Balinese' => 'Bali',
  'Osage' => 'Osge',
  'Lisu' => 'Lisu',
  'Linear_A' => 'Lina',
  'Syriac' => 'Syrc',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Ethiopic' => 'Ethi',
  'Duployan' => 'Dupl',
  'Chakma' => 'Cakm',
  'Medefaidrin' => 'Medf',
  'Old_Hungarian' => 'Hung',
  'Javanese' => 'Java',
  'Khudawadi' => 'Sind',
  'Mongolian' => 'Mong',
  'Ol_Chiki' => 'Olck',
  'Latin' => 'Latn',
  'Kaithi' => 'Kthi',
  'Old_North_Arabian' => 'Narb',
  'Bhaiksuki' => 'Bhks',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Greek' => 'Grek',
  'Old_Permic' => 'Perm',
  'Samaritan' => 'Samr',
  'Grantha' => 'Gran',
  'Linear_B' => 'Linb',
  'Cyrillic' => 'Cyrl',
  'Hatran' => 'Hatr',
  'Gunjala_Gondi' => 'Gong',
  'Armenian' => 'Armn',
  'Cham' => 'Cham',
  'Gothic' => 'Goth',
  'Sundanese' => 'Sund',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Brahmi' => 'Brah',
  'Lycian' => 'Lyci',
  'Tagalog' => 'Tglg',
  'Osmanya' => 'Osma',
  'Yezidi' => 'Yezi',
  'Makasar' => 'Maka',
  'Canadian_Aboriginal' => 'Cans',
  'Elymaic' => 'Elym',
  'Sogdian' => 'Sogd',
  'Khojki' => 'Khoj',
  'Elbasan' => 'Elba',
  'Cherokee' => 'Cher',
  'Old_South_Arabian' => 'Sarb',
  'Old_Turkic' => 'Orkh',
  'Bopomofo' => 'Bopo',
  'Inherited' => 'Zinh',
  'Palmyrene' => 'Palm',
  'Common' => 'Zyyy',
  'Oriya' => 'Orya',
  'Limbu' => 'Limb',
  'Bamum' => 'Bamu',
  'Thaana' => 'Thaa',
  'Nushu' => 'Nshu',
  'Lydian' => 'Lydi',
  'Kayah_Li' => 'Kali',
  'Ogham' => 'Ogam',
  'Cuneiform' => 'Xsux',
  'Caucasian_Albanian' => 'Aghb',
  'Hiragana' => 'Hira',
  'Takri' => 'Takr',
  'Pau_Cin_Hau' => 'Pauc',
  'Thai' => 'Thai',
  'Masaram_Gondi' => 'Gonm',
  'Meetei_Mayek' => 'Mtei',
  'Meroitic_Cursive' => 'Merc',
  'Vai' => 'Vaii',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Yi' => 'Yiii',
  'Myanmar' => 'Mymr',
  'Tirhuta' => 'Tirh',
  'SignWriting' => 'Sgnw',
  'Shavian' => 'Shaw',
  'New_Tai_Lue' => 'Talu',
  'Hangul' => 'Hang',
  'Tai_Viet' => 'Tavt',
  'Modi' => 'Modi',
  'Miao' => 'Plrd',
  'Phags_Pa' => 'Phag',
  'Hanunoo' => 'Hano',
  'Sharada' => 'Shrd',
  'Inscriptional_Parthian' => 'Prti',
  'Dives_Akuru' => 'Diak',
  'Tamil' => 'Taml',
  'Buhid' => 'Buhd',
  'Siddham' => 'Sidd',
  'Cypriot' => 'Cprt',
  'Kannada' => 'Knda',
  'Batak' => 'Batk',
  'Zanabazar_Square' => 'Zanb',
  'Bengali' => 'Beng',
  'Imperial_Aramaic' => 'Armi',
  'Ahom' => 'Ahom',
  'Multani' => 'Mult',
  'Nko' => 'Nkoo',
  'Nandinagari' => 'Nand',
  'Buginese' => 'Bugi',
  'Marchen' => 'Marc',
  'Khitan_Small_Script' => 'Kits',
  'Telugu' => 'Telu',
  'Runic' => 'Runr',
  'Bassa_Vah' => 'Bass',
  'Kharoshthi' => 'Khar',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Hebrew' => 'Hebr',
  'Devanagari' => 'Deva',
  'Tifinagh' => 'Tfng',
  'Warang_Citi' => 'Wara',
  'Gujarati' => 'Gujr',
  'Old_Italic' => 'Ital'
};
$ScriptId2ScriptCode = {
  '142' => 'Sogo',
  '285' => 'Bopo',
  '312' => 'Gong',
  '192' => 'Yezi',
  '402' => 'Cpmn',
  '264' => 'Mroo',
  '135' => 'Syrc',
  '335' => 'Lepc',
  '239' => 'Aghb',
  '342' => 'Diak',
  '311' => 'Nand',
  '401' => 'Linb',
  '141' => 'Sogd',
  '263' => 'Pauc',
  '126' => 'Palm',
  '349' => 'Cakm',
  '367' => 'Bugi',
  '399' => 'Lisu',
  '360' => 'Bali',
  '900' => 'Qaaa',
  '450' => 'Hmng',
  '175' => 'Orkh',
  '160' => 'Arab',
  '319' => 'Shrd',
  '215' => 'Latn',
  '167' => 'Rohg',
  '326' => 'Tirh',
  '313' => 'Gonm',
  '403' => 'Cprt',
  '170' => 'Thaa',
  '217' => 'Latf',
  '128' => 'Elym',
  '165' => 'Nkoo',
  '210' => 'Ital',
  '240' => 'Geor',
  '290' => 'Teng',
  '365' => 'Batk',
  '370' => 'Tglg',
  '328' => 'Dogr',
  '343' => 'Gran',
  '530' => 'Shui',
  '050' => 'Egyp',
  '570' => 'Brai',
  '330' => 'Tibt',
  '262' => 'Wara',
  '337' => 'Mtei',
  '314' => 'Mahj',
  '280' => 'Visp',
  '137' => 'Syrj',
  '344' => 'Saur',
  '130' => 'Prti',
  '287' => 'Kore',
  '261' => 'Olck',
  '106' => 'Narb',
  '949' => 'Qabx',
  '286' => 'Hang',
  '999' => 'Zzzz',
  '159' => 'Nbat',
  '440' => 'Cans',
  '100' => 'Mero',
  '136' => 'Syrn',
  '085' => 'Nkdb',
  '336' => 'Limb',
  '300' => 'Brah',
  '410' => 'Hira',
  '359' => 'Tavt',
  '221' => 'Cyrs',
  '125' => 'Hebr',
  '352' => 'Thai',
  '480' => 'Wole',
  '500' => 'Hani',
  '095' => 'Sgnw',
  '176' => 'Hung',
  '204' => 'Copt',
  '325' => 'Beng',
  '216' => 'Latg',
  '351' => 'Lana',
  '201' => 'Cari',
  '166' => 'Adlm',
  '327' => 'Orya',
  '320' => 'Gujr',
  '439' => 'Afak',
  '354' => 'Talu',
  '994' => 'Zinh',
  '120' => 'Tfng',
  '127' => 'Hatr',
  '218' => 'Moon',
  '202' => 'Lyci',
  '366' => 'Maka',
  '505' => 'Kitl',
  '040' => 'Ugar',
  '090' => 'Maya',
  '353' => 'Tale',
  '288' => 'Kits',
  '305' => 'Khar',
  '250' => 'Dsrt',
  '138' => 'Syre',
  '520' => 'Tang',
  '338' => 'Ahom',
  '620' => 'Roro',
  '445' => 'Cher',
  '993' => 'Zsye',
  '105' => 'Sarb',
  '080' => 'Hluw',
  '324' => 'Modi',
  '350' => 'Mymr',
  '030' => 'Xpeo',
  '502' => 'Hant',
  '357' => 'Kali',
  '109' => 'Chrs',
  '499' => 'Nshu',
  '501' => 'Hans',
  '997' => 'Zxxx',
  '460' => 'Yiii',
  '124' => 'Armi',
  '435' => 'Bamu',
  '220' => 'Cyrl',
  '411' => 'Kana',
  '323' => 'Mult',
  '348' => 'Sinh',
  '227' => 'Perm',
  '398' => 'Sora',
  '318' => 'Sind',
  '412' => 'Hrkt',
  '302' => 'Sidd',
  '123' => 'Samr',
  '101' => 'Merc',
  '070' => 'Egyd',
  '550' => 'Blis',
  '116' => 'Lydi',
  '060' => 'Egyh',
  '346' => 'Taml',
  '503' => 'Hanb',
  '430' => 'Ethi',
  '329' => 'Soyo',
  '225' => 'Glag',
  '316' => 'Sylo',
  '437' => 'Loma',
  '995' => 'Zmth',
  '470' => 'Vaii',
  '322' => 'Khoj',
  '355' => 'Khmr',
  '259' => 'Bass',
  '413' => 'Jpan',
  '321' => 'Takr',
  '200' => 'Grek',
  '755' => 'Dupl',
  '333' => 'Newa',
  '161' => 'Aran',
  '451' => 'Hmnp',
  '998' => 'Zyyy',
  '206' => 'Goth',
  '362' => 'Sund',
  '230' => 'Armn',
  '358' => 'Cham',
  '610' => 'Inds',
  '283' => 'Wcho',
  '361' => 'Java',
  '133' => 'Phlv',
  '510' => 'Jurc',
  '294' => 'Toto',
  '140' => 'Mand',
  '400' => 'Lina',
  '310' => 'Guru',
  '436' => 'Kpel',
  '020' => 'Xsux',
  '334' => 'Bhks',
  '317' => 'Kthi',
  '347' => 'Mlym',
  '265' => 'Medf',
  '134' => 'Avst',
  '293' => 'Piqd',
  '373' => 'Tagb',
  '340' => 'Telu',
  '284' => 'Jamo',
  '438' => 'Mend',
  '332' => 'Marc',
  '260' => 'Osma',
  '131' => 'Phli',
  '281' => 'Shaw',
  '363' => 'Rjng',
  '115' => 'Phnx',
  '345' => 'Knda',
  '145' => 'Mong',
  '219' => 'Osge',
  '282' => 'Plrd',
  '315' => 'Deva',
  '226' => 'Elba',
  '331' => 'Phag',
  '132' => 'Phlp',
  '364' => 'Leke',
  '139' => 'Mani',
  '371' => 'Hano',
  '291' => 'Cirt',
  '241' => 'Geok',
  '212' => 'Ogam',
  '996' => 'Zsym',
  '292' => 'Sara',
  '211' => 'Runr',
  '356' => 'Laoo',
  '339' => 'Zanb',
  '420' => 'Nkgb',
  '372' => 'Buhd'
};
$ScriptCode2EnglishName = {
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Lana' => 'Tai Tham (Lanna)',
  'Osge' => 'Osage',
  'Batk' => 'Batak',
  'Xpeo' => 'Old Persian',
  'Inds' => 'Indus (Harappan)',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Gujr' => 'Gujarati',
  'Bamu' => 'Bamum',
  'Kana' => 'Katakana',
  'Hmng' => 'Pahawh Hmong',
  'Sora' => 'Sora Sompeng',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Merc' => 'Meroitic Cursive',
  'Qabx' => 'Reserved for private use (end)',
  'Perm' => 'Old Permic',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Nshu' => "N\x{fc}shu",
  'Lyci' => 'Lycian',
  'Armi' => 'Imperial Aramaic',
  'Gran' => 'Grantha',
  'Lina' => 'Linear A',
  'Hatr' => 'Hatran',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Taml' => 'Tamil',
  'Egyd' => 'Egyptian demotic',
  'Latg' => 'Latin (Gaelic variant)',
  'Ahom' => 'Ahom, Tai Ahom',
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Laoo' => 'Lao',
  'Yiii' => 'Yi',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Teng' => 'Tengwar',
  'Mani' => 'Manichaean',
  'Zmth' => 'Mathematical notation',
  'Sgnw' => 'SignWriting',
  'Mymr' => 'Myanmar (Burmese)',
  'Gong' => 'Gunjala Gondi',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Thaa' => 'Thaana',
  'Guru' => 'Gurmukhi',
  'Bass' => 'Bassa Vah',
  'Limb' => 'Limbu',
  'Kthi' => 'Kaithi',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Kits' => 'Khitan small script',
  'Buhd' => 'Buhid',
  'Bugi' => 'Buginese',
  'Soyo' => 'Soyombo',
  'Mend' => 'Mende Kikakui',
  'Latf' => 'Latin (Fraktur variant)',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Runr' => 'Runic',
  'Mroo' => 'Mro, Mru',
  'Talu' => 'New Tai Lue',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Bhks' => 'Bhaiksuki',
  'Sind' => 'Khudawadi, Sindhi',
  'Hira' => 'Hiragana',
  'Qaaa' => 'Reserved for private use (start)',
  'Avst' => 'Avestan',
  'Kitl' => 'Khitan large script',
  'Tavt' => 'Tai Viet',
  'Samr' => 'Samaritan',
  'Nkoo' => "N\x{2019}Ko",
  'Pauc' => 'Pau Cin Hau',
  'Orya' => 'Oriya (Odia)',
  'Syre' => 'Syriac (Estrangelo variant)',
  'Lisu' => 'Lisu (Fraser)',
  'Ugar' => 'Ugaritic',
  'Bopo' => 'Bopomofo',
  'Khoj' => 'Khojki',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Sara' => 'Sarati',
  'Zinh' => 'Code for inherited script',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Knda' => 'Kannada',
  'Copt' => 'Coptic',
  'Cyrl' => 'Cyrillic',
  'Tagb' => 'Tagbanwa',
  'Mero' => 'Meroitic Hieroglyphs',
  'Nbat' => 'Nabataean',
  'Gonm' => 'Masaram Gondi',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Bali' => 'Balinese',
  'Grek' => 'Greek',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Leke' => 'Leke',
  'Roro' => 'Rongorongo',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Tibt' => 'Tibetan',
  'Wole' => 'Woleai',
  'Mong' => 'Mongolian',
  'Khmr' => 'Khmer',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Lydi' => 'Lydian',
  'Egyp' => 'Egyptian hieroglyphs',
  'Tang' => 'Tangut',
  'Phlv' => 'Book Pahlavi',
  'Adlm' => 'Adlam',
  'Cprt' => 'Cypriot syllabary',
  'Cher' => 'Cherokee',
  'Yezi' => 'Yezidi',
  'Syrj' => 'Syriac (Western variant)',
  'Cakm' => 'Chakma',
  'Loma' => 'Loma',
  'Beng' => 'Bengali (Bangla)',
  'Hebr' => 'Hebrew',
  'Shaw' => 'Shavian (Shaw)',
  'Zxxx' => 'Code for unwritten documents',
  'Cari' => 'Carian',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Dsrt' => 'Deseret (Mormon)',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Shui' => 'Shuishu',
  'Afak' => 'Afaka',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Kpel' => 'Kpelle',
  'Toto' => 'Toto',
  'Phnx' => 'Phoenician',
  'Cpmn' => 'Cypro-Minoan',
  'Telu' => 'Telugu',
  'Zsym' => 'Symbols',
  'Sogd' => 'Sogdian',
  'Ogam' => 'Ogham',
  'Mlym' => 'Malayalam',
  'Mand' => 'Mandaic, Mandaean',
  'Aghb' => 'Caucasian Albanian',
  'Blis' => 'Blissymbols',
  'Latn' => 'Latin',
  'Visp' => 'Visible Speech',
  'Vaii' => 'Vai',
  'Diak' => 'Dives Akuru',
  'Sinh' => 'Sinhala',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Saur' => 'Saurashtra',
  'Armn' => 'Armenian',
  'Marc' => 'Marchen',
  'Brah' => 'Brahmi',
  'Tfng' => 'Tifinagh (Berber)',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Rohg' => 'Hanifi Rohingya',
  'Mult' => 'Multani',
  'Sarb' => 'Old South Arabian',
  'Glag' => 'Glagolitic',
  'Hant' => 'Han (Traditional variant)',
  'Thai' => 'Thai',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Elym' => 'Elymaic',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Cirt' => 'Cirth',
  'Syrc' => 'Syriac',
  'Sylo' => 'Syloti Nagri',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Arab' => 'Arabic',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Deva' => 'Devanagari (Nagari)',
  'Hans' => 'Han (Simplified variant)',
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Kali' => 'Kayah Li',
  'Palm' => 'Palmyrene',
  'Cham' => 'Cham',
  'Khar' => 'Kharoshthi',
  'Dogr' => 'Dogra',
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Phli' => 'Inscriptional Pahlavi',
  'Syrn' => 'Syriac (Eastern variant)',
  'Sund' => 'Sundanese',
  'Maka' => 'Makasar',
  'Phag' => 'Phags-pa',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Tale' => 'Tai Le',
  'Java' => 'Javanese',
  'Mahj' => 'Mahajani',
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Tirh' => 'Tirhuta',
  'Sogo' => 'Old Sogdian',
  'Zyyy' => 'Code for undetermined script',
  'Jurc' => 'Jurchen',
  'Elba' => 'Elbasan',
  'Goth' => 'Gothic',
  'Phlp' => 'Psalter Pahlavi',
  'Chrs' => 'Chorasmian',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Nand' => 'Nandinagari',
  'Maya' => 'Mayan hieroglyphs',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Prti' => 'Inscriptional Parthian',
  'Zsye' => 'Symbols (Emoji variant)',
  'Brai' => 'Braille',
  'Zzzz' => 'Code for uncoded script',
  'Osma' => 'Osmanya',
  'Linb' => 'Linear B',
  'Plrd' => 'Miao (Pollard)',
  'Wcho' => 'Wancho',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Egyh' => 'Egyptian hieratic'
};
$ScriptCode2FrenchName = {
  'Saur' => 'saurachtra',
  'Orkh' => 'orkhon',
  'Diak' => 'dives akuru',
  'Sinh' => 'singhalais',
  'Vaii' => "va\x{ef}",
  'Armn' => "arm\x{e9}nien",
  'Blis' => 'symboles Bliss',
  'Aghb' => 'aghbanien',
  'Visp' => 'parole visible',
  'Latn' => 'latin',
  'Mtei' => 'meitei mayek',
  'Marc' => 'marchen',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Brah' => 'brahma',
  'Mult' => "multan\x{ee}",
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Glag' => 'glagolitique',
  'Sarb' => 'sud-arabique, himyarite',
  'Moon' => "\x{e9}criture Moon",
  'Rohg' => 'hanifi rohingya',
  'Thai' => "tha\x{ef}",
  'Syrj' => 'syriaque (variante occidentale)',
  'Yezi' => "y\x{e9}zidi",
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Cakm' => 'chakma',
  'Phlv' => 'pehlevi des livres',
  'Tang' => 'tangoute',
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Cprt' => 'syllabaire chypriote',
  'Adlm' => 'adlam',
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Cari' => 'carien',
  'Beng' => "bengal\x{ee} (bangla)",
  'Loma' => 'loma',
  'Shaw' => 'shavien (Shaw)',
  'Hebr' => "h\x{e9}breu",
  'Afak' => 'afaka',
  'Shui' => 'shuishu',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Toto' => 'toto',
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Sogd' => 'sogdien',
  'Mand' => "mand\x{e9}en",
  'Mlym' => "malay\x{e2}lam",
  'Ogam' => 'ogam',
  'Telu' => "t\x{e9}lougou",
  'Cpmn' => 'syllabaire chypro-minoen',
  'Phnx' => "ph\x{e9}nicien",
  'Zsym' => 'symboles',
  'Tale' => "ta\x{ef}-le",
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Java' => 'javanais',
  'Phag' => "\x{2019}phags pa",
  'Sogo' => 'ancien sogdien',
  'Tirh' => 'tirhouta',
  'Elba' => 'elbasan',
  'Jurc' => 'jurchen',
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Wara' => 'warang citi',
  'Goth' => 'gotique',
  'Phlp' => 'pehlevi des psautiers',
  'Chrs' => 'chorasmien',
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Plrd' => 'miao (Pollard)',
  'Linb' => "lin\x{e9}aire B",
  'Osma' => 'osmanais',
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Wcho' => 'wantcho',
  'Brai' => 'braille',
  'Prti' => 'parthe des inscriptions',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Syrc' => 'syriaque',
  'Cirt' => 'cirth',
  'Nkdb' => 'naxi dongba',
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Arab' => 'arabe',
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Palm' => "palmyr\x{e9}nien",
  'Kali' => 'kayah li',
  'Khar' => "kharochth\x{ee}",
  'Cham' => "cham (\x{10d}am, tcham)",
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Syrn' => 'syriaque (variante orientale)',
  'Phli' => 'pehlevi des inscriptions',
  'Sund' => 'sundanais',
  'Maka' => 'makassar',
  'Rjng' => 'redjang (kaganga)',
  'Dogr' => 'dogra',
  'Teng' => 'tengwar',
  'Yiii' => 'yi',
  'Laoo' => 'laotien',
  'Hano' => "hanoun\x{f3}o",
  'Bass' => 'bassa',
  'Kthi' => "kaith\x{ee}",
  'Limb' => 'limbou',
  'Mymr' => 'birman',
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Mani' => "manich\x{e9}en",
  'Zmth' => "notation math\x{e9}matique",
  'Guru' => "gourmoukh\x{ee}",
  'Thaa' => "th\x{e2}na",
  'Hmnp' => 'nyiakeng puachue hmong',
  'Gong' => "gunjala gond\x{ee}",
  'Buhd' => 'bouhide',
  'Kits' => "petite \x{e9}criture khitan",
  'Modi' => "mod\x{ee}",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Talu' => "nouveau ta\x{ef}-lue",
  'Mroo' => 'mro',
  'Runr' => 'runique',
  'Mend' => "mend\x{e9} kikakui",
  'Soyo' => 'soyombo',
  'Bugi' => 'bouguis',
  'Shrd' => 'charada, shard',
  'Latf' => "latin (variante bris\x{e9}e)",
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Batk' => 'batik',
  'Osge' => 'osage',
  'Olck' => 'ol tchiki',
  'Inds' => 'indus',
  'Sidd' => 'siddham',
  'Lana' => "ta\x{ef} tham (lanna)",
  'Aran' => 'arabe (variante nastalique)',
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Kana' => 'katakana',
  'Bamu' => 'bamoum',
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Sora' => 'sora sompeng',
  'Hmng' => 'pahawh hmong',
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Gran' => 'grantha',
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Perm' => 'ancien permien',
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Lyci' => 'lycien',
  'Nshu' => "n\x{fc}shu",
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Nkgb' => 'naxi geba, nakhi geba',
  'Ahom' => "\x{e2}hom",
  'Narb' => 'nord-arabique',
  'Hatr' => "hatr\x{e9}nien",
  'Lina' => "lin\x{e9}aire A",
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Taml' => 'tamoul',
  'Gonm' => "masaram gond\x{ee}",
  'Nbat' => "nabat\x{e9}en",
  'Tagb' => 'tagbanoua',
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Cyrl' => 'cyrillique',
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Grek' => 'grec',
  'Zanb' => 'zanabazar quadratique',
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Bali' => 'balinais',
  'Tibt' => "tib\x{e9}tain",
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Roro' => 'rongorongo',
  'Leke' => "l\x{e9}k\x{e9}",
  'Mong' => 'mongol',
  'Khmr' => 'khmer',
  'Lydi' => 'lydien',
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Wole' => "wol\x{e9}a\x{ef}",
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Kitl' => "grande \x{e9}criture khitan",
  'Pauc' => 'paou chin haou',
  'Nkoo' => "n\x{2019}ko",
  'Samr' => 'samaritain',
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Hira' => 'hiragana',
  'Avst' => 'avestique',
  'Ugar' => 'ougaritique',
  'Lisu' => 'lisu (Fraser)',
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Khoj' => "khojk\x{ee}",
  'Bopo' => 'bopomofo',
  'Orya' => "oriy\x{e2} (odia)",
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Sara' => 'sarati',
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Knda' => 'kannara (canara)',
  'Copt' => 'copte',
  'Tglg' => 'tagal (baybayin, alibata)'
};
$ScriptCodeVersion = {
  'Sara' => '',
  'Piqd' => '',
  'Dupl' => '7.0',
  'Zinh' => '',
  'Tglg' => '3.2',
  'Copt' => '4.1',
  'Knda' => '1.1',
  'Avst' => '5.2',
  'Sind' => '7.0',
  'Hira' => '1.1',
  'Qaaa' => '',
  'Nkoo' => '5.0',
  'Samr' => '5.2',
  'Pauc' => '7.0',
  'Tavt' => '5.2',
  'Kitl' => '',
  'Orya' => '1.1',
  'Khoj' => '7.0',
  'Bopo' => '1.1',
  'Lisu' => '5.2',
  'Syre' => '3.0',
  'Ugar' => '4.0',
  'Leke' => '',
  'Roro' => '',
  'Tibt' => '2.0',
  'Hrkt' => '1.1',
  'Wole' => '',
  'Lydi' => '5.1',
  'Jpan' => '1.1',
  'Khmr' => '3.0',
  'Mong' => '3.0',
  'Tagb' => '3.2',
  'Mero' => '6.1',
  'Cyrl' => '1.1',
  'Nbat' => '7.0',
  'Gonm' => '10.0',
  'Lepc' => '5.1',
  'Bali' => '5.0',
  'Zanb' => '10.0',
  'Hung' => '8.0',
  'Grek' => '1.1',
  'Nshu' => '10.0',
  'Lyci' => '5.1',
  'Perm' => '7.0',
  'Qabx' => '',
  'Cyrs' => '1.1',
  'Gran' => '7.0',
  'Armi' => '5.2',
  'Taml' => '1.1',
  'Egyd' => '',
  'Lina' => '7.0',
  'Narb' => '7.0',
  'Hatr' => '8.0',
  'Ahom' => '8.0',
  'Nkgb' => '',
  'Latg' => '1.1',
  'Lana' => '5.2',
  'Sidd' => '7.0',
  'Inds' => '',
  'Olck' => '5.1',
  'Batk' => '6.0',
  'Osge' => '9.0',
  'Xpeo' => '4.1',
  'Hmng' => '7.0',
  'Sora' => '6.1',
  'Kana' => '1.1',
  'Geok' => '1.1',
  'Bamu' => '5.2',
  'Gujr' => '1.1',
  'Merc' => '6.1',
  'Aran' => '1.1',
  'Modi' => '7.0',
  'Buhd' => '3.2',
  'Kits' => '13.0',
  'Shrd' => '6.1',
  'Latf' => '1.1',
  'Bugi' => '4.1',
  'Mend' => '7.0',
  'Soyo' => '10.0',
  'Mroo' => '7.0',
  'Runr' => '3.0',
  'Hluw' => '8.0',
  'Bhks' => '9.0',
  'Talu' => '4.1',
  'Xsux' => '5.0',
  'Hano' => '3.2',
  'Yiii' => '3.0',
  'Laoo' => '1.1',
  'Teng' => '',
  'Gong' => '11.0',
  'Thaa' => '3.0',
  'Guru' => '1.1',
  'Hmnp' => '12.0',
  'Mani' => '7.0',
  'Zmth' => '3.2',
  'Mymr' => '3.0',
  'Sgnw' => '8.0',
  'Limb' => '4.0',
  'Kthi' => '5.2',
  'Bass' => '7.0',
  'Geor' => '1.1',
  'Hans' => '1.1',
  'Khar' => '4.1',
  'Cham' => '5.1',
  'Palm' => '7.0',
  'Kali' => '5.1',
  'Dogr' => '11.0',
  'Rjng' => '5.1',
  'Sund' => '5.1',
  'Maka' => '11.0',
  'Syrn' => '3.0',
  'Phli' => '5.2',
  'Elym' => '12.0',
  'Nkdb' => '',
  'Cirt' => '',
  'Syrc' => '3.0',
  'Ethi' => '3.0',
  'Sylo' => '4.1',
  'Deva' => '1.1',
  'Ital' => '3.1',
  'Arab' => '1.1',
  'Kore' => '1.1',
  'Chrs' => '13.0',
  'Newa' => '9.0',
  'Goth' => '3.1',
  'Phlp' => '7.0',
  'Wara' => '7.0',
  'Maya' => '',
  'Nand' => '12.0',
  'Prti' => '5.2',
  'Zsye' => '6.0',
  'Brai' => '3.0',
  'Wcho' => '12.0',
  'Egyh' => '5.2',
  'Jamo' => '1.1',
  'Zzzz' => '',
  'Linb' => '4.0',
  'Plrd' => '6.1',
  'Osma' => '4.0',
  'Phag' => '5.0',
  'Mahj' => '7.0',
  'Java' => '5.2',
  'Hani' => '1.1',
  'Tale' => '4.0',
  'Medf' => '11.0',
  'Hang' => '1.1',
  'Zyyy' => '',
  'Jurc' => '',
  'Elba' => '7.0',
  'Tirh' => '7.0',
  'Sogo' => '11.0',
  'Dsrt' => '3.1',
  'Cans' => '3.0',
  'Toto' => '',
  'Hanb' => '1.1',
  'Kpel' => '',
  'Takr' => '6.1',
  'Afak' => '',
  'Shui' => '',
  'Zsym' => '1.1',
  'Phnx' => '5.0',
  'Cpmn' => '',
  'Telu' => '1.1',
  'Ogam' => '3.0',
  'Mand' => '6.0',
  'Mlym' => '1.1',
  'Sogd' => '11.0',
  'Adlm' => '9.0',
  'Cprt' => '4.0',
  'Egyp' => '5.2',
  'Phlv' => '',
  'Tang' => '9.0',
  'Cakm' => '6.1',
  'Syrj' => '3.0',
  'Yezi' => '13.0',
  'Cher' => '3.0',
  'Shaw' => '4.0',
  'Hebr' => '1.1',
  'Beng' => '1.1',
  'Loma' => '',
  'Cari' => '5.1',
  'Zxxx' => '',
  'Rohg' => '11.0',
  'Moon' => '',
  'Glag' => '4.1',
  'Sarb' => '5.2',
  'Hant' => '1.1',
  'Mult' => '8.0',
  'Thai' => '1.1',
  'Visp' => '',
  'Latn' => '1.1',
  'Blis' => '',
  'Aghb' => '7.0',
  'Armn' => '1.1',
  'Diak' => '13.0',
  'Sinh' => '3.0',
  'Orkh' => '5.2',
  'Vaii' => '5.1',
  'Saur' => '5.1',
  'Brah' => '6.0',
  'Tfng' => '4.1',
  'Marc' => '9.0',
  'Mtei' => '5.2'
};
$ScriptCodeDate = {
  'Ogam' => '2004-05-01
',
  'Mand' => '2010-07-23
',
  'Mlym' => '2004-05-01
',
  'Sogd' => '2017-11-21
',
  'Zsym' => '2007-11-26
',
  'Cpmn' => '2017-07-26
',
  'Phnx' => '2006-10-10
',
  'Telu' => '2004-05-01
',
  'Toto' => '2020-04-16
',
  'Hanb' => '2016-01-19
',
  'Kpel' => '2010-03-26
',
  'Takr' => '2012-02-06
',
  'Afak' => '2010-12-21
',
  'Shui' => '2017-07-26
',
  'Cans' => '2004-05-29
',
  'Dsrt' => '2004-05-01
',
  'Cari' => '2007-07-02
',
  'Zxxx' => '2011-06-21
',
  'Shaw' => '2004-05-01
',
  'Hebr' => '2004-05-01
',
  'Beng' => '2016-12-05
',
  'Loma' => '2010-03-26
',
  'Cakm' => '2012-02-06
',
  'Syrj' => '2004-05-01
',
  'Cher' => '2004-05-01
',
  'Yezi' => '2019-08-19
',
  'Adlm' => '2016-12-05
',
  'Cprt' => '2017-07-26
',
  'Egyp' => '2009-06-01
',
  'Phlv' => '2007-07-15
',
  'Tang' => '2016-12-05
',
  'Thai' => '2004-05-01
',
  'Glag' => '2006-06-21
',
  'Sarb' => '2009-06-01
',
  'Hant' => '2004-05-29
',
  'Mult' => '2015-07-07
',
  'Rohg' => '2017-11-21
',
  'Moon' => '2006-12-11
',
  'Mtei' => '2009-06-01
',
  'Brah' => '2010-07-23
',
  'Tfng' => '2006-06-21
',
  'Marc' => '2016-12-05
',
  'Armn' => '2004-05-01
',
  'Diak' => '2019-08-19
',
  'Orkh' => '2009-06-01
',
  'Sinh' => '2004-05-01
',
  'Vaii' => '2007-07-02
',
  'Saur' => '2007-07-02
',
  'Visp' => '2004-05-01
',
  'Latn' => '2004-05-01
',
  'Blis' => '2004-05-01
',
  'Aghb' => '2014-11-15
',
  'Sund' => '2007-07-02
',
  'Maka' => '2016-12-05
',
  'Syrn' => '2004-05-01
',
  'Phli' => '2009-06-01
',
  'Dogr' => '2016-12-05
',
  'Rjng' => '2009-02-23
',
  'Khar' => '2006-06-21
',
  'Cham' => '2009-11-11
',
  'Kali' => '2007-07-02
',
  'Palm' => '2014-11-15
',
  'Geor' => '2016-12-05
',
  'Hans' => '2004-05-29
',
  'Deva' => '2004-05-01
',
  'Ital' => '2004-05-29
',
  'Arab' => '2004-05-01
',
  'Kore' => '2007-06-13
',
  'Sylo' => '2006-06-21
',
  'Cirt' => '2004-05-01
',
  'Syrc' => '2004-05-01
',
  'Ethi' => '2004-10-25
',
  'Elym' => '2018-08-26
',
  'Nkdb' => '2017-07-26
',
  'Wcho' => '2017-07-26
',
  'Jamo' => '2016-01-19
',
  'Egyh' => '2004-05-01
',
  'Zzzz' => '2006-10-10
',
  'Plrd' => '2012-02-06
',
  'Linb' => '2004-05-29
',
  'Osma' => '2004-05-01
',
  'Zsye' => '2015-12-16
',
  'Prti' => '2009-06-01
',
  'Brai' => '2004-05-01
',
  'Wara' => '2014-11-15
',
  'Maya' => '2004-05-01
',
  'Nand' => '2018-08-26
',
  'Chrs' => '2019-08-19
',
  'Newa' => '2016-12-05
',
  'Phlp' => '2014-11-15
',
  'Goth' => '2004-05-01
',
  'Zyyy' => '2004-05-29
',
  'Jurc' => '2010-12-21
',
  'Elba' => '2014-11-15
',
  'Tirh' => '2014-11-15
',
  'Sogo' => '2017-11-21
',
  'Hang' => '2004-05-29
',
  'Mahj' => '2014-11-15
',
  'Java' => '2009-06-01
',
  'Hani' => '2009-02-23
',
  'Tale' => '2004-10-25
',
  'Medf' => '2016-12-05
',
  'Phag' => '2006-10-10
',
  'Ahom' => '2015-07-07
',
  'Nkgb' => '2017-07-26
',
  'Latg' => '2004-05-01
',
  'Taml' => '2004-05-01
',
  'Egyd' => '2004-05-01
',
  'Lina' => '2014-11-15
',
  'Narb' => '2014-11-15
',
  'Hatr' => '2015-07-07
',
  'Gran' => '2014-11-15
',
  'Armi' => '2009-06-01
',
  'Nshu' => '2017-07-26
',
  'Lyci' => '2007-07-02
',
  'Perm' => '2014-11-15
',
  'Qabx' => '2004-05-29
',
  'Cyrs' => '2004-05-01
',
  'Merc' => '2012-02-06
',
  'Aran' => '2014-11-15
',
  'Hmng' => '2014-11-15
',
  'Sora' => '2012-02-06
',
  'Kana' => '2004-05-01
',
  'Gujr' => '2004-05-01
',
  'Geok' => '2012-10-16
',
  'Bamu' => '2009-06-01
',
  'Inds' => '2004-05-01
',
  'Olck' => '2007-07-02
',
  'Osge' => '2016-12-05
',
  'Batk' => '2010-07-23
',
  'Xpeo' => '2006-06-21
',
  'Lana' => '2009-06-01
',
  'Sidd' => '2014-11-15
',
  'Mroo' => '2016-12-05
',
  'Runr' => '2004-05-01
',
  'Bhks' => '2016-12-05
',
  'Hluw' => '2015-07-07
',
  'Talu' => '2006-06-21
',
  'Xsux' => '2006-10-10
',
  'Shrd' => '2012-02-06
',
  'Latf' => '2004-05-01
',
  'Bugi' => '2006-06-21
',
  'Mend' => '2014-11-15
',
  'Soyo' => '2017-07-26
',
  'Buhd' => '2004-05-01
',
  'Kits' => '2015-07-15
',
  'Modi' => '2014-11-15
',
  'Limb' => '2004-05-29
',
  'Kthi' => '2009-06-01
',
  'Bass' => '2014-11-15
',
  'Gong' => '2016-12-05
',
  'Guru' => '2004-05-01
',
  'Thaa' => '2004-05-01
',
  'Hmnp' => '2017-07-26
',
  'Zmth' => '2007-11-26
',
  'Mani' => '2014-11-15
',
  'Mymr' => '2004-05-01
',
  'Sgnw' => '2015-07-07
',
  'Teng' => '2004-05-01
',
  'Hano' => '2004-05-29
',
  'Yiii' => '2004-05-01
',
  'Laoo' => '2004-05-01
',
  'Copt' => '2006-06-21
',
  'Knda' => '2004-05-29
',
  'Tglg' => '2009-02-23
',
  'Dupl' => '2014-11-15
',
  'Zinh' => '2009-02-23
',
  'Sara' => '2004-05-29
',
  'Piqd' => '2015-12-16
',
  'Khoj' => '2014-11-15
',
  'Bopo' => '2004-05-01
',
  'Lisu' => '2009-06-01
',
  'Syre' => '2004-05-01
',
  'Ugar' => '2004-05-01
',
  'Orya' => '2016-12-05
',
  'Nkoo' => '2006-10-10
',
  'Samr' => '2009-06-01
',
  'Pauc' => '2014-11-15
',
  'Tavt' => '2009-06-01
',
  'Kitl' => '2015-07-15
',
  'Avst' => '2009-06-01
',
  'Sind' => '2014-11-15
',
  'Hira' => '2004-05-01
',
  'Qaaa' => '2004-05-29
',
  'Lydi' => '2007-07-02
',
  'Jpan' => '2006-06-21
',
  'Mong' => '2004-05-01
',
  'Khmr' => '2004-05-29
',
  'Wole' => '2010-12-21
',
  'Roro' => '2004-05-01
',
  'Tibt' => '2004-05-01
',
  'Hrkt' => '2011-06-21
',
  'Leke' => '2015-07-07
',
  'Zanb' => '2017-07-26
',
  'Hung' => '2015-07-07
',
  'Grek' => '2004-05-01
',
  'Bali' => '2006-10-10
',
  'Lepc' => '2007-07-02
',
  'Gonm' => '2017-07-26
',
  'Mero' => '2012-02-06
',
  'Tagb' => '2004-05-01
',
  'Cyrl' => '2004-05-01
',
  'Nbat' => '2014-11-15
'
};
$ScriptCodeId = {
  'Limb' => '336',
  'Kthi' => '317',
  'Bass' => '259',
  'Gong' => '312',
  'Thaa' => '170',
  'Guru' => '310',
  'Hmnp' => '451',
  'Mani' => '139',
  'Zmth' => '995',
  'Mymr' => '350',
  'Sgnw' => '095',
  'Teng' => '290',
  'Hano' => '371',
  'Yiii' => '460',
  'Laoo' => '356',
  'Mroo' => '264',
  'Runr' => '211',
  'Bhks' => '334',
  'Hluw' => '080',
  'Talu' => '354',
  'Xsux' => '020',
  'Latf' => '217',
  'Shrd' => '319',
  'Bugi' => '367',
  'Mend' => '438',
  'Soyo' => '329',
  'Kits' => '288',
  'Buhd' => '372',
  'Modi' => '324',
  'Merc' => '101',
  'Aran' => '161',
  'Hmng' => '450',
  'Sora' => '398',
  'Kana' => '411',
  'Geok' => '241',
  'Bamu' => '435',
  'Gujr' => '320',
  'Inds' => '610',
  'Olck' => '261',
  'Batk' => '365',
  'Osge' => '219',
  'Xpeo' => '030',
  'Lana' => '351',
  'Sidd' => '302',
  'Ahom' => '338',
  'Nkgb' => '420',
  'Latg' => '216',
  'Taml' => '346',
  'Egyd' => '070',
  'Lina' => '400',
  'Narb' => '106',
  'Hatr' => '127',
  'Gran' => '343',
  'Armi' => '124',
  'Nshu' => '499',
  'Lyci' => '202',
  'Perm' => '227',
  'Qabx' => '949',
  'Cyrs' => '221',
  'Zanb' => '339',
  'Hung' => '176',
  'Grek' => '200',
  'Lepc' => '335',
  'Bali' => '360',
  'Gonm' => '313',
  'Tagb' => '373',
  'Mero' => '100',
  'Cyrl' => '220',
  'Nbat' => '159',
  'Lydi' => '116',
  'Jpan' => '413',
  'Mong' => '145',
  'Khmr' => '355',
  'Wole' => '480',
  'Roro' => '620',
  'Tibt' => '330',
  'Hrkt' => '412',
  'Leke' => '364',
  'Khoj' => '322',
  'Bopo' => '285',
  'Lisu' => '399',
  'Syre' => '138',
  'Ugar' => '040',
  'Orya' => '327',
  'Nkoo' => '165',
  'Samr' => '123',
  'Pauc' => '263',
  'Tavt' => '359',
  'Kitl' => '505',
  'Avst' => '134',
  'Sind' => '318',
  'Hira' => '410',
  'Qaaa' => '900',
  'Copt' => '204',
  'Knda' => '345',
  'Tglg' => '370',
  'Dupl' => '755',
  'Zinh' => '994',
  'Sara' => '292',
  'Piqd' => '293',
  'Mtei' => '337',
  'Brah' => '300',
  'Tfng' => '120',
  'Marc' => '332',
  'Armn' => '230',
  'Sinh' => '348',
  'Orkh' => '175',
  'Diak' => '342',
  'Vaii' => '470',
  'Saur' => '344',
  'Visp' => '280',
  'Latn' => '215',
  'Blis' => '550',
  'Aghb' => '239',
  'Thai' => '352',
  'Glag' => '225',
  'Sarb' => '105',
  'Hant' => '502',
  'Mult' => '323',
  'Rohg' => '167',
  'Moon' => '218',
  'Cari' => '201',
  'Zxxx' => '997',
  'Shaw' => '281',
  'Hebr' => '125',
  'Beng' => '325',
  'Loma' => '437',
  'Cakm' => '349',
  'Syrj' => '137',
  'Yezi' => '192',
  'Cher' => '445',
  'Adlm' => '166',
  'Cprt' => '403',
  'Egyp' => '050',
  'Phlv' => '133',
  'Tang' => '520',
  'Ogam' => '212',
  'Mlym' => '347',
  'Mand' => '140',
  'Sogd' => '141',
  'Zsym' => '996',
  'Cpmn' => '402',
  'Phnx' => '115',
  'Telu' => '340',
  'Toto' => '294',
  'Hanb' => '503',
  'Kpel' => '436',
  'Takr' => '321',
  'Afak' => '439',
  'Shui' => '530',
  'Cans' => '440',
  'Dsrt' => '250',
  'Zyyy' => '998',
  'Jurc' => '510',
  'Elba' => '226',
  'Sogo' => '142',
  'Tirh' => '326',
  'Hang' => '286',
  'Mahj' => '314',
  'Java' => '361',
  'Hani' => '500',
  'Tale' => '353',
  'Medf' => '265',
  'Phag' => '331',
  'Wcho' => '283',
  'Jamo' => '284',
  'Egyh' => '060',
  'Zzzz' => '999',
  'Plrd' => '282',
  'Linb' => '401',
  'Osma' => '260',
  'Zsye' => '993',
  'Prti' => '130',
  'Brai' => '570',
  'Wara' => '262',
  'Maya' => '090',
  'Nand' => '311',
  'Chrs' => '109',
  'Newa' => '333',
  'Goth' => '206',
  'Phlp' => '132',
  'Deva' => '315',
  'Ital' => '210',
  'Arab' => '160',
  'Kore' => '287',
  'Sylo' => '316',
  'Cirt' => '291',
  'Syrc' => '135',
  'Ethi' => '430',
  'Elym' => '128',
  'Nkdb' => '085',
  'Sund' => '362',
  'Maka' => '366',
  'Syrn' => '136',
  'Phli' => '131',
  'Dogr' => '328',
  'Rjng' => '363',
  'Khar' => '305',
  'Cham' => '358',
  'Kali' => '357',
  'Palm' => '126',
  'Geor' => '240',
  'Hans' => '501'
};
$Lang2Territory = {
  'fao' => {
    'FO' => 1
  },
  'bmv' => {
    'CM' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'nld' => {
    'BQ' => 1,
    'CW' => 1,
    'SX' => 1,
    'BE' => 1,
    'NL' => 1,
    'AW' => 1,
    'SR' => 1,
    'DE' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'mfa' => {
    'TH' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'srn' => {
    'SR' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'ibb' => {
    'NG' => 2
  },
  'kkt' => {
    'RU' => 2
  },
  'sus' => {
    'GN' => 2
  },
  'doi' => {
    'IN' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'tam' => {
    'LK' => 1,
    'MY' => 2,
    'SG' => 1,
    'IN' => 2
  },
  'som' => {
    'SO' => 1,
    'DJ' => 2,
    'ET' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'fil' => {
    'US' => 2,
    'PH' => 1
  },
  'rus' => {
    'LT' => 2,
    'BY' => 1,
    'KG' => 1,
    'TJ' => 2,
    'SJ' => 2,
    'LV' => 2,
    'RU' => 1,
    'UZ' => 2,
    'KZ' => 1,
    'UA' => 1,
    'PL' => 2,
    'EE' => 2,
    'DE' => 2,
    'BG' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'xho' => {
    'ZA' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'est' => {
    'EE' => 1
  },
  'tuk' => {
    'TM' => 1,
    'AF' => 2,
    'IR' => 2
  },
  'fon' => {
    'BJ' => 2
  },
  'nya' => {
    'MW' => 1,
    'ZM' => 2
  },
  'skr' => {
    'PK' => 2
  },
  'sav' => {
    'SN' => 2
  },
  'bal' => {
    'PK' => 2,
    'AF' => 2,
    'IR' => 2
  },
  'mak' => {
    'ID' => 2
  },
  'mwr' => {
    'IN' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'sag' => {
    'CF' => 1
  },
  'smo' => {
    'WS' => 1,
    'AS' => 1
  },
  'kin' => {
    'RW' => 1
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'bhi' => {
    'IN' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'ori' => {
    'IN' => 2
  },
  'haw' => {
    'US' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'tig' => {
    'ER' => 2
  },
  'arq' => {
    'DZ' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'srd' => {
    'IT' => 2
  },
  'suk' => {
    'TZ' => 2
  },
  'tiv' => {
    'NG' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'glg' => {
    'ES' => 2
  },
  'zho' => {
    'CN' => 1,
    'US' => 2,
    'VN' => 2,
    'TH' => 2,
    'ID' => 2,
    'SG' => 1,
    'MO' => 1,
    'MY' => 2,
    'TW' => 1,
    'HK' => 1
  },
  'wol' => {
    'SN' => 1
  },
  'swb' => {
    'YT' => 2
  },
  'bej' => {
    'SD' => 2
  },
  'hmo' => {
    'PG' => 1
  },
  'glv' => {
    'IM' => 1
  },
  'nyn' => {
    'UG' => 2
  },
  'vmw' => {
    'MZ' => 2
  },
  'lez' => {
    'RU' => 2
  },
  'zha' => {
    'CN' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'mai' => {
    'NP' => 2,
    'IN' => 2
  },
  'wbr' => {
    'IN' => 2
  },
  'tur' => {
    'CY' => 1,
    'DE' => 2,
    'TR' => 1
  },
  'bod' => {
    'CN' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'bin' => {
    'NG' => 2
  },
  'pmn' => {
    'PH' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'ilo' => {
    'PH' => 2
  },
  'fin' => {
    'SE' => 2,
    'EE' => 2,
    'FI' => 1
  },
  'wbq' => {
    'IN' => 2
  },
  'kal' => {
    'GL' => 1,
    'DK' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'ceb' => {
    'PH' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'kmb' => {
    'AO' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'slk' => {
    'SK' => 1,
    'CZ' => 2,
    'RS' => 2
  },
  'aln' => {
    'XK' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'ban' => {
    'ID' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'luz' => {
    'IR' => 2
  },
  'kon' => {
    'CD' => 2
  },
  'arz' => {
    'EG' => 2
  },
  'ckb' => {
    'IR' => 2,
    'IQ' => 2
  },
  'hye' => {
    'AM' => 1,
    'RU' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'gsw' => {
    'LI' => 1,
    'CH' => 1,
    'DE' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'unr' => {
    'IN' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'slv' => {
    'AT' => 2,
    'SI' => 1
  },
  'sco' => {
    'GB' => 2
  },
  'sas' => {
    'ID' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'tpi' => {
    'PG' => 1
  },
  'tum' => {
    'MW' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'orm' => {
    'ET' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'hno' => {
    'PK' => 2
  },
  'ssw' => {
    'SZ' => 1,
    'ZA' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'nep' => {
    'IN' => 2,
    'NP' => 1
  },
  'eng' => {
    'AI' => 1,
    'LS' => 1,
    'IQ' => 2,
    'KZ' => 2,
    'LC' => 1,
    'AT' => 2,
    'NR' => 1,
    'MH' => 1,
    'IT' => 2,
    'SG' => 1,
    'PK' => 1,
    'CH' => 2,
    'SI' => 2,
    'GD' => 1,
    'TO' => 1,
    'MP' => 1,
    'ZW' => 1,
    'AG' => 1,
    'DG' => 1,
    'IL' => 2,
    'TZ' => 1,
    'BA' => 2,
    'KN' => 1,
    'KE' => 1,
    'GG' => 1,
    'ET' => 2,
    'ZM' => 1,
    'LU' => 2,
    'FM' => 1,
    'CA' => 1,
    'GY' => 1,
    'PR' => 1,
    'MA' => 2,
    'SL' => 1,
    'GI' => 1,
    'SD' => 1,
    'TC' => 1,
    'EG' => 2,
    'HR' => 2,
    'TH' => 2,
    'AR' => 2,
    'NG' => 1,
    'BM' => 1,
    'PL' => 2,
    'MU' => 1,
    'CM' => 1,
    'VU' => 1,
    'SB' => 1,
    'ZA' => 1,
    'BE' => 2,
    'CC' => 1,
    'BW' => 1,
    'ER' => 1,
    'MX' => 2,
    'SK' => 2,
    'PG' => 1,
    'UG' => 1,
    'NL' => 2,
    'BS' => 1,
    'NF' => 1,
    'VC' => 1,
    'MW' => 1,
    'GR' => 2,
    'CZ' => 2,
    'HK' => 1,
    'YE' => 2,
    'TA' => 2,
    'DK' => 2,
    'CX' => 1,
    'MS' => 1,
    'BZ' => 1,
    'PT' => 2,
    'GB' => 1,
    'CY' => 2,
    'NU' => 1,
    'SH' => 1,
    'MG' => 1,
    'FK' => 1,
    'VG' => 1,
    'RO' => 2,
    'BI' => 1,
    'BG' => 2,
    'MT' => 1,
    'TV' => 1,
    'VI' => 1,
    'TR' => 2,
    'US' => 1,
    'LK' => 2,
    'PW' => 1,
    'MY' => 2,
    'CL' => 2,
    'GH' => 1,
    'LV' => 2,
    'PN' => 1,
    'LR' => 1,
    'RW' => 1,
    'BD' => 2,
    'TK' => 1,
    'LB' => 2,
    'UM' => 1,
    'FR' => 2,
    'WS' => 1,
    'NZ' => 1,
    'JM' => 1,
    'IO' => 1,
    'ES' => 2,
    'SE' => 2,
    'BB' => 1,
    'BR' => 2,
    'HU' => 2,
    'AU' => 1,
    'JE' => 1,
    'AE' => 2,
    'DE' => 2,
    'IE' => 1,
    'IN' => 1,
    'IM' => 1,
    'TT' => 1,
    'JO' => 2,
    'DM' => 1,
    'AS' => 1,
    'PH' => 1,
    'SZ' => 1,
    'NA' => 1,
    'AC' => 2,
    'LT' => 2,
    'GM' => 1,
    'FJ' => 1,
    'SX' => 1,
    'FI' => 2,
    'DZ' => 2,
    'KY' => 1,
    'EE' => 2,
    'SS' => 1,
    'KI' => 1,
    'SC' => 1,
    'GU' => 1,
    'CK' => 1
  },
  'krc' => {
    'RU' => 2
  },
  'glk' => {
    'IR' => 2
  },
  'hoc' => {
    'IN' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'oci' => {
    'FR' => 2
  },
  'pau' => {
    'PW' => 1
  },
  'fud' => {
    'WF' => 2
  },
  'bul' => {
    'BG' => 1
  },
  'khm' => {
    'KH' => 1
  },
  'ful' => {
    'GN' => 2,
    'ML' => 2,
    'NE' => 2,
    'NG' => 2,
    'SN' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'sna' => {
    'ZW' => 1
  },
  'afr' => {
    'ZA' => 2,
    'NA' => 2
  },
  'div' => {
    'MV' => 1
  },
  'bqi' => {
    'IR' => 2
  },
  'mag' => {
    'IN' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'grn' => {
    'PY' => 1
  },
  'dyu' => {
    'BF' => 2
  },
  'heb' => {
    'IL' => 1
  },
  'tcy' => {
    'IN' => 2
  },
  'dnj' => {
    'CI' => 2
  },
  'ell' => {
    'GR' => 1,
    'CY' => 1
  },
  'haz' => {
    'AF' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'xog' => {
    'UG' => 2
  },
  'deu' => {
    'FR' => 2,
    'US' => 2,
    'CZ' => 2,
    'DE' => 1,
    'CH' => 1,
    'SI' => 2,
    'PL' => 2,
    'BE' => 1,
    'GB' => 2,
    'DK' => 2,
    'KZ' => 2,
    'LI' => 1,
    'LU' => 1,
    'HU' => 2,
    'AT' => 1,
    'SK' => 2,
    'BR' => 2,
    'NL' => 2
  },
  'gle' => {
    'IE' => 1,
    'GB' => 2
  },
  'ben' => {
    'BD' => 1,
    'IN' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'tzm' => {
    'MA' => 1
  },
  'shn' => {
    'MM' => 2
  },
  'fij' => {
    'FJ' => 1
  },
  'nod' => {
    'TH' => 2
  },
  'guz' => {
    'KE' => 2
  },
  'ces' => {
    'SK' => 2,
    'CZ' => 1
  },
  'kdh' => {
    'SL' => 2
  },
  'bgn' => {
    'PK' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'kdx' => {
    'KE' => 2
  },
  'swe' => {
    'SE' => 1,
    'FI' => 1,
    'AX' => 1
  },
  'que' => {
    'BO' => 1,
    'EC' => 1,
    'PE' => 1
  },
  'hau' => {
    'NE' => 2,
    'NG' => 2
  },
  'por' => {
    'MO' => 1,
    'PT' => 1,
    'GW' => 1,
    'MZ' => 1,
    'ST' => 1,
    'BR' => 1,
    'GQ' => 1,
    'CV' => 1,
    'TL' => 1,
    'AO' => 1
  },
  'lug' => {
    'UG' => 2
  },
  'gom' => {
    'IN' => 2
  },
  'awa' => {
    'IN' => 2
  },
  'srp' => {
    'ME' => 1,
    'BA' => 1,
    'XK' => 1,
    'RS' => 1
  },
  'rmt' => {
    'IR' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'tha' => {
    'TH' => 1
  },
  'tyv' => {
    'RU' => 2
  },
  'kea' => {
    'CV' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'snd' => {
    'IN' => 2,
    'PK' => 2
  },
  'tir' => {
    'ER' => 1,
    'ET' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'amh' => {
    'ET' => 1
  },
  'bem' => {
    'ZM' => 2
  },
  'mon' => {
    'CN' => 2,
    'MN' => 1
  },
  'zdj' => {
    'KM' => 1
  },
  'gcr' => {
    'GF' => 2
  },
  'lua' => {
    'CD' => 2
  },
  'ara' => {
    'IL' => 1,
    'LY' => 1,
    'ER' => 1,
    'LB' => 1,
    'KM' => 1,
    'MA' => 2,
    'SS' => 2,
    'DZ' => 2,
    'TD' => 1,
    'SD' => 1,
    'EH' => 1,
    'SA' => 1,
    'YE' => 1,
    'EG' => 2,
    'OM' => 1,
    'QA' => 1,
    'TN' => 1,
    'IR' => 2,
    'IQ' => 1,
    'AE' => 1,
    'SO' => 1,
    'SY' => 1,
    'PS' => 1,
    'BH' => 1,
    'JO' => 1,
    'KW' => 1,
    'DJ' => 1,
    'MR' => 1
  },
  'kir' => {
    'KG' => 1
  },
  'kha' => {
    'IN' => 2
  },
  'mad' => {
    'ID' => 2
  },
  'nob' => {
    'NO' => 1,
    'SJ' => 1
  },
  'fvr' => {
    'SD' => 2
  },
  'hoj' => {
    'IN' => 2
  },
  'raj' => {
    'IN' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'bak' => {
    'RU' => 2
  },
  'run' => {
    'BI' => 1
  },
  'aze' => {
    'AZ' => 1,
    'RU' => 2,
    'IR' => 2,
    'IQ' => 2
  },
  'bos' => {
    'BA' => 1
  },
  'luo' => {
    'KE' => 2
  },
  'sqi' => {
    'MK' => 2,
    'XK' => 1,
    'RS' => 2,
    'AL' => 1
  },
  'kok' => {
    'IN' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'che' => {
    'RU' => 2
  },
  'tel' => {
    'IN' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'gil' => {
    'KI' => 1
  },
  'ary' => {
    'MA' => 2
  },
  'ukr' => {
    'UA' => 1,
    'RS' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'seh' => {
    'MZ' => 2
  },
  'gon' => {
    'IN' => 2
  },
  'nds' => {
    'NL' => 2,
    'DE' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'sat' => {
    'IN' => 2
  },
  'sqq' => {
    'TH' => 2
  },
  'kaz' => {
    'CN' => 2,
    'KZ' => 1
  },
  'tso' => {
    'MZ' => 2,
    'ZA' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'uig' => {
    'CN' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'tsn' => {
    'BW' => 1,
    'ZA' => 2
  },
  'hun' => {
    'HU' => 1,
    'RS' => 2,
    'AT' => 2,
    'RO' => 2
  },
  'bho' => {
    'MU' => 2,
    'NP' => 2,
    'IN' => 2
  },
  'kfy' => {
    'IN' => 2
  },
  'ita' => {
    'FR' => 2,
    'HR' => 2,
    'US' => 2,
    'CH' => 1,
    'DE' => 2,
    'MT' => 2,
    'SM' => 1,
    'IT' => 1,
    'VA' => 1
  },
  'hsn' => {
    'CN' => 2
  },
  'syl' => {
    'BD' => 2
  },
  'fas' => {
    'PK' => 2,
    'IR' => 1,
    'AF' => 1
  },
  'tat' => {
    'RU' => 2
  },
  'mni' => {
    'IN' => 2
  },
  'dan' => {
    'DE' => 2,
    'DK' => 1
  },
  'dje' => {
    'NE' => 2
  },
  'min' => {
    'ID' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'sef' => {
    'CI' => 2
  },
  'bar' => {
    'AT' => 2,
    'DE' => 2
  },
  'kor' => {
    'KR' => 1,
    'KP' => 1,
    'CN' => 2,
    'US' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'man' => {
    'GM' => 2,
    'GN' => 2
  },
  'kik' => {
    'KE' => 2
  },
  'sme' => {
    'NO' => 2
  },
  'bis' => {
    'VU' => 1
  },
  'oss' => {
    'GE' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'bew' => {
    'ID' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'bug' => {
    'ID' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'laj' => {
    'UG' => 2
  },
  'lat' => {
    'VA' => 2
  },
  'war' => {
    'PH' => 2
  },
  'ltz' => {
    'LU' => 1
  },
  'khn' => {
    'IN' => 2
  },
  'kbd' => {
    'RU' => 2
  },
  'mfe' => {
    'MU' => 2
  },
  'bjn' => {
    'ID' => 2
  },
  'mlt' => {
    'MT' => 1
  },
  'fuv' => {
    'NG' => 2
  },
  'mnu' => {
    'KE' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'gan' => {
    'CN' => 2
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'sot' => {
    'LS' => 1,
    'ZA' => 2
  },
  'pap' => {
    'AW' => 1,
    'CW' => 1,
    'BQ' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'ewe' => {
    'TG' => 2,
    'GH' => 2
  },
  'yue' => {
    'CN' => 2,
    'HK' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'udm' => {
    'RU' => 2
  },
  'nym' => {
    'TZ' => 2
  },
  'pan' => {
    'IN' => 2,
    'PK' => 2
  },
  'mya' => {
    'MM' => 1
  },
  'sah' => {
    'RU' => 2
  },
  'nor' => {
    'NO' => 1,
    'SJ' => 1
  },
  'spa' => {
    'SV' => 1,
    'HN' => 1,
    'DE' => 2,
    'US' => 2,
    'PA' => 1,
    'ES' => 1,
    'CO' => 1,
    'CR' => 1,
    'EC' => 1,
    'VE' => 1,
    'AR' => 1,
    'DO' => 1,
    'EA' => 1,
    'RO' => 2,
    'CU' => 1,
    'BO' => 1,
    'NI' => 1,
    'PR' => 1,
    'PY' => 1,
    'UY' => 1,
    'GI' => 2,
    'GQ' => 1,
    'FR' => 2,
    'GT' => 1,
    'BZ' => 2,
    'PT' => 2,
    'IC' => 1,
    'PH' => 2,
    'CL' => 1,
    'MX' => 1,
    'PE' => 1,
    'AD' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'kur' => {
    'IR' => 2,
    'TR' => 2,
    'SY' => 2,
    'IQ' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'kab' => {
    'DZ' => 2
  },
  'pol' => {
    'UA' => 2,
    'PL' => 1
  },
  'mzn' => {
    'IR' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'ton' => {
    'TO' => 1
  },
  'hil' => {
    'PH' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'inh' => {
    'RU' => 2
  },
  'fry' => {
    'NL' => 2
  },
  'swa' => {
    'UG' => 1,
    'CD' => 2,
    'TZ' => 1,
    'KE' => 1
  },
  'nno' => {
    'NO' => 1
  },
  'mdh' => {
    'PH' => 2
  },
  'sck' => {
    'IN' => 2
  },
  'hif' => {
    'FJ' => 1
  },
  'eus' => {
    'ES' => 2
  },
  'yor' => {
    'NG' => 1
  },
  'lao' => {
    'LA' => 1
  },
  'msa' => {
    'BN' => 1,
    'MY' => 1,
    'SG' => 1,
    'ID' => 2,
    'CC' => 2,
    'TH' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'zul' => {
    'ZA' => 2
  },
  'rkt' => {
    'BD' => 2,
    'IN' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'gbm' => {
    'IN' => 2
  },
  'san' => {
    'IN' => 2
  },
  'fra' => {
    'MF' => 1,
    'ML' => 1,
    'MA' => 1,
    'GP' => 1,
    'GQ' => 1,
    'FR' => 1,
    'BL' => 1,
    'PM' => 1,
    'NC' => 1,
    'KM' => 1,
    'BF' => 1,
    'CA' => 1,
    'LU' => 1,
    'CD' => 1,
    'YT' => 1,
    'RW' => 1,
    'CF' => 1,
    'CG' => 1,
    'MQ' => 1,
    'DJ' => 1,
    'RE' => 1,
    'GA' => 1,
    'NE' => 1,
    'BJ' => 1,
    'CH' => 1,
    'US' => 2,
    'GF' => 1,
    'SY' => 1,
    'RO' => 2,
    'HT' => 1,
    'IT' => 2,
    'BI' => 1,
    'TN' => 1,
    'MG' => 1,
    'CI' => 1,
    'WF' => 1,
    'GB' => 2,
    'MC' => 1,
    'PT' => 2,
    'TF' => 2,
    'DZ' => 1,
    'TD' => 1,
    'SC' => 1,
    'NL' => 2,
    'GN' => 1,
    'VU' => 1,
    'CM' => 1,
    'BE' => 1,
    'DE' => 2,
    'PF' => 1,
    'MU' => 1,
    'TG' => 1,
    'SN' => 1
  },
  'kom' => {
    'RU' => 2
  },
  'bam' => {
    'ML' => 2
  },
  'rej' => {
    'ID' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'aym' => {
    'BO' => 1
  },
  'noe' => {
    'IN' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'iii' => {
    'CN' => 2
  },
  'ach' => {
    'UG' => 2
  },
  'vls' => {
    'BE' => 2
  },
  'nbl' => {
    'ZA' => 2
  },
  'hne' => {
    'IN' => 2
  },
  'ron' => {
    'MD' => 1,
    'RS' => 2,
    'RO' => 1
  },
  'jav' => {
    'ID' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'bgc' => {
    'IN' => 2
  },
  'rif' => {
    'MA' => 2
  },
  'tvl' => {
    'TV' => 1
  },
  'lah' => {
    'PK' => 2
  },
  'shr' => {
    'MA' => 2
  },
  'uzb' => {
    'UZ' => 1,
    'AF' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'buc' => {
    'YT' => 2
  },
  'ibo' => {
    'NG' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'fuq' => {
    'NE' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'bsc' => {
    'SN' => 2
  },
  'aeb' => {
    'TN' => 2
  },
  'zgh' => {
    'MA' => 2
  },
  'kde' => {
    'TZ' => 2
  },
  'snk' => {
    'ML' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'myx' => {
    'UG' => 2
  },
  'hin' => {
    'IN' => 1,
    'FJ' => 2,
    'ZA' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'gqr' => {
    'ID' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'crs' => {
    'SC' => 2
  },
  'mfv' => {
    'SN' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'und' => {
    'CP' => 2,
    'BV' => 2,
    'HM' => 2,
    'GS' => 2,
    'AQ' => 2
  },
  'bjt' => {
    'SN' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'ttb' => {
    'GH' => 2
  },
  'tah' => {
    'PF' => 1
  },
  'tet' => {
    'TL' => 1
  },
  'tnr' => {
    'SN' => 2
  },
  'men' => {
    'SL' => 2
  },
  'sid' => {
    'ET' => 2
  },
  'wuu' => {
    'CN' => 2
  },
  'hbs' => {
    'HR' => 1,
    'BA' => 1,
    'SI' => 2,
    'RS' => 1,
    'XK' => 1,
    'ME' => 1,
    'AT' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'lin' => {
    'CD' => 2
  },
  'dzo' => {
    'BT' => 1
  },
  'mdf' => {
    'RU' => 2
  },
  'brx' => {
    'IN' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'ind' => {
    'ID' => 1
  },
  'hrv' => {
    'BA' => 1,
    'HR' => 1,
    'RS' => 2,
    'SI' => 2,
    'AT' => 2
  },
  'cat' => {
    'AD' => 1,
    'ES' => 2
  },
  'brh' => {
    'PK' => 2
  }
};
$Lang2Script = {
  'bbj' => {
    'Latn' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'ind' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'men' => {
    'Latn' => 1,
    'Mend' => 2
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'jml' => {
    'Deva' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'xsa' => {
    'Sarb' => 2
  },
  'mtr' => {
    'Deva' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'kht' => {
    'Mymr' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'lwl' => {
    'Thai' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'gqr' => {
    'Latn' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'cop' => {
    'Grek' => 2,
    'Arab' => 2,
    'Copt' => 2
  },
  'fuq' => {
    'Latn' => 1
  },
  'atj' => {
    'Latn' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'shr' => {
    'Arab' => 1,
    'Latn' => 1,
    'Tfng' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'bez' => {
    'Latn' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'rif' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'jav' => {
    'Java' => 2,
    'Latn' => 1
  },
  'srb' => {
    'Sora' => 2,
    'Latn' => 1
  },
  'ach' => {
    'Latn' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'kom' => {
    'Cyrl' => 1,
    'Perm' => 2
  },
  'gbm' => {
    'Deva' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'rkt' => {
    'Beng' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'fro' => {
    'Latn' => 2
  },
  'bra' => {
    'Deva' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'msa' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'inh' => {
    'Latn' => 2,
    'Cyrl' => 1,
    'Arab' => 2
  },
  'zap' => {
    'Latn' => 1
  },
  'yor' => {
    'Latn' => 1
  },
  'hif' => {
    'Deva' => 1,
    'Latn' => 1
  },
  'sck' => {
    'Deva' => 1
  },
  'mdh' => {
    'Latn' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'unx' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'udm' => {
    'Cyrl' => 1,
    'Latn' => 2
  },
  'aoz' => {
    'Latn' => 1
  },
  'pan' => {
    'Guru' => 1,
    'Arab' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'nym' => {
    'Latn' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'was' => {
    'Latn' => 1
  },
  'yue' => {
    'Hans' => 1,
    'Hant' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'sot' => {
    'Latn' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'war' => {
    'Latn' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'rap' => {
    'Latn' => 1
  },
  'ssy' => {
    'Latn' => 1
  },
  'fuv' => {
    'Latn' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'lrc' => {
    'Arab' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'amo' => {
    'Latn' => 1
  },
  'bis' => {
    'Latn' => 1
  },
  'sme' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'sly' => {
    'Latn' => 1
  },
  'pms' => {
    'Latn' => 1
  },
  'urd' => {
    'Arab' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'kor' => {
    'Kore' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'mni' => {
    'Mtei' => 2,
    'Beng' => 1
  },
  'fas' => {
    'Arab' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'osc' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'nus' => {
    'Latn' => 1
  },
  'hun' => {
    'Latn' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'taj' => {
    'Deva' => 1,
    'Tibt' => 2
  },
  'sel' => {
    'Cyrl' => 2
  },
  'kvr' => {
    'Latn' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'vie' => {
    'Latn' => 1,
    'Hani' => 2
  },
  'tso' => {
    'Latn' => 1
  },
  'ett' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'sqq' => {
    'Thai' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'nzi' => {
    'Latn' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'gon' => {
    'Telu' => 1,
    'Deva' => 1
  },
  'ary' => {
    'Arab' => 1
  },
  'gil' => {
    'Latn' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'bos' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'run' => {
    'Latn' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'stq' => {
    'Latn' => 1
  },
  'bfd' => {
    'Latn' => 1
  },
  'kha' => {
    'Beng' => 2,
    'Latn' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'kir' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'lua' => {
    'Latn' => 1
  },
  'nsk' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'maf' => {
    'Latn' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'kiu' => {
    'Latn' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'bem' => {
    'Latn' => 1
  },
  'mon' => {
    'Cyrl' => 1,
    'Mong' => 2,
    'Phag' => 2
  },
  'vic' => {
    'Latn' => 1
  },
  'amh' => {
    'Ethi' => 1
  },
  'chu' => {
    'Cyrl' => 2
  },
  'tsd' => {
    'Grek' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'srp' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'ava' => {
    'Cyrl' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'snd' => {
    'Sind' => 2,
    'Arab' => 1,
    'Khoj' => 2,
    'Deva' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'arg' => {
    'Latn' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'hau' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'kdh' => {
    'Latn' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'nod' => {
    'Lana' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'hnn' => {
    'Latn' => 1,
    'Hano' => 2
  },
  'ain' => {
    'Latn' => 2,
    'Kana' => 2
  },
  'grn' => {
    'Latn' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'chp' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'mxc' => {
    'Latn' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'lfn' => {
    'Latn' => 2,
    'Cyrl' => 2
  },
  'xsr' => {
    'Deva' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'tdg' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'ful' => {
    'Adlm' => 2,
    'Latn' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'pau' => {
    'Latn' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'rar' => {
    'Latn' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'tum' => {
    'Latn' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'bzx' => {
    'Latn' => 1
  },
  'kln' => {
    'Latn' => 1
  },
  'yao' => {
    'Latn' => 1
  },
  'crl' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'unr' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'rug' => {
    'Latn' => 1
  },
  'arz' => {
    'Arab' => 1
  },
  'kon' => {
    'Latn' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'lag' => {
    'Latn' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'btv' => {
    'Deva' => 1
  },
  'aln' => {
    'Latn' => 1
  },
  'xpr' => {
    'Prti' => 2
  },
  'sdc' => {
    'Latn' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'tur' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'pmn' => {
    'Latn' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'mai' => {
    'Deva' => 1,
    'Tirh' => 2
  },
  'lab' => {
    'Lina' => 2
  },
  'jut' => {
    'Latn' => 2
  },
  'crj' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'zho' => {
    'Hans' => 1,
    'Hant' => 1,
    'Bopo' => 2,
    'Phag' => 2
  },
  'glg' => {
    'Latn' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'uga' => {
    'Ugar' => 2
  },
  'nyn' => {
    'Latn' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'tkr' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'grt' => {
    'Beng' => 1
  },
  'khq' => {
    'Latn' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'lcp' => {
    'Thai' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'ori' => {
    'Orya' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'kin' => {
    'Latn' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'puu' => {
    'Latn' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'pli' => {
    'Deva' => 2,
    'Sinh' => 2,
    'Thai' => 2
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'mak' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'srx' => {
    'Deva' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'som' => {
    'Osma' => 2,
    'Arab' => 2,
    'Latn' => 1
  },
  'hmn' => {
    'Latn' => 1,
    'Hmng' => 2,
    'Laoo' => 1,
    'Plrd' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'pag' => {
    'Latn' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'doi' => {
    'Arab' => 1,
    'Takr' => 2,
    'Deva' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'ibb' => {
    'Latn' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'pnt' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Grek' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'gba' => {
    'Latn' => 1
  },
  'nld' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'bku' => {
    'Buhd' => 2,
    'Latn' => 1
  },
  'brh' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'cat' => {
    'Latn' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'hrv' => {
    'Latn' => 1
  },
  'mri' => {
    'Latn' => 1
  },
  'grc' => {
    'Cprt' => 2,
    'Linb' => 2,
    'Grek' => 2
  },
  'sid' => {
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'hbs' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'ttb' => {
    'Latn' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'den' => {
    'Latn' => 1,
    'Cans' => 2
  },
  'aar' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'ltg' => {
    'Latn' => 1
  },
  'bjj' => {
    'Deva' => 1
  },
  'avk' => {
    'Latn' => 2
  },
  'aii' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'rtm' => {
    'Latn' => 1
  },
  'hin' => {
    'Deva' => 1,
    'Latn' => 2,
    'Mahj' => 2
  },
  'myx' => {
    'Latn' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'zgh' => {
    'Tfng' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'zza' => {
    'Latn' => 1
  },
  'bft' => {
    'Tibt' => 2,
    'Arab' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'tsj' => {
    'Tibt' => 1
  },
  'cre' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'lah' => {
    'Arab' => 1
  },
  'tvl' => {
    'Latn' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'nnh' => {
    'Latn' => 1
  },
  'uzb' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'ron' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'ina' => {
    'Latn' => 2
  },
  'wbp' => {
    'Latn' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'kyu' => {
    'Kali' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'crk' => {
    'Cans' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'cjm' => {
    'Cham' => 1,
    'Arab' => 2
  },
  'vls' => {
    'Latn' => 1
  },
  'aym' => {
    'Latn' => 1
  },
  'rej' => {
    'Latn' => 1,
    'Rjng' => 2
  },
  'zea' => {
    'Latn' => 1
  },
  'bam' => {
    'Nkoo' => 1,
    'Latn' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'fra' => {
    'Latn' => 1,
    'Dupl' => 2
  },
  'san' => {
    'Sinh' => 2,
    'Sidd' => 2,
    'Gran' => 2,
    'Shrd' => 2,
    'Deva' => 2
  },
  'mua' => {
    'Latn' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'thq' => {
    'Deva' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'swa' => {
    'Latn' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'vmf' => {
    'Latn' => 1
  },
  'lao' => {
    'Laoo' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'bto' => {
    'Latn' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'dyo' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'ipk' => {
    'Latn' => 1
  },
  'ave' => {
    'Avst' => 2
  },
  'hil' => {
    'Latn' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'kur' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'lit' => {
    'Latn' => 1
  },
  'mnu' => {
    'Latn' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'kum' => {
    'Cyrl' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'bug' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'tdd' => {
    'Tale' => 1
  },
  'ale' => {
    'Latn' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'kik' => {
    'Latn' => 1
  },
  'bew' => {
    'Latn' => 1
  },
  'tru' => {
    'Latn' => 1,
    'Syrc' => 2
  },
  'wae' => {
    'Latn' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'gju' => {
    'Arab' => 1
  },
  'man' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'syl' => {
    'Beng' => 1,
    'Sylo' => 2
  },
  'byv' => {
    'Latn' => 1
  },
  'hsn' => {
    'Hans' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'bub' => {
    'Cyrl' => 1
  },
  'kfy' => {
    'Deva' => 1
  },
  'sga' => {
    'Ogam' => 2,
    'Latn' => 2
  },
  'ude' => {
    'Cyrl' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'pko' => {
    'Latn' => 1
  },
  'tly' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'uig' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 2
  },
  'gay' => {
    'Latn' => 1
  },
  'nov' => {
    'Latn' => 2
  },
  'mdt' => {
    'Latn' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'cay' => {
    'Latn' => 1
  },
  'kaz' => {
    'Arab' => 1,
    'Cyrl' => 1
  },
  'vai' => {
    'Latn' => 1,
    'Vaii' => 1
  },
  'mgp' => {
    'Deva' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'moh' => {
    'Latn' => 1
  },
  'iku' => {
    'Latn' => 1,
    'Cans' => 1
  },
  'sat' => {
    'Beng' => 2,
    'Olck' => 1,
    'Latn' => 2,
    'Deva' => 2,
    'Orya' => 2
  },
  'anp' => {
    'Deva' => 1
  },
  'sun' => {
    'Latn' => 1,
    'Sund' => 2
  },
  'frp' => {
    'Latn' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'xnr' => {
    'Deva' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'luo' => {
    'Latn' => 1
  },
  'sqi' => {
    'Elba' => 2,
    'Latn' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'aze' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'kas' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'sxn' => {
    'Latn' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'fvr' => {
    'Latn' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'kca' => {
    'Cyrl' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'dtm' => {
    'Latn' => 1
  },
  'nde' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'frr' => {
    'Latn' => 1
  },
  'egy' => {
    'Egyp' => 2
  },
  'tir' => {
    'Ethi' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'crh' => {
    'Cyrl' => 1
  },
  'wln' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'kcg' => {
    'Latn' => 1
  },
  'kdx' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'gag' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'myz' => {
    'Mand' => 2
  },
  'fit' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'enm' => {
    'Latn' => 2
  },
  'guz' => {
    'Latn' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'tzm' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'deu' => {
    'Runr' => 2,
    'Latn' => 1
  },
  'ccp' => {
    'Beng' => 1,
    'Cakm' => 1
  },
  'ttt' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 2
  },
  'byn' => {
    'Ethi' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'ttj' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'bqi' => {
    'Arab' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'afr' => {
    'Latn' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'phn' => {
    'Phnx' => 2
  },
  'hai' => {
    'Latn' => 1
  },
  'thl' => {
    'Deva' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'bmq' => {
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'jgo' => {
    'Latn' => 1
  },
  'oci' => {
    'Latn' => 1
  },
  'mrd' => {
    'Deva' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'eng' => {
    'Latn' => 1,
    'Shaw' => 2,
    'Dsrt' => 2
  },
  'kaj' => {
    'Latn' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'kjg' => {
    'Laoo' => 1,
    'Latn' => 2
  },
  'glk' => {
    'Arab' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'kat' => {
    'Geor' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'non' => {
    'Runr' => 2
  },
  'ssw' => {
    'Latn' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'orm' => {
    'Ethi' => 2,
    'Latn' => 1
  },
  'snx' => {
    'Hebr' => 2,
    'Samr' => 2
  },
  'ven' => {
    'Latn' => 1
  },
  'ikt' => {
    'Latn' => 1
  },
  'sas' => {
    'Latn' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'mdr' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'dty' => {
    'Deva' => 1
  },
  'kri' => {
    'Latn' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'rcf' => {
    'Latn' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'xav' => {
    'Latn' => 1
  },
  'mro' => {
    'Latn' => 1,
    'Mroo' => 2
  },
  'mwv' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'ban' => {
    'Latn' => 1,
    'Bali' => 2
  },
  'qug' => {
    'Latn' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'lmo' => {
    'Latn' => 1
  },
  'swg' => {
    'Latn' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'bfq' => {
    'Taml' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'kmb' => {
    'Latn' => 1
  },
  'dsb' => {
    'Latn' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'slk' => {
    'Latn' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'fin' => {
    'Latn' => 1
  },
  'mas' => {
    'Latn' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'liv' => {
    'Latn' => 2
  },
  'lui' => {
    'Latn' => 2
  },
  'ndo' => {
    'Latn' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'wbr' => {
    'Deva' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'zha' => {
    'Hans' => 2,
    'Latn' => 1
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'lez' => {
    'Cyrl' => 1,
    'Aghb' => 2
  },
  'vmw' => {
    'Latn' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'bbc' => {
    'Batk' => 2,
    'Latn' => 1
  },
  'swb' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'car' => {
    'Latn' => 1
  },
  'wol' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'lki' => {
    'Arab' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'xum' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'srd' => {
    'Latn' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'abw' => {
    'Phlp' => 2,
    'Phli' => 2
  },
  'kgp' => {
    'Latn' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'cho' => {
    'Latn' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'maz' => {
    'Latn' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'arc' => {
    'Palm' => 2,
    'Nbat' => 2,
    'Armi' => 2
  },
  'bhi' => {
    'Deva' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'tgk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'lzz' => {
    'Latn' => 1,
    'Geor' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'bal' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'skr' => {
    'Arab' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'syr' => {
    'Syrc' => 2,
    'Cyrl' => 1
  },
  'tuk' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'fil' => {
    'Latn' => 1,
    'Tglg' => 2
  },
  'kan' => {
    'Knda' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'lim' => {
    'Latn' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'osa' => {
    'Latn' => 2,
    'Osge' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'yap' => {
    'Latn' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'fia' => {
    'Arab' => 1
  },
  'rom' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'cja' => {
    'Arab' => 1,
    'Cham' => 2
  },
  'sus' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'kkt' => {
    'Cyrl' => 1
  },
  'tog' => {
    'Latn' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'kax' => {
    'Latn' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'jpn' => {
    'Jpan' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'fao' => {
    'Latn' => 1
  },
  'bmv' => {
    'Latn' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'sei' => {
    'Latn' => 1
  }
};
$Territory2Lang = {
  'FJ' => {
    'fij' => 1,
    'hin' => 2,
    'hif' => 1,
    'eng' => 1
  },
  'SX' => {
    'eng' => 1,
    'nld' => 1
  },
  'KG' => {
    'rus' => 1,
    'kir' => 1
  },
  'GM' => {
    'man' => 2,
    'eng' => 1
  },
  'GN' => {
    'sus' => 2,
    'ful' => 2,
    'fra' => 1,
    'man' => 2
  },
  'PH' => {
    'tsg' => 2,
    'spa' => 2,
    'ceb' => 2,
    'mdh' => 2,
    'eng' => 1,
    'pag' => 2,
    'war' => 2,
    'ilo' => 2,
    'hil' => 2,
    'pmn' => 2,
    'fil' => 1,
    'bik' => 2,
    'bhk' => 2
  },
  'SZ' => {
    'ssw' => 1,
    'eng' => 1
  },
  'CK' => {
    'eng' => 1
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'SC' => {
    'eng' => 1,
    'crs' => 2,
    'fra' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'FI' => {
    'fin' => 1,
    'swe' => 1,
    'eng' => 2
  },
  'SS' => {
    'eng' => 1,
    'ara' => 2
  },
  'HU' => {
    'eng' => 2,
    'deu' => 2,
    'hun' => 1
  },
  'JE' => {
    'eng' => 1
  },
  'NP' => {
    'nep' => 1,
    'mai' => 2,
    'bho' => 2
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'BR' => {
    'por' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'BB' => {
    'eng' => 1
  },
  'CV' => {
    'kea' => 2,
    'por' => 1
  },
  'SE' => {
    'eng' => 2,
    'swe' => 1,
    'fin' => 2
  },
  'PA' => {
    'spa' => 1
  },
  'MR' => {
    'ara' => 1
  },
  'AM' => {
    'hye' => 1
  },
  'DM' => {
    'eng' => 1
  },
  'UA' => {
    'pol' => 2,
    'ukr' => 1,
    'rus' => 1
  },
  'IM' => {
    'eng' => 1,
    'glv' => 1
  },
  'JO' => {
    'ara' => 1,
    'eng' => 2
  },
  'IN' => {
    'hoj' => 2,
    'raj' => 2,
    'asm' => 2,
    'tcy' => 2,
    'kha' => 2,
    'mal' => 2,
    'hin' => 1,
    'mai' => 2,
    'urd' => 2,
    'ben' => 2,
    'tam' => 2,
    'sck' => 2,
    'kok' => 2,
    'kas' => 2,
    'doi' => 2,
    'bgc' => 2,
    'wtm' => 2,
    'pan' => 2,
    'ori' => 2,
    'kfy' => 2,
    'hne' => 2,
    'bho' => 2,
    'unr' => 2,
    'bhb' => 2,
    'lmn' => 2,
    'mag' => 2,
    'mni' => 2,
    'noe' => 2,
    'mwr' => 2,
    'dcc' => 2,
    'kru' => 2,
    'hoc' => 2,
    'mar' => 2,
    'snd' => 2,
    'guj' => 2,
    'bhi' => 2,
    'brx' => 2,
    'awa' => 2,
    'swv' => 2,
    'gom' => 2,
    'bjj' => 2,
    'kan' => 2,
    'tel' => 2,
    'wbr' => 2,
    'xnr' => 2,
    'sat' => 2,
    'gon' => 2,
    'khn' => 2,
    'eng' => 1,
    'san' => 2,
    'wbq' => 2,
    'mtr' => 2,
    'rkt' => 2,
    'gbm' => 2,
    'nep' => 2
  },
  'SO' => {
    'som' => 1,
    'ara' => 1
  },
  'XK' => {
    'sqi' => 1,
    'hbs' => 1,
    'aln' => 2,
    'srp' => 1
  },
  'RS' => {
    'ukr' => 2,
    'ron' => 2,
    'hrv' => 2,
    'slk' => 2,
    'hbs' => 1,
    'srp' => 1,
    'hun' => 2,
    'sqi' => 2
  },
  'TK' => {
    'tkl' => 1,
    'eng' => 1
  },
  'BD' => {
    'rkt' => 2,
    'syl' => 2,
    'eng' => 2,
    'ben' => 1
  },
  'CF' => {
    'sag' => 1,
    'fra' => 1
  },
  'PE' => {
    'spa' => 1,
    'que' => 1
  },
  'RW' => {
    'eng' => 1,
    'fra' => 1,
    'kin' => 1
  },
  'CL' => {
    'spa' => 1,
    'eng' => 2
  },
  'LV' => {
    'rus' => 2,
    'eng' => 2,
    'lav' => 1
  },
  'YT' => {
    'buc' => 2,
    'fra' => 1,
    'swb' => 2
  },
  'MD' => {
    'ron' => 1
  },
  'SA' => {
    'ara' => 1
  },
  'FR' => {
    'fra' => 1,
    'ita' => 2,
    'deu' => 2,
    'eng' => 2,
    'oci' => 2,
    'spa' => 2
  },
  'GP' => {
    'fra' => 1
  },
  'BI' => {
    'eng' => 1,
    'run' => 1,
    'fra' => 1
  },
  'BQ' => {
    'nld' => 1,
    'pap' => 2
  },
  'RO' => {
    'eng' => 2,
    'spa' => 2,
    'fra' => 2,
    'hun' => 2,
    'ron' => 1
  },
  'BY' => {
    'rus' => 1,
    'bel' => 1
  },
  'VG' => {
    'eng' => 1
  },
  'BT' => {
    'dzo' => 1
  },
  'SH' => {
    'eng' => 1
  },
  'UZ' => {
    'uzb' => 1,
    'rus' => 2
  },
  'RU' => {
    'che' => 2,
    'udm' => 2,
    'rus' => 1,
    'myv' => 2,
    'chv' => 2,
    'tat' => 2,
    'kom' => 2,
    'kbd' => 2,
    'ady' => 2,
    'sah' => 2,
    'krc' => 2,
    'kum' => 2,
    'kkt' => 2,
    'lbe' => 2,
    'aze' => 2,
    'bak' => 2,
    'inh' => 2,
    'lez' => 2,
    'mdf' => 2,
    'hye' => 2,
    'ava' => 2,
    'tyv' => 2
  },
  'MY' => {
    'msa' => 1,
    'zho' => 2,
    'tam' => 2,
    'eng' => 2
  },
  'PW' => {
    'eng' => 1,
    'pau' => 1
  },
  'RE' => {
    'rcf' => 2,
    'fra' => 1
  },
  'LK' => {
    'eng' => 2,
    'tam' => 1,
    'sin' => 1
  },
  'MQ' => {
    'fra' => 1
  },
  'CG' => {
    'fra' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'US' => {
    'haw' => 2,
    'deu' => 2,
    'ita' => 2,
    'spa' => 2,
    'zho' => 2,
    'fra' => 2,
    'vie' => 2,
    'eng' => 1,
    'fil' => 2,
    'kor' => 2
  },
  'BJ' => {
    'fra' => 1,
    'fon' => 2
  },
  'MT' => {
    'mlt' => 1,
    'ita' => 2,
    'eng' => 1
  },
  'TV' => {
    'eng' => 1,
    'tvl' => 1
  },
  'CW' => {
    'pap' => 1,
    'nld' => 1
  },
  'PG' => {
    'eng' => 1,
    'tpi' => 1,
    'hmo' => 1
  },
  'SK' => {
    'slk' => 1,
    'deu' => 2,
    'eng' => 2,
    'ces' => 2
  },
  'UG' => {
    'nyn' => 2,
    'laj' => 2,
    'lug' => 2,
    'myx' => 2,
    'cgg' => 2,
    'teo' => 2,
    'ach' => 2,
    'xog' => 2,
    'eng' => 1,
    'swa' => 1
  },
  'ER' => {
    'tir' => 1,
    'eng' => 1,
    'tig' => 2,
    'ara' => 1
  },
  'KH' => {
    'khm' => 1
  },
  'CC' => {
    'eng' => 1,
    'msa' => 2
  },
  'GB' => {
    'gla' => 2,
    'sco' => 2,
    'deu' => 2,
    'gle' => 2,
    'cym' => 2,
    'eng' => 1,
    'fra' => 2
  },
  'OM' => {
    'ara' => 1
  },
  'HK' => {
    'yue' => 2,
    'zho' => 1,
    'eng' => 1
  },
  'CX' => {
    'eng' => 1
  },
  'TA' => {
    'eng' => 2
  },
  'CZ' => {
    'deu' => 2,
    'slk' => 2,
    'ces' => 1,
    'eng' => 2
  },
  'GR' => {
    'eng' => 2,
    'ell' => 1
  },
  'VC' => {
    'eng' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'CU' => {
    'spa' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'MN' => {
    'mon' => 1
  },
  'TH' => {
    'tts' => 2,
    'eng' => 2,
    'msa' => 2,
    'sqq' => 2,
    'zho' => 2,
    'mfa' => 2,
    'kxm' => 2,
    'nod' => 2,
    'tha' => 1
  },
  'MM' => {
    'shn' => 2,
    'mya' => 1
  },
  'AR' => {
    'spa' => 1,
    'eng' => 2
  },
  'VE' => {
    'spa' => 1
  },
  'IR' => {
    'glk' => 2,
    'kur' => 2,
    'fas' => 1,
    'tuk' => 2,
    'aze' => 2,
    'luz' => 2,
    'rmt' => 2,
    'ckb' => 2,
    'bqi' => 2,
    'mzn' => 2,
    'ara' => 2,
    'sdh' => 2,
    'bal' => 2,
    'lrc' => 2
  },
  'CO' => {
    'spa' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'VU' => {
    'fra' => 1,
    'bis' => 1,
    'eng' => 1
  },
  'PF' => {
    'fra' => 1,
    'tah' => 1
  },
  'SV' => {
    'spa' => 1
  },
  'BM' => {
    'eng' => 1
  },
  'PL' => {
    'pol' => 1,
    'deu' => 2,
    'csb' => 2,
    'lit' => 2,
    'eng' => 2,
    'rus' => 2
  },
  'LU' => {
    'eng' => 2,
    'ltz' => 1,
    'fra' => 1,
    'deu' => 1
  },
  'FM' => {
    'eng' => 1,
    'pon' => 2,
    'chk' => 2
  },
  'ZM' => {
    'bem' => 2,
    'nya' => 2,
    'eng' => 1
  },
  'CA' => {
    'iku' => 2,
    'ikt' => 2,
    'fra' => 1,
    'eng' => 1
  },
  'ET' => {
    'amh' => 1,
    'orm' => 2,
    'tir' => 2,
    'som' => 2,
    'wal' => 2,
    'aar' => 2,
    'eng' => 2,
    'sid' => 2
  },
  'AD' => {
    'cat' => 1,
    'spa' => 2
  },
  'KE' => {
    'kln' => 2,
    'kdx' => 2,
    'guz' => 2,
    'luo' => 2,
    'luy' => 2,
    'eng' => 1,
    'swa' => 1,
    'kik' => 2,
    'mnu' => 2
  },
  'ID' => {
    'ljp' => 2,
    'ban' => 2,
    'min' => 2,
    'bew' => 2,
    'sun' => 2,
    'ind' => 1,
    'bbc' => 2,
    'bjn' => 2,
    'ace' => 2,
    'gqr' => 2,
    'sas' => 2,
    'bug' => 2,
    'msa' => 2,
    'rej' => 2,
    'zho' => 2,
    'jav' => 2,
    'mak' => 2,
    'mad' => 2
  },
  'TZ' => {
    'swa' => 1,
    'eng' => 1,
    'suk' => 2,
    'kde' => 2,
    'nym' => 2
  },
  'QA' => {
    'ara' => 1
  },
  'GT' => {
    'spa' => 1,
    'quc' => 2
  },
  'VA' => {
    'ita' => 1,
    'lat' => 2
  },
  'TW' => {
    'zho' => 1
  },
  'SL' => {
    'kri' => 2,
    'men' => 2,
    'eng' => 1,
    'kdh' => 2
  },
  'GQ' => {
    'por' => 1,
    'spa' => 1,
    'fan' => 2,
    'fra' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'GI' => {
    'spa' => 2,
    'eng' => 1
  },
  'GY' => {
    'eng' => 1
  },
  'PK' => {
    'snd' => 2,
    'brh' => 2,
    'urd' => 1,
    'pus' => 2,
    'fas' => 2,
    'lah' => 2,
    'eng' => 1,
    'bgn' => 2,
    'pan' => 2,
    'skr' => 2,
    'hno' => 2,
    'bal' => 2
  },
  'SG' => {
    'tam' => 1,
    'eng' => 1,
    'msa' => 1,
    'zho' => 1
  },
  'IT' => {
    'eng' => 2,
    'srd' => 2,
    'ita' => 1,
    'fra' => 2
  },
  'AT' => {
    'slv' => 2,
    'eng' => 2,
    'hbs' => 2,
    'hun' => 2,
    'bar' => 2,
    'hrv' => 2,
    'deu' => 1
  },
  'NR' => {
    'eng' => 1,
    'nau' => 1
  },
  'IQ' => {
    'aze' => 2,
    'ara' => 1,
    'kur' => 2,
    'ckb' => 2,
    'eng' => 2
  },
  'KZ' => {
    'rus' => 1,
    'eng' => 2,
    'kaz' => 1,
    'deu' => 2
  },
  'LC' => {
    'eng' => 1
  },
  'LS' => {
    'sot' => 1,
    'eng' => 1
  },
  'AQ' => {
    'und' => 2
  },
  'AI' => {
    'eng' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'DJ' => {
    'som' => 2,
    'aar' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'MP' => {
    'eng' => 1
  },
  'TO' => {
    'ton' => 1,
    'eng' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'CH' => {
    'ita' => 1,
    'deu' => 1,
    'gsw' => 1,
    'fra' => 1,
    'roh' => 2,
    'eng' => 2
  },
  'AW' => {
    'pap' => 1,
    'nld' => 1
  },
  'LT' => {
    'eng' => 2,
    'lit' => 1,
    'rus' => 2
  },
  'LY' => {
    'ara' => 1
  },
  'AC' => {
    'eng' => 2
  },
  'GE' => {
    'oss' => 2,
    'abk' => 2,
    'kat' => 1
  },
  'NA' => {
    'eng' => 1,
    'kua' => 2,
    'ndo' => 2,
    'afr' => 2
  },
  'IS' => {
    'isl' => 1
  },
  'LI' => {
    'gsw' => 1,
    'deu' => 1
  },
  'MK' => {
    'sqi' => 2,
    'mkd' => 1
  },
  'AS' => {
    'eng' => 1,
    'smo' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'AX' => {
    'swe' => 1
  },
  'GU' => {
    'eng' => 1,
    'cha' => 1
  },
  'KI' => {
    'eng' => 1,
    'gil' => 1
  },
  'TD' => {
    'fra' => 1,
    'ara' => 1
  },
  'KY' => {
    'eng' => 1
  },
  'DZ' => {
    'kab' => 2,
    'eng' => 2,
    'ara' => 2,
    'fra' => 1,
    'arq' => 2
  },
  'AZ' => {
    'aze' => 1
  },
  'EE' => {
    'est' => 1,
    'fin' => 2,
    'eng' => 2,
    'rus' => 2
  },
  'SM' => {
    'ita' => 1
  },
  'BV' => {
    'und' => 2
  },
  'TJ' => {
    'tgk' => 1,
    'rus' => 2
  },
  'AU' => {
    'eng' => 1
  },
  'AO' => {
    'umb' => 2,
    'por' => 1,
    'kmb' => 2
  },
  'DO' => {
    'spa' => 1
  },
  'EC' => {
    'que' => 1,
    'spa' => 1
  },
  'CR' => {
    'spa' => 1
  },
  'JM' => {
    'jam' => 2,
    'eng' => 1
  },
  'IO' => {
    'eng' => 1
  },
  'SN' => {
    'fra' => 1,
    'mey' => 2,
    'bsc' => 2,
    'bjt' => 2,
    'snf' => 2,
    'ful' => 2,
    'tnr' => 2,
    'srr' => 2,
    'wol' => 1,
    'sav' => 2,
    'dyo' => 2,
    'mfv' => 2,
    'knf' => 2
  },
  'ES' => {
    'glg' => 2,
    'ast' => 2,
    'eng' => 2,
    'eus' => 2,
    'spa' => 1,
    'cat' => 2
  },
  'GW' => {
    'por' => 1
  },
  'HM' => {
    'und' => 2
  },
  'TT' => {
    'eng' => 1
  },
  'MV' => {
    'div' => 1
  },
  'GS' => {
    'und' => 2
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'AE' => {
    'ara' => 1,
    'eng' => 2
  },
  'DE' => {
    'fra' => 2,
    'vmf' => 2,
    'eng' => 2,
    'nds' => 2,
    'dan' => 2,
    'deu' => 1,
    'gsw' => 2,
    'spa' => 2,
    'nld' => 2,
    'tur' => 2,
    'bar' => 2,
    'rus' => 2,
    'ita' => 2
  },
  'HN' => {
    'spa' => 1
  },
  'BF' => {
    'dyu' => 2,
    'fra' => 1,
    'mos' => 2
  },
  'UM' => {
    'eng' => 1
  },
  'LB' => {
    'ara' => 1,
    'eng' => 2
  },
  'NC' => {
    'fra' => 1
  },
  'PM' => {
    'fra' => 1
  },
  'BL' => {
    'fra' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'PN' => {
    'eng' => 1
  },
  'CD' => {
    'lua' => 2,
    'lub' => 2,
    'fra' => 1,
    'kon' => 2,
    'swa' => 2,
    'lin' => 2
  },
  'GH' => {
    'aka' => 2,
    'abr' => 2,
    'eng' => 1,
    'ewe' => 2,
    'ttb' => 2
  },
  'ML' => {
    'ful' => 2,
    'snk' => 2,
    'fra' => 1,
    'ffm' => 2,
    'bam' => 2
  },
  'NZ' => {
    'mri' => 1,
    'eng' => 1
  },
  'MF' => {
    'fra' => 1
  },
  'WS' => {
    'eng' => 1,
    'smo' => 1
  },
  'EH' => {
    'ara' => 1
  },
  'KR' => {
    'kor' => 1
  },
  'NO' => {
    'nno' => 1,
    'nob' => 1,
    'nor' => 1,
    'sme' => 2
  },
  'FK' => {
    'eng' => 1
  },
  'EA' => {
    'spa' => 1
  },
  'CI' => {
    'fra' => 1,
    'dnj' => 2,
    'sef' => 2,
    'bci' => 2
  },
  'MG' => {
    'eng' => 1,
    'mlg' => 1,
    'fra' => 1
  },
  'CY' => {
    'tur' => 1,
    'eng' => 2,
    'ell' => 1
  },
  'NU' => {
    'niu' => 1,
    'eng' => 1
  },
  'JP' => {
    'jpn' => 1
  },
  'GA' => {
    'fra' => 1
  },
  'NE' => {
    'fuq' => 2,
    'dje' => 2,
    'hau' => 2,
    'ful' => 2,
    'tmh' => 2,
    'fra' => 1
  },
  'TR' => {
    'kur' => 2,
    'eng' => 2,
    'zza' => 2,
    'tur' => 1
  },
  'VI' => {
    'eng' => 1
  },
  'BG' => {
    'rus' => 2,
    'bul' => 1,
    'eng' => 2
  },
  'BS' => {
    'eng' => 1
  },
  'NF' => {
    'eng' => 1
  },
  'NL' => {
    'nld' => 1,
    'fra' => 2,
    'deu' => 2,
    'fry' => 2,
    'eng' => 2,
    'nds' => 2
  },
  'MZ' => {
    'ndc' => 2,
    'vmw' => 2,
    'ngl' => 2,
    'seh' => 2,
    'tso' => 2,
    'mgh' => 2,
    'por' => 1
  },
  'BW' => {
    'eng' => 1,
    'tsn' => 1
  },
  'MX' => {
    'spa' => 1,
    'eng' => 2
  },
  'PT' => {
    'por' => 1,
    'spa' => 2,
    'eng' => 2,
    'fra' => 2
  },
  'BZ' => {
    'spa' => 2,
    'eng' => 1
  },
  'MC' => {
    'fra' => 1
  },
  'MS' => {
    'eng' => 1
  },
  'WF' => {
    'wls' => 2,
    'fud' => 2,
    'fra' => 1
  },
  'DK' => {
    'kal' => 2,
    'deu' => 2,
    'dan' => 1,
    'eng' => 2
  },
  'YE' => {
    'ara' => 1,
    'eng' => 2
  },
  'KP' => {
    'kor' => 1
  },
  'UY' => {
    'spa' => 1
  },
  'MW' => {
    'tum' => 2,
    'eng' => 1,
    'nya' => 1
  },
  'PY' => {
    'grn' => 1,
    'spa' => 1
  },
  'BO' => {
    'aym' => 1,
    'que' => 1,
    'spa' => 1
  },
  'ME' => {
    'hbs' => 1,
    'srp' => 1
  },
  'HR' => {
    'eng' => 2,
    'hbs' => 1,
    'hrv' => 1,
    'ita' => 2
  },
  'VN' => {
    'zho' => 2,
    'vie' => 1
  },
  'BE' => {
    'eng' => 2,
    'nld' => 1,
    'fra' => 1,
    'vls' => 2,
    'deu' => 1
  },
  'MO' => {
    'por' => 1,
    'zho' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'CM' => {
    'fra' => 1,
    'bmv' => 2,
    'eng' => 1
  },
  'ZA' => {
    'xho' => 2,
    'ssw' => 2,
    'zul' => 2,
    'sot' => 2,
    'nso' => 2,
    'tso' => 2,
    'tsn' => 2,
    'hin' => 2,
    'nbl' => 2,
    'ven' => 2,
    'eng' => 1,
    'afr' => 2
  },
  'MU' => {
    'fra' => 1,
    'mfe' => 2,
    'eng' => 1,
    'bho' => 2
  },
  'SR' => {
    'nld' => 1,
    'srn' => 2
  },
  'CN' => {
    'gan' => 2,
    'kor' => 2,
    'kaz' => 2,
    'bod' => 2,
    'zho' => 1,
    'wuu' => 2,
    'hak' => 2,
    'zha' => 2,
    'yue' => 2,
    'uig' => 2,
    'iii' => 2,
    'hsn' => 2,
    'mon' => 2,
    'nan' => 2
  },
  'NG' => {
    'bin' => 2,
    'ibo' => 2,
    'eng' => 1,
    'ibb' => 2,
    'pcm' => 2,
    'efi' => 2,
    'yor' => 1,
    'fuv' => 2,
    'tiv' => 2,
    'hau' => 2,
    'ful' => 2
  },
  'KM' => {
    'wni' => 1,
    'ara' => 1,
    'zdj' => 1,
    'fra' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'BA' => {
    'eng' => 2,
    'hbs' => 1,
    'bos' => 1,
    'srp' => 1,
    'hrv' => 1
  },
  'AL' => {
    'sqi' => 1
  },
  'KN' => {
    'eng' => 1
  },
  'IL' => {
    'ara' => 1,
    'heb' => 1,
    'eng' => 2
  },
  'AF' => {
    'haz' => 2,
    'bal' => 2,
    'pus' => 1,
    'tuk' => 2,
    'fas' => 1,
    'uzb' => 2
  },
  'EG' => {
    'eng' => 2,
    'arz' => 2,
    'ara' => 2
  },
  'FO' => {
    'fao' => 1
  },
  'SD' => {
    'eng' => 1,
    'fvr' => 2,
    'bej' => 2,
    'ara' => 1
  },
  'MA' => {
    'tzm' => 1,
    'rif' => 2,
    'zgh' => 2,
    'eng' => 2,
    'ary' => 2,
    'shr' => 2,
    'fra' => 1,
    'ara' => 2
  },
  'PR' => {
    'spa' => 1,
    'eng' => 1
  },
  'MH' => {
    'mah' => 1,
    'eng' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'SJ' => {
    'rus' => 2,
    'nor' => 1,
    'nob' => 1
  },
  'HT' => {
    'hat' => 1,
    'fra' => 1
  },
  'CP' => {
    'und' => 2
  },
  'TN' => {
    'aeb' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'DG' => {
    'eng' => 1
  },
  'ZW' => {
    'eng' => 1,
    'nde' => 1,
    'sna' => 1
  },
  'ST' => {
    'por' => 1
  },
  'BH' => {
    'ara' => 1
  },
  'SY' => {
    'ara' => 1,
    'fra' => 1,
    'kur' => 2
  },
  'GF' => {
    'fra' => 1,
    'gcr' => 2
  },
  'SI' => {
    'hbs' => 2,
    'slv' => 1,
    'eng' => 2,
    'deu' => 2,
    'hrv' => 2
  },
  'GL' => {
    'kal' => 1
  }
};
$Script2Lang = {
  'Prti' => {
    'xpr' => 2
  },
  'Khmr' => {
    'khm' => 1
  },
  'Osma' => {
    'som' => 2
  },
  'Mong' => {
    'mon' => 2,
    'mnc' => 2
  },
  'Plrd' => {
    'hmn' => 1,
    'hmd' => 1
  },
  'Linb' => {
    'grc' => 2
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Lydi' => {
    'xld' => 2
  },
  'Phlp' => {
    'abw' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Tibt' => {
    'tsj' => 1,
    'dzo' => 1,
    'bod' => 1,
    'bft' => 2,
    'taj' => 2,
    'tdg' => 2
  },
  'Wara' => {
    'hoc' => 2
  },
  'Bali' => {
    'ban' => 2
  },
  'Lepc' => {
    'lep' => 1
  },
  'Tirh' => {
    'mai' => 2
  },
  'Grek' => {
    'bgx' => 1,
    'ell' => 1,
    'pnt' => 1,
    'tsd' => 1,
    'grc' => 2,
    'cop' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Cyrl' => {
    'kaz' => 1,
    'alt' => 1,
    'kum' => 1,
    'bul' => 1,
    'kpy' => 1,
    'lbe' => 1,
    'hbs' => 1,
    'mdf' => 1,
    'uig' => 1,
    'srp' => 1,
    'tly' => 1,
    'nog' => 1,
    'mns' => 1,
    'tyv' => 1,
    'ava' => 1,
    'crh' => 1,
    'mrj' => 1,
    'tab' => 1,
    'tgk' => 1,
    'chm' => 1,
    'che' => 1,
    'rus' => 1,
    'abq' => 1,
    'abk' => 1,
    'dar' => 1,
    'myv' => 1,
    'mkd' => 1,
    'ukr' => 1,
    'tuk' => 1,
    'kom' => 1,
    'chv' => 1,
    'kbd' => 1,
    'syr' => 1,
    'yrk' => 1,
    'krc' => 1,
    'gag' => 2,
    'ady' => 1,
    'evn' => 1,
    'kir' => 1,
    'kjh' => 1,
    'tkr' => 1,
    'cjs' => 1,
    'bel' => 1,
    'rom' => 2,
    'pnt' => 1,
    'xal' => 1,
    'kkt' => 1,
    'inh' => 1,
    'sme' => 2,
    'lez' => 1,
    'bak' => 1,
    'aze' => 1,
    'oss' => 1,
    'kaa' => 1,
    'aii' => 1,
    'bos' => 1,
    'ttt' => 1,
    'dng' => 1,
    'udm' => 1,
    'ude' => 1,
    'chu' => 2,
    'sel' => 2,
    'ron' => 2,
    'lfn' => 2,
    'tat' => 1,
    'rue' => 1,
    'mon' => 1,
    'sah' => 1,
    'bub' => 1,
    'uzb' => 1,
    'gld' => 1,
    'kur' => 1,
    'ckt' => 1,
    'kca' => 1
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Nbat' => {
    'arc' => 2
  },
  'Phag' => {
    'mon' => 2,
    'zho' => 2
  },
  'Hani' => {
    'vie' => 2
  },
  'Tale' => {
    'tdd' => 1
  },
  'Java' => {
    'jav' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Tglg' => {
    'fil' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Phli' => {
    'abw' => 2
  },
  'Knda' => {
    'tcy' => 1,
    'kan' => 1
  },
  'Copt' => {
    'cop' => 2
  },
  'Sund' => {
    'sun' => 2
  },
  'Hans' => {
    'wuu' => 1,
    'nan' => 1,
    'hak' => 1,
    'zho' => 1,
    'lzh' => 2,
    'yue' => 1,
    'hsn' => 1,
    'zha' => 2,
    'gan' => 1
  },
  'Geor' => {
    'kat' => 1,
    'xmf' => 1,
    'lzz' => 1
  },
  'Kali' => {
    'kyu' => 1,
    'eky' => 1
  },
  'Palm' => {
    'arc' => 2
  },
  'Dupl' => {
    'fra' => 2
  },
  'Cham' => {
    'cjm' => 1,
    'cja' => 2
  },
  'Orya' => {
    'ori' => 1,
    'sat' => 2
  },
  'Sylo' => {
    'syl' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Kore' => {
    'kor' => 1
  },
  'Ugar' => {
    'uga' => 2
  },
  'Arab' => {
    'khw' => 1,
    'bgn' => 1,
    'gbz' => 1,
    'tuk' => 1,
    'glk' => 1,
    'kxp' => 1,
    'hno' => 1,
    'som' => 2,
    'ary' => 1,
    'lrc' => 1,
    'msa' => 1,
    'tur' => 2,
    'sdh' => 1,
    'prd' => 1,
    'luz' => 1,
    'tly' => 1,
    'arz' => 1,
    'rmt' => 1,
    'ckb' => 1,
    'pus' => 1,
    'uig' => 1,
    'tgk' => 1,
    'brh' => 1,
    'ind' => 2,
    'snd' => 1,
    'cjm' => 2,
    'bal' => 1,
    'dcc' => 1,
    'skr' => 1,
    'kaz' => 1,
    'hau' => 1,
    'bqi' => 1,
    'lah' => 1,
    'shr' => 1,
    'arq' => 1,
    'fas' => 1,
    'kur' => 1,
    'uzb' => 1,
    'kvx' => 1,
    'zdj' => 1,
    'mfa' => 1,
    'pan' => 1,
    'gjk' => 1,
    'doi' => 1,
    'kas' => 1,
    'aze' => 1,
    'inh' => 2,
    'urd' => 1,
    'wni' => 1,
    'aeb' => 1,
    'ttt' => 2,
    'ars' => 1,
    'dyo' => 2,
    'wol' => 2,
    'swb' => 1,
    'hnd' => 1,
    'mvy' => 1,
    'fia' => 1,
    'kir' => 1,
    'cop' => 2,
    'ara' => 1,
    'bft' => 1,
    'sus' => 2,
    'raj' => 1,
    'lki' => 1,
    'haz' => 1,
    'gju' => 1,
    'cja' => 1,
    'mzn' => 1,
    'bej' => 1
  },
  'Bopo' => {
    'zho' => 2
  },
  'Khoj' => {
    'snd' => 2
  },
  'Ital' => {
    'xum' => 2,
    'ett' => 2,
    'osc' => 2
  },
  'Deva' => {
    'hif' => 1,
    'hin' => 1,
    'mai' => 1,
    'sck' => 1,
    'kok' => 1,
    'new' => 1,
    'bfy' => 1,
    'kas' => 1,
    'doi' => 1,
    'hoj' => 1,
    'raj' => 1,
    'dty' => 1,
    'gvr' => 1,
    'thl' => 1,
    'bap' => 1,
    'mag' => 1,
    'unx' => 1,
    'taj' => 1,
    'bgc' => 1,
    'wtm' => 1,
    'tdh' => 1,
    'kfy' => 1,
    'hne' => 1,
    'bho' => 1,
    'unr' => 1,
    'bhb' => 1,
    'tdg' => 1,
    'mar' => 1,
    'snd' => 1,
    'bhi' => 1,
    'brx' => 1,
    'awa' => 1,
    'xsr' => 1,
    'swv' => 1,
    'tkt' => 1,
    'gom' => 1,
    'mrd' => 1,
    'lif' => 1,
    'mwr' => 1,
    'btv' => 1,
    'noe' => 1,
    'mgp' => 1,
    'jml' => 1,
    'rjs' => 1,
    'kru' => 1,
    'pli' => 2,
    'hoc' => 1,
    'anp' => 1,
    'sat' => 2,
    'thr' => 1,
    'srx' => 1,
    'gon' => 1,
    'khn' => 1,
    'san' => 2,
    'mtr' => 1,
    'gbm' => 1,
    'nep' => 1,
    'bjj' => 1,
    'thq' => 1,
    'bra' => 1,
    'xnr' => 1,
    'wbr' => 1,
    'kfr' => 1
  },
  'Sind' => {
    'snd' => 2
  },
  'Avst' => {
    'ave' => 2
  },
  'Tavt' => {
    'blt' => 1
  },
  'Ethi' => {
    'orm' => 2,
    'amh' => 1,
    'gez' => 2,
    'tir' => 1,
    'tig' => 1,
    'byn' => 1,
    'wal' => 1
  },
  'Samr' => {
    'smp' => 2,
    'snx' => 2
  },
  'Nkoo' => {
    'nqo' => 1,
    'bam' => 1,
    'man' => 1
  },
  'Syrc' => {
    'syr' => 2,
    'aii' => 2,
    'tru' => 2,
    'ara' => 2
  },
  'Bugi' => {
    'mdr' => 2,
    'mak' => 2,
    'bug' => 2
  },
  'Mend' => {
    'men' => 2
  },
  'Shrd' => {
    'san' => 2
  },
  'Xsux' => {
    'akk' => 2,
    'hit' => 2
  },
  'Thai' => {
    'pli' => 2,
    'sqq' => 1,
    'tts' => 1,
    'kdt' => 1,
    'lcp' => 1,
    'tha' => 1,
    'lwl' => 1,
    'kxm' => 1
  },
  'Runr' => {
    'non' => 2,
    'deu' => 2
  },
  'Mroo' => {
    'mro' => 2
  },
  'Talu' => {
    'khb' => 1
  },
  'Modi' => {
    'mar' => 2
  },
  'Buhd' => {
    'bku' => 2
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Hant' => {
    'yue' => 1,
    'zho' => 1
  },
  'Mani' => {
    'xmn' => 2
  },
  'Mymr' => {
    'mya' => 1,
    'kht' => 1,
    'mnw' => 1,
    'shn' => 1
  },
  'Thaa' => {
    'div' => 1
  },
  'Tfng' => {
    'rif' => 1,
    'tzm' => 1,
    'zgh' => 1,
    'shr' => 1,
    'zen' => 2
  },
  'Guru' => {
    'pan' => 1
  },
  'Mtei' => {
    'mni' => 2
  },
  'Limb' => {
    'lif' => 1
  },
  'Aghb' => {
    'lez' => 2
  },
  'Laoo' => {
    'kjg' => 1,
    'hmn' => 1,
    'lao' => 1,
    'hnj' => 1
  },
  'Yiii' => {
    'iii' => 1
  },
  'Hano' => {
    'hnn' => 2
  },
  'Latn' => {
    'mwv' => 1,
    'mro' => 1,
    'rug' => 1,
    'xav' => 1,
    'nmg' => 1,
    'ace' => 1,
    'slv' => 1,
    'sco' => 1,
    'saq' => 1,
    'rcf' => 1,
    'kri' => 1,
    'ffm' => 1,
    'ksh' => 1,
    'mdr' => 1,
    'ife' => 1,
    'sas' => 1,
    'crl' => 2,
    'pcd' => 1,
    'jmc' => 1,
    'orm' => 1,
    'ven' => 1,
    'yao' => 1,
    'ikt' => 1,
    'nia' => 1,
    'kln' => 1,
    'tpi' => 1,
    'bzx' => 1,
    'tum' => 1,
    'ssw' => 1,
    'nhe' => 1,
    'loz' => 1,
    'twq' => 1,
    'ctd' => 1,
    'kaj' => 1,
    'kjg' => 2,
    'eng' => 1,
    'gmh' => 2,
    'rar' => 1,
    'fud' => 1,
    'rwk' => 1,
    'pau' => 1,
    'oci' => 1,
    'jgo' => 1,
    'bla' => 1,
    'ful' => 1,
    'vun' => 1,
    'bmq' => 1,
    'sna' => 1,
    'mxc' => 1,
    'lfn' => 2,
    'smj' => 1,
    'chp' => 1,
    'ast' => 1,
    'quc' => 1,
    'hai' => 1,
    'afr' => 1,
    'bre' => 1,
    'dnj' => 1,
    'dav' => 1,
    'dyu' => 1,
    'hnn' => 1,
    'ain' => 2,
    'grn' => 1,
    'ttj' => 1,
    'mls' => 1,
    'gle' => 1,
    'deu' => 1,
    'ttt' => 1,
    'tzm' => 1,
    'tsg' => 1,
    'kua' => 1,
    'gur' => 1,
    'lub' => 1,
    'xog' => 1,
    'guc' => 1,
    'guz' => 1,
    'vot' => 2,
    'pfl' => 1,
    'ces' => 1,
    'enm' => 2,
    'fij' => 1,
    'gag' => 1,
    'fit' => 1,
    'kdx' => 1,
    'umb' => 1,
    'ksf' => 1,
    'eka' => 1,
    'arw' => 2,
    'kcg' => 1,
    'abr' => 1,
    'kdh' => 1,
    'mus' => 1,
    'frs' => 1,
    'zag' => 1,
    'hau' => 1,
    'lug' => 1,
    'arg' => 1,
    'por' => 1,
    'swe' => 1,
    'dgr' => 1,
    'oji' => 2,
    'que' => 1,
    'kea' => 1,
    'wln' => 1,
    'scn' => 1,
    'frc' => 1,
    'egl' => 1,
    'srp' => 1,
    'hsb' => 1,
    'frr' => 1,
    'sei' => 1,
    'nld' => 1,
    'efi' => 1,
    'sgs' => 1,
    'bmv' => 1,
    'fao' => 1,
    'kax' => 1,
    'frm' => 2,
    'nso' => 1,
    'aka' => 1,
    'gba' => 1,
    'cym' => 1,
    'epo' => 1,
    'rmo' => 1,
    'nap' => 1,
    'syi' => 1,
    'tog' => 1,
    'ljp' => 1,
    'cch' => 1,
    'tmh' => 1,
    'cor' => 1,
    'srn' => 1,
    'rom' => 1,
    'pnt' => 1,
    'sus' => 1,
    'kck' => 1,
    'ibb' => 1,
    'gos' => 1,
    'yua' => 1,
    'see' => 1,
    'dum' => 2,
    'yap' => 1,
    'sli' => 1,
    'cps' => 1,
    'moe' => 1,
    'kkj' => 1,
    'pag' => 1,
    'ebu' => 1,
    'cos' => 1,
    'ewo' => 1,
    'osa' => 2,
    'ext' => 1,
    'nyo' => 1,
    'lim' => 1,
    'ngl' => 1,
    'xho' => 1,
    'hmn' => 1,
    'bci' => 1,
    'kut' => 1,
    'fil' => 1,
    'som' => 1,
    'dtp' => 1,
    'nya' => 1,
    'tuk' => 1,
    'vol' => 2,
    'est' => 1,
    'dak' => 1,
    'fon' => 1,
    'ses' => 1,
    'nhw' => 1,
    'mak' => 1,
    'sag' => 1,
    'mos' => 1,
    'sma' => 1,
    'chn' => 2,
    'puu' => 1,
    'bal' => 2,
    'gwi' => 1,
    'rmf' => 1,
    'tgk' => 1,
    'lam' => 1,
    'asa' => 1,
    'lzz' => 1,
    'kin' => 1,
    'smo' => 1,
    'haw' => 1,
    'gub' => 1,
    'csb' => 2,
    'pdc' => 1,
    'maz' => 1,
    'ang' => 2,
    'cho' => 1,
    'ter' => 1,
    'kgp' => 1,
    'izh' => 1,
    'tiv' => 1,
    'suk' => 1,
    'cic' => 1,
    'srd' => 1,
    'xum' => 2,
    'tsi' => 1,
    'khq' => 1,
    'her' => 1,
    'smn' => 1,
    'cha' => 1,
    'tkr' => 1,
    'glv' => 1,
    'hmo' => 1,
    'pro' => 2,
    'nyn' => 1,
    'ybb' => 1,
    'glg' => 1,
    'crj' => 2,
    'swb' => 2,
    'sbp' => 1,
    'car' => 1,
    'wol' => 1,
    'jut' => 2,
    'bbc' => 1,
    'ada' => 1,
    'vmw' => 1,
    'zha' => 1,
    'bqv' => 1,
    'pmn' => 1,
    'ilo' => 1,
    'tur' => 1,
    'bin' => 1,
    'lui' => 2,
    'mic' => 1,
    'ndo' => 1,
    'ceb' => 1,
    'nij' => 1,
    'liv' => 2,
    'mas' => 1,
    'vep' => 1,
    'isl' => 1,
    'sdc' => 1,
    'kal' => 1,
    'fin' => 1,
    'rob' => 1,
    'slk' => 1,
    'lav' => 1,
    'dsb' => 1,
    'cgg' => 1,
    'mlg' => 1,
    'aln' => 1,
    'kmb' => 1,
    'fan' => 1,
    'lag' => 1,
    'swg' => 1,
    'lmo' => 1,
    'qug' => 1,
    'mwk' => 1,
    'gsw' => 1,
    'chy' => 1,
    'ban' => 1,
    'kon' => 1,
    'tli' => 1,
    'nym' => 1,
    'rof' => 1,
    'bvb' => 1,
    'aoz' => 1,
    'udm' => 2,
    'zmi' => 1,
    'mgy' => 1,
    'nor' => 1,
    'nch' => 1,
    'kur' => 1,
    'spa' => 1,
    'jam' => 1,
    'hil' => 1,
    'ton' => 1,
    'pol' => 1,
    'ipk' => 1,
    'kab' => 1,
    'dyo' => 1,
    'mdh' => 1,
    'esu' => 1,
    'yor' => 1,
    'hif' => 1,
    'eus' => 1,
    'bto' => 1,
    'inh' => 2,
    'vmf' => 1,
    'zap' => 1,
    'swa' => 1,
    'nno' => 1,
    'arp' => 1,
    'fry' => 1,
    'njo' => 1,
    'zul' => 1,
    'del' => 1,
    'msa' => 1,
    'fro' => 2,
    'kge' => 1,
    'fra' => 1,
    'mua' => 1,
    'bam' => 1,
    'bze' => 1,
    'mgo' => 1,
    'zea' => 1,
    'gla' => 1,
    'dua' => 1,
    'vec' => 1,
    'rej' => 1,
    'aym' => 1,
    'hup' => 1,
    'vls' => 1,
    'nbl' => 1,
    'iii' => 2,
    'wbp' => 1,
    'prg' => 2,
    'srb' => 1,
    'ach' => 1,
    'ron' => 1,
    'ina' => 2,
    'rif' => 1,
    'wls' => 1,
    'scs' => 1,
    'jav' => 1,
    'bez' => 1,
    'nau' => 1,
    'nnh' => 1,
    'uzb' => 1,
    'bss' => 1,
    'shr' => 1,
    'tvl' => 1,
    'krl' => 1,
    'cre' => 2,
    'atj' => 1,
    'fuq' => 1,
    'niu' => 1,
    'buc' => 1,
    'zza' => 1,
    'ibo' => 1,
    'naq' => 1,
    'snk' => 1,
    'kde' => 1,
    'hin' => 2,
    'myx' => 1,
    'pon' => 1,
    'iba' => 1,
    'lkt' => 1,
    'rtm' => 1,
    'avk' => 2,
    'ltg' => 1,
    'roh' => 1,
    'crs' => 1,
    'aar' => 1,
    'gqr' => 1,
    'mgh' => 1,
    'lut' => 2,
    'den' => 1,
    'tet' => 1,
    'pdt' => 1,
    'zun' => 1,
    'saf' => 1,
    'tah' => 1,
    'ttb' => 1,
    'sad' => 1,
    'vro' => 1,
    'rup' => 1,
    'trv' => 1,
    'lin' => 1,
    'hbs' => 1,
    'men' => 1,
    'sid' => 1,
    'hrv' => 1,
    'mri' => 1,
    'ind' => 1,
    'brh' => 2,
    'cat' => 1,
    'ria' => 1,
    'lol' => 1,
    'bku' => 1,
    'bbj' => 1,
    'yrl' => 1,
    'pcm' => 1,
    'nde' => 1,
    'bik' => 1,
    'bem' => 1,
    'vic' => 1,
    'dtm' => 1,
    'goh' => 2,
    'rgn' => 1,
    'gcr' => 1,
    'kac' => 1,
    'kiu' => 1,
    'krj' => 1,
    'uli' => 1,
    'maf' => 1,
    'fvr' => 1,
    'nob' => 1,
    'mad' => 1,
    'rng' => 1,
    'sxn' => 1,
    'kir' => 1,
    'lua' => 1,
    'nsk' => 2,
    'bfd' => 1,
    'kha' => 1,
    'kau' => 1,
    'stq' => 1,
    'ksb' => 1,
    'aze' => 1,
    'run' => 1,
    'teo' => 1,
    'bkm' => 1,
    'aro' => 1,
    'sqi' => 1,
    'luo' => 1,
    'bos' => 1,
    'frp' => 1,
    'gil' => 1,
    'szl' => 1,
    'luy' => 1,
    'srr' => 1,
    'sat' => 2,
    'sun' => 1,
    'moh' => 1,
    'iku' => 1,
    'nds' => 1,
    'seh' => 1,
    'tkl' => 1,
    'nzi' => 1,
    'cay' => 1,
    'ett' => 2,
    'vai' => 1,
    'vie' => 1,
    'tso' => 1,
    'ndc' => 1,
    'mdt' => 1,
    'nov' => 2,
    'uig' => 2,
    'gay' => 1,
    'tly' => 1,
    'cad' => 1,
    'kvr' => 1,
    'pko' => 1,
    'ita' => 1,
    'tbw' => 1,
    'hun' => 1,
    'tsn' => 1,
    'hat' => 1,
    'kos' => 1,
    'sga' => 2,
    'nus' => 1,
    'bas' => 1,
    'osc' => 2,
    'dje' => 1,
    'sef' => 1,
    'rmu' => 1,
    'min' => 1,
    'byv' => 1,
    'dan' => 1,
    'man' => 1,
    'mwl' => 1,
    'din' => 1,
    'bar' => 1,
    'wae' => 1,
    'chk' => 1,
    'sly' => 1,
    'bew' => 1,
    'pms' => 1,
    'tru' => 1,
    'bis' => 1,
    'sme' => 1,
    'kik' => 1,
    'amo' => 1,
    'lbw' => 1,
    'ale' => 1,
    'laj' => 1,
    'nav' => 1,
    'grb' => 1,
    'nxq' => 1,
    'bug' => 1,
    'fuv' => 1,
    'mlt' => 1,
    'mfe' => 1,
    'bjn' => 1,
    'kpe' => 1,
    'hop' => 1,
    'rap' => 1,
    'ssy' => 1,
    'lun' => 1,
    'arn' => 1,
    'lat' => 2,
    'war' => 1,
    'akz' => 1,
    'ltz' => 1,
    'pap' => 1,
    'sot' => 1,
    'yav' => 1,
    'mah' => 1,
    'mnu' => 1,
    'sms' => 1,
    'lit' => 1,
    'lij' => 1,
    'ewe' => 1,
    'agq' => 1,
    'kfo' => 1,
    'was' => 1
  },
  'Vaii' => {
    'vai' => 1
  },
  'Sinh' => {
    'sin' => 1,
    'san' => 2,
    'pli' => 2
  },
  'Orkh' => {
    'otk' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Armn' => {
    'hye' => 1
  },
  'Lina' => {
    'lab' => 2
  },
  'Phnx' => {
    'phn' => 2
  },
  'Telu' => {
    'gon' => 1,
    'lmn' => 1,
    'tel' => 1,
    'wbq' => 1
  },
  'Narb' => {
    'xna' => 2
  },
  'Taml' => {
    'tam' => 1,
    'bfq' => 1
  },
  'Ogam' => {
    'sga' => 2
  },
  'Mlym' => {
    'mal' => 1
  },
  'Mand' => {
    'myz' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Cans' => {
    'iku' => 1,
    'chp' => 2,
    'crk' => 1,
    'nsk' => 1,
    'cre' => 1,
    'crm' => 1,
    'crj' => 1,
    'crl' => 1,
    'oji' => 1,
    'den' => 2,
    'csw' => 1
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Takr' => {
    'doi' => 2
  },
  'Armi' => {
    'arc' => 2
  },
  'Gran' => {
    'san' => 2
  },
  'Beng' => {
    'grt' => 1,
    'asm' => 1,
    'lus' => 1,
    'kha' => 2,
    'unr' => 1,
    'ben' => 1,
    'bpy' => 1,
    'sat' => 2,
    'ccp' => 1,
    'mni' => 1,
    'rkt' => 1,
    'syl' => 1,
    'unx' => 1
  },
  'Bamu' => {
    'bax' => 1
  },
  'Gujr' => {
    'guj' => 1
  },
  'Kana' => {
    'ain' => 2,
    'ryu' => 1
  },
  'Hebr' => {
    'lad' => 1,
    'snx' => 2,
    'yid' => 1,
    'jrb' => 1,
    'heb' => 1,
    'jpr' => 1
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Shaw' => {
    'eng' => 2
  },
  'Sora' => {
    'srb' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Egyp' => {
    'egy' => 2
  },
  'Sidd' => {
    'san' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Cprt' => {
    'grc' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Osge' => {
    'osa' => 1
  },
  'Batk' => {
    'bbc' => 2
  },
  'Cher' => {
    'chr' => 1
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Olck' => {
    'sat' => 1
  }
};
$DefaultScript = {
  'ces' => 'Latn',
  'pfl' => 'Latn',
  'nod' => 'Lana',
  'guz' => 'Latn',
  'fij' => 'Latn',
  'abq' => 'Cyrl',
  'shn' => 'Mymr',
  'umb' => 'Latn',
  'ksf' => 'Latn',
  'kdx' => 'Latn',
  'fit' => 'Latn',
  'gag' => 'Latn',
  'frs' => 'Latn',
  'kdh' => 'Latn',
  'khw' => 'Arab',
  'mus' => 'Latn',
  'bgn' => 'Arab',
  'abr' => 'Latn',
  'kcg' => 'Latn',
  'eka' => 'Latn',
  'por' => 'Latn',
  'arg' => 'Latn',
  'lug' => 'Latn',
  'zag' => 'Latn',
  'alt' => 'Cyrl',
  'que' => 'Latn',
  'oji' => 'Cans',
  'swe' => 'Latn',
  'dgr' => 'Latn',
  'tir' => 'Ethi',
  'frc' => 'Latn',
  'scn' => 'Latn',
  'wln' => 'Latn',
  'tha' => 'Thai',
  'ava' => 'Cyrl',
  'tyv' => 'Cyrl',
  'nan' => 'Hans',
  'crh' => 'Cyrl',
  'kea' => 'Latn',
  'rmt' => 'Arab',
  'gom' => 'Deva',
  'frr' => 'Latn',
  'awa' => 'Deva',
  'hsb' => 'Latn',
  'egl' => 'Latn',
  'mxc' => 'Latn',
  'sna' => 'Latn',
  'ast' => 'Latn',
  'smj' => 'Latn',
  'chp' => 'Latn',
  'thl' => 'Deva',
  'hai' => 'Latn',
  'lis' => 'Lisu',
  'quc' => 'Latn',
  'div' => 'Thaa',
  'bgx' => 'Grek',
  'bqi' => 'Arab',
  'mag' => 'Deva',
  'bre' => 'Latn',
  'afr' => 'Latn',
  'haz' => 'Arab',
  'ell' => 'Grek',
  'dnj' => 'Latn',
  'ttj' => 'Latn',
  'mls' => 'Latn',
  'tcy' => 'Knda',
  'byn' => 'Ethi',
  'heb' => 'Hebr',
  'grn' => 'Latn',
  'hnn' => 'Latn',
  'dyu' => 'Latn',
  'dav' => 'Latn',
  'ben' => 'Beng',
  'gur' => 'Latn',
  'kua' => 'Latn',
  'tsg' => 'Latn',
  'deu' => 'Latn',
  'gle' => 'Latn',
  'khb' => 'Talu',
  'guc' => 'Latn',
  'xog' => 'Latn',
  'eky' => 'Kali',
  'lub' => 'Latn',
  'kat' => 'Geor',
  'twq' => 'Latn',
  'loz' => 'Latn',
  'nhe' => 'Latn',
  'ssw' => 'Latn',
  'hak' => 'Hans',
  'abk' => 'Cyrl',
  'hno' => 'Arab',
  'ctd' => 'Latn',
  'glk' => 'Arab',
  'krc' => 'Cyrl',
  'eng' => 'Latn',
  'kjg' => 'Laoo',
  'kaj' => 'Latn',
  'nep' => 'Deva',
  'pau' => 'Latn',
  'rwk' => 'Latn',
  'fud' => 'Latn',
  'bul' => 'Cyrl',
  'mrd' => 'Deva',
  'rar' => 'Latn',
  'yid' => 'Hebr',
  'oci' => 'Latn',
  'hoc' => 'Deva',
  'kru' => 'Deva',
  'xmf' => 'Geor',
  'vun' => 'Latn',
  'tdg' => 'Deva',
  'ful' => 'Latn',
  'bla' => 'Latn',
  'jgo' => 'Latn',
  'saz' => 'Saur',
  'bmq' => 'Latn',
  'khm' => 'Khmr',
  'xsr' => 'Deva',
  'xav' => 'Latn',
  'rug' => 'Latn',
  'mro' => 'Latn',
  'mwv' => 'Latn',
  'nmg' => 'Latn',
  'bhb' => 'Deva',
  'slv' => 'Latn',
  'sco' => 'Latn',
  'ace' => 'Latn',
  'ffm' => 'Latn',
  'ksh' => 'Latn',
  'bap' => 'Deva',
  'kri' => 'Latn',
  'rcf' => 'Latn',
  'saq' => 'Latn',
  'bel' => 'Cyrl',
  'dty' => 'Deva',
  'jmc' => 'Latn',
  'pcd' => 'Latn',
  'crl' => 'Cans',
  'sas' => 'Latn',
  'hnd' => 'Arab',
  'mdr' => 'Latn',
  'ife' => 'Latn',
  'kln' => 'Latn',
  'nia' => 'Latn',
  'ikt' => 'Latn',
  'yao' => 'Latn',
  'ven' => 'Latn',
  'orm' => 'Latn',
  'tum' => 'Latn',
  'bzx' => 'Latn',
  'tpi' => 'Latn',
  'ilo' => 'Latn',
  'hmd' => 'Plrd',
  'prd' => 'Arab',
  'pmn' => 'Latn',
  'myv' => 'Cyrl',
  'mic' => 'Latn',
  'ndo' => 'Latn',
  'dar' => 'Cyrl',
  'bin' => 'Latn',
  'wbr' => 'Deva',
  'tur' => 'Latn',
  'bod' => 'Tibt',
  'vep' => 'Latn',
  'isl' => 'Latn',
  'kxp' => 'Arab',
  'evn' => 'Cyrl',
  'mas' => 'Latn',
  'ady' => 'Cyrl',
  'nij' => 'Latn',
  'bpy' => 'Beng',
  'ceb' => 'Latn',
  'wbq' => 'Telu',
  'fin' => 'Latn',
  'kal' => 'Latn',
  'sdc' => 'Latn',
  'aln' => 'Latn',
  'btv' => 'Deva',
  'mlg' => 'Latn',
  'lav' => 'Latn',
  'cgg' => 'Latn',
  'dsb' => 'Latn',
  'csw' => 'Cans',
  'rob' => 'Latn',
  'slk' => 'Latn',
  'lag' => 'Latn',
  'bfq' => 'Taml',
  'fan' => 'Latn',
  'kmb' => 'Latn',
  'gsw' => 'Latn',
  'mwk' => 'Latn',
  'qug' => 'Latn',
  'swg' => 'Latn',
  'lmo' => 'Latn',
  'hye' => 'Armn',
  'mrj' => 'Cyrl',
  'tab' => 'Cyrl',
  'mar' => 'Deva',
  'luz' => 'Arab',
  'kon' => 'Latn',
  'tli' => 'Latn',
  'arz' => 'Arab',
  'ckb' => 'Arab',
  'ban' => 'Latn',
  'chy' => 'Latn',
  'swv' => 'Deva',
  'maz' => 'Latn',
  'pdc' => 'Latn',
  'gub' => 'Latn',
  'ori' => 'Orya',
  'haw' => 'Latn',
  'kgp' => 'Latn',
  'ter' => 'Latn',
  'cho' => 'Latn',
  'blt' => 'Tavt',
  'jrb' => 'Hebr',
  'kvx' => 'Arab',
  'cic' => 'Latn',
  'tiv' => 'Latn',
  'suk' => 'Latn',
  'izh' => 'Latn',
  'smn' => 'Latn',
  'cha' => 'Latn',
  'lcp' => 'Thai',
  'kdt' => 'Thai',
  'her' => 'Latn',
  'khq' => 'Latn',
  'tsi' => 'Latn',
  'srd' => 'Latn',
  'tig' => 'Ethi',
  'arq' => 'Arab',
  'lki' => 'Arab',
  'ybb' => 'Latn',
  'nyn' => 'Latn',
  'grt' => 'Beng',
  'hmo' => 'Latn',
  'bej' => 'Arab',
  'glv' => 'Latn',
  'wol' => 'Latn',
  'car' => 'Latn',
  'sbp' => 'Latn',
  'ars' => 'Arab',
  'swb' => 'Arab',
  'lus' => 'Beng',
  'crj' => 'Cans',
  'glg' => 'Latn',
  'ada' => 'Latn',
  'mai' => 'Deva',
  'wni' => 'Arab',
  'bbc' => 'Latn',
  'bqv' => 'Latn',
  'hnj' => 'Laoo',
  'zha' => 'Latn',
  'kaa' => 'Cyrl',
  'lez' => 'Cyrl',
  'vmw' => 'Latn',
  'bax' => 'Bamu',
  'hmn' => 'Latn',
  'xho' => 'Latn',
  'bci' => 'Latn',
  'ngl' => 'Latn',
  'lim' => 'Latn',
  'nyo' => 'Latn',
  'kan' => 'Knda',
  'som' => 'Latn',
  'fil' => 'Latn',
  'kut' => 'Latn',
  'rus' => 'Cyrl',
  'kfr' => 'Deva',
  'nya' => 'Latn',
  'dtp' => 'Latn',
  'yrk' => 'Cyrl',
  'srx' => 'Deva',
  'fon' => 'Latn',
  'dak' => 'Latn',
  'est' => 'Latn',
  'mwr' => 'Deva',
  'mos' => 'Latn',
  'sag' => 'Latn',
  'kpy' => 'Cyrl',
  'mak' => 'Latn',
  'nhw' => 'Latn',
  'ses' => 'Latn',
  'gwi' => 'Latn',
  'bal' => 'Arab',
  'puu' => 'Latn',
  'sma' => 'Latn',
  'skr' => 'Arab',
  'asa' => 'Latn',
  'lam' => 'Latn',
  'rmf' => 'Latn',
  'bhi' => 'Deva',
  'smo' => 'Latn',
  'kin' => 'Latn',
  'pus' => 'Arab',
  'wtm' => 'Deva',
  'mfa' => 'Arab',
  'ryu' => 'Kana',
  'sei' => 'Latn',
  'gba' => 'Latn',
  'cym' => 'Latn',
  'aka' => 'Latn',
  'nso' => 'Latn',
  'kax' => 'Latn',
  'jpn' => 'Jpan',
  'fao' => 'Latn',
  'bmv' => 'Latn',
  'efi' => 'Latn',
  'sgs' => 'Latn',
  'nld' => 'Latn',
  'nap' => 'Latn',
  'lmn' => 'Telu',
  'rmo' => 'Latn',
  'epo' => 'Latn',
  'srn' => 'Latn',
  'rue' => 'Cyrl',
  'cor' => 'Latn',
  'wal' => 'Ethi',
  'tmh' => 'Latn',
  'tog' => 'Latn',
  'ljp' => 'Latn',
  'cch' => 'Latn',
  'syi' => 'Latn',
  'kkt' => 'Cyrl',
  'kck' => 'Latn',
  'sus' => 'Latn',
  'cja' => 'Arab',
  'rom' => 'Latn',
  'gvr' => 'Deva',
  'yua' => 'Latn',
  'gos' => 'Latn',
  'ibb' => 'Latn',
  'fia' => 'Arab',
  'moe' => 'Latn',
  'cps' => 'Latn',
  'sli' => 'Latn',
  'tam' => 'Taml',
  'yap' => 'Latn',
  'see' => 'Latn',
  'ext' => 'Latn',
  'cos' => 'Latn',
  'osa' => 'Osge',
  'ewo' => 'Latn',
  'kkj' => 'Latn',
  'pag' => 'Latn',
  'doi' => 'Arab',
  'ebu' => 'Latn',
  'bjj' => 'Deva',
  'ltg' => 'Latn',
  'mgh' => 'Latn',
  'gqr' => 'Latn',
  'aar' => 'Latn',
  'crs' => 'Latn',
  'roh' => 'Latn',
  'chm' => 'Cyrl',
  'zun' => 'Latn',
  'pdt' => 'Latn',
  'kht' => 'Mymr',
  'tet' => 'Latn',
  'den' => 'Latn',
  'lwl' => 'Thai',
  'rup' => 'Latn',
  'vro' => 'Latn',
  'sad' => 'Latn',
  'mtr' => 'Deva',
  'ttb' => 'Latn',
  'tah' => 'Latn',
  'saf' => 'Latn',
  'lbe' => 'Cyrl',
  'lin' => 'Latn',
  'jml' => 'Deva',
  'wuu' => 'Hans',
  'trv' => 'Latn',
  'men' => 'Latn',
  'sid' => 'Latn',
  'ria' => 'Latn',
  'lol' => 'Latn',
  'cat' => 'Latn',
  'brh' => 'Arab',
  'ind' => 'Latn',
  'mri' => 'Latn',
  'hrv' => 'Latn',
  'brx' => 'Deva',
  'bbj' => 'Latn',
  'dzo' => 'Tibt',
  'bku' => 'Latn',
  'tkt' => 'Deva',
  'mdf' => 'Cyrl',
  'jav' => 'Latn',
  'scs' => 'Latn',
  'wls' => 'Latn',
  'bgc' => 'Deva',
  'ron' => 'Latn',
  'hne' => 'Deva',
  'dng' => 'Cyrl',
  'mnw' => 'Mymr',
  'bss' => 'Latn',
  'nnh' => 'Latn',
  'bez' => 'Latn',
  'nau' => 'Latn',
  'krl' => 'Latn',
  'tsj' => 'Tibt',
  'tvl' => 'Latn',
  'lah' => 'Arab',
  'fuq' => 'Latn',
  'niu' => 'Latn',
  'bft' => 'Arab',
  'atj' => 'Latn',
  'ibo' => 'Latn',
  'zza' => 'Latn',
  'buc' => 'Latn',
  'pon' => 'Latn',
  'hin' => 'Deva',
  'myx' => 'Latn',
  'aeb' => 'Arab',
  'zgh' => 'Tfng',
  'snk' => 'Latn',
  'kde' => 'Latn',
  'naq' => 'Latn',
  'new' => 'Deva',
  'rtm' => 'Latn',
  'aii' => 'Cyrl',
  'lkt' => 'Latn',
  'iba' => 'Latn',
  'del' => 'Latn',
  'mkd' => 'Cyrl',
  'zul' => 'Latn',
  'thq' => 'Deva',
  'bra' => 'Deva',
  'kge' => 'Latn',
  'thr' => 'Deva',
  'lad' => 'Hebr',
  'bze' => 'Latn',
  'rkt' => 'Beng',
  'chv' => 'Cyrl',
  'gbm' => 'Deva',
  'mua' => 'Latn',
  'kom' => 'Cyrl',
  'fra' => 'Latn',
  'noe' => 'Deva',
  'dua' => 'Latn',
  'gla' => 'Latn',
  'zea' => 'Latn',
  'mgo' => 'Latn',
  'sin' => 'Sinh',
  'rjs' => 'Deva',
  'hup' => 'Latn',
  'aym' => 'Latn',
  'rej' => 'Latn',
  'vec' => 'Latn',
  'nbl' => 'Latn',
  'vls' => 'Latn',
  'cjm' => 'Cham',
  'ach' => 'Latn',
  'srb' => 'Latn',
  'wbp' => 'Latn',
  'crk' => 'Cans',
  'kyu' => 'Kali',
  'lep' => 'Lepc',
  'iii' => 'Yiii',
  'bvb' => 'Latn',
  'mya' => 'Mymr',
  'rof' => 'Latn',
  'nym' => 'Latn',
  'zmi' => 'Latn',
  'udm' => 'Cyrl',
  'aoz' => 'Latn',
  'jam' => 'Latn',
  'spa' => 'Latn',
  'gld' => 'Cyrl',
  'nch' => 'Latn',
  'sah' => 'Cyrl',
  'mgy' => 'Latn',
  'ipk' => 'Latn',
  'mzn' => 'Arab',
  'pol' => 'Latn',
  'asm' => 'Beng',
  'ton' => 'Latn',
  'hil' => 'Latn',
  'dyo' => 'Latn',
  'kab' => 'Latn',
  'bto' => 'Latn',
  'eus' => 'Latn',
  'yor' => 'Latn',
  'lao' => 'Laoo',
  'esu' => 'Latn',
  'mdh' => 'Latn',
  'sck' => 'Deva',
  'njo' => 'Latn',
  'fry' => 'Latn',
  'swa' => 'Latn',
  'nno' => 'Latn',
  'arp' => 'Latn',
  'zap' => 'Latn',
  'vmf' => 'Latn',
  'inh' => 'Cyrl',
  'nav' => 'Latn',
  'laj' => 'Latn',
  'ale' => 'Latn',
  'lbw' => 'Latn',
  'tts' => 'Thai',
  'bug' => 'Latn',
  'lrc' => 'Arab',
  'nxq' => 'Latn',
  'tdd' => 'Tale',
  'grb' => 'Latn',
  'sdh' => 'Arab',
  'ssy' => 'Latn',
  'hop' => 'Latn',
  'rap' => 'Latn',
  'kpe' => 'Latn',
  'bjn' => 'Latn',
  'mfe' => 'Latn',
  'mlt' => 'Latn',
  'fuv' => 'Latn',
  'ltz' => 'Latn',
  'khn' => 'Deva',
  'kbd' => 'Cyrl',
  'akz' => 'Latn',
  'war' => 'Latn',
  'gbz' => 'Arab',
  'arn' => 'Latn',
  'lun' => 'Latn',
  'kum' => 'Cyrl',
  'yav' => 'Latn',
  'sot' => 'Latn',
  'pap' => 'Latn',
  'gan' => 'Hans',
  'lit' => 'Latn',
  'sms' => 'Latn',
  'mnu' => 'Latn',
  'mah' => 'Latn',
  'guj' => 'Gujr',
  'lij' => 'Latn',
  'was' => 'Latn',
  'mns' => 'Cyrl',
  'kfo' => 'Latn',
  'agq' => 'Latn',
  'ewe' => 'Latn',
  'taj' => 'Deva',
  'tbw' => 'Latn',
  'ita' => 'Latn',
  'kvr' => 'Latn',
  'pko' => 'Latn',
  'bas' => 'Latn',
  'bho' => 'Deva',
  'nus' => 'Latn',
  'ude' => 'Cyrl',
  'kfy' => 'Deva',
  'hat' => 'Latn',
  'kos' => 'Latn',
  'tsn' => 'Latn',
  'hun' => 'Latn',
  'min' => 'Latn',
  'ckt' => 'Cyrl',
  'kxm' => 'Thai',
  'rmu' => 'Latn',
  'sef' => 'Latn',
  'bub' => 'Cyrl',
  'dje' => 'Latn',
  'mni' => 'Beng',
  'dan' => 'Latn',
  'hsn' => 'Hans',
  'byv' => 'Latn',
  'syl' => 'Beng',
  'fas' => 'Arab',
  'tat' => 'Cyrl',
  'gju' => 'Arab',
  'xal' => 'Cyrl',
  'cjs' => 'Cyrl',
  'mwl' => 'Latn',
  'chk' => 'Latn',
  'kor' => 'Kore',
  'wae' => 'Latn',
  'bar' => 'Latn',
  'din' => 'Latn',
  'mvy' => 'Arab',
  'urd' => 'Arab',
  'tru' => 'Latn',
  'pms' => 'Latn',
  'bew' => 'Latn',
  'sly' => 'Latn',
  'amo' => 'Latn',
  'oss' => 'Cyrl',
  'kik' => 'Latn',
  'sme' => 'Latn',
  'bis' => 'Latn',
  'ukr' => 'Cyrl',
  'luy' => 'Latn',
  'szl' => 'Latn',
  'srr' => 'Latn',
  'gil' => 'Latn',
  'frp' => 'Latn',
  'ary' => 'Arab',
  'xnr' => 'Deva',
  'che' => 'Cyrl',
  'tel' => 'Telu',
  'sun' => 'Latn',
  'anp' => 'Deva',
  'sat' => 'Olck',
  'seh' => 'Latn',
  'jpr' => 'Hebr',
  'nds' => 'Latn',
  'moh' => 'Latn',
  'nzi' => 'Latn',
  'tkl' => 'Latn',
  'nqo' => 'Nkoo',
  'mgp' => 'Deva',
  'tso' => 'Latn',
  'dcc' => 'Arab',
  'vie' => 'Latn',
  'sqq' => 'Thai',
  'cay' => 'Latn',
  'ndc' => 'Latn',
  'mdt' => 'Latn',
  'nog' => 'Cyrl',
  'cad' => 'Latn',
  'gay' => 'Latn',
  'yrl' => 'Latn',
  'gjk' => 'Arab',
  'tdh' => 'Deva',
  'bik' => 'Latn',
  'nde' => 'Latn',
  'pcm' => 'Latn',
  'tsd' => 'Grek',
  'kac' => 'Latn',
  'gcr' => 'Latn',
  'kca' => 'Cyrl',
  'rgn' => 'Latn',
  'amh' => 'Ethi',
  'vic' => 'Latn',
  'dtm' => 'Latn',
  'bem' => 'Latn',
  'mon' => 'Cyrl',
  'zdj' => 'Arab',
  'crm' => 'Cans',
  'krj' => 'Latn',
  'uli' => 'Latn',
  'kiu' => 'Latn',
  'raj' => 'Deva',
  'hoj' => 'Deva',
  'sxn' => 'Latn',
  'rng' => 'Latn',
  'nob' => 'Latn',
  'mad' => 'Latn',
  'fvr' => 'Latn',
  'maf' => 'Latn',
  'kau' => 'Latn',
  'kjh' => 'Cyrl',
  'kha' => 'Latn',
  'bfd' => 'Latn',
  'nsk' => 'Cans',
  'lua' => 'Latn',
  'ara' => 'Arab',
  'mal' => 'Mlym',
  'ksb' => 'Latn',
  'stq' => 'Latn',
  'sqi' => 'Latn',
  'luo' => 'Latn',
  'aro' => 'Latn',
  'bkm' => 'Latn',
  'kok' => 'Deva',
  'chr' => 'Cher',
  'teo' => 'Latn',
  'run' => 'Latn',
  'bak' => 'Cyrl',
  'bfy' => 'Deva'
};
$DefaultTerritory = {
  'uig' => 'CN',
  'ff_Adlm' => 'GN',
  'cad' => 'US',
  'ndc' => 'MZ',
  'sn' => 'ZW',
  'sqq' => 'TH',
  'ii' => 'CN',
  'kaz' => 'KZ',
  'tso' => 'ZA',
  'vie' => 'VN',
  'dcc' => 'IN',
  'yo' => 'NG',
  'tkl' => 'TK',
  'nqo' => 'GN',
  'iku' => 'CA',
  'moh' => 'CA',
  'nds' => 'DE',
  'gon' => 'IN',
  'seh' => 'MZ',
  'sun' => 'ID',
  'sat' => 'IN',
  'es' => 'ES',
  'che' => 'RU',
  'xnr' => 'IN',
  'tel' => 'IN',
  'gil' => 'KI',
  'srr' => 'SN',
  'szl' => 'PL',
  'luy' => 'KE',
  'ary' => 'MA',
  'ukr' => 'UA',
  'ku' => 'TR',
  'eu' => 'ES',
  'teo' => 'UG',
  'kas' => 'IN',
  'bak' => 'RU',
  'run' => 'BI',
  'sqi' => 'AL',
  'bos' => 'BA',
  'luo' => 'KE',
  'chr' => 'US',
  'kok' => 'IN',
  'kl' => 'GL',
  'el' => 'GR',
  've' => 'ZA',
  'ksb' => 'TZ',
  'mal' => 'IN',
  'lua' => 'CD',
  'kir' => 'KG',
  'kk' => 'KZ',
  'yue_Hans' => 'CN',
  'kha' => 'IN',
  'fvr' => 'IT',
  'nob' => 'NO',
  'mad' => 'ID',
  'hoj' => 'IN',
  'raj' => 'IN',
  'ky' => 'KG',
  'rn' => 'BI',
  'gaa' => 'GH',
  'amh' => 'ET',
  'zdj' => 'KM',
  'mon' => 'MN',
  'bem' => 'ZM',
  'hi_Latn' => 'IN',
  'gcr' => 'GF',
  'pcm' => 'NG',
  'nde' => 'ZW',
  'bik' => 'PH',
  'az_Cyrl' => 'AZ',
  'sr_Cyrl' => 'RS',
  'chu' => 'RU',
  'ee' => 'GH',
  'th' => 'TH',
  'shr_Latn' => 'MA',
  'ewe' => 'GH',
  'agq' => 'CM',
  'srp_Cyrl' => 'RS',
  'ln' => 'CD',
  'ful_Adlm' => 'GN',
  'uzb_Latn' => 'UZ',
  'guj' => 'IN',
  'shr_Tfng' => 'MA',
  'zh_Hant' => 'TW',
  'sc' => 'IT',
  'mnu' => 'KE',
  'sms' => 'FI',
  'mah' => 'MH',
  'lit' => 'LT',
  'gan' => 'CN',
  'yav' => 'CM',
  'uz_Cyrl' => 'UZ',
  'kum' => 'RU',
  'mr' => 'IN',
  'sot' => 'ZA',
  'kas_Arab' => 'IN',
  'bam_Nkoo' => 'ML',
  'knf' => 'SN',
  'aze_Arab' => 'IR',
  'arn' => 'CL',
  'bg' => 'BG',
  'war' => 'PH',
  'lat' => 'VA',
  'ks_Arab' => 'IN',
  'ltz' => 'LU',
  'kbd' => 'RU',
  'khn' => 'IN',
  'mlt' => 'MT',
  'bjn' => 'ID',
  'mfe' => 'MU',
  'fuv' => 'NG',
  'ssy' => 'ER',
  'kpe' => 'LR',
  'hin_Latn' => 'IN',
  'sdh' => 'IR',
  'tts' => 'TH',
  'lrc' => 'IR',
  'bug' => 'ID',
  'laj' => 'UG',
  'lb' => 'LU',
  'kik' => 'KE',
  'bis' => 'VU',
  'sme' => 'NO',
  'zh_Hans' => 'CN',
  'shi_Latn' => 'MA',
  'oss' => 'GE',
  'tn' => 'ZA',
  'fy' => 'NL',
  'be' => 'BY',
  'urd' => 'PK',
  'shi_Tfng' => 'MA',
  'bew' => 'ID',
  'kor' => 'KR',
  'chk' => 'FM',
  'wae' => 'CH',
  'syl' => 'BD',
  'hsn' => 'CN',
  'aa' => 'ET',
  'fas' => 'IR',
  'tat' => 'RU',
  'dan' => 'DK',
  'mni' => 'IN',
  'mni_Mtei' => 'IN',
  'dje' => 'NE',
  'min' => 'ID',
  'sef' => 'CI',
  'kxm' => 'TH',
  'hat' => 'HT',
  'hun' => 'HU',
  'tsn' => 'ZA',
  'nus' => 'SS',
  'bas' => 'CM',
  'kfy' => 'IN',
  'mt' => 'MT',
  'ita' => 'IT',
  'mey' => 'SN',
  'ig' => 'NG',
  'iii' => 'CN',
  'uz_Arab' => 'AF',
  'ach' => 'UG',
  'ki' => 'KE',
  'wbp' => 'AU',
  'vls' => 'BE',
  'st' => 'ZA',
  'nbl' => 'ZA',
  'rej' => 'ID',
  'sin' => 'LK',
  'aym' => 'BO',
  'mgo' => 'CM',
  'dua' => 'CM',
  'noe' => 'IN',
  'gla' => 'GB',
  'gbm' => 'IN',
  'fo' => 'FO',
  'chv' => 'RU',
  'san' => 'IN',
  'kom' => 'RU',
  'fra' => 'FR',
  'aze_Latn' => 'AZ',
  'mua' => 'CM',
  'bos_Latn' => 'BA',
  'bam' => 'ML',
  'ug' => 'CN',
  'iu' => 'CA',
  'msa' => 'MY',
  'ka' => 'GE',
  'uzb_Arab' => 'AF',
  'bo' => 'CN',
  'vi' => 'VN',
  'zul' => 'ZA',
  'mkd' => 'MK',
  'is' => 'IS',
  'iku_Latn' => 'CA',
  'vmf' => 'DE',
  'inh' => 'RU',
  'wo' => 'SN',
  'nno' => 'NO',
  'swa' => 'TZ',
  'fry' => 'NL',
  'sun_Latn' => 'ID',
  'sck' => 'IN',
  'mdh' => 'PH',
  'lao' => 'LA',
  'yor' => 'NG',
  'hif' => 'FJ',
  'eus' => 'ES',
  'pt' => 'BR',
  'jv' => 'ID',
  'nd' => 'ZW',
  'dyo' => 'SN',
  'sq' => 'AL',
  'kab' => 'DZ',
  'pol' => 'PL',
  'mzn' => 'IR',
  'asm' => 'IN',
  'hil' => 'PH',
  'ton' => 'TO',
  'ff_Latn' => 'SN',
  'sah' => 'RU',
  'jam' => 'JM',
  'spa' => 'ES',
  'kur' => 'TR',
  'uk' => 'UA',
  'eng_Dsrt' => 'US',
  'vai_Latn' => 'LR',
  'udm' => 'RU',
  'rof' => 'TZ',
  'nym' => 'TZ',
  'mya' => 'MM',
  'dzo' => 'BT',
  'ak' => 'GH',
  'mdf' => 'RU',
  'ko' => 'KR',
  'lt' => 'LT',
  'brx' => 'IN',
  'bm_Nkoo' => 'ML',
  'ba' => 'RU',
  'hrv' => 'HR',
  'rm' => 'CH',
  'mn_Mong' => 'CN',
  'mri' => 'NZ',
  'ind' => 'ID',
  'bs_Cyrl' => 'BA',
  'su_Latn' => 'ID',
  'cat' => 'ES',
  'brh' => 'PK',
  'fa' => 'IR',
  'tnr' => 'SN',
  'kam' => 'KE',
  'sd_Deva' => 'IN',
  'men' => 'SL',
  'sid' => 'ET',
  'wuu' => 'CN',
  'trv' => 'TW',
  'lin' => 'CD',
  'lbe' => 'RU',
  'pan_Arab' => 'PK',
  'mtr' => 'IN',
  'bjt' => 'SN',
  'tah' => 'PF',
  'ttb' => 'GH',
  'kw' => 'GB',
  'fi' => 'FI',
  'tr' => 'TR',
  'tet' => 'TL',
  'roh' => 'CH',
  'os' => 'GE',
  'gqr' => 'ID',
  'mgh' => 'MZ',
  'yue_Hant' => 'HK',
  'crs' => 'SC',
  'aar' => 'ET',
  'mfv' => 'SN',
  'hr' => 'HR',
  'gn' => 'PY',
  'bjj' => 'IN',
  'pan_Guru' => 'IN',
  'ne' => 'NP',
  'bsc' => 'SN',
  'lkt' => 'US',
  'tt' => 'RU',
  'zgh' => 'MA',
  'aeb' => 'TN',
  'naq' => 'NA',
  'snk' => 'ML',
  'kde' => 'TZ',
  'snd_Deva' => 'IN',
  'ja' => 'JP',
  'fur' => 'IT',
  'pon' => 'FM',
  'myx' => 'UG',
  'hin' => 'IN',
  'buc' => 'YT',
  'zza' => 'TR',
  'ibo' => 'NG',
  'ny' => 'MW',
  'niu' => 'NU',
  'fuq' => 'NE',
  'xh' => 'ZA',
  'shr' => 'MA',
  'lah' => 'PK',
  'tvl' => 'TV',
  'nnh' => 'CM',
  'bez' => 'TZ',
  'nau' => 'NR',
  'bss' => 'CM',
  'msa_Arab' => 'MY',
  'az_Arab' => 'IR',
  'hne' => 'IN',
  'nl' => 'NL',
  'mn' => 'MN',
  'wa' => 'BE',
  'ron' => 'RO',
  'en_Dsrt' => 'US',
  'as' => 'IN',
  'jav' => 'ID',
  'rif' => 'MA',
  'bgc' => 'IN',
  'wls' => 'WF',
  'id' => 'ID',
  'kas_Deva' => 'IN',
  'zho_Hans' => 'CN',
  'kin' => 'RW',
  'pus' => 'AF',
  'bhi' => 'IN',
  'oc' => 'FR',
  'sat_Olck' => 'IN',
  'asa' => 'TZ',
  'tgk' => 'TJ',
  'skr' => 'PK',
  'si' => 'LK',
  'sav' => 'SN',
  'sma' => 'SE',
  'mni_Beng' => 'IN',
  'mak' => 'ID',
  'ses' => 'ML',
  'et' => 'EE',
  'mwr' => 'IN',
  'sag' => 'CF',
  'lo' => 'LA',
  'mos' => 'BF',
  'est' => 'EE',
  'tuk' => 'TM',
  'sa' => 'IN',
  'syr' => 'IQ',
  'fon' => 'BJ',
  'nya' => 'MW',
  'lv' => 'LV',
  'fil' => 'PH',
  'kan' => 'IN',
  'som' => 'SO',
  'rus' => 'RU',
  'ngl' => 'MZ',
  'bs_Latn' => 'BA',
  'bci' => 'CI',
  'xho' => 'ZA',
  'pag' => 'PH',
  'ebu' => 'KE',
  'doi' => 'IN',
  'bm' => 'ML',
  'kkj' => 'CM',
  'ks_Deva' => 'IN',
  'cos' => 'FR',
  'osa' => 'US',
  'ewo' => 'CM',
  'gd' => 'GB',
  'ms_Arab' => 'MY',
  'tam' => 'IN',
  'ibb' => 'NG',
  'sus' => 'GN',
  'kkt' => 'RU',
  'to' => 'TO',
  'vai_Vaii' => 'LR',
  'dz' => 'BT',
  'tmh' => 'NE',
  'wal' => 'ET',
  'srn' => 'SR',
  'cor' => 'GB',
  'cch' => 'NG',
  'ljp' => 'ID',
  'ful_Latn' => 'SN',
  'sat_Deva' => 'IN',
  'lmn' => 'IN',
  'efi' => 'NG',
  'ha_Arab' => 'NG',
  'bmv' => 'CM',
  'fao' => 'FO',
  'nld' => 'NL',
  'nso' => 'ZA',
  'aka' => 'GH',
  'cym' => 'GB',
  'jpn' => 'JP',
  'wtm' => 'IN',
  'mfa' => 'TH',
  'ban' => 'ID',
  'swv' => 'IN',
  'kon' => 'CD',
  'luz' => 'IR',
  'ckb' => 'IQ',
  'arz' => 'EG',
  'cu' => 'RU',
  'hye' => 'AM',
  'mar' => 'IN',
  'my' => 'MM',
  'gsw' => 'CH',
  'kmb' => 'AO',
  'so' => 'SO',
  'lag' => 'TZ',
  'fan' => 'GQ',
  'gu' => 'IN',
  'slk' => 'SK',
  'cs' => 'CZ',
  'nb' => 'NO',
  'mlg' => 'MG',
  'aln' => 'XK',
  'cgg' => 'UG',
  'dsb' => 'DE',
  'lav' => 'LV',
  'kal' => 'GL',
  'fin' => 'FI',
  'wbq' => 'IN',
  'ml' => 'IN',
  'nn' => 'NO',
  'ady' => 'RU',
  'ceb' => 'PH',
  'zu' => 'ZA',
  'isl' => 'IS',
  'mas' => 'KE',
  'de' => 'DE',
  'tur' => 'TR',
  'wbr' => 'IN',
  'sw' => 'TZ',
  'bod' => 'CN',
  'af' => 'ZA',
  'qu' => 'PE',
  'ndo' => 'NA',
  'bin' => 'NG',
  'myv' => 'RU',
  'sv' => 'SE',
  'pmn' => 'PH',
  'ilo' => 'PH',
  'mk' => 'MK',
  'br' => 'FR',
  'vmw' => 'MZ',
  'lez' => 'RU',
  'ms' => 'MY',
  'zha' => 'CN',
  'bbc' => 'ID',
  'hi' => 'IN',
  'an' => 'ES',
  'wni' => 'KM',
  'ce' => 'RU',
  'mai' => 'IN',
  'glg' => 'ES',
  'bhk' => 'PH',
  'sbp' => 'TZ',
  'wol' => 'SN',
  'cy' => 'GB',
  'swb' => 'YT',
  'fr' => 'FR',
  'rw' => 'RW',
  'hmo' => 'PG',
  'bej' => 'SD',
  'glv' => 'IM',
  'ti' => 'ET',
  'pa_Guru' => 'IN',
  'nyn' => 'UG',
  'arq' => 'DZ',
  'tig' => 'ER',
  'srp_Latn' => 'RS',
  'cha' => 'GU',
  'smn' => 'FI',
  'srd' => 'IT',
  'khq' => 'ML',
  'uzb_Cyrl' => 'UZ',
  'tiv' => 'NG',
  'gl' => 'ES',
  'suk' => 'TZ',
  'cic' => 'US',
  'ta' => 'IN',
  'blt' => 'VN',
  'pa_Arab' => 'PK',
  'km' => 'KH',
  'ori' => 'IN',
  'mg' => 'MG',
  'haw' => 'US',
  'ro' => 'RO',
  'ha' => 'NG',
  'csb' => 'PL',
  'pl' => 'PL',
  'khm' => 'KH',
  'sg' => 'CF',
  'jgo' => 'CM',
  'it' => 'IT',
  'vun' => 'TZ',
  'gv' => 'IM',
  'hoc' => 'IN',
  'kru' => 'IN',
  'oci' => 'FR',
  'kn' => 'IN',
  'cv' => 'RU',
  'en' => 'US',
  'rwk' => 'TZ',
  'pau' => 'PW',
  'bul' => 'BG',
  'fud' => 'WF',
  'nep' => 'NP',
  'kaj' => 'NG',
  'eng' => 'US',
  'am' => 'ET',
  'uz_Latn' => 'UZ',
  'krc' => 'RU',
  'glk' => 'IR',
  'co' => 'FR',
  'hno' => 'PK',
  'abk' => 'GE',
  'ssw' => 'ZA',
  'hak' => 'CN',
  'twq' => 'NE',
  'ss' => 'ZA',
  'kat' => 'GE',
  'aze_Cyrl' => 'AZ',
  'tpi' => 'PG',
  'sk' => 'SK',
  'hau_Arab' => 'NG',
  'bos_Cyrl' => 'BA',
  'ru' => 'RU',
  'tum' => 'MW',
  'ur' => 'PK',
  'ikt' => 'CA',
  'orm' => 'ET',
  'ven' => 'ZA',
  'kln' => 'KE',
  'ife' => 'TG',
  'jmc' => 'TZ',
  'snd_Arab' => 'PK',
  'sas' => 'ID',
  'bel' => 'BY',
  'sl' => 'SI',
  'saq' => 'KE',
  'ps' => 'AF',
  'rcf' => 'RE',
  'ffm' => 'ML',
  'ksh' => 'DE',
  'kri' => 'SL',
  'se' => 'NO',
  'om' => 'ET',
  'ace' => 'ID',
  'sco' => 'GB',
  'slv' => 'SI',
  'nmg' => 'CM',
  'bhb' => 'IN',
  'sd_Arab' => 'PK',
  'unr' => 'IN',
  'mon_Mong' => 'CN',
  'ken' => 'CM',
  'dv' => 'MV',
  'gom' => 'IN',
  'ca' => 'ES',
  'awa' => 'IN',
  'hsb' => 'DE',
  'rmt' => 'IR',
  'iu_Latn' => 'CA',
  'scn' => 'IT',
  'lg' => 'UG',
  'snf' => 'SN',
  'ava' => 'RU',
  'nan' => 'CN',
  'tyv' => 'RU',
  'kea' => 'CV',
  'wln' => 'BE',
  'tha' => 'TH',
  'tk' => 'TM',
  'tir' => 'ET',
  'ga' => 'IE',
  'swe' => 'SE',
  'que' => 'PE',
  'hau' => 'NG',
  'arg' => 'ES',
  'por' => 'BR',
  'lug' => 'UG',
  'te' => 'IN',
  'kcg' => 'NG',
  'mus' => 'US',
  'kdh' => 'SL',
  'lu' => 'CD',
  'abr' => 'GH',
  'bgn' => 'PK',
  'hy' => 'AM',
  'umb' => 'AO',
  'bn' => 'BD',
  'ksf' => 'CM',
  'kdx' => 'KE',
  'shn' => 'MM',
  'he' => 'IL',
  'fij' => 'FJ',
  'nod' => 'TH',
  'guz' => 'KE',
  'ces' => 'CZ',
  'lub' => 'CD',
  'az_Latn' => 'AZ',
  'sr_Latn' => 'RS',
  'mer' => 'KE',
  'xog' => 'UG',
  'ccp' => 'BD',
  'deu' => 'DE',
  'tg' => 'TJ',
  'gle' => 'IE',
  'nr' => 'ZA',
  'kua' => 'NA',
  'ben' => 'BD',
  'tzm' => 'MA',
  'tsg' => 'PH',
  'grn' => 'PY',
  'dav' => 'KE',
  'dyu' => 'BF',
  'tcy' => 'IN',
  'byn' => 'ER',
  'heb' => 'IL',
  'dnj' => 'CI',
  'ell' => 'GR',
  'haz' => 'AF',
  'bre' => 'FR',
  'afr' => 'ZA',
  'da' => 'DK',
  'div' => 'MV',
  'mag' => 'IN',
  'bqi' => 'IR',
  'zho_Hant' => 'TW',
  'or' => 'IN',
  'quc' => 'GT',
  'mi' => 'NZ',
  'smj' => 'SE',
  'hu' => 'HU',
  'ts' => 'ZA',
  'ast' => 'ES',
  'sna' => 'ZW',
  'gez' => 'ET'
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
	my $regex = "\\p\{$_[0]\}";
	if ($_[1]=~/\p{$_[0]}/){
	    if ($_[2]){
		my $count = 0;
		while ($_[1] =~ m/\p{$_[0]}/gs) {$count++};
		return $count;
	    }
	    return 1;
	}
	return 0;
    }
    if ($_[0] eq 'Hans' || $_[0] eq 'Hant'){
	my $script = &simplified_or_traditional_chinese($_[1]);
	if ($script eq $_[0]){
	    return contains_script('Han', $_[1], $_[2]) if ($_[2]);
	    return 1;
	}
	return 0;
    }
    print STDERR "unsupported script $_[0]\n";
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
    my ($str, $lang) = @_;

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
    print STDERR "unknown script $_[0]\n";
    return undef;
}

sub script_name{
    return undef unless(@_);
    return $$ScriptCode2ScriptName{$_[0]} if (exists $$ScriptCode2ScriptName{$_[0]});
    print STDERR "unknown script $_[0]\n";
    return undef;
}

sub language_scripts{
    return () unless(@_);
    return sort keys %{$$Lang2Script{$_[0]}} if (exists $$Lang2Script{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    return sort keys %{$$Lang2Script{$langcode}} if (exists $$Lang2Script{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode,1);
    return sort keys %{$$Lang2Script{$langcode}} if (exists $$Lang2Script{$langcode});
    print STDERR "unknown language $_[0]\n";
    return ();
}

sub default_script{
    return undef unless(@_);
    return $$DefaultScript{$_[0]} if (exists $$DefaultScript{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    return $$DefaultScript{$langcode} if (exists $$DefaultScript{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode,1);
    return $$DefaultScript{$langcode} if (exists $$DefaultScript{$langcode});
    return undef;
}

sub languages_with_script{
    return () unless(@_);
    return sort keys %{$$Script2Lang{$_[0]}} if (exists $$Script2Lang{$_[0]});
    my $code = script_code($_[0]);
    return sort keys %{$$Script2Lang{$code}} if (exists $$Script2Lang{$code});
    print STDERR "unknown script $_[0]\n";
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
    print STDERR "unknown script $_[0]\n";
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
    print STDERR "unknown script $_[0]\n";
    return ();
}



sub language_territories{
    return undef unless(@_);
    return keys %{$$Lang2Territory{$_[0]}} if (exists $$Lang2Territory{$_[0]});
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    return sort keys %{$$Lang2Territory{$langcode}} if (exists $$Lang2Territory{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode,1);
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
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    return $$DefaultTerritory{$langcode} if (exists $$DefaultTerritory{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode,1);
    return $$DefaultTerritory{$langcode} if (exists $$DefaultTerritory{$langcode});
    return 'XX';
}

sub primary_territories{
    return () unless(@_);
    if (exists $$Lang2Territory{$_[0]}){
	return grep($$Lang2Territory{$_[0]}{$_} == 1, keys %{$$Lang2Territory{$_[0]}});
    }
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    if (exists $$Lang2Territory{$langcode}){
	return grep($$Lang2Territory{$langcode}{$_} == 1, keys %{$$Lang2Territory{$langcode}});
    }
    $langcode = ISO::639::3::get_macro_language($langcode,1);
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
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    if (exists $$Lang2Territory{$langcode}){
	return grep($$Lang2Territory{$langcode}{$_} == 2, keys %{$$Lang2Territory{$langcode}});
    }
    $langcode = ISO::639::3::get_macro_language($langcode,1);
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


