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
  'Cham' => 'Cham',
  'Bugi' => 'Buginese',
  'Lina' => 'Linear_A',
  'Laoo' => 'Lao',
  'Ethi' => 'Ethiopic',
  'Visp' => '',
  'Bamu' => 'Bamum',
  'Mahj' => 'Mahajani',
  'Kali' => 'Kayah_Li',
  'Kpel' => '',
  'Linb' => 'Linear_B',
  'Lydi' => 'Lydian',
  'Phlv' => '',
  'Zsym' => '',
  'Cyrs' => '',
  'Jamo' => '',
  'Mymr' => 'Myanmar',
  'Wara' => 'Warang_Citi',
  'Runr' => 'Runic',
  'Mong' => 'Mongolian',
  'Plrd' => 'Miao',
  'Sora' => 'Sora_Sompeng',
  'Hano' => 'Hanunoo',
  'Cyrl' => 'Cyrillic',
  'Geor' => 'Georgian',
  'Latn' => 'Latin',
  'Cher' => 'Cherokee',
  'Gong' => 'Gunjala_Gondi',
  'Nand' => 'Nandinagari',
  'Hanb' => '',
  'Rjng' => 'Rejang',
  'Zzzz' => 'Unknown',
  'Prti' => 'Inscriptional_Parthian',
  'Cpmn' => '',
  'Ogam' => 'Ogham',
  'Ital' => 'Old_Italic',
  'Armn' => 'Armenian',
  'Talu' => 'New_Tai_Lue',
  'Samr' => 'Samaritan',
  'Shaw' => 'Shavian',
  'Arab' => 'Arabic',
  'Guru' => 'Gurmukhi',
  'Jpan' => '',
  'Sogo' => 'Old_Sogdian',
  'Takr' => 'Takri',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Knda' => 'Kannada',
  'Syrn' => '',
  'Osma' => 'Osmanya',
  'Bopo' => 'Bopomofo',
  'Mand' => 'Mandaic',
  'Modi' => 'Modi',
  'Teng' => '',
  'Deva' => 'Devanagari',
  'Vaii' => 'Vai',
  'Khar' => 'Kharoshthi',
  'Hmng' => 'Pahawh_Hmong',
  'Marc' => 'Marchen',
  'Hira' => 'Hiragana',
  'Pauc' => 'Pau_Cin_Hau',
  'Hatr' => 'Hatran',
  'Mlym' => 'Malayalam',
  'Bhks' => 'Bhaiksuki',
  'Inds' => '',
  'Nkdb' => '',
  'Jurc' => '',
  'Tavt' => 'Tai_Viet',
  'Chrs' => 'Chorasmian',
  'Thaa' => 'Thaana',
  'Perm' => 'Old_Permic',
  'Syre' => '',
  'Cprt' => 'Cypriot',
  'Bali' => 'Balinese',
  'Latf' => '',
  'Mani' => 'Manichaean',
  'Zxxx' => '',
  'Nkgb' => '',
  'Geok' => 'Georgian',
  'Phag' => 'Phags_Pa',
  'Roro' => '',
  'Soyo' => 'Soyombo',
  'Sind' => 'Khudawadi',
  'Copt' => 'Coptic',
  'Brah' => 'Brahmi',
  'Aghb' => 'Caucasian_Albanian',
  'Sinh' => 'Sinhala',
  'Rohg' => 'Hanifi_Rohingya',
  'Tfng' => 'Tifinagh',
  'Maya' => '',
  'Hans' => '',
  'Batk' => 'Batak',
  'Lepc' => 'Lepcha',
  'Medf' => 'Medefaidrin',
  'Telu' => 'Telugu',
  'Tale' => 'Tai_Le',
  'Zinh' => 'Inherited',
  'Sidd' => 'Siddham',
  'Grek' => 'Greek',
  'Gujr' => 'Gujarati',
  'Zmth' => '',
  'Elba' => 'Elbasan',
  'Egyd' => '',
  'Moon' => '',
  'Java' => 'Javanese',
  'Buhd' => 'Buhid',
  'Ugar' => 'Ugaritic',
  'Cari' => 'Carian',
  'Osge' => 'Osage',
  'Tglg' => 'Tagalog',
  'Thai' => 'Thai',
  'Hant' => '',
  'Shui' => '',
  'Wcho' => 'Wancho',
  'Dsrt' => 'Deseret',
  'Zanb' => 'Zanabazar_Square',
  'Nshu' => 'Nushu',
  'Lisu' => 'Lisu',
  'Wole' => '',
  'Mend' => 'Mende_Kikakui',
  'Kitl' => '',
  'Tirh' => 'Tirhuta',
  'Limb' => 'Limbu',
  'Egyh' => '',
  'Newa' => 'Newa',
  'Blis' => '',
  'Tibt' => 'Tibetan',
  'Kthi' => 'Kaithi',
  'Mroo' => 'Mro',
  'Cakm' => 'Chakma',
  'Palm' => 'Palmyrene',
  'Sgnw' => 'SignWriting',
  'Adlm' => 'Adlam',
  'Lyci' => 'Lycian',
  'Goth' => 'Gothic',
  'Aran' => '',
  'Orkh' => 'Old_Turkic',
  'Armi' => 'Imperial_Aramaic',
  'Yiii' => 'Yi',
  'Qabx' => '',
  'Xpeo' => 'Old_Persian',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Piqd' => '',
  'Cans' => 'Canadian_Aboriginal',
  'Narb' => 'Old_North_Arabian',
  'Kits' => 'Khitan_Small_Script',
  'Toto' => '',
  'Merc' => 'Meroitic_Cursive',
  'Tagb' => 'Tagbanwa',
  'Ahom' => 'Ahom',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Afak' => '',
  'Nbat' => 'Nabataean',
  'Sund' => 'Sundanese',
  'Nkoo' => 'Nko',
  'Glag' => 'Glagolitic',
  'Kana' => 'Katakana',
  'Orya' => 'Oriya',
  'Yezi' => 'Yezidi',
  'Saur' => 'Saurashtra',
  'Hebr' => 'Hebrew',
  'Gran' => 'Grantha',
  'Cirt' => '',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Phli' => 'Inscriptional_Pahlavi',
  'Gonm' => 'Masaram_Gondi',
  'Syrj' => '',
  'Khoj' => 'Khojki',
  'Sogd' => 'Sogdian',
  'Avst' => 'Avestan',
  'Mult' => 'Multani',
  'Maka' => 'Makasar',
  'Zsye' => '',
  'Lana' => 'Tai_Tham',
  'Dogr' => 'Dogra',
  'Tang' => 'Tangut',
  'Diak' => 'Dives_Akuru',
  'Taml' => 'Tamil',
  'Xsux' => 'Cuneiform',
  'Leke' => '',
  'Syrc' => 'Syriac',
  'Sara' => '',
  'Khmr' => 'Khmer',
  'Brai' => 'Braille',
  'Beng' => 'Bengali',
  'Qaaa' => '',
  'Hani' => 'Han',
  'Hung' => 'Old_Hungarian',
  'Zyyy' => 'Common',
  'Mtei' => 'Meetei_Mayek',
  'Latg' => '',
  'Loma' => '',
  'Bass' => 'Bassa_Vah',
  'Shrd' => 'Sharada',
  'Sarb' => 'Old_South_Arabian',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Hang' => 'Hangul',
  'Phnx' => 'Phoenician',
  'Elym' => 'Elymaic',
  'Dupl' => 'Duployan',
  'Olck' => 'Ol_Chiki',
  'Phlp' => 'Psalter_Pahlavi',
  'Sylo' => 'Syloti_Nagri',
  'Kore' => ''
};
$ScriptName2ScriptCode = {
  'Gothic' => 'Goth',
  'Old_Permic' => 'Perm',
  'Tai_Tham' => 'Lana',
  'Khojki' => 'Khoj',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Buginese' => 'Bugi',
  'Saurashtra' => 'Saur',
  'Greek' => 'Grek',
  'Mende_Kikakui' => 'Mend',
  'Syloti_Nagri' => 'Sylo',
  'Chorasmian' => 'Chrs',
  'Bamum' => 'Bamu',
  'Syriac' => 'Syrc',
  'Bopomofo' => 'Bopo',
  'Makasar' => 'Maka',
  'Hanunoo' => 'Hano',
  'Mongolian' => 'Mong',
  'Caucasian_Albanian' => 'Aghb',
  'Katakana' => 'Kana',
  'Meetei_Mayek' => 'Mtei',
  'Duployan' => 'Dupl',
  'Gurmukhi' => 'Guru',
  'Deseret' => 'Dsrt',
  'Myanmar' => 'Mymr',
  'Common' => 'Zyyy',
  'Javanese' => 'Java',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Canadian_Aboriginal' => 'Cans',
  'Gunjala_Gondi' => 'Gong',
  'Buhid' => 'Buhd',
  'Mro' => 'Mroo',
  'Shavian' => 'Shaw',
  'Latin' => 'Latn',
  'Manichaean' => 'Mani',
  'Elymaic' => 'Elym',
  'Soyombo' => 'Soyo',
  'Meroitic_Cursive' => 'Merc',
  'Runic' => 'Runr',
  'Coptic' => 'Copt',
  'Gujarati' => 'Gujr',
  'Dives_Akuru' => 'Diak',
  'Nko' => 'Nkoo',
  'SignWriting' => 'Sgnw',
  'Chakma' => 'Cakm',
  'Ethiopic' => 'Ethi',
  'Wancho' => 'Wcho',
  'Multani' => 'Mult',
  'Medefaidrin' => 'Medf',
  'Khudawadi' => 'Sind',
  'Carian' => 'Cari',
  'Old_Turkic' => 'Orkh',
  'Tibetan' => 'Tibt',
  'Mahajani' => 'Mahj',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Pau_Cin_Hau' => 'Pauc',
  'Ahom' => 'Ahom',
  'Tirhuta' => 'Tirh',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Khitan_Small_Script' => 'Kits',
  'Armenian' => 'Armn',
  'Tamil' => 'Taml',
  'Cherokee' => 'Cher',
  'Glagolitic' => 'Glag',
  'Lydian' => 'Lydi',
  'Hiragana' => 'Hira',
  'Lisu' => 'Lisu',
  'Masaram_Gondi' => 'Gonm',
  'Imperial_Aramaic' => 'Armi',
  'Cuneiform' => 'Xsux',
  'Hangul' => 'Hang',
  'Pahawh_Hmong' => 'Hmng',
  'Newa' => 'Newa',
  'Takri' => 'Takr',
  'Nushu' => 'Nshu',
  'Georgian' => 'Geor',
  'Tagbanwa' => 'Tagb',
  'Osmanya' => 'Osma',
  'Tai_Viet' => 'Tavt',
  '' => 'Zxxx',
  'Linear_B' => 'Linb',
  'Elbasan' => 'Elba',
  'Tagalog' => 'Tglg',
  'Osage' => 'Osge',
  'Hatran' => 'Hatr',
  'Braille' => 'Brai',
  'Tangut' => 'Tang',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Cyrillic' => 'Cyrl',
  'Han' => 'Hani',
  'Inscriptional_Pahlavi' => 'Phli',
  'Tai_Le' => 'Tale',
  'Phags_Pa' => 'Phag',
  'Bhaiksuki' => 'Bhks',
  'Lao' => 'Laoo',
  'Balinese' => 'Bali',
  'Nabataean' => 'Nbat',
  'Kannada' => 'Knda',
  'Adlam' => 'Adlm',
  'Avestan' => 'Avst',
  'Sora_Sompeng' => 'Sora',
  'Telugu' => 'Telu',
  'Marchen' => 'Marc',
  'Bengali' => 'Beng',
  'Thai' => 'Thai',
  'Nandinagari' => 'Nand',
  'Ugaritic' => 'Ugar',
  'Batak' => 'Batk',
  'Oriya' => 'Orya',
  'Inherited' => 'Zinh',
  'Mandaic' => 'Mand',
  'Ogham' => 'Ogam',
  'Old_Persian' => 'Xpeo',
  'Malayalam' => 'Mlym',
  'Brahmi' => 'Brah',
  'Unknown' => 'Zzzz',
  'Bassa_Vah' => 'Bass',
  'Kayah_Li' => 'Kali',
  'New_Tai_Lue' => 'Talu',
  'Limbu' => 'Limb',
  'Devanagari' => 'Deva',
  'Thaana' => 'Thaa',
  'Phoenician' => 'Phnx',
  'Lycian' => 'Lyci',
  'Kharoshthi' => 'Khar',
  'Zanabazar_Square' => 'Zanb',
  'Siddham' => 'Sidd',
  'Palmyrene' => 'Palm',
  'Old_Sogdian' => 'Sogo',
  'Sharada' => 'Shrd',
  'Sundanese' => 'Sund',
  'Vai' => 'Vaii',
  'Rejang' => 'Rjng',
  'Old_Italic' => 'Ital',
  'Psalter_Pahlavi' => 'Phlp',
  'Samaritan' => 'Samr',
  'Arabic' => 'Arab',
  'Cypriot' => 'Cprt',
  'Hanifi_Rohingya' => 'Rohg',
  'Lepcha' => 'Lepc',
  'Tifinagh' => 'Tfng',
  'Modi' => 'Modi',
  'Old_South_Arabian' => 'Sarb',
  'Warang_Citi' => 'Wara',
  'Khmer' => 'Khmr',
  'Inscriptional_Parthian' => 'Prti',
  'Cham' => 'Cham',
  'Linear_A' => 'Lina',
  'Yi' => 'Yiii',
  'Old_Hungarian' => 'Hung',
  'Ol_Chiki' => 'Olck',
  'Hebrew' => 'Hebr',
  'Sogdian' => 'Sogd',
  'Miao' => 'Plrd',
  'Kaithi' => 'Kthi',
  'Dogra' => 'Dogr',
  'Yezidi' => 'Yezi',
  'Grantha' => 'Gran',
  'Sinhala' => 'Sinh',
  'Old_North_Arabian' => 'Narb'
};
$ScriptId2ScriptCode = {
  '131' => 'Phli',
  '400' => 'Lina',
  '398' => 'Sora',
  '502' => 'Hant',
  '265' => 'Medf',
  '403' => 'Cprt',
  '995' => 'Zmth',
  '570' => 'Brai',
  '399' => 'Lisu',
  '356' => 'Laoo',
  '349' => 'Cakm',
  '437' => 'Loma',
  '137' => 'Syrj',
  '410' => 'Hira',
  '337' => 'Mtei',
  '357' => 'Kali',
  '192' => 'Yezi',
  '165' => 'Nkoo',
  '283' => 'Wcho',
  '998' => 'Zyyy',
  '311' => 'Nand',
  '109' => 'Chrs',
  '120' => 'Tfng',
  '106' => 'Narb',
  '138' => 'Syre',
  '142' => 'Sogo',
  '227' => 'Perm',
  '060' => 'Egyh',
  '997' => 'Zxxx',
  '030' => 'Xpeo',
  '480' => 'Wole',
  '226' => 'Elba',
  '342' => 'Diak',
  '430' => 'Ethi',
  '281' => 'Shaw',
  '127' => 'Hatr',
  '070' => 'Egyd',
  '175' => 'Orkh',
  '499' => 'Nshu',
  '327' => 'Orya',
  '413' => 'Jpan',
  '354' => 'Talu',
  '040' => 'Ugar',
  '412' => 'Hrkt',
  '100' => 'Mero',
  '264' => 'Mroo',
  '999' => 'Zzzz',
  '167' => 'Rohg',
  '221' => 'Cyrs',
  '353' => 'Tale',
  '993' => 'Zsye',
  '280' => 'Visp',
  '550' => 'Blis',
  '126' => 'Palm',
  '339' => 'Zanb',
  '330' => 'Tibt',
  '305' => 'Khar',
  '090' => 'Maya',
  '230' => 'Armn',
  '134' => 'Avst',
  '145' => 'Mong',
  '344' => 'Saur',
  '291' => 'Cirt',
  '160' => 'Arab',
  '343' => 'Gran',
  '352' => 'Thai',
  '312' => 'Gong',
  '325' => 'Beng',
  '451' => 'Hmnp',
  '367' => 'Bugi',
  '324' => 'Modi',
  '362' => 'Sund',
  '262' => 'Wara',
  '350' => 'Mymr',
  '315' => 'Deva',
  '365' => 'Batk',
  '139' => 'Mani',
  '239' => 'Aghb',
  '263' => 'Pauc',
  '318' => 'Sind',
  '470' => 'Vaii',
  '124' => 'Armi',
  '310' => 'Guru',
  '125' => 'Hebr',
  '411' => 'Kana',
  '260' => 'Osma',
  '215' => 'Latn',
  '166' => 'Adlm',
  '250' => 'Dsrt',
  '132' => 'Phlp',
  '520' => 'Tang',
  '261' => 'Olck',
  '288' => 'Kits',
  '900' => 'Qaaa',
  '285' => 'Bopo',
  '170' => 'Thaa',
  '450' => 'Hmng',
  '500' => 'Hani',
  '402' => 'Cpmn',
  '326' => 'Tirh',
  '340' => 'Telu',
  '317' => 'Kthi',
  '501' => 'Hans',
  '217' => 'Latf',
  '322' => 'Khoj',
  '436' => 'Kpel',
  '136' => 'Syrn',
  '335' => 'Lepc',
  '294' => 'Toto',
  '949' => 'Qabx',
  '994' => 'Zinh',
  '293' => 'Piqd',
  '101' => 'Merc',
  '210' => 'Ital',
  '610' => 'Inds',
  '284' => 'Jamo',
  '105' => 'Sarb',
  '366' => 'Maka',
  '204' => 'Copt',
  '328' => 'Dogr',
  '200' => 'Grek',
  '334' => 'Bhks',
  '373' => 'Tagb',
  '161' => 'Aran',
  '095' => 'Sgnw',
  '241' => 'Geok',
  '225' => 'Glag',
  '435' => 'Bamu',
  '348' => 'Sinh',
  '286' => 'Hang',
  '240' => 'Geor',
  '020' => 'Xsux',
  '363' => 'Rjng',
  '128' => 'Elym',
  '332' => 'Marc',
  '351' => 'Lana',
  '329' => 'Soyo',
  '290' => 'Teng',
  '292' => 'Sara',
  '314' => 'Mahj',
  '505' => 'Kitl',
  '996' => 'Zsym',
  '313' => 'Gonm',
  '755' => 'Dupl',
  '336' => 'Limb',
  '282' => 'Plrd',
  '333' => 'Newa',
  '133' => 'Phlv',
  '460' => 'Yiii',
  '159' => 'Nbat',
  '438' => 'Mend',
  '331' => 'Phag',
  '050' => 'Egyp',
  '338' => 'Ahom',
  '080' => 'Hluw',
  '300' => 'Brah',
  '212' => 'Ogam',
  '141' => 'Sogd',
  '218' => 'Moon',
  '440' => 'Cans',
  '287' => 'Kore',
  '259' => 'Bass',
  '347' => 'Mlym',
  '364' => 'Leke',
  '220' => 'Cyrl',
  '206' => 'Goth',
  '202' => 'Lyci',
  '360' => 'Bali',
  '321' => 'Takr',
  '372' => 'Buhd',
  '216' => 'Latg',
  '130' => 'Prti',
  '401' => 'Linb',
  '345' => 'Knda',
  '361' => 'Java',
  '176' => 'Hung',
  '371' => 'Hano',
  '319' => 'Shrd',
  '135' => 'Syrc',
  '346' => 'Taml',
  '620' => 'Roro',
  '510' => 'Jurc',
  '219' => 'Osge',
  '201' => 'Cari',
  '211' => 'Runr',
  '439' => 'Afak',
  '115' => 'Phnx',
  '359' => 'Tavt',
  '302' => 'Sidd',
  '140' => 'Mand',
  '530' => 'Shui',
  '316' => 'Sylo',
  '320' => 'Gujr',
  '445' => 'Cher',
  '323' => 'Mult',
  '116' => 'Lydi',
  '370' => 'Tglg',
  '123' => 'Samr',
  '420' => 'Nkgb',
  '358' => 'Cham',
  '503' => 'Hanb',
  '085' => 'Nkdb',
  '355' => 'Khmr'
};
$ScriptCode2EnglishName = {
  'Mlym' => 'Malayalam',
  'Bhks' => 'Bhaiksuki',
  'Hatr' => 'Hatran',
  'Pauc' => 'Pau Cin Hau',
  'Marc' => 'Marchen',
  'Hira' => 'Hiragana',
  'Chrs' => 'Chorasmian',
  'Thaa' => 'Thaana',
  'Jurc' => 'Jurchen',
  'Tavt' => 'Tai Viet',
  'Inds' => 'Indus (Harappan)',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Mani' => 'Manichaean',
  'Bali' => 'Balinese',
  'Latf' => 'Latin (Fraktur variant)',
  'Cprt' => 'Cypriot syllabary',
  'Syre' => 'Syriac (Estrangelo variant)',
  'Perm' => 'Old Permic',
  'Sind' => 'Khudawadi, Sindhi',
  'Soyo' => 'Soyombo',
  'Copt' => 'Coptic',
  'Roro' => 'Rongorongo',
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Phag' => 'Phags-pa',
  'Zxxx' => 'Code for unwritten documents',
  'Tfng' => 'Tifinagh (Berber)',
  'Maya' => 'Mayan hieroglyphs',
  'Rohg' => 'Hanifi Rohingya',
  'Brah' => 'Brahmi',
  'Aghb' => 'Caucasian Albanian',
  'Sinh' => 'Sinhala',
  'Telu' => 'Telugu',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Batk' => 'Batak',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Hans' => 'Han (Simplified variant)',
  'Ugar' => 'Ugaritic',
  'Buhd' => 'Buhid',
  'Elba' => 'Elbasan',
  'Egyd' => 'Egyptian demotic',
  'Java' => 'Javanese',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Zmth' => 'Mathematical notation',
  'Tale' => 'Tai Le',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Zinh' => 'Code for inherited script',
  'Grek' => 'Greek',
  'Gujr' => 'Gujarati',
  'Shui' => 'Shuishu',
  'Hant' => 'Han (Traditional variant)',
  'Thai' => 'Thai',
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Cari' => 'Carian',
  'Osge' => 'Osage',
  'Bamu' => 'Bamum',
  'Visp' => 'Visible Speech',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Lina' => 'Linear A',
  'Laoo' => 'Lao',
  'Bugi' => 'Buginese',
  'Cham' => 'Cham',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Lydi' => 'Lydian',
  'Phlv' => 'Book Pahlavi',
  'Zsym' => 'Symbols',
  'Kali' => 'Kayah Li',
  'Linb' => 'Linear B',
  'Kpel' => 'Kpelle',
  'Mahj' => 'Mahajani',
  'Runr' => 'Runic',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Plrd' => 'Miao (Pollard)',
  'Mong' => 'Mongolian',
  'Mymr' => 'Myanmar (Burmese)',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Cher' => 'Cherokee',
  'Gong' => 'Gunjala Gondi',
  'Latn' => 'Latin',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Cyrl' => 'Cyrillic',
  'Sora' => 'Sora Sompeng',
  'Cpmn' => 'Cypro-Minoan',
  'Ogam' => 'Ogham',
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Zzzz' => 'Code for uncoded script',
  'Prti' => 'Inscriptional Parthian',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Nand' => 'Nandinagari',
  'Sogo' => 'Old Sogdian',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Samr' => 'Samaritan',
  'Talu' => 'New Tai Lue',
  'Armn' => 'Armenian',
  'Shaw' => 'Shavian (Shaw)',
  'Arab' => 'Arabic',
  'Guru' => 'Gurmukhi',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Bopo' => 'Bopomofo',
  'Osma' => 'Osmanya',
  'Syrn' => 'Syriac (Eastern variant)',
  'Knda' => 'Kannada',
  'Khar' => 'Kharoshthi',
  'Hmng' => 'Pahawh Hmong',
  'Deva' => 'Devanagari (Nagari)',
  'Vaii' => 'Vai',
  'Teng' => 'Tengwar',
  'Mand' => 'Mandaic, Mandaean',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Sogd' => 'Sogdian',
  'Khoj' => 'Khojki',
  'Phli' => 'Inscriptional Pahlavi',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Syrj' => 'Syriac (Western variant)',
  'Gonm' => 'Masaram Gondi',
  'Gran' => 'Grantha',
  'Cirt' => 'Cirth',
  'Lana' => 'Tai Tham (Lanna)',
  'Dogr' => 'Dogra',
  'Zsye' => 'Symbols (Emoji variant)',
  'Maka' => 'Makasar',
  'Mult' => 'Multani',
  'Avst' => 'Avestan',
  'Syrc' => 'Syriac',
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Taml' => 'Tamil',
  'Leke' => 'Leke',
  'Diak' => 'Dives Akuru',
  'Tang' => 'Tangut',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Qaaa' => 'Reserved for private use (start)',
  'Brai' => 'Braille',
  'Beng' => 'Bengali (Bangla)',
  'Sara' => 'Sarati',
  'Khmr' => 'Khmer',
  'Latg' => 'Latin (Gaelic variant)',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Zyyy' => 'Code for undetermined script',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Sarb' => 'Old South Arabian',
  'Bass' => 'Bassa Vah',
  'Loma' => 'Loma',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Phnx' => 'Phoenician',
  'Elym' => 'Elymaic',
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Phlp' => 'Psalter Pahlavi',
  'Sylo' => 'Syloti Nagri',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Lisu' => 'Lisu (Fraser)',
  'Wole' => 'Woleai',
  'Mend' => 'Mende Kikakui',
  'Dsrt' => 'Deseret (Mormon)',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Nshu' => "N\x{fc}shu",
  'Wcho' => 'Wancho',
  'Cakm' => 'Chakma',
  'Palm' => 'Palmyrene',
  'Adlm' => 'Adlam',
  'Sgnw' => 'SignWriting',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Blis' => 'Blissymbols',
  'Mroo' => 'Mro, Mru',
  'Tibt' => 'Tibetan',
  'Kthi' => 'Kaithi',
  'Egyh' => 'Egyptian hieratic',
  'Limb' => 'Limbu',
  'Kitl' => 'Khitan large script',
  'Tirh' => 'Tirhuta',
  'Yiii' => 'Yi',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Armi' => 'Imperial Aramaic',
  'Goth' => 'Gothic',
  'Lyci' => 'Lycian',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Xpeo' => 'Old Persian',
  'Qabx' => 'Reserved for private use (end)',
  'Kits' => 'Khitan small script',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Mero' => 'Meroitic Hieroglyphs',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Nkoo' => "N\x{2019}Ko",
  'Sund' => 'Sundanese',
  'Afak' => 'Afaka',
  'Nbat' => 'Nabataean',
  'Tagb' => 'Tagbanwa',
  'Ahom' => 'Ahom, Tai Ahom',
  'Egyp' => 'Egyptian hieroglyphs',
  'Toto' => 'Toto',
  'Merc' => 'Meroitic Cursive',
  'Glag' => 'Glagolitic',
  'Hebr' => 'Hebrew',
  'Orya' => 'Oriya (Odia)',
  'Yezi' => 'Yezidi',
  'Saur' => 'Saurashtra',
  'Kana' => 'Katakana'
};
$ScriptCode2FrenchName = {
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Guru' => "gourmoukh\x{ee}",
  'Shaw' => 'shavien (Shaw)',
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Arab' => 'arabe',
  'Samr' => 'samaritain',
  'Talu' => "nouveau ta\x{ef}-lue",
  'Armn' => "arm\x{e9}nien",
  'Takr' => "t\x{e2}kr\x{ee}",
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Sogo' => 'ancien sogdien',
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Prti' => 'parthe des inscriptions',
  'Rjng' => 'redjang (kaganga)',
  'Ogam' => 'ogam',
  'Cpmn' => 'syllabaire chypro-minoen',
  'Mand' => "mand\x{e9}en",
  'Modi' => "mod\x{ee}",
  'Teng' => 'tengwar',
  'Vaii' => "va\x{ef}",
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Khar' => "kharochth\x{ee}",
  'Hmng' => 'pahawh hmong',
  'Syrn' => 'syriaque (variante orientale)',
  'Osma' => 'osmanais',
  'Knda' => 'kannara (canara)',
  'Bopo' => 'bopomofo',
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Linb' => "lin\x{e9}aire B",
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Kali' => 'kayah li',
  'Zsym' => 'symboles',
  'Phlv' => 'pehlevi des livres',
  'Lydi' => 'lydien',
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Bugi' => 'bouguis',
  'Cham' => "cham (\x{10d}am, tcham)",
  'Laoo' => 'laotien',
  'Lina' => "lin\x{e9}aire A",
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Visp' => 'parole visible',
  'Bamu' => 'bamoum',
  'Sora' => 'sora sompeng',
  'Cyrl' => 'cyrillique',
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Hano' => "hanoun\x{f3}o",
  'Latn' => 'latin',
  'Gong' => "gunjala gond\x{ee}",
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Mymr' => 'birman',
  'Plrd' => 'miao (Pollard)',
  'Mong' => 'mongol',
  'Wara' => 'warang citi',
  'Runr' => 'runique',
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Batk' => 'batik',
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Telu' => "t\x{e9}lougou",
  'Aghb' => 'aghbanien',
  'Sinh' => 'singhalais',
  'Brah' => 'brahma',
  'Rohg' => 'hanifi rohingya',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Osge' => 'osage',
  'Cari' => 'carien',
  'Thai' => "tha\x{ef}",
  'Tglg' => 'tagal (baybayin, alibata)',
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Shui' => 'shuishu',
  'Grek' => 'grec',
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Sidd' => 'siddham',
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Tale' => "ta\x{ef}-le",
  'Zmth' => "notation math\x{e9}matique",
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Java' => 'javanais',
  'Moon' => "\x{e9}criture Moon",
  'Elba' => 'elbasan',
  'Buhd' => 'bouhide',
  'Ugar' => 'ougaritique',
  'Nkdb' => 'naxi dongba',
  'Inds' => 'indus',
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Jurc' => 'jurchen',
  'Chrs' => 'chorasmien',
  'Thaa' => "th\x{e2}na",
  'Hira' => 'hiragana',
  'Marc' => 'marchen',
  'Pauc' => 'paou chin haou',
  'Hatr' => "hatr\x{e9}nien",
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Mlym' => "malay\x{e2}lam",
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Phag' => "\x{2019}phags pa",
  'Nkgb' => 'naxi geba, nakhi geba',
  'Roro' => 'rongorongo',
  'Copt' => 'copte',
  'Soyo' => 'soyombo',
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Perm' => 'ancien permien',
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Cprt' => 'syllabaire chypriote',
  'Latf' => "latin (variante bris\x{e9}e)",
  'Bali' => 'balinais',
  'Mani' => "manich\x{e9}en",
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Toto' => 'toto',
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Tagb' => 'tagbanoua',
  'Ahom' => "\x{e2}hom",
  'Nbat' => "nabat\x{e9}en",
  'Afak' => 'afaka',
  'Sund' => 'sundanais',
  'Nkoo' => "n\x{2019}ko",
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Narb' => 'nord-arabique',
  'Kits' => "petite \x{e9}criture khitan",
  'Kana' => 'katakana',
  'Orya' => "oriy\x{e2} (odia)",
  'Yezi' => "y\x{e9}zidi",
  'Saur' => 'saurachtra',
  'Hebr' => "h\x{e9}breu",
  'Glag' => 'glagolitique',
  'Kitl' => "grande \x{e9}criture khitan",
  'Tirh' => 'tirhouta',
  'Limb' => 'limbou',
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Kthi' => "kaith\x{ee}",
  'Tibt' => "tib\x{e9}tain",
  'Mroo' => 'mro',
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Blis' => 'symboles Bliss',
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Adlm' => 'adlam',
  'Cakm' => 'chakma',
  'Palm' => "palmyr\x{e9}nien",
  'Wcho' => 'wantcho',
  'Nshu' => "n\x{fc}shu",
  'Zanb' => 'zanabazar quadratique',
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Wole' => "wol\x{e9}a\x{ef}",
  'Lisu' => 'lisu (Fraser)',
  'Mend' => "mend\x{e9} kikakui",
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Aran' => 'arabe (variante nastalique)',
  'Lyci' => 'lycien',
  'Goth' => 'gotique',
  'Orkh' => 'orkhon',
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Yiii' => 'yi',
  'Loma' => 'loma',
  'Bass' => 'bassa',
  'Sarb' => 'sud-arabique, himyarite',
  'Shrd' => 'charada, shard',
  'Mtei' => 'meitei mayek',
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Olck' => 'ol tchiki',
  'Phlp' => 'pehlevi des psautiers',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Phnx' => "ph\x{e9}nicien",
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Hmnp' => 'nyiakeng puachue hmong',
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Mult' => "multan\x{ee}",
  'Maka' => 'makassar',
  'Avst' => 'avestique',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Dogr' => 'dogra',
  'Lana' => "ta\x{ef} tham (lanna)",
  'Cirt' => 'cirth',
  'Gran' => 'grantha',
  'Gonm' => "masaram gond\x{ee}",
  'Syrj' => 'syriaque (variante occidentale)',
  'Phli' => 'pehlevi des inscriptions',
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Khoj' => "khojk\x{ee}",
  'Sogd' => 'sogdien',
  'Khmr' => 'khmer',
  'Sara' => 'sarati',
  'Beng' => "bengal\x{ee} (bangla)",
  'Brai' => 'braille',
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Tang' => 'tangoute',
  'Diak' => 'dives akuru',
  'Leke' => "l\x{e9}k\x{e9}",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Taml' => 'tamoul',
  'Syrc' => 'syriaque'
};
$ScriptCodeVersion = {
  'Mani' => '7.0',
  'Bali' => '5.0',
  'Latf' => '1.1',
  'Cprt' => '4.0',
  'Perm' => '7.0',
  'Syre' => '3.0',
  'Sind' => '7.0',
  'Soyo' => '10.0',
  'Copt' => '4.1',
  'Roro' => '',
  'Nkgb' => '',
  'Phag' => '5.0',
  'Geok' => '1.1',
  'Zxxx' => '',
  'Mlym' => '1.1',
  'Bhks' => '9.0',
  'Hatr' => '8.0',
  'Pauc' => '7.0',
  'Marc' => '9.0',
  'Hira' => '1.1',
  'Chrs' => '13.0',
  'Thaa' => '3.0',
  'Jurc' => '',
  'Tavt' => '5.2',
  'Inds' => '',
  'Nkdb' => '',
  'Buhd' => '3.2',
  'Ugar' => '4.0',
  'Elba' => '7.0',
  'Egyd' => '',
  'Java' => '5.2',
  'Moon' => '',
  'Zmth' => '3.2',
  'Tale' => '4.0',
  'Sidd' => '7.0',
  'Zinh' => '',
  'Gujr' => '1.1',
  'Grek' => '1.1',
  'Shui' => '',
  'Hant' => '1.1',
  'Tglg' => '3.2',
  'Thai' => '1.1',
  'Cari' => '5.1',
  'Osge' => '9.0',
  'Maya' => '',
  'Tfng' => '4.1',
  'Rohg' => '11.0',
  'Brah' => '6.0',
  'Sinh' => '3.0',
  'Aghb' => '7.0',
  'Telu' => '1.1',
  'Batk' => '6.0',
  'Lepc' => '5.1',
  'Medf' => '11.0',
  'Hans' => '1.1',
  'Runr' => '3.0',
  'Wara' => '7.0',
  'Mong' => '3.0',
  'Plrd' => '6.1',
  'Mymr' => '3.0',
  'Jamo' => '1.1',
  'Cher' => '3.0',
  'Gong' => '11.0',
  'Latn' => '1.1',
  'Hano' => '3.2',
  'Geor' => '1.1',
  'Cyrl' => '1.1',
  'Sora' => '6.1',
  'Bamu' => '5.2',
  'Visp' => '',
  'Ethi' => '3.0',
  'Laoo' => '1.1',
  'Lina' => '7.0',
  'Bugi' => '4.1',
  'Cham' => '5.1',
  'Cyrs' => '1.1',
  'Lydi' => '5.1',
  'Phlv' => '',
  'Zsym' => '1.1',
  'Kali' => '5.1',
  'Linb' => '4.0',
  'Kpel' => '',
  'Mahj' => '7.0',
  'Bopo' => '1.1',
  'Osma' => '4.0',
  'Syrn' => '3.0',
  'Knda' => '1.1',
  'Khar' => '4.1',
  'Hmng' => '7.0',
  'Deva' => '1.1',
  'Vaii' => '5.1',
  'Teng' => '',
  'Modi' => '7.0',
  'Mand' => '6.0',
  'Cpmn' => '',
  'Ogam' => '3.0',
  'Rjng' => '5.1',
  'Prti' => '5.2',
  'Zzzz' => '',
  'Hanb' => '1.1',
  'Nand' => '12.0',
  'Sogo' => '11.0',
  'Hrkt' => '1.1',
  'Takr' => '6.1',
  'Talu' => '4.1',
  'Samr' => '5.2',
  'Armn' => '1.1',
  'Shaw' => '4.0',
  'Guru' => '1.1',
  'Arab' => '1.1',
  'Jpan' => '1.1',
  'Ital' => '3.1',
  'Syrc' => '3.0',
  'Xsux' => '5.0',
  'Taml' => '1.1',
  'Leke' => '',
  'Diak' => '13.0',
  'Tang' => '9.0',
  'Hani' => '1.1',
  'Qaaa' => '',
  'Brai' => '3.0',
  'Beng' => '1.1',
  'Sara' => '',
  'Khmr' => '3.0',
  'Sogd' => '11.0',
  'Khoj' => '7.0',
  'Hluw' => '8.0',
  'Phli' => '5.2',
  'Gonm' => '10.0',
  'Syrj' => '3.0',
  'Gran' => '7.0',
  'Cirt' => '',
  'Lana' => '5.2',
  'Dogr' => '11.0',
  'Zsye' => '6.0',
  'Avst' => '5.2',
  'Mult' => '8.0',
  'Maka' => '11.0',
  'Dupl' => '7.0',
  'Hmnp' => '12.0',
  'Hang' => '1.1',
  'Phnx' => '5.0',
  'Elym' => '12.0',
  'Sylo' => '4.1',
  'Phlp' => '7.0',
  'Kore' => '1.1',
  'Olck' => '5.1',
  'Latg' => '1.1',
  'Hung' => '8.0',
  'Mtei' => '5.2',
  'Zyyy' => '',
  'Shrd' => '6.1',
  'Sarb' => '5.2',
  'Bass' => '7.0',
  'Loma' => '',
  'Yiii' => '3.0',
  'Armi' => '5.2',
  'Orkh' => '5.2',
  'Lyci' => '5.1',
  'Goth' => '3.1',
  'Aran' => '1.1',
  'Xpeo' => '4.1',
  'Qabx' => '',
  'Wole' => '',
  'Mend' => '7.0',
  'Lisu' => '5.2',
  'Dsrt' => '3.1',
  'Zanb' => '10.0',
  'Nshu' => '10.0',
  'Wcho' => '12.0',
  'Cakm' => '6.1',
  'Palm' => '7.0',
  'Adlm' => '9.0',
  'Sgnw' => '8.0',
  'Newa' => '9.0',
  'Blis' => '',
  'Mroo' => '7.0',
  'Tibt' => '2.0',
  'Kthi' => '5.2',
  'Limb' => '4.0',
  'Egyh' => '5.2',
  'Kitl' => '',
  'Tirh' => '7.0',
  'Glag' => '4.1',
  'Hebr' => '1.1',
  'Orya' => '1.1',
  'Yezi' => '13.0',
  'Saur' => '5.1',
  'Kana' => '1.1',
  'Kits' => '13.0',
  'Cans' => '3.0',
  'Narb' => '7.0',
  'Mero' => '6.1',
  'Piqd' => '',
  'Sund' => '5.1',
  'Nkoo' => '5.0',
  'Afak' => '',
  'Nbat' => '7.0',
  'Egyp' => '5.2',
  'Tagb' => '3.2',
  'Ahom' => '8.0',
  'Toto' => '',
  'Merc' => '6.1'
};
$ScriptCodeDate = {
  'Hatr' => '2015-07-07
',
  'Mlym' => '2004-05-01
',
  'Bhks' => '2016-12-05
',
  'Marc' => '2016-12-05
',
  'Hira' => '2004-05-01
',
  'Pauc' => '2014-11-15
',
  'Chrs' => '2019-08-19
',
  'Thaa' => '2004-05-01
',
  'Inds' => '2004-05-01
',
  'Nkdb' => '2017-07-26
',
  'Jurc' => '2010-12-21
',
  'Tavt' => '2009-06-01
',
  'Bali' => '2006-10-10
',
  'Latf' => '2004-05-01
',
  'Mani' => '2014-11-15
',
  'Syre' => '2004-05-01
',
  'Perm' => '2014-11-15
',
  'Cprt' => '2017-07-26
',
  'Roro' => '2004-05-01
',
  'Soyo' => '2017-07-26
',
  'Sind' => '2014-11-15
',
  'Copt' => '2006-06-21
',
  'Zxxx' => '2011-06-21
',
  'Nkgb' => '2017-07-26
',
  'Phag' => '2006-10-10
',
  'Geok' => '2012-10-16
',
  'Tfng' => '2006-06-21
',
  'Maya' => '2004-05-01
',
  'Brah' => '2010-07-23
',
  'Sinh' => '2004-05-01
',
  'Aghb' => '2014-11-15
',
  'Rohg' => '2017-11-21
',
  'Telu' => '2004-05-01
',
  'Hans' => '2004-05-29
',
  'Batk' => '2010-07-23
',
  'Medf' => '2016-12-05
',
  'Lepc' => '2007-07-02
',
  'Elba' => '2014-11-15
',
  'Moon' => '2006-12-11
',
  'Egyd' => '2004-05-01
',
  'Java' => '2009-06-01
',
  'Buhd' => '2004-05-01
',
  'Ugar' => '2004-05-01
',
  'Tale' => '2004-10-25
',
  'Sidd' => '2014-11-15
',
  'Zinh' => '2009-02-23
',
  'Gujr' => '2004-05-01
',
  'Grek' => '2004-05-01
',
  'Zmth' => '2007-11-26
',
  'Hant' => '2004-05-29
',
  'Shui' => '2017-07-26
',
  'Cari' => '2007-07-02
',
  'Osge' => '2016-12-05
',
  'Thai' => '2004-05-01
',
  'Tglg' => '2009-02-23
',
  'Visp' => '2004-05-01
',
  'Ethi' => '2004-10-25
',
  'Bamu' => '2009-06-01
',
  'Cham' => '2009-11-11
',
  'Bugi' => '2006-06-21
',
  'Laoo' => '2004-05-01
',
  'Lina' => '2014-11-15
',
  'Lydi' => '2007-07-02
',
  'Phlv' => '2007-07-15
',
  'Zsym' => '2007-11-26
',
  'Cyrs' => '2004-05-01
',
  'Mahj' => '2014-11-15
',
  'Kali' => '2007-07-02
',
  'Linb' => '2004-05-29
',
  'Kpel' => '2010-03-26
',
  'Wara' => '2014-11-15
',
  'Runr' => '2004-05-01
',
  'Plrd' => '2012-02-06
',
  'Mong' => '2004-05-01
',
  'Jamo' => '2016-01-19
',
  'Mymr' => '2004-05-01
',
  'Latn' => '2004-05-01
',
  'Cher' => '2004-05-01
',
  'Gong' => '2016-12-05
',
  'Sora' => '2012-02-06
',
  'Hano' => '2004-05-29
',
  'Cyrl' => '2004-05-01
',
  'Geor' => '2016-12-05
',
  'Rjng' => '2009-02-23
',
  'Zzzz' => '2006-10-10
',
  'Prti' => '2009-06-01
',
  'Cpmn' => '2017-07-26
',
  'Ogam' => '2004-05-01
',
  'Nand' => '2018-08-26
',
  'Hanb' => '2016-01-19
',
  'Sogo' => '2017-11-21
',
  'Takr' => '2012-02-06
',
  'Hrkt' => '2011-06-21
',
  'Ital' => '2004-05-29
',
  'Samr' => '2009-06-01
',
  'Talu' => '2006-06-21
',
  'Armn' => '2004-05-01
',
  'Shaw' => '2004-05-01
',
  'Arab' => '2004-05-01
',
  'Guru' => '2004-05-01
',
  'Jpan' => '2006-06-21
',
  'Bopo' => '2004-05-01
',
  'Osma' => '2004-05-01
',
  'Syrn' => '2004-05-01
',
  'Knda' => '2004-05-29
',
  'Deva' => '2004-05-01
',
  'Vaii' => '2007-07-02
',
  'Khar' => '2006-06-21
',
  'Hmng' => '2014-11-15
',
  'Mand' => '2010-07-23
',
  'Modi' => '2014-11-15
',
  'Teng' => '2004-05-01
',
  'Khoj' => '2014-11-15
',
  'Sogd' => '2017-11-21
',
  'Gran' => '2014-11-15
',
  'Cirt' => '2004-05-01
',
  'Phli' => '2009-06-01
',
  'Hluw' => '2015-07-07
',
  'Gonm' => '2017-07-26
',
  'Syrj' => '2004-05-01
',
  'Zsye' => '2015-12-16
',
  'Lana' => '2009-06-01
',
  'Dogr' => '2016-12-05
',
  'Mult' => '2015-07-07
',
  'Maka' => '2016-12-05
',
  'Avst' => '2009-06-01
',
  'Xsux' => '2006-10-10
',
  'Taml' => '2004-05-01
',
  'Leke' => '2015-07-07
',
  'Syrc' => '2004-05-01
',
  'Tang' => '2016-12-05
',
  'Diak' => '2019-08-19
',
  'Brai' => '2004-05-01
',
  'Beng' => '2016-12-05
',
  'Hani' => '2009-02-23
',
  'Qaaa' => '2004-05-29
',
  'Sara' => '2004-05-29
',
  'Khmr' => '2004-05-29
',
  'Latg' => '2004-05-01
',
  'Hung' => '2015-07-07
',
  'Zyyy' => '2004-05-29
',
  'Mtei' => '2009-06-01
',
  'Bass' => '2014-11-15
',
  'Shrd' => '2012-02-06
',
  'Sarb' => '2009-06-01
',
  'Loma' => '2010-03-26
',
  'Dupl' => '2014-11-15
',
  'Hmnp' => '2017-07-26
',
  'Phnx' => '2006-10-10
',
  'Elym' => '2018-08-26
',
  'Hang' => '2004-05-29
',
  'Olck' => '2007-07-02
',
  'Sylo' => '2006-06-21
',
  'Phlp' => '2014-11-15
',
  'Kore' => '2007-06-13
',
  'Mend' => '2014-11-15
',
  'Wole' => '2010-12-21
',
  'Lisu' => '2009-06-01
',
  'Wcho' => '2017-07-26
',
  'Dsrt' => '2004-05-01
',
  'Zanb' => '2017-07-26
',
  'Nshu' => '2017-07-26
',
  'Newa' => '2016-12-05
',
  'Blis' => '2004-05-01
',
  'Mroo' => '2016-12-05
',
  'Tibt' => '2004-05-01
',
  'Kthi' => '2009-06-01
',
  'Palm' => '2014-11-15
',
  'Cakm' => '2012-02-06
',
  'Adlm' => '2016-12-05
',
  'Sgnw' => '2015-07-07
',
  'Kitl' => '2015-07-15
',
  'Tirh' => '2014-11-15
',
  'Limb' => '2004-05-29
',
  'Egyh' => '2004-05-01
',
  'Yiii' => '2004-05-01
',
  'Lyci' => '2007-07-02
',
  'Goth' => '2004-05-01
',
  'Aran' => '2014-11-15
',
  'Orkh' => '2009-06-01
',
  'Armi' => '2009-06-01
',
  'Xpeo' => '2006-06-21
',
  'Qabx' => '2004-05-29
',
  'Kits' => '2015-07-15
',
  'Mero' => '2012-02-06
',
  'Piqd' => '2015-12-16
',
  'Cans' => '2004-05-29
',
  'Narb' => '2014-11-15
',
  'Afak' => '2010-12-21
',
  'Nbat' => '2014-11-15
',
  'Sund' => '2007-07-02
',
  'Nkoo' => '2006-10-10
',
  'Toto' => '2020-04-16
',
  'Merc' => '2012-02-06
',
  'Tagb' => '2004-05-01
',
  'Ahom' => '2015-07-07
',
  'Egyp' => '2009-06-01
',
  'Glag' => '2006-06-21
',
  'Hebr' => '2004-05-01
',
  'Kana' => '2004-05-01
',
  'Yezi' => '2019-08-19
',
  'Saur' => '2007-07-02
',
  'Orya' => '2016-12-05
'
};
$ScriptCodeId = {
  'Latg' => '216',
  'Mtei' => '337',
  'Zyyy' => '998',
  'Hung' => '176',
  'Sarb' => '105',
  'Shrd' => '319',
  'Bass' => '259',
  'Loma' => '437',
  'Dupl' => '755',
  'Phnx' => '115',
  'Hang' => '286',
  'Elym' => '128',
  'Hmnp' => '451',
  'Sylo' => '316',
  'Phlp' => '132',
  'Kore' => '287',
  'Olck' => '261',
  'Sogd' => '141',
  'Khoj' => '322',
  'Gonm' => '313',
  'Syrj' => '137',
  'Hluw' => '080',
  'Phli' => '131',
  'Cirt' => '291',
  'Gran' => '343',
  'Dogr' => '328',
  'Lana' => '351',
  'Zsye' => '993',
  'Mult' => '323',
  'Maka' => '366',
  'Avst' => '134',
  'Syrc' => '135',
  'Leke' => '364',
  'Xsux' => '020',
  'Taml' => '346',
  'Diak' => '342',
  'Tang' => '520',
  'Qaaa' => '900',
  'Hani' => '500',
  'Brai' => '570',
  'Beng' => '325',
  'Khmr' => '355',
  'Sara' => '292',
  'Kits' => '288',
  'Cans' => '440',
  'Narb' => '106',
  'Piqd' => '293',
  'Mero' => '100',
  'Nkoo' => '165',
  'Sund' => '362',
  'Nbat' => '159',
  'Afak' => '439',
  'Egyp' => '050',
  'Tagb' => '373',
  'Ahom' => '338',
  'Merc' => '101',
  'Toto' => '294',
  'Glag' => '225',
  'Hebr' => '125',
  'Yezi' => '192',
  'Orya' => '327',
  'Saur' => '344',
  'Kana' => '411',
  'Wole' => '480',
  'Lisu' => '399',
  'Mend' => '438',
  'Nshu' => '499',
  'Zanb' => '339',
  'Dsrt' => '250',
  'Wcho' => '283',
  'Adlm' => '166',
  'Sgnw' => '095',
  'Cakm' => '349',
  'Palm' => '126',
  'Tibt' => '330',
  'Mroo' => '264',
  'Kthi' => '317',
  'Newa' => '333',
  'Blis' => '550',
  'Limb' => '336',
  'Egyh' => '060',
  'Tirh' => '326',
  'Kitl' => '505',
  'Yiii' => '460',
  'Orkh' => '175',
  'Armi' => '124',
  'Aran' => '161',
  'Lyci' => '202',
  'Goth' => '206',
  'Xpeo' => '030',
  'Qabx' => '949',
  'Tfng' => '120',
  'Maya' => '090',
  'Rohg' => '167',
  'Aghb' => '239',
  'Sinh' => '348',
  'Brah' => '300',
  'Telu' => '340',
  'Batk' => '365',
  'Lepc' => '335',
  'Medf' => '265',
  'Hans' => '501',
  'Buhd' => '372',
  'Ugar' => '040',
  'Moon' => '218',
  'Java' => '361',
  'Egyd' => '070',
  'Elba' => '226',
  'Zmth' => '995',
  'Sidd' => '302',
  'Zinh' => '994',
  'Grek' => '200',
  'Gujr' => '320',
  'Tale' => '353',
  'Shui' => '530',
  'Hant' => '502',
  'Tglg' => '370',
  'Thai' => '352',
  'Osge' => '219',
  'Cari' => '201',
  'Bhks' => '334',
  'Mlym' => '347',
  'Hatr' => '127',
  'Pauc' => '263',
  'Hira' => '410',
  'Marc' => '332',
  'Thaa' => '170',
  'Chrs' => '109',
  'Tavt' => '359',
  'Jurc' => '510',
  'Nkdb' => '085',
  'Inds' => '610',
  'Mani' => '139',
  'Latf' => '217',
  'Bali' => '360',
  'Cprt' => '403',
  'Perm' => '227',
  'Syre' => '138',
  'Copt' => '204',
  'Soyo' => '329',
  'Sind' => '318',
  'Roro' => '620',
  'Phag' => '331',
  'Geok' => '241',
  'Nkgb' => '420',
  'Zxxx' => '997',
  'Ogam' => '212',
  'Cpmn' => '402',
  'Zzzz' => '999',
  'Prti' => '130',
  'Rjng' => '363',
  'Hanb' => '503',
  'Nand' => '311',
  'Takr' => '321',
  'Hrkt' => '412',
  'Sogo' => '142',
  'Arab' => '160',
  'Shaw' => '281',
  'Guru' => '310',
  'Jpan' => '413',
  'Talu' => '354',
  'Samr' => '123',
  'Armn' => '230',
  'Ital' => '210',
  'Bopo' => '285',
  'Osma' => '260',
  'Syrn' => '136',
  'Knda' => '345',
  'Khar' => '305',
  'Hmng' => '450',
  'Vaii' => '470',
  'Deva' => '315',
  'Teng' => '290',
  'Mand' => '140',
  'Modi' => '324',
  'Bamu' => '435',
  'Visp' => '280',
  'Ethi' => '430',
  'Laoo' => '356',
  'Lina' => '400',
  'Cham' => '358',
  'Bugi' => '367',
  'Cyrs' => '221',
  'Phlv' => '133',
  'Zsym' => '996',
  'Lydi' => '116',
  'Linb' => '401',
  'Kpel' => '436',
  'Kali' => '357',
  'Mahj' => '314',
  'Mong' => '145',
  'Plrd' => '282',
  'Runr' => '211',
  'Wara' => '262',
  'Mymr' => '350',
  'Jamo' => '284',
  'Gong' => '312',
  'Cher' => '445',
  'Latn' => '215',
  'Geor' => '240',
  'Cyrl' => '220',
  'Hano' => '371',
  'Sora' => '398'
};
$Lang2Territory = {
  'suk' => {
    'TZ' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'tel' => {
    'IN' => 2
  },
  'tig' => {
    'ER' => 2
  },
  'afr' => {
    'NA' => 2,
    'ZA' => 2
  },
  'sot' => {
    'LS' => 1,
    'ZA' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'sas' => {
    'ID' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'gqr' => {
    'ID' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'aeb' => {
    'TN' => 2
  },
  'gsw' => {
    'CH' => 1,
    'DE' => 2,
    'LI' => 1
  },
  'unr' => {
    'IN' => 2
  },
  'hil' => {
    'PH' => 2
  },
  'laj' => {
    'UG' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'hoc' => {
    'IN' => 2
  },
  'mzn' => {
    'IR' => 2
  },
  'swb' => {
    'YT' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'mdh' => {
    'PH' => 2
  },
  'shn' => {
    'MM' => 2
  },
  'amh' => {
    'ET' => 1
  },
  'bgn' => {
    'PK' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'kab' => {
    'DZ' => 2
  },
  'glg' => {
    'ES' => 2
  },
  'tnr' => {
    'SN' => 2
  },
  'hif' => {
    'FJ' => 1
  },
  'sme' => {
    'NO' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'fry' => {
    'NL' => 2
  },
  'bis' => {
    'VU' => 1
  },
  'kon' => {
    'CD' => 2
  },
  'kaz' => {
    'KZ' => 1,
    'CN' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'mad' => {
    'ID' => 2
  },
  'srp' => {
    'RS' => 1,
    'XK' => 1,
    'ME' => 1,
    'BA' => 1
  },
  'guz' => {
    'KE' => 2
  },
  'awa' => {
    'IN' => 2
  },
  'ben' => {
    'IN' => 2,
    'BD' => 1
  },
  'fan' => {
    'GQ' => 2
  },
  'jav' => {
    'ID' => 2
  },
  'zha' => {
    'CN' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'ori' => {
    'IN' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'doi' => {
    'IN' => 2
  },
  'bal' => {
    'PK' => 2,
    'IR' => 2,
    'AF' => 2
  },
  'tir' => {
    'ER' => 1,
    'ET' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'cat' => {
    'AD' => 1,
    'ES' => 2
  },
  'som' => {
    'DJ' => 2,
    'SO' => 1,
    'ET' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'gom' => {
    'IN' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'ibo' => {
    'NG' => 2
  },
  'tah' => {
    'PF' => 1
  },
  'ary' => {
    'MA' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'che' => {
    'RU' => 2
  },
  'ltz' => {
    'LU' => 1
  },
  'tso' => {
    'ZA' => 2,
    'MZ' => 2
  },
  'mfv' => {
    'SN' => 2
  },
  'swa' => {
    'UG' => 1,
    'TZ' => 1,
    'KE' => 1,
    'CD' => 2
  },
  'glv' => {
    'IM' => 1
  },
  'ven' => {
    'ZA' => 2
  },
  'mlt' => {
    'MT' => 1
  },
  'ton' => {
    'TO' => 1
  },
  'kum' => {
    'RU' => 2
  },
  'mnu' => {
    'KE' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'fij' => {
    'FJ' => 1
  },
  'hoj' => {
    'IN' => 2
  },
  'pau' => {
    'PW' => 1
  },
  'kkt' => {
    'RU' => 2
  },
  'tsn' => {
    'ZA' => 2,
    'BW' => 1
  },
  'nob' => {
    'SJ' => 1,
    'NO' => 1
  },
  'kor' => {
    'KR' => 1,
    'US' => 2,
    'CN' => 2,
    'KP' => 1
  },
  'lez' => {
    'RU' => 2
  },
  'bin' => {
    'NG' => 2
  },
  'rus' => {
    'KG' => 1,
    'KZ' => 1,
    'SJ' => 2,
    'DE' => 2,
    'UA' => 1,
    'RU' => 1,
    'BY' => 1,
    'LT' => 2,
    'BG' => 2,
    'LV' => 2,
    'UZ' => 2,
    'TJ' => 2,
    'EE' => 2,
    'PL' => 2
  },
  'run' => {
    'BI' => 1
  },
  'tpi' => {
    'PG' => 1
  },
  'kok' => {
    'IN' => 2
  },
  'sus' => {
    'GN' => 2
  },
  'tzm' => {
    'MA' => 1
  },
  'pol' => {
    'UA' => 2,
    'PL' => 1
  },
  'grn' => {
    'PY' => 1
  },
  'bho' => {
    'IN' => 2,
    'NP' => 2,
    'MU' => 2
  },
  'bmv' => {
    'CM' => 2
  },
  'aym' => {
    'BO' => 1
  },
  'kom' => {
    'RU' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'hye' => {
    'RU' => 2,
    'AM' => 1
  },
  'gcr' => {
    'GF' => 2
  },
  'kin' => {
    'RW' => 1
  },
  'nld' => {
    'SR' => 1,
    'NL' => 1,
    'CW' => 1,
    'BQ' => 1,
    'AW' => 1,
    'DE' => 2,
    'BE' => 1,
    'SX' => 1
  },
  'lat' => {
    'VA' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'crs' => {
    'SC' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'snk' => {
    'ML' => 2
  },
  'syl' => {
    'BD' => 2
  },
  'kur' => {
    'IQ' => 2,
    'SY' => 2,
    'TR' => 2,
    'IR' => 2
  },
  'bjn' => {
    'ID' => 2
  },
  'man' => {
    'GN' => 2,
    'GM' => 2
  },
  'brh' => {
    'PK' => 2
  },
  'mni' => {
    'IN' => 2
  },
  'kal' => {
    'GL' => 1,
    'DK' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'lah' => {
    'PK' => 2
  },
  'oci' => {
    'FR' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'ara' => {
    'IL' => 1,
    'YE' => 1,
    'KM' => 1,
    'SO' => 1,
    'TN' => 1,
    'KW' => 1,
    'MR' => 1,
    'AE' => 1,
    'QA' => 1,
    'EG' => 2,
    'TD' => 1,
    'SY' => 1,
    'PS' => 1,
    'DJ' => 1,
    'DZ' => 2,
    'EH' => 1,
    'SD' => 1,
    'IQ' => 1,
    'LB' => 1,
    'SS' => 2,
    'SA' => 1,
    'MA' => 2,
    'IR' => 2,
    'OM' => 1,
    'JO' => 1,
    'ER' => 1,
    'LY' => 1,
    'BH' => 1
  },
  'sav' => {
    'SN' => 2
  },
  'aln' => {
    'XK' => 2
  },
  'dje' => {
    'NE' => 2
  },
  'xog' => {
    'UG' => 2
  },
  'tum' => {
    'MW' => 2
  },
  'swe' => {
    'AX' => 1,
    'SE' => 1,
    'FI' => 1
  },
  'ngl' => {
    'MZ' => 2
  },
  'buc' => {
    'YT' => 2
  },
  'bgc' => {
    'IN' => 2
  },
  'est' => {
    'EE' => 1
  },
  'hin' => {
    'FJ' => 2,
    'ZA' => 2,
    'IN' => 1
  },
  'ttb' => {
    'GH' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'rif' => {
    'MA' => 2
  },
  'lua' => {
    'CD' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'vls' => {
    'BE' => 2
  },
  'gan' => {
    'CN' => 2
  },
  'bem' => {
    'ZM' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'slv' => {
    'AT' => 2,
    'SI' => 1
  },
  'sef' => {
    'CI' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'pap' => {
    'BQ' => 2,
    'AW' => 1,
    'CW' => 1
  },
  'khm' => {
    'KH' => 1
  },
  'kbd' => {
    'RU' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'heb' => {
    'IL' => 1
  },
  'bak' => {
    'RU' => 2
  },
  'ceb' => {
    'PH' => 2
  },
  'nep' => {
    'IN' => 2,
    'NP' => 1
  },
  'sid' => {
    'ET' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'yue' => {
    'CN' => 2,
    'HK' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'bej' => {
    'SD' => 2
  },
  'rmt' => {
    'IR' => 2
  },
  'srd' => {
    'IT' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'bul' => {
    'BG' => 1
  },
  'lug' => {
    'UG' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'lin' => {
    'CD' => 2
  },
  'smo' => {
    'AS' => 1,
    'WS' => 1
  },
  'dyu' => {
    'BF' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'ron' => {
    'RO' => 1,
    'MD' => 1,
    'RS' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'tiv' => {
    'NG' => 2
  },
  'nya' => {
    'ZM' => 2,
    'MW' => 1
  },
  'slk' => {
    'CZ' => 2,
    'SK' => 1,
    'RS' => 2
  },
  'rej' => {
    'ID' => 2
  },
  'tat' => {
    'RU' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'mdf' => {
    'RU' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'bug' => {
    'ID' => 2
  },
  'lao' => {
    'LA' => 1
  },
  'myx' => {
    'UG' => 2
  },
  'deu' => {
    'US' => 2,
    'NL' => 2,
    'CH' => 1,
    'BE' => 1,
    'SK' => 2,
    'KZ' => 2,
    'BR' => 2,
    'SI' => 2,
    'FR' => 2,
    'DK' => 2,
    'GB' => 2,
    'CZ' => 2,
    'PL' => 2,
    'AT' => 1,
    'DE' => 1,
    'LU' => 1,
    'LI' => 1,
    'HU' => 2
  },
  'tam' => {
    'SG' => 1,
    'MY' => 2,
    'LK' => 1,
    'IN' => 2
  },
  'bar' => {
    'AT' => 2,
    'DE' => 2
  },
  'tuk' => {
    'AF' => 2,
    'TM' => 1,
    'IR' => 2
  },
  'fvr' => {
    'SD' => 2
  },
  'wuu' => {
    'CN' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'fin' => {
    'FI' => 1,
    'EE' => 2,
    'SE' => 2
  },
  'noe' => {
    'IN' => 2
  },
  'nbl' => {
    'ZA' => 2
  },
  'fuv' => {
    'NG' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'mwr' => {
    'IN' => 2
  },
  'zgh' => {
    'MA' => 2
  },
  'kde' => {
    'TZ' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'min' => {
    'ID' => 2
  },
  'fra' => {
    'GB' => 2,
    'CF' => 1,
    'IT' => 2,
    'CG' => 1,
    'TF' => 2,
    'RE' => 1,
    'RW' => 1,
    'PT' => 2,
    'NC' => 1,
    'MC' => 1,
    'MQ' => 1,
    'PF' => 1,
    'NL' => 2,
    'CH' => 1,
    'MF' => 1,
    'BI' => 1,
    'GF' => 1,
    'WF' => 1,
    'DJ' => 1,
    'DZ' => 1,
    'SY' => 1,
    'TD' => 1,
    'HT' => 1,
    'RO' => 2,
    'CM' => 1,
    'BJ' => 1,
    'SN' => 1,
    'GQ' => 1,
    'MA' => 1,
    'MG' => 1,
    'MU' => 1,
    'BF' => 1,
    'TG' => 1,
    'CI' => 1,
    'NE' => 1,
    'LU' => 1,
    'DE' => 2,
    'TN' => 1,
    'ML' => 1,
    'CD' => 1,
    'CA' => 1,
    'GP' => 1,
    'KM' => 1,
    'VU' => 1,
    'BL' => 1,
    'GN' => 1,
    'US' => 2,
    'GA' => 1,
    'BE' => 1,
    'SC' => 1,
    'YT' => 1,
    'FR' => 1,
    'PM' => 1
  },
  'tcy' => {
    'IN' => 2
  },
  'tet' => {
    'TL' => 1
  },
  'inh' => {
    'RU' => 2
  },
  'nor' => {
    'NO' => 1,
    'SJ' => 1
  },
  'myv' => {
    'RU' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'sna' => {
    'ZW' => 1
  },
  'uig' => {
    'CN' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'glk' => {
    'IR' => 2
  },
  'nyn' => {
    'UG' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'dan' => {
    'DE' => 2,
    'DK' => 1
  },
  'bos' => {
    'BA' => 1
  },
  'gla' => {
    'GB' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'ssw' => {
    'SZ' => 1,
    'ZA' => 2
  },
  'bhi' => {
    'IN' => 2
  },
  'tvl' => {
    'TV' => 1
  },
  'bqi' => {
    'IR' => 2
  },
  'pmn' => {
    'PH' => 2
  },
  'sat' => {
    'IN' => 2
  },
  'aze' => {
    'RU' => 2,
    'IR' => 2,
    'IQ' => 2,
    'AZ' => 1
  },
  'raj' => {
    'IN' => 2
  },
  'kea' => {
    'CV' => 2
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'hsn' => {
    'CN' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'ita' => {
    'SM' => 1,
    'FR' => 2,
    'DE' => 2,
    'VA' => 1,
    'IT' => 1,
    'US' => 2,
    'CH' => 1,
    'MT' => 2,
    'HR' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'wbr' => {
    'IN' => 2
  },
  'mfa' => {
    'TH' => 2
  },
  'men' => {
    'SL' => 2
  },
  'khn' => {
    'IN' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'bjt' => {
    'SN' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'rkt' => {
    'BD' => 2,
    'IN' => 2
  },
  'bam' => {
    'ML' => 2
  },
  'hun' => {
    'RO' => 2,
    'HU' => 1,
    'RS' => 2,
    'AT' => 2
  },
  'kdx' => {
    'KE' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'eus' => {
    'ES' => 2
  },
  'gon' => {
    'IN' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'nym' => {
    'TZ' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'fil' => {
    'PH' => 1,
    'US' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'msa' => {
    'ID' => 2,
    'CC' => 2,
    'BN' => 1,
    'SG' => 1,
    'MY' => 1,
    'TH' => 2
  },
  'gle' => {
    'GB' => 2,
    'IE' => 1
  },
  'kik' => {
    'KE' => 2
  },
  'shr' => {
    'MA' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'nno' => {
    'NO' => 1
  },
  'lbe' => {
    'RU' => 2
  },
  'kdh' => {
    'SL' => 2
  },
  'orm' => {
    'ET' => 2
  },
  'sah' => {
    'RU' => 2
  },
  'hau' => {
    'NG' => 2,
    'NE' => 2
  },
  'uzb' => {
    'AF' => 2,
    'UZ' => 1
  },
  'kfy' => {
    'IN' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'war' => {
    'PH' => 2
  },
  'tha' => {
    'TH' => 1
  },
  'hbs' => {
    'ME' => 1,
    'BA' => 1,
    'XK' => 1,
    'SI' => 2,
    'RS' => 1,
    'HR' => 1,
    'AT' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'nod' => {
    'TH' => 2
  },
  'iii' => {
    'CN' => 2
  },
  'und' => {
    'AQ' => 2,
    'CP' => 2,
    'GS' => 2,
    'BV' => 2,
    'HM' => 2
  },
  'tyv' => {
    'RU' => 2
  },
  'san' => {
    'IN' => 2
  },
  'mya' => {
    'MM' => 1
  },
  'abr' => {
    'GH' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'haw' => {
    'US' => 2
  },
  'ban' => {
    'ID' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'bew' => {
    'ID' => 2
  },
  'ibb' => {
    'NG' => 2
  },
  'hne' => {
    'IN' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'mak' => {
    'ID' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'kir' => {
    'KG' => 1
  },
  'que' => {
    'PE' => 1,
    'BO' => 1,
    'EC' => 1
  },
  'pan' => {
    'IN' => 2,
    'PK' => 2
  },
  'haz' => {
    'AF' => 2
  },
  'xho' => {
    'ZA' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'yor' => {
    'NG' => 1
  },
  'zho' => {
    'ID' => 2,
    'CN' => 1,
    'US' => 2,
    'TW' => 1,
    'VN' => 2,
    'MO' => 1,
    'TH' => 2,
    'HK' => 1,
    'SG' => 1,
    'MY' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'krc' => {
    'RU' => 2
  },
  'ckb' => {
    'IQ' => 2,
    'IR' => 2
  },
  'seh' => {
    'MZ' => 2
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'ewe' => {
    'GH' => 2,
    'TG' => 2
  },
  'hrv' => {
    'RS' => 2,
    'HR' => 1,
    'AT' => 2,
    'BA' => 1,
    'SI' => 2
  },
  'skr' => {
    'PK' => 2
  },
  'bod' => {
    'CN' => 2
  },
  'ilo' => {
    'PH' => 2
  },
  'dnj' => {
    'CI' => 2
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'por' => {
    'TL' => 1,
    'GW' => 1,
    'CV' => 1,
    'MZ' => 1,
    'AO' => 1,
    'GQ' => 1,
    'PT' => 1,
    'BR' => 1,
    'ST' => 1,
    'MO' => 1
  },
  'hno' => {
    'PK' => 2
  },
  'hmo' => {
    'PG' => 1
  },
  'zdj' => {
    'KM' => 1
  },
  'sag' => {
    'CF' => 1
  },
  'udm' => {
    'RU' => 2
  },
  'snd' => {
    'PK' => 2,
    'IN' => 2
  },
  'wol' => {
    'SN' => 1
  },
  'arz' => {
    'EG' => 2
  },
  'ful' => {
    'GN' => 2,
    'SN' => 2,
    'NE' => 2,
    'NG' => 2,
    'ML' => 2
  },
  'srn' => {
    'SR' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'gil' => {
    'KI' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'nds' => {
    'NL' => 2,
    'DE' => 2
  },
  'brx' => {
    'IN' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'kha' => {
    'IN' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'fud' => {
    'WF' => 2
  },
  'sqi' => {
    'RS' => 2,
    'MK' => 2,
    'XK' => 1,
    'AL' => 1
  },
  'ach' => {
    'UG' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'fas' => {
    'AF' => 1,
    'PK' => 2,
    'IR' => 1
  },
  'gbm' => {
    'IN' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'fuq' => {
    'NE' => 2
  },
  'fao' => {
    'FO' => 1
  },
  'mfe' => {
    'MU' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'ukr' => {
    'UA' => 1,
    'RS' => 2
  },
  'eng' => {
    'UG' => 1,
    'AI' => 1,
    'SH' => 1,
    'DG' => 1,
    'CA' => 1,
    'IN' => 1,
    'MH' => 1,
    'SC' => 1,
    'BE' => 2,
    'GM' => 1,
    'MU' => 1,
    'GU' => 1,
    'AC' => 2,
    'DM' => 1,
    'NZ' => 1,
    'FK' => 1,
    'BB' => 1,
    'BZ' => 1,
    'EE' => 2,
    'BI' => 1,
    'IL' => 2,
    'CM' => 1,
    'AR' => 2,
    'ZW' => 1,
    'KZ' => 2,
    'LS' => 1,
    'KY' => 1,
    'TZ' => 1,
    'GB' => 1,
    'KN' => 1,
    'IM' => 1,
    'CK' => 1,
    'MP' => 1,
    'TC' => 1,
    'BS' => 1,
    'ER' => 1,
    'UM' => 1,
    'YE' => 2,
    'NG' => 1,
    'VG' => 1,
    'TO' => 1,
    'CC' => 1,
    'PR' => 1,
    'MA' => 2,
    'IE' => 1,
    'NF' => 1,
    'GH' => 1,
    'SE' => 2,
    'DE' => 2,
    'AS' => 1,
    'LU' => 2,
    'CH' => 2,
    'NL' => 2,
    'BD' => 2,
    'CY' => 2,
    'BR' => 2,
    'GD' => 1,
    'LK' => 2,
    'WS' => 1,
    'LB' => 2,
    'SX' => 1,
    'BW' => 1,
    'PK' => 1,
    'MX' => 2,
    'JM' => 1,
    'AU' => 1,
    'SS' => 1,
    'TA' => 2,
    'KE' => 1,
    'RW' => 1,
    'MW' => 1,
    'ET' => 2,
    'VU' => 1,
    'FM' => 1,
    'ES' => 2,
    'LT' => 2,
    'BA' => 2,
    'FR' => 2,
    'GI' => 1,
    'EG' => 2,
    'SK' => 2,
    'PL' => 2,
    'ZA' => 1,
    'IO' => 1,
    'TT' => 1,
    'HK' => 1,
    'SL' => 1,
    'NR' => 1,
    'KI' => 1,
    'TK' => 1,
    'MS' => 1,
    'ZM' => 1,
    'MT' => 1,
    'TV' => 1,
    'SI' => 2,
    'FJ' => 1,
    'CZ' => 2,
    'VC' => 1,
    'PH' => 1,
    'HR' => 2,
    'GG' => 1,
    'PN' => 1,
    'HU' => 2,
    'IT' => 2,
    'FI' => 2,
    'US' => 1,
    'PW' => 1,
    'BM' => 1,
    'LC' => 1,
    'TR' => 2,
    'GR' => 2,
    'SD' => 1,
    'IQ' => 2,
    'CL' => 2,
    'SB' => 1,
    'MG' => 1,
    'AG' => 1,
    'BG' => 2,
    'TH' => 2,
    'CX' => 1,
    'AT' => 2,
    'JO' => 2,
    'SZ' => 1,
    'AE' => 2,
    'PG' => 1,
    'SG' => 1,
    'VI' => 1,
    'RO' => 2,
    'DZ' => 2,
    'LR' => 1,
    'DK' => 2,
    'NA' => 1,
    'JE' => 1,
    'MY' => 2,
    'PT' => 2,
    'NU' => 1,
    'LV' => 2,
    'GY' => 1
  },
  'bsc' => {
    'SN' => 2
  },
  'spa' => {
    'GT' => 1,
    'AR' => 1,
    'RO' => 2,
    'CR' => 1,
    'PA' => 1,
    'PT' => 2,
    'UY' => 1,
    'PH' => 2,
    'PY' => 1,
    'MX' => 1,
    'VE' => 1,
    'CL' => 1,
    'PE' => 1,
    'SV' => 1,
    'GI' => 2,
    'FR' => 2,
    'ES' => 1,
    'US' => 2,
    'EA' => 1,
    'EC' => 1,
    'HN' => 1,
    'DE' => 2,
    'DO' => 1,
    'NI' => 1,
    'BZ' => 2,
    'IC' => 1,
    'BO' => 1,
    'CU' => 1,
    'GQ' => 1,
    'PR' => 1,
    'AD' => 2,
    'CO' => 1
  },
  'vmw' => {
    'MZ' => 2
  },
  'tur' => {
    'CY' => 1,
    'TR' => 1,
    'DE' => 2
  },
  'ces' => {
    'SK' => 2,
    'CZ' => 1
  },
  'mag' => {
    'IN' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'kmb' => {
    'AO' => 2
  },
  'dzo' => {
    'BT' => 1
  },
  'arq' => {
    'DZ' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'mai' => {
    'IN' => 2,
    'NP' => 2
  },
  'sck' => {
    'IN' => 2
  },
  'fon' => {
    'BJ' => 2
  },
  'mon' => {
    'CN' => 2,
    'MN' => 1
  },
  'mos' => {
    'BF' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'luz' => {
    'IR' => 2
  },
  'sqq' => {
    'TH' => 2
  },
  'div' => {
    'MV' => 1
  },
  'dyo' => {
    'SN' => 2
  },
  'ell' => {
    'CY' => 1,
    'GR' => 1
  }
};
$Lang2Script = {
  'ria' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'guz' => {
    'Latn' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'amo' => {
    'Latn' => 1
  },
  'xsr' => {
    'Deva' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'nzi' => {
    'Latn' => 1
  },
  'lui' => {
    'Latn' => 2
  },
  'sga' => {
    'Latn' => 2,
    'Ogam' => 2
  },
  'zha' => {
    'Hans' => 2,
    'Latn' => 1
  },
  'jav' => {
    'Java' => 2,
    'Latn' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'xum' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'phn' => {
    'Phnx' => 2
  },
  'cha' => {
    'Latn' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'ndo' => {
    'Latn' => 1
  },
  'chp' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'iku' => {
    'Latn' => 1,
    'Cans' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'guj' => {
    'Gujr' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'rcf' => {
    'Latn' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'zap' => {
    'Latn' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'thq' => {
    'Deva' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'mnu' => {
    'Latn' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'ina' => {
    'Latn' => 2
  },
  'pko' => {
    'Latn' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'mgp' => {
    'Deva' => 1
  },
  'kor' => {
    'Kore' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'afr' => {
    'Latn' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'vic' => {
    'Latn' => 1
  },
  'gqr' => {
    'Latn' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'unr' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'kri' => {
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'hai' => {
    'Latn' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'gay' => {
    'Latn' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'amh' => {
    'Ethi' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'jml' => {
    'Deva' => 1
  },
  'tly' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'sme' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'mri' => {
    'Latn' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'bez' => {
    'Latn' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'hin' => {
    'Mahj' => 2,
    'Latn' => 2,
    'Deva' => 1
  },
  'ind' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'khw' => {
    'Arab' => 1
  },
  'anp' => {
    'Deva' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'bem' => {
    'Latn' => 1
  },
  'chu' => {
    'Cyrl' => 2
  },
  'mwl' => {
    'Latn' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'slv' => {
    'Latn' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'xav' => {
    'Latn' => 1
  },
  'vmf' => {
    'Latn' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'maz' => {
    'Latn' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'ron' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'xpr' => {
    'Prti' => 2
  },
  'dak' => {
    'Latn' => 1
  },
  'bjj' => {
    'Deva' => 1
  },
  'cjm' => {
    'Cham' => 1,
    'Arab' => 2
  },
  'rus' => {
    'Cyrl' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'run' => {
    'Latn' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'frp' => {
    'Latn' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'kom' => {
    'Cyrl' => 1,
    'Perm' => 2
  },
  'zza' => {
    'Latn' => 1
  },
  'tog' => {
    'Latn' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'nld' => {
    'Latn' => 1
  },
  'kin' => {
    'Latn' => 1
  },
  'ltg' => {
    'Latn' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'syl' => {
    'Sylo' => 2,
    'Beng' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'dsb' => {
    'Latn' => 1
  },
  'mni' => {
    'Beng' => 1,
    'Mtei' => 2
  },
  'rue' => {
    'Cyrl' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'ccp' => {
    'Cakm' => 1,
    'Beng' => 1
  },
  'lah' => {
    'Arab' => 1
  },
  'byn' => {
    'Ethi' => 1
  },
  'lag' => {
    'Latn' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'crj' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'aze' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'pmn' => {
    'Latn' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'cic' => {
    'Latn' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'hsn' => {
    'Hans' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'tkr' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'men' => {
    'Latn' => 1,
    'Mend' => 2
  },
  'sdc' => {
    'Latn' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'rkt' => {
    'Beng' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'hun' => {
    'Latn' => 1
  },
  'bft' => {
    'Arab' => 1,
    'Tibt' => 2
  },
  'xsa' => {
    'Sarb' => 2
  },
  'rmf' => {
    'Latn' => 1
  },
  'bam' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'pms' => {
    'Latn' => 1
  },
  'urd' => {
    'Arab' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'pnt' => {
    'Latn' => 1,
    'Grek' => 1,
    'Cyrl' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'mua' => {
    'Latn' => 1
  },
  'nov' => {
    'Latn' => 2
  },
  'nym' => {
    'Latn' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'gon' => {
    'Deva' => 1,
    'Telu' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'rej' => {
    'Latn' => 1,
    'Rjng' => 2
  },
  'slk' => {
    'Latn' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'bug' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'grt' => {
    'Beng' => 1
  },
  'gba' => {
    'Latn' => 1
  },
  'cho' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'tuk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'lzz' => {
    'Geor' => 1,
    'Latn' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'zgh' => {
    'Tfng' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'min' => {
    'Latn' => 1
  },
  'bbc' => {
    'Latn' => 1,
    'Batk' => 2
  },
  'ale' => {
    'Latn' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'abw' => {
    'Phlp' => 2,
    'Phli' => 2
  },
  'yao' => {
    'Latn' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'new' => {
    'Deva' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'ssy' => {
    'Latn' => 1
  },
  'crh' => {
    'Cyrl' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'bos' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'bqi' => {
    'Arab' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'bto' => {
    'Latn' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'ssw' => {
    'Latn' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'udm' => {
    'Cyrl' => 1,
    'Latn' => 2
  },
  'yua' => {
    'Latn' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'wol' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'dng' => {
    'Cyrl' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'kht' => {
    'Mymr' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'kha' => {
    'Beng' => 2,
    'Latn' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'hmn' => {
    'Laoo' => 1,
    'Latn' => 1,
    'Plrd' => 1,
    'Hmng' => 2
  },
  'fao' => {
    'Latn' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'eng' => {
    'Shaw' => 2,
    'Dsrt' => 2,
    'Latn' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'ain' => {
    'Latn' => 2,
    'Kana' => 2
  },
  'kmb' => {
    'Latn' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'rar' => {
    'Latn' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'nnh' => {
    'Latn' => 1
  },
  'sck' => {
    'Deva' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'mon' => {
    'Mong' => 2,
    'Cyrl' => 1,
    'Phag' => 2
  },
  'fon' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'dyo' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'crl' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'shr' => {
    'Tfng' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'msa' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'orm' => {
    'Ethi' => 2,
    'Latn' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'bra' => {
    'Deva' => 1
  },
  'bub' => {
    'Cyrl' => 1
  },
  'hau' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'uzb' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'non' => {
    'Runr' => 2
  },
  'kat' => {
    'Geor' => 1
  },
  'kan' => {
    'Knda' => 1
  },
  'hbs' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'arc' => {
    'Palm' => 2,
    'Nbat' => 2,
    'Armi' => 2
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'mdt' => {
    'Latn' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'ban' => {
    'Bali' => 2,
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'aoz' => {
    'Latn' => 1
  },
  'ibb' => {
    'Latn' => 1
  },
  'bku' => {
    'Latn' => 1,
    'Buhd' => 2
  },
  'bew' => {
    'Latn' => 1
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'mak' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'vai' => {
    'Latn' => 1,
    'Vaii' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'pan' => {
    'Guru' => 1,
    'Arab' => 1
  },
  'yor' => {
    'Latn' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'dtm' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'zho' => {
    'Hans' => 1,
    'Phag' => 2,
    'Hant' => 1,
    'Bopo' => 2
  },
  'dty' => {
    'Deva' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'stq' => {
    'Latn' => 1
  },
  'atj' => {
    'Latn' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'rom' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'kaz' => {
    'Arab' => 1,
    'Cyrl' => 1
  },
  'ave' => {
    'Avst' => 2
  },
  'mrd' => {
    'Deva' => 1
  },
  'srp' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'mdr' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'ett' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'nus' => {
    'Latn' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'kaj' => {
    'Latn' => 1
  },
  'doi' => {
    'Deva' => 1,
    'Takr' => 2,
    'Arab' => 1
  },
  'kas' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'ori' => {
    'Orya' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'bmq' => {
    'Latn' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'som' => {
    'Latn' => 1,
    'Arab' => 2,
    'Osma' => 2
  },
  'bal' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'tir' => {
    'Ethi' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'lfn' => {
    'Cyrl' => 2,
    'Latn' => 2
  },
  'ary' => {
    'Arab' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'tso' => {
    'Latn' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'grc' => {
    'Grek' => 2,
    'Cprt' => 2,
    'Linb' => 2
  },
  'swa' => {
    'Latn' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'kum' => {
    'Cyrl' => 1
  },
  'ven' => {
    'Latn' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'hnn' => {
    'Hano' => 2,
    'Latn' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'kkt' => {
    'Cyrl' => 1
  },
  'egy' => {
    'Egyp' => 2
  },
  'pau' => {
    'Latn' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'tdd' => {
    'Tale' => 1
  },
  'swg' => {
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'sot' => {
    'Latn' => 1
  },
  'sas' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'hil' => {
    'Latn' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'mxc' => {
    'Latn' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'swb' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'laj' => {
    'Latn' => 1
  },
  'mtr' => {
    'Deva' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'moh' => {
    'Latn' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'avk' => {
    'Latn' => 2
  },
  'kfo' => {
    'Latn' => 1
  },
  'mdh' => {
    'Latn' => 1
  },
  'srx' => {
    'Deva' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'glg' => {
    'Latn' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'hif' => {
    'Latn' => 1,
    'Deva' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'kon' => {
    'Latn' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'bis' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'srb' => {
    'Latn' => 1,
    'Sora' => 2
  },
  'crk' => {
    'Cans' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'lua' => {
    'Latn' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'sxn' => {
    'Latn' => 1
  },
  'rif' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'ttb' => {
    'Latn' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'byv' => {
    'Latn' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'ttt' => {
    'Cyrl' => 1,
    'Arab' => 2,
    'Latn' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'kyu' => {
    'Kali' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'wln' => {
    'Latn' => 1
  },
  'sid' => {
    'Latn' => 1
  },
  'kln' => {
    'Latn' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'dav' => {
    'Latn' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'yue' => {
    'Hans' => 1,
    'Hant' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'mro' => {
    'Mroo' => 2,
    'Latn' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'yap' => {
    'Latn' => 1
  },
  'thl' => {
    'Deva' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'kgp' => {
    'Latn' => 1
  },
  'srd' => {
    'Latn' => 1
  },
  'wbp' => {
    'Latn' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'mas' => {
    'Latn' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'sly' => {
    'Latn' => 1
  },
  'ttj' => {
    'Latn' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'lez' => {
    'Cyrl' => 1,
    'Aghb' => 2
  },
  'bfy' => {
    'Deva' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'lki' => {
    'Arab' => 1
  },
  'lim' => {
    'Latn' => 1
  },
  'uga' => {
    'Ugar' => 2
  },
  'prd' => {
    'Arab' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'gju' => {
    'Arab' => 1
  },
  'grn' => {
    'Latn' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'tzm' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'sus' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'tsd' => {
    'Grek' => 1
  },
  'aym' => {
    'Latn' => 1
  },
  'bmv' => {
    'Latn' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'gcr' => {
    'Latn' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'oji' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'frr' => {
    'Latn' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'kur' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'nsk' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'brh' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'man' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'oci' => {
    'Latn' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'aln' => {
    'Latn' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'tum' => {
    'Latn' => 1
  },
  'rug' => {
    'Latn' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'sat' => {
    'Beng' => 2,
    'Latn' => 2,
    'Deva' => 2,
    'Olck' => 1,
    'Orya' => 2
  },
  'kua' => {
    'Latn' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'lit' => {
    'Latn' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'syr' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'lcp' => {
    'Thai' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'wbr' => {
    'Deva' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'ava' => {
    'Cyrl' => 1
  },
  'kdx' => {
    'Latn' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'bfd' => {
    'Latn' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'nde' => {
    'Latn' => 1
  },
  'den' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'bzx' => {
    'Latn' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'fil' => {
    'Latn' => 1,
    'Tglg' => 2
  },
  'btv' => {
    'Deva' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'osa' => {
    'Latn' => 2,
    'Osge' => 1
  },
  'tdg' => {
    'Deva' => 1,
    'Tibt' => 2
  },
  'mwk' => {
    'Latn' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'fia' => {
    'Arab' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'ffm' => {
    'Latn' => 1
  },
  'deu' => {
    'Runr' => 2,
    'Latn' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'kjg' => {
    'Latn' => 2,
    'Laoo' => 1
  },
  'myx' => {
    'Latn' => 1
  },
  'lao' => {
    'Laoo' => 1
  },
  'fvr' => {
    'Latn' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'fin' => {
    'Latn' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'osc' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'kde' => {
    'Latn' => 1
  },
  'jpn' => {
    'Jpan' => 1
  },
  'fuv' => {
    'Latn' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'kca' => {
    'Cyrl' => 1
  },
  'aii' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'tet' => {
    'Latn' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'zea' => {
    'Latn' => 1
  },
  'fra' => {
    'Dupl' => 2,
    'Latn' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'inh' => {
    'Cyrl' => 1,
    'Arab' => 2,
    'Latn' => 2
  },
  'khq' => {
    'Latn' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'arp' => {
    'Latn' => 1
  },
  'arg' => {
    'Latn' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'bfq' => {
    'Taml' => 1
  },
  'uig' => {
    'Latn' => 2,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'nyn' => {
    'Latn' => 1
  },
  'xnr' => {
    'Deva' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'tvl' => {
    'Latn' => 1
  },
  'bhi' => {
    'Deva' => 1
  },
  'kax' => {
    'Latn' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'liv' => {
    'Latn' => 2
  },
  'hrv' => {
    'Latn' => 1
  },
  'skr' => {
    'Arab' => 1
  },
  'vie' => {
    'Hani' => 2,
    'Latn' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'kiu' => {
    'Latn' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'ful' => {
    'Adlm' => 2,
    'Latn' => 1
  },
  'snd' => {
    'Arab' => 1,
    'Sind' => 2,
    'Khoj' => 2,
    'Deva' => 1
  },
  'arz' => {
    'Arab' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'gil' => {
    'Latn' => 1
  },
  'sqi' => {
    'Elba' => 2,
    'Latn' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'fas' => {
    'Arab' => 1
  },
  'ach' => {
    'Latn' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'umb' => {
    'Latn' => 1
  },
  'fuq' => {
    'Latn' => 1
  },
  'unx' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'tgk' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'luo' => {
    'Latn' => 1
  },
  'vmw' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'tur' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'mai' => {
    'Tirh' => 2,
    'Deva' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'sqq' => {
    'Thai' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'kik' => {
    'Latn' => 1
  },
  'kdh' => {
    'Latn' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'sun' => {
    'Latn' => 1,
    'Sund' => 2
  },
  'gag' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'gmh' => {
    'Latn' => 2
  },
  'kfy' => {
    'Deva' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'war' => {
    'Latn' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'was' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'maf' => {
    'Latn' => 1
  },
  'cop' => {
    'Arab' => 2,
    'Grek' => 2,
    'Copt' => 2
  },
  'cay' => {
    'Latn' => 1
  },
  'nod' => {
    'Lana' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'san' => {
    'Shrd' => 2,
    'Deva' => 2,
    'Sinh' => 2,
    'Sidd' => 2,
    'Gran' => 2
  },
  'mya' => {
    'Mymr' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'snx' => {
    'Hebr' => 2,
    'Samr' => 2
  },
  'quc' => {
    'Latn' => 1
  },
  'cja' => {
    'Cham' => 2,
    'Arab' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'taj' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'lmo' => {
    'Latn' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'kir' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'wae' => {
    'Latn' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'pli' => {
    'Thai' => 2,
    'Sinh' => 2,
    'Deva' => 2
  },
  'tru' => {
    'Syrc' => 2,
    'Latn' => 1
  },
  'ikt' => {
    'Latn' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'pus' => {
    'Arab' => 1
  }
};
$Territory2Lang = {
  'FI' => {
    'eng' => 2,
    'swe' => 1,
    'fin' => 1
  },
  'CN' => {
    'wuu' => 2,
    'kaz' => 2,
    'bod' => 2,
    'mon' => 2,
    'hsn' => 2,
    'yue' => 2,
    'iii' => 2,
    'kor' => 2,
    'zho' => 1,
    'nan' => 2,
    'uig' => 2,
    'hak' => 2,
    'zha' => 2,
    'gan' => 2
  },
  'TR' => {
    'kur' => 2,
    'zza' => 2,
    'tur' => 1,
    'eng' => 2
  },
  'GR' => {
    'ell' => 1,
    'eng' => 2
  },
  'IQ' => {
    'ara' => 1,
    'eng' => 2,
    'kur' => 2,
    'ckb' => 2,
    'aze' => 2
  },
  'CL' => {
    'spa' => 1,
    'eng' => 2
  },
  'YT' => {
    'fra' => 1,
    'swb' => 2,
    'buc' => 2
  },
  'AD' => {
    'cat' => 1,
    'spa' => 2
  },
  'SB' => {
    'eng' => 1
  },
  'VN' => {
    'zho' => 2,
    'vie' => 1
  },
  'SN' => {
    'knf' => 2,
    'ful' => 2,
    'wol' => 1,
    'sav' => 2,
    'bsc' => 2,
    'snf' => 2,
    'srr' => 2,
    'mfv' => 2,
    'dyo' => 2,
    'mey' => 2,
    'bjt' => 2,
    'fra' => 1,
    'tnr' => 2
  },
  'GQ' => {
    'por' => 1,
    'fan' => 2,
    'fra' => 1,
    'spa' => 1
  },
  'MG' => {
    'mlg' => 1,
    'eng' => 1,
    'fra' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'TH' => {
    'eng' => 2,
    'tha' => 1,
    'msa' => 2,
    'kxm' => 2,
    'sqq' => 2,
    'tts' => 2,
    'mfa' => 2,
    'zho' => 2,
    'nod' => 2
  },
  'CX' => {
    'eng' => 1
  },
  'JO' => {
    'eng' => 2,
    'ara' => 1
  },
  'AT' => {
    'hrv' => 2,
    'hbs' => 2,
    'deu' => 1,
    'hun' => 2,
    'bar' => 2,
    'slv' => 2,
    'eng' => 2
  },
  'SZ' => {
    'ssw' => 1,
    'eng' => 1
  },
  'CR' => {
    'spa' => 1
  },
  'AE' => {
    'ara' => 1,
    'eng' => 2
  },
  'PG' => {
    'tpi' => 1,
    'eng' => 1,
    'hmo' => 1
  },
  'HT' => {
    'hat' => 1,
    'fra' => 1
  },
  'ME' => {
    'srp' => 1,
    'hbs' => 1
  },
  'NO' => {
    'nob' => 1,
    'sme' => 2,
    'nor' => 1,
    'nno' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'JE' => {
    'eng' => 1
  },
  'LV' => {
    'rus' => 2,
    'lav' => 1,
    'eng' => 2
  },
  'IS' => {
    'isl' => 1
  },
  'ET' => {
    'wal' => 2,
    'aar' => 2,
    'tir' => 2,
    'orm' => 2,
    'som' => 2,
    'eng' => 2,
    'amh' => 1,
    'sid' => 2
  },
  'EA' => {
    'spa' => 1
  },
  'FM' => {
    'eng' => 1,
    'pon' => 2,
    'chk' => 2
  },
  'LT' => {
    'lit' => 1,
    'eng' => 2,
    'rus' => 2
  },
  'BA' => {
    'hbs' => 1,
    'hrv' => 1,
    'eng' => 2,
    'bos' => 1,
    'srp' => 1
  },
  'FR' => {
    'deu' => 2,
    'oci' => 2,
    'spa' => 2,
    'eng' => 2,
    'ita' => 2,
    'fra' => 1
  },
  'SK' => {
    'ces' => 2,
    'deu' => 2,
    'slk' => 1,
    'eng' => 2
  },
  'MO' => {
    'zho' => 1,
    'por' => 1
  },
  'TT' => {
    'eng' => 1
  },
  'BO' => {
    'que' => 1,
    'aym' => 1,
    'spa' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'KI' => {
    'gil' => 1,
    'eng' => 1
  },
  'SO' => {
    'som' => 1,
    'ara' => 1
  },
  'TV' => {
    'tvl' => 1,
    'eng' => 1
  },
  'SI' => {
    'slv' => 1,
    'eng' => 2,
    'hrv' => 2,
    'hbs' => 2,
    'deu' => 2
  },
  'FJ' => {
    'eng' => 1,
    'fij' => 1,
    'hif' => 1,
    'hin' => 2
  },
  'KH' => {
    'khm' => 1
  },
  'CZ' => {
    'deu' => 2,
    'slk' => 2,
    'ces' => 1,
    'eng' => 2
  },
  'VE' => {
    'spa' => 1
  },
  'CW' => {
    'nld' => 1,
    'pap' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'BQ' => {
    'nld' => 1,
    'pap' => 2
  },
  'PN' => {
    'eng' => 1
  },
  'IT' => {
    'srd' => 2,
    'ita' => 1,
    'fra' => 2,
    'eng' => 2
  },
  'MN' => {
    'mon' => 1
  },
  'UM' => {
    'eng' => 1
  },
  'VG' => {
    'eng' => 1
  },
  'SV' => {
    'spa' => 1
  },
  'CC' => {
    'msa' => 2,
    'eng' => 1
  },
  'TW' => {
    'zho' => 1
  },
  'MA' => {
    'ara' => 2,
    'tzm' => 1,
    'fra' => 1,
    'shr' => 2,
    'ary' => 2,
    'rif' => 2,
    'zgh' => 2,
    'eng' => 2
  },
  'NF' => {
    'eng' => 1
  },
  'SE' => {
    'fin' => 2,
    'swe' => 1,
    'eng' => 2
  },
  'GH' => {
    'ttb' => 2,
    'aka' => 2,
    'ewe' => 2,
    'eng' => 1,
    'abr' => 2
  },
  'AS' => {
    'eng' => 1,
    'smo' => 1
  },
  'LU' => {
    'ltz' => 1,
    'fra' => 1,
    'eng' => 2,
    'deu' => 1
  },
  'NL' => {
    'nld' => 1,
    'deu' => 2,
    'fry' => 2,
    'fra' => 2,
    'eng' => 2,
    'nds' => 2
  },
  'CH' => {
    'deu' => 1,
    'gsw' => 1,
    'eng' => 2,
    'roh' => 2,
    'fra' => 1,
    'ita' => 1
  },
  'NC' => {
    'fra' => 1
  },
  'MC' => {
    'fra' => 1
  },
  'CY' => {
    'tur' => 1,
    'eng' => 2,
    'ell' => 1
  },
  'BR' => {
    'deu' => 2,
    'por' => 1,
    'eng' => 2
  },
  'WS' => {
    'eng' => 1,
    'smo' => 1
  },
  'BW' => {
    'eng' => 1,
    'tsn' => 1
  },
  'CV' => {
    'por' => 1,
    'kea' => 2
  },
  'PK' => {
    'lah' => 2,
    'urd' => 1,
    'fas' => 2,
    'pus' => 2,
    'skr' => 2,
    'snd' => 2,
    'pan' => 2,
    'bal' => 2,
    'bgn' => 2,
    'hno' => 2,
    'brh' => 2,
    'eng' => 1
  },
  'JM' => {
    'eng' => 1,
    'jam' => 2
  },
  'SS' => {
    'ara' => 2,
    'eng' => 1
  },
  'KE' => {
    'luy' => 2,
    'swa' => 1,
    'luo' => 2,
    'mnu' => 2,
    'kln' => 2,
    'kik' => 2,
    'guz' => 2,
    'kdx' => 2,
    'eng' => 1
  },
  'SA' => {
    'ara' => 1
  },
  'CG' => {
    'fra' => 1
  },
  'SJ' => {
    'nob' => 1,
    'nor' => 1,
    'rus' => 2
  },
  'EC' => {
    'spa' => 1,
    'que' => 1
  },
  'HN' => {
    'spa' => 1
  },
  'SH' => {
    'eng' => 1
  },
  'DG' => {
    'eng' => 1
  },
  'IN' => {
    'san' => 2,
    'khn' => 2,
    'guj' => 2,
    'tcy' => 2,
    'gom' => 2,
    'gbm' => 2,
    'rkt' => 2,
    'mal' => 2,
    'asm' => 2,
    'mtr' => 2,
    'kha' => 2,
    'dcc' => 2,
    'brx' => 2,
    'mwr' => 2,
    'wbq' => 2,
    'noe' => 2,
    'wbr' => 2,
    'hoc' => 2,
    'kan' => 2,
    'unr' => 2,
    'kas' => 2,
    'snd' => 2,
    'ori' => 2,
    'doi' => 2,
    'wtm' => 2,
    'bho' => 2,
    'kfy' => 2,
    'awa' => 2,
    'tam' => 2,
    'ben' => 2,
    'kok' => 2,
    'swv' => 2,
    'hin' => 1,
    'tel' => 2,
    'kru' => 2,
    'raj' => 2,
    'sat' => 2,
    'bhi' => 2,
    'bgc' => 2,
    'bjj' => 2,
    'hoj' => 2,
    'lmn' => 2,
    'xnr' => 2,
    'gon' => 2,
    'sck' => 2,
    'mai' => 2,
    'pan' => 2,
    'mag' => 2,
    'mar' => 2,
    'urd' => 2,
    'hne' => 2,
    'mni' => 2,
    'eng' => 1,
    'nep' => 2,
    'bhb' => 2
  },
  'QA' => {
    'ara' => 1
  },
  'BE' => {
    'nld' => 1,
    'deu' => 1,
    'fra' => 1,
    'vls' => 2,
    'eng' => 2
  },
  'SC' => {
    'fra' => 1,
    'crs' => 2,
    'eng' => 1
  },
  'GM' => {
    'man' => 2,
    'eng' => 1
  },
  'BF' => {
    'mos' => 2,
    'fra' => 1,
    'dyu' => 2
  },
  'GW' => {
    'por' => 1
  },
  'AC' => {
    'eng' => 2
  },
  'CU' => {
    'spa' => 1
  },
  'GL' => {
    'kal' => 1
  },
  'NZ' => {
    'mri' => 1,
    'eng' => 1
  },
  'NP' => {
    'bho' => 2,
    'mai' => 2,
    'nep' => 1
  },
  'FK' => {
    'eng' => 1
  },
  'NE' => {
    'fra' => 1,
    'hau' => 2,
    'fuq' => 2,
    'ful' => 2,
    'tmh' => 2,
    'dje' => 2
  },
  'DO' => {
    'spa' => 1
  },
  'BZ' => {
    'eng' => 1,
    'spa' => 2
  },
  'GF' => {
    'gcr' => 2,
    'fra' => 1
  },
  'AR' => {
    'spa' => 1,
    'eng' => 2
  },
  'ZW' => {
    'nde' => 1,
    'sna' => 1,
    'eng' => 1
  },
  'WF' => {
    'fra' => 1,
    'wls' => 2,
    'fud' => 2
  },
  'MK' => {
    'sqi' => 2,
    'mkd' => 1
  },
  'TZ' => {
    'eng' => 1,
    'kde' => 2,
    'suk' => 2,
    'swa' => 1,
    'nym' => 2
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'PY' => {
    'grn' => 1,
    'spa' => 1
  },
  'AF' => {
    'uzb' => 2,
    'haz' => 2,
    'bal' => 2,
    'fas' => 1,
    'tuk' => 2,
    'pus' => 1
  },
  'GB' => {
    'gle' => 2,
    'sco' => 2,
    'deu' => 2,
    'fra' => 2,
    'gla' => 2,
    'cym' => 2,
    'eng' => 1
  },
  'IM' => {
    'glv' => 1,
    'eng' => 1
  },
  'RE' => {
    'rcf' => 2,
    'fra' => 1
  },
  'MM' => {
    'mya' => 1,
    'shn' => 2
  },
  'LI' => {
    'deu' => 1,
    'gsw' => 1
  },
  'BH' => {
    'ara' => 1
  },
  'BS' => {
    'eng' => 1
  },
  'US' => {
    'eng' => 1,
    'vie' => 2,
    'haw' => 2,
    'fra' => 2,
    'ita' => 2,
    'zho' => 2,
    'spa' => 2,
    'deu' => 2,
    'fil' => 2,
    'kor' => 2
  },
  'PW' => {
    'pau' => 1,
    'eng' => 1
  },
  'BM' => {
    'eng' => 1
  },
  'CD' => {
    'swa' => 2,
    'lin' => 2,
    'lua' => 2,
    'lub' => 2,
    'kon' => 2,
    'fra' => 1
  },
  'LC' => {
    'eng' => 1
  },
  'PM' => {
    'fra' => 1
  },
  'SD' => {
    'eng' => 1,
    'ara' => 1,
    'fvr' => 2,
    'bej' => 2
  },
  'MZ' => {
    'seh' => 2,
    'tso' => 2,
    'por' => 1,
    'mgh' => 2,
    'ndc' => 2,
    'vmw' => 2,
    'ngl' => 2
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'AL' => {
    'sqi' => 1
  },
  'BG' => {
    'eng' => 2,
    'bul' => 1,
    'rus' => 2
  },
  'HM' => {
    'und' => 2
  },
  'MR' => {
    'ara' => 1
  },
  'CP' => {
    'und' => 2
  },
  'SG' => {
    'eng' => 1,
    'zho' => 1,
    'msa' => 1,
    'tam' => 1
  },
  'VI' => {
    'eng' => 1
  },
  'BJ' => {
    'fon' => 2,
    'fra' => 1
  },
  'RO' => {
    'fra' => 2,
    'eng' => 2,
    'ron' => 1,
    'spa' => 2,
    'hun' => 2
  },
  'DZ' => {
    'kab' => 2,
    'eng' => 2,
    'ara' => 2,
    'fra' => 1,
    'arq' => 2
  },
  'DK' => {
    'kal' => 2,
    'deu' => 2,
    'dan' => 1,
    'eng' => 2
  },
  'NA' => {
    'afr' => 2,
    'ndo' => 2,
    'eng' => 1,
    'kua' => 2
  },
  'AX' => {
    'swe' => 1
  },
  'MY' => {
    'tam' => 2,
    'zho' => 2,
    'msa' => 1,
    'eng' => 2
  },
  'AM' => {
    'hye' => 1
  },
  'RU' => {
    'kbd' => 2,
    'ava' => 2,
    'tyv' => 2,
    'krc' => 2,
    'ady' => 2,
    'kkt' => 2,
    'hye' => 2,
    'kom' => 2,
    'chv' => 2,
    'kum' => 2,
    'udm' => 2,
    'mdf' => 2,
    'lbe' => 2,
    'sah' => 2,
    'aze' => 2,
    'che' => 2,
    'tat' => 2,
    'rus' => 1,
    'myv' => 2,
    'bak' => 2,
    'lez' => 2,
    'inh' => 2
  },
  'PT' => {
    'spa' => 2,
    'por' => 1,
    'eng' => 2,
    'fra' => 2
  },
  'NU' => {
    'niu' => 1,
    'eng' => 1
  },
  'IR' => {
    'ckb' => 2,
    'luz' => 2,
    'ara' => 2,
    'bqi' => 2,
    'tuk' => 2,
    'fas' => 1,
    'aze' => 2,
    'kur' => 2,
    'sdh' => 2,
    'rmt' => 2,
    'lrc' => 2,
    'glk' => 2,
    'mzn' => 2,
    'bal' => 2
  },
  'LY' => {
    'ara' => 1
  },
  'VA' => {
    'lat' => 2,
    'ita' => 1
  },
  'GY' => {
    'eng' => 1
  },
  'KM' => {
    'fra' => 1,
    'ara' => 1,
    'wni' => 1,
    'zdj' => 1
  },
  'VU' => {
    'eng' => 1,
    'fra' => 1,
    'bis' => 1
  },
  'ES' => {
    'eus' => 2,
    'spa' => 1,
    'glg' => 2,
    'cat' => 2,
    'eng' => 2,
    'ast' => 2
  },
  'UA' => {
    'rus' => 1,
    'pol' => 2,
    'ukr' => 1
  },
  'BY' => {
    'rus' => 1,
    'bel' => 1
  },
  'GI' => {
    'eng' => 1,
    'spa' => 2
  },
  'MV' => {
    'div' => 1
  },
  'EG' => {
    'eng' => 2,
    'ara' => 2,
    'arz' => 2
  },
  'PL' => {
    'deu' => 2,
    'rus' => 2,
    'csb' => 2,
    'lit' => 2,
    'pol' => 1,
    'eng' => 2
  },
  'ZA' => {
    'ssw' => 2,
    'ven' => 2,
    'afr' => 2,
    'sot' => 2,
    'nso' => 2,
    'tsn' => 2,
    'zul' => 2,
    'eng' => 1,
    'tso' => 2,
    'nbl' => 2,
    'xho' => 2,
    'hin' => 2
  },
  'IO' => {
    'eng' => 1
  },
  'SL' => {
    'men' => 2,
    'eng' => 1,
    'kdh' => 2,
    'kri' => 2
  },
  'HK' => {
    'eng' => 1,
    'zho' => 1,
    'yue' => 2
  },
  'OM' => {
    'ara' => 1
  },
  'AW' => {
    'nld' => 1,
    'pap' => 1
  },
  'BT' => {
    'dzo' => 1
  },
  'GS' => {
    'und' => 2
  },
  'NR' => {
    'nau' => 1,
    'eng' => 1
  },
  'RS' => {
    'sqi' => 2,
    'ron' => 2,
    'slk' => 2,
    'hun' => 2,
    'hbs' => 1,
    'hrv' => 2,
    'ukr' => 2,
    'srp' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'PA' => {
    'spa' => 1
  },
  'MS' => {
    'eng' => 1
  },
  'SR' => {
    'srn' => 2,
    'nld' => 1
  },
  'TK' => {
    'tkl' => 1,
    'eng' => 1
  },
  'ZM' => {
    'eng' => 1,
    'bem' => 2,
    'nya' => 2
  },
  'MT' => {
    'mlt' => 1,
    'ita' => 2,
    'eng' => 1
  },
  'KG' => {
    'rus' => 1,
    'kir' => 1
  },
  'SY' => {
    'ara' => 1,
    'fra' => 1,
    'kur' => 2
  },
  'VC' => {
    'eng' => 1
  },
  'AO' => {
    'kmb' => 2,
    'umb' => 2,
    'por' => 1
  },
  'BV' => {
    'und' => 2
  },
  'TJ' => {
    'rus' => 2,
    'tgk' => 1
  },
  'HR' => {
    'ita' => 2,
    'eng' => 2,
    'hrv' => 1,
    'hbs' => 1
  },
  'PH' => {
    'bik' => 2,
    'war' => 2,
    'mdh' => 2,
    'fil' => 1,
    'spa' => 2,
    'eng' => 1,
    'pag' => 2,
    'ilo' => 2,
    'tsg' => 2,
    'pmn' => 2,
    'hil' => 2,
    'bhk' => 2,
    'ceb' => 2
  },
  'GG' => {
    'eng' => 1
  },
  'HU' => {
    'deu' => 2,
    'hun' => 1,
    'eng' => 2
  },
  'GE' => {
    'abk' => 2,
    'kat' => 1,
    'oss' => 2
  },
  'BL' => {
    'fra' => 1
  },
  'YE' => {
    'eng' => 2,
    'ara' => 1
  },
  'TN' => {
    'ara' => 1,
    'fra' => 1,
    'aeb' => 2
  },
  'NG' => {
    'eng' => 1,
    'yor' => 1,
    'efi' => 2,
    'fuv' => 2,
    'ibb' => 2,
    'ful' => 2,
    'ibo' => 2,
    'tiv' => 2,
    'bin' => 2,
    'hau' => 2,
    'pcm' => 2
  },
  'ML' => {
    'ful' => 2,
    'snk' => 2,
    'bam' => 2,
    'fra' => 1,
    'ffm' => 2
  },
  'KP' => {
    'kor' => 1
  },
  'TO' => {
    'ton' => 1,
    'eng' => 1
  },
  'EH' => {
    'ara' => 1
  },
  'GA' => {
    'fra' => 1
  },
  'JP' => {
    'jpn' => 1
  },
  'PR' => {
    'spa' => 1,
    'eng' => 1
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'CI' => {
    'sef' => 2,
    'bci' => 2,
    'fra' => 1,
    'dnj' => 2
  },
  'DE' => {
    'bar' => 2,
    'fra' => 2,
    'ita' => 2,
    'nld' => 2,
    'spa' => 2,
    'tur' => 2,
    'deu' => 1,
    'vmf' => 2,
    'dan' => 2,
    'eng' => 2,
    'nds' => 2,
    'gsw' => 2,
    'rus' => 2
  },
  'KW' => {
    'ara' => 1
  },
  'BD' => {
    'rkt' => 2,
    'eng' => 2,
    'ben' => 1,
    'syl' => 2
  },
  'AZ' => {
    'aze' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'LK' => {
    'sin' => 1,
    'eng' => 2,
    'tam' => 1
  },
  'SX' => {
    'nld' => 1,
    'eng' => 1
  },
  'LB' => {
    'ara' => 1,
    'eng' => 2
  },
  'DJ' => {
    'fra' => 1,
    'ara' => 1,
    'som' => 2,
    'aar' => 2
  },
  'MX' => {
    'eng' => 2,
    'spa' => 1
  },
  'AU' => {
    'eng' => 1
  },
  'TA' => {
    'eng' => 2
  },
  'BN' => {
    'msa' => 1
  },
  'RW' => {
    'fra' => 1,
    'eng' => 1,
    'kin' => 1
  },
  'MW' => {
    'nya' => 1,
    'eng' => 1,
    'tum' => 2
  },
  'GP' => {
    'fra' => 1
  },
  'UG' => {
    'xog' => 2,
    'laj' => 2,
    'cgg' => 2,
    'lug' => 2,
    'eng' => 1,
    'nyn' => 2,
    'ach' => 2,
    'myx' => 2,
    'teo' => 2,
    'swa' => 1
  },
  'AI' => {
    'eng' => 1
  },
  'GN' => {
    'ful' => 2,
    'fra' => 1,
    'sus' => 2,
    'man' => 2
  },
  'CA' => {
    'ikt' => 2,
    'eng' => 1,
    'fra' => 1,
    'iku' => 2
  },
  'AQ' => {
    'und' => 2
  },
  'MD' => {
    'ron' => 1
  },
  'MH' => {
    'eng' => 1,
    'mah' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'PE' => {
    'que' => 1,
    'spa' => 1
  },
  'CO' => {
    'spa' => 1
  },
  'MU' => {
    'mfe' => 2,
    'bho' => 2,
    'eng' => 1,
    'fra' => 1
  },
  'GU' => {
    'eng' => 1,
    'cha' => 1
  },
  'DM' => {
    'eng' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'BB' => {
    'eng' => 1
  },
  'BI' => {
    'fra' => 1,
    'run' => 1,
    'eng' => 1
  },
  'EE' => {
    'rus' => 2,
    'fin' => 2,
    'eng' => 2,
    'est' => 1
  },
  'PF' => {
    'fra' => 1,
    'tah' => 1
  },
  'MF' => {
    'fra' => 1
  },
  'MQ' => {
    'fra' => 1
  },
  'IL' => {
    'eng' => 2,
    'ara' => 1,
    'heb' => 1
  },
  'FO' => {
    'fao' => 1
  },
  'TD' => {
    'ara' => 1,
    'fra' => 1
  },
  'SM' => {
    'ita' => 1
  },
  'CM' => {
    'eng' => 1,
    'fra' => 1,
    'bmv' => 2
  },
  'KR' => {
    'kor' => 1
  },
  'GT' => {
    'quc' => 2,
    'spa' => 1
  },
  'KZ' => {
    'eng' => 2,
    'kaz' => 1,
    'rus' => 1,
    'deu' => 2
  },
  'LS' => {
    'eng' => 1,
    'sot' => 1
  },
  'XK' => {
    'sqi' => 1,
    'hbs' => 1,
    'aln' => 2,
    'srp' => 1
  },
  'KY' => {
    'eng' => 1
  },
  'ID' => {
    'sun' => 2,
    'mad' => 2,
    'bew' => 2,
    'bug' => 2,
    'ind' => 1,
    'ban' => 2,
    'msa' => 2,
    'rej' => 2,
    'bjn' => 2,
    'jav' => 2,
    'sas' => 2,
    'gqr' => 2,
    'mak' => 2,
    'ljp' => 2,
    'ace' => 2,
    'min' => 2,
    'bbc' => 2,
    'zho' => 2
  },
  'KN' => {
    'eng' => 1
  },
  'CF' => {
    'sag' => 1,
    'fra' => 1
  },
  'UY' => {
    'spa' => 1
  },
  'UZ' => {
    'rus' => 2,
    'uzb' => 1
  },
  'CK' => {
    'eng' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'MP' => {
    'eng' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'ER' => {
    'ara' => 1,
    'eng' => 1,
    'tig' => 2,
    'tir' => 1
  },
  'ST' => {
    'por' => 1
  }
};
$Script2Lang = {
  'Tavt' => {
    'blt' => 1
  },
  'Avst' => {
    'ave' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Thaa' => {
    'div' => 1
  },
  'Phli' => {
    'abw' => 2
  },
  'Gran' => {
    'san' => 2
  },
  'Mlym' => {
    'mal' => 1
  },
  'Khoj' => {
    'snd' => 2
  },
  'Phag' => {
    'mon' => 2,
    'zho' => 2
  },
  'Khmr' => {
    'khm' => 1
  },
  'Hani' => {
    'vie' => 2
  },
  'Sind' => {
    'snd' => 2
  },
  'Copt' => {
    'cop' => 2
  },
  'Beng' => {
    'asm' => 1,
    'kha' => 2,
    'ccp' => 1,
    'ben' => 1,
    'lus' => 1,
    'rkt' => 1,
    'unr' => 1,
    'syl' => 1,
    'sat' => 2,
    'unx' => 1,
    'bpy' => 1,
    'mni' => 1,
    'grt' => 1
  },
  'Cprt' => {
    'grc' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Syrc' => {
    'ara' => 2,
    'tru' => 2,
    'syr' => 2,
    'aii' => 2
  },
  'Mani' => {
    'xmn' => 2
  },
  'Xsux' => {
    'akk' => 2,
    'hit' => 2
  },
  'Taml' => {
    'bfq' => 1,
    'tam' => 1
  },
  'Bali' => {
    'ban' => 2
  },
  'Batk' => {
    'bbc' => 2
  },
  'Lepc' => {
    'lep' => 1
  },
  'Hans' => {
    'gan' => 1,
    'zha' => 2,
    'hak' => 1,
    'yue' => 1,
    'hsn' => 1,
    'lzh' => 2,
    'zho' => 1,
    'nan' => 1,
    'wuu' => 1
  },
  'Shrd' => {
    'san' => 2
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Telu' => {
    'lmn' => 1,
    'wbq' => 1,
    'gon' => 1,
    'tel' => 1
  },
  'Mtei' => {
    'mni' => 2
  },
  'Sinh' => {
    'sin' => 1,
    'pli' => 2,
    'san' => 2
  },
  'Aghb' => {
    'lez' => 2
  },
  'Tfng' => {
    'tzm' => 1,
    'zen' => 2,
    'zgh' => 1,
    'rif' => 1,
    'shr' => 1
  },
  'Phlp' => {
    'abw' => 2
  },
  'Sylo' => {
    'syl' => 2
  },
  'Thai' => {
    'pli' => 2,
    'lwl' => 1,
    'kxm' => 1,
    'lcp' => 1,
    'tha' => 1,
    'tts' => 1,
    'sqq' => 1,
    'kdt' => 1
  },
  'Kore' => {
    'kor' => 1
  },
  'Tglg' => {
    'fil' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Olck' => {
    'sat' => 1
  },
  'Osge' => {
    'osa' => 1
  },
  'Hant' => {
    'zho' => 1,
    'yue' => 1
  },
  'Phnx' => {
    'phn' => 2
  },
  'Tale' => {
    'tdd' => 1
  },
  'Grek' => {
    'tsd' => 1,
    'cop' => 2,
    'grc' => 2,
    'bgx' => 1,
    'pnt' => 1,
    'ell' => 1
  },
  'Sidd' => {
    'san' => 2
  },
  'Gujr' => {
    'guj' => 1
  },
  'Buhd' => {
    'bku' => 2
  },
  'Ugar' => {
    'uga' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Java' => {
    'jav' => 2
  },
  'Dupl' => {
    'fra' => 2
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Limb' => {
    'lif' => 1
  },
  'Linb' => {
    'grc' => 2
  },
  'Tirh' => {
    'mai' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Palm' => {
    'arc' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Lydi' => {
    'xld' => 2
  },
  'Mroo' => {
    'mro' => 2
  },
  'Tibt' => {
    'bft' => 2,
    'dzo' => 1,
    'bod' => 1,
    'tsj' => 1,
    'tdg' => 2,
    'taj' => 2
  },
  'Laoo' => {
    'lao' => 1,
    'kjg' => 1,
    'hnj' => 1,
    'hmn' => 1
  },
  'Lina' => {
    'lab' => 2
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Bugi' => {
    'bug' => 2,
    'mdr' => 2,
    'mak' => 2
  },
  'Cham' => {
    'cjm' => 1,
    'cja' => 2
  },
  'Bamu' => {
    'bax' => 1
  },
  'Mend' => {
    'men' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Ethi' => {
    'tig' => 1,
    'wal' => 1,
    'tir' => 1,
    'orm' => 2,
    'gez' => 2,
    'byn' => 1,
    'amh' => 1
  },
  'Hano' => {
    'hnn' => 2
  },
  'Cyrl' => {
    'ukr' => 1,
    'che' => 1,
    'bak' => 1,
    'sel' => 2,
    'kum' => 1,
    'pnt' => 1,
    'dar' => 1,
    'gld' => 1,
    'ckt' => 1,
    'tgk' => 1,
    'kaa' => 1,
    'chm' => 1,
    'evn' => 1,
    'mon' => 1,
    'kkt' => 1,
    'bul' => 1,
    'ron' => 2,
    'cjs' => 1,
    'alt' => 1,
    'tab' => 1,
    'kpy' => 1,
    'ude' => 1,
    'srp' => 1,
    'aze' => 1,
    'rom' => 2,
    'kaz' => 1,
    'tkr' => 1,
    'udm' => 1,
    'ttt' => 1,
    'chu' => 2,
    'dng' => 1,
    'chv' => 1,
    'syr' => 1,
    'ava' => 1,
    'kbd' => 1,
    'lfn' => 2,
    'mkd' => 1,
    'rue' => 1,
    'kur' => 1,
    'myv' => 1,
    'inh' => 1,
    'uig' => 1,
    'tly' => 1,
    'bel' => 1,
    'mns' => 1,
    'crh' => 1,
    'xal' => 1,
    'kjh' => 1,
    'bos' => 1,
    'yrk' => 1,
    'abk' => 1,
    'kir' => 1,
    'sme' => 2,
    'mrj' => 1,
    'krc' => 1,
    'mdf' => 1,
    'abq' => 1,
    'lbe' => 1,
    'sah' => 1,
    'rus' => 1,
    'tat' => 1,
    'lez' => 1,
    'nog' => 1,
    'tuk' => 1,
    'gag' => 2,
    'uzb' => 1,
    'bub' => 1,
    'ady' => 1,
    'kom' => 1,
    'hbs' => 1,
    'tyv' => 1,
    'oss' => 1,
    'aii' => 1,
    'kca' => 1
  },
  'Geor' => {
    'xmf' => 1,
    'lzz' => 1,
    'kat' => 1
  },
  'Sora' => {
    'srb' => 2
  },
  'Cher' => {
    'chr' => 1
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Latn' => {
    'brh' => 2,
    'dsb' => 1,
    'man' => 1,
    'kur' => 1,
    'bjn' => 1,
    'trv' => 1,
    'nia' => 1,
    'snk' => 1,
    'nsk' => 2,
    'bre' => 1,
    'kpe' => 1,
    'oci' => 1,
    'lag' => 1,
    'kal' => 1,
    'tkl' => 1,
    'sms' => 1,
    'rug' => 1,
    'fit' => 1,
    'swe' => 1,
    'tum' => 1,
    'xog' => 1,
    'dje' => 1,
    'eka' => 1,
    'esu' => 1,
    'aln' => 1,
    'est' => 1,
    'nap' => 1,
    'chy' => 1,
    'frm' => 2,
    'crj' => 2,
    'lam' => 1,
    'ngl' => 1,
    'buc' => 1,
    'gub' => 1,
    'tpi' => 1,
    'run' => 1,
    'lim' => 1,
    'sly' => 1,
    'ttj' => 1,
    'bin' => 1,
    'pol' => 1,
    'grn' => 1,
    'sus' => 1,
    'tzm' => 1,
    'izh' => 1,
    'aro' => 1,
    'frp' => 1,
    'hop' => 1,
    'gcr' => 1,
    'oji' => 2,
    'frr' => 1,
    'zza' => 1,
    'bmv' => 1,
    'tog' => 1,
    'aym' => 1,
    'cch' => 1,
    'crs' => 1,
    'lat' => 2,
    'agq' => 1,
    'ltg' => 1,
    'kin' => 1,
    'nld' => 1,
    'maz' => 1,
    'hsb' => 1,
    'dav' => 1,
    'ctd' => 1,
    'wln' => 1,
    'sid' => 1,
    'kln' => 1,
    'rob' => 1,
    'ceb' => 1,
    'dum' => 2,
    'yap' => 1,
    'niu' => 1,
    'enm' => 2,
    'mro' => 1,
    'vol' => 2,
    'ljp' => 1,
    'lug' => 1,
    'wbp' => 1,
    'vro' => 1,
    'arn' => 1,
    'kgp' => 1,
    'mgo' => 1,
    'csb' => 2,
    'srd' => 1,
    'mas' => 1,
    'dak' => 1,
    'ron' => 1,
    'dyu' => 1,
    'lij' => 1,
    'lin' => 1,
    'smo' => 1,
    'sad' => 1,
    'nso' => 1,
    'mah' => 1,
    'ind' => 1,
    'ang' => 2,
    'lua' => 1,
    'ada' => 1,
    'ttb' => 1,
    'hin' => 2,
    'rif' => 1,
    'sxn' => 1,
    'dtp' => 1,
    'zmi' => 1,
    'vls' => 1,
    'byv' => 1,
    'bkm' => 1,
    'sef' => 1,
    'wls' => 1,
    'xav' => 1,
    'vmf' => 1,
    'slv' => 1,
    'ttt' => 1,
    'bem' => 1,
    'mwl' => 1,
    'mgh' => 1,
    'pap' => 1,
    'lub' => 1,
    'lun' => 1,
    'ndc' => 1,
    'kab' => 1,
    'zun' => 1,
    'gay' => 1,
    'tly' => 1,
    'kkj' => 1,
    'moe' => 1,
    'lkt' => 1,
    'jmc' => 1,
    'nmg' => 1,
    'loz' => 1,
    'glg' => 1,
    'fro' => 2,
    'bis' => 1,
    'kon' => 1,
    'fry' => 1,
    'hif' => 1,
    'mri' => 1,
    'sme' => 1,
    'srb' => 1,
    'frs' => 1,
    'car' => 1,
    'tbw' => 1,
    'bez' => 1,
    'ksb' => 1,
    'suk' => 1,
    'nav' => 1,
    'bik' => 1,
    'vic' => 1,
    'sas' => 1,
    'gqr' => 1,
    'cad' => 1,
    'rgn' => 1,
    'afr' => 1,
    'sot' => 1,
    'rup' => 1,
    'swb' => 2,
    'rof' => 1,
    'kri' => 1,
    'laj' => 1,
    'hil' => 1,
    'vec' => 1,
    'hat' => 1,
    'nhe' => 1,
    'gsw' => 1,
    'mxc' => 1,
    'moh' => 1,
    'kfo' => 1,
    'mdh' => 1,
    'avk' => 2,
    'nij' => 1,
    'bbj' => 1,
    'lut' => 2,
    'hai' => 1,
    'luy' => 1,
    'tso' => 1,
    'zap' => 1,
    'njo' => 1,
    'bvb' => 1,
    'ltz' => 1,
    'pdt' => 1,
    'rcf' => 1,
    'nxq' => 1,
    'kut' => 1,
    'ibo' => 1,
    'tah' => 1,
    'mnu' => 1,
    'ven' => 1,
    'ton' => 1,
    'mlt' => 1,
    'sei' => 1,
    'swa' => 1,
    'pcd' => 1,
    'glv' => 1,
    'ses' => 1,
    'fij' => 1,
    'rng' => 1,
    'pau' => 1,
    'pko' => 1,
    'ina' => 2,
    'aka' => 1,
    'hnn' => 1,
    'ter' => 1,
    'swg' => 1,
    'kcg' => 1,
    'tsn' => 1,
    'nob' => 1,
    'amo' => 1,
    'mad' => 1,
    'mdr' => 1,
    'srp' => 1,
    'rtm' => 1,
    'guz' => 1,
    'rom' => 1,
    'ife' => 1,
    'krl' => 1,
    'ria' => 1,
    'ipk' => 1,
    'naq' => 1,
    'sga' => 2,
    'bss' => 1,
    'nus' => 1,
    'jav' => 1,
    'fan' => 1,
    'zha' => 1,
    'ett' => 2,
    'lui' => 2,
    'nzi' => 1,
    'som' => 1,
    'cat' => 1,
    'bmq' => 1,
    'bal' => 2,
    'kau' => 1,
    'bqv' => 1,
    'iku' => 1,
    'cha' => 1,
    'xum' => 2,
    'kaj' => 1,
    'ndo' => 1,
    'chp' => 1,
    'pfl' => 1,
    'szl' => 1,
    'jut' => 2,
    'mls' => 1,
    'cym' => 1,
    'lfn' => 2,
    'mgy' => 1,
    'kvr' => 1,
    'pro' => 2,
    'aoz' => 1,
    'zul' => 1,
    'smj' => 1,
    'bew' => 1,
    'bku' => 1,
    'dgr' => 1,
    'ibb' => 1,
    'ebu' => 1,
    'quc' => 1,
    'tsg' => 1,
    'haw' => 1,
    'ban' => 1,
    'vai' => 1,
    'mwv' => 1,
    'cre' => 2,
    'chk' => 1,
    'lmo' => 1,
    'mak' => 1,
    'yor' => 1,
    'isl' => 1,
    'wae' => 1,
    'krj' => 1,
    'tru' => 1,
    'dtm' => 1,
    'gur' => 1,
    'sma' => 1,
    'que' => 1,
    'pon' => 1,
    'xho' => 1,
    'kir' => 1,
    'stq' => 1,
    'ewe' => 1,
    'atj' => 1,
    'cor' => 1,
    'seh' => 1,
    'pdc' => 1,
    'lav' => 1,
    'nhw' => 1,
    'ikt' => 1,
    'nno' => 1,
    'kdh' => 1,
    'orm' => 1,
    'rap' => 1,
    'sun' => 1,
    'kik' => 1,
    'shr' => 1,
    'msa' => 1,
    'gle' => 1,
    'rmu' => 1,
    'ewo' => 1,
    'bas' => 1,
    'war' => 1,
    'din' => 1,
    'gag' => 1,
    'hau' => 1,
    'uzb' => 1,
    'gmh' => 2,
    'sgs' => 1,
    'kge' => 1,
    'maf' => 1,
    'ksh' => 1,
    'hbs' => 1,
    'was' => 1,
    'abr' => 1,
    'mus' => 1,
    'bci' => 1,
    'iii' => 2,
    'mdt' => 1,
    'cay' => 1,
    'cps' => 1,
    'eng' => 1,
    'frc' => 1,
    'mlg' => 1,
    'umb' => 1,
    'fao' => 1,
    'mfe' => 1,
    'hmn' => 1,
    'fuq' => 1,
    'kck' => 1,
    'tgk' => 1,
    'hup' => 1,
    'luo' => 1,
    'kmb' => 1,
    'goh' => 2,
    'ain' => 2,
    'spa' => 1,
    'tur' => 1,
    'vmw' => 1,
    'rar' => 1,
    'ces' => 1,
    'fon' => 1,
    'smn' => 1,
    'tmh' => 1,
    'nnh' => 1,
    'dyo' => 1,
    'crl' => 2,
    'cos' => 1,
    'nch' => 1,
    'aar' => 1,
    'mos' => 1,
    'por' => 1,
    'vie' => 1,
    'tli' => 1,
    'dnj' => 1,
    'liv' => 2,
    'ilo' => 1,
    'hrv' => 1,
    'syi' => 1,
    'yua' => 1,
    'kac' => 1,
    'egl' => 1,
    'kiu' => 1,
    'udm' => 2,
    'hmo' => 1,
    'sag' => 1,
    'cgg' => 1,
    'nds' => 1,
    'rwk' => 1,
    'gil' => 1,
    'ful' => 1,
    'srn' => 1,
    'qug' => 1,
    'ace' => 1,
    'bze' => 1,
    'wol' => 1,
    'ach' => 1,
    'twq' => 1,
    'teo' => 1,
    'fud' => 1,
    'sqi' => 1,
    'vep' => 1,
    'kha' => 1,
    'khq' => 1,
    'see' => 1,
    'vot' => 2,
    'uli' => 1,
    'nor' => 1,
    'inh' => 2,
    'yao' => 1,
    'sna' => 1,
    'uig' => 2,
    'arp' => 1,
    'prg' => 2,
    'arg' => 1,
    'lol' => 1,
    'ssy' => 1,
    'gla' => 1,
    'iba' => 1,
    'dan' => 1,
    'bos' => 1,
    'nyn' => 1,
    'tvl' => 1,
    'her' => 1,
    'nyo' => 1,
    'gos' => 1,
    'ext' => 1,
    'ssw' => 1,
    'kax' => 1,
    'bto' => 1,
    'scn' => 1,
    'pcm' => 1,
    'srr' => 1,
    'mwk' => 1,
    'roh' => 1,
    'gba' => 1,
    'bug' => 1,
    'cho' => 1,
    'ffm' => 1,
    'nya' => 1,
    'slk' => 1,
    'asa' => 1,
    'ybb' => 1,
    'rej' => 1,
    'osa' => 2,
    'tiv' => 1,
    'rmo' => 1,
    'bar' => 1,
    'fvr' => 1,
    'tuk' => 1,
    'lzz' => 1,
    'deu' => 1,
    'scs' => 1,
    'myx' => 1,
    'kjg' => 2,
    'arw' => 2,
    'kde' => 1,
    'nbl' => 1,
    'fuv' => 1,
    'kos' => 1,
    'zag' => 1,
    'osc' => 2,
    'fin' => 1,
    'ksf' => 1,
    'jam' => 1,
    'ale' => 1,
    'zea' => 1,
    'tet' => 1,
    'fra' => 1,
    'puu' => 1,
    'bbc' => 1,
    'min' => 1,
    'kdx' => 1,
    'hun' => 1,
    'rmf' => 1,
    'bam' => 1,
    'pnt' => 1,
    'grb' => 1,
    'bfd' => 1,
    'mua' => 1,
    'tsi' => 1,
    'sli' => 1,
    'eus' => 1,
    'pms' => 1,
    'yrl' => 1,
    'saq' => 1,
    'pag' => 1,
    'nym' => 1,
    'mic' => 1,
    'nov' => 2,
    'bzx' => 1,
    'den' => 1,
    'nde' => 1,
    'dua' => 1,
    'bla' => 1,
    'guc' => 1,
    'fil' => 1,
    'nau' => 1,
    'cic' => 1,
    'ast' => 1,
    'kua' => 1,
    'kea' => 1,
    'lit' => 1,
    'pmn' => 1,
    'sat' => 2,
    'aze' => 1,
    'jgo' => 1,
    'tkr' => 1,
    'ita' => 1,
    'sco' => 1,
    'gwi' => 1,
    'sbp' => 1,
    'saf' => 1,
    'epo' => 1,
    'chn' => 2,
    'efi' => 1,
    'akz' => 1,
    'lbw' => 1,
    'vun' => 1,
    'yav' => 1,
    'men' => 1,
    'del' => 1,
    'sdc' => 1
  },
  'Mymr' => {
    'kht' => 1,
    'shn' => 1,
    'mnw' => 1,
    'mya' => 1
  },
  'Orkh' => {
    'otk' => 2
  },
  'Armi' => {
    'arc' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Wara' => {
    'hoc' => 2
  },
  'Runr' => {
    'deu' => 2,
    'non' => 2
  },
  'Mong' => {
    'mon' => 2,
    'mnc' => 2
  },
  'Plrd' => {
    'hmn' => 1,
    'hmd' => 1
  },
  'Yiii' => {
    'iii' => 1
  },
  'Armn' => {
    'hye' => 1
  },
  'Samr' => {
    'snx' => 2,
    'smp' => 2
  },
  'Talu' => {
    'khb' => 1
  },
  'Guru' => {
    'pan' => 1
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Egyp' => {
    'egy' => 2
  },
  'Arab' => {
    'zdj' => 1,
    'khw' => 1,
    'skr' => 1,
    'kaz' => 1,
    'aze' => 1,
    'raj' => 1,
    'kvx' => 1,
    'ind' => 2,
    'hno' => 1,
    'mfa' => 1,
    'dcc' => 1,
    'fas' => 1,
    'mvy' => 1,
    'wol' => 2,
    'snd' => 1,
    'arz' => 1,
    'kas' => 1,
    'doi' => 1,
    'ttt' => 2,
    'bal' => 1,
    'som' => 2,
    'tur' => 2,
    'tgk' => 1,
    'urd' => 1,
    'arq' => 1,
    'bej' => 1,
    'ary' => 1,
    'bft' => 1,
    'hnd' => 1,
    'gbz' => 1,
    'luz' => 1,
    'gjk' => 1,
    'cjm' => 2,
    'dyo' => 2,
    'rmt' => 1,
    'hau' => 1,
    'uzb' => 1,
    'gju' => 1,
    'prd' => 1,
    'sus' => 2,
    'tuk' => 1,
    'msa' => 1,
    'lrc' => 1,
    'shr' => 1,
    'fia' => 1,
    'lki' => 1,
    'aeb' => 1,
    'cop' => 2,
    'swb' => 1,
    'mzn' => 1,
    'lah' => 1,
    'tly' => 1,
    'wni' => 1,
    'ara' => 1,
    'uig' => 1,
    'sdh' => 1,
    'kxp' => 1,
    'inh' => 2,
    'cja' => 1,
    'kur' => 1,
    'brh' => 1,
    'bgn' => 1,
    'ckb' => 1,
    'pus' => 1,
    'bqi' => 1,
    'glk' => 1,
    'kir' => 1,
    'pan' => 1,
    'haz' => 1,
    'ars' => 1
  },
  'Shaw' => {
    'eng' => 2
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Merc' => {
    'xmr' => 2
  },
  'Ital' => {
    'xum' => 2,
    'osc' => 2,
    'ett' => 2
  },
  'Sund' => {
    'sun' => 2
  },
  'Nkoo' => {
    'bam' => 1,
    'nqo' => 1,
    'man' => 1
  },
  'Takr' => {
    'doi' => 2
  },
  'Nbat' => {
    'arc' => 2
  },
  'Cans' => {
    'crk' => 1,
    'crj' => 1,
    'crl' => 1,
    'cre' => 1,
    'iku' => 1,
    'oji' => 1,
    'csw' => 1,
    'crm' => 1,
    'chp' => 2,
    'nsk' => 1,
    'den' => 2
  },
  'Narb' => {
    'xna' => 2
  },
  'Ogam' => {
    'sga' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Prti' => {
    'xpr' => 2
  },
  'Orya' => {
    'ori' => 1,
    'sat' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Mand' => {
    'myz' => 2
  },
  'Kana' => {
    'ryu' => 1,
    'ain' => 2
  },
  'Modi' => {
    'mar' => 2
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Deva' => {
    'gbm' => 1,
    'gom' => 1,
    'khn' => 1,
    'san' => 2,
    'brx' => 1,
    'mtr' => 1,
    'wbr' => 1,
    'hoc' => 1,
    'noe' => 1,
    'mwr' => 1,
    'doi' => 1,
    'gvr' => 1,
    'snd' => 1,
    'kas' => 1,
    'unr' => 1,
    'anp' => 1,
    'bho' => 1,
    'wtm' => 1,
    'lif' => 1,
    'kfr' => 1,
    'rjs' => 1,
    'bra' => 1,
    'xsr' => 1,
    'kfy' => 1,
    'awa' => 1,
    'mrd' => 1,
    'bfy' => 1,
    'tdg' => 1,
    'kok' => 1,
    'tdh' => 1,
    'sat' => 2,
    'raj' => 1,
    'kru' => 1,
    'hin' => 1,
    'swv' => 1,
    'bap' => 1,
    'bjj' => 1,
    'thr' => 1,
    'bgc' => 1,
    'bhi' => 1,
    'btv' => 1,
    'dty' => 1,
    'xnr' => 1,
    'tkt' => 1,
    'mgp' => 1,
    'hoj' => 1,
    'pli' => 2,
    'mai' => 1,
    'sck' => 1,
    'hif' => 1,
    'gon' => 1,
    'new' => 1,
    'thl' => 1,
    'thq' => 1,
    'mar' => 1,
    'jml' => 1,
    'mag' => 1,
    'taj' => 1,
    'hne' => 1,
    'unx' => 1,
    'nep' => 1,
    'srx' => 1,
    'bhb' => 1
  },
  'Hebr' => {
    'jpr' => 1,
    'yid' => 1,
    'snx' => 2,
    'jrb' => 1,
    'lad' => 1,
    'heb' => 1
  },
  'Vaii' => {
    'vai' => 1
  },
  'Knda' => {
    'tcy' => 1,
    'kan' => 1
  },
  'Osma' => {
    'som' => 2
  },
  'Bopo' => {
    'zho' => 2
  }
};
$DefaultScript = {
  'pon' => 'Latn',
  'haz' => 'Arab',
  'yor' => 'Latn',
  'kjh' => 'Cyrl',
  'dtm' => 'Latn',
  'ckb' => 'Arab',
  'nhw' => 'Latn',
  'lav' => 'Latn',
  'krc' => 'Cyrl',
  'dty' => 'Deva',
  'ryu' => 'Kana',
  'stq' => 'Latn',
  'cor' => 'Latn',
  'atj' => 'Latn',
  'ewe' => 'Latn',
  'seh' => 'Latn',
  'tsg' => 'Latn',
  'ebu' => 'Latn',
  'haw' => 'Latn',
  'ban' => 'Latn',
  'smj' => 'Latn',
  'aoz' => 'Latn',
  'ibb' => 'Latn',
  'bew' => 'Latn',
  'bku' => 'Latn',
  'mak' => 'Latn',
  'kan' => 'Knda',
  'ady' => 'Cyrl',
  'kge' => 'Latn',
  'sgs' => 'Latn',
  'mdt' => 'Latn',
  'iii' => 'Yiii',
  'gle' => 'Latn',
  'sah' => 'Cyrl',
  'orm' => 'Latn',
  'nno' => 'Latn',
  'rap' => 'Latn',
  'mnw' => 'Mymr',
  'bra' => 'Deva',
  'bub' => 'Cyrl',
  'kat' => 'Geor',
  'nnh' => 'Latn',
  'sck' => 'Deva',
  'smn' => 'Latn',
  'mon' => 'Cyrl',
  'fon' => 'Latn',
  'luz' => 'Arab',
  'cos' => 'Latn',
  'gbz' => 'Arab',
  'mos' => 'Latn',
  'aar' => 'Latn',
  'hnd' => 'Arab',
  'dyo' => 'Latn',
  'crl' => 'Cans',
  'mlg' => 'Latn',
  'mfe' => 'Latn',
  'fao' => 'Latn',
  'hmn' => 'Latn',
  'eng' => 'Latn',
  'ukr' => 'Cyrl',
  'arq' => 'Arab',
  'dzo' => 'Tibt',
  'kmb' => 'Latn',
  'lus' => 'Beng',
  'hup' => 'Latn',
  'rar' => 'Latn',
  'bze' => 'Latn',
  'ace' => 'Latn',
  'srn' => 'Latn',
  'qug' => 'Latn',
  'dng' => 'Cyrl',
  'wol' => 'Latn',
  'nds' => 'Latn',
  'cgg' => 'Latn',
  'fud' => 'Latn',
  'twq' => 'Latn',
  'kht' => 'Mymr',
  'dcc' => 'Arab',
  'kha' => 'Latn',
  'brx' => 'Deva',
  'bod' => 'Tibt',
  'hno' => 'Arab',
  'por' => 'Latn',
  'ude' => 'Cyrl',
  'udm' => 'Cyrl',
  'yua' => 'Latn',
  'kac' => 'Latn',
  'yrk' => 'Cyrl',
  'glk' => 'Arab',
  'abk' => 'Cyrl',
  'crh' => 'Cyrl',
  'ssy' => 'Latn',
  'lol' => 'Latn',
  'iba' => 'Latn',
  'lmn' => 'Telu',
  'ars' => 'Arab',
  'scn' => 'Latn',
  'srr' => 'Latn',
  'nyo' => 'Latn',
  'her' => 'Latn',
  'ext' => 'Latn',
  'bqi' => 'Arab',
  'nqo' => 'Nkoo',
  'bto' => 'Latn',
  'ssw' => 'Latn',
  'bhb' => 'Deva',
  'myv' => 'Cyrl',
  'yao' => 'Latn',
  'mns' => 'Cyrl',
  'jpr' => 'Hebr',
  'new' => 'Deva',
  'jam' => 'Latn',
  'wuu' => 'Hans',
  'ksf' => 'Latn',
  'zgh' => 'Tfng',
  'kos' => 'Latn',
  'mwr' => 'Deva',
  'nbl' => 'Latn',
  'min' => 'Latn',
  'bbc' => 'Latn',
  'ale' => 'Latn',
  'tat' => 'Cyrl',
  'ybb' => 'Latn',
  'rej' => 'Latn',
  'slk' => 'Latn',
  'rmo' => 'Latn',
  'lrc' => 'Arab',
  'bug' => 'Latn',
  'gba' => 'Latn',
  'grt' => 'Beng',
  'cho' => 'Latn',
  'tam' => 'Taml',
  'bar' => 'Latn',
  'nym' => 'Latn',
  'dua' => 'Latn',
  'saq' => 'Latn',
  'nau' => 'Latn',
  'hun' => 'Latn',
  'bft' => 'Arab',
  'rmf' => 'Latn',
  'eus' => 'Latn',
  'urd' => 'Arab',
  'pms' => 'Latn',
  'yrl' => 'Latn',
  'saz' => 'Saur',
  'tsi' => 'Latn',
  'sli' => 'Latn',
  'dar' => 'Cyrl',
  'mua' => 'Latn',
  'lbw' => 'Latn',
  'vun' => 'Latn',
  'epo' => 'Latn',
  'men' => 'Latn',
  'sdc' => 'Latn',
  'rkt' => 'Beng',
  'yav' => 'Latn',
  'khn' => 'Deva',
  'hak' => 'Hans',
  'pmn' => 'Latn',
  'cic' => 'Latn',
  'sbp' => 'Latn',
  'hsn' => 'Hans',
  'saf' => 'Latn',
  'ita' => 'Latn',
  'dje' => 'Latn',
  'esu' => 'Latn',
  'tkt' => 'Deva',
  'swe' => 'Latn',
  'xog' => 'Latn',
  'buc' => 'Latn',
  'ngl' => 'Latn',
  'gub' => 'Latn',
  'nap' => 'Latn',
  'est' => 'Latn',
  'crj' => 'Cans',
  'lam' => 'Latn',
  'chy' => 'Latn',
  'syl' => 'Beng',
  'bjn' => 'Latn',
  'nia' => 'Latn',
  'sdh' => 'Arab',
  'mni' => 'Beng',
  'dsb' => 'Latn',
  'rue' => 'Cyrl',
  'lah' => 'Arab',
  'lag' => 'Latn',
  'byn' => 'Ethi',
  'zza' => 'Latn',
  'kom' => 'Cyrl',
  'tog' => 'Latn',
  'bpy' => 'Beng',
  'agq' => 'Latn',
  'kin' => 'Latn',
  'ltg' => 'Latn',
  'nld' => 'Latn',
  'cch' => 'Latn',
  'rus' => 'Cyrl',
  'bap' => 'Deva',
  'blt' => 'Tavt',
  'yid' => 'Hebr',
  'kok' => 'Deva',
  'run' => 'Latn',
  'tdh' => 'Deva',
  'aro' => 'Latn',
  'izh' => 'Latn',
  'hop' => 'Latn',
  'frp' => 'Latn',
  'bho' => 'Deva',
  'mgo' => 'Latn',
  'vro' => 'Latn',
  'arn' => 'Latn',
  'rmt' => 'Arab',
  'lug' => 'Latn',
  'bul' => 'Cyrl',
  'nso' => 'Latn',
  'mah' => 'Latn',
  'bjj' => 'Deva',
  'dak' => 'Latn',
  'ron' => 'Latn',
  'cjm' => 'Cham',
  'ceb' => 'Latn',
  'bak' => 'Cyrl',
  'rob' => 'Latn',
  'maz' => 'Latn',
  'hsb' => 'Latn',
  'lwl' => 'Thai',
  'bej' => 'Arab',
  'ljp' => 'Latn',
  'kdt' => 'Thai',
  'gld' => 'Cyrl',
  'mwl' => 'Latn',
  'bem' => 'Latn',
  'sef' => 'Latn',
  'slv' => 'Latn',
  'vmf' => 'Latn',
  'xav' => 'Latn',
  'lun' => 'Latn',
  'hin' => 'Deva',
  'ind' => 'Latn',
  'khw' => 'Arab',
  'anp' => 'Deva',
  'dtp' => 'Latn',
  'vls' => 'Latn',
  'gan' => 'Hans',
  'fry' => 'Latn',
  'mri' => 'Latn',
  'sme' => 'Latn',
  'tbw' => 'Latn',
  'car' => 'Latn',
  'bez' => 'Latn',
  'frs' => 'Latn',
  'kxp' => 'Arab',
  'hnj' => 'Laoo',
  'gay' => 'Latn',
  'amh' => 'Ethi',
  'bgn' => 'Arab',
  'kab' => 'Latn',
  'zun' => 'Latn',
  'jmc' => 'Latn',
  'moe' => 'Latn',
  'jml' => 'Deva',
  'gsw' => 'Latn',
  'chr' => 'Cher',
  'rof' => 'Latn',
  'mzn' => 'Arab',
  'hoc' => 'Deva',
  'kri' => 'Latn',
  'bbj' => 'Latn',
  'nij' => 'Latn',
  'asm' => 'Beng',
  'hai' => 'Latn',
  'luy' => 'Latn',
  'tel' => 'Telu',
  'nav' => 'Latn',
  'suk' => 'Latn',
  'afr' => 'Latn',
  'rgn' => 'Latn',
  'rup' => 'Latn',
  'gqr' => 'Latn',
  'vic' => 'Latn',
  'nog' => 'Cyrl',
  'wtm' => 'Deva',
  'pko' => 'Latn',
  'bgx' => 'Grek',
  'khb' => 'Talu',
  'hoj' => 'Deva',
  'mgp' => 'Deva',
  'kor' => 'Kore',
  'kcg' => 'Latn',
  'nob' => 'Latn',
  'tsn' => 'Latn',
  'ter' => 'Latn',
  'rcf' => 'Latn',
  'che' => 'Cyrl',
  'tah' => 'Latn',
  'kut' => 'Latn',
  'nxq' => 'Latn',
  'njo' => 'Latn',
  'zap' => 'Latn',
  'bvb' => 'Latn',
  'sei' => 'Latn',
  'thq' => 'Deva',
  'chm' => 'Cyrl',
  'mnu' => 'Latn',
  'ton' => 'Latn',
  'cha' => 'Latn',
  'pfl' => 'Latn',
  'szl' => 'Latn',
  'ndo' => 'Latn',
  'chp' => 'Latn',
  'bqv' => 'Latn',
  'kau' => 'Latn',
  'guj' => 'Gujr',
  'gom' => 'Deva',
  'mgy' => 'Latn',
  'naq' => 'Latn',
  'ria' => 'Latn',
  'kpy' => 'Cyrl',
  'guz' => 'Latn',
  'rtm' => 'Latn',
  'amo' => 'Latn',
  'mad' => 'Latn',
  'xsr' => 'Deva',
  'ben' => 'Beng',
  'nzi' => 'Latn',
  'zha' => 'Latn',
  'bss' => 'Latn',
  'jav' => 'Latn',
  'xho' => 'Latn',
  'que' => 'Latn',
  'sma' => 'Latn',
  'wae' => 'Latn',
  'isl' => 'Latn',
  'krj' => 'Latn',
  'gur' => 'Latn',
  'tru' => 'Latn',
  'ikt' => 'Latn',
  'pdc' => 'Latn',
  'pus' => 'Arab',
  'quc' => 'Latn',
  'cja' => 'Arab',
  'zul' => 'Latn',
  'hne' => 'Deva',
  'mkd' => 'Cyrl',
  'taj' => 'Deva',
  'dgr' => 'Latn',
  'chk' => 'Latn',
  'lmo' => 'Latn',
  'mwv' => 'Latn',
  'ksh' => 'Latn',
  'was' => 'Latn',
  'tha' => 'Thai',
  'maf' => 'Latn',
  'wbq' => 'Telu',
  'cay' => 'Latn',
  'nod' => 'Lana',
  'cps' => 'Latn',
  'bci' => 'Latn',
  'mus' => 'Latn',
  'abr' => 'Latn',
  'mya' => 'Mymr',
  'tyv' => 'Cyrl',
  'kik' => 'Latn',
  'kdh' => 'Latn',
  'lbe' => 'Cyrl',
  'sun' => 'Latn',
  'gag' => 'Latn',
  'kfy' => 'Deva',
  'bas' => 'Latn',
  'ewo' => 'Latn',
  'rmu' => 'Latn',
  'war' => 'Latn',
  'din' => 'Latn',
  'kfr' => 'Deva',
  'mai' => 'Deva',
  'tmh' => 'Latn',
  'nch' => 'Latn',
  'ell' => 'Grek',
  'sqq' => 'Thai',
  'div' => 'Thaa',
  'frc' => 'Latn',
  'umb' => 'Latn',
  'fuq' => 'Latn',
  'luo' => 'Latn',
  'tur' => 'Latn',
  'vmw' => 'Latn',
  'ces' => 'Latn',
  'mag' => 'Deva',
  'evn' => 'Cyrl',
  'spa' => 'Latn',
  'kck' => 'Latn',
  'ful' => 'Latn',
  'arz' => 'Arab',
  'sin' => 'Sinh',
  'gil' => 'Latn',
  'rwk' => 'Latn',
  'teo' => 'Latn',
  'sqi' => 'Latn',
  'vep' => 'Latn',
  'gbm' => 'Deva',
  'fas' => 'Arab',
  'ach' => 'Latn',
  'ilo' => 'Latn',
  'skr' => 'Arab',
  'hrv' => 'Latn',
  'tli' => 'Latn',
  'vie' => 'Latn',
  'tab' => 'Cyrl',
  'dnj' => 'Latn',
  'kiu' => 'Latn',
  'hmo' => 'Latn',
  'zdj' => 'Arab',
  'sag' => 'Latn',
  'syi' => 'Latn',
  'egl' => 'Latn',
  'nyn' => 'Latn',
  'xnr' => 'Deva',
  'gla' => 'Latn',
  'xal' => 'Cyrl',
  'dan' => 'Latn',
  'pcm' => 'Latn',
  'gos' => 'Latn',
  'tvl' => 'Latn',
  'bhi' => 'Deva',
  'kax' => 'Latn',
  'uli' => 'Latn',
  'inh' => 'Cyrl',
  'see' => 'Latn',
  'khq' => 'Latn',
  'arp' => 'Latn',
  'arg' => 'Latn',
  'mar' => 'Deva',
  'bfq' => 'Taml',
  'sna' => 'Latn',
  'bel' => 'Cyrl',
  'gvr' => 'Deva',
  'fin' => 'Latn',
  'zag' => 'Latn',
  'kde' => 'Latn',
  'jpn' => 'Jpan',
  'fuv' => 'Latn',
  'noe' => 'Deva',
  'puu' => 'Latn',
  'kca' => 'Cyrl',
  'aii' => 'Cyrl',
  'tcy' => 'Knda',
  'tet' => 'Latn',
  'zea' => 'Latn',
  'fra' => 'Latn',
  'nya' => 'Latn',
  'asa' => 'Latn',
  'tiv' => 'Latn',
  'osa' => 'Osge',
  'tdg' => 'Deva',
  'roh' => 'Latn',
  'mwk' => 'Latn',
  'mdf' => 'Cyrl',
  'fia' => 'Arab',
  'ffm' => 'Latn',
  'deu' => 'Latn',
  'scs' => 'Latn',
  'myx' => 'Latn',
  'kjg' => 'Laoo',
  'lao' => 'Laoo',
  'fvr' => 'Latn',
  'mic' => 'Latn',
  'nde' => 'Latn',
  'den' => 'Latn',
  'bla' => 'Latn',
  'bzx' => 'Latn',
  'pag' => 'Latn',
  'gjk' => 'Arab',
  'fil' => 'Latn',
  'btv' => 'Deva',
  'guc' => 'Latn',
  'thr' => 'Deva',
  'cjs' => 'Cyrl',
  'lis' => 'Lisu',
  'kdx' => 'Latn',
  'grb' => 'Latn',
  'ckt' => 'Cyrl',
  'bfd' => 'Latn',
  'kxm' => 'Thai',
  'lcp' => 'Thai',
  'wbr' => 'Deva',
  'akz' => 'Latn',
  'efi' => 'Latn',
  'lep' => 'Lepc',
  'del' => 'Latn',
  'mfa' => 'Arab',
  'eky' => 'Kali',
  'ava' => 'Cyrl',
  'jgo' => 'Latn',
  'raj' => 'Deva',
  'sat' => 'Olck',
  'kua' => 'Latn',
  'ast' => 'Latn',
  'tsj' => 'Tibt',
  'xmf' => 'Geor',
  'kea' => 'Latn',
  'lit' => 'Latn',
  'kvx' => 'Arab',
  'gwi' => 'Latn',
  'sco' => 'Latn',
  'hmd' => 'Plrd',
  'rjs' => 'Deva',
  'wal' => 'Ethi',
  'aln' => 'Latn',
  'eka' => 'Latn',
  'bax' => 'Bamu',
  'tum' => 'Latn',
  'sms' => 'Latn',
  'rug' => 'Latn',
  'fit' => 'Latn',
  'bgc' => 'Deva',
  'nsk' => 'Cans',
  'snk' => 'Latn',
  'trv' => 'Latn',
  'brh' => 'Arab',
  'jrb' => 'Hebr',
  'oci' => 'Latn',
  'tkl' => 'Latn',
  'kal' => 'Latn',
  'bre' => 'Latn',
  'kpe' => 'Latn',
  'ara' => 'Arab',
  'wni' => 'Arab',
  'aym' => 'Latn',
  'tsd' => 'Grek',
  'bmv' => 'Latn',
  'gcr' => 'Latn',
  'hye' => 'Armn',
  'frr' => 'Latn',
  'oji' => 'Cans',
  'oss' => 'Cyrl',
  'crs' => 'Latn',
  'sly' => 'Latn',
  'ttj' => 'Latn',
  'bin' => 'Latn',
  'lez' => 'Cyrl',
  'bfy' => 'Deva',
  'abq' => 'Cyrl',
  'tpi' => 'Latn',
  'lki' => 'Arab',
  'lim' => 'Latn',
  'gju' => 'Arab',
  'prd' => 'Arab',
  'grn' => 'Latn',
  'pol' => 'Latn',
  'sus' => 'Latn',
  'kgp' => 'Latn',
  'srd' => 'Latn',
  'wbp' => 'Latn',
  'smo' => 'Latn',
  'sad' => 'Latn',
  'lin' => 'Latn',
  'tts' => 'Thai',
  'mas' => 'Latn',
  'lij' => 'Latn',
  'dyu' => 'Latn',
  'wln' => 'Latn',
  'nep' => 'Deva',
  'sid' => 'Latn',
  'kln' => 'Latn',
  'ctd' => 'Latn',
  'heb' => 'Hebr',
  'dav' => 'Latn',
  'niu' => 'Latn',
  'kaa' => 'Cyrl',
  'lad' => 'Hebr',
  'mro' => 'Latn',
  'thl' => 'Deva',
  'yap' => 'Latn',
  'wls' => 'Latn',
  'bkm' => 'Latn',
  'kyu' => 'Kali',
  'khm' => 'Khmr',
  'pap' => 'Latn',
  'lub' => 'Latn',
  'mvy' => 'Arab',
  'mgh' => 'Latn',
  'kbd' => 'Cyrl',
  'ada' => 'Latn',
  'kru' => 'Deva',
  'lua' => 'Latn',
  'crm' => 'Cans',
  'sxn' => 'Latn',
  'swv' => 'Deva',
  'ttb' => 'Latn',
  'byv' => 'Latn',
  'zmi' => 'Latn',
  'kon' => 'Latn',
  'bis' => 'Latn',
  'mrj' => 'Cyrl',
  'srb' => 'Latn',
  'crk' => 'Cans',
  'srx' => 'Deva',
  'csw' => 'Cans',
  'ndc' => 'Latn',
  'lkt' => 'Latn',
  'glg' => 'Latn',
  'loz' => 'Latn',
  'nmg' => 'Latn',
  'kkj' => 'Latn',
  'vec' => 'Latn',
  'hil' => 'Latn',
  'mxc' => 'Latn',
  'hat' => 'Latn',
  'nhe' => 'Latn',
  'aeb' => 'Arab',
  'swb' => 'Arab',
  'laj' => 'Latn',
  'mtr' => 'Deva',
  'moh' => 'Latn',
  'shn' => 'Mymr',
  'mdh' => 'Latn',
  'kfo' => 'Latn',
  'ksb' => 'Latn',
  'tig' => 'Ethi',
  'sot' => 'Latn',
  'sas' => 'Latn',
  'bik' => 'Latn',
  'cad' => 'Latn',
  'hnn' => 'Latn',
  'aka' => 'Latn',
  'kkt' => 'Cyrl',
  'pau' => 'Latn',
  'rng' => 'Latn',
  'fij' => 'Latn',
  'alt' => 'Cyrl',
  'tdd' => 'Tale',
  'swg' => 'Latn',
  'ary' => 'Arab',
  'ibo' => 'Latn',
  'tso' => 'Latn',
  'ltz' => 'Latn',
  'pdt' => 'Latn',
  'pcd' => 'Latn',
  'swa' => 'Latn',
  'glv' => 'Latn',
  'ses' => 'Latn',
  'kum' => 'Cyrl',
  'ven' => 'Latn',
  'mlt' => 'Latn',
  'kaj' => 'Latn',
  'doi' => 'Arab',
  'chv' => 'Cyrl',
  'ori' => 'Orya',
  'bmq' => 'Latn',
  'som' => 'Latn',
  'cat' => 'Latn',
  'tir' => 'Ethi',
  'bal' => 'Arab',
  'kvr' => 'Latn',
  'nan' => 'Hans',
  'mls' => 'Latn',
  'mal' => 'Mlym',
  'cym' => 'Latn',
  'rom' => 'Latn',
  'ife' => 'Latn',
  'ipk' => 'Latn',
  'krl' => 'Latn',
  'mrd' => 'Deva',
  'mdr' => 'Latn',
  'awa' => 'Deva',
  'nus' => 'Latn',
  'fan' => 'Latn'
};
$DefaultTerritory = {
  'afr' => 'ZA',
  'wtm' => 'IN',
  'gqr' => 'ID',
  'suk' => 'TZ',
  'lo' => 'LA',
  'tel' => 'IN',
  'lu' => 'CD',
  'asm' => 'IN',
  'luy' => 'KE',
  'ca' => 'ES',
  'an' => 'ES',
  'unr' => 'IN',
  'gsw' => 'CH',
  'fa' => 'IR',
  'sg' => 'CF',
  'kri' => 'SL',
  'chr' => 'US',
  'rof' => 'TZ',
  'mzn' => 'IR',
  'hoc' => 'IN',
  'jmc' => 'TZ',
  'bo' => 'CN',
  'ts' => 'ZA',
  'tnr' => 'SN',
  'sd_Arab' => 'PK',
  'amh' => 'ET',
  'my' => 'MM',
  'en' => 'US',
  'am' => 'ET',
  'kab' => 'DZ',
  'bgn' => 'PK',
  'bez' => 'TZ',
  'ig' => 'NG',
  'sme' => 'NO',
  'mri' => 'NZ',
  'mn' => 'MN',
  'fry' => 'NL',
  'ben' => 'BD',
  'zha' => 'CN',
  'jav' => 'ID',
  'bss' => 'CM',
  'or' => 'IN',
  'nn' => 'NO',
  'naq' => 'NA',
  'guz' => 'KE',
  'mad' => 'ID',
  'guj' => 'IN',
  'gom' => 'IN',
  'sq' => 'AL',
  'szl' => 'PL',
  'aze_Cyrl' => 'AZ',
  've' => 'ZA',
  'ndo' => 'NA',
  'cha' => 'GU',
  'se' => 'NO',
  'iku' => 'CA',
  'fur' => 'IT',
  'wo' => 'SN',
  'ton' => 'TO',
  'mnu' => 'KE',
  'tah' => 'PF',
  'da' => 'DK',
  'rcf' => 'RE',
  'che' => 'RU',
  'iu' => 'CA',
  'nob' => 'NO',
  'tsn' => 'ZA',
  'kor' => 'KR',
  'kcg' => 'NG',
  'sa' => 'IN',
  'ii' => 'CN',
  'mon_Mong' => 'CN',
  'sun_Latn' => 'ID',
  'hoj' => 'IN',
  'mr' => 'IN',
  'rus' => 'RU',
  'blt' => 'VN',
  'kok' => 'IN',
  'run' => 'BI',
  'kin' => 'RW',
  'nld' => 'NL',
  'agq' => 'CM',
  'lat' => 'VA',
  'cch' => 'NG',
  'oc' => 'FR',
  'zza' => 'TR',
  'kom' => 'RU',
  'pan_Arab' => 'PK',
  'lah' => 'PK',
  'byn' => 'ER',
  'lag' => 'TZ',
  'ccp' => 'BD',
  'sdh' => 'IR',
  'sn' => 'ZW',
  'bjn' => 'ID',
  'syl' => 'BD',
  'dsb' => 'DE',
  'mni' => 'IN',
  'tn' => 'ZA',
  'buc' => 'YT',
  'ngl' => 'MZ',
  'est' => 'EE',
  'sav' => 'SN',
  'hin_Latn' => 'IN',
  'dje' => 'NE',
  'rn' => 'BI',
  'xog' => 'UG',
  'swe' => 'SE',
  'iku_Latn' => 'CA',
  'ee' => 'GH',
  'srp_Latn' => 'RS',
  'gan' => 'CN',
  'vls' => 'BE',
  'bs_Cyrl' => 'BA',
  'hin' => 'IN',
  'ind' => 'ID',
  'so' => 'SO',
  'sc' => 'IT',
  'gv' => 'IM',
  'bem' => 'ZM',
  'chu' => 'RU',
  'yo' => 'NG',
  'slv' => 'SI',
  'vmf' => 'DE',
  'sef' => 'CI',
  'ljp' => 'ID',
  'mer' => 'KE',
  'bej' => 'SD',
  'nd' => 'ZW',
  'ceb' => 'PH',
  'bak' => 'RU',
  'zh_Hant' => 'TW',
  'ur' => 'PK',
  'co' => 'FR',
  'hsb' => 'DE',
  'mah' => 'MH',
  'nso' => 'ZA',
  'ful_Latn' => 'SN',
  'bjj' => 'IN',
  'ron' => 'RO',
  'snd_Arab' => 'PK',
  'ru' => 'RU',
  'rmt' => 'IR',
  'gd' => 'GB',
  'mgo' => 'CM',
  'arn' => 'CL',
  'bul' => 'BG',
  'uz_Arab' => 'AF',
  'lug' => 'UG',
  'tam' => 'IN',
  'tuk' => 'TM',
  'lrc' => 'IR',
  'rej' => 'ID',
  'tat' => 'RU',
  'slk' => 'SK',
  'bug' => 'ID',
  'min' => 'ID',
  'bbc' => 'ID',
  'ha' => 'NG',
  'jam' => 'JM',
  'wuu' => 'CN',
  'ksf' => 'CM',
  'mwr' => 'IN',
  'nbl' => 'ZA',
  'fi' => 'FI',
  'zgh' => 'MA',
  'uk' => 'UA',
  'yue_Hans' => 'CN',
  'az_Arab' => 'IR',
  'myv' => 'RU',
  'bhb' => 'IN',
  'de' => 'DE',
  'ro' => 'RO',
  'srr' => 'SN',
  'scn' => 'IT',
  'nqo' => 'GN',
  'ssw' => 'ZA',
  'bqi' => 'IR',
  'glk' => 'IR',
  'abk' => 'GE',
  'bg' => 'BG',
  'bos' => 'BA',
  'lmn' => 'IN',
  'ssy' => 'ER',
  'sbp' => 'TZ',
  'az_Latn' => 'AZ',
  'hsn' => 'CN',
  'hu' => 'HU',
  'ita' => 'IT',
  'ks_Arab' => 'IN',
  'ug' => 'CN',
  'gez' => 'ET',
  'ken' => 'CM',
  'ps' => 'AF',
  'sd_Deva' => 'IN',
  'pmn' => 'PH',
  'cic' => 'US',
  'men' => 'SL',
  'hak' => 'CN',
  'khn' => 'IN',
  'yav' => 'CM',
  'vun' => 'TZ',
  'kas_Deva' => 'IN',
  'cs' => 'CZ',
  'kk' => 'KZ',
  'nr' => 'ZA',
  'eus' => 'ES',
  'urd' => 'PK',
  'vai_Vaii' => 'LR',
  'sw' => 'TZ',
  'mua' => 'CM',
  'eng_Dsrt' => 'US',
  'st' => 'ZA',
  'bam' => 'ML',
  'hun' => 'HU',
  'ful_Adlm' => 'GN',
  'shi_Latn' => 'MA',
  'zu' => 'ZA',
  'nau' => 'NR',
  'dua' => 'CM',
  'gon' => 'IN',
  'nym' => 'TZ',
  'saq' => 'KE',
  'hau' => 'NG',
  'kat' => 'GE',
  'gle' => 'IE',
  'msa' => 'MY',
  'shr' => 'MA',
  'sl' => 'SI',
  'sah' => 'RU',
  'orm' => 'ET',
  'nno' => 'NO',
  'br' => 'FR',
  'iii' => 'CN',
  'mk' => 'MK',
  'srp_Cyrl' => 'RS',
  'kan' => 'IN',
  'uz_Cyrl' => 'UZ',
  'aze_Latn' => 'AZ',
  'ady' => 'RU',
  'ku' => 'TR',
  'mak' => 'ID',
  'ak' => 'GH',
  'haw' => 'US',
  'ban' => 'ID',
  'tsg' => 'PH',
  'ebu' => 'KE',
  'ibb' => 'NG',
  'bew' => 'ID',
  'smj' => 'SE',
  'shi_Tfng' => 'MA',
  'ckb' => 'IQ',
  'krc' => 'RU',
  'lav' => 'LV',
  'tg' => 'TJ',
  'seh' => 'MZ',
  'cor' => 'GB',
  'ewe' => 'GH',
  'pa_Arab' => 'PK',
  'nl' => 'NL',
  'to' => 'TO',
  'pon' => 'FM',
  'pt' => 'BR',
  'haz' => 'AF',
  'wa' => 'BE',
  'yor' => 'NG',
  'aa' => 'ET',
  'udm' => 'RU',
  'hau_Arab' => 'NG',
  'gn' => 'PY',
  'bod' => 'CN',
  'hno' => 'PK',
  'por' => 'BR',
  'dcc' => 'IN',
  'kha' => 'IN',
  'brx' => 'IN',
  'fud' => 'WF',
  'el' => 'GR',
  'twq' => 'NE',
  'mey' => 'SN',
  'wol' => 'SN',
  'ace' => 'ID',
  'srn' => 'SR',
  'rw' => 'RW',
  'nds' => 'DE',
  'cgg' => 'UG',
  'kmb' => 'AO',
  'arq' => 'DZ',
  'dzo' => 'BT',
  'et' => 'EE',
  'uzb_Latn' => 'UZ',
  'mfe' => 'MU',
  'fao' => 'FO',
  'mlg' => 'MG',
  'ukr' => 'UA',
  'iu_Latn' => 'CA',
  'eng' => 'US',
  'mos' => 'BF',
  'aar' => 'ET',
  'luz' => 'IR',
  'cos' => 'FR',
  'ha_Arab' => 'NG',
  'uzb_Cyrl' => 'UZ',
  'ln' => 'CD',
  'dyo' => 'SN',
  'sck' => 'IN',
  'nnh' => 'CM',
  'yue_Hant' => 'HK',
  'smn' => 'FI',
  'mon' => 'MN',
  'fon' => 'BJ',
  'sot' => 'ZA',
  'af' => 'ZA',
  'ms' => 'MY',
  'sas' => 'ID',
  'bik' => 'PH',
  'cad' => 'US',
  'fo' => 'FO',
  'bhk' => 'PH',
  'ksb' => 'TZ',
  'tig' => 'ER',
  'ky' => 'KG',
  'mtr' => 'IN',
  'snd_Deva' => 'IN',
  'mdh' => 'PH',
  'ms_Arab' => 'MY',
  'shn' => 'MM',
  'moh' => 'CA',
  'lt' => 'LT',
  'hat' => 'HT',
  'aeb' => 'TN',
  'hil' => 'PH',
  'laj' => 'UG',
  'swb' => 'YT',
  'glg' => 'ES',
  'nmg' => 'CM',
  'lkt' => 'US',
  'sat_Deva' => 'IN',
  'kkj' => 'CM',
  'ndc' => 'MZ',
  'it' => 'IT',
  'ne' => 'NP',
  'bm' => 'ML',
  'hif' => 'FJ',
  'kon' => 'CD',
  'bis' => 'VU',
  'bn' => 'BD',
  'sr_Cyrl' => 'RS',
  'awa' => 'IN',
  'fan' => 'GQ',
  'nus' => 'SS',
  'kaz' => 'KZ',
  'knf' => 'SN',
  'ife' => 'TG',
  'km' => 'KH',
  'kw' => 'GB',
  'nan' => 'CN',
  'cu' => 'RU',
  'sr_Latn' => 'RS',
  'mal' => 'IN',
  'cym' => 'GB',
  'ori' => 'IN',
  'kas' => 'IN',
  'chv' => 'RU',
  'kaj' => 'NG',
  'doi' => 'IN',
  'tir' => 'ET',
  'som' => 'SO',
  'cat' => 'ES',
  'ses' => 'ML',
  'mfv' => 'SN',
  'glv' => 'IM',
  'swa' => 'TZ',
  'qu' => 'PE',
  'ven' => 'ZA',
  'mlt' => 'MT',
  'kum' => 'RU',
  'ary' => 'MA',
  'lb' => 'LU',
  'ibo' => 'NG',
  'pan_Guru' => 'IN',
  'ltz' => 'LU',
  'cy' => 'GB',
  'tso' => 'ZA',
  'aka' => 'GH',
  'pau' => 'PW',
  'cv' => 'RU',
  'msa_Arab' => 'MY',
  'fij' => 'FJ',
  'kkt' => 'RU',
  'sus' => 'GN',
  'tzm' => 'MA',
  'grn' => 'PY',
  'pol' => 'PL',
  'bin' => 'NG',
  'lez' => 'RU',
  'kn' => 'IN',
  'tpi' => 'PG',
  'eu' => 'ES',
  'crs' => 'SC',
  'oss' => 'GE',
  'ta' => 'IN',
  'hr' => 'HR',
  'aym' => 'BO',
  'bmv' => 'CM',
  'gcr' => 'GF',
  'hye' => 'AM',
  'tkl' => 'TK',
  'kal' => 'GL',
  'oci' => 'FR',
  'kpe' => 'LR',
  'bre' => 'FR',
  'wni' => 'KM',
  'snk' => 'ML',
  'trv' => 'TW',
  'kur' => 'TR',
  'fy' => 'NL',
  'brh' => 'PK',
  'bgc' => 'IN',
  'gu' => 'IN',
  'vi' => 'VN',
  'aln' => 'XK',
  'ml' => 'IN',
  'be' => 'BY',
  'tum' => 'MW',
  'mg' => 'MG',
  'sms' => 'FI',
  'id' => 'ID',
  'ff_Adlm' => 'GN',
  'rif' => 'MA',
  'swv' => 'IN',
  'ttb' => 'GH',
  'kru' => 'IN',
  'lua' => 'CD',
  'khm' => 'KH',
  'zh_Hans' => 'CN',
  'lub' => 'CD',
  'mgh' => 'MZ',
  'kbd' => 'RU',
  'ff_Latn' => 'SN',
  'shr_Tfng' => 'MA',
  'ja' => 'JP',
  'wls' => 'WF',
  'niu' => 'NU',
  'si' => 'LK',
  'heb' => 'IL',
  'wln' => 'BE',
  'nep' => 'NP',
  'ti' => 'ET',
  'sid' => 'ET',
  'kln' => 'KE',
  'dav' => 'KE',
  'ba' => 'RU',
  'kam' => 'KE',
  'sk' => 'SK',
  'lin' => 'CD',
  'dyu' => 'BF',
  'pa_Guru' => 'IN',
  'mas' => 'KE',
  'tts' => 'TH',
  'srd' => 'IT',
  'csb' => 'PL',
  'mn_Mong' => 'CN',
  'wbp' => 'AU',
  'lao' => 'LA',
  'myx' => 'UG',
  'deu' => 'DE',
  'fvr' => 'IT',
  'kl' => 'GL',
  'tiv' => 'NG',
  'osa' => 'US',
  'bs_Latn' => 'BA',
  'asa' => 'TZ',
  'nya' => 'MW',
  'ffm' => 'ML',
  'om' => 'ET',
  'en_Dsrt' => 'US',
  'roh' => 'CH',
  'mdf' => 'RU',
  'bm_Nkoo' => 'ML',
  'fra' => 'FR',
  'tcy' => 'IN',
  'tet' => 'TL',
  'tr' => 'TR',
  'fin' => 'FI',
  'jpn' => 'JP',
  'fuv' => 'NG',
  'ga' => 'IE',
  'noe' => 'IN',
  'kde' => 'TZ',
  'arg' => 'ES',
  'mar' => 'IN',
  'bel' => 'BY',
  'pl' => 'PL',
  'uig' => 'CN',
  'sna' => 'ZW',
  'inh' => 'RU',
  'ce' => 'RU',
  'khq' => 'ML',
  'pcm' => 'NG',
  'bhi' => 'IN',
  'sat_Olck' => 'IN',
  'tvl' => 'TV',
  'nyn' => 'UG',
  'shr_Latn' => 'MA',
  'th' => 'TH',
  'dan' => 'DK',
  'xnr' => 'IN',
  'gla' => 'GB',
  'sco' => 'GB',
  'wal' => 'ET',
  'raj' => 'IN',
  'jgo' => 'CM',
  'sat' => 'IN',
  'kea' => 'CV',
  'lit' => 'LT',
  'kua' => 'NA',
  'ast' => 'ES',
  'mfa' => 'TH',
  'bjt' => 'SN',
  'lg' => 'UG',
  'ava' => 'RU',
  'syr' => 'IQ',
  'kxm' => 'TH',
  'lv' => 'LV',
  'efi' => 'NG',
  'bam_Nkoo' => 'ML',
  'wbr' => 'IN',
  'os' => 'GE',
  'hi_Latn' => 'IN',
  'tk' => 'TM',
  'ny' => 'MW',
  'kdx' => 'KE',
  'nb' => 'NO',
  'snf' => 'SN',
  'hi' => 'IN',
  'fil' => 'PH',
  'ki' => 'KE',
  'xh' => 'ZA',
  'mt' => 'MT',
  'nde' => 'ZW',
  'pag' => 'PH',
  'es' => 'ES',
  'kfy' => 'IN',
  'war' => 'PH',
  'bas' => 'CM',
  'sv' => 'SE',
  'ewo' => 'CM',
  'kik' => 'KE',
  'sun' => 'ID',
  'uz_Latn' => 'UZ',
  'kdh' => 'SL',
  'lbe' => 'RU',
  'tt' => 'RU',
  'nod' => 'TH',
  'san' => 'IN',
  'mya' => 'MM',
  'tyv' => 'RU',
  'bci' => 'CI',
  'mus' => 'US',
  'abr' => 'GH',
  'tha' => 'TH',
  'ksh' => 'DE',
  'wbq' => 'IN',
  'su_Latn' => 'ID',
  'gl' => 'ES',
  'chk' => 'FM',
  'bos_Cyrl' => 'BA',
  'uzb_Arab' => 'AF',
  'dv' => 'MV',
  'quc' => 'GT',
  'hne' => 'IN',
  'mkd' => 'MK',
  'zul' => 'ZA',
  'ikt' => 'CA',
  'pus' => 'AF',
  'zho_Hans' => 'CN',
  'kir' => 'KG',
  'jv' => 'ID',
  'xho' => 'ZA',
  'que' => 'PE',
  'sma' => 'SE',
  'bos_Latn' => 'BA',
  'fr' => 'FR',
  'wae' => 'CH',
  'isl' => 'IS',
  'zdj' => 'KM',
  'hmo' => 'PG',
  'sag' => 'CF',
  'mni_Mtei' => 'IN',
  'ks_Deva' => 'IN',
  'vai_Latn' => 'LR',
  'hrv' => 'HR',
  'skr' => 'PK',
  'ilo' => 'PH',
  'dnj' => 'CI',
  'az_Cyrl' => 'AZ',
  'vie' => 'VN',
  'he' => 'IL',
  'teo' => 'UG',
  'sqi' => 'AL',
  'fas' => 'IR',
  'dz' => 'BT',
  'ach' => 'UG',
  'mni_Beng' => 'IN',
  'gbm' => 'IN',
  'te' => 'IN',
  'arz' => 'EG',
  'rwk' => 'TZ',
  'gil' => 'KI',
  'sin' => 'LK',
  'hy' => 'AM',
  'zho_Hant' => 'TW',
  'mag' => 'IN',
  'vmw' => 'MZ',
  'aze_Arab' => 'IR',
  'tur' => 'TR',
  'ces' => 'CZ',
  'spa' => 'ES',
  'luo' => 'KE',
  'tgk' => 'TJ',
  'kas_Arab' => 'IN',
  'umb' => 'AO',
  'fuq' => 'NE',
  'mi' => 'NZ',
  'bsc' => 'SN',
  'gaa' => 'GH',
  'ko' => 'KR',
  'is' => 'IS',
  'as' => 'IN',
  'ell' => 'GR',
  'div' => 'MV',
  'sqq' => 'TH',
  'ss' => 'ZA',
  'mai' => 'IN',
  'ka' => 'GE',
  'tmh' => 'NE',
  'rm' => 'CH'
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


