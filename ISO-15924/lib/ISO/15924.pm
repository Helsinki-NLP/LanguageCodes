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
  'Elba' => 'Elbasan',
  'Medf' => 'Medefaidrin',
  'Java' => 'Javanese',
  'Dsrt' => 'Deseret',
  'Loma' => '',
  'Buhd' => 'Buhid',
  'Nshu' => 'Nushu',
  'Armn' => 'Armenian',
  'Syrn' => '',
  'Jamo' => '',
  'Thai' => 'Thai',
  'Ahom' => 'Ahom',
  'Tglg' => 'Tagalog',
  'Cprt' => 'Cypriot',
  'Wole' => '',
  'Jurc' => '',
  'Blis' => '',
  'Cirt' => '',
  'Geok' => 'Georgian',
  'Hatr' => 'Hatran',
  'Laoo' => 'Lao',
  'Taml' => 'Tamil',
  'Mult' => 'Multani',
  'Sarb' => 'Old_South_Arabian',
  'Sind' => 'Khudawadi',
  'Batk' => 'Batak',
  'Phlp' => 'Psalter_Pahlavi',
  'Beng' => 'Bengali',
  'Gujr' => 'Gujarati',
  'Bhks' => 'Bhaiksuki',
  'Leke' => '',
  'Kore' => '',
  'Teng' => '',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Zanb' => 'Zanabazar_Square',
  'Nkoo' => 'Nko',
  'Shui' => '',
  'Syrj' => '',
  'Glag' => 'Glagolitic',
  'Rohg' => 'Hanifi_Rohingya',
  'Adlm' => 'Adlam',
  'Cans' => 'Canadian_Aboriginal',
  'Zxxx' => '',
  'Sogd' => 'Sogdian',
  'Cyrl' => 'Cyrillic',
  'Deva' => 'Devanagari',
  'Runr' => 'Runic',
  'Syrc' => 'Syriac',
  'Syre' => '',
  'Diak' => 'Dives_Akuru',
  'Gran' => 'Grantha',
  'Ugar' => 'Ugaritic',
  'Hebr' => 'Hebrew',
  'Afak' => '',
  'Xsux' => 'Cuneiform',
  'Grek' => 'Greek',
  'Phnx' => 'Phoenician',
  'Lisu' => 'Lisu',
  'Modi' => 'Modi',
  'Ogam' => 'Ogham',
  'Cakm' => 'Chakma',
  'Latn' => 'Latin',
  'Tibt' => 'Tibetan',
  'Orkh' => 'Old_Turkic',
  'Merc' => 'Meroitic_Cursive',
  'Hmng' => 'Pahawh_Hmong',
  'Ital' => 'Old_Italic',
  'Talu' => 'New_Tai_Lue',
  'Kali' => 'Kayah_Li',
  'Hanb' => '',
  'Khmr' => 'Khmer',
  'Tang' => 'Tangut',
  'Telu' => 'Telugu',
  'Brai' => 'Braille',
  'Maya' => '',
  'Qabx' => '',
  'Lina' => 'Linear_A',
  'Tavt' => 'Tai_Viet',
  'Hant' => '',
  'Bamu' => 'Bamum',
  'Zyyy' => 'Common',
  'Sogo' => 'Old_Sogdian',
  'Xpeo' => 'Old_Persian',
  'Aghb' => 'Caucasian_Albanian',
  'Osma' => 'Osmanya',
  'Nbat' => 'Nabataean',
  'Bass' => 'Bassa_Vah',
  'Kana' => 'Katakana',
  'Nkdb' => '',
  'Mend' => 'Mende_Kikakui',
  'Inds' => '',
  'Lana' => 'Tai_Tham',
  'Sinh' => 'Sinhala',
  'Mand' => 'Mandaic',
  'Bali' => 'Balinese',
  'Aran' => '',
  'Sara' => '',
  'Maka' => 'Makasar',
  'Qaaa' => '',
  'Avst' => 'Avestan',
  'Lepc' => 'Lepcha',
  'Ethi' => 'Ethiopic',
  'Orya' => 'Oriya',
  'Vaii' => 'Vai',
  'Bopo' => 'Bopomofo',
  'Hano' => 'Hanunoo',
  'Nand' => 'Nandinagari',
  'Bugi' => 'Buginese',
  'Phlv' => '',
  'Guru' => 'Gurmukhi',
  'Sora' => 'Sora_Sompeng',
  'Mong' => 'Mongolian',
  'Wcho' => 'Wancho',
  'Hung' => 'Old_Hungarian',
  'Linb' => 'Linear_B',
  'Cari' => 'Carian',
  'Saur' => 'Saurashtra',
  'Soyo' => 'Soyombo',
  'Armi' => 'Imperial_Aramaic',
  'Olck' => 'Ol_Chiki',
  'Mroo' => 'Mro',
  'Marc' => 'Marchen',
  'Knda' => 'Kannada',
  'Thaa' => 'Thaana',
  'Visp' => '',
  'Zsye' => '',
  'Nkgb' => '',
  'Latg' => '',
  'Hani' => 'Han',
  'Dogr' => 'Dogra',
  'Phli' => 'Inscriptional_Pahlavi',
  'Pauc' => 'Pau_Cin_Hau',
  'Zsym' => '',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Cham' => 'Cham',
  'Hang' => 'Hangul',
  'Gonm' => 'Masaram_Gondi',
  'Dupl' => 'Duployan',
  'Zzzz' => 'Unknown',
  'Palm' => 'Palmyrene',
  'Shaw' => 'Shavian',
  'Prti' => 'Inscriptional_Parthian',
  'Perm' => 'Old_Permic',
  'Gong' => 'Gunjala_Gondi',
  'Osge' => 'Osage',
  'Moon' => '',
  'Arab' => 'Arabic',
  'Mymr' => 'Myanmar',
  'Brah' => 'Brahmi',
  'Cyrs' => '',
  'Zmth' => '',
  'Samr' => 'Samaritan',
  'Kpel' => '',
  'Lydi' => 'Lydian',
  'Khar' => 'Kharoshthi',
  'Hira' => 'Hiragana',
  'Khoj' => 'Khojki',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Kitl' => '',
  'Cpmn' => '',
  'Cher' => 'Cherokee',
  'Takr' => 'Takri',
  'Geor' => 'Georgian',
  'Sidd' => 'Siddham',
  'Kthi' => 'Kaithi',
  'Yezi' => 'Yezidi',
  'Yiii' => 'Yi',
  'Tagb' => 'Tagbanwa',
  'Mlym' => 'Malayalam',
  'Plrd' => 'Miao',
  'Lyci' => 'Lycian',
  'Kits' => 'Khitan_Small_Script',
  'Hans' => '',
  'Roro' => '',
  'Sgnw' => 'SignWriting',
  'Mahj' => 'Mahajani',
  'Tale' => 'Tai_Le',
  'Egyh' => '',
  'Rjng' => 'Rejang',
  'Newa' => 'Newa',
  'Zinh' => 'Inherited',
  'Egyd' => '',
  'Tfng' => 'Tifinagh',
  'Chrs' => 'Chorasmian',
  'Toto' => '',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Sylo' => 'Syloti_Nagri',
  'Sund' => 'Sundanese',
  'Copt' => 'Coptic',
  'Jpan' => '',
  'Mtei' => 'Meetei_Mayek',
  'Latf' => '',
  'Elym' => 'Elymaic',
  'Piqd' => '',
  'Narb' => 'Old_North_Arabian',
  'Phag' => 'Phags_Pa',
  'Tirh' => 'Tirhuta',
  'Shrd' => 'Sharada',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Goth' => 'Gothic',
  'Mani' => 'Manichaean',
  'Wara' => 'Warang_Citi',
  'Limb' => 'Limbu'
};
$ScriptName2ScriptCode = {
  'Shavian' => 'Shaw',
  'Carian' => 'Cari',
  'Chakma' => 'Cakm',
  'Ugaritic' => 'Ugar',
  'Zanabazar_Square' => 'Zanb',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Javanese' => 'Java',
  'Brahmi' => 'Brah',
  'Hiragana' => 'Hira',
  'Adlam' => 'Adlm',
  'Gunjala_Gondi' => 'Gong',
  'Han' => 'Hani',
  'Batak' => 'Batk',
  'Lycian' => 'Lyci',
  'Buhid' => 'Buhd',
  'Chorasmian' => 'Chrs',
  'Tifinagh' => 'Tfng',
  'Sogdian' => 'Sogd',
  'Bengali' => 'Beng',
  'Newa' => 'Newa',
  'Khojki' => 'Khoj',
  'Inscriptional_Pahlavi' => 'Phli',
  'Balinese' => 'Bali',
  'Coptic' => 'Copt',
  'Old_Italic' => 'Ital',
  'Phags_Pa' => 'Phag',
  'Syloti_Nagri' => 'Sylo',
  'Katakana' => 'Kana',
  'Old_Hungarian' => 'Hung',
  'Old_Persian' => 'Xpeo',
  'Gothic' => 'Goth',
  'Malayalam' => 'Mlym',
  'Inherited' => 'Zinh',
  'Old_South_Arabian' => 'Sarb',
  'Tai_Viet' => 'Tavt',
  'Limbu' => 'Limb',
  'Bopomofo' => 'Bopo',
  'Gurmukhi' => 'Guru',
  'Runic' => 'Runr',
  'Takri' => 'Takr',
  'Lydian' => 'Lydi',
  'Mro' => 'Mroo',
  'Tamil' => 'Taml',
  'Linear_B' => 'Linb',
  'Tai_Le' => 'Tale',
  'Elymaic' => 'Elym',
  'Kaithi' => 'Kthi',
  'Greek' => 'Grek',
  'Khudawadi' => 'Sind',
  'Myanmar' => 'Mymr',
  'Duployan' => 'Dupl',
  'Khitan_Small_Script' => 'Kits',
  'Common' => 'Zyyy',
  'Ethiopic' => 'Ethi',
  '' => 'Zxxx',
  'Grantha' => 'Gran',
  'Mandaic' => 'Mand',
  'Vai' => 'Vaii',
  'Sinhala' => 'Sinh',
  'Sora_Sompeng' => 'Sora',
  'Saurashtra' => 'Saur',
  'Georgian' => 'Geor',
  'Cherokee' => 'Cher',
  'Dogra' => 'Dogr',
  'Cham' => 'Cham',
  'Ogham' => 'Ogam',
  'Osage' => 'Osge',
  'Unknown' => 'Zzzz',
  'Meroitic_Cursive' => 'Merc',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Glagolitic' => 'Glag',
  'Palmyrene' => 'Palm',
  'Bamum' => 'Bamu',
  'Hebrew' => 'Hebr',
  'Kannada' => 'Knda',
  'Tangut' => 'Tang',
  'Pahawh_Hmong' => 'Hmng',
  'Rejang' => 'Rjng',
  'Cyrillic' => 'Cyrl',
  'Makasar' => 'Maka',
  'Syriac' => 'Syrc',
  'Bhaiksuki' => 'Bhks',
  'Multani' => 'Mult',
  'Lisu' => 'Lisu',
  'Modi' => 'Modi',
  'Siddham' => 'Sidd',
  'Oriya' => 'Orya',
  'Old_Turkic' => 'Orkh',
  'Lao' => 'Laoo',
  'Latin' => 'Latn',
  'Tagalog' => 'Tglg',
  'Warang_Citi' => 'Wara',
  'Elbasan' => 'Elba',
  'Sharada' => 'Shrd',
  'Yi' => 'Yiii',
  'Telugu' => 'Telu',
  'Tirhuta' => 'Tirh',
  'New_Tai_Lue' => 'Talu',
  'Old_Permic' => 'Perm',
  'SignWriting' => 'Sgnw',
  'Hangul' => 'Hang',
  'Medefaidrin' => 'Medf',
  'Armenian' => 'Armn',
  'Tibetan' => 'Tibt',
  'Kayah_Li' => 'Kali',
  'Marchen' => 'Marc',
  'Inscriptional_Parthian' => 'Prti',
  'Gujarati' => 'Gujr',
  'Hatran' => 'Hatr',
  'Arabic' => 'Arab',
  'Cypriot' => 'Cprt',
  'Tai_Tham' => 'Lana',
  'Deseret' => 'Dsrt',
  'Bassa_Vah' => 'Bass',
  'Thaana' => 'Thaa',
  'Linear_A' => 'Lina',
  'Old_Sogdian' => 'Sogo',
  'Hanifi_Rohingya' => 'Rohg',
  'Braille' => 'Brai',
  'Buginese' => 'Bugi',
  'Mende_Kikakui' => 'Mend',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Dives_Akuru' => 'Diak',
  'Lepcha' => 'Lepc',
  'Old_North_Arabian' => 'Narb',
  'Cuneiform' => 'Xsux',
  'Wancho' => 'Wcho',
  'Nabataean' => 'Nbat',
  'Khmer' => 'Khmr',
  'Thai' => 'Thai',
  'Ahom' => 'Ahom',
  'Miao' => 'Plrd',
  'Imperial_Aramaic' => 'Armi',
  'Sundanese' => 'Sund',
  'Mahajani' => 'Mahj',
  'Mongolian' => 'Mong',
  'Avestan' => 'Avst',
  'Nko' => 'Nkoo',
  'Devanagari' => 'Deva',
  'Caucasian_Albanian' => 'Aghb',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Ol_Chiki' => 'Olck',
  'Pau_Cin_Hau' => 'Pauc',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Meetei_Mayek' => 'Mtei',
  'Tagbanwa' => 'Tagb',
  'Psalter_Pahlavi' => 'Phlp',
  'Nandinagari' => 'Nand',
  'Masaram_Gondi' => 'Gonm',
  'Hanunoo' => 'Hano',
  'Canadian_Aboriginal' => 'Cans',
  'Osmanya' => 'Osma',
  'Nushu' => 'Nshu',
  'Soyombo' => 'Soyo',
  'Phoenician' => 'Phnx',
  'Yezidi' => 'Yezi',
  'Manichaean' => 'Mani',
  'Kharoshthi' => 'Khar',
  'Samaritan' => 'Samr'
};
$ScriptId2ScriptCode = {
  '095' => 'Sgnw',
  '499' => 'Nshu',
  '339' => 'Zanb',
  '239' => 'Aghb',
  '321' => 'Takr',
  '340' => 'Telu',
  '166' => 'Adlm',
  '200' => 'Grek',
  '020' => 'Xsux',
  '366' => 'Maka',
  '131' => 'Phli',
  '130' => 'Prti',
  '372' => 'Buhd',
  '312' => 'Gong',
  '127' => 'Hatr',
  '294' => 'Toto',
  '328' => 'Dogr',
  '135' => 'Syrc',
  '358' => 'Cham',
  '240' => 'Geor',
  '263' => 'Pauc',
  '365' => 'Batk',
  '287' => 'Kore',
  '332' => 'Marc',
  '620' => 'Roro',
  '241' => 'Geok',
  '265' => 'Medf',
  '502' => 'Hant',
  '126' => 'Palm',
  '445' => 'Cher',
  '136' => 'Syrn',
  '204' => 'Copt',
  '331' => 'Phag',
  '202' => 'Lyci',
  '302' => 'Sidd',
  '356' => 'Laoo',
  '100' => 'Mero',
  '305' => 'Khar',
  '610' => 'Inds',
  '995' => 'Zmth',
  '210' => 'Ital',
  '212' => 'Ogam',
  '167' => 'Rohg',
  '125' => 'Hebr',
  '040' => 'Ugar',
  '355' => 'Khmr',
  '349' => 'Cakm',
  '335' => 'Lepc',
  '105' => 'Sarb',
  '288' => 'Kits',
  '330' => 'Tibt',
  '436' => 'Kpel',
  '949' => 'Qabx',
  '201' => 'Cari',
  '337' => 'Mtei',
  '142' => 'Sogo',
  '338' => 'Ahom',
  '116' => 'Lydi',
  '316' => 'Sylo',
  '399' => 'Lisu',
  '085' => 'Nkdb',
  '080' => 'Hluw',
  '320' => 'Gujr',
  '261' => 'Olck',
  '109' => 'Chrs',
  '050' => 'Egyp',
  '345' => 'Knda',
  '325' => 'Beng',
  '139' => 'Mani',
  '440' => 'Cans',
  '192' => 'Yezi',
  '326' => 'Tirh',
  '570' => 'Brai',
  '510' => 'Jurc',
  '357' => 'Kali',
  '225' => 'Glag',
  '324' => 'Modi',
  '262' => 'Wara',
  '373' => 'Tagb',
  '353' => 'Tale',
  '280' => 'Visp',
  '413' => 'Jpan',
  '439' => 'Afak',
  '217' => 'Latf',
  '336' => 'Limb',
  '520' => 'Tang',
  '344' => 'Saur',
  '106' => 'Narb',
  '161' => 'Aran',
  '323' => 'Mult',
  '371' => 'Hano',
  '360' => 'Bali',
  '160' => 'Arab',
  '410' => 'Hira',
  '138' => 'Syre',
  '293' => 'Piqd',
  '219' => 'Osge',
  '346' => 'Taml',
  '070' => 'Egyd',
  '101' => 'Merc',
  '350' => 'Mymr',
  '291' => 'Cirt',
  '311' => 'Nand',
  '137' => 'Syrj',
  '315' => 'Deva',
  '319' => 'Shrd',
  '342' => 'Diak',
  '264' => 'Mroo',
  '115' => 'Phnx',
  '286' => 'Hang',
  '282' => 'Plrd',
  '333' => 'Newa',
  '176' => 'Hung',
  '313' => 'Gonm',
  '285' => 'Bopo',
  '398' => 'Sora',
  '351' => 'Lana',
  '260' => 'Osma',
  '175' => 'Orkh',
  '215' => 'Latn',
  '359' => 'Tavt',
  '317' => 'Kthi',
  '550' => 'Blis',
  '211' => 'Runr',
  '090' => 'Maya',
  '124' => 'Armi',
  '284' => 'Jamo',
  '134' => 'Avst',
  '438' => 'Mend',
  '505' => 'Kitl',
  '250' => 'Dsrt',
  '437' => 'Loma',
  '283' => 'Wcho',
  '206' => 'Goth',
  '318' => 'Sind',
  '352' => 'Thai',
  '420' => 'Nkgb',
  '500' => 'Hani',
  '364' => 'Leke',
  '165' => 'Nkoo',
  '994' => 'Zinh',
  '367' => 'Bugi',
  '226' => 'Elba',
  '451' => 'Hmnp',
  '450' => 'Hmng',
  '334' => 'Bhks',
  '310' => 'Guru',
  '300' => 'Brah',
  '159' => 'Nbat',
  '329' => 'Soyo',
  '435' => 'Bamu',
  '060' => 'Egyh',
  '123' => 'Samr',
  '292' => 'Sara',
  '402' => 'Cpmn',
  '370' => 'Tglg',
  '141' => 'Sogd',
  '343' => 'Gran',
  '030' => 'Xpeo',
  '412' => 'Hrkt',
  '401' => 'Linb',
  '362' => 'Sund',
  '900' => 'Qaaa',
  '347' => 'Mlym',
  '403' => 'Cprt',
  '996' => 'Zsym',
  '363' => 'Rjng',
  '999' => 'Zzzz',
  '140' => 'Mand',
  '460' => 'Yiii',
  '348' => 'Sinh',
  '993' => 'Zsye',
  '430' => 'Ethi',
  '322' => 'Khoj',
  '132' => 'Phlp',
  '400' => 'Lina',
  '120' => 'Tfng',
  '354' => 'Talu',
  '314' => 'Mahj',
  '218' => 'Moon',
  '145' => 'Mong',
  '998' => 'Zyyy',
  '480' => 'Wole',
  '503' => 'Hanb',
  '227' => 'Perm',
  '755' => 'Dupl',
  '133' => 'Phlv',
  '411' => 'Kana',
  '530' => 'Shui',
  '281' => 'Shaw',
  '220' => 'Cyrl',
  '361' => 'Java',
  '997' => 'Zxxx',
  '259' => 'Bass',
  '128' => 'Elym',
  '327' => 'Orya',
  '470' => 'Vaii',
  '501' => 'Hans',
  '170' => 'Thaa',
  '290' => 'Teng',
  '221' => 'Cyrs',
  '216' => 'Latg',
  '230' => 'Armn'
};
$ScriptCode2EnglishName = {
  'Hmng' => 'Pahawh Hmong',
  'Merc' => 'Meroitic Cursive',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Khmr' => 'Khmer',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Talu' => 'New Tai Lue',
  'Kali' => 'Kayah Li',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Lisu' => 'Lisu (Fraser)',
  'Phnx' => 'Phoenician',
  'Grek' => 'Greek',
  'Tibt' => 'Tibetan',
  'Latn' => 'Latin',
  'Ogam' => 'Ogham',
  'Cakm' => 'Chakma',
  'Osma' => 'Osmanya',
  'Aghb' => 'Caucasian Albanian',
  'Xpeo' => 'Old Persian',
  'Bass' => 'Bassa Vah',
  'Nbat' => 'Nabataean',
  'Tang' => 'Tangut',
  'Telu' => 'Telugu',
  'Zyyy' => 'Code for undetermined script',
  'Bamu' => 'Bamum',
  'Sogo' => 'Old Sogdian',
  'Tavt' => 'Tai Viet',
  'Hant' => 'Han (Traditional variant)',
  'Lina' => 'Linear A',
  'Qabx' => 'Reserved for private use (end)',
  'Brai' => 'Braille',
  'Maya' => 'Mayan hieroglyphs',
  'Bali' => 'Balinese',
  'Mand' => 'Mandaic, Mandaean',
  'Sinh' => 'Sinhala',
  'Lana' => 'Tai Tham (Lanna)',
  'Sara' => 'Sarati',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Mend' => 'Mende Kikakui',
  'Inds' => 'Indus (Harappan)',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Kana' => 'Katakana',
  'Orya' => 'Oriya (Odia)',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Nand' => 'Nandinagari',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Bopo' => 'Bopomofo',
  'Vaii' => 'Vai',
  'Avst' => 'Avestan',
  'Qaaa' => 'Reserved for private use (start)',
  'Maka' => 'Makasar',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Armn' => 'Armenian',
  'Syrn' => 'Syriac (Eastern variant)',
  'Loma' => 'Loma',
  'Dsrt' => 'Deseret (Mormon)',
  'Java' => 'Javanese',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Elba' => 'Elbasan',
  'Nshu' => "N\x{fc}shu",
  'Buhd' => 'Buhid',
  'Phlp' => 'Psalter Pahlavi',
  'Beng' => 'Bengali (Bangla)',
  'Batk' => 'Batak',
  'Sind' => 'Khudawadi, Sindhi',
  'Mult' => 'Multani',
  'Sarb' => 'Old South Arabian',
  'Leke' => 'Leke',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Gujr' => 'Gujarati',
  'Bhks' => 'Bhaiksuki',
  'Hatr' => 'Hatran',
  'Wole' => 'Woleai',
  'Jurc' => 'Jurchen',
  'Blis' => 'Blissymbols',
  'Cirt' => 'Cirth',
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Ahom' => 'Ahom, Tai Ahom',
  'Cprt' => 'Cypriot syllabary',
  'Thai' => 'Thai',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Taml' => 'Tamil',
  'Laoo' => 'Lao',
  'Sogd' => 'Sogdian',
  'Zxxx' => 'Code for unwritten documents',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Adlm' => 'Adlam',
  'Teng' => 'Tengwar',
  'Syrj' => 'Syriac (Western variant)',
  'Rohg' => 'Hanifi Rohingya',
  'Glag' => 'Glagolitic',
  'Shui' => 'Shuishu',
  'Nkoo' => "N\x{2019}Ko",
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Mero' => 'Meroitic Hieroglyphs',
  'Ugar' => 'Ugaritic',
  'Gran' => 'Grantha',
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Hebr' => 'Hebrew',
  'Afak' => 'Afaka',
  'Deva' => 'Devanagari (Nagari)',
  'Cyrl' => 'Cyrillic',
  'Diak' => 'Dives Akuru',
  'Syre' => 'Syriac (Estrangelo variant)',
  'Syrc' => 'Syriac',
  'Runr' => 'Runic',
  'Hans' => 'Han (Simplified variant)',
  'Kits' => 'Khitan small script',
  'Roro' => 'Rongorongo',
  'Mlym' => 'Malayalam',
  'Tagb' => 'Tagbanwa',
  'Yiii' => 'Yi',
  'Yezi' => 'Yezidi',
  'Lyci' => 'Lycian',
  'Plrd' => 'Miao (Pollard)',
  'Egyh' => 'Egyptian hieratic',
  'Egyd' => 'Egyptian demotic',
  'Zinh' => 'Code for inherited script',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Sgnw' => 'SignWriting',
  'Tale' => 'Tai Le',
  'Mahj' => 'Mahajani',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Elym' => 'Elymaic',
  'Tirh' => 'Tirhuta',
  'Phag' => 'Phags-pa',
  'Sund' => 'Sundanese',
  'Copt' => 'Coptic',
  'Sylo' => 'Syloti Nagri',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Toto' => 'Toto',
  'Tfng' => 'Tifinagh (Berber)',
  'Chrs' => 'Chorasmian',
  'Latf' => 'Latin (Fraktur variant)',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Limb' => 'Limbu',
  'Egyp' => 'Egyptian hieroglyphs',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Goth' => 'Gothic',
  'Mani' => 'Manichaean',
  'Knda' => 'Kannada',
  'Mroo' => 'Mro, Mru',
  'Marc' => 'Marchen',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Armi' => 'Imperial Aramaic',
  'Zsye' => 'Symbols (Emoji variant)',
  'Thaa' => 'Thaana',
  'Visp' => 'Visible Speech',
  'Sora' => 'Sora Sompeng',
  'Mong' => 'Mongolian',
  'Phlv' => 'Book Pahlavi',
  'Guru' => 'Gurmukhi',
  'Bugi' => 'Buginese',
  'Soyo' => 'Soyombo',
  'Cari' => 'Carian',
  'Saur' => 'Saurashtra',
  'Linb' => 'Linear B',
  'Wcho' => 'Wancho',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Phli' => 'Inscriptional Pahlavi',
  'Dogr' => 'Dogra',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Zsym' => 'Symbols',
  'Pauc' => 'Pau Cin Hau',
  'Latg' => 'Latin (Gaelic variant)',
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Brah' => 'Brahmi',
  'Mymr' => 'Myanmar (Burmese)',
  'Arab' => 'Arabic',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Kpel' => 'Kpelle',
  'Samr' => 'Samaritan',
  'Zmth' => 'Mathematical notation',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Zzzz' => 'Code for uncoded script',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Gonm' => 'Masaram Gondi',
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Cham' => 'Cham',
  'Perm' => 'Old Permic',
  'Gong' => 'Gunjala Gondi',
  'Osge' => 'Osage',
  'Palm' => 'Palmyrene',
  'Shaw' => 'Shavian (Shaw)',
  'Prti' => 'Inscriptional Parthian',
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Cher' => 'Cherokee',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Kthi' => 'Kaithi',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Kitl' => 'Khitan large script',
  'Khoj' => 'Khojki',
  'Hira' => 'Hiragana',
  'Khar' => 'Kharoshthi',
  'Lydi' => 'Lydian',
  'Cpmn' => 'Cypro-Minoan'
};
$ScriptCode2FrenchName = {
  'Inds' => 'indus',
  'Mend' => "mend\x{e9} kikakui",
  'Kana' => 'katakana',
  'Nkdb' => 'naxi dongba',
  'Sara' => 'sarati',
  'Aran' => 'arabe (variante nastalique)',
  'Bali' => 'balinais',
  'Lana' => "ta\x{ef} tham (lanna)",
  'Sinh' => 'singhalais',
  'Mand' => "mand\x{e9}en",
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Avst' => 'avestique',
  'Maka' => 'makassar',
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Vaii' => "va\x{ef}",
  'Bopo' => 'bopomofo',
  'Hano' => "hanoun\x{f3}o",
  'Orya' => "oriy\x{e2} (odia)",
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Ogam' => 'ogam',
  'Latn' => 'latin',
  'Cakm' => 'chakma',
  'Tibt' => "tib\x{e9}tain",
  'Lisu' => 'lisu (Fraser)',
  'Modi' => "mod\x{ee}",
  'Grek' => 'grec',
  'Phnx' => "ph\x{e9}nicien",
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Talu' => "nouveau ta\x{ef}-lue",
  'Kali' => 'kayah li',
  'Khmr' => 'khmer',
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Hmng' => 'pahawh hmong',
  'Orkh' => 'orkhon',
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Lina' => "lin\x{e9}aire A",
  'Bamu' => 'bamoum',
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Sogo' => 'ancien sogdien',
  'Brai' => 'braille',
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Telu' => "t\x{e9}lougou",
  'Tang' => 'tangoute',
  'Bass' => 'bassa',
  'Nbat' => "nabat\x{e9}en",
  'Aghb' => 'aghbanien',
  'Osma' => 'osmanais',
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Nkoo' => "n\x{2019}ko",
  'Shui' => 'shuishu',
  'Syrj' => 'syriaque (variante occidentale)',
  'Glag' => 'glagolitique',
  'Rohg' => 'hanifi rohingya',
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Zanb' => 'zanabazar quadratique',
  'Teng' => 'tengwar',
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Sogd' => 'sogdien',
  'Adlm' => 'adlam',
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Diak' => 'dives akuru',
  'Runr' => 'runique',
  'Syrc' => 'syriaque',
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Cyrl' => 'cyrillique',
  'Afak' => 'afaka',
  'Hebr' => "h\x{e9}breu",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Gran' => 'grantha',
  'Ugar' => 'ougaritique',
  'Nshu' => "n\x{fc}shu",
  'Buhd' => 'bouhide',
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Loma' => 'loma',
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Elba' => 'elbasan',
  'Java' => 'javanais',
  'Syrn' => 'syriaque (variante orientale)',
  'Armn' => "arm\x{e9}nien",
  'Taml' => 'tamoul',
  'Laoo' => 'laotien',
  'Cprt' => 'syllabaire chypriote',
  'Tglg' => 'tagal (baybayin, alibata)',
  'Ahom' => "\x{e2}hom",
  'Wole' => "wol\x{e9}a\x{ef}",
  'Cirt' => 'cirth',
  'Jurc' => 'jurchen',
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Blis' => 'symboles Bliss',
  'Hatr' => "hatr\x{e9}nien",
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Thai' => "tha\x{ef}",
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Leke' => "l\x{e9}k\x{e9}",
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Batk' => 'batik',
  'Beng' => "bengal\x{ee} (bangla)",
  'Phlp' => 'pehlevi des psautiers',
  'Mult' => "multan\x{ee}",
  'Sarb' => 'sud-arabique, himyarite',
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Mtei' => 'meitei mayek',
  'Latf' => "latin (variante bris\x{e9}e)",
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Sund' => 'sundanais',
  'Copt' => 'copte',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Chrs' => 'chorasmien',
  'Toto' => 'toto',
  'Tirh' => 'tirhouta',
  'Phag' => "\x{2019}phags pa",
  'Narb' => 'nord-arabique',
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Goth' => 'gotique',
  'Mani' => "manich\x{e9}en",
  'Shrd' => 'charada, shard',
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Limb' => 'limbou',
  'Wara' => 'warang citi',
  'Lyci' => 'lycien',
  'Plrd' => 'miao (Pollard)',
  'Tagb' => 'tagbanoua',
  'Mlym' => "malay\x{e2}lam",
  'Yezi' => "y\x{e9}zidi",
  'Yiii' => 'yi',
  'Roro' => 'rongorongo',
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Kits' => "petite \x{e9}criture khitan",
  'Tale' => "ta\x{ef}-le",
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Rjng' => 'redjang (kaganga)',
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Shaw' => 'shavien (Shaw)',
  'Prti' => 'parthe des inscriptions',
  'Palm' => "palmyr\x{e9}nien",
  'Osge' => 'osage',
  'Perm' => 'ancien permien',
  'Gong' => "gunjala gond\x{ee}",
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Gonm' => "masaram gond\x{ee}",
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Cham' => "cham (\x{10d}am, tcham)",
  'Samr' => 'samaritain',
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Zmth' => "notation math\x{e9}matique",
  'Brah' => 'brahma',
  'Moon' => "\x{e9}criture Moon",
  'Arab' => 'arabe',
  'Mymr' => 'birman',
  'Cpmn' => 'syllabaire chypro-minoen',
  'Hira' => 'hiragana',
  'Kitl' => "grande \x{e9}criture khitan",
  'Khoj' => "khojk\x{ee}",
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Lydi' => 'lydien',
  'Khar' => "kharochth\x{ee}",
  'Kthi' => "kaith\x{ee}",
  'Sidd' => 'siddham',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Saur' => 'saurachtra',
  'Cari' => 'carien',
  'Soyo' => 'soyombo',
  'Wcho' => 'wantcho',
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Linb' => "lin\x{e9}aire B",
  'Sora' => 'sora sompeng',
  'Mong' => 'mongol',
  'Bugi' => 'bouguis',
  'Phlv' => 'pehlevi des livres',
  'Guru' => "gourmoukh\x{ee}",
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Thaa' => "th\x{e2}na",
  'Visp' => 'parole visible',
  'Mroo' => 'mro',
  'Marc' => 'marchen',
  'Knda' => 'kannara (canara)',
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Olck' => 'ol tchiki',
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Nkgb' => 'naxi geba, nakhi geba',
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Hmnp' => 'nyiakeng puachue hmong',
  'Zsym' => 'symboles',
  'Pauc' => 'paou chin haou',
  'Dogr' => 'dogra',
  'Phli' => 'pehlevi des inscriptions'
};
$ScriptCodeVersion = {
  'Zmth' => '3.2',
  'Cyrs' => '1.1',
  'Kpel' => '',
  'Samr' => '5.2',
  'Mymr' => '3.0',
  'Arab' => '1.1',
  'Moon' => '',
  'Brah' => '6.0',
  'Osge' => '9.0',
  'Perm' => '7.0',
  'Gong' => '11.0',
  'Shaw' => '4.0',
  'Palm' => '7.0',
  'Prti' => '5.2',
  'Cham' => '5.1',
  'Hang' => '1.1',
  'Zzzz' => '',
  'Dupl' => '7.0',
  'Gonm' => '10.0',
  'Sidd' => '7.0',
  'Kthi' => '5.2',
  'Cher' => '3.0',
  'Geor' => '1.1',
  'Takr' => '6.1',
  'Cpmn' => '',
  'Khar' => '4.1',
  'Lydi' => '5.1',
  'Hrkt' => '1.1',
  'Kitl' => '',
  'Khoj' => '7.0',
  'Hira' => '1.1',
  'Visp' => '',
  'Thaa' => '3.0',
  'Zsye' => '6.0',
  'Olck' => '5.1',
  'Armi' => '5.2',
  'Knda' => '1.1',
  'Marc' => '9.0',
  'Mroo' => '7.0',
  'Linb' => '4.0',
  'Wcho' => '12.0',
  'Hung' => '8.0',
  'Soyo' => '10.0',
  'Cari' => '5.1',
  'Saur' => '5.1',
  'Phlv' => '',
  'Guru' => '1.1',
  'Bugi' => '4.1',
  'Sora' => '6.1',
  'Mong' => '3.0',
  'Zsym' => '1.1',
  'Pauc' => '7.0',
  'Hmnp' => '12.0',
  'Phli' => '5.2',
  'Dogr' => '11.0',
  'Hani' => '1.1',
  'Nkgb' => '',
  'Latg' => '1.1',
  'Phag' => '5.0',
  'Tirh' => '7.0',
  'Piqd' => '',
  'Elym' => '12.0',
  'Narb' => '7.0',
  'Jpan' => '1.1',
  'Latf' => '1.1',
  'Mtei' => '5.2',
  'Toto' => '',
  'Chrs' => '13.0',
  'Tfng' => '4.1',
  'Copt' => '4.1',
  'Sund' => '5.1',
  'Sylo' => '4.1',
  'Hluw' => '8.0',
  'Limb' => '4.0',
  'Wara' => '7.0',
  'Goth' => '3.1',
  'Mani' => '7.0',
  'Egyp' => '5.2',
  'Shrd' => '6.1',
  'Roro' => '',
  'Kits' => '13.0',
  'Hans' => '1.1',
  'Plrd' => '6.1',
  'Lyci' => '5.1',
  'Yezi' => '13.0',
  'Yiii' => '3.0',
  'Mlym' => '1.1',
  'Tagb' => '3.2',
  'Newa' => '9.0',
  'Rjng' => '5.1',
  'Zinh' => '',
  'Egyd' => '',
  'Egyh' => '5.2',
  'Mahj' => '7.0',
  'Tale' => '4.0',
  'Sgnw' => '8.0',
  'Cans' => '3.0',
  'Adlm' => '9.0',
  'Zxxx' => '',
  'Sogd' => '11.0',
  'Zanb' => '10.0',
  'Mero' => '6.1',
  'Syrj' => '3.0',
  'Glag' => '4.1',
  'Rohg' => '11.0',
  'Shui' => '',
  'Nkoo' => '5.0',
  'Teng' => '',
  'Xsux' => '5.0',
  'Hebr' => '1.1',
  'Afak' => '',
  'Ugar' => '4.0',
  'Gran' => '7.0',
  'Syrc' => '3.0',
  'Runr' => '3.0',
  'Diak' => '13.0',
  'Syre' => '3.0',
  'Cyrl' => '1.1',
  'Deva' => '1.1',
  'Syrn' => '3.0',
  'Armn' => '1.1',
  'Buhd' => '3.2',
  'Nshu' => '10.0',
  'Java' => '5.2',
  'Medf' => '11.0',
  'Elba' => '7.0',
  'Loma' => '',
  'Dsrt' => '3.1',
  'Bhks' => '9.0',
  'Gujr' => '1.1',
  'Leke' => '',
  'Kore' => '1.1',
  'Sind' => '7.0',
  'Mult' => '8.0',
  'Sarb' => '5.2',
  'Phlp' => '7.0',
  'Beng' => '1.1',
  'Batk' => '6.0',
  'Laoo' => '1.1',
  'Taml' => '1.1',
  'Thai' => '1.1',
  'Jamo' => '1.1',
  'Blis' => '',
  'Wole' => '',
  'Jurc' => '',
  'Cirt' => '',
  'Geok' => '1.1',
  'Hatr' => '8.0',
  'Tglg' => '3.2',
  'Ahom' => '8.0',
  'Cprt' => '4.0',
  'Sara' => '',
  'Aran' => '1.1',
  'Sinh' => '3.0',
  'Mand' => '6.0',
  'Lana' => '5.2',
  'Bali' => '5.0',
  'Nkdb' => '',
  'Kana' => '1.1',
  'Mend' => '7.0',
  'Inds' => '',
  'Hano' => '3.2',
  'Bopo' => '1.1',
  'Vaii' => '5.1',
  'Nand' => '12.0',
  'Ethi' => '3.0',
  'Orya' => '1.1',
  'Lepc' => '5.1',
  'Qaaa' => '',
  'Maka' => '11.0',
  'Avst' => '5.2',
  'Ital' => '3.1',
  'Khmr' => '3.0',
  'Kali' => '5.1',
  'Talu' => '4.1',
  'Hanb' => '1.1',
  'Orkh' => '5.2',
  'Hmng' => '7.0',
  'Merc' => '6.1',
  'Tibt' => '2.0',
  'Cakm' => '6.1',
  'Ogam' => '3.0',
  'Latn' => '1.1',
  'Phnx' => '5.0',
  'Grek' => '1.1',
  'Modi' => '7.0',
  'Lisu' => '5.2',
  'Nbat' => '7.0',
  'Bass' => '7.0',
  'Xpeo' => '4.1',
  'Osma' => '4.0',
  'Aghb' => '7.0',
  'Qabx' => '',
  'Brai' => '3.0',
  'Maya' => '',
  'Sogo' => '11.0',
  'Zyyy' => '',
  'Bamu' => '5.2',
  'Hant' => '1.1',
  'Tavt' => '5.2',
  'Lina' => '7.0',
  'Tang' => '9.0',
  'Telu' => '1.1'
};
$ScriptCodeDate = {
  'Egyp' => '2009-06-01
',
  'Shrd' => '2012-02-06
',
  'Mani' => '2014-11-15
',
  'Goth' => '2004-05-01
',
  'Wara' => '2014-11-15
',
  'Limb' => '2004-05-29
',
  'Copt' => '2006-06-21
',
  'Sund' => '2007-07-02
',
  'Hluw' => '2015-07-07
',
  'Sylo' => '2006-06-21
',
  'Toto' => '2020-04-16
',
  'Chrs' => '2019-08-19
',
  'Tfng' => '2006-06-21
',
  'Latf' => '2004-05-01
',
  'Mtei' => '2009-06-01
',
  'Jpan' => '2006-06-21
',
  'Narb' => '2014-11-15
',
  'Piqd' => '2015-12-16
',
  'Elym' => '2018-08-26
',
  'Tirh' => '2014-11-15
',
  'Phag' => '2006-10-10
',
  'Sgnw' => '2015-07-07
',
  'Tale' => '2004-10-25
',
  'Mahj' => '2014-11-15
',
  'Egyh' => '2004-05-01
',
  'Zinh' => '2009-02-23
',
  'Egyd' => '2004-05-01
',
  'Newa' => '2016-12-05
',
  'Rjng' => '2009-02-23
',
  'Mlym' => '2004-05-01
',
  'Tagb' => '2004-05-01
',
  'Yiii' => '2004-05-01
',
  'Yezi' => '2019-08-19
',
  'Lyci' => '2007-07-02
',
  'Plrd' => '2012-02-06
',
  'Hans' => '2004-05-29
',
  'Kits' => '2015-07-15
',
  'Roro' => '2004-05-01
',
  'Khoj' => '2014-11-15
',
  'Hrkt' => '2011-06-21
',
  'Hira' => '2004-05-01
',
  'Kitl' => '2015-07-15
',
  'Lydi' => '2007-07-02
',
  'Khar' => '2006-06-21
',
  'Cpmn' => '2017-07-26
',
  'Geor' => '2016-12-05
',
  'Takr' => '2012-02-06
',
  'Cher' => '2004-05-01
',
  'Kthi' => '2009-06-01
',
  'Sidd' => '2014-11-15
',
  'Zzzz' => '2006-10-10
',
  'Dupl' => '2014-11-15
',
  'Gonm' => '2017-07-26
',
  'Hang' => '2004-05-29
',
  'Cham' => '2009-11-11
',
  'Perm' => '2014-11-15
',
  'Gong' => '2016-12-05
',
  'Osge' => '2016-12-05
',
  'Shaw' => '2004-05-01
',
  'Prti' => '2009-06-01
',
  'Palm' => '2014-11-15
',
  'Brah' => '2010-07-23
',
  'Arab' => '2004-05-01
',
  'Mymr' => '2004-05-01
',
  'Moon' => '2006-12-11
',
  'Kpel' => '2010-03-26
',
  'Samr' => '2009-06-01
',
  'Zmth' => '2007-11-26
',
  'Cyrs' => '2004-05-01
',
  'Latg' => '2004-05-01
',
  'Nkgb' => '2017-07-26
',
  'Hani' => '2009-02-23
',
  'Phli' => '2009-06-01
',
  'Dogr' => '2016-12-05
',
  'Hmnp' => '2017-07-26
',
  'Pauc' => '2014-11-15
',
  'Zsym' => '2007-11-26
',
  'Sora' => '2012-02-06
',
  'Mong' => '2004-05-01
',
  'Guru' => '2004-05-01
',
  'Phlv' => '2007-07-15
',
  'Bugi' => '2006-06-21
',
  'Soyo' => '2017-07-26
',
  'Saur' => '2007-07-02
',
  'Cari' => '2007-07-02
',
  'Linb' => '2004-05-29
',
  'Wcho' => '2017-07-26
',
  'Hung' => '2015-07-07
',
  'Knda' => '2004-05-29
',
  'Marc' => '2016-12-05
',
  'Mroo' => '2016-12-05
',
  'Olck' => '2007-07-02
',
  'Armi' => '2009-06-01
',
  'Zsye' => '2015-12-16
',
  'Thaa' => '2004-05-01
',
  'Visp' => '2004-05-01
',
  'Avst' => '2009-06-01
',
  'Qaaa' => '2004-05-29
',
  'Maka' => '2016-12-05
',
  'Lepc' => '2007-07-02
',
  'Orya' => '2016-12-05
',
  'Ethi' => '2004-10-25
',
  'Nand' => '2018-08-26
',
  'Bopo' => '2004-05-01
',
  'Hano' => '2004-05-29
',
  'Vaii' => '2007-07-02
',
  'Inds' => '2004-05-01
',
  'Mend' => '2014-11-15
',
  'Nkdb' => '2017-07-26
',
  'Kana' => '2004-05-01
',
  'Bali' => '2006-10-10
',
  'Mand' => '2010-07-23
',
  'Sinh' => '2004-05-01
',
  'Lana' => '2009-06-01
',
  'Aran' => '2014-11-15
',
  'Sara' => '2004-05-29
',
  'Tang' => '2016-12-05
',
  'Telu' => '2004-05-01
',
  'Zyyy' => '2004-05-29
',
  'Bamu' => '2009-06-01
',
  'Sogo' => '2017-11-21
',
  'Tavt' => '2009-06-01
',
  'Hant' => '2004-05-29
',
  'Lina' => '2014-11-15
',
  'Qabx' => '2004-05-29
',
  'Brai' => '2004-05-01
',
  'Maya' => '2004-05-01
',
  'Osma' => '2004-05-01
',
  'Aghb' => '2014-11-15
',
  'Xpeo' => '2006-06-21
',
  'Bass' => '2014-11-15
',
  'Nbat' => '2014-11-15
',
  'Modi' => '2014-11-15
',
  'Lisu' => '2009-06-01
',
  'Phnx' => '2006-10-10
',
  'Grek' => '2004-05-01
',
  'Tibt' => '2004-05-01
',
  'Latn' => '2004-05-01
',
  'Ogam' => '2004-05-01
',
  'Cakm' => '2012-02-06
',
  'Hmng' => '2014-11-15
',
  'Merc' => '2012-02-06
',
  'Orkh' => '2009-06-01
',
  'Khmr' => '2004-05-29
',
  'Talu' => '2006-06-21
',
  'Hanb' => '2016-01-19
',
  'Kali' => '2007-07-02
',
  'Ital' => '2004-05-29
',
  'Deva' => '2004-05-01
',
  'Cyrl' => '2004-05-01
',
  'Diak' => '2019-08-19
',
  'Syre' => '2004-05-01
',
  'Syrc' => '2004-05-01
',
  'Runr' => '2004-05-01
',
  'Ugar' => '2004-05-01
',
  'Gran' => '2014-11-15
',
  'Xsux' => '2006-10-10
',
  'Hebr' => '2004-05-01
',
  'Afak' => '2010-12-21
',
  'Teng' => '2004-05-01
',
  'Syrj' => '2004-05-01
',
  'Rohg' => '2017-11-21
',
  'Glag' => '2006-06-21
',
  'Shui' => '2017-07-26
',
  'Nkoo' => '2006-10-10
',
  'Zanb' => '2017-07-26
',
  'Mero' => '2012-02-06
',
  'Zxxx' => '2011-06-21
',
  'Sogd' => '2017-11-21
',
  'Adlm' => '2016-12-05
',
  'Cans' => '2004-05-29
',
  'Jurc' => '2010-12-21
',
  'Wole' => '2010-12-21
',
  'Cirt' => '2004-05-01
',
  'Blis' => '2004-05-01
',
  'Geok' => '2012-10-16
',
  'Hatr' => '2015-07-07
',
  'Cprt' => '2017-07-26
',
  'Tglg' => '2009-02-23
',
  'Ahom' => '2015-07-07
',
  'Thai' => '2004-05-01
',
  'Jamo' => '2016-01-19
',
  'Taml' => '2004-05-01
',
  'Laoo' => '2004-05-01
',
  'Beng' => '2016-12-05
',
  'Phlp' => '2014-11-15
',
  'Batk' => '2010-07-23
',
  'Sind' => '2014-11-15
',
  'Mult' => '2015-07-07
',
  'Sarb' => '2009-06-01
',
  'Leke' => '2015-07-07
',
  'Kore' => '2007-06-13
',
  'Bhks' => '2016-12-05
',
  'Gujr' => '2004-05-01
',
  'Loma' => '2010-03-26
',
  'Dsrt' => '2004-05-01
',
  'Java' => '2009-06-01
',
  'Medf' => '2016-12-05
',
  'Elba' => '2014-11-15
',
  'Nshu' => '2017-07-26
',
  'Buhd' => '2004-05-01
',
  'Armn' => '2004-05-01
',
  'Syrn' => '2004-05-01
'
};
$ScriptCodeId = {
  'Latf' => '217',
  'Mtei' => '337',
  'Jpan' => '413',
  'Sund' => '362',
  'Copt' => '204',
  'Hluw' => '080',
  'Sylo' => '316',
  'Toto' => '294',
  'Chrs' => '109',
  'Tfng' => '120',
  'Tirh' => '326',
  'Phag' => '331',
  'Narb' => '106',
  'Piqd' => '293',
  'Elym' => '128',
  'Mani' => '139',
  'Goth' => '206',
  'Egyp' => '050',
  'Shrd' => '319',
  'Limb' => '336',
  'Wara' => '262',
  'Lyci' => '202',
  'Plrd' => '282',
  'Mlym' => '347',
  'Tagb' => '373',
  'Yezi' => '192',
  'Yiii' => '460',
  'Roro' => '620',
  'Hans' => '501',
  'Kits' => '288',
  'Mahj' => '314',
  'Tale' => '353',
  'Sgnw' => '095',
  'Zinh' => '994',
  'Egyd' => '070',
  'Newa' => '333',
  'Rjng' => '363',
  'Egyh' => '060',
  'Perm' => '227',
  'Gong' => '312',
  'Osge' => '219',
  'Prti' => '130',
  'Shaw' => '281',
  'Palm' => '126',
  'Zzzz' => '999',
  'Gonm' => '313',
  'Dupl' => '755',
  'Cham' => '358',
  'Hang' => '286',
  'Kpel' => '436',
  'Samr' => '123',
  'Zmth' => '995',
  'Cyrs' => '221',
  'Brah' => '300',
  'Mymr' => '350',
  'Arab' => '160',
  'Moon' => '218',
  'Cpmn' => '402',
  'Kitl' => '505',
  'Hira' => '410',
  'Hrkt' => '412',
  'Khoj' => '322',
  'Khar' => '305',
  'Lydi' => '116',
  'Sidd' => '302',
  'Kthi' => '317',
  'Geor' => '240',
  'Takr' => '321',
  'Cher' => '445',
  'Soyo' => '329',
  'Saur' => '344',
  'Cari' => '201',
  'Linb' => '401',
  'Hung' => '176',
  'Wcho' => '283',
  'Mong' => '145',
  'Sora' => '398',
  'Phlv' => '133',
  'Guru' => '310',
  'Bugi' => '367',
  'Zsye' => '993',
  'Visp' => '280',
  'Thaa' => '170',
  'Knda' => '345',
  'Marc' => '332',
  'Mroo' => '264',
  'Olck' => '261',
  'Armi' => '124',
  'Hani' => '500',
  'Nkgb' => '420',
  'Latg' => '216',
  'Hmnp' => '451',
  'Pauc' => '263',
  'Zsym' => '996',
  'Phli' => '131',
  'Dogr' => '328',
  'Mend' => '438',
  'Inds' => '610',
  'Nkdb' => '085',
  'Kana' => '411',
  'Sara' => '292',
  'Aran' => '161',
  'Bali' => '360',
  'Mand' => '140',
  'Sinh' => '348',
  'Lana' => '351',
  'Lepc' => '335',
  'Avst' => '134',
  'Qaaa' => '900',
  'Maka' => '366',
  'Nand' => '311',
  'Bopo' => '285',
  'Hano' => '371',
  'Vaii' => '470',
  'Orya' => '327',
  'Ethi' => '430',
  'Tibt' => '330',
  'Cakm' => '349',
  'Ogam' => '212',
  'Latn' => '215',
  'Modi' => '324',
  'Lisu' => '399',
  'Phnx' => '115',
  'Grek' => '200',
  'Khmr' => '355',
  'Kali' => '357',
  'Talu' => '354',
  'Hanb' => '503',
  'Ital' => '210',
  'Hmng' => '450',
  'Merc' => '101',
  'Orkh' => '175',
  'Zyyy' => '998',
  'Bamu' => '435',
  'Sogo' => '142',
  'Tavt' => '359',
  'Hant' => '502',
  'Lina' => '400',
  'Qabx' => '949',
  'Brai' => '570',
  'Maya' => '090',
  'Telu' => '340',
  'Tang' => '520',
  'Bass' => '259',
  'Nbat' => '159',
  'Osma' => '260',
  'Aghb' => '239',
  'Xpeo' => '030',
  'Glag' => '225',
  'Syrj' => '137',
  'Rohg' => '167',
  'Shui' => '530',
  'Nkoo' => '165',
  'Zanb' => '339',
  'Mero' => '100',
  'Teng' => '290',
  'Zxxx' => '997',
  'Sogd' => '141',
  'Adlm' => '166',
  'Cans' => '440',
  'Diak' => '342',
  'Syre' => '138',
  'Syrc' => '135',
  'Runr' => '211',
  'Deva' => '315',
  'Cyrl' => '220',
  'Xsux' => '020',
  'Afak' => '439',
  'Hebr' => '125',
  'Ugar' => '040',
  'Gran' => '343',
  'Nshu' => '499',
  'Buhd' => '372',
  'Loma' => '437',
  'Dsrt' => '250',
  'Java' => '361',
  'Medf' => '265',
  'Elba' => '226',
  'Syrn' => '136',
  'Armn' => '230',
  'Taml' => '346',
  'Laoo' => '356',
  'Wole' => '480',
  'Jurc' => '510',
  'Cirt' => '291',
  'Geok' => '241',
  'Hatr' => '127',
  'Blis' => '550',
  'Ahom' => '338',
  'Tglg' => '370',
  'Cprt' => '403',
  'Thai' => '352',
  'Jamo' => '284',
  'Leke' => '364',
  'Kore' => '287',
  'Bhks' => '334',
  'Gujr' => '320',
  'Beng' => '325',
  'Phlp' => '132',
  'Batk' => '365',
  'Sind' => '318',
  'Mult' => '323',
  'Sarb' => '105'
};
$Lang2Territory = {
  'ben' => {
    'BD' => 1,
    'IN' => 2
  },
  'bis' => {
    'VU' => 1
  },
  'pau' => {
    'PW' => 1
  },
  'eus' => {
    'ES' => 2
  },
  'lit' => {
    'PL' => 2,
    'LT' => 1
  },
  'glg' => {
    'ES' => 2
  },
  'arq' => {
    'DZ' => 2
  },
  'kmb' => {
    'AO' => 2
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'som' => {
    'DJ' => 2,
    'SO' => 1,
    'ET' => 2
  },
  'sav' => {
    'SN' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'bjn' => {
    'ID' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'krc' => {
    'RU' => 2
  },
  'dyu' => {
    'BF' => 2
  },
  'mfe' => {
    'MU' => 2
  },
  'ltz' => {
    'LU' => 1
  },
  'fvr' => {
    'SD' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'men' => {
    'SL' => 2
  },
  'ach' => {
    'UG' => 2
  },
  'sef' => {
    'CI' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'khn' => {
    'IN' => 2
  },
  'por' => {
    'MZ' => 1,
    'TL' => 1,
    'BR' => 1,
    'GW' => 1,
    'PT' => 1,
    'AO' => 1,
    'MO' => 1,
    'ST' => 1,
    'GQ' => 1,
    'CV' => 1
  },
  'mfa' => {
    'TH' => 2
  },
  'kok' => {
    'IN' => 2
  },
  'fin' => {
    'SE' => 2,
    'EE' => 2,
    'FI' => 1
  },
  'fud' => {
    'WF' => 2
  },
  'bho' => {
    'NP' => 2,
    'MU' => 2,
    'IN' => 2
  },
  'run' => {
    'BI' => 1
  },
  'che' => {
    'RU' => 2
  },
  'inh' => {
    'RU' => 2
  },
  'gil' => {
    'KI' => 1
  },
  'crs' => {
    'SC' => 2
  },
  'bqi' => {
    'IR' => 2
  },
  'fon' => {
    'BJ' => 2
  },
  'guz' => {
    'KE' => 2
  },
  'tem' => {
    'SL' => 2
  },
  'laj' => {
    'UG' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'dje' => {
    'NE' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'bal' => {
    'IR' => 2,
    'PK' => 2,
    'AF' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'brh' => {
    'PK' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'sck' => {
    'IN' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'gbm' => {
    'IN' => 2
  },
  'uig' => {
    'CN' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'fuv' => {
    'NG' => 2
  },
  'doi' => {
    'IN' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'nld' => {
    'SX' => 1,
    'DE' => 2,
    'SR' => 1,
    'AW' => 1,
    'CW' => 1,
    'BE' => 1,
    'NL' => 1,
    'BQ' => 1
  },
  'hil' => {
    'PH' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'tuk' => {
    'AF' => 2,
    'IR' => 2,
    'TM' => 1
  },
  'jav' => {
    'ID' => 2
  },
  'pan' => {
    'IN' => 2,
    'PK' => 2
  },
  'zho' => {
    'TH' => 2,
    'MY' => 2,
    'SG' => 1,
    'ID' => 2,
    'TW' => 1,
    'CN' => 1,
    'VN' => 2,
    'US' => 2,
    'MO' => 1,
    'HK' => 1
  },
  'war' => {
    'PH' => 2
  },
  'wuu' => {
    'CN' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'sus' => {
    'GN' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'noe' => {
    'IN' => 2
  },
  'ckb' => {
    'IR' => 2,
    'IQ' => 2
  },
  'fra' => {
    'DZ' => 1,
    'IT' => 2,
    'TF' => 2,
    'LU' => 1,
    'SN' => 1,
    'HT' => 1,
    'GQ' => 1,
    'PF' => 1,
    'SC' => 1,
    'YT' => 1,
    'CM' => 1,
    'BJ' => 1,
    'ML' => 1,
    'GF' => 1,
    'CI' => 1,
    'MQ' => 1,
    'PM' => 1,
    'RO' => 2,
    'TN' => 1,
    'KM' => 1,
    'PT' => 2,
    'GB' => 2,
    'BI' => 1,
    'MF' => 1,
    'VU' => 1,
    'MU' => 1,
    'GN' => 1,
    'CF' => 1,
    'CG' => 1,
    'RE' => 1,
    'WF' => 1,
    'SY' => 1,
    'NE' => 1,
    'US' => 2,
    'NL' => 2,
    'BE' => 1,
    'MG' => 1,
    'DJ' => 1,
    'GA' => 1,
    'CD' => 1,
    'BL' => 1,
    'MA' => 1,
    'DE' => 2,
    'TD' => 1,
    'RW' => 1,
    'FR' => 1,
    'GP' => 1,
    'CH' => 1,
    'NC' => 1,
    'MC' => 1,
    'BF' => 1,
    'TG' => 1,
    'CA' => 1
  },
  'mzn' => {
    'IR' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'mad' => {
    'ID' => 2
  },
  'ssw' => {
    'SZ' => 1,
    'ZA' => 2
  },
  'que' => {
    'PE' => 1,
    'EC' => 1,
    'BO' => 1
  },
  'suk' => {
    'TZ' => 2
  },
  'gan' => {
    'CN' => 2
  },
  'gsw' => {
    'LI' => 1,
    'DE' => 2,
    'CH' => 1
  },
  'ceb' => {
    'PH' => 2
  },
  'lah' => {
    'PK' => 2
  },
  'ron' => {
    'MD' => 1,
    'RO' => 1,
    'RS' => 2
  },
  'nya' => {
    'ZM' => 2,
    'MW' => 1
  },
  'spa' => {
    'FR' => 2,
    'VE' => 1,
    'PA' => 1,
    'DE' => 2,
    'EA' => 1,
    'PR' => 1,
    'ES' => 1,
    'BZ' => 2,
    'CU' => 1,
    'PH' => 2,
    'IC' => 1,
    'PY' => 1,
    'US' => 2,
    'GT' => 1,
    'RO' => 2,
    'PT' => 2,
    'BO' => 1,
    'CR' => 1,
    'SV' => 1,
    'CL' => 1,
    'NI' => 1,
    'PE' => 1,
    'CO' => 1,
    'HN' => 1,
    'AR' => 1,
    'EC' => 1,
    'GI' => 2,
    'DO' => 1,
    'AD' => 2,
    'MX' => 1,
    'UY' => 1,
    'GQ' => 1
  },
  'nde' => {
    'ZW' => 1
  },
  'teo' => {
    'UG' => 2
  },
  'aeb' => {
    'TN' => 2
  },
  'oci' => {
    'FR' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'mni' => {
    'IN' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'ary' => {
    'MA' => 2
  },
  'khm' => {
    'KH' => 1
  },
  'bci' => {
    'CI' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'nbl' => {
    'ZA' => 2
  },
  'bem' => {
    'ZM' => 2
  },
  'kam' => {
    'KE' => 2
  },
  'bgn' => {
    'PK' => 2
  },
  'seh' => {
    'MZ' => 2
  },
  'lao' => {
    'LA' => 1
  },
  'mey' => {
    'SN' => 2
  },
  'hsn' => {
    'CN' => 2
  },
  'gom' => {
    'IN' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'srn' => {
    'SR' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'buc' => {
    'YT' => 2
  },
  'nep' => {
    'NP' => 1,
    'IN' => 2
  },
  'kea' => {
    'CV' => 2
  },
  'zdj' => {
    'KM' => 1
  },
  'xho' => {
    'ZA' => 2
  },
  'nds' => {
    'DE' => 2,
    'NL' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'mak' => {
    'ID' => 2
  },
  'mon' => {
    'MN' => 1,
    'CN' => 2
  },
  'wbr' => {
    'IN' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'dan' => {
    'DK' => 1,
    'DE' => 2
  },
  'bod' => {
    'CN' => 2
  },
  'rkt' => {
    'IN' => 2,
    'BD' => 2
  },
  'ara' => {
    'QA' => 1,
    'KM' => 1,
    'TN' => 1,
    'PS' => 1,
    'SS' => 2,
    'MA' => 2,
    'LB' => 1,
    'IR' => 2,
    'BH' => 1,
    'SO' => 1,
    'AE' => 1,
    'EG' => 2,
    'MR' => 1,
    'TD' => 1,
    'YE' => 1,
    'SA' => 1,
    'SY' => 1,
    'ER' => 1,
    'DJ' => 1,
    'EH' => 1,
    'IQ' => 1,
    'IL' => 1,
    'OM' => 1,
    'DZ' => 2,
    'LY' => 1,
    'JO' => 1,
    'KW' => 1,
    'SD' => 1
  },
  'haw' => {
    'US' => 2
  },
  'rif' => {
    'MA' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'nod' => {
    'TH' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'ita' => {
    'MT' => 2,
    'SM' => 1,
    'US' => 2,
    'VA' => 1,
    'DE' => 2,
    'IT' => 1,
    'FR' => 2,
    'HR' => 2,
    'CH' => 1
  },
  'bhb' => {
    'IN' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'mfv' => {
    'SN' => 2
  },
  'hye' => {
    'AM' => 1,
    'RU' => 2
  },
  'bos' => {
    'BA' => 1
  },
  'hoc' => {
    'IN' => 2
  },
  'bar' => {
    'AT' => 2,
    'DE' => 2
  },
  'kfy' => {
    'IN' => 2
  },
  'pol' => {
    'UA' => 2,
    'PL' => 1
  },
  'kir' => {
    'KG' => 1
  },
  'tsn' => {
    'BW' => 1,
    'ZA' => 2
  },
  'kin' => {
    'RW' => 1
  },
  'fuq' => {
    'NE' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'mag' => {
    'IN' => 2
  },
  'tyv' => {
    'RU' => 2
  },
  'amh' => {
    'ET' => 1
  },
  'tat' => {
    'RU' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'und' => {
    'CP' => 2,
    'AQ' => 2,
    'BV' => 2,
    'GS' => 2,
    'HM' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'kha' => {
    'IN' => 2
  },
  'kik' => {
    'KE' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'hun' => {
    'HU' => 1,
    'RO' => 2,
    'AT' => 2,
    'RS' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'ful' => {
    'SN' => 2,
    'GN' => 2,
    'NE' => 2,
    'NG' => 2,
    'ML' => 2
  },
  'luz' => {
    'IR' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'kor' => {
    'KP' => 1,
    'US' => 2,
    'KR' => 1,
    'CN' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'yor' => {
    'NG' => 1
  },
  'awa' => {
    'IN' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'bug' => {
    'ID' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'tpi' => {
    'PG' => 1
  },
  'lin' => {
    'CD' => 2
  },
  'hau' => {
    'NE' => 2,
    'NG' => 2
  },
  'aym' => {
    'BO' => 1
  },
  'bam' => {
    'ML' => 2
  },
  'fil' => {
    'US' => 2,
    'PH' => 1
  },
  'hmo' => {
    'PG' => 1
  },
  'ibb' => {
    'NG' => 2
  },
  'hno' => {
    'PK' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'raj' => {
    'IN' => 2
  },
  'kon' => {
    'CD' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'hbs' => {
    'XK' => 1,
    'ME' => 1,
    'HR' => 1,
    'SI' => 2,
    'BA' => 1,
    'RS' => 1,
    'AT' => 2
  },
  'lat' => {
    'VA' => 2
  },
  'eng' => {
    'UG' => 1,
    'PL' => 2,
    'SK' => 2,
    'ZW' => 1,
    'NR' => 1,
    'TK' => 1,
    'SC' => 1,
    'BM' => 1,
    'CY' => 2,
    'DK' => 2,
    'BI' => 1,
    'MH' => 1,
    'CZ' => 2,
    'HK' => 1,
    'CX' => 1,
    'CL' => 2,
    'TV' => 1,
    'JO' => 2,
    'KN' => 1,
    'GD' => 1,
    'AU' => 1,
    'VI' => 1,
    'LS' => 1,
    'BR' => 2,
    'SX' => 1,
    'IO' => 1,
    'ET' => 2,
    'CC' => 1,
    'SS' => 1,
    'TA' => 2,
    'SI' => 2,
    'IT' => 2,
    'GM' => 1,
    'IQ' => 2,
    'IM' => 1,
    'YE' => 2,
    'EG' => 2,
    'IN' => 1,
    'PT' => 2,
    'GU' => 1,
    'BG' => 2,
    'PH' => 1,
    'KY' => 1,
    'PN' => 1,
    'VG' => 1,
    'NL' => 2,
    'IE' => 1,
    'CH' => 2,
    'AS' => 1,
    'FK' => 1,
    'BS' => 1,
    'JE' => 1,
    'MA' => 2,
    'NA' => 1,
    'PR' => 1,
    'LC' => 1,
    'TC' => 1,
    'AR' => 2,
    'SD' => 1,
    'NU' => 1,
    'IL' => 2,
    'MY' => 2,
    'LR' => 1,
    'SH' => 1,
    'GI' => 1,
    'LV' => 2,
    'MW' => 1,
    'HU' => 2,
    'PW' => 1,
    'PK' => 1,
    'GY' => 1,
    'CK' => 1,
    'RO' => 2,
    'NF' => 1,
    'AI' => 1,
    'TH' => 2,
    'AC' => 2,
    'BB' => 1,
    'PG' => 1,
    'MS' => 1,
    'MP' => 1,
    'BE' => 2,
    'JM' => 1,
    'NZ' => 1,
    'US' => 1,
    'SL' => 1,
    'KE' => 1,
    'FR' => 2,
    'RW' => 1,
    'UM' => 1,
    'EE' => 2,
    'FJ' => 1,
    'LB' => 2,
    'SB' => 1,
    'KZ' => 2,
    'SZ' => 1,
    'ZA' => 1,
    'WS' => 1,
    'NG' => 1,
    'DZ' => 2,
    'LT' => 2,
    'BA' => 2,
    'MX' => 2,
    'FI' => 2,
    'CM' => 1,
    'GR' => 2,
    'TT' => 1,
    'LU' => 2,
    'AE' => 2,
    'AG' => 1,
    'DG' => 1,
    'SG' => 1,
    'GH' => 1,
    'GB' => 1,
    'LK' => 2,
    'SE' => 2,
    'FM' => 1,
    'GG' => 1,
    'MU' => 1,
    'VU' => 1,
    'ER' => 1,
    'AT' => 2,
    'MG' => 1,
    'DM' => 1,
    'BD' => 2,
    'KI' => 1,
    'BW' => 1,
    'HR' => 2,
    'DE' => 2,
    'TO' => 1,
    'BZ' => 1,
    'CA' => 1,
    'ZM' => 1,
    'ES' => 2,
    'TZ' => 1,
    'VC' => 1,
    'MT' => 1,
    'TR' => 2
  },
  'iii' => {
    'CN' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'kal' => {
    'DK' => 2,
    'GL' => 1
  },
  'ban' => {
    'ID' => 2
  },
  'tur' => {
    'CY' => 1,
    'DE' => 2,
    'TR' => 1
  },
  'mdf' => {
    'RU' => 2
  },
  'nyn' => {
    'UG' => 2
  },
  'sas' => {
    'ID' => 2
  },
  'udm' => {
    'RU' => 2
  },
  'kbd' => {
    'RU' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'lug' => {
    'UG' => 2
  },
  'rmt' => {
    'IR' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'tam' => {
    'SG' => 1,
    'IN' => 2,
    'MY' => 2,
    'LK' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'min' => {
    'ID' => 2
  },
  'mwr' => {
    'IN' => 2
  },
  'tcy' => {
    'IN' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'aln' => {
    'XK' => 2
  },
  'sah' => {
    'RU' => 2
  },
  'bum' => {
    'CM' => 2
  },
  'pam' => {
    'PH' => 2
  },
  'bew' => {
    'ID' => 2
  },
  'mdh' => {
    'PH' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'kaz' => {
    'KZ' => 1,
    'CN' => 2
  },
  'man' => {
    'GM' => 2,
    'GN' => 2
  },
  'koi' => {
    'RU' => 2
  },
  'fao' => {
    'FO' => 1
  },
  'skr' => {
    'PK' => 2
  },
  'zha' => {
    'CN' => 2
  },
  'glv' => {
    'IM' => 1
  },
  'heb' => {
    'IL' => 1
  },
  'kde' => {
    'TZ' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'bhi' => {
    'IN' => 2
  },
  'san' => {
    'IN' => 2
  },
  'gcr' => {
    'GF' => 2
  },
  'snd' => {
    'IN' => 2,
    'PK' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'hrv' => {
    'RS' => 2,
    'SI' => 2,
    'AT' => 2,
    'BA' => 1,
    'HR' => 1
  },
  'mya' => {
    'MM' => 1
  },
  'brx' => {
    'IN' => 2
  },
  'glk' => {
    'IR' => 2
  },
  'fry' => {
    'NL' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'orm' => {
    'ET' => 2
  },
  'uzb' => {
    'UZ' => 1,
    'AF' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'syl' => {
    'BD' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'lez' => {
    'RU' => 2
  },
  'gle' => {
    'GB' => 2,
    'IE' => 1
  },
  'sid' => {
    'ET' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'tha' => {
    'TH' => 1
  },
  'swb' => {
    'YT' => 2
  },
  'bak' => {
    'RU' => 2
  },
  'sme' => {
    'NO' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'hak' => {
    'CN' => 2
  },
  'kur' => {
    'TR' => 2,
    'IR' => 2,
    'SY' => 2,
    'IQ' => 2
  },
  'mer' => {
    'KE' => 2
  },
  'nor' => {
    'SJ' => 1,
    'NO' => 1
  },
  'gon' => {
    'IN' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'shi' => {
    'MA' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'kri' => {
    'SL' => 2
  },
  'sqi' => {
    'MK' => 2,
    'XK' => 1,
    'RS' => 2,
    'AL' => 1
  },
  'nym' => {
    'TZ' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'lua' => {
    'CD' => 2
  },
  'bej' => {
    'SD' => 2
  },
  'dzo' => {
    'BT' => 1
  },
  'bin' => {
    'NG' => 2
  },
  'tzm' => {
    'MA' => 1
  },
  'deu' => {
    'GB' => 2,
    'DK' => 2,
    'CZ' => 2,
    'BR' => 2,
    'DE' => 1,
    'KZ' => 2,
    'FR' => 2,
    'CH' => 1,
    'US' => 2,
    'LU' => 1,
    'HU' => 2,
    'BE' => 1,
    'AT' => 1,
    'NL' => 2,
    'SK' => 2,
    'LI' => 1,
    'PL' => 2,
    'SI' => 2
  },
  'tnr' => {
    'SN' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'tet' => {
    'TL' => 1
  },
  'ton' => {
    'TO' => 1
  },
  'yue' => {
    'HK' => 2,
    'CN' => 2
  },
  'tum' => {
    'MW' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'ori' => {
    'IN' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'tig' => {
    'ER' => 2
  },
  'pap' => {
    'CW' => 1,
    'AW' => 1,
    'BQ' => 2
  },
  'swa' => {
    'KE' => 1,
    'TZ' => 1,
    'CD' => 2,
    'UG' => 1
  },
  'swe' => {
    'FI' => 1,
    'SE' => 1,
    'AX' => 1
  },
  'rej' => {
    'ID' => 2
  },
  'fij' => {
    'FJ' => 1
  },
  'aka' => {
    'GH' => 2
  },
  'vls' => {
    'BE' => 2
  },
  'dnj' => {
    'CI' => 2
  },
  'arz' => {
    'EG' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'tir' => {
    'ER' => 1,
    'ET' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'est' => {
    'EE' => 1
  },
  'tvl' => {
    'TV' => 1
  },
  'ibo' => {
    'NG' => 2
  },
  'shn' => {
    'MM' => 2
  },
  'ukr' => {
    'UA' => 1,
    'RS' => 2
  },
  'cat' => {
    'AD' => 1,
    'ES' => 2
  },
  'wol' => {
    'SN' => 1
  },
  'gaa' => {
    'GH' => 2
  },
  'bgc' => {
    'IN' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'xog' => {
    'UG' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'myx' => {
    'UG' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'msa' => {
    'ID' => 2,
    'SG' => 1,
    'CC' => 2,
    'BN' => 1,
    'MY' => 1,
    'TH' => 2
  },
  'ewe' => {
    'GH' => 2,
    'TG' => 2
  },
  'tel' => {
    'IN' => 2
  },
  'mai' => {
    'NP' => 2,
    'IN' => 2
  },
  'tah' => {
    'PF' => 1
  },
  'sag' => {
    'CF' => 1
  },
  'bul' => {
    'BG' => 1
  },
  'snk' => {
    'ML' => 2
  },
  'smo' => {
    'AS' => 1,
    'WS' => 1
  },
  'aze' => {
    'AZ' => 1,
    'IR' => 2,
    'RU' => 2,
    'IQ' => 2
  },
  'slk' => {
    'RS' => 2,
    'CZ' => 2,
    'SK' => 1
  },
  'haz' => {
    'AF' => 2
  },
  'srd' => {
    'IT' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'tso' => {
    'MZ' => 2,
    'ZA' => 2
  },
  'bjt' => {
    'SN' => 2
  },
  'fas' => {
    'AF' => 1,
    'IR' => 1,
    'PK' => 2
  },
  'bsc' => {
    'SN' => 2
  },
  'nob' => {
    'SJ' => 1,
    'NO' => 1
  },
  'nno' => {
    'NO' => 1
  },
  'hif' => {
    'FJ' => 1
  },
  'slv' => {
    'SI' => 1,
    'AT' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'kom' => {
    'RU' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'rus' => {
    'UZ' => 2,
    'KZ' => 1,
    'BY' => 1,
    'LT' => 2,
    'RU' => 1,
    'PL' => 2,
    'EE' => 2,
    'DE' => 2,
    'SJ' => 2,
    'BG' => 2,
    'UA' => 1,
    'KG' => 1,
    'LV' => 2,
    'TJ' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'gor' => {
    'ID' => 2
  },
  'kab' => {
    'DZ' => 2
  },
  'sat' => {
    'IN' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'grn' => {
    'PY' => 1
  },
  'hne' => {
    'IN' => 2
  },
  'unr' => {
    'IN' => 2
  },
  'sna' => {
    'ZW' => 1
  },
  'div' => {
    'MV' => 1
  },
  'hoj' => {
    'IN' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'ces' => {
    'CZ' => 1,
    'SK' => 2
  },
  'zgh' => {
    'MA' => 2
  },
  'ilo' => {
    'PH' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'sou' => {
    'TH' => 2
  },
  'afr' => {
    'ZA' => 2,
    'NA' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'srp' => {
    'XK' => 1,
    'ME' => 1,
    'BA' => 1,
    'RS' => 1
  },
  'sot' => {
    'LS' => 1,
    'ZA' => 2
  },
  'vmw' => {
    'MZ' => 2
  },
  'hin' => {
    'ZA' => 2,
    'IN' => 1,
    'FJ' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'mlt' => {
    'MT' => 1
  },
  'ell' => {
    'CY' => 1,
    'GR' => 1
  },
  'tiv' => {
    'NG' => 2
  }
};
$Lang2Script = {
  'bfd' => {
    'Latn' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'bpy' => {
    'Beng' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'dty' => {
    'Deva' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'luo' => {
    'Latn' => 1
  },
  'wbr' => {
    'Deva' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'xnr' => {
    'Deva' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'ary' => {
    'Arab' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'ava' => {
    'Cyrl' => 1
  },
  'mrd' => {
    'Deva' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'ron' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'jml' => {
    'Deva' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'crk' => {
    'Cans' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'zap' => {
    'Latn' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'ccp' => {
    'Beng' => 1,
    'Cakm' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'amh' => {
    'Ethi' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'ale' => {
    'Latn' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'hau' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'sxn' => {
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'kor' => {
#    'Kore' => 1
    'Hang' => 1      
  },
  'akk' => {
    'Xsux' => 2
  },
  'hun' => {
    'Latn' => 1
  },
  'ful' => {
    'Latn' => 1,
    'Adlm' => 2
  },
  'hat' => {
    'Latn' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'nod' => {
    'Lana' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'yap' => {
    'Latn' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'srb' => {
    'Latn' => 1,
    'Sora' => 2
  },
  'sdc' => {
    'Latn' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'frr' => {
    'Latn' => 1
  },
  'kln' => {
    'Latn' => 1
  },
  'cho' => {
    'Latn' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'cjm' => {
    'Arab' => 2,
    'Cham' => 1
  },
  'chp' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'xsr' => {
    'Deva' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'fuq' => {
    'Latn' => 1
  },
  'kin' => {
    'Latn' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'ltg' => {
    'Latn' => 1
  },
  'lim' => {
    'Latn' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'aoz' => {
    'Latn' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'xav' => {
    'Latn' => 1
  },
  'chu' => {
    'Cyrl' => 2
  },
  'inh' => {
    'Latn' => 2,
    'Arab' => 2,
    'Cyrl' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'tem' => {
    'Latn' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'gil' => {
    'Latn' => 1
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'kiu' => {
    'Latn' => 1
  },
  'zea' => {
    'Latn' => 1
  },
  'glg' => {
    'Latn' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'pau' => {
    'Latn' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'gba' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'men' => {
    'Latn' => 1,
    'Mend' => 2
  },
  'fia' => {
    'Arab' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'sus' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'mas' => {
    'Latn' => 1
  },
  'zho' => {
    'Hans' => 1,
    'Bopo' => 2,
    'Phag' => 2,
    'Hant' => 1
  },
  'war' => {
    'Latn' => 1
  },
  'kyu' => {
    'Kali' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'lah' => {
    'Arab' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'srx' => {
    'Deva' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'kat' => {
    'Geor' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'fra' => {
    'Dupl' => 2,
    'Latn' => 1
  },
  'ssw' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'brh' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'uig' => {
    'Latn' => 2,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'bal' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'jav' => {
    'Java' => 2,
    'Latn' => 1
  },
  'tuk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'nld' => {
    'Latn' => 1
  },
  'hil' => {
    'Latn' => 1
  },
  'bbc' => {
    'Batk' => 2,
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'wln' => {
    'Latn' => 1
  },
  'pan' => {
    'Arab' => 1,
    'Guru' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'doi' => {
    'Arab' => 1,
    'Takr' => 2,
    'Deva' => 1
  },
  'pko' => {
    'Latn' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'gaa' => {
    'Latn' => 1
  },
  'swg' => {
    'Latn' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'ttt' => {
    'Cyrl' => 1,
    'Arab' => 2,
    'Latn' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'msa' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'bku' => {
    'Latn' => 1,
    'Buhd' => 2
  },
  'amo' => {
    'Latn' => 1
  },
  'mua' => {
    'Latn' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'mai' => {
    'Tirh' => 2,
    'Deva' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'ori' => {
    'Orya' => 1
  },
  'nov' => {
    'Latn' => 2
  },
  'tts' => {
    'Thai' => 1
  },
  'tzm' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'frp' => {
    'Latn' => 1
  },
  'rej' => {
    'Rjng' => 2,
    'Latn' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'lzz' => {
    'Latn' => 1,
    'Geor' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'cay' => {
    'Latn' => 1
  },
  'tdd' => {
    'Tale' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'kaj' => {
    'Latn' => 1
  },
  'bfq' => {
    'Taml' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'zgh' => {
    'Tfng' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'srp' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'tgk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'afr' => {
    'Latn' => 1
  },
  'sou' => {
    'Thai' => 1
  },
  'vmw' => {
    'Latn' => 1
  },
  'crj' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'sot' => {
    'Latn' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'hif' => {
    'Latn' => 1,
    'Deva' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'khq' => {
    'Latn' => 1
  },
  'crl' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'tdg' => {
    'Deva' => 1,
    'Tibt' => 2
  },
  'tso' => {
    'Latn' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'aze' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'gor' => {
    'Latn' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'vic' => {
    'Latn' => 1
  },
  'bjj' => {
    'Deva' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'grn' => {
    'Latn' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'dtm' => {
    'Latn' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'kas' => {
    'Arab' => 1,
    'Deva' => 1
  },
  'aln' => {
    'Latn' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'anp' => {
    'Deva' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'gju' => {
    'Arab' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'fao' => {
    'Latn' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'cop' => {
    'Arab' => 2,
    'Grek' => 2,
    'Copt' => 2
  },
  'man' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'kaz' => {
    'Arab' => 1,
    'Cyrl' => 1
  },
  'cja' => {
    'Cham' => 2,
    'Arab' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'xpr' => {
    'Prti' => 2
  },
  'thr' => {
    'Deva' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'skr' => {
    'Arab' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'pam' => {
    'Latn' => 1
  },
  'mdh' => {
    'Latn' => 1
  },
  'sga' => {
    'Latn' => 2,
    'Ogam' => 2
  },
  'tru' => {
    'Latn' => 1,
    'Syrc' => 2
  },
  'lep' => {
    'Lepc' => 1
  },
  'kon' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'lki' => {
    'Arab' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'lfn' => {
    'Latn' => 2,
    'Cyrl' => 2
  },
  'ibb' => {
    'Latn' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'aii' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'thl' => {
    'Deva' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'sas' => {
    'Latn' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'ban' => {
    'Latn' => 1,
    'Bali' => 2
  },
  'tur' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'kal' => {
    'Latn' => 1
  },
  'gay' => {
    'Latn' => 1
  },
  'eng' => {
    'Dsrt' => 2,
    'Shaw' => 2,
    'Latn' => 1
  },
  'xsa' => {
    'Sarb' => 2
  },
  'nus' => {
    'Latn' => 1
  },
  'nyn' => {
    'Latn' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'mgp' => {
    'Deva' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'den' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'sid' => {
    'Latn' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'krj' => {
    'Latn' => 1
  },
  'lua' => {
    'Latn' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'srr' => {
    'Latn' => 1
  },
  'gon' => {
    'Deva' => 1,
    'Telu' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'lag' => {
    'Latn' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'mdt' => {
    'Latn' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'mxc' => {
    'Latn' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'san' => {
    'Sidd' => 2,
    'Sinh' => 2,
    'Shrd' => 2,
    'Gran' => 2,
    'Deva' => 2
  },
  'ctd' => {
    'Latn' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'hmn' => {
    'Hmng' => 2,
    'Laoo' => 1,
    'Plrd' => 1,
    'Latn' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'arg' => {
    'Latn' => 1
  },
  'lez' => {
    'Aghb' => 2,
    'Cyrl' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'orm' => {
    'Ethi' => 2,
    'Latn' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'xum' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'kea' => {
    'Latn' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'moh' => {
    'Latn' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'mon' => {
    'Phag' => 2,
    'Cyrl' => 1,
    'Mong' => 2
  },
  'ikt' => {
    'Latn' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'mak' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'vai' => {
    'Vaii' => 1,
    'Latn' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'oci' => {
    'Latn' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'nde' => {
    'Latn' => 1
  },
  'mni' => {
    'Beng' => 1,
    'Mtei' => 2
  },
  'rmo' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'ina' => {
    'Latn' => 2
  },
  'nhw' => {
    'Latn' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'uga' => {
    'Ugar' => 2
  },
  'srn' => {
    'Latn' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'kam' => {
    'Latn' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'bem' => {
    'Latn' => 1
  },
  'kgp' => {
    'Latn' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'hsn' => {
    'Hans' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'lao' => {
    'Laoo' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'kha' => {
    'Beng' => 2,
    'Latn' => 1
  },
  'kik' => {
    'Latn' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'nzi' => {
    'Latn' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'arc' => {
    'Armi' => 2,
    'Nbat' => 2,
    'Palm' => 2
  },
  'bap' => {
    'Deva' => 1
  },
  'zza' => {
    'Latn' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'lui' => {
    'Latn' => 2
  },
  'yor' => {
    'Latn' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'bug' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'kjg' => {
    'Laoo' => 1,
    'Latn' => 2
  },
  'alt' => {
    'Cyrl' => 1
  },
  'ssy' => {
    'Latn' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'stq' => {
    'Latn' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'rkt' => {
    'Beng' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'rif' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'nsk' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'kir' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'kfy' => {
    'Deva' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'bos' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'rom' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'gwi' => {
    'Latn' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'run' => {
    'Latn' => 1
  },
  'pal' => {
    'Phli' => 2,
    'Phlp' => 2
  },
  'non' => {
    'Runr' => 2
  },
  'che' => {
    'Cyrl' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'taj' => {
    'Deva' => 1,
    'Tibt' => 2
  },
  'nmg' => {
    'Latn' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'fin' => {
    'Latn' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'guz' => {
    'Latn' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'byn' => {
    'Ethi' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'bqi' => {
    'Arab' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'som' => {
    'Arab' => 2,
    'Osma' => 2,
    'Latn' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'kmb' => {
    'Latn' => 1
  },
  'mro' => {
    'Latn' => 1,
    'Mroo' => 2
  },
  'lit' => {
    'Latn' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'tog' => {
    'Latn' => 1
  },
  'tkr' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'bis' => {
    'Latn' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'ach' => {
    'Latn' => 1
  },
  'syr' => {
    'Syrc' => 2,
    'Cyrl' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'fvr' => {
    'Latn' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'kao' => {
    'Latn' => 1
  },
  'lmo' => {
    'Latn' => 1
  },
  'bzx' => {
    'Latn' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'thq' => {
    'Deva' => 1
  },
  'crh' => {
    'Cyrl' => 1
  },
  'jpn' => {
    'Jpan' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'lcp' => {
    'Thai' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'ven' => {
    'Latn' => 1
  },
  'wbp' => {
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'bez' => {
    'Latn' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'rcf' => {
    'Latn' => 1
  },
  'hai' => {
    'Latn' => 1
  },
  'sck' => {
    'Deva' => 1
  },
  'kum' => {
    'Cyrl' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'atj' => {
    'Latn' => 1
  },
  'maz' => {
    'Latn' => 1
  },
  'ave' => {
    'Avst' => 2
  },
  'phn' => {
    'Phnx' => 2
  },
  'fuv' => {
    'Latn' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'urd' => {
    'Arab' => 1
  },
  'myx' => {
    'Latn' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'ndo' => {
    'Latn' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'egy' => {
    'Egyp' => 2
  },
  'tvl' => {
    'Latn' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'wol' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'osa' => {
    'Latn' => 2,
    'Osge' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'gag' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'vie' => {
    'Hani' => 2,
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'sam' => {
    'Samr' => 2,
    'Hebr' => 2
  },
  'tum' => {
    'Latn' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'byv' => {
    'Latn' => 1
  },
  'deu' => {
    'Latn' => 1,
    'Runr' => 2
  },
  'bin' => {
    'Latn' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'yue' => {
    'Hans' => 1,
    'Hant' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'bra' => {
    'Deva' => 1
  },
  'osc' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'arz' => {
    'Arab' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'tir' => {
    'Ethi' => 1
  },
  'mri' => {
    'Latn' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'swa' => {
    'Latn' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'kca' => {
    'Cyrl' => 1
  },
  'pms' => {
    'Latn' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'bmq' => {
    'Latn' => 1
  },
  'unr' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'iku' => {
    'Cans' => 1,
    'Latn' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'sun' => {
    'Sund' => 2,
    'Latn' => 1
  },
  'tly' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'hin' => {
    'Mahj' => 2,
    'Latn' => 2,
    'Deva' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'hnn' => {
    'Latn' => 1,
    'Hano' => 2
  },
  'mdr' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'fas' => {
    'Arab' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'sly' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'liv' => {
    'Latn' => 2
  },
  'srd' => {
    'Latn' => 1
  },
  'dyo' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'slk' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'bto' => {
    'Latn' => 1
  },
  'pli' => {
    'Thai' => 2,
    'Sinh' => 2,
    'Deva' => 2
  },
  'hne' => {
    'Deva' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'ett' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'sin' => {
    'Sinh' => 1
  },
  'sat' => {
    'Latn' => 2,
    'Beng' => 2,
    'Deva' => 2,
    'Orya' => 2,
    'Olck' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'wbq' => {
    'Telu' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'kom' => {
    'Cyrl' => 1,
    'Perm' => 2
  },
  'din' => {
    'Latn' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'rug' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'koi' => {
    'Cyrl' => 1
  },
  'pnt' => {
    'Latn' => 1,
    'Grek' => 1,
    'Cyrl' => 1
  },
  'kht' => {
    'Mymr' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'zha' => {
    'Hans' => 2,
    'Latn' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'bew' => {
    'Latn' => 1
  },
  'tsd' => {
    'Grek' => 1
  },
  'bum' => {
    'Latn' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'yao' => {
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'bua' => {
    'Cyrl' => 1
  },
  'hbs' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'ind' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'ain' => {
    'Latn' => 2,
    'Kana' => 2
  },
  'aym' => {
    'Latn' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'grt' => {
    'Beng' => 1
  },
  'fil' => {
    'Latn' => 1,
    'Tglg' => 2
  },
  'dsb' => {
    'Latn' => 1
  },
  'bam' => {
    'Nkoo' => 1,
    'Latn' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'btv' => {
    'Deva' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'udm' => {
    'Cyrl' => 1,
    'Latn' => 2
  },
  'rar' => {
    'Latn' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'unx' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'was' => {
    'Latn' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'mer' => {
    'Latn' => 1
  },
  'kur' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'wae' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'swb' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'bkm' => {
    'Latn' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'ttj' => {
    'Latn' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'sme' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'kxm' => {
    'Thai' => 1
  },
  'nym' => {
    'Latn' => 1
  },
  'avk' => {
    'Latn' => 2
  },
  'sqi' => {
    'Elba' => 2,
    'Latn' => 1
  },
  'kri' => {
    'Latn' => 1
  },
  'maf' => {
    'Latn' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'fur' => {
    'Latn' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'mtr' => {
    'Deva' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'shi' => {
    'Arab' => 1,
    'Tfng' => 1,
    'Latn' => 1
  },
  'hrv' => {
    'Latn' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'snd' => {
    'Sind' => 2,
    'Arab' => 1,
    'Khoj' => 2,
    'Deva' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'vmf' => {
    'Latn' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'bhi' => {
    'Deva' => 1
  },
  'syl' => {
    'Sylo' => 2,
    'Beng' => 1
  },
  'bft' => {
    'Tibt' => 2,
    'Arab' => 1
  },
  'nnh' => {
    'Latn' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'grc' => {
    'Grek' => 2,
    'Cprt' => 2,
    'Linb' => 2
  },
  'uzb' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'kan' => {
    'Knda' => 1
  }
};
$Territory2Lang = {
  'AM' => {
    'hye' => 1
  },
  'LU' => {
    'ltz' => 1,
    'deu' => 1,
    'fra' => 1,
    'eng' => 2
  },
  'MX' => {
    'eng' => 2,
    'spa' => 1
  },
  'FI' => {
    'eng' => 2,
    'fin' => 1,
    'swe' => 1
  },
  'LT' => {
    'eng' => 2,
    'lit' => 1,
    'rus' => 2
  },
  'DO' => {
    'spa' => 1
  },
  'DZ' => {
    'kab' => 2,
    'arq' => 2,
    'ara' => 2,
    'fra' => 1,
    'eng' => 2
  },
  'EC' => {
    'que' => 1,
    'spa' => 1
  },
  'WS' => {
    'smo' => 1,
    'eng' => 1
  },
  'CO' => {
    'spa' => 1
  },
  'ID' => {
    'bug' => 2,
    'rej' => 2,
    'bjn' => 2,
    'msa' => 2,
    'ban' => 2,
    'mad' => 2,
    'bew' => 2,
    'ljp' => 2,
    'bbc' => 2,
    'sas' => 2,
    'sun' => 2,
    'mak' => 2,
    'gor' => 2,
    'jav' => 2,
    'min' => 2,
    'ace' => 2,
    'zho' => 2,
    'ind' => 1
  },
  'ME' => {
    'srp' => 1,
    'hbs' => 1
  },
  'NG' => {
    'tiv' => 2,
    'hau' => 2,
    'efi' => 2,
    'ibb' => 2,
    'pcm' => 2,
    'ful' => 2,
    'bin' => 2,
    'eng' => 1,
    'fuv' => 2,
    'ibo' => 2,
    'yor' => 1
  },
  'SE' => {
    'fin' => 2,
    'swe' => 1,
    'eng' => 2
  },
  'PS' => {
    'ara' => 1
  },
  'GH' => {
    'ewe' => 2,
    'aka' => 2,
    'abr' => 2,
    'eng' => 1,
    'gaa' => 2
  },
  'AE' => {
    'ara' => 1,
    'eng' => 2
  },
  'DG' => {
    'eng' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'JP' => {
    'jpn' => 1
  },
  'BD' => {
    'rkt' => 2,
    'ben' => 1,
    'eng' => 2,
    'syl' => 2
  },
  'AT' => {
    'eng' => 2,
    'hun' => 2,
    'hrv' => 2,
    'slv' => 2,
    'deu' => 1,
    'hbs' => 2,
    'bar' => 2
  },
  'NO' => {
    'sme' => 2,
    'nor' => 1,
    'nob' => 1,
    'nno' => 1
  },
  'MU' => {
    'mfe' => 2,
    'bho' => 2,
    'fra' => 1,
    'eng' => 1
  },
  'EH' => {
    'ara' => 1
  },
  'OM' => {
    'ara' => 1
  },
  'UZ' => {
    'uzb' => 1,
    'rus' => 2
  },
  'AW' => {
    'pap' => 1,
    'nld' => 1
  },
  'VU' => {
    'fra' => 1,
    'bis' => 1,
    'eng' => 1
  },
  'RE' => {
    'rcf' => 2,
    'fra' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'CN' => {
    'uig' => 2,
    'zha' => 2,
    'mon' => 2,
    'hak' => 2,
    'kaz' => 2,
    'gan' => 2,
    'wuu' => 2,
    'yue' => 2,
    'hsn' => 2,
    'nan' => 2,
    'iii' => 2,
    'kor' => 2,
    'bod' => 2,
    'zho' => 1
  },
  'CA' => {
    'eng' => 1,
    'ikt' => 2,
    'fra' => 1,
    'iku' => 2
  },
  'VC' => {
    'eng' => 1
  },
  'EA' => {
    'spa' => 1
  },
  'DE' => {
    'gsw' => 2,
    'nld' => 2,
    'ita' => 2,
    'vmf' => 2,
    'tur' => 2,
    'deu' => 1,
    'eng' => 2,
    'dan' => 2,
    'fra' => 2,
    'nds' => 2,
    'bar' => 2,
    'rus' => 2,
    'spa' => 2
  },
  'HR' => {
    'eng' => 2,
    'hrv' => 1,
    'ita' => 2,
    'hbs' => 1
  },
  'BW' => {
    'tsn' => 1,
    'eng' => 1
  },
  'KI' => {
    'eng' => 1,
    'gil' => 1
  },
  'SO' => {
    'som' => 1,
    'ara' => 1
  },
  'CK' => {
    'eng' => 1
  },
  'SA' => {
    'ara' => 1
  },
  'PK' => {
    'bal' => 2,
    'hno' => 2,
    'eng' => 1,
    'bgn' => 2,
    'pan' => 2,
    'skr' => 2,
    'lah' => 2,
    'brh' => 2,
    'snd' => 2,
    'fas' => 2,
    'pus' => 2,
    'urd' => 1
  },
  'PW' => {
    'eng' => 1,
    'pau' => 1
  },
  'CI' => {
    'sef' => 2,
    'fra' => 1,
    'dnj' => 2,
    'bci' => 2
  },
  'LV' => {
    'lav' => 1,
    'rus' => 2,
    'eng' => 2
  },
  'AD' => {
    'spa' => 2,
    'cat' => 1
  },
  'IL' => {
    'eng' => 2,
    'ara' => 1,
    'heb' => 1
  },
  'AR' => {
    'spa' => 1,
    'eng' => 2
  },
  'KP' => {
    'kor' => 1
  },
  'KM' => {
    'fra' => 1,
    'ara' => 1,
    'wni' => 1,
    'zdj' => 1
  },
  'PG' => {
    'hmo' => 1,
    'tpi' => 1,
    'eng' => 1
  },
  'AC' => {
    'eng' => 2
  },
  'PY' => {
    'grn' => 1,
    'spa' => 1
  },
  'SL' => {
    'men' => 2,
    'kri' => 2,
    'eng' => 1,
    'tem' => 2
  },
  'CV' => {
    'por' => 1,
    'kea' => 2
  },
  'US' => {
    'kor' => 2,
    'deu' => 2,
    'vie' => 2,
    'zho' => 2,
    'fra' => 2,
    'eng' => 1,
    'fil' => 2,
    'spa' => 2,
    'haw' => 2,
    'ita' => 2
  },
  'KE' => {
    'guz' => 2,
    'kik' => 2,
    'luo' => 2,
    'mer' => 2,
    'eng' => 1,
    'luy' => 2,
    'kam' => 2,
    'swa' => 1,
    'kln' => 2
  },
  'JM' => {
    'jam' => 2,
    'eng' => 1
  },
  'MP' => {
    'eng' => 1
  },
  'GN' => {
    'sus' => 2,
    'ful' => 2,
    'fra' => 1,
    'man' => 2
  },
  'GW' => {
    'por' => 1
  },
  'SZ' => {
    'ssw' => 1,
    'eng' => 1
  },
  'LB' => {
    'ara' => 1,
    'eng' => 2
  },
  'RU' => {
    'bak' => 2,
    'aze' => 2,
    'tyv' => 2,
    'ady' => 2,
    'kum' => 2,
    'tat' => 2,
    'myv' => 2,
    'sah' => 2,
    'inh' => 2,
    'che' => 2,
    'ava' => 2,
    'hye' => 2,
    'rus' => 1,
    'krc' => 2,
    'kom' => 2,
    'mdf' => 2,
    'kbd' => 2,
    'chv' => 2,
    'koi' => 2,
    'udm' => 2,
    'lbe' => 2,
    'lez' => 2
  },
  'AX' => {
    'swe' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'IR' => {
    'glk' => 2,
    'ara' => 2,
    'mzn' => 2,
    'luz' => 2,
    'lrc' => 2,
    'aze' => 2,
    'bqi' => 2,
    'bal' => 2,
    'tuk' => 2,
    'rmt' => 2,
    'sdh' => 2,
    'fas' => 1,
    'ckb' => 2,
    'kur' => 2
  },
  'UM' => {
    'eng' => 1
  },
  'RW' => {
    'kin' => 1,
    'eng' => 1,
    'fra' => 1
  },
  'YE' => {
    'ara' => 1,
    'eng' => 2
  },
  'KR' => {
    'kor' => 1
  },
  'SN' => {
    'snf' => 2,
    'knf' => 2,
    'bsc' => 2,
    'mey' => 2,
    'wol' => 1,
    'bjt' => 2,
    'dyo' => 2,
    'tnr' => 2,
    'mfv' => 2,
    'ful' => 2,
    'srr' => 2,
    'sav' => 2,
    'fra' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'GM' => {
    'man' => 2,
    'eng' => 1
  },
  'IM' => {
    'glv' => 1,
    'eng' => 1
  },
  'SI' => {
    'deu' => 2,
    'slv' => 1,
    'hrv' => 2,
    'eng' => 2,
    'hbs' => 2
  },
  'IT' => {
    'eng' => 2,
    'fra' => 2,
    'srd' => 2,
    'ita' => 1
  },
  'PE' => {
    'que' => 1,
    'spa' => 1
  },
  'TN' => {
    'ara' => 1,
    'aeb' => 2,
    'fra' => 1
  },
  'MK' => {
    'sqi' => 2,
    'mkd' => 1
  },
  'MQ' => {
    'fra' => 1
  },
  'IS' => {
    'isl' => 1
  },
  'GE' => {
    'oss' => 2,
    'kat' => 1,
    'abk' => 2
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'CD' => {
    'swa' => 2,
    'lin' => 2,
    'fra' => 1,
    'kon' => 2,
    'lua' => 2,
    'lub' => 2
  },
  'VG' => {
    'eng' => 1
  },
  'VA' => {
    'lat' => 2,
    'ita' => 1
  },
  'NP' => {
    'mai' => 2,
    'nep' => 1,
    'bho' => 2
  },
  'MN' => {
    'mon' => 1
  },
  'BQ' => {
    'nld' => 1,
    'pap' => 2
  },
  'VE' => {
    'spa' => 1
  },
  'BS' => {
    'eng' => 1
  },
  'FK' => {
    'eng' => 1
  },
  'NC' => {
    'fra' => 1
  },
  'JE' => {
    'eng' => 1
  },
  'GQ' => {
    'fra' => 1,
    'por' => 1,
    'spa' => 1,
    'fan' => 2
  },
  'BM' => {
    'eng' => 1
  },
  'NR' => {
    'eng' => 1,
    'nau' => 1
  },
  'YT' => {
    'swb' => 2,
    'fra' => 1,
    'buc' => 2
  },
  'PL' => {
    'rus' => 2,
    'deu' => 2,
    'eng' => 2,
    'pol' => 1,
    'lit' => 2,
    'csb' => 2
  },
  'MZ' => {
    'por' => 1,
    'ndc' => 2,
    'mgh' => 2,
    'vmw' => 2,
    'ngl' => 2,
    'tso' => 2,
    'seh' => 2
  },
  'UG' => {
    'ach' => 2,
    'laj' => 2,
    'myx' => 2,
    'lug' => 2,
    'teo' => 2,
    'xog' => 2,
    'nyn' => 2,
    'swa' => 1,
    'cgg' => 2,
    'eng' => 1
  },
  'SJ' => {
    'rus' => 2,
    'nor' => 1,
    'nob' => 1
  },
  'UA' => {
    'ukr' => 1,
    'rus' => 1,
    'pol' => 2
  },
  'CL' => {
    'eng' => 2,
    'spa' => 1
  },
  'KG' => {
    'kir' => 1,
    'rus' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'DK' => {
    'deu' => 2,
    'kal' => 2,
    'dan' => 1,
    'eng' => 2
  },
  'HK' => {
    'zho' => 1,
    'eng' => 1,
    'yue' => 2
  },
  'MH' => {
    'eng' => 1,
    'mah' => 1
  },
  'DJ' => {
    'som' => 2,
    'ara' => 1,
    'fra' => 1,
    'aar' => 2
  },
  'SR' => {
    'srn' => 2,
    'nld' => 1
  },
  'CP' => {
    'und' => 2
  },
  'TV' => {
    'tvl' => 1,
    'eng' => 1
  },
  'CU' => {
    'spa' => 1
  },
  'MC' => {
    'fra' => 1
  },
  'CC' => {
    'msa' => 2,
    'eng' => 1
  },
  'BR' => {
    'eng' => 2,
    'por' => 1,
    'deu' => 2
  },
  'BV' => {
    'und' => 2
  },
  'LS' => {
    'eng' => 1,
    'sot' => 1
  },
  'IO' => {
    'eng' => 1
  },
  'VI' => {
    'eng' => 1
  },
  'TT' => {
    'eng' => 1
  },
  'BA' => {
    'hbs' => 1,
    'hrv' => 1,
    'srp' => 1,
    'bos' => 1,
    'eng' => 2
  },
  'ML' => {
    'ffm' => 2,
    'fra' => 1,
    'ful' => 2,
    'snk' => 2,
    'bam' => 2
  },
  'CM' => {
    'eng' => 1,
    'fra' => 1,
    'bum' => 2
  },
  'GR' => {
    'eng' => 2,
    'ell' => 1
  },
  'BJ' => {
    'fon' => 2,
    'fra' => 1
  },
  'BY' => {
    'bel' => 1,
    'rus' => 1
  },
  'ZA' => {
    'afr' => 2,
    'eng' => 1,
    'nbl' => 2,
    'xho' => 2,
    'sot' => 2,
    'tso' => 2,
    'hin' => 2,
    'ssw' => 2,
    'nso' => 2,
    'zul' => 2,
    'tsn' => 2,
    'ven' => 2
  },
  'LK' => {
    'sin' => 1,
    'tam' => 1,
    'eng' => 2
  },
  'GB' => {
    'cym' => 2,
    'deu' => 2,
    'sco' => 2,
    'fra' => 2,
    'gle' => 2,
    'gla' => 2,
    'eng' => 1
  },
  'AO' => {
    'umb' => 2,
    'por' => 1,
    'kmb' => 2
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'SG' => {
    'msa' => 1,
    'zho' => 1,
    'tam' => 1,
    'eng' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'DM' => {
    'eng' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'SY' => {
    'kur' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'MG' => {
    'mlg' => 1,
    'fra' => 1,
    'eng' => 1
  },
  'ER' => {
    'tig' => 2,
    'tir' => 1,
    'ara' => 1,
    'eng' => 1
  },
  'GA' => {
    'fra' => 1
  },
  'MM' => {
    'mya' => 1,
    'shn' => 2
  },
  'FM' => {
    'eng' => 1,
    'pon' => 2,
    'chk' => 2
  },
  'TR' => {
    'kur' => 2,
    'zza' => 2,
    'eng' => 2,
    'tur' => 1
  },
  'MT' => {
    'ita' => 2,
    'mlt' => 1,
    'eng' => 1
  },
  'SM' => {
    'ita' => 1
  },
  'BZ' => {
    'eng' => 1,
    'spa' => 2
  },
  'ZM' => {
    'nya' => 2,
    'bem' => 2,
    'eng' => 1
  },
  'ES' => {
    'ast' => 2,
    'eng' => 2,
    'glg' => 2,
    'eus' => 2,
    'spa' => 1,
    'cat' => 2
  },
  'TZ' => {
    'kde' => 2,
    'eng' => 1,
    'nym' => 2,
    'swa' => 1,
    'suk' => 2
  },
  'LA' => {
    'lao' => 1
  },
  'GS' => {
    'und' => 2
  },
  'TO' => {
    'ton' => 1,
    'eng' => 1
  },
  'GY' => {
    'eng' => 1
  },
  'UY' => {
    'spa' => 1
  },
  'HU' => {
    'hun' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'MW' => {
    'eng' => 1,
    'tum' => 2,
    'nya' => 1
  },
  'LI' => {
    'deu' => 1,
    'gsw' => 1
  },
  'GI' => {
    'spa' => 2,
    'eng' => 1
  },
  'SH' => {
    'eng' => 1
  },
  'MY' => {
    'zho' => 2,
    'tam' => 2,
    'eng' => 2,
    'msa' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'NU' => {
    'niu' => 1,
    'eng' => 1
  },
  'SD' => {
    'ara' => 1,
    'bej' => 2,
    'eng' => 1,
    'fvr' => 2
  },
  'CR' => {
    'spa' => 1
  },
  'BB' => {
    'eng' => 1
  },
  'TH' => {
    'mfa' => 2,
    'eng' => 2,
    'sou' => 2,
    'zho' => 2,
    'tts' => 2,
    'tha' => 1,
    'msa' => 2,
    'kxm' => 2,
    'nod' => 2
  },
  'AI' => {
    'eng' => 1
  },
  'NF' => {
    'eng' => 1
  },
  'RO' => {
    'eng' => 2,
    'ron' => 1,
    'hun' => 2,
    'fra' => 2,
    'spa' => 2
  },
  'BH' => {
    'ara' => 1
  },
  'GT' => {
    'quc' => 2,
    'spa' => 1
  },
  'BE' => {
    'fra' => 1,
    'vls' => 2,
    'eng' => 2,
    'nld' => 1,
    'deu' => 1
  },
  'TJ' => {
    'rus' => 2,
    'tgk' => 1
  },
  'MO' => {
    'zho' => 1,
    'por' => 1
  },
  'NZ' => {
    'eng' => 1,
    'mri' => 1
  },
  'MD' => {
    'ron' => 1
  },
  'MS' => {
    'eng' => 1
  },
  'TG' => {
    'ewe' => 2,
    'fra' => 1
  },
  'FJ' => {
    'hif' => 1,
    'eng' => 1,
    'fij' => 1,
    'hin' => 2
  },
  'BT' => {
    'dzo' => 1
  },
  'EE' => {
    'rus' => 2,
    'fin' => 2,
    'est' => 1,
    'eng' => 2
  },
  'KZ' => {
    'rus' => 1,
    'eng' => 2,
    'kaz' => 1,
    'deu' => 2
  },
  'FR' => {
    'eng' => 2,
    'fra' => 1,
    'deu' => 2,
    'oci' => 2,
    'spa' => 2,
    'ita' => 2
  },
  'MR' => {
    'ara' => 1
  },
  'HT' => {
    'fra' => 1,
    'hat' => 1
  },
  'PF' => {
    'tah' => 1,
    'fra' => 1
  },
  'ST' => {
    'por' => 1
  },
  'FO' => {
    'fao' => 1
  },
  'IQ' => {
    'kur' => 2,
    'aze' => 2,
    'ckb' => 2,
    'eng' => 2,
    'ara' => 1
  },
  'KH' => {
    'khm' => 1
  },
  'HN' => {
    'spa' => 1
  },
  'AL' => {
    'sqi' => 1
  },
  'BG' => {
    'rus' => 2,
    'bul' => 1,
    'eng' => 2
  },
  'SV' => {
    'spa' => 1
  },
  'PT' => {
    'por' => 1,
    'eng' => 2,
    'fra' => 2,
    'spa' => 2
  },
  'GU' => {
    'eng' => 1,
    'cha' => 1
  },
  'XK' => {
    'sqi' => 1,
    'srp' => 1,
    'aln' => 2,
    'hbs' => 1
  },
  'IN' => {
    'mtr' => 2,
    'hin' => 1,
    'mai' => 2,
    'tel' => 2,
    'asm' => 2,
    'awa' => 2,
    'gon' => 2,
    'wbr' => 2,
    'hoj' => 2,
    'bgc' => 2,
    'tcy' => 2,
    'kok' => 2,
    'mwr' => 2,
    'khn' => 2,
    'unr' => 2,
    'swv' => 2,
    'tam' => 2,
    'mag' => 2,
    'kha' => 2,
    'noe' => 2,
    'bho' => 2,
    'urd' => 2,
    'nep' => 2,
    'gom' => 2,
    'wbq' => 2,
    'kas' => 2,
    'kan' => 2,
    'hoc' => 2,
    'doi' => 2,
    'lmn' => 2,
    'guj' => 2,
    'eng' => 1,
    'dcc' => 2,
    'wtm' => 2,
    'hne' => 2,
    'mar' => 2,
    'pan' => 2,
    'sat' => 2,
    'mal' => 2,
    'kfy' => 2,
    'bjj' => 2,
    'san' => 2,
    'bhi' => 2,
    'rkt' => 2,
    'ben' => 2,
    'bhb' => 2,
    'ori' => 2,
    'brx' => 2,
    'kru' => 2,
    'mni' => 2,
    'raj' => 2,
    'sck' => 2,
    'gbm' => 2,
    'xnr' => 2,
    'snd' => 2
  },
  'EG' => {
    'arz' => 2,
    'ara' => 2,
    'eng' => 2
  },
  'NE' => {
    'fuq' => 2,
    'hau' => 2,
    'dje' => 2,
    'ful' => 2,
    'fra' => 1,
    'tmh' => 2
  },
  'AQ' => {
    'und' => 2
  },
  'NL' => {
    'nds' => 2,
    'fry' => 2,
    'deu' => 2,
    'eng' => 2,
    'nld' => 1,
    'fra' => 2
  },
  'PN' => {
    'eng' => 1
  },
  'MV' => {
    'div' => 1
  },
  'KY' => {
    'eng' => 1
  },
  'WF' => {
    'fra' => 1,
    'fud' => 2,
    'wls' => 2
  },
  'PH' => {
    'pam' => 2,
    'eng' => 1,
    'bik' => 2,
    'war' => 2,
    'fil' => 1,
    'spa' => 2,
    'mdh' => 2,
    'tsg' => 2,
    'hil' => 2,
    'bhk' => 2,
    'ilo' => 2,
    'pag' => 2,
    'ceb' => 2
  },
  'CF' => {
    'fra' => 1,
    'sag' => 1
  },
  'CG' => {
    'fra' => 1
  },
  'VN' => {
    'vie' => 1,
    'zho' => 2
  },
  'LC' => {
    'eng' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'NA' => {
    'ndo' => 2,
    'kua' => 2,
    'afr' => 2,
    'eng' => 1
  },
  'RS' => {
    'sqi' => 2,
    'hrv' => 2,
    'hbs' => 1,
    'hun' => 2,
    'ron' => 2,
    'srp' => 1,
    'slk' => 2,
    'ukr' => 2
  },
  'PR' => {
    'eng' => 1,
    'spa' => 1
  },
  'PA' => {
    'spa' => 1
  },
  'MA' => {
    'ary' => 2,
    'fra' => 1,
    'eng' => 2,
    'tzm' => 1,
    'ara' => 2,
    'shi' => 2,
    'rif' => 2,
    'zgh' => 2
  },
  'HM' => {
    'und' => 2
  },
  'CH' => {
    'ita' => 1,
    'gsw' => 1,
    'deu' => 1,
    'roh' => 2,
    'eng' => 2,
    'fra' => 1
  },
  'GP' => {
    'fra' => 1
  },
  'AS' => {
    'smo' => 1,
    'eng' => 1
  },
  'TD' => {
    'fra' => 1,
    'ara' => 1
  },
  'SC' => {
    'crs' => 2,
    'fra' => 1,
    'eng' => 1
  },
  'AZ' => {
    'aze' => 1
  },
  'GF' => {
    'gcr' => 2,
    'fra' => 1
  },
  'TK' => {
    'eng' => 1,
    'tkl' => 1
  },
  'SK' => {
    'ces' => 2,
    'slk' => 1,
    'deu' => 2,
    'eng' => 2
  },
  'ZW' => {
    'sna' => 1,
    'nde' => 1,
    'eng' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'QA' => {
    'ara' => 1
  },
  'BO' => {
    'aym' => 1,
    'que' => 1,
    'spa' => 1
  },
  'BI' => {
    'fra' => 1,
    'eng' => 1,
    'run' => 1
  },
  'MF' => {
    'fra' => 1
  },
  'CZ' => {
    'slk' => 2,
    'ces' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'CX' => {
    'eng' => 1
  },
  'AF' => {
    'bal' => 2,
    'haz' => 2,
    'uzb' => 2,
    'fas' => 1,
    'pus' => 1,
    'tuk' => 2
  },
  'PM' => {
    'fra' => 1
  },
  'CY' => {
    'eng' => 2,
    'tur' => 1,
    'ell' => 1
  },
  'AU' => {
    'eng' => 1
  },
  'KN' => {
    'eng' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'JO' => {
    'ara' => 1,
    'eng' => 2
  },
  'CW' => {
    'pap' => 1,
    'nld' => 1
  },
  'LY' => {
    'ara' => 1
  },
  'BF' => {
    'mos' => 2,
    'fra' => 1,
    'dyu' => 2
  },
  'TA' => {
    'eng' => 2
  },
  'ET' => {
    'som' => 2,
    'wal' => 2,
    'tir' => 2,
    'aar' => 2,
    'sid' => 2,
    'eng' => 2,
    'amh' => 1,
    'orm' => 2
  },
  'SS' => {
    'eng' => 1,
    'ara' => 2
  },
  'GL' => {
    'kal' => 1
  },
  'SX' => {
    'eng' => 1,
    'nld' => 1
  },
  'BL' => {
    'fra' => 1
  },
  'TW' => {
    'zho' => 1
  }
};
$Script2Lang = {
  'Nbat' => {
    'arc' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Aghb' => {
    'lez' => 2
  },
  'Osma' => {
    'som' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Tale' => {
    'tdd' => 1
  },
  'Tavt' => {
    'blt' => 1
  },
  'Hant' => {
    'zho' => 1,
    'yue' => 1
  },
  'Lina' => {
    'lab' => 2
  },
  'Bamu' => {
    'bax' => 1
  },
  'Telu' => {
    'gon' => 1,
    'wbq' => 1,
    'tel' => 1,
    'lmn' => 1
  },
  'Ital' => {
    'xum' => 2,
    'ett' => 2,
    'osc' => 2
  },
  'Talu' => {
    'khb' => 1
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Khmr' => {
    'khm' => 1
  },
  'Orkh' => {
    'otk' => 2
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Hans' => {
    'lzh' => 2,
    'hsn' => 1,
    'wuu' => 1,
    'yue' => 1,
    'zho' => 1,
    'nan' => 1,
    'zha' => 2,
    'hak' => 1,
    'gan' => 1
  },
  'Ogam' => {
    'sga' => 2
  },
  'Plrd' => {
    'hmn' => 1,
    'hmd' => 1
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Latn' => {
    'mgo' => 1,
    'fud' => 1,
    'nch' => 1,
    'fin' => 1,
    'dak' => 1,
    'por' => 1,
    'nmg' => 1,
    'sms' => 1,
    'sef' => 1,
    'inh' => 2,
    'cos' => 1,
    'run' => 1,
    'xav' => 1,
    'loz' => 1,
    'aoz' => 1,
    'crs' => 1,
    'jut' => 2,
    'gil' => 1,
    'laj' => 1,
    'kck' => 1,
    'dje' => 1,
    'tem' => 1,
    'guz' => 1,
    'frc' => 1,
    'fon' => 1,
    'rgn' => 1,
    'eus' => 1,
    'gba' => 1,
    'pau' => 1,
    'akz' => 1,
    'ext' => 1,
    'bis' => 1,
    'dum' => 2,
    'arw' => 2,
    'tog' => 1,
    'tkr' => 1,
    'chn' => 2,
    'kmb' => 1,
    'som' => 1,
    'lit' => 1,
    'zea' => 1,
    'kiu' => 1,
    'glg' => 1,
    'mro' => 1,
    'cch' => 1,
    'eka' => 1,
    'bzx' => 1,
    'mwk' => 1,
    'fan' => 1,
    'tmh' => 1,
    'kao' => 1,
    'bjn' => 1,
    'lmo' => 1,
    'men' => 1,
    'ach' => 1,
    'ltz' => 1,
    'fvr' => 1,
    'cic' => 1,
    'mfe' => 1,
    'dyu' => 1,
    'bez' => 1,
    'nyo' => 1,
    'mas' => 1,
    'moe' => 1,
    'wbp' => 1,
    'war' => 1,
    'lij' => 1,
    'ewo' => 1,
    'ven' => 1,
    'pdc' => 1,
    'sus' => 1,
    'abr' => 1,
    'que' => 1,
    'ssw' => 1,
    'suk' => 1,
    'lbw' => 1,
    'mad' => 1,
    'fra' => 1,
    'ceb' => 1,
    'mls' => 1,
    'hsb' => 1,
    'gsw' => 1,
    'yua' => 1,
    'mgh' => 1,
    'rap' => 1,
    'bla' => 1,
    'atj' => 1,
    'bal' => 2,
    'puu' => 1,
    'rob' => 1,
    'iba' => 1,
    'ace' => 1,
    'niu' => 1,
    'uig' => 2,
    'oji' => 2,
    'chk' => 1,
    'hai' => 1,
    'sbp' => 1,
    'rcf' => 1,
    'pfl' => 1,
    'brh' => 2,
    'ndc' => 1,
    'goh' => 2,
    'zmi' => 1,
    'gur' => 1,
    'grb' => 1,
    'fuv' => 1,
    'wln' => 1,
    'rwk' => 1,
    'tuk' => 1,
    'jav' => 1,
    'nld' => 1,
    'maz' => 1,
    'bbc' => 1,
    'hil' => 1,
    'moh' => 1,
    'bre' => 1,
    'epo' => 1,
    'ast' => 1,
    'aro' => 1,
    'bfd' => 1,
    'xum' => 2,
    'kea' => 1,
    'buc' => 1,
    'bss' => 1,
    'nds' => 1,
    'vai' => 1,
    'ngl' => 1,
    'gub' => 1,
    'xho' => 1,
    'luo' => 1,
    'mwl' => 1,
    'see' => 1,
    'kkj' => 1,
    'mak' => 1,
    'ikt' => 1,
    'vro' => 1,
    'ter' => 1,
    'ebu' => 1,
    'saf' => 1,
    'ina' => 2,
    'nhw' => 1,
    'spa' => 1,
    'sgs' => 1,
    'nya' => 1,
    'rmo' => 1,
    'ron' => 1,
    'ybb' => 1,
    'mos' => 1,
    'oci' => 1,
    'scn' => 1,
    'nde' => 1,
    'teo' => 1,
    'seh' => 1,
    'bem' => 1,
    'kgp' => 1,
    'kam' => 1,
    'bci' => 1,
    'lun' => 1,
    'cre' => 2,
    'nbl' => 1,
    'umb' => 1,
    'srn' => 1,
    'lkt' => 1,
    'zap' => 1,
    'lub' => 1,
    'smn' => 1,
    'nzi' => 1,
    'naq' => 1,
    'kha' => 1,
    'kik' => 1,
    'qug' => 1,
    'pag' => 1,
    'nso' => 1,
    'isl' => 1,
    'ksf' => 1,
    'hop' => 1,
    'arn' => 1,
    'bug' => 1,
    'mah' => 1,
    'ksh' => 1,
    'sco' => 1,
    'ljp' => 1,
    'yor' => 1,
    'hat' => 1,
    'hun' => 1,
    'ful' => 1,
    'lui' => 2,
    'sxn' => 1,
    'hau' => 1,
    'ipk' => 1,
    'lin' => 1,
    'ale' => 1,
    'sad' => 1,
    'tpi' => 1,
    'tkl' => 1,
    'ses' => 1,
    'egl' => 1,
    'krl' => 1,
    'zza' => 1,
    'pdt' => 1,
    'kln' => 1,
    'nsk' => 2,
    'haw' => 1,
    'rtm' => 1,
    'rif' => 1,
    'chp' => 1,
    'cho' => 1,
    'frr' => 1,
    'sei' => 1,
    'sdc' => 1,
    'dan' => 1,
    'sli' => 1,
    'srb' => 1,
    'ssy' => 1,
    'yap' => 1,
    'aar' => 1,
    'stq' => 1,
    'ita' => 1,
    'kjg' => 2,
    'csb' => 2,
    'mic' => 1,
    'bar' => 1,
    'kge' => 1,
    'gwi' => 1,
    'ltg' => 1,
    'rom' => 1,
    'bos' => 1,
    'lim' => 1,
    'fuq' => 1,
    'kin' => 1,
    'kir' => 1,
    'tsn' => 1,
    'pol' => 1,
    'yrl' => 1,
    'vec' => 1,
    'rup' => 1,
    'cym' => 1,
    'tsi' => 1,
    'vot' => 2,
    'bik' => 1,
    'rug' => 1,
    'min' => 1,
    'cgg' => 1,
    'esu' => 1,
    'car' => 1,
    'aln' => 1,
    'rmu' => 1,
    'din' => 1,
    'kos' => 1,
    'rng' => 1,
    'pcd' => 1,
    'roh' => 1,
    'yao' => 1,
    'mdh' => 1,
    'pcm' => 1,
    'sga' => 2,
    'guc' => 1,
    'bew' => 1,
    'mwv' => 1,
    'bum' => 1,
    'pam' => 1,
    'zha' => 1,
    'nhe' => 1,
    'glv' => 1,
    'nap' => 1,
    'fao' => 1,
    'agq' => 1,
    'ang' => 2,
    'pnt' => 1,
    'man' => 1,
    'hmo' => 1,
    'ibb' => 1,
    'lfn' => 2,
    'arp' => 1,
    'dsb' => 1,
    'bam' => 1,
    'njo' => 1,
    'fil' => 1,
    'aym' => 1,
    'ain' => 2,
    'nxq' => 1,
    'twq' => 1,
    'ind' => 1,
    'hbs' => 1,
    'kon' => 1,
    'bqv' => 1,
    'tru' => 1,
    'nus' => 1,
    'nyn' => 1,
    'was' => 1,
    'cha' => 1,
    'iii' => 2,
    'gay' => 1,
    'kal' => 1,
    'tur' => 1,
    'ban' => 1,
    'eng' => 1,
    'lat' => 2,
    'wls' => 1,
    'fro' => 2,
    'syi' => 1,
    'lug' => 1,
    'quc' => 1,
    'sas' => 1,
    'del' => 1,
    'udm' => 2,
    'rar' => 1,
    'tsg' => 1,
    'sme' => 1,
    'krj' => 1,
    'vol' => 2,
    'ttj' => 1,
    'cps' => 1,
    'sid' => 1,
    'swb' => 2,
    'bkm' => 1,
    'kau' => 1,
    'gle' => 1,
    'izh' => 1,
    'nor' => 1,
    'tli' => 1,
    'mer' => 1,
    'den' => 1,
    'wae' => 1,
    'kur' => 1,
    'ife' => 1,
    'rmf' => 1,
    'bze' => 1,
    'lav' => 1,
    'efi' => 1,
    'dua' => 1,
    'lag' => 1,
    'mgy' => 1,
    'mdt' => 1,
    'shi' => 1,
    'dtp' => 1,
    'srr' => 1,
    'maf' => 1,
    'fur' => 1,
    'bbj' => 1,
    'nij' => 1,
    'avk' => 2,
    'nym' => 1,
    'lua' => 1,
    'szl' => 1,
    'kri' => 1,
    'mus' => 1,
    'sqi' => 1,
    'gcr' => 1,
    'ctd' => 1,
    'mxc' => 1,
    'luy' => 1,
    'kac' => 1,
    'asa' => 1,
    'vmf' => 1,
    'kde' => 1,
    'hrv' => 1,
    'zul' => 1,
    'cor' => 1,
    'uzb' => 1,
    'ria' => 1,
    'orm' => 1,
    'vep' => 1,
    'dgr' => 1,
    'fry' => 1,
    'nnh' => 1,
    'prg' => 2,
    'gmh' => 2,
    'nau' => 1,
    'ada' => 1,
    'arg' => 1,
    'hmn' => 1,
    'wol' => 1,
    'swg' => 1,
    'gaa' => 1,
    'ttt' => 1,
    'kcg' => 1,
    'cat' => 1,
    'ibo' => 1,
    'tvl' => 1,
    'est' => 1,
    'her' => 1,
    'ndo' => 1,
    'smj' => 1,
    'kua' => 1,
    'myx' => 1,
    'pko' => 1,
    'xog' => 1,
    'jam' => 1,
    'ksb' => 1,
    'jmc' => 1,
    'gag' => 1,
    'bku' => 1,
    'yav' => 1,
    'msa' => 1,
    'ewe' => 1,
    'vie' => 1,
    'mua' => 1,
    'kut' => 1,
    'amo' => 1,
    'osa' => 2,
    'snk' => 1,
    'rof' => 1,
    'tah' => 1,
    'fit' => 1,
    'sag' => 1,
    'gos' => 1,
    'kvr' => 1,
    'osc' => 2,
    'tet' => 1,
    'ton' => 1,
    'tzm' => 1,
    'deu' => 1,
    'byv' => 1,
    'bin' => 1,
    'mlg' => 1,
    'nov' => 2,
    'pon' => 1,
    'hup' => 1,
    'tum' => 1,
    'gla' => 1,
    'swe' => 1,
    'nia' => 1,
    'lzz' => 1,
    'rej' => 1,
    'fij' => 1,
    'lol' => 1,
    'swa' => 1,
    'frs' => 1,
    'frp' => 1,
    'saq' => 1,
    'pap' => 1,
    'mri' => 1,
    'kfo' => 1,
    'vls' => 1,
    'dnj' => 1,
    'aka' => 1,
    'tbw' => 1,
    'iku' => 1,
    'ces' => 1,
    'scs' => 1,
    'bvb' => 1,
    'bas' => 1,
    'bmq' => 1,
    'uli' => 1,
    'sna' => 1,
    'kaj' => 1,
    'pms' => 1,
    'cay' => 1,
    'ilo' => 1,
    'sma' => 1,
    'zun' => 1,
    'vmw' => 1,
    'hin' => 2,
    'sot' => 1,
    'nav' => 1,
    'hnn' => 1,
    'crj' => 2,
    'srp' => 1,
    'dav' => 1,
    'tgk' => 1,
    'enm' => 2,
    'afr' => 1,
    'lam' => 1,
    'mlt' => 1,
    'tiv' => 1,
    'tly' => 1,
    'trv' => 1,
    'sun' => 1,
    'zag' => 1,
    'liv' => 2,
    'tso' => 1,
    'slk' => 1,
    'aze' => 1,
    'srd' => 1,
    'dyo' => 1,
    'smo' => 1,
    'cad' => 1,
    'kpe' => 1,
    'jgo' => 1,
    'crl' => 2,
    'sly' => 1,
    'mdr' => 1,
    'nno' => 1,
    'hif' => 1,
    'khq' => 1,
    'nob' => 1,
    'chy' => 1,
    'frm' => 2,
    'dtm' => 1,
    'slv' => 1,
    'pro' => 2,
    'kab' => 1,
    'sat' => 2,
    'vun' => 1,
    'ett' => 2,
    'grn' => 1,
    'ffm' => 1,
    'gor' => 1,
    'bto' => 1,
    'vic' => 1,
    'lut' => 2
  },
  'Tibt' => {
    'bod' => 1,
    'taj' => 2,
    'tsj' => 1,
    'tdg' => 2,
    'bft' => 2,
    'dzo' => 1
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Yiii' => {
    'iii' => 1
  },
  'Grek' => {
    'ell' => 1,
    'grc' => 2,
    'bgx' => 1,
    'tsd' => 1,
    'pnt' => 1,
    'cop' => 2
  },
  'Phnx' => {
    'phn' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Mlym' => {
    'mal' => 1
  },
  'Modi' => {
    'mar' => 2
  },
  'Vaii' => {
    'vai' => 1
  },
  'Hano' => {
    'hnn' => 2
  },
  'Bopo' => {
    'zho' => 2
  },
  'Limb' => {
    'lif' => 1
  },
  'Ethi' => {
    'tig' => 1,
    'tir' => 1,
    'amh' => 1,
    'orm' => 2,
    'wal' => 1,
    'byn' => 1,
    'gez' => 2
  },
  'Wara' => {
    'hoc' => 2
  },
  'Orya' => {
    'sat' => 2,
    'ori' => 1
  },
  'Mani' => {
    'xmn' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Lepc' => {
    'lep' => 1
  },
  'Shrd' => {
    'san' => 2
  },
  'Egyp' => {
    'egy' => 2
  },
  'Avst' => {
    'ave' => 2
  },
  'Phag' => {
    'zho' => 2,
    'mon' => 2
  },
  'Tirh' => {
    'mai' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Sinh' => {
    'pli' => 2,
    'sin' => 1,
    'san' => 2
  },
  'Mand' => {
    'myz' => 2
  },
  'Bali' => {
    'ban' => 2
  },
  'Narb' => {
    'xna' => 2
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Kana' => {
    'ryu' => 1,
    'ain' => 2
  },
  'Mend' => {
    'men' => 2
  },
  'Mtei' => {
    'mni' => 2
  },
  'Tfng' => {
    'shi' => 1,
    'rif' => 1,
    'zgh' => 1,
    'tzm' => 1,
    'zen' => 2
  },
  'Sylo' => {
    'syl' => 2
  },
  'Sund' => {
    'sun' => 2
  },
  'Copt' => {
    'cop' => 2
  },
  'Gujr' => {
    'guj' => 1
  },
#  'Kore' => {
  'Hang' => {      
    'kor' => 1
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Sind' => {
    'snd' => 2
  },
  'Batk' => {
    'bbc' => 2
  },
  'Beng' => {
    'unx' => 1,
    'sat' => 2,
    'mni' => 1,
    'kha' => 2,
    'syl' => 1,
    'lus' => 1,
    'asm' => 1,
    'ccp' => 1,
    'unr' => 1,
    'ben' => 1,
    'grt' => 1,
    'rkt' => 1,
    'bpy' => 1
  },
  'Phlp' => {
    'pal' => 2
  },
  'Phli' => {
    'pal' => 2
  },
  'Laoo' => {
    'lao' => 1,
    'hmn' => 1,
    'hnj' => 1,
    'kjg' => 1
  },
  'Hani' => {
    'vie' => 2
  },
  'Taml' => {
    'bfq' => 1,
    'tam' => 1
  },
  'Thai' => {
    'kdt' => 1,
    'sou' => 1,
    'tts' => 1,
    'tha' => 1,
    'lcp' => 1,
    'pli' => 2,
    'lwl' => 1,
    'kxm' => 1
  },
  'Cprt' => {
    'grc' => 2
  },
  'Tglg' => {
    'fil' => 2
  },
  'Thaa' => {
    'div' => 1
  },
  'Armi' => {
    'arc' => 2
  },
  'Olck' => {
    'sat' => 1
  },
  'Armn' => {
    'hye' => 1
  },
  'Mroo' => {
    'mro' => 2
  },
  'Knda' => {
    'tcy' => 1,
    'kan' => 1
  },
  'Buhd' => {
    'bku' => 2
  },
  'Linb' => {
    'grc' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Bugi' => {
    'mdr' => 2,
    'mak' => 2,
    'bug' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Java' => {
    'jav' => 2
  },
  'Guru' => {
    'pan' => 1
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Mong' => {
    'mon' => 2,
    'mnc' => 2
  },
  'Sora' => {
    'srb' => 2
  },
  'Sidd' => {
    'san' => 2
  },
  'Hebr' => {
    'sam' => 2,
    'jrb' => 1,
    'lad' => 1,
    'heb' => 1,
    'jpr' => 1,
    'yid' => 1
  },
  'Xsux' => {
    'hit' => 2,
    'akk' => 2
  },
  'Gran' => {
    'san' => 2
  },
  'Ugar' => {
    'uga' => 2
  },
  'Cher' => {
    'chr' => 1
  },
  'Takr' => {
    'doi' => 2
  },
  'Geor' => {
    'lzz' => 1,
    'xmf' => 1,
    'kat' => 1
  },
  'Runr' => {
    'deu' => 2,
    'non' => 2
  },
  'Syrc' => {
    'aii' => 2,
    'syr' => 2,
    'tru' => 2,
    'ara' => 2
  },
  'Cyrl' => {
    'xal' => 1,
    'ude' => 1,
    'aze' => 1,
    'evn' => 1,
    'alt' => 1,
    'kum' => 1,
    'tab' => 1,
    'uig' => 1,
    'rom' => 2,
    'bos' => 1,
    'kom' => 1,
    'rus' => 1,
    'uzb' => 1,
    'tuk' => 1,
    'kir' => 1,
    'kjh' => 1,
    'lez' => 1,
    'bak' => 1,
    'sme' => 2,
    'tyv' => 1,
    'bel' => 1,
    'chm' => 1,
    'tat' => 1,
    'kca' => 1,
    'crh' => 1,
    'ady' => 1,
    'kpy' => 1,
    'nog' => 1,
    'kur' => 1,
    'tgk' => 1,
    'srp' => 1,
    'lbe' => 1,
    'tly' => 1,
    'abq' => 1,
    'ron' => 2,
    'aii' => 1,
    'lfn' => 2,
    'sel' => 2,
    'tkr' => 1,
    'hbs' => 1,
    'bua' => 1,
    'ava' => 1,
    'kaa' => 1,
    'mdf' => 1,
    'gld' => 1,
    'krc' => 1,
    'dar' => 1,
    'ckt' => 1,
    'udm' => 1,
    'kbd' => 1,
    'chv' => 1,
    'mns' => 1,
    'abk' => 1,
    'syr' => 1,
    'oss' => 1,
    'ttt' => 1,
    'ukr' => 1,
    'mrj' => 1,
    'che' => 1,
    'inh' => 1,
    'sah' => 1,
    'myv' => 1,
    'chu' => 2,
    'gag' => 2,
    'yrk' => 1,
    'dng' => 1,
    'kaz' => 1,
    'pnt' => 1,
    'koi' => 1,
    'cjs' => 1,
    'mon' => 1,
    'bul' => 1,
    'mkd' => 1,
    'rue' => 1
  },
  'Lydi' => {
    'xld' => 2
  },
  'Khoj' => {
    'snd' => 2
  },
  'Deva' => {
    'tdh' => 1,
    'mrd' => 1,
    'kru' => 1,
    'brx' => 1,
    'bhb' => 1,
    'snd' => 1,
    'xnr' => 1,
    'gbm' => 1,
    'hif' => 1,
    'raj' => 1,
    'sck' => 1,
    'san' => 2,
    'bhi' => 1,
    'bra' => 1,
    'xsr' => 1,
    'tkt' => 1,
    'bfy' => 1,
    'tdg' => 1,
    'jml' => 1,
    'sat' => 2,
    'unx' => 1,
    'mar' => 1,
    'wtm' => 1,
    'hne' => 1,
    'gvr' => 1,
    'bjj' => 1,
    'pli' => 2,
    'kfy' => 1,
    'btv' => 1,
    'thl' => 1,
    'doi' => 1,
    'kas' => 1,
    'rjs' => 1,
    'hoc' => 1,
    'gom' => 1,
    'kfr' => 1,
    'anp' => 1,
    'noe' => 1,
    'nep' => 1,
    'mgp' => 1,
    'thq' => 1,
    'bho' => 1,
    'kok' => 1,
    'bgc' => 1,
    'hoj' => 1,
    'mag' => 1,
    'taj' => 1,
    'bap' => 1,
    'swv' => 1,
    'unr' => 1,
    'khn' => 1,
    'lif' => 1,
    'mwr' => 1,
    'srx' => 1,
    'wbr' => 1,
    'thr' => 1,
    'dty' => 1,
    'awa' => 1,
    'mai' => 1,
    'new' => 1,
    'hin' => 1,
    'mtr' => 1,
    'gon' => 1
  },
  'Samr' => {
    'sam' => 2,
    'smp' => 2
  },
  'Arab' => {
    'ind' => 2,
    'ary' => 1,
    'aeb' => 1,
    'sdh' => 1,
    'arq' => 1,
    'raj' => 1,
    'som' => 2,
    'pus' => 1,
    'gbz' => 1,
    'hno' => 1,
    'bej' => 1,
    'ars' => 1,
    'lki' => 1,
    'gjk' => 1,
    'fia' => 1,
    'dcc' => 1,
    'arz' => 1,
    'hnd' => 1,
    'rmt' => 1,
    'bgn' => 1,
    'tur' => 2,
    'inh' => 2,
    'zdj' => 1,
    'urd' => 1,
    'ttt' => 2,
    'mfa' => 1,
    'wol' => 2,
    'gju' => 1,
    'skr' => 1,
    'khw' => 1,
    'cja' => 1,
    'kaz' => 1,
    'cop' => 2,
    'bqi' => 1,
    'kvx' => 1,
    'msa' => 1,
    'prd' => 1,
    'uig' => 1,
    'brh' => 1,
    'snd' => 1,
    'fas' => 1,
    'kxp' => 1,
    'haz' => 1,
    'aze' => 1,
    'dyo' => 2,
    'bal' => 1,
    'cjm' => 2,
    'ara' => 1,
    'pan' => 1,
    'bft' => 1,
    'tuk' => 1,
    'kir' => 1,
    'kas' => 1,
    'doi' => 1,
    'lrc' => 1,
    'uzb' => 1,
    'glk' => 1,
    'kur' => 1,
    'ckb' => 1,
    'sus' => 2,
    'mvy' => 1,
    'swb' => 1,
    'lah' => 1,
    'tly' => 1,
    'hau' => 1,
    'shi' => 1,
    'tgk' => 1,
    'luz' => 1,
    'mzn' => 1,
    'wni' => 1
  },
  'Mymr' => {
    'shn' => 1,
    'mya' => 1,
    'kht' => 1,
    'mnw' => 1
  },
  'Cans' => {
    'crm' => 1,
    'crl' => 1,
    'den' => 2,
    'oji' => 1,
    'csw' => 1,
    'cre' => 1,
    'iku' => 1,
    'crk' => 1,
    'nsk' => 1,
    'chp' => 2,
    'crj' => 1
  },
  'Adlm' => {
    'ful' => 2
  },
  'Shaw' => {
    'eng' => 2
  },
  'Prti' => {
    'xpr' => 2
  },
  'Nkoo' => {
    'nqo' => 1,
    'man' => 1,
    'bam' => 1
  },
  'Palm' => {
    'arc' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Osge' => {
    'osa' => 1
  },
  'Cham' => {
    'cja' => 2,
    'cjm' => 1
  },
  'Dupl' => {
    'fra' => 2
  }
};
$DefaultScript = {
  'bhi' => 'Deva',
  'kac' => 'Latn',
  'asa' => 'Latn',
  'luy' => 'Latn',
  'vmf' => 'Latn',
  'kde' => 'Latn',
  'chr' => 'Cher',
  'hrv' => 'Latn',
  'cor' => 'Latn',
  'ria' => 'Latn',
  'kan' => 'Knda',
  'rjs' => 'Deva',
  'dgr' => 'Latn',
  'nnh' => 'Latn',
  'bft' => 'Arab',
  'syl' => 'Beng',
  'bel' => 'Cyrl',
  'tsg' => 'Latn',
  'sme' => 'Latn',
  'cps' => 'Latn',
  'ttj' => 'Latn',
  'tha' => 'Thai',
  'nan' => 'Hans',
  'swb' => 'Arab',
  'bkm' => 'Latn',
  'kau' => 'Latn',
  'gle' => 'Latn',
  'mer' => 'Latn',
  'wae' => 'Latn',
  'rmf' => 'Latn',
  'bze' => 'Latn',
  'khb' => 'Talu',
  'efi' => 'Latn',
  'lav' => 'Latn',
  'mnw' => 'Mymr',
  'dua' => 'Latn',
  'mtr' => 'Deva',
  'dtp' => 'Latn',
  'jrb' => 'Hebr',
  'maf' => 'Latn',
  'fur' => 'Latn',
  'nij' => 'Latn',
  'nym' => 'Latn',
  'kxm' => 'Thai',
  'kri' => 'Latn',
  'sqi' => 'Latn',
  'dsb' => 'Latn',
  'fil' => 'Latn',
  'aym' => 'Latn',
  'grt' => 'Beng',
  'twq' => 'Latn',
  'ind' => 'Latn',
  'bua' => 'Cyrl',
  'raj' => 'Deva',
  'bqv' => 'Latn',
  'sdh' => 'Arab',
  'was' => 'Latn',
  'mdf' => 'Cyrl',
  'cha' => 'Latn',
  'kaa' => 'Cyrl',
  'syi' => 'Latn',
  'lug' => 'Latn',
  'chv' => 'Cyrl',
  'kbd' => 'Cyrl',
  'btv' => 'Deva',
  'rmt' => 'Arab',
  'udm' => 'Cyrl',
  'rar' => 'Latn',
  'del' => 'Latn',
  'rup' => 'Latn',
  'vec' => 'Latn',
  'tsi' => 'Latn',
  'cym' => 'Latn',
  'tcy' => 'Knda',
  'mrj' => 'Cyrl',
  'bik' => 'Latn',
  'tam' => 'Taml',
  'rug' => 'Latn',
  'sah' => 'Cyrl',
  'car' => 'Latn',
  'esu' => 'Latn',
  'rmu' => 'Latn',
  'din' => 'Latn',
  'roh' => 'Latn',
  'dng' => 'Cyrl',
  'kvx' => 'Arab',
  'yao' => 'Latn',
  'pcm' => 'Latn',
  'tsd' => 'Grek',
  'bew' => 'Latn',
  'mwv' => 'Latn',
  'bum' => 'Latn',
  'heb' => 'Hebr',
  'kht' => 'Mymr',
  'nhe' => 'Latn',
  'zha' => 'Latn',
  'nqo' => 'Nkoo',
  'koi' => 'Cyrl',
  'agq' => 'Latn',
  'slk' => 'Latn',
  'srd' => 'Latn',
  'dyo' => 'Latn',
  'kpe' => 'Latn',
  'sly' => 'Latn',
  'mdr' => 'Latn',
  'fas' => 'Arab',
  'ryu' => 'Kana',
  'wbq' => 'Telu',
  'kom' => 'Cyrl',
  'lmn' => 'Telu',
  'slv' => 'Latn',
  'guj' => 'Gujr',
  'hne' => 'Deva',
  'sat' => 'Olck',
  'vun' => 'Latn',
  'sin' => 'Sinh',
  'bto' => 'Latn',
  'chm' => 'Cyrl',
  'hoj' => 'Deva',
  'scs' => 'Latn',
  'lus' => 'Beng',
  'bmq' => 'Latn',
  'sna' => 'Latn',
  'pms' => 'Latn',
  'ilo' => 'Latn',
  'kca' => 'Cyrl',
  'zun' => 'Latn',
  'hin' => 'Deva',
  'hnn' => 'Latn',
  'nav' => 'Latn',
  'trv' => 'Latn',
  'wal' => 'Ethi',
  'sun' => 'Latn',
  'bra' => 'Deva',
  'ton' => 'Latn',
  'deu' => 'Latn',
  'byv' => 'Latn',
  'dzo' => 'Tibt',
  'bej' => 'Arab',
  'bin' => 'Latn',
  'mlg' => 'Latn',
  'tig' => 'Ethi',
  'tum' => 'Latn',
  'dar' => 'Cyrl',
  'swe' => 'Latn',
  'lol' => 'Latn',
  'fij' => 'Latn',
  'swa' => 'Latn',
  'hnj' => 'Laoo',
  'pap' => 'Latn',
  'saq' => 'Latn',
  'mri' => 'Latn',
  'tir' => 'Ethi',
  'mar' => 'Deva',
  'kfo' => 'Latn',
  'arz' => 'Arab',
  'tbw' => 'Latn',
  'wol' => 'Latn',
  'cat' => 'Latn',
  'tvl' => 'Latn',
  'shn' => 'Mymr',
  'est' => 'Latn',
  'myv' => 'Cyrl',
  'ndo' => 'Latn',
  'kua' => 'Latn',
  'myx' => 'Latn',
  'urd' => 'Arab',
  'jam' => 'Latn',
  'xog' => 'Latn',
  'bax' => 'Bamu',
  'ksb' => 'Latn',
  'jmc' => 'Latn',
  'gag' => 'Latn',
  'yav' => 'Latn',
  'vie' => 'Latn',
  'kut' => 'Latn',
  'osa' => 'Osge',
  'snk' => 'Latn',
  'xmf' => 'Geor',
  'tah' => 'Latn',
  'sag' => 'Latn',
  'gos' => 'Latn',
  'mgh' => 'Latn',
  'atj' => 'Latn',
  'puu' => 'Latn',
  'iba' => 'Latn',
  'niu' => 'Latn',
  'ace' => 'Latn',
  'chk' => 'Latn',
  'oji' => 'Cans',
  'hai' => 'Latn',
  'sck' => 'Deva',
  'rcf' => 'Latn',
  'kum' => 'Cyrl',
  'zmi' => 'Latn',
  'fuv' => 'Latn',
  'maz' => 'Latn',
  'bez' => 'Latn',
  'mvy' => 'Arab',
  'nyo' => 'Latn',
  'wbp' => 'Latn',
  'ckb' => 'Arab',
  'lcp' => 'Thai',
  'lij' => 'Latn',
  'ven' => 'Latn',
  'crh' => 'Cyrl',
  'thq' => 'Deva',
  'abr' => 'Latn',
  'jpn' => 'Jpan',
  'que' => 'Latn',
  'suk' => 'Latn',
  'lbw' => 'Latn',
  'ceb' => 'Latn',
  'gsw' => 'Latn',
  'gan' => 'Hans',
  'ben' => 'Beng',
  'akz' => 'Latn',
  'abq' => 'Cyrl',
  'bis' => 'Latn',
  'tog' => 'Latn',
  'kmb' => 'Latn',
  'pus' => 'Arab',
  'som' => 'Latn',
  'lit' => 'Latn',
  'mro' => 'Latn',
  'eka' => 'Latn',
  'mwk' => 'Latn',
  'bzx' => 'Latn',
  'fan' => 'Latn',
  'kao' => 'Latn',
  'bjn' => 'Latn',
  'lmo' => 'Latn',
  'dcc' => 'Arab',
  'ach' => 'Latn',
  'fvr' => 'Latn',
  'bgx' => 'Grek',
  'cic' => 'Latn',
  'mfe' => 'Latn',
  'hnd' => 'Arab',
  'hmd' => 'Plrd',
  'fud' => 'Latn',
  'mfa' => 'Arab',
  'fin' => 'Latn',
  'dak' => 'Latn',
  'por' => 'Latn',
  'nmg' => 'Latn',
  'taj' => 'Deva',
  'cos' => 'Latn',
  'che' => 'Cyrl',
  'bho' => 'Deva',
  'run' => 'Latn',
  'crs' => 'Latn',
  'bqi' => 'Arab',
  'khw' => 'Arab',
  'guz' => 'Latn',
  'frc' => 'Latn',
  'fon' => 'Latn',
  'byn' => 'Ethi',
  'rgn' => 'Latn',
  'pdt' => 'Latn',
  'bfy' => 'Deva',
  'nsk' => 'Cans',
  'haw' => 'Latn',
  'bod' => 'Tibt',
  'rkt' => 'Beng',
  'ara' => 'Arab',
  'dan' => 'Latn',
  'sli' => 'Latn',
  'ssy' => 'Latn',
  'aar' => 'Latn',
  'ita' => 'Latn',
  'stq' => 'Latn',
  'kru' => 'Deva',
  'kjg' => 'Laoo',
  'alt' => 'Cyrl',
  'bar' => 'Latn',
  'gwi' => 'Latn',
  'rom' => 'Latn',
  'kjh' => 'Cyrl',
  'pol' => 'Latn',
  'kfy' => 'Deva',
  'yrl' => 'Latn',
  'nzi' => 'Latn',
  'bap' => 'Deva',
  'kik' => 'Latn',
  'kha' => 'Latn',
  'naq' => 'Latn',
  'pag' => 'Latn',
  'nog' => 'Cyrl',
  'tat' => 'Cyrl',
  'isl' => 'Latn',
  'hop' => 'Latn',
  'mah' => 'Latn',
  'bug' => 'Latn',
  'ksh' => 'Latn',
  'wni' => 'Arab',
  'sco' => 'Latn',
  'ljp' => 'Latn',
  'yor' => 'Latn',
  'luz' => 'Arab',
  'egl' => 'Latn',
  'krl' => 'Latn',
  'zza' => 'Latn',
  'saf' => 'Latn',
  'nhw' => 'Latn',
  'gjk' => 'Arab',
  'sgs' => 'Latn',
  'rmo' => 'Latn',
  'mni' => 'Beng',
  'mos' => 'Latn',
  'oci' => 'Latn',
  'nde' => 'Latn',
  'aeb' => 'Arab',
  'teo' => 'Latn',
  'hsn' => 'Hans',
  'gld' => 'Cyrl',
  'seh' => 'Latn',
  'lao' => 'Laoo',
  'bem' => 'Latn',
  'kgp' => 'Latn',
  'bgn' => 'Arab',
  'kam' => 'Latn',
  'bci' => 'Latn',
  'srn' => 'Latn',
  'abk' => 'Cyrl',
  'lub' => 'Latn',
  'smn' => 'Latn',
  'moh' => 'Latn',
  'bre' => 'Latn',
  'epo' => 'Latn',
  'blt' => 'Tavt',
  'kea' => 'Latn',
  'nep' => 'Deva',
  'bss' => 'Latn',
  'xho' => 'Latn',
  'mwl' => 'Latn',
  'mon' => 'Cyrl',
  'mak' => 'Latn',
  'ikt' => 'Latn',
  'lis' => 'Lisu',
  'gcr' => 'Latn',
  'evn' => 'Cyrl',
  'ctd' => 'Latn',
  'mxc' => 'Latn',
  'brx' => 'Deva',
  'mya' => 'Mymr',
  'tab' => 'Cyrl',
  'zul' => 'Latn',
  'orm' => 'Latn',
  'vep' => 'Latn',
  'glk' => 'Arab',
  'fry' => 'Latn',
  'lez' => 'Cyrl',
  'arg' => 'Latn',
  'nau' => 'Latn',
  'ada' => 'Latn',
  'hmn' => 'Latn',
  'krj' => 'Latn',
  'sid' => 'Latn',
  'bak' => 'Cyrl',
  'izh' => 'Latn',
  'den' => 'Latn',
  'tli' => 'Latn',
  'kpy' => 'Cyrl',
  'mgp' => 'Deva',
  'hak' => 'Hans',
  'ife' => 'Latn',
  'lwl' => 'Thai',
  'mgy' => 'Latn',
  'lag' => 'Latn',
  'mdt' => 'Latn',
  'asm' => 'Beng',
  'srr' => 'Latn',
  'bbj' => 'Latn',
  'lua' => 'Latn',
  'szl' => 'Latn',
  'mus' => 'Latn',
  'hmo' => 'Latn',
  'ibb' => 'Latn',
  'hno' => 'Arab',
  'arp' => 'Latn',
  'aii' => 'Cyrl',
  'njo' => 'Latn',
  'ars' => 'Arab',
  'nxq' => 'Latn',
  'lki' => 'Arab',
  'kon' => 'Latn',
  'lep' => 'Lepc',
  'tru' => 'Latn',
  'tsj' => 'Tibt',
  'nus' => 'Latn',
  'nyn' => 'Latn',
  'kal' => 'Latn',
  'gay' => 'Latn',
  'iii' => 'Yiii',
  'ban' => 'Latn',
  'tur' => 'Latn',
  'eng' => 'Latn',
  'gvr' => 'Deva',
  'wls' => 'Latn',
  'thl' => 'Deva',
  'quc' => 'Latn',
  'sas' => 'Latn',
  'ckt' => 'Cyrl',
  'gju' => 'Arab',
  'mwr' => 'Deva',
  'min' => 'Latn',
  'cgg' => 'Latn',
  'kfr' => 'Deva',
  'anp' => 'Deva',
  'aln' => 'Latn',
  'rng' => 'Latn',
  'kos' => 'Latn',
  'pcd' => 'Latn',
  'mdh' => 'Latn',
  'guc' => 'Latn',
  'prd' => 'Arab',
  'pam' => 'Latn',
  'thr' => 'Deva',
  'skr' => 'Arab',
  'glv' => 'Latn',
  'nap' => 'Latn',
  'fao' => 'Latn',
  'cja' => 'Arab',
  'zag' => 'Latn',
  'tso' => 'Latn',
  'haz' => 'Arab',
  'smo' => 'Latn',
  'ude' => 'Cyrl',
  'tdg' => 'Deva',
  'cad' => 'Latn',
  'crl' => 'Cans',
  'jgo' => 'Latn',
  'nno' => 'Latn',
  'kxp' => 'Arab',
  'nob' => 'Latn',
  'chy' => 'Latn',
  'khq' => 'Latn',
  'rus' => 'Cyrl',
  'dtm' => 'Latn',
  'csw' => 'Cans',
  'kab' => 'Latn',
  'grn' => 'Latn',
  'ffm' => 'Latn',
  'gor' => 'Latn',
  'bjj' => 'Deva',
  'vic' => 'Latn',
  'ces' => 'Latn',
  'zgh' => 'Tfng',
  'bvb' => 'Latn',
  'bas' => 'Latn',
  'uli' => 'Latn',
  'div' => 'Thaa',
  'kaj' => 'Latn',
  'bfq' => 'Taml',
  'tdd' => 'Tale',
  'cay' => 'Latn',
  'ady' => 'Cyrl',
  'sma' => 'Latn',
  'eky' => 'Kali',
  'vmw' => 'Latn',
  'sot' => 'Latn',
  'crj' => 'Cans',
  'dav' => 'Latn',
  'sou' => 'Thai',
  'afr' => 'Latn',
  'lam' => 'Latn',
  'mlt' => 'Latn',
  'ell' => 'Grek',
  'tiv' => 'Latn',
  'kvr' => 'Latn',
  'tet' => 'Latn',
  'tts' => 'Thai',
  'ori' => 'Orya',
  'pon' => 'Latn',
  'hup' => 'Latn',
  'gla' => 'Latn',
  'nia' => 'Latn',
  'rej' => 'Latn',
  'frs' => 'Latn',
  'frp' => 'Latn',
  'crm' => 'Cans',
  'vls' => 'Latn',
  'dnj' => 'Latn',
  'aka' => 'Latn',
  'swg' => 'Latn',
  'bgc' => 'Deva',
  'gaa' => 'Latn',
  'kcg' => 'Latn',
  'ukr' => 'Cyrl',
  'ibo' => 'Latn',
  'her' => 'Latn',
  'smj' => 'Latn',
  'pko' => 'Latn',
  'new' => 'Deva',
  'tel' => 'Telu',
  'mai' => 'Deva',
  'jpr' => 'Hebr',
  'bku' => 'Latn',
  'ewe' => 'Latn',
  'mua' => 'Latn',
  'amo' => 'Latn',
  'rof' => 'Latn',
  'bul' => 'Cyrl',
  'fit' => 'Latn',
  'cjs' => 'Cyrl',
  'tkt' => 'Deva',
  'rap' => 'Latn',
  'bla' => 'Latn',
  'bal' => 'Arab',
  'rob' => 'Latn',
  'xal' => 'Cyrl',
  'pfl' => 'Latn',
  'sbp' => 'Latn',
  'gbm' => 'Deva',
  'brh' => 'Arab',
  'ndc' => 'Latn',
  'lrc' => 'Arab',
  'doi' => 'Arab',
  'gur' => 'Latn',
  'grb' => 'Latn',
  'wln' => 'Latn',
  'jav' => 'Latn',
  'rwk' => 'Latn',
  'mal' => 'Mlym',
  'nld' => 'Latn',
  'hil' => 'Latn',
  'bbc' => 'Latn',
  'kyu' => 'Kali',
  'wuu' => 'Hans',
  'mas' => 'Latn',
  'moe' => 'Latn',
  'war' => 'Latn',
  'noe' => 'Deva',
  'ewo' => 'Latn',
  'pdc' => 'Latn',
  'sus' => 'Latn',
  'saz' => 'Saur',
  'ssw' => 'Latn',
  'kat' => 'Geor',
  'mad' => 'Latn',
  'fra' => 'Latn',
  'mzn' => 'Arab',
  'lah' => 'Arab',
  'hsb' => 'Latn',
  'srx' => 'Deva',
  'mls' => 'Latn',
  'yua' => 'Latn',
  'eus' => 'Latn',
  'gba' => 'Latn',
  'pau' => 'Latn',
  'ext' => 'Latn',
  'arq' => 'Arab',
  'zea' => 'Latn',
  'glg' => 'Latn',
  'kiu' => 'Latn',
  'krc' => 'Cyrl',
  'cch' => 'Latn',
  'tmh' => 'Latn',
  'men' => 'Latn',
  'ltz' => 'Latn',
  'fia' => 'Arab',
  'dyu' => 'Latn',
  'mgo' => 'Latn',
  'nch' => 'Latn',
  'kok' => 'Deva',
  'oss' => 'Cyrl',
  'khn' => 'Deva',
  'sms' => 'Latn',
  'sef' => 'Latn',
  'lad' => 'Hebr',
  'inh' => 'Cyrl',
  'xav' => 'Latn',
  'aoz' => 'Latn',
  'loz' => 'Latn',
  'yrk' => 'Cyrl',
  'gil' => 'Latn',
  'laj' => 'Latn',
  'mkd' => 'Cyrl',
  'rue' => 'Cyrl',
  'kck' => 'Latn',
  'dje' => 'Latn',
  'tem' => 'Latn',
  'kln' => 'Latn',
  'xsr' => 'Deva',
  'rtm' => 'Latn',
  'cjm' => 'Cham',
  'cho' => 'Latn',
  'chp' => 'Latn',
  'sei' => 'Latn',
  'sdc' => 'Latn',
  'frr' => 'Latn',
  'bhb' => 'Deva',
  'srb' => 'Latn',
  'yap' => 'Latn',
  'nod' => 'Lana',
  'mic' => 'Latn',
  'kge' => 'Latn',
  'hoc' => 'Deva',
  'ltg' => 'Latn',
  'hye' => 'Armn',
  'lim' => 'Latn',
  'fuq' => 'Latn',
  'kin' => 'Latn',
  'tsn' => 'Latn',
  'amh' => 'Ethi',
  'tyv' => 'Cyrl',
  'swv' => 'Deva',
  'mag' => 'Deva',
  'qug' => 'Latn',
  'nso' => 'Latn',
  'ksf' => 'Latn',
  'arn' => 'Latn',
  'awa' => 'Deva',
#  'kor' => 'Kore',
  'kor' => 'Hang',    
  'hat' => 'Latn',
  'hun' => 'Latn',
  'ful' => 'Latn',
  'sxn' => 'Latn',
  'ipk' => 'Latn',
  'lin' => 'Latn',
  'ale' => 'Latn',
  'tpi' => 'Latn',
  'ses' => 'Latn',
  'tkl' => 'Latn',
  'sad' => 'Latn',
  'lbe' => 'Cyrl',
  'vro' => 'Latn',
  'crk' => 'Cans',
  'ter' => 'Latn',
  'ebu' => 'Latn',
  'gbz' => 'Arab',
  'spa' => 'Latn',
  'nya' => 'Latn',
  'jml' => 'Deva',
  'ybb' => 'Latn',
  'ron' => 'Latn',
  'ary' => 'Arab',
  'khm' => 'Khmr',
  'mrd' => 'Deva',
  'ava' => 'Cyrl',
  'tdh' => 'Deva',
  'scn' => 'Latn',
  'xnr' => 'Deva',
  'gom' => 'Deva',
  'lun' => 'Latn',
  'nbl' => 'Latn',
  'umb' => 'Latn',
  'wtm' => 'Deva',
  'lkt' => 'Latn',
  'zap' => 'Latn',
  'mns' => 'Cyrl',
  'kdt' => 'Thai',
  'bpy' => 'Beng',
  'ast' => 'Latn',
  'aro' => 'Latn',
  'zdj' => 'Arab',
  'bfd' => 'Latn',
  'buc' => 'Latn',
  'nds' => 'Latn',
  'ngl' => 'Latn',
  'gub' => 'Latn',
  'yid' => 'Hebr',
  'wbr' => 'Deva',
  'luo' => 'Latn',
  'kkj' => 'Latn',
  'see' => 'Latn',
  'dty' => 'Deva'
};
$DefaultTerritory = {
  'est' => 'EE',
  'shn' => 'MM',
  'tvl' => 'TV',
  'sv' => 'SE',
  'bam_Nkoo' => 'ML',
  'cat' => 'ES',
  'wol' => 'SN',
  'jam' => 'JM',
  'xog' => 'UG',
  'kua' => 'NA',
  'myx' => 'UG',
  'urd' => 'PK',
  'myv' => 'RU',
  'ndo' => 'NA',
  'vie' => 'VN',
  'jmc' => 'TZ',
  'yav' => 'CM',
  'ksb' => 'TZ',
  'ro' => 'RO',
  'tah' => 'PF',
  'sag' => 'CF',
  'hin_Latn' => 'IN',
  'shi_Latn' => 'MA',
  'osa' => 'US',
  'snk' => 'ML',
  'zho_Hans' => 'CN',
  'dzo' => 'BT',
  'bej' => 'SD',
  'nl' => 'NL',
  'bin' => 'NG',
  'tnr' => 'SN',
  'deu' => 'DE',
  'es' => 'ES',
  'is' => 'IS',
  'ton' => 'TO',
  'gu' => 'IN',
  'ko' => 'KR',
  'az_Latn' => 'AZ',
  'tum' => 'MW',
  'tig' => 'ER',
  'mlg' => 'MG',
  'gl' => 'ES',
  'saq' => 'KE',
  'swa' => 'TZ',
  'te' => 'IN',
  'swe' => 'SE',
  'fij' => 'FJ',
  'da' => 'DK',
  'arz' => 'EG',
  'ur' => 'PK',
  'mri' => 'NZ',
  'tir' => 'ET',
  'mar' => 'IN',
  'unr' => 'IN',
  'pl' => 'PL',
  'ful_Latn' => 'SN',
  'sna' => 'ZW',
  'iku' => 'CA',
  'hoj' => 'IN',
  'ilo' => 'PH',
  'knf' => 'SN',
  'ne' => 'NP',
  'zu' => 'ZA',
  'tn' => 'ZA',
  'hin' => 'IN',
  'mn' => 'MN',
  'sun' => 'ID',
  'wal' => 'ET',
  'trv' => 'TW',
  'kpe' => 'LR',
  'nr' => 'ZA',
  'slk' => 'SK',
  'srd' => 'IT',
  'dyo' => 'SN',
  'sat_Deva' => 'IN',
  'fas' => 'IR',
  'bsc' => 'SN',
  'slv' => 'SI',
  'guj' => 'IN',
  'kom' => 'RU',
  'lmn' => 'IN',
  'wbq' => 'IN',
  'sat' => 'IN',
  'vun' => 'TZ',
  'sin' => 'LK',
  'hne' => 'IN',
  'bik' => 'PH',
  'tam' => 'IN',
  'tr' => 'TR',
  'tk' => 'TM',
  'tcy' => 'IN',
  'cym' => 'GB',
  'roh' => 'CH',
  'af' => 'ZA',
  'ca' => 'ES',
  'sah' => 'RU',
  'bum' => 'CM',
  'bew' => 'ID',
  'pcm' => 'NG',
  'nqo' => 'GN',
  'koi' => 'RU',
  'agq' => 'CM',
  'sd_Arab' => 'PK',
  'zha' => 'CN',
  'heb' => 'IL',
  'ks_Deva' => 'IN',
  'bm_Nkoo' => 'ML',
  'twq' => 'NE',
  'aym' => 'BO',
  'dsb' => 'DE',
  'bam' => 'ML',
  'fil' => 'PH',
  'sdh' => 'IR',
  'raj' => 'IN',
  'ind' => 'ID',
  'lat' => 'VA',
  'cha' => 'GU',
  'mdf' => 'RU',
  'pa_Arab' => 'PK',
  'udm' => 'RU',
  'lug' => 'UG',
  'kbd' => 'RU',
  'chv' => 'RU',
  'rmt' => 'IR',
  'gle' => 'IE',
  'tha' => 'TH',
  'swb' => 'YT',
  'nan' => 'CN',
  'nd' => 'ZW',
  'sme' => 'NO',
  'wa' => 'BE',
  'bel' => 'BY',
  'tsg' => 'PH',
  'wae' => 'CH',
  'kur' => 'TR',
  'mer' => 'KE',
  'tt' => 'RU',
  'ta' => 'IN',
  'shi' => 'MA',
  'mtr' => 'IN',
  'lav' => 'LV',
  'efi' => 'NG',
  'dua' => 'CM',
  'kri' => 'SL',
  'sqi' => 'AL',
  'hi' => 'IN',
  'nym' => 'TZ',
  'kxm' => 'TH',
  'fur' => 'IT',
  'uz_Arab' => 'AF',
  'aa' => 'ET',
  'kde' => 'TZ',
  'chr' => 'US',
  'asa' => 'TZ',
  'luy' => 'KE',
  'vmf' => 'DE',
  'bhi' => 'IN',
  'cor' => 'GB',
  'hrv' => 'HR',
  'kan' => 'IN',
  'mg' => 'MG',
  'bhk' => 'PH',
  'sat_Olck' => 'IN',
  'syl' => 'BD',
  'iu_Latn' => 'CA',
  'ful_Adlm' => 'GN',
  'ha_Arab' => 'NG',
  'nnh' => 'CM',
  'blt' => 'VN',
  'moh' => 'CA',
  'snd_Deva' => 'IN',
  'jv' => 'ID',
  'bre' => 'FR',
  'ii' => 'CN',
  'nep' => 'NP',
  'kea' => 'CV',
  'aze_Cyrl' => 'AZ',
  'xho' => 'ZA',
  'bos_Cyrl' => 'BA',
  'bss' => 'CM',
  'th' => 'TH',
  'su_Latn' => 'ID',
  'uzb_Cyrl' => 'UZ',
  'so' => 'SO',
  'mak' => 'ID',
  'ikt' => 'CA',
  'et' => 'EE',
  'mon' => 'MN',
  'ku' => 'TR',
  'os' => 'GE',
  'nde' => 'ZW',
  'teo' => 'UG',
  'aeb' => 'TN',
  'mos' => 'BF',
  'oci' => 'FR',
  'sr_Latn' => 'RS',
  'mni' => 'IN',
  'cs' => 'CZ',
  'bci' => 'CI',
  'bem' => 'ZM',
  'kam' => 'KE',
  'bgn' => 'PK',
  'lao' => 'LA',
  'seh' => 'MZ',
  'mey' => 'SN',
  'hsn' => 'CN',
  'smn' => 'FI',
  'tg' => 'TJ',
  'aze_Latn' => 'AZ',
  'lub' => 'CD',
  'gd' => 'GB',
  'srn' => 'SR',
  'abk' => 'GE',
  'sg' => 'CF',
  'ce' => 'RU',
  'nn' => 'NO',
  'ff_Adlm' => 'GN',
  'en' => 'US',
  'tat' => 'RU',
  'isl' => 'IS',
  'kha' => 'IN',
  'kik' => 'KE',
  'naq' => 'NA',
  'ig' => 'NG',
  'pag' => 'PH',
  'luz' => 'IR',
  'wni' => 'KM',
  'ljp' => 'ID',
  'ksh' => 'DE',
  'sco' => 'GB',
  'yor' => 'NG',
  'ts' => 'ZA',
  'bug' => 'ID',
  'mah' => 'MH',
  'rw' => 'RW',
  'zza' => 'TR',
  'dan' => 'DK',
  'bod' => 'CN',
  'rif' => 'MA',
  'haw' => 'US',
  'ita' => 'IT',
  'kru' => 'IN',
  'aar' => 'ET',
  'ssy' => 'ER',
  'mfv' => 'SN',
  'bos' => 'BA',
  'kfy' => 'IN',
  'pol' => 'PL',
  'cv' => 'RU',
  'ka' => 'GE',
  'kir' => 'KG',
  'mk' => 'MK',
  'nmg' => 'CM',
  'vai_Vaii' => 'LR',
  'por' => 'BR',
  'as' => 'IN',
  'fin' => 'FI',
  'mfa' => 'TH',
  'fud' => 'WF',
  'run' => 'BI',
  'cos' => 'FR',
  'che' => 'RU',
  've' => 'ZA',
  'crs' => 'SC',
  'my' => 'MM',
  'bqi' => 'IR',
  'byn' => 'ER',
  'fon' => 'BJ',
  'ks_Arab' => 'IN',
  'guz' => 'KE',
  'br' => 'FR',
  'ben' => 'BD',
  'pa_Guru' => 'IN',
  'sun_Latn' => 'ID',
  'bis' => 'VU',
  'ak' => 'GH',
  'qu' => 'PE',
  'lit' => 'LT',
  'kmb' => 'AO',
  'som' => 'SO',
  'pus' => 'AF',
  'bjn' => 'ID',
  'fan' => 'GQ',
  'ki' => 'KE',
  'cic' => 'US',
  'mfe' => 'MU',
  'lu' => 'CD',
  'fvr' => 'SD',
  'dcc' => 'IN',
  'ach' => 'UG',
  'syr' => 'IQ',
  'wbp' => 'AU',
  'bez' => 'TZ',
  'abr' => 'GH',
  'zh_Hant' => 'TW',
  'gn' => 'PY',
  'jpn' => 'JP',
  'ven' => 'ZA',
  'ckb' => 'IQ',
  'vai_Latn' => 'LR',
  'bn' => 'BD',
  'cu' => 'RU',
  'rm' => 'CH',
  'que' => 'PE',
  'suk' => 'TZ',
  'gan' => 'CN',
  'gsw' => 'CH',
  'srp_Cyrl' => 'RS',
  'ceb' => 'PH',
  'niu' => 'NU',
  'iku_Latn' => 'CA',
  'ace' => 'ID',
  'mgh' => 'MZ',
  'eu' => 'ES',
  'kum' => 'RU',
  'he' => 'IL',
  'sck' => 'IN',
  'sq' => 'AL',
  'rcf' => 'RE',
  'sc' => 'IT',
  'lt' => 'LT',
  'be' => 'BY',
  'chk' => 'FM',
  'bg' => 'BG',
  'fuv' => 'NG',
  'ibo' => 'NG',
  'ukr' => 'UA',
  'kcg' => 'NG',
  'gaa' => 'GH',
  'bgc' => 'IN',
  'smj' => 'SE',
  'mua' => 'CM',
  'sk' => 'SK',
  'ewe' => 'GH',
  'msa' => 'MY',
  'tel' => 'IN',
  'mai' => 'IN',
  'bul' => 'BG',
  'rof' => 'TZ',
  'dv' => 'MV',
  'sa' => 'IN',
  'tzm' => 'MA',
  'tts' => 'TH',
  'kas_Arab' => 'IN',
  'tet' => 'TL',
  'bs_Cyrl' => 'BA',
  'gla' => 'GB',
  'pon' => 'FM',
  'snd_Arab' => 'PK',
  'ori' => 'IN',
  'sd_Deva' => 'IN',
  'rej' => 'ID',
  'vls' => 'BE',
  'dnj' => 'CI',
  'aka' => 'GH',
  'om' => 'ET',
  'ln' => 'CD',
  'bm' => 'ML',
  'kaj' => 'NG',
  'or' => 'IN',
  'div' => 'MV',
  'bas' => 'CM',
  'ces' => 'CZ',
  'zgh' => 'MA',
  'srp_Latn' => 'RS',
  'sma' => 'SE',
  'ady' => 'RU',
  'sou' => 'TH',
  'afr' => 'ZA',
  'tgk' => 'TJ',
  'dav' => 'KE',
  'sot' => 'ZA',
  'wo' => 'SN',
  'vmw' => 'MZ',
  'cy' => 'GB',
  'bs_Latn' => 'BA',
  'ss' => 'ZA',
  'mlt' => 'MT',
  'ell' => 'GR',
  'tiv' => 'NG',
  'cad' => 'US',
  'az_Cyrl' => 'AZ',
  'haz' => 'AF',
  'bjt' => 'SN',
  'tso' => 'ZA',
  'nob' => 'NO',
  'khq' => 'ML',
  'nno' => 'NO',
  'hif' => 'FJ',
  'msa_Arab' => 'MY',
  'ny' => 'MW',
  'ha' => 'NG',
  'jgo' => 'CM',
  'el' => 'GR',
  'kas' => 'IN',
  'rus' => 'RU',
  'yo' => 'NG',
  'bjj' => 'IN',
  'km' => 'KH',
  'ffm' => 'ML',
  'gor' => 'ID',
  'kab' => 'DZ',
  'uk' => 'UA',
  'grn' => 'PY',
  'min' => 'ID',
  'cgg' => 'UG',
  'mwr' => 'IN',
  'yue_Hans' => 'CN',
  'hr' => 'HR',
  'en_Dsrt' => 'US',
  'mt' => 'MT',
  'aln' => 'XK',
  'pam' => 'PH',
  'ps' => 'AF',
  'uz_Cyrl' => 'UZ',
  'mdh' => 'PH',
  'kaz' => 'KZ',
  'fao' => 'FO',
  'skr' => 'PK',
  'glv' => 'IM',
  'lv' => 'LV',
  'pt' => 'BR',
  'ee' => 'GH',
  'ml' => 'IN',
  'hmo' => 'PG',
  'ibb' => 'NG',
  'hno' => 'PK',
  'xh' => 'ZA',
  'mn_Mong' => 'CN',
  'kon' => 'CD',
  'sw' => 'TZ',
  'shi_Tfng' => 'MA',
  'am' => 'ET',
  'eng' => 'US',
  'kal' => 'GL',
  'iii' => 'CN',
  'tur' => 'TR',
  'ban' => 'ID',
  'nyn' => 'UG',
  'uzb_Arab' => 'AF',
  'nus' => 'SS',
  'sas' => 'ID',
  'kl' => 'GL',
  'quc' => 'GT',
  'ms_Arab' => 'MY',
  'uz_Latn' => 'UZ',
  'wls' => 'WF',
  'sid' => 'ET',
  'bak' => 'RU',
  'ff_Latn' => 'SN',
  'hak' => 'CN',
  'kas_Deva' => 'IN',
  'ife' => 'TG',
  'fo' => 'FO',
  'srr' => 'SN',
  'gon' => 'IN',
  'gez' => 'ET',
  'nb' => 'NO',
  'asm' => 'IN',
  'ru' => 'RU',
  'kk' => 'KZ',
  'ja' => 'JP',
  'lag' => 'TZ',
  'szl' => 'PL',
  'mus' => 'US',
  'lua' => 'CD',
  'san' => 'IN',
  'fa' => 'IR',
  'gcr' => 'GF',
  'zul' => 'ZA',
  'mya' => 'MM',
  'brx' => 'IN',
  'kn' => 'IN',
  'glk' => 'IR',
  'fry' => 'NL',
  'vi' => 'VN',
  'hy' => 'AM',
  'orm' => 'ET',
  'mon_Mong' => 'CN',
  'arg' => 'ES',
  'nau' => 'NR',
  'lez' => 'RU',
  'ast' => 'ES',
  'buc' => 'YT',
  'zdj' => 'KM',
  'eng_Dsrt' => 'US',
  'iu' => 'CA',
  'ngl' => 'MZ',
  'nds' => 'DE',
  'kkj' => 'CM',
  'aze_Arab' => 'IR',
  'ga' => 'IE',
  'wbr' => 'IN',
  'luo' => 'KE',
  'ron' => 'RO',
  'nya' => 'MW',
  'spa' => 'ES',
  'ebu' => 'KE',
  'oc' => 'FR',
  'scn' => 'IT',
  'xnr' => 'IN',
  'ava' => 'RU',
  'ary' => 'MA',
  'ms' => 'MY',
  'khm' => 'KH',
  'lg' => 'UG',
  'nbl' => 'ZA',
  'umb' => 'AO',
  'it' => 'IT',
  'gom' => 'IN',
  'de' => 'DE',
  'wtm' => 'IN',
  'lkt' => 'US',
  'ug' => 'CN',
  'swv' => 'IN',
  'ccp' => 'BD',
  'mag' => 'IN',
  'id' => 'ID',
  'st' => 'ZA',
  'tyv' => 'RU',
  'amh' => 'ET',
  'lo' => 'LA',
  'co' => 'FR',
  'nso' => 'ZA',
  'mni_Mtei' => 'IN',
  'pan_Arab' => 'PK',
  'ba' => 'RU',
  'hat' => 'HT',
  'hun' => 'HU',
  'kor' => 'KR',
  'pan_Guru' => 'IN',
  'arn' => 'CL',
  'ksf' => 'CM',
  'mni_Beng' => 'IN',
  'awa' => 'IN',
  'az_Arab' => 'IR',
  'fy' => 'NL',
  'lbe' => 'RU',
  'an' => 'ES',
  'tkl' => 'TK',
  'tpi' => 'PG',
  'mr' => 'IN',
  'ses' => 'ML',
  'lin' => 'CD',
  'hau' => 'NG',
  'kln' => 'KE',
  'csb' => 'PL',
  'nod' => 'TH',
  'fr' => 'FR',
  'bhb' => 'IN',
  'hye' => 'AM',
  'se' => 'NO',
  'hoc' => 'IN',
  'tsn' => 'ZA',
  'kin' => 'RW',
  'fuq' => 'NE',
  'ti' => 'ET',
  'sef' => 'CI',
  'sms' => 'FI',
  'oss' => 'GE',
  'khn' => 'IN',
  'mi' => 'NZ',
  'kok' => 'IN',
  'mgo' => 'CM',
  'to' => 'TO',
  'hu' => 'HU',
  'inh' => 'RU',
  'zh_Hans' => 'CN',
  'chu' => 'RU',
  'gil' => 'KI',
  'tem' => 'SL',
  'laj' => 'UG',
  'mkd' => 'MK',
  'dje' => 'NE',
  'si' => 'LK',
  'pau' => 'PW',
  'uzb_Latn' => 'UZ',
  'gv' => 'IM',
  'eus' => 'ES',
  'glg' => 'ES',
  'arq' => 'DZ',
  'sav' => 'SN',
  'zho_Hant' => 'TW',
  'tmh' => 'NE',
  'krc' => 'RU',
  'cch' => 'NG',
  'dyu' => 'BF',
  'fi' => 'FI',
  'lb' => 'LU',
  'ltz' => 'LU',
  'hau_Arab' => 'NG',
  'men' => 'SL',
  'war' => 'PH',
  'mas' => 'KE',
  'hi_Latn' => 'IN',
  'sl' => 'SI',
  'kw' => 'GB',
  'wuu' => 'CN',
  'sus' => 'GN',
  'ky' => 'KG',
  'ewo' => 'CM',
  'noe' => 'IN',
  'fra' => 'FR',
  'mzn' => 'IR',
  'kat' => 'GE',
  'mad' => 'ID',
  'rn' => 'BI',
  'ssw' => 'ZA',
  'bo' => 'CN',
  'hsb' => 'DE',
  'lah' => 'PK',
  'sn' => 'ZW',
  'dz' => 'BT',
  'yue_Hant' => 'HK',
  'brh' => 'PK',
  'ndc' => 'MZ',
  'gbm' => 'IN',
  'snf' => 'SN',
  'sbp' => 'TZ',
  'uig' => 'CN',
  'doi' => 'IN',
  'lrc' => 'IR',
  'mal' => 'IN',
  'bbc' => 'ID',
  'nld' => 'NL',
  'hil' => 'PH',
  'sr_Cyrl' => 'RS',
  'rwk' => 'TZ',
  'tuk' => 'TM',
  'jav' => 'ID',
  'bos_Latn' => 'BA',
  'wln' => 'BE',
  'ken' => 'CM'
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
	    warn "Something went wrong! [$@]\n";
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


