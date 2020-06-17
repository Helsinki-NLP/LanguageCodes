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
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Plrd' => 'Miao',
  'Syrn' => '',
  'Tang' => 'Tangut',
  'Aran' => '',
  'Merc' => 'Meroitic_Cursive',
  'Geok' => 'Georgian',
  'Thaa' => 'Thaana',
  'Sogd' => 'Sogdian',
  'Samr' => 'Samaritan',
  'Lyci' => 'Lycian',
  'Osge' => 'Osage',
  'Wara' => 'Warang_Citi',
  'Mtei' => 'Meetei_Mayek',
  'Adlm' => 'Adlam',
  'Ogam' => 'Ogham',
  'Sarb' => 'Old_South_Arabian',
  'Laoo' => 'Lao',
  'Rjng' => 'Rejang',
  'Armn' => 'Armenian',
  'Syrc' => 'Syriac',
  'Bopo' => 'Bopomofo',
  'Elym' => 'Elymaic',
  'Hatr' => 'Hatran',
  'Armi' => 'Imperial_Aramaic',
  'Xsux' => 'Cuneiform',
  'Sora' => 'Sora_Sompeng',
  'Chrs' => 'Chorasmian',
  'Vaii' => 'Vai',
  'Gujr' => 'Gujarati',
  'Cprt' => 'Cypriot',
  'Ital' => 'Old_Italic',
  'Ahom' => 'Ahom',
  'Tagb' => 'Tagbanwa',
  'Saur' => 'Saurashtra',
  'Afak' => '',
  'Syrj' => '',
  'Khoj' => 'Khojki',
  'Cari' => 'Carian',
  'Orya' => 'Oriya',
  'Telu' => 'Telugu',
  'Shui' => '',
  'Mlym' => 'Malayalam',
  'Takr' => 'Takri',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Lepc' => 'Lepcha',
  'Latg' => '',
  'Sogo' => 'Old_Sogdian',
  'Ethi' => 'Ethiopic',
  'Goth' => 'Gothic',
  'Gran' => 'Grantha',
  'Hant' => '',
  'Sidd' => 'Siddham',
  'Loma' => '',
  'Tglg' => 'Tagalog',
  'Hebr' => 'Hebrew',
  'Batk' => 'Batak',
  'Mong' => 'Mongolian',
  'Dogr' => 'Dogra',
  'Rohg' => 'Hanifi_Rohingya',
  'Mult' => 'Multani',
  'Yiii' => 'Yi',
  'Teng' => '',
  'Diak' => 'Dives_Akuru',
  'Hmng' => 'Pahawh_Hmong',
  'Olck' => 'Ol_Chiki',
  'Cher' => 'Cherokee',
  'Toto' => '',
  'Zzzz' => 'Unknown',
  'Cirt' => '',
  'Bali' => 'Balinese',
  'Geor' => 'Georgian',
  'Soyo' => 'Soyombo',
  'Aghb' => 'Caucasian_Albanian',
  'Tfng' => 'Tifinagh',
  'Qaaa' => '',
  'Mahj' => 'Mahajani',
  'Tirh' => 'Tirhuta',
  'Avst' => 'Avestan',
  'Lana' => 'Tai_Tham',
  'Osma' => 'Osmanya',
  'Nkdb' => '',
  'Khmr' => 'Khmer',
  'Phli' => 'Inscriptional_Pahlavi',
  'Kana' => 'Katakana',
  'Gonm' => 'Masaram_Gondi',
  'Java' => 'Javanese',
  'Bhks' => 'Bhaiksuki',
  'Narb' => 'Old_North_Arabian',
  'Newa' => 'Newa',
  'Roro' => '',
  'Medf' => 'Medefaidrin',
  'Bugi' => 'Buginese',
  'Nbat' => 'Nabataean',
  'Kore' => '',
  'Hang' => 'Hangul',
  'Mand' => 'Mandaic',
  'Runr' => 'Runic',
  'Gong' => 'Gunjala_Gondi',
  'Taml' => 'Tamil',
  'Wcho' => 'Wancho',
  'Piqd' => '',
  'Brai' => 'Braille',
  'Cyrl' => 'Cyrillic',
  'Nkgb' => '',
  'Kali' => 'Kayah_Li',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Lina' => 'Linear_A',
  'Lydi' => 'Lydian',
  'Kpel' => '',
  'Phlv' => '',
  'Mend' => 'Mende_Kikakui',
  'Linb' => 'Linear_B',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Tale' => 'Tai_Le',
  'Latn' => 'Latin',
  'Khar' => 'Kharoshthi',
  'Talu' => 'New_Tai_Lue',
  'Nkoo' => 'Nko',
  'Sind' => 'Khudawadi',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Yezi' => 'Yezidi',
  'Perm' => 'Old_Permic',
  'Limb' => 'Limbu',
  'Copt' => 'Coptic',
  'Sund' => 'Sundanese',
  'Dupl' => 'Duployan',
  'Leke' => '',
  'Egyh' => '',
  'Nand' => 'Nandinagari',
  'Kits' => 'Khitan_Small_Script',
  'Inds' => '',
  'Cakm' => 'Chakma',
  'Blis' => '',
  'Kthi' => 'Kaithi',
  'Hung' => 'Old_Hungarian',
  'Phag' => 'Phags_Pa',
  'Hani' => 'Han',
  'Modi' => 'Modi',
  'Egyd' => '',
  'Zinh' => 'Inherited',
  'Grek' => 'Greek',
  'Phnx' => 'Phoenician',
  'Bass' => 'Bassa_Vah',
  'Orkh' => 'Old_Turkic',
  'Cpmn' => '',
  'Guru' => 'Gurmukhi',
  'Zsye' => '',
  'Jpan' => '',
  'Elba' => 'Elbasan',
  'Prti' => 'Inscriptional_Parthian',
  'Kitl' => '',
  'Deva' => 'Devanagari',
  'Marc' => 'Marchen',
  'Knda' => 'Kannada',
  'Tavt' => 'Tai_Viet',
  'Mani' => 'Manichaean',
  'Maka' => 'Makasar',
  'Visp' => '',
  'Arab' => 'Arabic',
  'Pauc' => 'Pau_Cin_Hau',
  'Bamu' => 'Bamum',
  'Sinh' => 'Sinhala',
  'Qabx' => '',
  'Hanb' => '',
  'Maya' => '',
  'Xpeo' => 'Old_Persian',
  'Shaw' => 'Shavian',
  'Palm' => 'Palmyrene',
  'Phlp' => 'Psalter_Pahlavi',
  'Zsym' => '',
  'Buhd' => 'Buhid',
  'Nshu' => 'Nushu',
  'Cham' => 'Cham',
  'Mroo' => 'Mro',
  'Sylo' => 'Syloti_Nagri',
  'Zanb' => 'Zanabazar_Square',
  'Jamo' => '',
  'Ugar' => 'Ugaritic',
  'Shrd' => 'Sharada',
  'Dsrt' => 'Deseret',
  'Thai' => 'Thai',
  'Syre' => '',
  'Hano' => 'Hanunoo',
  'Wole' => '',
  'Mymr' => 'Myanmar',
  'Lisu' => 'Lisu',
  'Zxxx' => '',
  'Hans' => '',
  'Cyrs' => '',
  'Jurc' => '',
  'Beng' => 'Bengali',
  'Glag' => 'Glagolitic',
  'Latf' => '',
  'Tibt' => 'Tibetan',
  'Moon' => '',
  'Sgnw' => 'SignWriting',
  'Brah' => 'Brahmi',
  'Zyyy' => 'Common',
  'Sara' => '',
  'Hira' => 'Hiragana',
  'Cans' => 'Canadian_Aboriginal',
  'Zmth' => ''
};
$ScriptName2ScriptCode = {
  'Bopomofo' => 'Bopo',
  'Sharada' => 'Shrd',
  'Hanunoo' => 'Hano',
  'Tai_Viet' => 'Tavt',
  'Ol_Chiki' => 'Olck',
  'Devanagari' => 'Deva',
  'Modi' => 'Modi',
  'Ogham' => 'Ogam',
  'Old_Permic' => 'Perm',
  'Yi' => 'Yiii',
  'Zanabazar_Square' => 'Zanb',
  'Khmer' => 'Khmr',
  'Oriya' => 'Orya',
  'Tibetan' => 'Tibt',
  'SignWriting' => 'Sgnw',
  'Syloti_Nagri' => 'Sylo',
  'Old_Italic' => 'Ital',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Miao' => 'Plrd',
  'Tai_Le' => 'Tale',
  'Syriac' => 'Syrc',
  'Meroitic_Cursive' => 'Merc',
  'Grantha' => 'Gran',
  'Linear_B' => 'Linb',
  'Wancho' => 'Wcho',
  'Sogdian' => 'Sogd',
  'Saurashtra' => 'Saur',
  'Lao' => 'Laoo',
  'Kayah_Li' => 'Kali',
  'Samaritan' => 'Samr',
  'Tai_Tham' => 'Lana',
  'Vai' => 'Vaii',
  'Carian' => 'Cari',
  'Ugaritic' => 'Ugar',
  'Old_Sogdian' => 'Sogo',
  'Masaram_Gondi' => 'Gonm',
  '' => 'Zxxx',
  'Khojki' => 'Khoj',
  'Tamil' => 'Taml',
  'Telugu' => 'Telu',
  'Myanmar' => 'Mymr',
  'Tangut' => 'Tang',
  'Shavian' => 'Shaw',
  'Kaithi' => 'Kthi',
  'Old_Turkic' => 'Orkh',
  'Cherokee' => 'Cher',
  'Old_North_Arabian' => 'Narb',
  'Duployan' => 'Dupl',
  'Medefaidrin' => 'Medf',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Dives_Akuru' => 'Diak',
  'Khitan_Small_Script' => 'Kits',
  'Unknown' => 'Zzzz',
  'Palmyrene' => 'Palm',
  'Lisu' => 'Lisu',
  'Cypriot' => 'Cprt',
  'Old_Persian' => 'Xpeo',
  'Sinhala' => 'Sinh',
  'Batak' => 'Batk',
  'Malayalam' => 'Mlym',
  'Inscriptional_Pahlavi' => 'Phli',
  'Pahawh_Hmong' => 'Hmng',
  'Runic' => 'Runr',
  'Soyombo' => 'Soyo',
  'Tifinagh' => 'Tfng',
  'Dogra' => 'Dogr',
  'Thai' => 'Thai',
  'Phoenician' => 'Phnx',
  'Cham' => 'Cham',
  'Deseret' => 'Dsrt',
  'Old_Hungarian' => 'Hung',
  'Chakma' => 'Cakm',
  'Latin' => 'Latn',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Inscriptional_Parthian' => 'Prti',
  'Inherited' => 'Zinh',
  'Hiragana' => 'Hira',
  'Gunjala_Gondi' => 'Gong',
  'Mro' => 'Mroo',
  'Coptic' => 'Copt',
  'Manichaean' => 'Mani',
  'Lepcha' => 'Lepc',
  'Tagalog' => 'Tglg',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Canadian_Aboriginal' => 'Cans',
  'Lydian' => 'Lydi',
  'New_Tai_Lue' => 'Talu',
  'Buginese' => 'Bugi',
  'Han' => 'Hani',
  'Armenian' => 'Armn',
  'Ahom' => 'Ahom',
  'Hatran' => 'Hatr',
  'Bamum' => 'Bamu',
  'Bengali' => 'Beng',
  'Rejang' => 'Rjng',
  'Kharoshthi' => 'Khar',
  'Bhaiksuki' => 'Bhks',
  'Psalter_Pahlavi' => 'Phlp',
  'Mende_Kikakui' => 'Mend',
  'Nushu' => 'Nshu',
  'Limbu' => 'Limb',
  'Arabic' => 'Arab',
  'Lycian' => 'Lyci',
  'Osmanya' => 'Osma',
  'Brahmi' => 'Brah',
  'Pau_Cin_Hau' => 'Pauc',
  'Tirhuta' => 'Tirh',
  'Katakana' => 'Kana',
  'Greek' => 'Grek',
  'Elymaic' => 'Elym',
  'Javanese' => 'Java',
  'Hanifi_Rohingya' => 'Rohg',
  'Yezidi' => 'Yezi',
  'Sora_Sompeng' => 'Sora',
  'Tagbanwa' => 'Tagb',
  'Sundanese' => 'Sund',
  'Caucasian_Albanian' => 'Aghb',
  'Meetei_Mayek' => 'Mtei',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Multani' => 'Mult',
  'Common' => 'Zyyy',
  'Linear_A' => 'Lina',
  'Cyrillic' => 'Cyrl',
  'Gujarati' => 'Gujr',
  'Braille' => 'Brai',
  'Siddham' => 'Sidd',
  'Mandaic' => 'Mand',
  'Newa' => 'Newa',
  'Buhid' => 'Buhd',
  'Imperial_Aramaic' => 'Armi',
  'Elbasan' => 'Elba',
  'Osage' => 'Osge',
  'Phags_Pa' => 'Phag',
  'Hebrew' => 'Hebr',
  'Old_South_Arabian' => 'Sarb',
  'Warang_Citi' => 'Wara',
  'Khudawadi' => 'Sind',
  'Chorasmian' => 'Chrs',
  'Takri' => 'Takr',
  'Marchen' => 'Marc',
  'Hangul' => 'Hang',
  'Gurmukhi' => 'Guru',
  'Mongolian' => 'Mong',
  'Mahajani' => 'Mahj',
  'Balinese' => 'Bali',
  'Nko' => 'Nkoo',
  'Nabataean' => 'Nbat',
  'Thaana' => 'Thaa',
  'Adlam' => 'Adlm',
  'Georgian' => 'Geor',
  'Nandinagari' => 'Nand',
  'Kannada' => 'Knda',
  'Gothic' => 'Goth',
  'Avestan' => 'Avst',
  'Makasar' => 'Maka',
  'Ethiopic' => 'Ethi',
  'Cuneiform' => 'Xsux',
  'Glagolitic' => 'Glag',
  'Bassa_Vah' => 'Bass'
};
$ScriptId2ScriptCode = {
  '060' => 'Egyh',
  '755' => 'Dupl',
  '128' => 'Elym',
  '116' => 'Lydi',
  '142' => 'Sogo',
  '176' => 'Hung',
  '357' => 'Kali',
  '219' => 'Osge',
  '293' => 'Piqd',
  '312' => 'Gong',
  '302' => 'Sidd',
  '220' => 'Cyrl',
  '286' => 'Hang',
  '134' => 'Avst',
  '339' => 'Zanb',
  '260' => 'Osma',
  '355' => 'Khmr',
  '201' => 'Cari',
  '348' => 'Sinh',
  '323' => 'Mult',
  '284' => 'Jamo',
  '358' => 'Cham',
  '020' => 'Xsux',
  '435' => 'Bamu',
  '127' => 'Hatr',
  '105' => 'Sarb',
  '101' => 'Merc',
  '204' => 'Copt',
  '132' => 'Phlp',
  '360' => 'Bali',
  '217' => 'Latf',
  '290' => 'Teng',
  '263' => 'Pauc',
  '030' => 'Xpeo',
  '398' => 'Sora',
  '480' => 'Wole',
  '401' => 'Linb',
  '335' => 'Lepc',
  '501' => 'Hans',
  '175' => 'Orkh',
  '334' => 'Bhks',
  '530' => 'Shui',
  '294' => 'Toto',
  '325' => 'Beng',
  '365' => 'Batk',
  '450' => 'Hmng',
  '040' => 'Ugar',
  '227' => 'Perm',
  '136' => 'Syrn',
  '373' => 'Tagb',
  '570' => 'Brai',
  '206' => 'Goth',
  '100' => 'Mero',
  '361' => 'Java',
  '085' => 'Nkdb',
  '451' => 'Hmnp',
  '399' => 'Lisu',
  '445' => 'Cher',
  '292' => 'Sara',
  '318' => 'Sind',
  '241' => 'Geok',
  '120' => 'Tfng',
  '285' => 'Bopo',
  '291' => 'Cirt',
  '050' => 'Egyp',
  '470' => 'Vaii',
  '400' => 'Lina',
  '436' => 'Kpel',
  '328' => 'Dogr',
  '347' => 'Mlym',
  '352' => 'Thai',
  '264' => 'Mroo',
  '412' => 'Hrkt',
  '215' => 'Latn',
  '319' => 'Shrd',
  '320' => 'Gujr',
  '499' => 'Nshu',
  '370' => 'Tglg',
  '997' => 'Zxxx',
  '331' => 'Phag',
  '311' => 'Nand',
  '344' => 'Saur',
  '095' => 'Sgnw',
  '225' => 'Glag',
  '402' => 'Cpmn',
  '345' => 'Knda',
  '900' => 'Qaaa',
  '503' => 'Hanb',
  '353' => 'Tale',
  '070' => 'Egyd',
  '362' => 'Sund',
  '161' => 'Aran',
  '437' => 'Loma',
  '287' => 'Kore',
  '317' => 'Kthi',
  '310' => 'Guru',
  '999' => 'Zzzz',
  '321' => 'Takr',
  '283' => 'Wcho',
  '326' => 'Tirh',
  '140' => 'Mand',
  '413' => 'Jpan',
  '364' => 'Leke',
  '239' => 'Aghb',
  '090' => 'Maya',
  '994' => 'Zinh',
  '620' => 'Roro',
  '167' => 'Rohg',
  '159' => 'Nbat',
  '210' => 'Ital',
  '141' => 'Sogd',
  '166' => 'Adlm',
  '410' => 'Hira',
  '440' => 'Cans',
  '332' => 'Marc',
  '200' => 'Grek',
  '460' => 'Yiii',
  '354' => 'Talu',
  '998' => 'Zyyy',
  '211' => 'Runr',
  '280' => 'Visp',
  '411' => 'Kana',
  '342' => 'Diak',
  '145' => 'Mong',
  '137' => 'Syrj',
  '337' => 'Mtei',
  '403' => 'Cprt',
  '550' => 'Blis',
  '340' => 'Telu',
  '165' => 'Nkoo',
  '262' => 'Wara',
  '305' => 'Khar',
  '333' => 'Newa',
  '212' => 'Ogam',
  '327' => 'Orya',
  '349' => 'Cakm',
  '170' => 'Thaa',
  '993' => 'Zsye',
  '366' => 'Maka',
  '115' => 'Phnx',
  '265' => 'Medf',
  '124' => 'Armi',
  '109' => 'Chrs',
  '259' => 'Bass',
  '202' => 'Lyci',
  '288' => 'Kits',
  '505' => 'Kitl',
  '439' => 'Afak',
  '313' => 'Gonm',
  '502' => 'Hant',
  '346' => 'Taml',
  '226' => 'Elba',
  '130' => 'Prti',
  '131' => 'Phli',
  '281' => 'Shaw',
  '080' => 'Hluw',
  '240' => 'Geor',
  '133' => 'Phlv',
  '192' => 'Yezi',
  '221' => 'Cyrs',
  '218' => 'Moon',
  '351' => 'Lana',
  '520' => 'Tang',
  '314' => 'Mahj',
  '125' => 'Hebr',
  '300' => 'Brah',
  '359' => 'Tavt',
  '356' => 'Laoo',
  '343' => 'Gran',
  '371' => 'Hano',
  '995' => 'Zmth',
  '420' => 'Nkgb',
  '329' => 'Soyo',
  '250' => 'Dsrt',
  '160' => 'Arab',
  '372' => 'Buhd',
  '330' => 'Tibt',
  '350' => 'Mymr',
  '949' => 'Qabx',
  '138' => 'Syre',
  '139' => 'Mani',
  '322' => 'Khoj',
  '123' => 'Samr',
  '336' => 'Limb',
  '282' => 'Plrd',
  '216' => 'Latg',
  '261' => 'Olck',
  '324' => 'Modi',
  '367' => 'Bugi',
  '126' => 'Palm',
  '996' => 'Zsym',
  '430' => 'Ethi',
  '363' => 'Rjng',
  '610' => 'Inds',
  '500' => 'Hani',
  '135' => 'Syrc',
  '230' => 'Armn',
  '106' => 'Narb',
  '316' => 'Sylo',
  '315' => 'Deva',
  '338' => 'Ahom',
  '438' => 'Mend',
  '510' => 'Jurc'
};
$ScriptCode2EnglishName = {
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Syrn' => 'Syriac (Eastern variant)',
  'Plrd' => 'Miao (Pollard)',
  'Tang' => 'Tangut',
  'Merc' => 'Meroitic Cursive',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Thaa' => 'Thaana',
  'Samr' => 'Samaritan',
  'Sogd' => 'Sogdian',
  'Lyci' => 'Lycian',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Osge' => 'Osage',
  'Ogam' => 'Ogham',
  'Adlm' => 'Adlam',
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Sarb' => 'Old South Arabian',
  'Laoo' => 'Lao',
  'Armn' => 'Armenian',
  'Syrc' => 'Syriac',
  'Bopo' => 'Bopomofo',
  'Hatr' => 'Hatran',
  'Elym' => 'Elymaic',
  'Sora' => 'Sora Sompeng',
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Armi' => 'Imperial Aramaic',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Gujr' => 'Gujarati',
  'Cprt' => 'Cypriot syllabary',
  'Chrs' => 'Chorasmian',
  'Vaii' => 'Vai',
  'Ahom' => 'Ahom, Tai Ahom',
  'Tagb' => 'Tagbanwa',
  'Saur' => 'Saurashtra',
  'Cari' => 'Carian',
  'Syrj' => 'Syriac (Western variant)',
  'Afak' => 'Afaka',
  'Khoj' => 'Khojki',
  'Telu' => 'Telugu',
  'Orya' => 'Oriya (Odia)',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Shui' => 'Shuishu',
  'Mlym' => 'Malayalam',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Latg' => 'Latin (Gaelic variant)',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Sogo' => 'Old Sogdian',
  'Gran' => 'Grantha',
  'Hant' => 'Han (Traditional variant)',
  'Goth' => 'Gothic',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Loma' => 'Loma',
  'Hebr' => 'Hebrew',
  'Batk' => 'Batak',
  'Dogr' => 'Dogra',
  'Mong' => 'Mongolian',
  'Rohg' => 'Hanifi Rohingya',
  'Yiii' => 'Yi',
  'Mult' => 'Multani',
  'Diak' => 'Dives Akuru',
  'Teng' => 'Tengwar',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Hmng' => 'Pahawh Hmong',
  'Cher' => 'Cherokee',
  'Toto' => 'Toto',
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Bali' => 'Balinese',
  'Zzzz' => 'Code for uncoded script',
  'Cirt' => 'Cirth',
  'Soyo' => 'Soyombo',
  'Aghb' => 'Caucasian Albanian',
  'Tfng' => 'Tifinagh (Berber)',
  'Qaaa' => 'Reserved for private use (start)',
  'Mahj' => 'Mahajani',
  'Avst' => 'Avestan',
  'Tirh' => 'Tirhuta',
  'Osma' => 'Osmanya',
  'Lana' => 'Tai Tham (Lanna)',
  'Khmr' => 'Khmer',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Gonm' => 'Masaram Gondi',
  'Phli' => 'Inscriptional Pahlavi',
  'Kana' => 'Katakana',
  'Bhks' => 'Bhaiksuki',
  'Java' => 'Javanese',
  'Roro' => 'Rongorongo',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Bugi' => 'Buginese',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Nbat' => 'Nabataean',
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Mand' => 'Mandaic, Mandaean',
  'Runr' => 'Runic',
  'Taml' => 'Tamil',
  'Gong' => 'Gunjala Gondi',
  'Wcho' => 'Wancho',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Brai' => 'Braille',
  'Kali' => 'Kayah Li',
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Cyrl' => 'Cyrillic',
  'Kpel' => 'Kpelle',
  'Lydi' => 'Lydian',
  'Lina' => 'Linear A',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Phlv' => 'Book Pahlavi',
  'Linb' => 'Linear B',
  'Mend' => 'Mende Kikakui',
  'Mero' => 'Meroitic Hieroglyphs',
  'Latn' => 'Latin',
  'Tale' => 'Tai Le',
  'Nkoo' => "N\x{2019}Ko",
  'Talu' => 'New Tai Lue',
  'Khar' => 'Kharoshthi',
  'Sind' => 'Khudawadi, Sindhi',
  'Perm' => 'Old Permic',
  'Yezi' => 'Yezidi',
  'Egyp' => 'Egyptian hieroglyphs',
  'Sund' => 'Sundanese',
  'Limb' => 'Limbu',
  'Copt' => 'Coptic',
  'Leke' => 'Leke',
  'Egyh' => 'Egyptian hieratic',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Kits' => 'Khitan small script',
  'Nand' => 'Nandinagari',
  'Kthi' => 'Kaithi',
  'Blis' => 'Blissymbols',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Cakm' => 'Chakma',
  'Inds' => 'Indus (Harappan)',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Phag' => 'Phags-pa',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Egyd' => 'Egyptian demotic',
  'Grek' => 'Greek',
  'Zinh' => 'Code for inherited script',
  'Bass' => 'Bassa Vah',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Phnx' => 'Phoenician',
  'Guru' => 'Gurmukhi',
  'Cpmn' => 'Cypro-Minoan',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Zsye' => 'Symbols (Emoji variant)',
  'Elba' => 'Elbasan',
  'Marc' => 'Marchen',
  'Prti' => 'Inscriptional Parthian',
  'Deva' => 'Devanagari (Nagari)',
  'Kitl' => 'Khitan large script',
  'Tavt' => 'Tai Viet',
  'Knda' => 'Kannada',
  'Maka' => 'Makasar',
  'Mani' => 'Manichaean',
  'Visp' => 'Visible Speech',
  'Arab' => 'Arabic',
  'Pauc' => 'Pau Cin Hau',
  'Sinh' => 'Sinhala',
  'Bamu' => 'Bamum',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Qabx' => 'Reserved for private use (end)',
  'Maya' => 'Mayan hieroglyphs',
  'Xpeo' => 'Old Persian',
  'Palm' => 'Palmyrene',
  'Shaw' => 'Shavian (Shaw)',
  'Zsym' => 'Symbols',
  'Phlp' => 'Psalter Pahlavi',
  'Mroo' => 'Mro, Mru',
  'Nshu' => "N\x{fc}shu",
  'Buhd' => 'Buhid',
  'Cham' => 'Cham',
  'Sylo' => 'Syloti Nagri',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Ugar' => 'Ugaritic',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Dsrt' => 'Deseret (Mormon)',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Syre' => 'Syriac (Estrangelo variant)',
  'Thai' => 'Thai',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Zxxx' => 'Code for unwritten documents',
  'Wole' => 'Woleai',
  'Mymr' => 'Myanmar (Burmese)',
  'Lisu' => 'Lisu (Fraser)',
  'Hans' => 'Han (Simplified variant)',
  'Jurc' => 'Jurchen',
  'Beng' => 'Bengali (Bangla)',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Latf' => 'Latin (Fraktur variant)',
  'Glag' => 'Glagolitic',
  'Tibt' => 'Tibetan',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Brah' => 'Brahmi',
  'Sgnw' => 'SignWriting',
  'Sara' => 'Sarati',
  'Zyyy' => 'Code for undetermined script',
  'Hira' => 'Hiragana',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Zmth' => 'Mathematical notation'
};
$ScriptCode2FrenchName = {
  'Mand' => "mand\x{e9}en",
  'Runr' => 'runique',
  'Gong' => "gunjala gond\x{ee}",
  'Taml' => 'tamoul',
  'Wcho' => 'wantcho',
  'Brai' => 'braille',
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Nkgb' => 'naxi geba, nakhi geba',
  'Cyrl' => 'cyrillique',
  'Kali' => 'kayah li',
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Lina' => "lin\x{e9}aire A",
  'Lydi' => 'lydien',
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Phlv' => 'pehlevi des livres',
  'Mend' => "mend\x{e9} kikakui",
  'Linb' => "lin\x{e9}aire B",
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Tale' => "ta\x{ef}-le",
  'Latn' => 'latin',
  'Khar' => "kharochth\x{ee}",
  'Talu' => "nouveau ta\x{ef}-lue",
  'Nkoo' => "n\x{2019}ko",
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Yezi' => "y\x{e9}zidi",
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Perm' => 'ancien permien',
  'Limb' => 'limbou',
  'Copt' => 'copte',
  'Sund' => 'sundanais',
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Leke' => "l\x{e9}k\x{e9}",
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Kits' => "petite \x{e9}criture khitan",
  'Inds' => 'indus',
  'Cakm' => 'chakma',
  'Blis' => 'symboles Bliss',
  'Kthi' => "kaith\x{ee}",
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Phag' => "\x{2019}phags pa",
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Modi' => "mod\x{ee}",
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Grek' => 'grec',
  'Phnx' => "ph\x{e9}nicien",
  'Bass' => 'bassa',
  'Orkh' => 'orkhon',
  'Guru' => "gourmoukh\x{ee}",
  'Cpmn' => 'syllabaire chypro-minoen',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Elba' => 'elbasan',
  'Prti' => 'parthe des inscriptions',
  'Kitl' => "grande \x{e9}criture khitan",
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Marc' => 'marchen',
  'Knda' => 'kannara (canara)',
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Mani' => "manich\x{e9}en",
  'Maka' => 'makassar',
  'Visp' => 'parole visible',
  'Arab' => 'arabe',
  'Pauc' => 'paou chin haou',
  'Bamu' => 'bamoum',
  'Sinh' => 'singhalais',
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Shaw' => 'shavien (Shaw)',
  'Palm' => "palmyr\x{e9}nien",
  'Phlp' => 'pehlevi des psautiers',
  'Zsym' => 'symboles',
  'Buhd' => 'bouhide',
  'Nshu' => "n\x{fc}shu",
  'Cham' => "cham (\x{10d}am, tcham)",
  'Mroo' => 'mro',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Zanb' => 'zanabazar quadratique',
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Ugar' => 'ougaritique',
  'Shrd' => 'charada, shard',
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Thai' => "tha\x{ef}",
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Hano' => "hanoun\x{f3}o",
  'Lisu' => 'lisu (Fraser)',
  'Wole' => "wol\x{e9}a\x{ef}",
  'Mymr' => 'birman',
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Beng' => "bengal\x{ee} (bangla)",
  'Jurc' => 'jurchen',
  'Glag' => 'glagolitique',
  'Latf' => "latin (variante bris\x{e9}e)",
  'Tibt' => "tib\x{e9}tain",
  'Moon' => "\x{e9}criture Moon",
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Brah' => 'brahma',
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Sara' => 'sarati',
  'Hira' => 'hiragana',
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Zmth' => "notation math\x{e9}matique",
  'Hmnp' => 'nyiakeng puachue hmong',
  'Syrn' => 'syriaque (variante orientale)',
  'Plrd' => 'miao (Pollard)',
  'Tang' => 'tangoute',
  'Aran' => 'arabe (variante nastalique)',
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Thaa' => "th\x{e2}na",
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Sogd' => 'sogdien',
  'Samr' => 'samaritain',
  'Lyci' => 'lycien',
  'Osge' => 'osage',
  'Wara' => 'warang citi',
  'Mtei' => 'meitei mayek',
  'Adlm' => 'adlam',
  'Ogam' => 'ogam',
  'Laoo' => 'laotien',
  'Sarb' => 'sud-arabique, himyarite',
  'Rjng' => 'redjang (kaganga)',
  'Armn' => "arm\x{e9}nien",
  'Syrc' => 'syriaque',
  'Bopo' => 'bopomofo',
  'Hatr' => "hatr\x{e9}nien",
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Sora' => 'sora sompeng',
  'Chrs' => 'chorasmien',
  'Vaii' => "va\x{ef}",
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Cprt' => 'syllabaire chypriote',
  'Ahom' => "\x{e2}hom",
  'Tagb' => 'tagbanoua',
  'Saur' => 'saurachtra',
  'Afak' => 'afaka',
  'Syrj' => 'syriaque (variante occidentale)',
  'Khoj' => "khojk\x{ee}",
  'Cari' => 'carien',
  'Orya' => "oriy\x{e2} (odia)",
  'Telu' => "t\x{e9}lougou",
  'Mlym' => "malay\x{e2}lam",
  'Shui' => 'shuishu',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Sogo' => 'ancien sogdien',
  'Gran' => 'grantha',
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Goth' => 'gotique',
  'Sidd' => 'siddham',
  'Loma' => 'loma',
  'Tglg' => 'tagal (baybayin, alibata)',
  'Batk' => 'batik',
  'Hebr' => "h\x{e9}breu",
  'Mong' => 'mongol',
  'Dogr' => 'dogra',
  'Rohg' => 'hanifi rohingya',
  'Mult' => "multan\x{ee}",
  'Yiii' => 'yi',
  'Teng' => 'tengwar',
  'Diak' => 'dives akuru',
  'Hmng' => 'pahawh hmong',
  'Olck' => 'ol tchiki',
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Toto' => 'toto',
  'Bali' => 'balinais',
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Cirt' => 'cirth',
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Soyo' => 'soyombo',
  'Aghb' => 'aghbanien',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Avst' => 'avestique',
  'Tirh' => 'tirhouta',
  'Lana' => "ta\x{ef} tham (lanna)",
  'Osma' => 'osmanais',
  'Nkdb' => 'naxi dongba',
  'Khmr' => 'khmer',
  'Kana' => 'katakana',
  'Phli' => 'pehlevi des inscriptions',
  'Gonm' => "masaram gond\x{ee}",
  'Java' => 'javanais',
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Narb' => 'nord-arabique',
  'Roro' => 'rongorongo',
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Bugi' => 'bouguis',
  'Nbat' => "nabat\x{e9}en",
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)"
};
$ScriptCodeVersion = {
  'Aran' => '1.1',
  'Merc' => '6.1',
  'Thaa' => '3.0',
  'Geok' => '1.1',
  'Tang' => '9.0',
  'Syrn' => '3.0',
  'Plrd' => '6.1',
  'Hmnp' => '12.0',
  'Syrc' => '3.0',
  'Bopo' => '1.1',
  'Sarb' => '5.2',
  'Laoo' => '1.1',
  'Rjng' => '5.1',
  'Armn' => '1.1',
  'Osge' => '9.0',
  'Wara' => '7.0',
  'Mtei' => '5.2',
  'Adlm' => '9.0',
  'Ogam' => '3.0',
  'Sogd' => '11.0',
  'Samr' => '5.2',
  'Lyci' => '5.1',
  'Tagb' => '3.2',
  'Saur' => '5.1',
  'Ahom' => '8.0',
  'Armi' => '5.2',
  'Xsux' => '5.0',
  'Sora' => '6.1',
  'Vaii' => '5.1',
  'Chrs' => '13.0',
  'Ital' => '3.1',
  'Gujr' => '1.1',
  'Cprt' => '4.0',
  'Hatr' => '8.0',
  'Elym' => '12.0',
  'Latg' => '1.1',
  'Lepc' => '5.1',
  'Hluw' => '8.0',
  'Shui' => '',
  'Mlym' => '1.1',
  'Takr' => '6.1',
  'Khoj' => '7.0',
  'Syrj' => '3.0',
  'Afak' => '',
  'Cari' => '5.1',
  'Orya' => '1.1',
  'Telu' => '1.1',
  'Rohg' => '11.0',
  'Batk' => '6.0',
  'Hebr' => '1.1',
  'Mong' => '3.0',
  'Dogr' => '11.0',
  'Sidd' => '7.0',
  'Loma' => '',
  'Tglg' => '3.2',
  'Sogo' => '11.0',
  'Ethi' => '3.0',
  'Goth' => '3.1',
  'Gran' => '7.0',
  'Hant' => '1.1',
  'Toto' => '',
  'Cirt' => '',
  'Zzzz' => '',
  'Bali' => '5.0',
  'Geor' => '1.1',
  'Hmng' => '7.0',
  'Olck' => '5.1',
  'Cher' => '3.0',
  'Teng' => '',
  'Diak' => '13.0',
  'Mult' => '8.0',
  'Yiii' => '3.0',
  'Lana' => '5.2',
  'Osma' => '4.0',
  'Nkdb' => '',
  'Khmr' => '3.0',
  'Avst' => '5.2',
  'Tirh' => '7.0',
  'Qaaa' => '',
  'Mahj' => '7.0',
  'Aghb' => '7.0',
  'Soyo' => '10.0',
  'Tfng' => '4.1',
  'Kore' => '1.1',
  'Hang' => '1.1',
  'Nbat' => '7.0',
  'Narb' => '7.0',
  'Newa' => '9.0',
  'Roro' => '',
  'Medf' => '11.0',
  'Bugi' => '4.1',
  'Kana' => '1.1',
  'Phli' => '5.2',
  'Gonm' => '10.0',
  'Java' => '5.2',
  'Bhks' => '9.0',
  'Nkgb' => '',
  'Cyrl' => '1.1',
  'Kali' => '5.1',
  'Brai' => '3.0',
  'Piqd' => '',
  'Gong' => '11.0',
  'Taml' => '1.1',
  'Wcho' => '12.0',
  'Mand' => '6.0',
  'Runr' => '3.0',
  'Khar' => '4.1',
  'Nkoo' => '5.0',
  'Talu' => '4.1',
  'Sind' => '7.0',
  'Tale' => '4.0',
  'Latn' => '1.1',
  'Mend' => '7.0',
  'Linb' => '4.0',
  'Mero' => '6.1',
  'Hrkt' => '1.1',
  'Lydi' => '5.1',
  'Lina' => '7.0',
  'Kpel' => '',
  'Phlv' => '',
  'Phag' => '5.0',
  'Hani' => '1.1',
  'Nand' => '12.0',
  'Kits' => '13.0',
  'Inds' => '',
  'Cakm' => '6.1',
  'Kthi' => '5.2',
  'Hung' => '8.0',
  'Blis' => '',
  'Limb' => '4.0',
  'Copt' => '4.1',
  'Sund' => '5.1',
  'Dupl' => '7.0',
  'Leke' => '',
  'Egyh' => '5.2',
  'Yezi' => '13.0',
  'Egyp' => '5.2',
  'Perm' => '7.0',
  'Zsye' => '6.0',
  'Jpan' => '1.1',
  'Elba' => '7.0',
  'Cpmn' => '',
  'Guru' => '1.1',
  'Zinh' => '',
  'Grek' => '1.1',
  'Phnx' => '5.0',
  'Bass' => '7.0',
  'Orkh' => '5.2',
  'Modi' => '7.0',
  'Egyd' => '',
  'Arab' => '1.1',
  'Visp' => '',
  'Knda' => '1.1',
  'Tavt' => '5.2',
  'Mani' => '7.0',
  'Maka' => '11.0',
  'Prti' => '5.2',
  'Kitl' => '',
  'Deva' => '1.1',
  'Marc' => '9.0',
  'Nshu' => '10.0',
  'Buhd' => '3.2',
  'Cham' => '5.1',
  'Mroo' => '7.0',
  'Palm' => '7.0',
  'Shaw' => '4.0',
  'Phlp' => '7.0',
  'Zsym' => '1.1',
  'Qabx' => '',
  'Hanb' => '1.1',
  'Xpeo' => '4.1',
  'Maya' => '',
  'Pauc' => '7.0',
  'Bamu' => '5.2',
  'Sinh' => '3.0',
  'Hans' => '1.1',
  'Cyrs' => '1.1',
  'Jurc' => '',
  'Beng' => '1.1',
  'Hano' => '3.2',
  'Mymr' => '3.0',
  'Wole' => '',
  'Lisu' => '5.2',
  'Zxxx' => '',
  'Shrd' => '6.1',
  'Dsrt' => '3.1',
  'Thai' => '1.1',
  'Syre' => '3.0',
  'Zanb' => '10.0',
  'Sylo' => '4.1',
  'Jamo' => '1.1',
  'Ugar' => '4.0',
  'Cans' => '3.0',
  'Hira' => '1.1',
  'Zmth' => '3.2',
  'Sgnw' => '8.0',
  'Brah' => '6.0',
  'Zyyy' => '',
  'Sara' => '',
  'Tibt' => '2.0',
  'Moon' => '',
  'Glag' => '4.1',
  'Latf' => '1.1'
};
$ScriptCodeDate = {
  'Sylo' => '2006-06-21
',
  'Zanb' => '2017-07-26
',
  'Jamo' => '2016-01-19
',
  'Ugar' => '2004-05-01
',
  'Shrd' => '2012-02-06
',
  'Dsrt' => '2004-05-01
',
  'Thai' => '2004-05-01
',
  'Syre' => '2004-05-01
',
  'Hano' => '2004-05-29
',
  'Mymr' => '2004-05-01
',
  'Wole' => '2010-12-21
',
  'Lisu' => '2009-06-01
',
  'Zxxx' => '2011-06-21
',
  'Hans' => '2004-05-29
',
  'Cyrs' => '2004-05-01
',
  'Jurc' => '2010-12-21
',
  'Beng' => '2016-12-05
',
  'Glag' => '2006-06-21
',
  'Latf' => '2004-05-01
',
  'Tibt' => '2004-05-01
',
  'Moon' => '2006-12-11
',
  'Sgnw' => '2015-07-07
',
  'Brah' => '2010-07-23
',
  'Zyyy' => '2004-05-29
',
  'Sara' => '2004-05-29
',
  'Hira' => '2004-05-01
',
  'Cans' => '2004-05-29
',
  'Zmth' => '2007-11-26
',
  'Kitl' => '2015-07-15
',
  'Prti' => '2009-06-01
',
  'Deva' => '2004-05-01
',
  'Marc' => '2016-12-05
',
  'Knda' => '2004-05-29
',
  'Tavt' => '2009-06-01
',
  'Mani' => '2014-11-15
',
  'Maka' => '2016-12-05
',
  'Visp' => '2004-05-01
',
  'Arab' => '2004-05-01
',
  'Pauc' => '2014-11-15
',
  'Bamu' => '2009-06-01
',
  'Sinh' => '2004-05-01
',
  'Qabx' => '2004-05-29
',
  'Hanb' => '2016-01-19
',
  'Xpeo' => '2006-06-21
',
  'Maya' => '2004-05-01
',
  'Palm' => '2014-11-15
',
  'Shaw' => '2004-05-01
',
  'Phlp' => '2014-11-15
',
  'Zsym' => '2007-11-26
',
  'Buhd' => '2004-05-01
',
  'Nshu' => '2017-07-26
',
  'Cham' => '2009-11-11
',
  'Mroo' => '2016-12-05
',
  'Yezi' => '2019-08-19
',
  'Egyp' => '2009-06-01
',
  'Perm' => '2014-11-15
',
  'Copt' => '2006-06-21
',
  'Limb' => '2004-05-29
',
  'Sund' => '2007-07-02
',
  'Dupl' => '2014-11-15
',
  'Leke' => '2015-07-07
',
  'Egyh' => '2004-05-01
',
  'Nand' => '2018-08-26
',
  'Kits' => '2015-07-15
',
  'Cakm' => '2012-02-06
',
  'Inds' => '2004-05-01
',
  'Kthi' => '2009-06-01
',
  'Hung' => '2015-07-07
',
  'Blis' => '2004-05-01
',
  'Phag' => '2006-10-10
',
  'Hani' => '2009-02-23
',
  'Egyd' => '2004-05-01
',
  'Modi' => '2014-11-15
',
  'Zinh' => '2009-02-23
',
  'Grek' => '2004-05-01
',
  'Phnx' => '2006-10-10
',
  'Bass' => '2014-11-15
',
  'Orkh' => '2009-06-01
',
  'Cpmn' => '2017-07-26
',
  'Guru' => '2004-05-01
',
  'Zsye' => '2015-12-16
',
  'Jpan' => '2006-06-21
',
  'Elba' => '2014-11-15
',
  'Mand' => '2010-07-23
',
  'Runr' => '2004-05-01
',
  'Gong' => '2016-12-05
',
  'Taml' => '2004-05-01
',
  'Wcho' => '2017-07-26
',
  'Brai' => '2004-05-01
',
  'Piqd' => '2015-12-16
',
  'Cyrl' => '2004-05-01
',
  'Nkgb' => '2017-07-26
',
  'Kali' => '2007-07-02
',
  'Hrkt' => '2011-06-21
',
  'Lydi' => '2007-07-02
',
  'Lina' => '2014-11-15
',
  'Kpel' => '2010-03-26
',
  'Phlv' => '2007-07-15
',
  'Mend' => '2014-11-15
',
  'Linb' => '2004-05-29
',
  'Mero' => '2012-02-06
',
  'Tale' => '2004-10-25
',
  'Latn' => '2004-05-01
',
  'Khar' => '2006-06-21
',
  'Talu' => '2006-06-21
',
  'Nkoo' => '2006-10-10
',
  'Sind' => '2014-11-15
',
  'Aghb' => '2014-11-15
',
  'Soyo' => '2017-07-26
',
  'Tfng' => '2006-06-21
',
  'Qaaa' => '2004-05-29
',
  'Mahj' => '2014-11-15
',
  'Avst' => '2009-06-01
',
  'Tirh' => '2014-11-15
',
  'Lana' => '2009-06-01
',
  'Osma' => '2004-05-01
',
  'Nkdb' => '2017-07-26
',
  'Khmr' => '2004-05-29
',
  'Phli' => '2009-06-01
',
  'Kana' => '2004-05-01
',
  'Gonm' => '2017-07-26
',
  'Java' => '2009-06-01
',
  'Bhks' => '2016-12-05
',
  'Narb' => '2014-11-15
',
  'Newa' => '2016-12-05
',
  'Roro' => '2004-05-01
',
  'Bugi' => '2006-06-21
',
  'Medf' => '2016-12-05
',
  'Nbat' => '2014-11-15
',
  'Kore' => '2007-06-13
',
  'Hang' => '2004-05-29
',
  'Sogo' => '2017-11-21
',
  'Ethi' => '2004-10-25
',
  'Gran' => '2014-11-15
',
  'Goth' => '2004-05-01
',
  'Hant' => '2004-05-29
',
  'Sidd' => '2014-11-15
',
  'Loma' => '2010-03-26
',
  'Tglg' => '2009-02-23
',
  'Hebr' => '2004-05-01
',
  'Batk' => '2010-07-23
',
  'Mong' => '2004-05-01
',
  'Dogr' => '2016-12-05
',
  'Rohg' => '2017-11-21
',
  'Mult' => '2015-07-07
',
  'Yiii' => '2004-05-01
',
  'Teng' => '2004-05-01
',
  'Diak' => '2019-08-19
',
  'Olck' => '2007-07-02
',
  'Hmng' => '2014-11-15
',
  'Cher' => '2004-05-01
',
  'Toto' => '2020-04-16
',
  'Bali' => '2006-10-10
',
  'Zzzz' => '2006-10-10
',
  'Cirt' => '2004-05-01
',
  'Geor' => '2016-12-05
',
  'Hatr' => '2015-07-07
',
  'Elym' => '2018-08-26
',
  'Xsux' => '2006-10-10
',
  'Sora' => '2012-02-06
',
  'Armi' => '2009-06-01
',
  'Chrs' => '2019-08-19
',
  'Vaii' => '2007-07-02
',
  'Gujr' => '2004-05-01
',
  'Cprt' => '2017-07-26
',
  'Ital' => '2004-05-29
',
  'Ahom' => '2015-07-07
',
  'Tagb' => '2004-05-01
',
  'Saur' => '2007-07-02
',
  'Afak' => '2010-12-21
',
  'Syrj' => '2004-05-01
',
  'Khoj' => '2014-11-15
',
  'Cari' => '2007-07-02
',
  'Orya' => '2016-12-05
',
  'Telu' => '2004-05-01
',
  'Mlym' => '2004-05-01
',
  'Shui' => '2017-07-26
',
  'Takr' => '2012-02-06
',
  'Hluw' => '2015-07-07
',
  'Lepc' => '2007-07-02
',
  'Latg' => '2004-05-01
',
  'Hmnp' => '2017-07-26
',
  'Plrd' => '2012-02-06
',
  'Syrn' => '2004-05-01
',
  'Tang' => '2016-12-05
',
  'Aran' => '2014-11-15
',
  'Merc' => '2012-02-06
',
  'Thaa' => '2004-05-01
',
  'Geok' => '2012-10-16
',
  'Sogd' => '2017-11-21
',
  'Samr' => '2009-06-01
',
  'Lyci' => '2007-07-02
',
  'Wara' => '2014-11-15
',
  'Osge' => '2016-12-05
',
  'Mtei' => '2009-06-01
',
  'Adlm' => '2016-12-05
',
  'Ogam' => '2004-05-01
',
  'Sarb' => '2009-06-01
',
  'Laoo' => '2004-05-01
',
  'Rjng' => '2009-02-23
',
  'Armn' => '2004-05-01
',
  'Syrc' => '2004-05-01
',
  'Bopo' => '2004-05-01
'
};
$ScriptCodeId = {
  'Elba' => '226',
  'Zsye' => '993',
  'Jpan' => '413',
  'Cpmn' => '402',
  'Guru' => '310',
  'Phnx' => '115',
  'Bass' => '259',
  'Orkh' => '175',
  'Zinh' => '994',
  'Grek' => '200',
  'Modi' => '324',
  'Egyd' => '070',
  'Phag' => '331',
  'Hani' => '500',
  'Inds' => '610',
  'Cakm' => '349',
  'Kthi' => '317',
  'Hung' => '176',
  'Blis' => '550',
  'Nand' => '311',
  'Kits' => '288',
  'Dupl' => '755',
  'Egyh' => '060',
  'Leke' => '364',
  'Limb' => '336',
  'Copt' => '204',
  'Sund' => '362',
  'Egyp' => '050',
  'Yezi' => '192',
  'Perm' => '227',
  'Sind' => '318',
  'Khar' => '305',
  'Talu' => '354',
  'Nkoo' => '165',
  'Tale' => '353',
  'Latn' => '215',
  'Mero' => '100',
  'Mend' => '438',
  'Linb' => '401',
  'Phlv' => '133',
  'Hrkt' => '412',
  'Lydi' => '116',
  'Kpel' => '436',
  'Lina' => '400',
  'Cyrl' => '220',
  'Nkgb' => '420',
  'Kali' => '357',
  'Brai' => '570',
  'Piqd' => '293',
  'Wcho' => '283',
  'Gong' => '312',
  'Taml' => '346',
  'Runr' => '211',
  'Mand' => '140',
  'Zmth' => '995',
  'Hira' => '410',
  'Cans' => '440',
  'Zyyy' => '998',
  'Sara' => '292',
  'Sgnw' => '095',
  'Brah' => '300',
  'Moon' => '218',
  'Tibt' => '330',
  'Glag' => '225',
  'Latf' => '217',
  'Cyrs' => '221',
  'Beng' => '325',
  'Jurc' => '510',
  'Hans' => '501',
  'Lisu' => '399',
  'Wole' => '480',
  'Mymr' => '350',
  'Zxxx' => '997',
  'Hano' => '371',
  'Thai' => '352',
  'Syre' => '138',
  'Shrd' => '319',
  'Dsrt' => '250',
  'Jamo' => '284',
  'Ugar' => '040',
  'Zanb' => '339',
  'Sylo' => '316',
  'Cham' => '358',
  'Nshu' => '499',
  'Buhd' => '372',
  'Mroo' => '264',
  'Phlp' => '132',
  'Zsym' => '996',
  'Palm' => '126',
  'Shaw' => '281',
  'Maya' => '090',
  'Xpeo' => '030',
  'Qabx' => '949',
  'Hanb' => '503',
  'Bamu' => '435',
  'Sinh' => '348',
  'Pauc' => '263',
  'Arab' => '160',
  'Visp' => '280',
  'Mani' => '139',
  'Maka' => '366',
  'Knda' => '345',
  'Tavt' => '359',
  'Prti' => '130',
  'Deva' => '315',
  'Kitl' => '505',
  'Marc' => '332',
  'Latg' => '216',
  'Hluw' => '080',
  'Lepc' => '335',
  'Shui' => '530',
  'Mlym' => '347',
  'Takr' => '321',
  'Orya' => '327',
  'Telu' => '340',
  'Syrj' => '137',
  'Khoj' => '322',
  'Afak' => '439',
  'Cari' => '201',
  'Saur' => '344',
  'Tagb' => '373',
  'Ahom' => '338',
  'Vaii' => '470',
  'Chrs' => '109',
  'Cprt' => '403',
  'Gujr' => '320',
  'Ital' => '210',
  'Armi' => '124',
  'Xsux' => '020',
  'Sora' => '398',
  'Hatr' => '127',
  'Elym' => '128',
  'Bopo' => '285',
  'Syrc' => '135',
  'Armn' => '230',
  'Laoo' => '356',
  'Sarb' => '105',
  'Rjng' => '363',
  'Adlm' => '166',
  'Ogam' => '212',
  'Wara' => '262',
  'Osge' => '219',
  'Mtei' => '337',
  'Lyci' => '202',
  'Sogd' => '141',
  'Samr' => '123',
  'Geok' => '241',
  'Thaa' => '170',
  'Aran' => '161',
  'Merc' => '101',
  'Tang' => '520',
  'Plrd' => '282',
  'Syrn' => '136',
  'Hmnp' => '451',
  'Kore' => '287',
  'Hang' => '286',
  'Nbat' => '159',
  'Medf' => '265',
  'Bugi' => '367',
  'Narb' => '106',
  'Newa' => '333',
  'Roro' => '620',
  'Java' => '361',
  'Bhks' => '334',
  'Phli' => '131',
  'Kana' => '411',
  'Gonm' => '313',
  'Nkdb' => '085',
  'Khmr' => '355',
  'Lana' => '351',
  'Osma' => '260',
  'Avst' => '134',
  'Tirh' => '326',
  'Mahj' => '314',
  'Qaaa' => '900',
  'Tfng' => '120',
  'Aghb' => '239',
  'Soyo' => '329',
  'Cirt' => '291',
  'Zzzz' => '999',
  'Bali' => '360',
  'Geor' => '240',
  'Toto' => '294',
  'Cher' => '445',
  'Olck' => '261',
  'Hmng' => '450',
  'Teng' => '290',
  'Diak' => '342',
  'Mult' => '323',
  'Yiii' => '460',
  'Rohg' => '167',
  'Mong' => '145',
  'Dogr' => '328',
  'Batk' => '365',
  'Hebr' => '125',
  'Loma' => '437',
  'Tglg' => '370',
  'Sidd' => '302',
  'Goth' => '206',
  'Gran' => '343',
  'Hant' => '502',
  'Sogo' => '142',
  'Ethi' => '430'
};
$Lang2Territory = {
  'bew' => {
    'ID' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'tsn' => {
    'ZA' => 2,
    'BW' => 1
  },
  'rif' => {
    'MA' => 2
  },
  'dyu' => {
    'BF' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'gon' => {
    'IN' => 2
  },
  'nep' => {
    'IN' => 2,
    'NP' => 1
  },
  'kik' => {
    'KE' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'kde' => {
    'TZ' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'nds' => {
    'DE' => 2,
    'NL' => 2
  },
  'men' => {
    'SL' => 2
  },
  'bsc' => {
    'SN' => 2
  },
  'aeb' => {
    'TN' => 2
  },
  'tyv' => {
    'RU' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'bhi' => {
    'IN' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'mdf' => {
    'RU' => 2
  },
  'kom' => {
    'RU' => 2
  },
  'bos' => {
    'BA' => 1
  },
  'pap' => {
    'CW' => 1,
    'BQ' => 2,
    'AW' => 1
  },
  'udm' => {
    'RU' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'hoj' => {
    'IN' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'ell' => {
    'GR' => 1,
    'CY' => 1
  },
  'ita' => {
    'DE' => 2,
    'HR' => 2,
    'SM' => 1,
    'MT' => 2,
    'US' => 2,
    'IT' => 1,
    'VA' => 1,
    'CH' => 1,
    'FR' => 2
  },
  'nor' => {
    'SJ' => 1,
    'NO' => 1
  },
  'hno' => {
    'PK' => 2
  },
  'kok' => {
    'IN' => 2
  },
  'tpi' => {
    'PG' => 1
  },
  'bug' => {
    'ID' => 2
  },
  'seh' => {
    'MZ' => 2
  },
  'srd' => {
    'IT' => 2
  },
  'fao' => {
    'FO' => 1
  },
  'bel' => {
    'BY' => 1
  },
  'tzm' => {
    'MA' => 1
  },
  'ikt' => {
    'CA' => 2
  },
  'bar' => {
    'AT' => 2,
    'DE' => 2
  },
  'nyn' => {
    'UG' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'uzb' => {
    'AF' => 2,
    'UZ' => 1
  },
  'syl' => {
    'BD' => 2
  },
  'pmn' => {
    'PH' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'bis' => {
    'VU' => 1
  },
  'hau' => {
    'NG' => 2,
    'NE' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'kor' => {
    'KR' => 1,
    'US' => 2,
    'CN' => 2,
    'KP' => 1
  },
  'laj' => {
    'UG' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'bqi' => {
    'IR' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'ces' => {
    'SK' => 2,
    'CZ' => 1
  },
  'sna' => {
    'ZW' => 1
  },
  'nod' => {
    'TH' => 2
  },
  'aze' => {
    'IR' => 2,
    'IQ' => 2,
    'RU' => 2,
    'AZ' => 1
  },
  'zgh' => {
    'MA' => 2
  },
  'tam' => {
    'IN' => 2,
    'MY' => 2,
    'SG' => 1,
    'LK' => 1
  },
  'sef' => {
    'CI' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'fas' => {
    'IR' => 1,
    'PK' => 2,
    'AF' => 1
  },
  'rcf' => {
    'RE' => 2
  },
  'ori' => {
    'IN' => 2
  },
  'gil' => {
    'KI' => 1
  },
  'xho' => {
    'ZA' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'kon' => {
    'CD' => 2
  },
  'sav' => {
    'SN' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'glk' => {
    'IR' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'jam' => {
    'JM' => 2
  },
  'mdh' => {
    'PH' => 2
  },
  'srp' => {
    'XK' => 1,
    'BA' => 1,
    'RS' => 1,
    'ME' => 1
  },
  'myx' => {
    'UG' => 2
  },
  'fil' => {
    'US' => 2,
    'PH' => 1
  },
  'tah' => {
    'PF' => 1
  },
  'fvr' => {
    'SD' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'rmt' => {
    'IR' => 2
  },
  'ltz' => {
    'LU' => 1
  },
  'eus' => {
    'ES' => 2
  },
  'amh' => {
    'ET' => 1
  },
  'orm' => {
    'ET' => 2
  },
  'mfe' => {
    'MU' => 2
  },
  'ban' => {
    'ID' => 2
  },
  'ary' => {
    'MA' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'nno' => {
    'NO' => 1
  },
  'glv' => {
    'IM' => 1
  },
  'zdj' => {
    'KM' => 1
  },
  'ceb' => {
    'PH' => 2
  },
  'swe' => {
    'FI' => 1,
    'AX' => 1,
    'SE' => 1
  },
  'bgn' => {
    'PK' => 2
  },
  'gle' => {
    'GB' => 2,
    'IE' => 1
  },
  'cat' => {
    'ES' => 2,
    'AD' => 1
  },
  'hbs' => {
    'XK' => 1,
    'AT' => 2,
    'RS' => 1,
    'BA' => 1,
    'ME' => 1,
    'HR' => 1,
    'SI' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'unr' => {
    'IN' => 2
  },
  'est' => {
    'EE' => 1
  },
  'guz' => {
    'KE' => 2
  },
  'kaz' => {
    'CN' => 2,
    'KZ' => 1
  },
  'nym' => {
    'TZ' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'tuk' => {
    'AF' => 2,
    'IR' => 2,
    'TM' => 1
  },
  'lez' => {
    'RU' => 2
  },
  'slk' => {
    'SK' => 1,
    'CZ' => 2,
    'RS' => 2
  },
  'ach' => {
    'UG' => 2
  },
  'tvl' => {
    'TV' => 1
  },
  'bod' => {
    'CN' => 2
  },
  'mfv' => {
    'SN' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'mai' => {
    'NP' => 2,
    'IN' => 2
  },
  'kir' => {
    'KG' => 1
  },
  'wol' => {
    'SN' => 1
  },
  'bmv' => {
    'CM' => 2
  },
  'aym' => {
    'BO' => 1
  },
  'doi' => {
    'IN' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'kur' => {
    'SY' => 2,
    'TR' => 2,
    'IQ' => 2,
    'IR' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'eng' => {
    'GB' => 1,
    'MS' => 1,
    'FM' => 1,
    'LV' => 2,
    'CH' => 2,
    'US' => 1,
    'AI' => 1,
    'SS' => 1,
    'SC' => 1,
    'LC' => 1,
    'GM' => 1,
    'HU' => 2,
    'GI' => 1,
    'PG' => 1,
    'MY' => 2,
    'UM' => 1,
    'LU' => 2,
    'AG' => 1,
    'IT' => 2,
    'PN' => 1,
    'SG' => 1,
    'BE' => 2,
    'BR' => 2,
    'JM' => 1,
    'SL' => 1,
    'GU' => 1,
    'SZ' => 1,
    'GY' => 1,
    'CM' => 1,
    'RO' => 2,
    'PK' => 1,
    'ZW' => 1,
    'KI' => 1,
    'MA' => 2,
    'MG' => 1,
    'IN' => 1,
    'TT' => 1,
    'CX' => 1,
    'DZ' => 2,
    'VG' => 1,
    'IL' => 2,
    'KN' => 1,
    'LK' => 2,
    'IE' => 1,
    'JO' => 2,
    'CK' => 1,
    'TV' => 1,
    'JE' => 1,
    'SK' => 2,
    'FR' => 2,
    'BW' => 1,
    'CL' => 2,
    'BD' => 2,
    'ES' => 2,
    'CA' => 1,
    'ZA' => 1,
    'KY' => 1,
    'BB' => 1,
    'HK' => 1,
    'CC' => 1,
    'SH' => 1,
    'ZM' => 1,
    'IO' => 1,
    'FI' => 2,
    'TO' => 1,
    'NU' => 1,
    'GR' => 2,
    'RW' => 1,
    'DG' => 1,
    'PW' => 1,
    'MW' => 1,
    'IM' => 1,
    'DM' => 1,
    'PT' => 2,
    'SI' => 2,
    'CY' => 2,
    'BZ' => 1,
    'SX' => 1,
    'BM' => 1,
    'FJ' => 1,
    'SD' => 1,
    'UG' => 1,
    'PH' => 1,
    'GG' => 1,
    'SE' => 2,
    'NZ' => 1,
    'EE' => 2,
    'DK' => 2,
    'SB' => 1,
    'DE' => 2,
    'PR' => 1,
    'MU' => 1,
    'BI' => 1,
    'TH' => 2,
    'FK' => 1,
    'VU' => 1,
    'AS' => 1,
    'NA' => 1,
    'AE' => 2,
    'VC' => 1,
    'AC' => 2,
    'ET' => 2,
    'KE' => 1,
    'AR' => 2,
    'LB' => 2,
    'TZ' => 1,
    'TA' => 2,
    'BS' => 1,
    'PL' => 2,
    'NL' => 2,
    'BG' => 2,
    'LR' => 1,
    'NF' => 1,
    'EG' => 2,
    'MT' => 1,
    'KZ' => 2,
    'GH' => 1,
    'LT' => 2,
    'GD' => 1,
    'NR' => 1,
    'AU' => 1,
    'VI' => 1,
    'MH' => 1,
    'WS' => 1,
    'HR' => 2,
    'TC' => 1,
    'ER' => 1,
    'MP' => 1,
    'AT' => 2,
    'YE' => 2,
    'LS' => 1,
    'MX' => 2,
    'TR' => 2,
    'CZ' => 2,
    'BA' => 2,
    'TK' => 1,
    'NG' => 1,
    'IQ' => 2
  },
  'lin' => {
    'CD' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'zha' => {
    'CN' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'hye' => {
    'AM' => 1,
    'RU' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'que' => {
    'PE' => 1,
    'EC' => 1,
    'BO' => 1
  },
  'arq' => {
    'DZ' => 2
  },
  'nld' => {
    'BQ' => 1,
    'BE' => 1,
    'SX' => 1,
    'SR' => 1,
    'CW' => 1,
    'NL' => 1,
    'AW' => 1,
    'DE' => 2
  },
  'bam' => {
    'ML' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'buc' => {
    'YT' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'aln' => {
    'XK' => 2
  },
  'gsw' => {
    'LI' => 1,
    'DE' => 2,
    'CH' => 1
  },
  'hne' => {
    'IN' => 2
  },
  'min' => {
    'ID' => 2
  },
  'hil' => {
    'PH' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'tiv' => {
    'NG' => 2
  },
  'ara' => {
    'YE' => 1,
    'MA' => 2,
    'DZ' => 2,
    'SO' => 1,
    'LY' => 1,
    'SD' => 1,
    'SY' => 1,
    'KW' => 1,
    'QA' => 1,
    'EG' => 2,
    'IQ' => 1,
    'MR' => 1,
    'AE' => 1,
    'IL' => 1,
    'OM' => 1,
    'SA' => 1,
    'TN' => 1,
    'BH' => 1,
    'PS' => 1,
    'IR' => 2,
    'JO' => 1,
    'SS' => 2,
    'KM' => 1,
    'EH' => 1,
    'DJ' => 1,
    'ER' => 1,
    'LB' => 1,
    'TD' => 1
  },
  'suk' => {
    'TZ' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'awa' => {
    'IN' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'snd' => {
    'IN' => 2,
    'PK' => 2
  },
  'sas' => {
    'ID' => 2
  },
  'kin' => {
    'RW' => 1
  },
  'pol' => {
    'UA' => 2,
    'PL' => 1
  },
  'deu' => {
    'GB' => 2,
    'CH' => 1,
    'US' => 2,
    'DK' => 2,
    'SK' => 2,
    'DE' => 1,
    'FR' => 2,
    'HU' => 2,
    'LI' => 1,
    'BR' => 2,
    'BE' => 1,
    'AT' => 1,
    'CZ' => 2,
    'SI' => 2,
    'LU' => 1,
    'NL' => 2,
    'PL' => 2,
    'KZ' => 2
  },
  'xog' => {
    'UG' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'mni' => {
    'IN' => 2
  },
  'tnr' => {
    'SN' => 2
  },
  'mya' => {
    'MM' => 1
  },
  'dzo' => {
    'BT' => 1
  },
  'wni' => {
    'KM' => 1
  },
  'raj' => {
    'IN' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'por' => {
    'TL' => 1,
    'ST' => 1,
    'MZ' => 1,
    'AO' => 1,
    'PT' => 1,
    'BR' => 1,
    'GW' => 1,
    'GQ' => 1,
    'MO' => 1,
    'CV' => 1
  },
  'sck' => {
    'IN' => 2
  },
  'ron' => {
    'RS' => 2,
    'MD' => 1,
    'RO' => 1
  },
  'crs' => {
    'SC' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'dan' => {
    'DK' => 1,
    'DE' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'fin' => {
    'FI' => 1,
    'EE' => 2,
    'SE' => 2
  },
  'gqr' => {
    'ID' => 2
  },
  'kal' => {
    'DK' => 2,
    'GL' => 1
  },
  'lah' => {
    'PK' => 2
  },
  'lao' => {
    'LA' => 1
  },
  'mag' => {
    'IN' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'nob' => {
    'SJ' => 1,
    'NO' => 1
  },
  'csb' => {
    'PL' => 2
  },
  'glg' => {
    'ES' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'iii' => {
    'CN' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'ibo' => {
    'NG' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'tir' => {
    'ER' => 1,
    'ET' => 2
  },
  'slv' => {
    'AT' => 2,
    'SI' => 1
  },
  'bgc' => {
    'IN' => 2
  },
  'mak' => {
    'ID' => 2
  },
  'kmb' => {
    'AO' => 2
  },
  'msa' => {
    'SG' => 1,
    'TH' => 2,
    'BN' => 1,
    'ID' => 2,
    'CC' => 2,
    'MY' => 1
  },
  'guj' => {
    'IN' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'ckb' => {
    'IR' => 2,
    'IQ' => 2
  },
  'shn' => {
    'MM' => 2
  },
  'brh' => {
    'PK' => 2
  },
  'oci' => {
    'FR' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'sqq' => {
    'TH' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'krc' => {
    'RU' => 2
  },
  'ttb' => {
    'GH' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'brx' => {
    'IN' => 2
  },
  'sag' => {
    'CF' => 1
  },
  'sme' => {
    'NO' => 2
  },
  'bem' => {
    'ZM' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'hun' => {
    'RS' => 2,
    'HU' => 1,
    'AT' => 2,
    'RO' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'tso' => {
    'MZ' => 2,
    'ZA' => 2
  },
  'yue' => {
    'HK' => 2,
    'CN' => 2
  },
  'grn' => {
    'PY' => 1
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'tha' => {
    'TH' => 1
  },
  'sot' => {
    'LS' => 1,
    'ZA' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'sid' => {
    'ET' => 2
  },
  'bul' => {
    'BG' => 1
  },
  'tum' => {
    'MW' => 2
  },
  'smo' => {
    'WS' => 1,
    'AS' => 1
  },
  'mnu' => {
    'KE' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'sah' => {
    'RU' => 2
  },
  'ukr' => {
    'RS' => 2,
    'UA' => 1
  },
  'shr' => {
    'MA' => 2
  },
  'tcy' => {
    'IN' => 2
  },
  'haz' => {
    'AF' => 2
  },
  'uig' => {
    'CN' => 2
  },
  'che' => {
    'RU' => 2
  },
  'ibb' => {
    'NG' => 2
  },
  'bjt' => {
    'SN' => 2
  },
  'lug' => {
    'UG' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'tat' => {
    'RU' => 2
  },
  'mzn' => {
    'IR' => 2
  },
  'khm' => {
    'KH' => 1
  },
  'mfa' => {
    'TH' => 2
  },
  'gan' => {
    'CN' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'pan' => {
    'IN' => 2,
    'PK' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'hif' => {
    'FJ' => 1
  },
  'sqi' => {
    'XK' => 1,
    'MK' => 2,
    'AL' => 1,
    'RS' => 2
  },
  'hrv' => {
    'AT' => 2,
    'BA' => 1,
    'RS' => 2,
    'SI' => 2,
    'HR' => 1
  },
  'arz' => {
    'EG' => 2
  },
  'div' => {
    'MV' => 1
  },
  'mlt' => {
    'MT' => 1
  },
  'gbm' => {
    'IN' => 2
  },
  'kkt' => {
    'RU' => 2
  },
  'kea' => {
    'CV' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'man' => {
    'GN' => 2,
    'GM' => 2
  },
  'ben' => {
    'IN' => 2,
    'BD' => 1
  },
  'cym' => {
    'GB' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'bin' => {
    'NG' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'ton' => {
    'TO' => 1
  },
  'fra' => {
    'BF' => 1,
    'RW' => 1,
    'MC' => 1,
    'GP' => 1,
    'CI' => 1,
    'MF' => 1,
    'US' => 2,
    'SC' => 1,
    'GF' => 1,
    'CH' => 1,
    'BJ' => 1,
    'RO' => 2,
    'CM' => 1,
    'GB' => 2,
    'GA' => 1,
    'GQ' => 1,
    'SN' => 1,
    'NL' => 2,
    'CD' => 1,
    'PM' => 1,
    'LU' => 1,
    'CF' => 1,
    'DZ' => 1,
    'MG' => 1,
    'MA' => 1,
    'PT' => 2,
    'GN' => 1,
    'PF' => 1,
    'DE' => 2,
    'TD' => 1,
    'CG' => 1,
    'NE' => 1,
    'MU' => 1,
    'DJ' => 1,
    'NC' => 1,
    'IT' => 2,
    'KM' => 1,
    'HT' => 1,
    'ML' => 1,
    'TN' => 1,
    'MQ' => 1,
    'SY' => 1,
    'TF' => 2,
    'YT' => 1,
    'BI' => 1,
    'CA' => 1,
    'VU' => 1,
    'BL' => 1,
    'TG' => 1,
    'BE' => 1,
    'FR' => 1,
    'WF' => 1,
    'RE' => 1
  },
  'som' => {
    'SO' => 1,
    'DJ' => 2,
    'ET' => 2
  },
  'kbd' => {
    'RU' => 2
  },
  'swb' => {
    'YT' => 2
  },
  'yor' => {
    'NG' => 1
  },
  'lat' => {
    'VA' => 2
  },
  'inh' => {
    'RU' => 2
  },
  'ewe' => {
    'GH' => 2,
    'TG' => 2
  },
  'rus' => {
    'SJ' => 2,
    'EE' => 2,
    'UZ' => 2,
    'LV' => 2,
    'UA' => 1,
    'RU' => 1,
    'LT' => 2,
    'KZ' => 1,
    'DE' => 2,
    'KG' => 1,
    'BG' => 2,
    'BY' => 1,
    'TJ' => 2,
    'PL' => 2
  },
  'jav' => {
    'ID' => 2
  },
  'haw' => {
    'US' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'tig' => {
    'ER' => 2
  },
  'hoc' => {
    'IN' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'hsn' => {
    'CN' => 2
  },
  'dnj' => {
    'CI' => 2
  },
  'lua' => {
    'CD' => 2
  },
  'bjn' => {
    'ID' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'tel' => {
    'IN' => 2
  },
  'fon' => {
    'BJ' => 2
  },
  'bal' => {
    'AF' => 2,
    'IR' => 2,
    'PK' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'rkt' => {
    'BD' => 2,
    'IN' => 2
  },
  'wbr' => {
    'IN' => 2
  },
  'dje' => {
    'NE' => 2
  },
  'afr' => {
    'ZA' => 2,
    'NA' => 2
  },
  'wuu' => {
    'CN' => 2
  },
  'sat' => {
    'IN' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'tur' => {
    'TR' => 1,
    'CY' => 1,
    'DE' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'bho' => {
    'MU' => 2,
    'NP' => 2,
    'IN' => 2
  },
  'luz' => {
    'IR' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'mwr' => {
    'IN' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'san' => {
    'IN' => 2
  },
  'bak' => {
    'RU' => 2
  },
  'bej' => {
    'SD' => 2
  },
  'gcr' => {
    'GF' => 2
  },
  'nbl' => {
    'ZA' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'kfy' => {
    'IN' => 2
  },
  'war' => {
    'PH' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'heb' => {
    'IL' => 1
  },
  'zho' => {
    'ID' => 2,
    'TH' => 2,
    'TW' => 1,
    'VN' => 2,
    'CN' => 1,
    'HK' => 1,
    'SG' => 1,
    'US' => 2,
    'MY' => 2,
    'MO' => 1
  },
  'fud' => {
    'WF' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'kab' => {
    'DZ' => 2
  },
  'ilo' => {
    'PH' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'fuq' => {
    'NE' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'nya' => {
    'MW' => 1,
    'ZM' => 2
  },
  'skr' => {
    'PK' => 2
  },
  'aar' => {
    'DJ' => 2,
    'ET' => 2
  },
  'noe' => {
    'IN' => 2
  },
  'mon' => {
    'CN' => 2,
    'MN' => 1
  },
  'run' => {
    'BI' => 1
  },
  'fry' => {
    'NL' => 2
  },
  'vls' => {
    'BE' => 2
  },
  'khn' => {
    'IN' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'mad' => {
    'ID' => 2
  },
  'kha' => {
    'IN' => 2
  },
  'vmw' => {
    'MZ' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'swa' => {
    'TZ' => 1,
    'CD' => 2,
    'KE' => 1,
    'UG' => 1
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'kdh' => {
    'SL' => 2
  },
  'snk' => {
    'ML' => 2
  },
  'ful' => {
    'SN' => 2,
    'NE' => 2,
    'GN' => 2,
    'NG' => 2,
    'ML' => 2
  },
  'rej' => {
    'ID' => 2
  },
  'gom' => {
    'IN' => 2
  },
  'hmo' => {
    'PG' => 1
  },
  'und' => {
    'CP' => 2,
    'GS' => 2,
    'AQ' => 2,
    'HM' => 2,
    'BV' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'bbc' => {
    'ID' => 2
  },
  'kdx' => {
    'KE' => 2
  },
  'sus' => {
    'GN' => 2
  },
  'fij' => {
    'FJ' => 1
  },
  'mlg' => {
    'MG' => 1
  },
  'mal' => {
    'IN' => 2
  },
  'tet' => {
    'TL' => 1
  },
  'fuv' => {
    'NG' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'pau' => {
    'PW' => 1
  },
  'spa' => {
    'CU' => 1,
    'UY' => 1,
    'AD' => 2,
    'VE' => 1,
    'PH' => 2,
    'IC' => 1,
    'GQ' => 1,
    'PT' => 2,
    'DO' => 1,
    'GI' => 2,
    'NI' => 1,
    'HN' => 1,
    'BZ' => 2,
    'CR' => 1,
    'AR' => 1,
    'US' => 2,
    'RO' => 2,
    'MX' => 1,
    'FR' => 2,
    'EA' => 1,
    'ES' => 1,
    'BO' => 1,
    'CL' => 1,
    'CO' => 1,
    'PE' => 1,
    'EC' => 1,
    'PY' => 1,
    'PR' => 1,
    'DE' => 2,
    'PA' => 1,
    'SV' => 1,
    'GT' => 1
  },
  'srn' => {
    'SR' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'ssw' => {
    'ZA' => 2,
    'SZ' => 1
  },
  'hin' => {
    'IN' => 1,
    'ZA' => 2,
    'FJ' => 2
  }
};
$Lang2Script = {
  'nnh' => {
    'Latn' => 1
  },
  'kik' => {
    'Latn' => 1
  },
  'liv' => {
    'Latn' => 2
  },
  'gon' => {
    'Telu' => 1,
    'Deva' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'bew' => {
    'Latn' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'iku' => {
    'Latn' => 1,
    'Cans' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'lui' => {
    'Latn' => 2
  },
  'mdr' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'sgs' => {
    'Latn' => 1
  },
  'btv' => {
    'Deva' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'aeb' => {
    'Arab' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'den' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'arc' => {
    'Palm' => 2,
    'Nbat' => 2,
    'Armi' => 2
  },
  'hno' => {
    'Arab' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'bug' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'ttj' => {
    'Latn' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'udm' => {
    'Latn' => 2,
    'Cyrl' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'nyn' => {
    'Latn' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'syl' => {
    'Sylo' => 2,
    'Beng' => 1
  },
  'uzb' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'fao' => {
    'Latn' => 1
  },
  'xum' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'bqi' => {
    'Arab' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'pmn' => {
    'Latn' => 1
  },
  'hau' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'vmf' => {
    'Latn' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'taj' => {
    'Deva' => 1,
    'Tibt' => 2
  },
  'gag' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'bzx' => {
    'Latn' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'gil' => {
    'Latn' => 1
  },
  'rcf' => {
    'Latn' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'xnr' => {
    'Deva' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'myx' => {
    'Latn' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'anp' => {
    'Deva' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'amh' => {
    'Ethi' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'orm' => {
    'Latn' => 1,
    'Ethi' => 2
  },
  'sma' => {
    'Latn' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'gju' => {
    'Arab' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'ccp' => {
    'Cakm' => 1,
    'Beng' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'amo' => {
    'Latn' => 1
  },
  'ary' => {
    'Arab' => 1
  },
  'bfq' => {
    'Taml' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'hai' => {
    'Latn' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'slk' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'lfn' => {
    'Latn' => 2,
    'Cyrl' => 2
  },
  'tvl' => {
    'Latn' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'nym' => {
    'Latn' => 1
  },
  'kaz' => {
    'Cyrl' => 1,
    'Arab' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'tuk' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'doi' => {
    'Deva' => 1,
    'Takr' => 2,
    'Arab' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'mdt' => {
    'Latn' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'maz' => {
    'Latn' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'eng' => {
    'Shaw' => 2,
    'Latn' => 1,
    'Dsrt' => 2
  },
  'mai' => {
    'Tirh' => 2,
    'Deva' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'aym' => {
    'Latn' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'bfd' => {
    'Latn' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'bam' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'osa' => {
    'Latn' => 2,
    'Osge' => 1
  },
  'zha' => {
    'Hans' => 2,
    'Latn' => 1
  },
  'ave' => {
    'Avst' => 2
  },
  'oss' => {
    'Cyrl' => 1
  },
  'ven' => {
    'Latn' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'hil' => {
    'Latn' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'tiv' => {
    'Latn' => 1
  },
  'kat' => {
    'Geor' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'vai' => {
    'Latn' => 1,
    'Vaii' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'aln' => {
    'Latn' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'kaj' => {
    'Latn' => 1
  },
  'snd' => {
    'Sind' => 2,
    'Arab' => 1,
    'Deva' => 1,
    'Khoj' => 2
  },
  'sas' => {
    'Latn' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'uga' => {
    'Ugar' => 2
  },
  'dty' => {
    'Deva' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'deu' => {
    'Runr' => 2,
    'Latn' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'lmo' => {
    'Latn' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'pli' => {
    'Deva' => 2,
    'Sinh' => 2,
    'Thai' => 2
  },
  'fin' => {
    'Latn' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'kas' => {
    'Arab' => 1,
    'Deva' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'ron' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'sck' => {
    'Deva' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'mua' => {
    'Latn' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'ale' => {
    'Latn' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'lah' => {
    'Arab' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'tru' => {
    'Latn' => 1,
    'Syrc' => 2
  },
  'ibo' => {
    'Latn' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'tkr' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'atj' => {
    'Latn' => 1
  },
  'unx' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'kmb' => {
    'Latn' => 1
  },
  'bub' => {
    'Cyrl' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'ttb' => {
    'Latn' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'sme' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'csw' => {
    'Cans' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'moh' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'lim' => {
    'Latn' => 1
  },
  'tsd' => {
    'Grek' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'crk' => {
    'Cans' => 1
  },
  'tso' => {
    'Latn' => 1
  },
  'shr' => {
    'Arab' => 1,
    'Tfng' => 1,
    'Latn' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'uig' => {
    'Latn' => 2,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'crl' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'gay' => {
    'Latn' => 1
  },
  'urd' => {
    'Arab' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'abw' => {
    'Phli' => 2,
    'Phlp' => 2
  },
  'xav' => {
    'Latn' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'zza' => {
    'Latn' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'hif' => {
    'Latn' => 1,
    'Deva' => 1
  },
  'grc' => {
    'Cprt' => 2,
    'Linb' => 2,
    'Grek' => 2
  },
  'nsk' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'tat' => {
    'Cyrl' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'pnt' => {
    'Grek' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'swg' => {
    'Latn' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'hrv' => {
    'Latn' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'sqi' => {
    'Elba' => 2,
    'Latn' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'lmn' => {
    'Telu' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'man' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'frr' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'wbp' => {
    'Latn' => 1
  },
  'yor' => {
    'Latn' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'inh' => {
    'Cyrl' => 1,
    'Arab' => 2,
    'Latn' => 2
  },
  'gba' => {
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'nde' => {
    'Latn' => 1
  },
  'yap' => {
    'Latn' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'fra' => {
    'Dupl' => 2,
    'Latn' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'bez' => {
    'Latn' => 1
  },
  'aoz' => {
    'Latn' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'wbr' => {
    'Deva' => 1
  },
  'sly' => {
    'Latn' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'chp' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'lua' => {
    'Latn' => 1
  },
  'kum' => {
    'Cyrl' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'arg' => {
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'thq' => {
    'Deva' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'bra' => {
    'Deva' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'kht' => {
    'Mymr' => 1
  },
  'war' => {
    'Latn' => 1
  },
  'ain' => {
    'Kana' => 2,
    'Latn' => 2
  },
  'kln' => {
    'Latn' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'sun' => {
    'Latn' => 1,
    'Sund' => 2
  },
  'fuq' => {
    'Latn' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'cho' => {
    'Latn' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'kjg' => {
    'Latn' => 2,
    'Laoo' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'kha' => {
    'Latn' => 1,
    'Beng' => 2
  },
  'mon' => {
    'Cyrl' => 1,
    'Phag' => 2,
    'Mong' => 2
  },
  'mgp' => {
    'Deva' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'crh' => {
    'Cyrl' => 1
  },
  'frp' => {
    'Latn' => 1
  },
  'rej' => {
    'Rjng' => 2,
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'kdh' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'bbc' => {
    'Latn' => 1,
    'Batk' => 2
  },
  'niu' => {
    'Latn' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'cop' => {
    'Grek' => 2,
    'Arab' => 2,
    'Copt' => 2
  },
  'hak' => {
    'Hans' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'kan' => {
    'Knda' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'rif' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'bhi' => {
    'Deva' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'sxn' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'kom' => {
    'Perm' => 2,
    'Cyrl' => 1
  },
  'bos' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'yao' => {
    'Latn' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'men' => {
    'Latn' => 1,
    'Mend' => 2
  },
  'pro' => {
    'Latn' => 2
  },
  'ady' => {
    'Cyrl' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'vic' => {
    'Latn' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'mrd' => {
    'Deva' => 1
  },
  'srd' => {
    'Latn' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'ikt' => {
    'Latn' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'tdg' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'tog' => {
    'Latn' => 1
  },
  'ssy' => {
    'Latn' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'snx' => {
    'Hebr' => 2,
    'Samr' => 2
  },
  'pms' => {
    'Latn' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'tzm' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'zgh' => {
    'Tfng' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'nod' => {
    'Lana' => 1
  },
  'aze' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'osc' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'otk' => {
    'Orkh' => 2
  },
  'bis' => {
    'Latn' => 1
  },
  'was' => {
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'kor' => {
    'Kore' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'kon' => {
    'Latn' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'bft' => {
    'Arab' => 1,
    'Tibt' => 2
  },
  'mos' => {
    'Latn' => 1
  },
  'ori' => {
    'Orya' => 1
  },
  'fas' => {
    'Arab' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'kri' => {
    'Latn' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'grt' => {
    'Beng' => 1
  },
  'fil' => {
    'Latn' => 1,
    'Tglg' => 2
  },
  'ltg' => {
    'Latn' => 1
  },
  'cay' => {
    'Latn' => 1
  },
  'mdh' => {
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'avk' => {
    'Latn' => 2
  },
  'bss' => {
    'Latn' => 1
  },
  'pko' => {
    'Latn' => 1
  },
  'srp' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'ban' => {
    'Latn' => 1,
    'Bali' => 2
  },
  'fvr' => {
    'Latn' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'xsa' => {
    'Sarb' => 2
  },
  'cjm' => {
    'Arab' => 2,
    'Cham' => 1
  },
  'hbs' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'phn' => {
    'Phnx' => 2
  },
  'unr' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'lez' => {
    'Aghb' => 2,
    'Cyrl' => 1
  },
  'crj' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'ach' => {
    'Latn' => 1
  },
  'stq' => {
    'Latn' => 1
  },
  'kyu' => {
    'Kali' => 1
  },
  'guz' => {
    'Latn' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'mtr' => {
    'Deva' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'kur' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'zap' => {
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'kgp' => {
    'Latn' => 1
  },
  'xsr' => {
    'Deva' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'bmv' => {
    'Latn' => 1
  },
  'wol' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'kir' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'hmn' => {
    'Plrd' => 1,
    'Latn' => 1,
    'Laoo' => 1,
    'Hmng' => 2
  },
  'zen' => {
    'Tfng' => 2
  },
  'mxc' => {
    'Latn' => 1
  },
  'nld' => {
    'Latn' => 1
  },
  'kax' => {
    'Latn' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'maf' => {
    'Latn' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'byv' => {
    'Latn' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'ava' => {
    'Cyrl' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'kiu' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'mni' => {
    'Mtei' => 2,
    'Beng' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'uli' => {
    'Latn' => 1
  },
  'khq' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'mas' => {
    'Latn' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'kin' => {
    'Latn' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'ett' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'gqr' => {
    'Latn' => 1
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'hnn' => {
    'Latn' => 1,
    'Hano' => 2
  },
  'dtm' => {
    'Latn' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'jml' => {
    'Deva' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'lao' => {
    'Laoo' => 1
  },
  'tir' => {
    'Ethi' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'thl' => {
    'Deva' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'glg' => {
    'Latn' => 1
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'vol' => {
    'Latn' => 2
  },
  'rom' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'bjj' => {
    'Deva' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'kpe' => {
    'Latn' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'brh' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'oci' => {
    'Latn' => 1
  },
  'kca' => {
    'Cyrl' => 1
  },
  'mak' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'msa' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'ndo' => {
    'Latn' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'pcd' => {
    'Latn' => 1
  },
  'sqq' => {
    'Thai' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'sga' => {
    'Latn' => 2,
    'Ogam' => 2
  },
  'xpr' => {
    'Prti' => 2
  },
  'brx' => {
    'Deva' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'nov' => {
    'Latn' => 2
  },
  'wtm' => {
    'Deva' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'lit' => {
    'Latn' => 1
  },
  'sot' => {
    'Latn' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'ind' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'sid' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'bem' => {
    'Latn' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'hun' => {
    'Latn' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'yue' => {
    'Hant' => 1,
    'Hans' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'mri' => {
    'Latn' => 1
  },
  'grn' => {
    'Latn' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'nus' => {
    'Latn' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'srx' => {
    'Deva' => 1
  },
  'wae' => {
    'Latn' => 1
  },
  'ibb' => {
    'Latn' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'tum' => {
    'Latn' => 1
  },
  'mnu' => {
    'Latn' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'bku' => {
    'Buhd' => 2,
    'Latn' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'pan' => {
    'Guru' => 1,
    'Arab' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'ina' => {
    'Latn' => 2
  },
  'egy' => {
    'Egyp' => 2
  },
  'rug' => {
    'Latn' => 1
  },
  'fia' => {
    'Arab' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'aii' => {
    'Syrc' => 2,
    'Cyrl' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'arz' => {
    'Arab' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'lki' => {
    'Arab' => 1
  },
  'kkt' => {
    'Cyrl' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'tly' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'srb' => {
    'Sora' => 2,
    'Latn' => 1
  },
  'tgk' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'chu' => {
    'Cyrl' => 2
  },
  'bgx' => {
    'Grek' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'swb' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'jav' => {
    'Latn' => 1,
    'Java' => 2
  },
  'sms' => {
    'Latn' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'lun' => {
    'Latn' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'som' => {
    'Arab' => 2,
    'Osma' => 2,
    'Latn' => 1
  },
  'zea' => {
    'Latn' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'rar' => {
    'Latn' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'rkt' => {
    'Beng' => 1
  },
  'lcp' => {
    'Thai' => 1
  },
  'afr' => {
    'Latn' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'hsn' => {
    'Hans' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'mro' => {
    'Mroo' => 2,
    'Latn' => 1
  },
  'bal' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'dsb' => {
    'Latn' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'luo' => {
    'Latn' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'tdd' => {
    'Tale' => 1
  },
  'tur' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'jpn' => {
    'Jpan' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'sat' => {
    'Olck' => 1,
    'Deva' => 2,
    'Orya' => 2,
    'Latn' => 2,
    'Beng' => 2
  },
  'byn' => {
    'Ethi' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'mar' => {
    'Modi' => 2,
    'Deva' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'kfy' => {
    'Deva' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'san' => {
    'Sidd' => 2,
    'Shrd' => 2,
    'Deva' => 2,
    'Gran' => 2,
    'Sinh' => 2
  },
  'wln' => {
    'Latn' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'non' => {
    'Runr' => 2
  },
  'lzz' => {
    'Latn' => 1,
    'Geor' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'ttt' => {
    'Latn' => 1,
    'Arab' => 2,
    'Cyrl' => 1
  },
  'skr' => {
    'Arab' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'zho' => {
    'Hans' => 1,
    'Phag' => 2,
    'Bopo' => 2,
    'Hant' => 1
  },
  'bto' => {
    'Latn' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'vmw' => {
    'Latn' => 1
  },
  'dyo' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'swa' => {
    'Latn' => 1
  },
  'run' => {
    'Latn' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'syr' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'khn' => {
    'Deva' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'vie' => {
    'Hani' => 2,
    'Latn' => 1
  },
  'ful' => {
    'Latn' => 1,
    'Adlm' => 2
  },
  'nzi' => {
    'Latn' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'sdc' => {
    'Latn' => 1
  },
  'bmq' => {
    'Latn' => 1
  },
  'fuv' => {
    'Latn' => 1
  },
  'cja' => {
    'Arab' => 1,
    'Cham' => 2
  },
  'pau' => {
    'Latn' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'hin' => {
    'Latn' => 2,
    'Deva' => 1,
    'Mahj' => 2
  },
  'ssw' => {
    'Latn' => 1
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'kdx' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'sus' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'lag' => {
    'Latn' => 1
  }
};
$Territory2Lang = {
  'CX' => {
    'eng' => 1
  },
  'DZ' => {
    'arq' => 2,
    'fra' => 1,
    'ara' => 2,
    'kab' => 2,
    'eng' => 2
  },
  'IN' => {
    'gon' => 2,
    'nep' => 2,
    'tam' => 2,
    'unr' => 2,
    'hoc' => 2,
    'noe' => 2,
    'bgc' => 2,
    'awa' => 2,
    'wbq' => 2,
    'tcy' => 2,
    'bhb' => 2,
    'bjj' => 2,
    'hne' => 2,
    'kan' => 2,
    'urd' => 2,
    'pan' => 2,
    'kha' => 2,
    'wbr' => 2,
    'bhi' => 2,
    'asm' => 2,
    'rkt' => 2,
    'mni' => 2,
    'khn' => 2,
    'ori' => 2,
    'mtr' => 2,
    'xnr' => 2,
    'tel' => 2,
    'guj' => 2,
    'swv' => 2,
    'snd' => 2,
    'eng' => 1,
    'kok' => 2,
    'gom' => 2,
    'mwr' => 2,
    'doi' => 2,
    'bho' => 2,
    'brx' => 2,
    'kas' => 2,
    'wtm' => 2,
    'hoj' => 2,
    'sck' => 2,
    'sat' => 2,
    'raj' => 2,
    'dcc' => 2,
    'mai' => 2,
    'kru' => 2,
    'kfy' => 2,
    'ben' => 2,
    'hin' => 1,
    'mal' => 2,
    'mag' => 2,
    'mar' => 2,
    'lmn' => 2,
    'gbm' => 2,
    'san' => 2
  },
  'VG' => {
    'eng' => 1
  },
  'QA' => {
    'ara' => 1
  },
  'KH' => {
    'khm' => 1
  },
  'PK' => {
    'bgn' => 2,
    'pus' => 2,
    'eng' => 1,
    'skr' => 2,
    'pan' => 2,
    'brh' => 2,
    'hno' => 2,
    'urd' => 1,
    'snd' => 2,
    'bal' => 2,
    'lah' => 2,
    'fas' => 2
  },
  'CI' => {
    'sef' => 2,
    'fra' => 1,
    'dnj' => 2,
    'bci' => 2
  },
  'RS' => {
    'hbs' => 1,
    'ukr' => 2,
    'slk' => 2,
    'srp' => 1,
    'ron' => 2,
    'sqi' => 2,
    'hrv' => 2,
    'hun' => 2
  },
  'CR' => {
    'spa' => 1
  },
  'MO' => {
    'por' => 1,
    'zho' => 1
  },
  'SO' => {
    'som' => 1,
    'ara' => 1
  },
  'ID' => {
    'jav' => 2,
    'sun' => 2,
    'rej' => 2,
    'gqr' => 2,
    'bug' => 2,
    'zho' => 2,
    'bew' => 2,
    'min' => 2,
    'ace' => 2,
    'mad' => 2,
    'ljp' => 2,
    'ban' => 2,
    'ind' => 1,
    'msa' => 2,
    'sas' => 2,
    'bbc' => 2,
    'mak' => 2,
    'bjn' => 2
  },
  'LY' => {
    'ara' => 1
  },
  'ES' => {
    'glg' => 2,
    'eng' => 2,
    'ast' => 2,
    'cat' => 2,
    'eus' => 2,
    'spa' => 1
  },
  'CA' => {
    'eng' => 1,
    'fra' => 1,
    'iku' => 2,
    'ikt' => 2
  },
  'BD' => {
    'ben' => 1,
    'syl' => 2,
    'eng' => 2,
    'rkt' => 2
  },
  'BW' => {
    'tsn' => 1,
    'eng' => 1
  },
  'FR' => {
    'fra' => 1,
    'ita' => 2,
    'deu' => 2,
    'eng' => 2,
    'oci' => 2,
    'spa' => 2
  },
  'KP' => {
    'kor' => 1
  },
  'SM' => {
    'ita' => 1
  },
  'BY' => {
    'rus' => 1,
    'bel' => 1
  },
  'BB' => {
    'eng' => 1
  },
  'KY' => {
    'eng' => 1
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'AX' => {
    'swe' => 1
  },
  'KN' => {
    'eng' => 1
  },
  'SK' => {
    'slk' => 1,
    'ces' => 2,
    'deu' => 2,
    'eng' => 2
  },
  'PF' => {
    'tah' => 1,
    'fra' => 1
  },
  'GI' => {
    'eng' => 1,
    'spa' => 2
  },
  'GM' => {
    'eng' => 1,
    'man' => 2
  },
  'MZ' => {
    'tso' => 2,
    'vmw' => 2,
    'ndc' => 2,
    'por' => 1,
    'mgh' => 2,
    'seh' => 2,
    'ngl' => 2
  },
  'ST' => {
    'por' => 1
  },
  'AD' => {
    'cat' => 1,
    'spa' => 2
  },
  'CD' => {
    'lua' => 2,
    'fra' => 1,
    'lub' => 2,
    'kon' => 2,
    'lin' => 2,
    'swa' => 2
  },
  'UM' => {
    'eng' => 1
  },
  'MY' => {
    'msa' => 1,
    'zho' => 2,
    'eng' => 2,
    'tam' => 2
  },
  'GB' => {
    'cym' => 2,
    'sco' => 2,
    'eng' => 1,
    'deu' => 2,
    'gla' => 2,
    'gle' => 2,
    'fra' => 2
  },
  'CP' => {
    'und' => 2
  },
  'FM' => {
    'chk' => 2,
    'pon' => 2,
    'eng' => 1
  },
  'SS' => {
    'eng' => 1,
    'ara' => 2
  },
  'AI' => {
    'eng' => 1
  },
  'SR' => {
    'nld' => 1,
    'srn' => 2
  },
  'YT' => {
    'swb' => 2,
    'fra' => 1,
    'buc' => 2
  },
  'IS' => {
    'isl' => 1
  },
  'JM' => {
    'eng' => 1,
    'jam' => 2
  },
  'KR' => {
    'kor' => 1
  },
  'OM' => {
    'ara' => 1
  },
  'BV' => {
    'und' => 2
  },
  'GU' => {
    'eng' => 1,
    'cha' => 1
  },
  'ML' => {
    'bam' => 2,
    'ful' => 2,
    'snk' => 2,
    'ffm' => 2,
    'fra' => 1
  },
  'MK' => {
    'mkd' => 1,
    'sqi' => 2
  },
  'AG' => {
    'eng' => 1
  },
  'PA' => {
    'spa' => 1
  },
  'EC' => {
    'spa' => 1,
    'que' => 1
  },
  'PN' => {
    'eng' => 1
  },
  'SG' => {
    'tam' => 1,
    'eng' => 1,
    'zho' => 1,
    'msa' => 1
  },
  'GW' => {
    'por' => 1
  },
  'DJ' => {
    'som' => 2,
    'aar' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'IT' => {
    'fra' => 2,
    'ita' => 1,
    'eng' => 2,
    'srd' => 2
  },
  'BS' => {
    'eng' => 1
  },
  'KZ' => {
    'kaz' => 1,
    'rus' => 1,
    'deu' => 2,
    'eng' => 2
  },
  'NF' => {
    'eng' => 1
  },
  'NL' => {
    'nld' => 1,
    'deu' => 2,
    'eng' => 2,
    'nds' => 2,
    'fra' => 2,
    'fry' => 2
  },
  'AL' => {
    'sqi' => 1
  },
  'PL' => {
    'lit' => 2,
    'rus' => 2,
    'csb' => 2,
    'pol' => 1,
    'deu' => 2,
    'eng' => 2
  },
  'PM' => {
    'fra' => 1
  },
  'BG' => {
    'eng' => 2,
    'bul' => 1,
    'rus' => 2
  },
  'ET' => {
    'wal' => 2,
    'som' => 2,
    'amh' => 1,
    'tir' => 2,
    'sid' => 2,
    'orm' => 2,
    'aar' => 2,
    'eng' => 2
  },
  'MM' => {
    'mya' => 1,
    'shn' => 2
  },
  'GA' => {
    'fra' => 1
  },
  'GP' => {
    'fra' => 1
  },
  'KE' => {
    'mnu' => 2,
    'kdx' => 2,
    'luy' => 2,
    'kln' => 2,
    'guz' => 2,
    'luo' => 2,
    'swa' => 1,
    'eng' => 1,
    'kik' => 2
  },
  'BL' => {
    'fra' => 1
  },
  'BA' => {
    'bos' => 1,
    'srp' => 1,
    'eng' => 2,
    'hbs' => 1,
    'hrv' => 1
  },
  'JP' => {
    'jpn' => 1
  },
  'HM' => {
    'und' => 2
  },
  'AT' => {
    'hrv' => 2,
    'hun' => 2,
    'bar' => 2,
    'eng' => 2,
    'deu' => 1,
    'hbs' => 2,
    'slv' => 2
  },
  'LS' => {
    'sot' => 1,
    'eng' => 1
  },
  'AF' => {
    'uzb' => 2,
    'fas' => 1,
    'bal' => 2,
    'tuk' => 2,
    'pus' => 1,
    'haz' => 2
  },
  'AM' => {
    'hye' => 1
  },
  'TK' => {
    'tkl' => 1,
    'eng' => 1
  },
  'NG' => {
    'efi' => 2,
    'yor' => 1,
    'tiv' => 2,
    'fuv' => 2,
    'eng' => 1,
    'bin' => 2,
    'ibb' => 2,
    'hau' => 2,
    'pcm' => 2,
    'ibo' => 2,
    'ful' => 2
  },
  'TF' => {
    'fra' => 2
  },
  'MV' => {
    'div' => 1
  },
  'AU' => {
    'eng' => 1
  },
  'GL' => {
    'kal' => 1
  },
  'GH' => {
    'ttb' => 2,
    'aka' => 2,
    'abr' => 2,
    'ewe' => 2,
    'eng' => 1
  },
  'NR' => {
    'nau' => 1,
    'eng' => 1
  },
  'BH' => {
    'ara' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'LT' => {
    'eng' => 2,
    'lit' => 1,
    'rus' => 2
  },
  'PY' => {
    'spa' => 1,
    'grn' => 1
  },
  'HR' => {
    'ita' => 2,
    'hrv' => 1,
    'hbs' => 1,
    'eng' => 2
  },
  'WS' => {
    'smo' => 1,
    'eng' => 1
  },
  'ER' => {
    'eng' => 1,
    'tig' => 2,
    'ara' => 1,
    'tir' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'GE' => {
    'kat' => 1,
    'oss' => 2,
    'abk' => 2
  },
  'BM' => {
    'eng' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'SX' => {
    'nld' => 1,
    'eng' => 1
  },
  'BZ' => {
    'eng' => 1,
    'spa' => 2
  },
  'SI' => {
    'deu' => 2,
    'eng' => 2,
    'slv' => 1,
    'hbs' => 2,
    'hrv' => 2
  },
  'FJ' => {
    'eng' => 1,
    'hif' => 1,
    'hin' => 2,
    'fij' => 1
  },
  'PT' => {
    'fra' => 2,
    'spa' => 2,
    'por' => 1,
    'eng' => 2
  },
  'GQ' => {
    'spa' => 1,
    'por' => 1,
    'fra' => 1,
    'fan' => 2
  },
  'PH' => {
    'fil' => 1,
    'eng' => 1,
    'war' => 2,
    'spa' => 2,
    'tsg' => 2,
    'ilo' => 2,
    'hil' => 2,
    'ceb' => 2,
    'mdh' => 2,
    'bhk' => 2,
    'bik' => 2,
    'pag' => 2,
    'pmn' => 2
  },
  'SD' => {
    'ara' => 1,
    'bej' => 2,
    'fvr' => 2,
    'eng' => 1
  },
  'UG' => {
    'lug' => 2,
    'teo' => 2,
    'cgg' => 2,
    'eng' => 1,
    'swa' => 1,
    'laj' => 2,
    'xog' => 2,
    'myx' => 2,
    'nyn' => 2,
    'ach' => 2
  },
  'BJ' => {
    'fra' => 1,
    'fon' => 2
  },
  'SH' => {
    'eng' => 1
  },
  'IO' => {
    'eng' => 1
  },
  'SJ' => {
    'nob' => 1,
    'nor' => 1,
    'rus' => 2
  },
  'CC' => {
    'eng' => 1,
    'msa' => 2
  },
  'NU' => {
    'niu' => 1,
    'eng' => 1
  },
  'FI' => {
    'swe' => 1,
    'fin' => 1,
    'eng' => 2
  },
  'MF' => {
    'fra' => 1
  },
  'BI' => {
    'run' => 1,
    'fra' => 1,
    'eng' => 1
  },
  'TW' => {
    'zho' => 1
  },
  'TH' => {
    'nod' => 2,
    'eng' => 2,
    'tts' => 2,
    'sqq' => 2,
    'kxm' => 2,
    'tha' => 1,
    'mfa' => 2,
    'msa' => 2,
    'zho' => 2
  },
  'EA' => {
    'spa' => 1
  },
  'WF' => {
    'fud' => 2,
    'fra' => 1,
    'wls' => 2
  },
  'NA' => {
    'ndo' => 2,
    'afr' => 2,
    'eng' => 1,
    'kua' => 2
  },
  'VC' => {
    'eng' => 1
  },
  'MD' => {
    'ron' => 1
  },
  'EE' => {
    'est' => 1,
    'eng' => 2,
    'fin' => 2,
    'rus' => 2
  },
  'UZ' => {
    'rus' => 2,
    'uzb' => 1
  },
  'NZ' => {
    'mri' => 1,
    'eng' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'KM' => {
    'wni' => 1,
    'fra' => 1,
    'ara' => 1,
    'zdj' => 1
  },
  'TT' => {
    'eng' => 1
  },
  'HN' => {
    'spa' => 1
  },
  'BT' => {
    'dzo' => 1
  },
  'MG' => {
    'fra' => 1,
    'eng' => 1,
    'mlg' => 1
  },
  'MA' => {
    'tzm' => 1,
    'rif' => 2,
    'ary' => 2,
    'fra' => 1,
    'zgh' => 2,
    'eng' => 2,
    'shr' => 2,
    'ara' => 2
  },
  'DO' => {
    'spa' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'IL' => {
    'eng' => 2,
    'heb' => 1,
    'ara' => 1
  },
  'AW' => {
    'pap' => 1,
    'nld' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'KI' => {
    'eng' => 1,
    'gil' => 1
  },
  'ZW' => {
    'sna' => 1,
    'nde' => 1,
    'eng' => 1
  },
  'CM' => {
    'fra' => 1,
    'eng' => 1,
    'bmv' => 2
  },
  'RO' => {
    'ron' => 1,
    'eng' => 2,
    'spa' => 2,
    'fra' => 2,
    'hun' => 2
  },
  'RU' => {
    'bak' => 2,
    'kum' => 2,
    'ady' => 2,
    'tyv' => 2,
    'hye' => 2,
    'tat' => 2,
    'mdf' => 2,
    'kkt' => 2,
    'lez' => 2,
    'kom' => 2,
    'ava' => 2,
    'udm' => 2,
    'myv' => 2,
    'lbe' => 2,
    'kbd' => 2,
    'rus' => 1,
    'inh' => 2,
    'sah' => 2,
    'krc' => 2,
    'che' => 2,
    'chv' => 2,
    'aze' => 2
  },
  'MC' => {
    'fra' => 1
  },
  'AZ' => {
    'aze' => 1
  },
  'GF' => {
    'fra' => 1,
    'gcr' => 2
  },
  'CL' => {
    'eng' => 2,
    'spa' => 1
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'MQ' => {
    'fra' => 1
  },
  'ZA' => {
    'eng' => 1,
    'afr' => 2,
    'ssw' => 2,
    'hin' => 2,
    'sot' => 2,
    'nso' => 2,
    'tso' => 2,
    'ven' => 2,
    'tsn' => 2,
    'zul' => 2,
    'xho' => 2,
    'nbl' => 2
  },
  'XK' => {
    'srp' => 1,
    'hbs' => 1,
    'aln' => 2,
    'sqi' => 1
  },
  'LK' => {
    'sin' => 1,
    'eng' => 2,
    'tam' => 1
  },
  'SV' => {
    'spa' => 1
  },
  'GN' => {
    'ful' => 2,
    'sus' => 2,
    'man' => 2,
    'fra' => 1
  },
  'JE' => {
    'eng' => 1
  },
  'TV' => {
    'eng' => 1,
    'tvl' => 1
  },
  'CG' => {
    'fra' => 1
  },
  'PE' => {
    'que' => 1,
    'spa' => 1
  },
  'JO' => {
    'ara' => 1,
    'eng' => 2
  },
  'CK' => {
    'eng' => 1
  },
  'CF' => {
    'fra' => 1,
    'sag' => 1
  },
  'PG' => {
    'hmo' => 1,
    'tpi' => 1,
    'eng' => 1
  },
  'LI' => {
    'gsw' => 1,
    'deu' => 1
  },
  'HU' => {
    'eng' => 2,
    'deu' => 2,
    'hun' => 1
  },
  'SA' => {
    'ara' => 1
  },
  'MN' => {
    'mon' => 1
  },
  'LU' => {
    'deu' => 1,
    'eng' => 2,
    'fra' => 1,
    'ltz' => 1
  },
  'GS' => {
    'und' => 2
  },
  'CU' => {
    'spa' => 1
  },
  'CH' => {
    'eng' => 2,
    'deu' => 1,
    'gsw' => 1,
    'roh' => 2,
    'fra' => 1,
    'ita' => 1
  },
  'LV' => {
    'rus' => 2,
    'lav' => 1,
    'eng' => 2
  },
  'IR' => {
    'rmt' => 2,
    'tuk' => 2,
    'mzn' => 2,
    'bal' => 2,
    'fas' => 1,
    'sdh' => 2,
    'ara' => 2,
    'lrc' => 2,
    'kur' => 2,
    'bqi' => 2,
    'luz' => 2,
    'ckb' => 2,
    'glk' => 2,
    'aze' => 2
  },
  'MS' => {
    'eng' => 1
  },
  'LC' => {
    'eng' => 1
  },
  'EH' => {
    'ara' => 1
  },
  'US' => {
    'ita' => 2,
    'fil' => 2,
    'eng' => 1,
    'spa' => 2,
    'haw' => 2,
    'zho' => 2,
    'fra' => 2,
    'vie' => 2,
    'kor' => 2,
    'deu' => 2
  },
  'SC' => {
    'fra' => 1,
    'crs' => 2,
    'eng' => 1
  },
  'SL' => {
    'kdh' => 2,
    'men' => 2,
    'kri' => 2,
    'eng' => 1
  },
  'BR' => {
    'por' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'BE' => {
    'vls' => 2,
    'deu' => 1,
    'nld' => 1,
    'eng' => 2,
    'fra' => 1
  },
  'RE' => {
    'fra' => 1,
    'rcf' => 2
  },
  'GY' => {
    'eng' => 1
  },
  'KG' => {
    'kir' => 1,
    'rus' => 1
  },
  'SY' => {
    'kur' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'SZ' => {
    'ssw' => 1,
    'eng' => 1
  },
  'HT' => {
    'fra' => 1,
    'hat' => 1
  },
  'GT' => {
    'quc' => 2,
    'spa' => 1
  },
  'UA' => {
    'pol' => 2,
    'rus' => 1,
    'ukr' => 1
  },
  'TN' => {
    'ara' => 1,
    'fra' => 1,
    'aeb' => 2
  },
  'BQ' => {
    'pap' => 2,
    'nld' => 1
  },
  'TD' => {
    'fra' => 1,
    'ara' => 1
  },
  'NC' => {
    'fra' => 1
  },
  'CW' => {
    'pap' => 1,
    'nld' => 1
  },
  'TJ' => {
    'rus' => 2,
    'tgk' => 1
  },
  'TA' => {
    'eng' => 2
  },
  'TZ' => {
    'nym' => 2,
    'kde' => 2,
    'swa' => 1,
    'eng' => 1,
    'suk' => 2
  },
  'VE' => {
    'spa' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'MT' => {
    'ita' => 2,
    'mlt' => 1,
    'eng' => 1
  },
  'EG' => {
    'arz' => 2,
    'ara' => 2,
    'eng' => 2
  },
  'AO' => {
    'umb' => 2,
    'kmb' => 2,
    'por' => 1
  },
  'BF' => {
    'mos' => 2,
    'fra' => 1,
    'dyu' => 2
  },
  'LB' => {
    'eng' => 2,
    'ara' => 1
  },
  'AR' => {
    'eng' => 2,
    'spa' => 1
  },
  'NP' => {
    'nep' => 1,
    'bho' => 2,
    'mai' => 2
  },
  'TR' => {
    'eng' => 2,
    'kur' => 2,
    'zza' => 2,
    'tur' => 1
  },
  'BO' => {
    'aym' => 1,
    'spa' => 1,
    'que' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'CZ' => {
    'ces' => 1,
    'slk' => 2,
    'deu' => 2,
    'eng' => 2
  },
  'MX' => {
    'spa' => 1,
    'eng' => 2
  },
  'YE' => {
    'ara' => 1,
    'eng' => 2
  },
  'IQ' => {
    'kur' => 2,
    'ara' => 1,
    'ckb' => 2,
    'eng' => 2,
    'aze' => 2
  },
  'VI' => {
    'eng' => 1
  },
  'CN' => {
    'hak' => 2,
    'uig' => 2,
    'gan' => 2,
    'wuu' => 2,
    'bod' => 2,
    'iii' => 2,
    'kaz' => 2,
    'hsn' => 2,
    'zho' => 1,
    'mon' => 2,
    'zha' => 2,
    'kor' => 2,
    'yue' => 2,
    'nan' => 2
  },
  'ME' => {
    'hbs' => 1,
    'srp' => 1
  },
  'MP' => {
    'eng' => 1
  },
  'MH' => {
    'eng' => 1,
    'mah' => 1
  },
  'CO' => {
    'spa' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'CY' => {
    'tur' => 1,
    'ell' => 1,
    'eng' => 2
  },
  'DM' => {
    'eng' => 1
  },
  'MW' => {
    'eng' => 1,
    'nya' => 1,
    'tum' => 2
  },
  'IM' => {
    'glv' => 1,
    'eng' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'UY' => {
    'spa' => 1
  },
  'SE' => {
    'eng' => 2,
    'fin' => 2,
    'swe' => 1
  },
  'SN' => {
    'mey' => 2,
    'sav' => 2,
    'tnr' => 2,
    'dyo' => 2,
    'srr' => 2,
    'knf' => 2,
    'mfv' => 2,
    'bjt' => 2,
    'fra' => 1,
    'snf' => 2,
    'wol' => 1,
    'ful' => 2,
    'bsc' => 2
  },
  'AQ' => {
    'und' => 2
  },
  'ZM' => {
    'bem' => 2,
    'eng' => 1,
    'nya' => 2
  },
  'HK' => {
    'yue' => 2,
    'eng' => 1,
    'zho' => 1
  },
  'VN' => {
    'zho' => 2,
    'vie' => 1
  },
  'RW' => {
    'eng' => 1,
    'kin' => 1,
    'fra' => 1
  },
  'GR' => {
    'eng' => 2,
    'ell' => 1
  },
  'DG' => {
    'eng' => 1
  },
  'PW' => {
    'eng' => 1,
    'pau' => 1
  },
  'TO' => {
    'eng' => 1,
    'ton' => 1
  },
  'VA' => {
    'ita' => 1,
    'lat' => 2
  },
  'VU' => {
    'bis' => 1,
    'fra' => 1,
    'eng' => 1
  },
  'FK' => {
    'eng' => 1
  },
  'MR' => {
    'ara' => 1
  },
  'AE' => {
    'ara' => 1,
    'eng' => 2
  },
  'AC' => {
    'eng' => 2
  },
  'FO' => {
    'fao' => 1
  },
  'AS' => {
    'eng' => 1,
    'smo' => 1
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'NO' => {
    'sme' => 2,
    'nob' => 1,
    'nor' => 1,
    'nno' => 1
  },
  'DE' => {
    'dan' => 2,
    'bar' => 2,
    'rus' => 2,
    'ita' => 2,
    'spa' => 2,
    'nld' => 2,
    'eng' => 2,
    'tur' => 2,
    'fra' => 2,
    'nds' => 2,
    'gsw' => 2,
    'vmf' => 2,
    'deu' => 1
  },
  'PR' => {
    'spa' => 1,
    'eng' => 1
  },
  'NE' => {
    'hau' => 2,
    'tmh' => 2,
    'fuq' => 2,
    'fra' => 1,
    'dje' => 2,
    'ful' => 2
  },
  'MU' => {
    'eng' => 1,
    'mfe' => 2,
    'fra' => 1,
    'bho' => 2
  },
  'CV' => {
    'kea' => 2,
    'por' => 1
  },
  'DK' => {
    'dan' => 1,
    'kal' => 2,
    'deu' => 2,
    'eng' => 2
  }
};
$Script2Lang = {
  'Xpeo' => {
    'peo' => 2
  },
  'Bamu' => {
    'bax' => 1
  },
  'Sinh' => {
    'pli' => 2,
    'sin' => 1,
    'san' => 2
  },
  'Yiii' => {
    'iii' => 1
  },
  'Cham' => {
    'cjm' => 1,
    'cja' => 2
  },
  'Buhd' => {
    'bku' => 2
  },
  'Mroo' => {
    'mro' => 2
  },
  'Bali' => {
    'ban' => 2
  },
  'Geor' => {
    'lzz' => 1,
    'kat' => 1,
    'xmf' => 1
  },
  'Shaw' => {
    'eng' => 2
  },
  'Olck' => {
    'sat' => 1
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Palm' => {
    'arc' => 2
  },
  'Phlp' => {
    'abw' => 2
  },
  'Cher' => {
    'chr' => 1
  },
  'Sidd' => {
    'san' => 2
  },
  'Knda' => {
    'kan' => 1,
    'tcy' => 1
  },
  'Tavt' => {
    'blt' => 1
  },
  'Mani' => {
    'xmn' => 2
  },
  'Tglg' => {
    'fil' => 2
  },
  'Ethi' => {
    'gez' => 2,
    'tir' => 1,
    'byn' => 1,
    'wal' => 1,
    'amh' => 1,
    'tig' => 1,
    'orm' => 2
  },
  'Deva' => {
    'sck' => 1,
    'hoj' => 1,
    'bra' => 1,
    'anp' => 1,
    'wtm' => 1,
    'kas' => 1,
    'mai' => 1,
    'kru' => 1,
    'sat' => 2,
    'raj' => 1,
    'gom' => 1,
    'xsr' => 1,
    'kok' => 1,
    'tkt' => 1,
    'mwr' => 1,
    'mrd' => 1,
    'pli' => 2,
    'brx' => 1,
    'thq' => 1,
    'doi' => 1,
    'bho' => 1,
    'gbm' => 1,
    'jml' => 1,
    'san' => 2,
    'lif' => 1,
    'hin' => 1,
    'kfy' => 1,
    'tdg' => 1,
    'mag' => 1,
    'bfy' => 1,
    'mar' => 1,
    'gvr' => 1,
    'taj' => 1,
    'rjs' => 1,
    'hne' => 1,
    'bjj' => 1,
    'tdh' => 1,
    'hoc' => 1,
    'unr' => 1,
    'thl' => 1,
    'srx' => 1,
    'noe' => 1,
    'bgc' => 1,
    'awa' => 1,
    'kfr' => 1,
    'gon' => 1,
    'thr' => 1,
    'nep' => 1,
    'bap' => 1,
    'bhb' => 1,
    'new' => 1,
    'xnr' => 1,
    'swv' => 1,
    'khn' => 1,
    'mtr' => 1,
    'dty' => 1,
    'mgp' => 1,
    'snd' => 1,
    'btv' => 1,
    'unx' => 1,
    'hif' => 1,
    'wbr' => 1,
    'bhi' => 1
  },
  'Prti' => {
    'xpr' => 2
  },
  'Hant' => {
    'yue' => 1,
    'zho' => 1
  },
  'Gran' => {
    'san' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Arab' => {
    'kxp' => 1,
    'arz' => 1,
    'ars' => 1,
    'raj' => 1,
    'wni' => 1,
    'kas' => 1,
    'lki' => 1,
    'prd' => 1,
    'tly' => 1,
    'tgk' => 1,
    'cja' => 1,
    'rmt' => 1,
    'gju' => 1,
    'lah' => 1,
    'sus' => 2,
    'uig' => 1,
    'ara' => 1,
    'haz' => 1,
    'bqi' => 1,
    'shr' => 1,
    'skr' => 1,
    'ttt' => 2,
    'aze' => 1,
    'urd' => 1,
    'hau' => 1,
    'khw' => 1,
    'glk' => 1,
    'dyo' => 2,
    'pan' => 1,
    'bft' => 1,
    'fia' => 1,
    'gbz' => 1,
    'snd' => 1,
    'mzn' => 1,
    'mfa' => 1,
    'mvy' => 1,
    'fas' => 1,
    'kur' => 1,
    'lrc' => 1,
    'pus' => 1,
    'luz' => 1,
    'doi' => 1,
    'hno' => 1,
    'dcc' => 1,
    'tur' => 2,
    'wol' => 2,
    'kir' => 1,
    'arq' => 1,
    'ind' => 2,
    'uzb' => 1,
    'bej' => 1,
    'inh' => 2,
    'bgn' => 1,
    'cjm' => 2,
    'swb' => 1,
    'cop' => 2,
    'ary' => 1,
    'zdj' => 1,
    'som' => 2,
    'hnd' => 1,
    'gjk' => 1,
    'ckb' => 1,
    'brh' => 1,
    'kaz' => 1,
    'msa' => 1,
    'bal' => 1,
    'tuk' => 1,
    'aeb' => 1,
    'sdh' => 1,
    'kvx' => 1
  },
  'Batk' => {
    'bbc' => 2
  },
  'Hebr' => {
    'heb' => 1,
    'snx' => 2,
    'jpr' => 1,
    'lad' => 1,
    'yid' => 1,
    'jrb' => 1
  },
  'Mong' => {
    'mon' => 2,
    'mnc' => 2
  },
  'Tibt' => {
    'bft' => 2,
    'tsj' => 1,
    'dzo' => 1,
    'taj' => 2,
    'tdg' => 2,
    'bod' => 1
  },
  'Narb' => {
    'xna' => 2
  },
  'Bugi' => {
    'mdr' => 2,
    'bug' => 2,
    'mak' => 2
  },
  'Kana' => {
    'ryu' => 1,
    'ain' => 2
  },
  'Phli' => {
    'abw' => 2
  },
  'Java' => {
    'jav' => 2
  },
  'Kore' => {
    'kor' => 1
  },
  'Cans' => {
    'chp' => 2,
    'oji' => 1,
    'nsk' => 1,
    'crk' => 1,
    'crj' => 1,
    'iku' => 1,
    'den' => 2,
    'cre' => 1,
    'csw' => 1,
    'crl' => 1,
    'crm' => 1
  },
  'Nbat' => {
    'arc' => 2
  },
  'Shrd' => {
    'san' => 2
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Thai' => {
    'tts' => 1,
    'sqq' => 1,
    'kxm' => 1,
    'kdt' => 1,
    'tha' => 1,
    'lcp' => 1,
    'pli' => 2,
    'lwl' => 1
  },
  'Sylo' => {
    'syl' => 2
  },
  'Aghb' => {
    'lez' => 2
  },
  'Tfng' => {
    'zgh' => 1,
    'zen' => 2,
    'rif' => 1,
    'tzm' => 1,
    'shr' => 1
  },
  'Ugar' => {
    'uga' => 2
  },
  'Osma' => {
    'som' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Hans' => {
    'wuu' => 1,
    'hak' => 1,
    'lzh' => 2,
    'gan' => 1,
    'yue' => 1,
    'nan' => 1,
    'zho' => 1,
    'hsn' => 1,
    'zha' => 2
  },
  'Beng' => {
    'unr' => 1,
    'bpy' => 1,
    'syl' => 1,
    'kha' => 2,
    'grt' => 1,
    'ben' => 1,
    'mni' => 1,
    'ccp' => 1,
    'rkt' => 1,
    'asm' => 1,
    'lus' => 1,
    'unx' => 1,
    'sat' => 2
  },
  'Khmr' => {
    'khm' => 1
  },
  'Tirh' => {
    'mai' => 2
  },
  'Avst' => {
    'ave' => 2
  },
  'Hano' => {
    'hnn' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Mymr' => {
    'mya' => 1,
    'shn' => 1,
    'mnw' => 1,
    'kht' => 1
  },
  'Wara' => {
    'hoc' => 2
  },
  'Osge' => {
    'osa' => 1
  },
  'Mend' => {
    'men' => 2
  },
  'Mtei' => {
    'mni' => 2
  },
  'Linb' => {
    'grc' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Ogam' => {
    'sga' => 2
  },
  'Samr' => {
    'snx' => 2,
    'smp' => 2
  },
  'Lydi' => {
    'xld' => 2
  },
  'Lina' => {
    'lab' => 2
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Syrc' => {
    'ara' => 2,
    'aii' => 2,
    'tru' => 2,
    'syr' => 2
  },
  'Talu' => {
    'khb' => 1
  },
  'Nkoo' => {
    'man' => 1,
    'bam' => 1,
    'nqo' => 1
  },
  'Sind' => {
    'snd' => 2
  },
  'Bopo' => {
    'zho' => 2
  },
  'Laoo' => {
    'hnj' => 1,
    'lao' => 1,
    'kjg' => 1,
    'hmn' => 1
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Armn' => {
    'hye' => 1
  },
  'Tale' => {
    'tdd' => 1
  },
  'Latn' => {
    'cic' => 1,
    'arp' => 1,
    'kge' => 1,
    'szl' => 1,
    'ain' => 2,
    'war' => 1,
    'dum' => 2,
    'nbl' => 1,
    'gcr' => 1,
    'wln' => 1,
    'kln' => 1,
    'fit' => 1,
    'del' => 1,
    'bla' => 1,
    'nso' => 1,
    'luo' => 1,
    'nau' => 1,
    'vun' => 1,
    'asa' => 1,
    'zag' => 1,
    'sat' => 2,
    'tur' => 1,
    'dgr' => 1,
    'qug' => 1,
    'roh' => 1,
    'mwl' => 1,
    'rar' => 1,
    'aoz' => 1,
    'zea' => 1,
    'rmo' => 1,
    'dje' => 1,
    'afr' => 1,
    'sly' => 1,
    'dnj' => 1,
    'chp' => 1,
    'lua' => 1,
    'mic' => 1,
    'arg' => 1,
    'mro' => 1,
    'dsb' => 1,
    'fon' => 1,
    'bal' => 2,
    'bjn' => 1,
    'kkj' => 1,
    'nhe' => 1,
    'inh' => 2,
    'ewe' => 1,
    'jav' => 1,
    'sms' => 1,
    'swb' => 2,
    'wbp' => 1,
    'yor' => 1,
    'lat' => 2,
    'nde' => 1,
    'haw' => 1,
    'gba' => 1,
    'rwk' => 1,
    'fra' => 1,
    'scs' => 1,
    'gla' => 1,
    'ton' => 1,
    'yap' => 1,
    'som' => 1,
    'lun' => 1,
    'bez' => 1,
    'gmh' => 2,
    'fuv' => 1,
    'bmq' => 1,
    'sdc' => 1,
    'tet' => 1,
    'guc' => 1,
    'hin' => 2,
    'ssw' => 1,
    'mgh' => 1,
    'spa' => 1,
    'tsg' => 1,
    'pau' => 1,
    'srn' => 1,
    'niu' => 1,
    'bbc' => 1,
    'kdx' => 1,
    'din' => 1,
    'lag' => 1,
    'mlg' => 1,
    'cps' => 1,
    'sus' => 1,
    'fij' => 1,
    'vec' => 1,
    'jgo' => 1,
    'rej' => 1,
    'nyo' => 1,
    'hmo' => 1,
    'kdh' => 1,
    'mgy' => 1,
    'snk' => 1,
    'vie' => 1,
    'njo' => 1,
    'nzi' => 1,
    'ful' => 1,
    'mad' => 1,
    'ljp' => 1,
    'dyo' => 1,
    'swa' => 1,
    'kha' => 1,
    'vmw' => 1,
    'fry' => 1,
    'frs' => 1,
    'run' => 1,
    'frp' => 1,
    'vls' => 1,
    'sun' => 1,
    'fuq' => 1,
    'dak' => 1,
    'twq' => 1,
    'lzz' => 1,
    'ngl' => 1,
    'ilo' => 1,
    'nya' => 1,
    'aar' => 1,
    'ttt' => 1,
    'fud' => 1,
    'bto' => 1,
    'bik' => 1,
    'fro' => 2,
    'lub' => 1,
    'prg' => 2,
    'cho' => 1,
    'kab' => 1,
    'kjg' => 2,
    'moh' => 1,
    'sot' => 1,
    'lit' => 1,
    'arw' => 2,
    'sid' => 1,
    'ind' => 1,
    'dua' => 1,
    'teo' => 1,
    'hun' => 1,
    'lim' => 1,
    'kfo' => 1,
    'bem' => 1,
    'nap' => 1,
    'grn' => 1,
    'mri' => 1,
    'tso' => 1,
    'mwv' => 1,
    'sga' => 2,
    'bkm' => 1,
    'sag' => 1,
    'pcd' => 1,
    'ttb' => 1,
    'sme' => 1,
    'nov' => 2,
    'aka' => 1,
    'nmg' => 1,
    'nch' => 1,
    'atj' => 1,
    'kpe' => 1,
    'bze' => 1,
    'chk' => 1,
    'tkr' => 1,
    'lkt' => 1,
    'oci' => 1,
    'rap' => 1,
    'brh' => 2,
    'msa' => 1,
    'mak' => 1,
    'kmb' => 1,
    'goh' => 2,
    'zul' => 1,
    'ndo' => 1,
    'yav' => 1,
    'lol' => 1,
    'aro' => 1,
    'slv' => 1,
    'vol' => 2,
    'iii' => 2,
    'glg' => 1,
    'rom' => 1,
    'ibo' => 1,
    'tru' => 1,
    'pon' => 1,
    'tly' => 1,
    'kea' => 1,
    'tgk' => 1,
    'srb' => 1,
    'bin' => 1,
    'man' => 1,
    'mls' => 1,
    'cym' => 1,
    'dtp' => 1,
    'frr' => 1,
    'pnt' => 1,
    'agq' => 1,
    'mlt' => 1,
    'lam' => 1,
    'swg' => 1,
    'see' => 1,
    'sqi' => 1,
    'hrv' => 1,
    'lut' => 2,
    'loz' => 1,
    'xav' => 1,
    'bku' => 1,
    'zza' => 1,
    'kua' => 1,
    'nav' => 1,
    'hif' => 1,
    'her' => 1,
    'gos' => 1,
    'ast' => 1,
    'nsk' => 2,
    'lug' => 1,
    'lbw' => 1,
    'rug' => 1,
    'ina' => 2,
    'ada' => 1,
    'ndc' => 1,
    'uig' => 2,
    'nus' => 1,
    'shr' => 1,
    'wae' => 1,
    'ibb' => 1,
    'crl' => 2,
    'arn' => 1,
    'car' => 1,
    'mnu' => 1,
    'gay' => 1,
    'tum' => 1,
    'rob' => 1,
    'smo' => 1,
    'saf' => 1,
    'bfd' => 1,
    'mus' => 1,
    'kvr' => 1,
    'tkl' => 1,
    'que' => 1,
    'nld' => 1,
    'mxc' => 1,
    'bam' => 1,
    'pdc' => 1,
    'hmn' => 1,
    'ext' => 1,
    'zha' => 1,
    'osa' => 2,
    'kax' => 1,
    'maf' => 1,
    'ven' => 1,
    'ang' => 2,
    'zap' => 1,
    'kur' => 1,
    'ybb' => 1,
    'efi' => 1,
    'kau' => 1,
    'eng' => 1,
    'lin' => 1,
    'mah' => 1,
    'kgp' => 1,
    'cha' => 1,
    'cgg' => 1,
    'mdt' => 1,
    'maz' => 1,
    'jut' => 2,
    'iba' => 1,
    'aym' => 1,
    'bvb' => 1,
    'akz' => 1,
    'kir' => 1,
    'rgn' => 1,
    'wol' => 1,
    'bmv' => 1,
    'stq' => 1,
    'crj' => 2,
    'lfn' => 2,
    'ach' => 1,
    'naq' => 1,
    'kac' => 1,
    'rtm' => 1,
    'slk' => 1,
    'moe' => 1,
    'tvl' => 1,
    'izh' => 1,
    'nym' => 1,
    'guz' => 1,
    'tuk' => 1,
    'vep' => 1,
    'hup' => 1,
    'eka' => 1,
    'chn' => 2,
    'nxq' => 1,
    'gle' => 1,
    'swe' => 1,
    'rup' => 1,
    'pdt' => 1,
    'hat' => 1,
    'est' => 1,
    'cat' => 1,
    'ctd' => 1,
    'hbs' => 1,
    'tli' => 1,
    'pag' => 1,
    'nno' => 1,
    'amo' => 1,
    'glv' => 1,
    'ceb' => 1,
    'saq' => 1,
    'hai' => 1,
    'zun' => 1,
    'mwk' => 1,
    'lav' => 1,
    'esu' => 1,
    'dtm' => 1,
    'ale' => 1,
    'mua' => 1,
    'csb' => 2,
    'nob' => 1,
    'grb' => 1,
    'kut' => 1,
    'kal' => 1,
    'hsb' => 1,
    'fan' => 1,
    'ett' => 2,
    'lmo' => 1,
    'crs' => 1,
    'sad' => 1,
    'dan' => 1,
    'gqr' => 1,
    'fin' => 1,
    'bqv' => 1,
    'ses' => 1,
    'oji' => 2,
    'dav' => 1,
    'hnn' => 1,
    'ron' => 1,
    'hop' => 1,
    'ife' => 1,
    'por' => 1,
    'gur' => 1,
    'frc' => 1,
    'xog' => 1,
    'khq' => 1,
    'uli' => 1,
    'sas' => 1,
    'bas' => 1,
    'luy' => 1,
    'mas' => 1,
    'cad' => 1,
    'kaj' => 1,
    'pol' => 1,
    'ter' => 1,
    'deu' => 1,
    'kin' => 1,
    'tiv' => 1,
    'hil' => 1,
    'byv' => 1,
    'suk' => 1,
    'vai' => 1,
    'buc' => 1,
    'enm' => 2,
    'zmi' => 1,
    'jmc' => 1,
    'abr' => 1,
    'pfl' => 1,
    'kcg' => 1,
    'kiu' => 1,
    'min' => 1,
    'aln' => 1,
    'gsw' => 1,
    'cos' => 1,
    'nyn' => 1,
    'bar' => 1,
    'ikt' => 1,
    'ace' => 1,
    'tog' => 1,
    'sbp' => 1,
    'uzb' => 1,
    'rof' => 1,
    'pms' => 1,
    'ssy' => 1,
    'xum' => 2,
    'fao' => 1,
    'tsi' => 1,
    'tzm' => 1,
    'cch' => 1,
    'rmf' => 1,
    'vic' => 1,
    'chy' => 1,
    'den' => 1,
    'nor' => 1,
    'ita' => 1,
    'tpi' => 1,
    'srd' => 1,
    'seh' => 1,
    'bug' => 1,
    'rmu' => 1,
    'trv' => 1,
    'udm' => 2,
    'tmh' => 1,
    'ffm' => 1,
    'ttj' => 1,
    'pap' => 1,
    'ebu' => 1,
    'bre' => 1,
    'pcm' => 1,
    'vro' => 1,
    'iku' => 1,
    'frm' => 2,
    'yao' => 1,
    'bos' => 1,
    'sgs' => 1,
    'mdr' => 1,
    'syi' => 1,
    'sxn' => 1,
    'lui' => 2,
    'ipk' => 1,
    'nds' => 1,
    'sei' => 1,
    'srr' => 1,
    'men' => 1,
    'pro' => 2,
    'yrl' => 1,
    'nnh' => 1,
    'kde' => 1,
    'liv' => 2,
    'sco' => 1,
    'kik' => 1,
    'cor' => 1,
    'bew' => 1,
    'umb' => 1,
    'nij' => 1,
    'rif' => 1,
    'tsn' => 1,
    'kck' => 1,
    'dyu' => 1,
    'puu' => 1,
    'nia' => 1,
    'lij' => 1,
    'ban' => 1,
    'krj' => 1,
    'orm' => 1,
    'mfe' => 1,
    'vot' => 2,
    'ltz' => 1,
    'ksh' => 1,
    'tah' => 1,
    'sma' => 1,
    'gwi' => 1,
    'fvr' => 1,
    'eus' => 1,
    'ria' => 1,
    'ewo' => 1,
    'myx' => 1,
    'smj' => 1,
    'tbw' => 1,
    'fil' => 1,
    'ltg' => 1,
    'yua' => 1,
    'sli' => 1,
    'cre' => 2,
    'cay' => 1,
    'smn' => 1,
    'pko' => 1,
    'srp' => 1,
    'bss' => 1,
    'avk' => 2,
    'isl' => 1,
    'mdh' => 1,
    'jam' => 1,
    'bbj' => 1,
    'gag' => 1,
    'kon' => 1,
    'bzx' => 1,
    'quc' => 1,
    'mos' => 1,
    'sef' => 1,
    'epo' => 1,
    'kri' => 1,
    'xho' => 1,
    'scn' => 1,
    'rng' => 1,
    'rcf' => 1,
    'gil' => 1,
    'egl' => 1,
    'sna' => 1,
    'laj' => 1,
    'wls' => 1,
    'kos' => 1,
    'ces' => 1,
    'mgo' => 1,
    'aze' => 1,
    'bci' => 1,
    'was' => 1,
    'bis' => 1,
    'hau' => 1,
    'pmn' => 1,
    'osc' => 2,
    'gub' => 1,
    'krl' => 1,
    'ksf' => 1,
    'ksb' => 1,
    'vmf' => 1,
    'nhw' => 1
  },
  'Plrd' => {
    'hmn' => 1,
    'hmd' => 1
  },
  'Taml' => {
    'bfq' => 1,
    'tam' => 1
  },
  'Mand' => {
    'myz' => 2
  },
  'Runr' => {
    'deu' => 2,
    'non' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Cyrl' => {
    'sel' => 2,
    'gag' => 2,
    'ude' => 1,
    'yrk' => 1,
    'crh' => 1,
    'tat' => 1,
    'syr' => 1,
    'mon' => 1,
    'gld' => 1,
    'che' => 1,
    'aze' => 1,
    'ttt' => 1,
    'chv' => 1,
    'uig' => 1,
    'sah' => 1,
    'ukr' => 1,
    'abk' => 1,
    'ava' => 1,
    'xal' => 1,
    'tgk' => 1,
    'mrj' => 1,
    'tly' => 1,
    'kkt' => 1,
    'chu' => 2,
    'pnt' => 1,
    'aii' => 1,
    'abq' => 1,
    'srp' => 1,
    'ron' => 2,
    'bos' => 1,
    'kom' => 1,
    'mdf' => 1,
    'lfn' => 2,
    'lez' => 1,
    'evn' => 1,
    'tkr' => 1,
    'tuk' => 1,
    'ady' => 1,
    'tyv' => 1,
    'bub' => 1,
    'kjh' => 1,
    'kum' => 1,
    'kaz' => 1,
    'kca' => 1,
    'kpy' => 1,
    'hbs' => 1,
    'tab' => 1,
    'inh' => 1,
    'rus' => 1,
    'alt' => 1,
    'kbd' => 1,
    'rom' => 2,
    'cjs' => 1,
    'dng' => 1,
    'lbe' => 1,
    'rue' => 1,
    'bul' => 1,
    'uzb' => 1,
    'bak' => 1,
    'oss' => 1,
    'bel' => 1,
    'dar' => 1,
    'chm' => 1,
    'sme' => 2,
    'mns' => 1,
    'kur' => 1,
    'mkd' => 1,
    'krc' => 1,
    'kaa' => 1,
    'ckt' => 1,
    'nog' => 1,
    'kir' => 1,
    'myv' => 1,
    'udm' => 1
  },
  'Thaa' => {
    'div' => 1
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Mlym' => {
    'mal' => 1
  },
  'Takr' => {
    'doi' => 2
  },
  'Grek' => {
    'tsd' => 1,
    'pnt' => 1,
    'bgx' => 1,
    'ell' => 1,
    'grc' => 2,
    'cop' => 2
  },
  'Phnx' => {
    'phn' => 2
  },
  'Orkh' => {
    'otk' => 2
  },
  'Khoj' => {
    'snd' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Modi' => {
    'mar' => 2
  },
  'Orya' => {
    'sat' => 2,
    'ori' => 1
  },
  'Telu' => {
    'gon' => 1,
    'tel' => 1,
    'wbq' => 1,
    'lmn' => 1
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Elba' => {
    'sqi' => 2
  },
  'Guru' => {
    'pan' => 1
  },
  'Lepc' => {
    'lep' => 1
  },
  'Sora' => {
    'srb' => 2
  },
  'Copt' => {
    'cop' => 2
  },
  'Limb' => {
    'lif' => 1
  },
  'Xsux' => {
    'hit' => 2,
    'akk' => 2
  },
  'Armi' => {
    'arc' => 2
  },
  'Sund' => {
    'sun' => 2
  },
  'Vaii' => {
    'vai' => 1
  },
  'Dupl' => {
    'fra' => 2
  },
  'Gujr' => {
    'guj' => 1
  },
  'Cprt' => {
    'grc' => 2
  },
  'Ital' => {
    'ett' => 2,
    'xum' => 2,
    'osc' => 2
  },
  'Egyp' => {
    'egy' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Phag' => {
    'mon' => 2,
    'zho' => 2
  },
  'Hani' => {
    'vie' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Cakm' => {
    'ccp' => 1
  }
};
$DefaultScript = {
  'asa' => 'Latn',
  'tdd' => 'Tale',
  'vun' => 'Latn',
  'luo' => 'Latn',
  'jpr' => 'Hebr',
  'byn' => 'Ethi',
  'hnj' => 'Laoo',
  'dcc' => 'Arab',
  'tur' => 'Latn',
  'sat' => 'Olck',
  'wal' => 'Ethi',
  'jpn' => 'Jpan',
  'szl' => 'Latn',
  'kfy' => 'Deva',
  'mar' => 'Deva',
  'cic' => 'Latn',
  'gvr' => 'Deva',
  'gcr' => 'Latn',
  'bej' => 'Arab',
  'bak' => 'Cyrl',
  'bla' => 'Latn',
  'del' => 'Latn',
  'wln' => 'Latn',
  'bap' => 'Deva',
  'jav' => 'Latn',
  'sms' => 'Latn',
  'rus' => 'Cyrl',
  'kkj' => 'Latn',
  'ewe' => 'Latn',
  'swb' => 'Arab',
  'kbd' => 'Cyrl',
  'lun' => 'Latn',
  'som' => 'Latn',
  'ton' => 'Latn',
  'afr' => 'Latn',
  'dje' => 'Latn',
  'lcp' => 'Thai',
  'mwl' => 'Latn',
  'rkt' => 'Beng',
  'zea' => 'Latn',
  'evn' => 'Cyrl',
  'rmo' => 'Latn',
  'rar' => 'Latn',
  'bal' => 'Arab',
  'dsb' => 'Latn',
  'mro' => 'Latn',
  'nan' => 'Hans',
  'hsn' => 'Hans',
  'dnj' => 'Latn',
  'mic' => 'Latn',
  'hmo' => 'Latn',
  'gom' => 'Deva',
  'njo' => 'Latn',
  'ful' => 'Latn',
  'nzi' => 'Latn',
  'vie' => 'Latn',
  'ssw' => 'Latn',
  'hin' => 'Deva',
  'cja' => 'Arab',
  'tsg' => 'Latn',
  'pau' => 'Latn',
  'bmq' => 'Latn',
  'fuv' => 'Latn',
  'sdc' => 'Latn',
  'mal' => 'Mlym',
  'cps' => 'Latn',
  'lag' => 'Latn',
  'vec' => 'Latn',
  'fij' => 'Latn',
  'sus' => 'Latn',
  'kdx' => 'Latn',
  'din' => 'Latn',
  'aar' => 'Latn',
  'skr' => 'Arab',
  'lad' => 'Hebr',
  'twq' => 'Latn',
  'ilo' => 'Latn',
  'bik' => 'Latn',
  'bto' => 'Latn',
  'fud' => 'Latn',
  'heb' => 'Hebr',
  'swa' => 'Latn',
  'dyo' => 'Latn',
  'vmw' => 'Latn',
  'swv' => 'Deva',
  'khn' => 'Deva',
  'run' => 'Latn',
  'frs' => 'Latn',
  'bkm' => 'Latn',
  'brx' => 'Deva',
  'lrc' => 'Arab',
  'sqq' => 'Thai',
  'pcd' => 'Latn',
  'nmg' => 'Latn',
  'wtm' => 'Deva',
  'dua' => 'Latn',
  'sid' => 'Latn',
  'ind' => 'Latn',
  'bul' => 'Cyrl',
  'sot' => 'Latn',
  'lit' => 'Latn',
  'grn' => 'Latn',
  'nap' => 'Latn',
  'lus' => 'Beng',
  'mri' => 'Latn',
  'teo' => 'Latn',
  'hun' => 'Latn',
  'bem' => 'Latn',
  'bgc' => 'Deva',
  'thl' => 'Deva',
  'kpy' => 'Cyrl',
  'tab' => 'Cyrl',
  'tir' => 'Ethi',
  'rom' => 'Latn',
  'bjj' => 'Deva',
  'iii' => 'Yiii',
  'glg' => 'Latn',
  'oci' => 'Latn',
  'brh' => 'Arab',
  'rap' => 'Latn',
  'kpe' => 'Latn',
  'shn' => 'Mymr',
  'bze' => 'Latn',
  'ndo' => 'Latn',
  'lol' => 'Latn',
  'yav' => 'Latn',
  'kca' => 'Cyrl',
  'mak' => 'Latn',
  'mlt' => 'Latn',
  'agq' => 'Latn',
  'aii' => 'Cyrl',
  'lki' => 'Arab',
  'div' => 'Thaa',
  'arz' => 'Arab',
  'srb' => 'Latn',
  'eky' => 'Kali',
  'xmf' => 'Geor',
  'kea' => 'Latn',
  'kkt' => 'Cyrl',
  'bgx' => 'Grek',
  'chr' => 'Cher',
  'ibb' => 'Latn',
  'wae' => 'Latn',
  'srx' => 'Deva',
  'haz' => 'Arab',
  'nus' => 'Latn',
  'ukr' => 'Cyrl',
  'saf' => 'Latn',
  'mnu' => 'Latn',
  'smo' => 'Latn',
  'tum' => 'Latn',
  'her' => 'Latn',
  'nav' => 'Latn',
  'kua' => 'Latn',
  'khw' => 'Arab',
  'bku' => 'Latn',
  'kxm' => 'Thai',
  'mzn' => 'Arab',
  'mfa' => 'Arab',
  'khm' => 'Khmr',
  'ndc' => 'Latn',
  'rug' => 'Latn',
  'lbw' => 'Latn',
  'fia' => 'Arab',
  'lug' => 'Latn',
  'kgp' => 'Latn',
  'xsr' => 'Deva',
  'ybb' => 'Latn',
  'kdt' => 'Thai',
  'zap' => 'Latn',
  'pus' => 'Arab',
  'nog' => 'Cyrl',
  'wol' => 'Latn',
  'rgn' => 'Latn',
  'bmv' => 'Latn',
  'bvb' => 'Latn',
  'mnw' => 'Mymr',
  'iba' => 'Latn',
  'mxc' => 'Latn',
  'nld' => 'Latn',
  'hmn' => 'Latn',
  'kvr' => 'Latn',
  'tkl' => 'Latn',
  'maf' => 'Latn',
  'ext' => 'Latn',
  'kax' => 'Latn',
  'hat' => 'Latn',
  'est' => 'Latn',
  'pdt' => 'Latn',
  'cat' => 'Latn',
  'cjm' => 'Cham',
  'ceb' => 'Latn',
  'glv' => 'Latn',
  'nno' => 'Latn',
  'pag' => 'Latn',
  'kyu' => 'Kali',
  'crj' => 'Cans',
  'ach' => 'Latn',
  'stq' => 'Latn',
  'lez' => 'Cyrl',
  'vep' => 'Latn',
  'hup' => 'Latn',
  'sdh' => 'Arab',
  'mtr' => 'Deva',
  'kvx' => 'Arab',
  'izh' => 'Latn',
  'kjh' => 'Cyrl',
  'guz' => 'Latn',
  'gqr' => 'Latn',
  'sad' => 'Latn',
  'dan' => 'Latn',
  'blt' => 'Tavt',
  'hnn' => 'Latn',
  'ife' => 'Latn',
  'ars' => 'Arab',
  'ses' => 'Latn',
  'oji' => 'Cans',
  'bqv' => 'Latn',
  'wni' => 'Arab',
  'raj' => 'Deva',
  'lav' => 'Latn',
  'dtm' => 'Latn',
  'lao' => 'Laoo',
  'jml' => 'Deva',
  'kut' => 'Latn',
  'kal' => 'Latn',
  'awa' => 'Deva',
  'byv' => 'Latn',
  'abk' => 'Cyrl',
  'min' => 'Latn',
  'pfl' => 'Latn',
  'kiu' => 'Latn',
  'lwl' => 'Thai',
  'xal' => 'Cyrl',
  'ava' => 'Cyrl',
  'buc' => 'Latn',
  'tdh' => 'Deva',
  'khq' => 'Latn',
  'uli' => 'Latn',
  'mni' => 'Beng',
  'pol' => 'Latn',
  'kin' => 'Latn',
  'cad' => 'Latn',
  'luy' => 'Latn',
  'mas' => 'Latn',
  'seh' => 'Latn',
  'srd' => 'Latn',
  'kok' => 'Deva',
  'tpi' => 'Latn',
  'trv' => 'Latn',
  'mrd' => 'Deva',
  'ita' => 'Latn',
  'vic' => 'Latn',
  'ckt' => 'Cyrl',
  'hoj' => 'Deva',
  'tmh' => 'Latn',
  'bre' => 'Latn',
  'tog' => 'Latn',
  'tdg' => 'Deva',
  'ace' => 'Latn',
  'bar' => 'Latn',
  'ikt' => 'Latn',
  'cch' => 'Latn',
  'tsi' => 'Latn',
  'rmf' => 'Latn',
  'bel' => 'Cyrl',
  'pms' => 'Latn',
  'dar' => 'Cyrl',
  'ssy' => 'Latn',
  'sco' => 'Latn',
  'nep' => 'Deva',
  'hak' => 'Hans',
  'yrl' => 'Latn',
  'bhb' => 'Deva',
  'tsn' => 'Latn',
  'kck' => 'Latn',
  'cor' => 'Latn',
  'dng' => 'Cyrl',
  'kan' => 'Knda',
  'umb' => 'Latn',
  'yao' => 'Latn',
  'kom' => 'Cyrl',
  'syi' => 'Latn',
  'sxn' => 'Latn',
  'mdf' => 'Cyrl',
  'bhi' => 'Deva',
  'ady' => 'Cyrl',
  'tyv' => 'Cyrl',
  'men' => 'Latn',
  'sei' => 'Latn',
  'nds' => 'Latn',
  'srr' => 'Latn',
  'fil' => 'Latn',
  'ltg' => 'Latn',
  'sli' => 'Latn',
  'yua' => 'Latn',
  'grt' => 'Beng',
  'ewo' => 'Latn',
  'kxp' => 'Arab',
  'bss' => 'Latn',
  'pko' => 'Latn',
  'jam' => 'Latn',
  'bbj' => 'Latn',
  'mdh' => 'Latn',
  'cay' => 'Latn',
  'ban' => 'Latn',
  'mfe' => 'Latn',
  'krj' => 'Latn',
  'hmd' => 'Plrd',
  'eus' => 'Latn',
  'rmt' => 'Arab',
  'sin' => 'Sinh',
  'fvr' => 'Latn',
  'ksh' => 'Latn',
  'mgo' => 'Latn',
  'ryu' => 'Kana',
  'zgh' => 'Tfng',
  'tam' => 'Taml',
  'nod' => 'Lana',
  'wbq' => 'Telu',
  'gub' => 'Latn',
  'ksf' => 'Latn',
  'kor' => 'Kore',
  'ksb' => 'Latn',
  'bis' => 'Latn',
  'was' => 'Latn',
  'glk' => 'Arab',
  'quc' => 'Latn',
  'kon' => 'Latn',
  'yrk' => 'Cyrl',
  'rng' => 'Latn',
  'kri' => 'Latn',
  'xho' => 'Latn',
  'ori' => 'Orya',
  'fas' => 'Arab',
  'bft' => 'Arab',
  'mos' => 'Latn',
  'gld' => 'Cyrl',
  'epo' => 'Latn',
  'mwr' => 'Deva',
  'zag' => 'Latn',
  'thq' => 'Deva',
  'nau' => 'Latn',
  'luz' => 'Arab',
  'kaa' => 'Cyrl',
  'bho' => 'Deva',
  'qug' => 'Latn',
  'bra' => 'Deva',
  'kru' => 'Deva',
  'dgr' => 'Latn',
  'war' => 'Latn',
  'kht' => 'Mymr',
  'bfy' => 'Deva',
  'arp' => 'Latn',
  'kge' => 'Latn',
  'nso' => 'Latn',
  'jrb' => 'Hebr',
  'nbl' => 'Latn',
  'bax' => 'Bamu',
  'kln' => 'Latn',
  'fit' => 'Latn',
  'hoc' => 'Deva',
  'tig' => 'Ethi',
  'nde' => 'Latn',
  'gba' => 'Latn',
  'haw' => 'Latn',
  'nhe' => 'Latn',
  'inh' => 'Cyrl',
  'wbp' => 'Latn',
  'yor' => 'Latn',
  'bez' => 'Latn',
  'hnd' => 'Arab',
  'rwk' => 'Latn',
  'fra' => 'Latn',
  'yap' => 'Latn',
  'scs' => 'Latn',
  'gla' => 'Latn',
  'wuu' => 'Hans',
  'sly' => 'Latn',
  'wbr' => 'Deva',
  'roh' => 'Latn',
  'aoz' => 'Latn',
  'fon' => 'Latn',
  'tel' => 'Telu',
  'arg' => 'Latn',
  'bjn' => 'Latn',
  'chp' => 'Latn',
  'lua' => 'Latn',
  'kum' => 'Cyrl',
  'jgo' => 'Latn',
  'nyo' => 'Latn',
  'rej' => 'Latn',
  'lep' => 'Lepc',
  'mgy' => 'Latn',
  'snk' => 'Latn',
  'kdh' => 'Latn',
  'mgh' => 'Latn',
  'guc' => 'Latn',
  'srn' => 'Latn',
  'spa' => 'Latn',
  'tet' => 'Latn',
  'mlg' => 'Latn',
  'saz' => 'Saur',
  'niu' => 'Latn',
  'bbc' => 'Latn',
  'noe' => 'Deva',
  'nya' => 'Latn',
  'dak' => 'Latn',
  'sun' => 'Latn',
  'fuq' => 'Latn',
  'ngl' => 'Latn',
  'kjg' => 'Laoo',
  'kab' => 'Latn',
  'cho' => 'Latn',
  'lub' => 'Latn',
  'kha' => 'Latn',
  'mad' => 'Latn',
  'ljp' => 'Latn',
  'frp' => 'Latn',
  'crh' => 'Cyrl',
  'vls' => 'Latn',
  'mgp' => 'Deva',
  'fry' => 'Latn',
  'mon' => 'Cyrl',
  'sme' => 'Latn',
  'csw' => 'Cans',
  'sag' => 'Latn',
  'mwv' => 'Latn',
  'krc' => 'Cyrl',
  'ttb' => 'Latn',
  'nch' => 'Latn',
  'aka' => 'Latn',
  'tha' => 'Thai',
  'moh' => 'Latn',
  'tso' => 'Latn',
  'tsd' => 'Grek',
  'lim' => 'Latn',
  'kfo' => 'Latn',
  'crk' => 'Cans',
  'slv' => 'Latn',
  'new' => 'Deva',
  'aro' => 'Latn',
  'cjs' => 'Cyrl',
  'tru' => 'Latn',
  'gjk' => 'Arab',
  'ibo' => 'Latn',
  'atj' => 'Latn',
  'lkt' => 'Latn',
  'ckb' => 'Arab',
  'chk' => 'Latn',
  'guj' => 'Gujr',
  'zul' => 'Latn',
  'bub' => 'Cyrl',
  'kmb' => 'Latn',
  'lam' => 'Latn',
  'swg' => 'Latn',
  'abq' => 'Cyrl',
  'hrv' => 'Latn',
  'sqi' => 'Latn',
  'see' => 'Latn',
  'bin' => 'Latn',
  'mls' => 'Latn',
  'cym' => 'Latn',
  'ben' => 'Beng',
  'mrj' => 'Cyrl',
  'pon' => 'Latn',
  'lmn' => 'Telu',
  'gbm' => 'Deva',
  'frr' => 'Latn',
  'dtp' => 'Latn',
  'crl' => 'Cans',
  'che' => 'Cyrl',
  'arn' => 'Latn',
  'tcy' => 'Knda',
  'sah' => 'Cyrl',
  'urd' => 'Arab',
  'car' => 'Latn',
  'rob' => 'Latn',
  'gay' => 'Latn',
  'ast' => 'Latn',
  'gos' => 'Latn',
  'zza' => 'Latn',
  'loz' => 'Latn',
  'xav' => 'Latn',
  'ude' => 'Cyrl',
  'gan' => 'Hans',
  'ada' => 'Latn',
  'tat' => 'Cyrl',
  'nsk' => 'Cans',
  'mah' => 'Latn',
  'lin' => 'Latn',
  'chm' => 'Cyrl',
  'eng' => 'Latn',
  'mdt' => 'Latn',
  'maz' => 'Latn',
  'cgg' => 'Latn',
  'cha' => 'Latn',
  'kau' => 'Latn',
  'doi' => 'Arab',
  'efi' => 'Latn',
  'aym' => 'Latn',
  'akz' => 'Latn',
  'mai' => 'Deva',
  'myv' => 'Cyrl',
  'rue' => 'Cyrl',
  'pdc' => 'Latn',
  'mus' => 'Latn',
  'arq' => 'Arab',
  'bfd' => 'Latn',
  'que' => 'Latn',
  'hye' => 'Armn',
  'ven' => 'Latn',
  'oss' => 'Cyrl',
  'osa' => 'Osge',
  'zha' => 'Latn',
  'rup' => 'Latn',
  'ctd' => 'Latn',
  'thr' => 'Deva',
  'gle' => 'Latn',
  'nxq' => 'Latn',
  'bgn' => 'Arab',
  'swe' => 'Latn',
  'alt' => 'Cyrl',
  'zdj' => 'Arab',
  'saq' => 'Latn',
  'hai' => 'Latn',
  'bfq' => 'Taml',
  'lbe' => 'Cyrl',
  'tli' => 'Latn',
  'amo' => 'Latn',
  'ary' => 'Arab',
  'moe' => 'Latn',
  'bod' => 'Tibt',
  'tvl' => 'Latn',
  'rtm' => 'Latn',
  'slk' => 'Latn',
  'naq' => 'Latn',
  'kac' => 'Latn',
  'eka' => 'Latn',
  'nym' => 'Latn',
  'fin' => 'Latn',
  'fan' => 'Latn',
  'tts' => 'Thai',
  'lmo' => 'Latn',
  'crs' => 'Latn',
  'ron' => 'Latn',
  'sck' => 'Deva',
  'por' => 'Latn',
  'hop' => 'Latn',
  'dav' => 'Latn',
  'dzo' => 'Tibt',
  'mya' => 'Mymr',
  'mua' => 'Latn',
  'ale' => 'Latn',
  'nob' => 'Latn',
  'mwk' => 'Latn',
  'zun' => 'Latn',
  'mag' => 'Deva',
  'esu' => 'Latn',
  'hsb' => 'Latn',
  'lah' => 'Arab',
  'grb' => 'Latn',
  'chv' => 'Cyrl',
  'suk' => 'Latn',
  'tiv' => 'Latn',
  'ara' => 'Arab',
  'kat' => 'Geor',
  'nqo' => 'Nkoo',
  'hil' => 'Latn',
  'kcg' => 'Latn',
  'hne' => 'Deva',
  'gsw' => 'Latn',
  'aln' => 'Latn',
  'abr' => 'Latn',
  'jmc' => 'Latn',
  'zmi' => 'Latn',
  'gur' => 'Latn',
  'frc' => 'Latn',
  'asm' => 'Beng',
  'xog' => 'Latn',
  'ter' => 'Latn',
  'mvy' => 'Arab',
  'deu' => 'Latn',
  'bas' => 'Latn',
  'sas' => 'Latn',
  'dty' => 'Deva',
  'kaj' => 'Latn',
  'gbz' => 'Arab',
  'bug' => 'Latn',
  'hno' => 'Arab',
  'rmu' => 'Latn',
  'mns' => 'Cyrl',
  'chy' => 'Latn',
  'den' => 'Latn',
  'ell' => 'Grek',
  'mkd' => 'Cyrl',
  'vro' => 'Latn',
  'pcm' => 'Latn',
  'udm' => 'Cyrl',
  'ffm' => 'Latn',
  'ttj' => 'Latn',
  'ebu' => 'Latn',
  'pap' => 'Latn',
  'sbp' => 'Latn',
  'syl' => 'Beng',
  'rof' => 'Latn',
  'nyn' => 'Latn',
  'cos' => 'Latn',
  'fao' => 'Latn',
  'kfr' => 'Deva',
  'lis' => 'Lisu',
  'kde' => 'Latn',
  'bpy' => 'Beng',
  'kik' => 'Latn',
  'nnh' => 'Latn',
  'puu' => 'Latn',
  'dyu' => 'Latn',
  'rjs' => 'Deva',
  'lij' => 'Latn',
  'nia' => 'Latn',
  'nij' => 'Latn',
  'bew' => 'Latn',
  'mdr' => 'Latn',
  'sgs' => 'Latn',
  'ipk' => 'Latn',
  'aeb' => 'Arab',
  'btv' => 'Deva',
  'tkt' => 'Deva',
  'crm' => 'Cans',
  'myx' => 'Latn',
  'smj' => 'Latn',
  'tbw' => 'Latn',
  'anp' => 'Deva',
  'isl' => 'Latn',
  'smn' => 'Latn',
  'orm' => 'Latn',
  'prd' => 'Arab',
  'amh' => 'Ethi',
  'gju' => 'Arab',
  'yid' => 'Hebr',
  'ria' => 'Latn',
  'ltz' => 'Latn',
  'sma' => 'Latn',
  'tah' => 'Latn',
  'gwi' => 'Latn',
  'sna' => 'Latn',
  'tsj' => 'Tibt',
  'kos' => 'Latn',
  'wls' => 'Latn',
  'bqi' => 'Arab',
  'khb' => 'Talu',
  'ces' => 'Latn',
  'laj' => 'Latn',
  'krl' => 'Latn',
  'taj' => 'Deva',
  'nhw' => 'Latn',
  'vmf' => 'Latn',
  'bci' => 'Latn',
  'pmn' => 'Latn',
  'bzx' => 'Latn',
  'gag' => 'Latn',
  'scn' => 'Latn',
  'xnr' => 'Deva',
  'gil' => 'Latn',
  'egl' => 'Latn',
  'rcf' => 'Latn',
  'sef' => 'Latn'
};
$DefaultTerritory = {
  'ast' => 'ES',
  'hif' => 'FJ',
  'zza' => 'TR',
  'gan' => 'CN',
  'kas_Arab' => 'IN',
  'tat' => 'RU',
  'arn' => 'CL',
  'che' => 'RU',
  'tcy' => 'IN',
  'shr' => 'MA',
  'sah' => 'RU',
  'tr' => 'TR',
  'uig' => 'CN',
  'mni_Beng' => 'IN',
  'om' => 'ET',
  'urd' => 'PK',
  'sw' => 'TZ',
  'cym' => 'GB',
  'ben' => 'BD',
  'bin' => 'NG',
  'lmn' => 'IN',
  'pon' => 'FM',
  'cu' => 'RU',
  'gbm' => 'IN',
  'ks_Arab' => 'IN',
  'cs' => 'CZ',
  'hrv' => 'HR',
  'sqi' => 'AL',
  'lkt' => 'US',
  'ckb' => 'IQ',
  'chk' => 'FM',
  'zul' => 'ZA',
  'guj' => 'IN',
  'kmb' => 'AO',
  'slv' => 'SI',
  'nn' => 'NO',
  'ibo' => 'NG',
  'ms' => 'MY',
  'knf' => 'SN',
  'it' => 'IT',
  'ku' => 'TR',
  'sr_Latn' => 'RS',
  'moh' => 'CA',
  'tha' => 'TH',
  'lb' => 'LU',
  'tso' => 'ZA',
  'en' => 'US',
  'sme' => 'NO',
  'th' => 'TH',
  'mey' => 'SN',
  'krc' => 'RU',
  'ttb' => 'GH',
  'sag' => 'CF',
  'ak' => 'GH',
  'aka' => 'GH',
  'kha' => 'IN',
  'sk' => 'SK',
  'kl' => 'GL',
  'gd' => 'GB',
  'ljp' => 'ID',
  'ha_Arab' => 'NG',
  'mad' => 'ID',
  'vls' => 'BE',
  'mon' => 'MN',
  'fry' => 'NL',
  'noe' => 'IN',
  'nya' => 'MW',
  'lo' => 'LA',
  'ngl' => 'MZ',
  'hin_Latn' => 'IN',
  'ko' => 'KR',
  'fuq' => 'NE',
  'sun' => 'ID',
  'kab' => 'DZ',
  'lub' => 'CD',
  'aze_Cyrl' => 'AZ',
  'sg' => 'CF',
  'srn' => 'SR',
  'spa' => 'ES',
  'mgh' => 'MZ',
  'tet' => 'TL',
  'pan_Arab' => 'PK',
  'rn' => 'BI',
  'mlg' => 'MG',
  'bbc' => 'ID',
  'niu' => 'NU',
  'or' => 'IN',
  'rej' => 'ID',
  'jgo' => 'CM',
  'hy' => 'AM',
  'snk' => 'ML',
  'kdh' => 'SL',
  'wbr' => 'IN',
  'wuu' => 'CN',
  'roh' => 'CH',
  'ee' => 'GH',
  'bjn' => 'ID',
  'fon' => 'BJ',
  'arg' => 'ES',
  'tel' => 'IN',
  'lua' => 'CD',
  'kum' => 'RU',
  'kk' => 'KZ',
  'haw' => 'US',
  'hoc' => 'IN',
  'tig' => 'ER',
  'nde' => 'ZW',
  'wbp' => 'AU',
  'yor' => 'NG',
  'mer' => 'KE',
  'inh' => 'RU',
  'et' => 'EE',
  'srp_Latn' => 'RS',
  'bez' => 'TZ',
  'gla' => 'GB',
  'so' => 'SO',
  'pan_Guru' => 'IN',
  'fra' => 'FR',
  'rwk' => 'TZ',
  'war' => 'PH',
  'si' => 'LK',
  've' => 'ZA',
  'shr_Latn' => 'MA',
  'hu' => 'HU',
  'nso' => 'ZA',
  'bam_Nkoo' => 'ML',
  'kln' => 'KE',
  'nbl' => 'ZA',
  'uzb_Latn' => 'UZ',
  'mwr' => 'IN',
  'lv' => 'LV',
  'nau' => 'NR',
  'luz' => 'IR',
  'ii' => 'CN',
  'zh_Hant' => 'TW',
  'kru' => 'IN',
  'az_Arab' => 'IR',
  'sav' => 'SN',
  'gil' => 'KI',
  'rcf' => 'RE',
  'scn' => 'IT',
  'xnr' => 'IN',
  'bo' => 'CN',
  'sef' => 'CI',
  'ur' => 'PK',
  'wls' => 'WF',
  'ces' => 'CZ',
  'bqi' => 'IR',
  'laj' => 'UG',
  'sna' => 'ZW',
  'vmf' => 'DE',
  'pmn' => 'PH',
  'hau' => 'NG',
  'bci' => 'CI',
  'tt' => 'RU',
  'orm' => 'ET',
  'msa_Arab' => 'MY',
  'amh' => 'ET',
  'lg' => 'UG',
  'tah' => 'PF',
  'sma' => 'SE',
  'ltz' => 'LU',
  'smj' => 'SE',
  'wa' => 'BE',
  'myx' => 'UG',
  'be' => 'BY',
  'isl' => 'IS',
  'smn' => 'FI',
  'ki' => 'KE',
  'lu' => 'CD',
  'gaa' => 'GH',
  'bm' => 'ML',
  'iku' => 'CA',
  'bsc' => 'SN',
  'ig' => 'NG',
  'snd_Arab' => 'PK',
  'aeb' => 'TN',
  'gez' => 'ET',
  'kik' => 'KE',
  'gon' => 'IN',
  'kde' => 'TZ',
  'nnh' => 'CM',
  'te' => 'IN',
  'dyu' => 'BF',
  'mn_Mong' => 'CN',
  'bew' => 'ID',
  'rof' => 'TZ',
  'syl' => 'BD',
  'sbp' => 'TZ',
  'ce' => 'RU',
  'fr' => 'FR',
  'nyn' => 'UG',
  'cos' => 'FR',
  'sl' => 'SI',
  'fao' => 'FO',
  'zu' => 'ZA',
  'hno' => 'PK',
  'bug' => 'ID',
  'ell' => 'GR',
  'mkd' => 'MK',
  'sat_Olck' => 'IN',
  'pcm' => 'NG',
  'ebu' => 'KE',
  'ffm' => 'ML',
  'udm' => 'RU',
  'qu' => 'PE',
  'os' => 'GE',
  'asm' => 'IN',
  'xog' => 'UG',
  'deu' => 'DE',
  'kaj' => 'NG',
  'vai_Vaii' => 'LR',
  'bas' => 'CM',
  'sas' => 'ID',
  'chv' => 'RU',
  'suk' => 'TZ',
  'nqo' => 'GN',
  'hil' => 'PH',
  'ne' => 'NP',
  'tiv' => 'NG',
  'kat' => 'GE',
  'aln' => 'XK',
  'gsw' => 'CH',
  'uz_Cyrl' => 'UZ',
  'kcg' => 'NG',
  'hne' => 'IN',
  'abr' => 'GH',
  'jmc' => 'TZ',
  'nob' => 'NO',
  'es' => 'ES',
  'ts' => 'ZA',
  'is' => 'IS',
  'ml' => 'IN',
  'csb' => 'PL',
  'mua' => 'CM',
  'mag' => 'IN',
  'lah' => 'PK',
  'hsb' => 'DE',
  'bs_Cyrl' => 'BA',
  'fin' => 'FI',
  'km' => 'KH',
  'tts' => 'TH',
  'crs' => 'SC',
  'fan' => 'GQ',
  'por' => 'BR',
  'kas' => 'IN',
  'snf' => 'SN',
  'sck' => 'IN',
  'ron' => 'RO',
  'dzo' => 'BT',
  'bn' => 'BD',
  'mya' => 'MM',
  'dav' => 'KE',
  'bod' => 'CN',
  'tvl' => 'TV',
  'ta' => 'IN',
  'ss' => 'ZA',
  'slk' => 'SK',
  'naq' => 'NA',
  'fa' => 'IR',
  'tuk' => 'TM',
  'pa_Arab' => 'PK',
  'nym' => 'TZ',
  'kaz' => 'KZ',
  'ka' => 'GE',
  'de' => 'DE',
  'st' => 'ZA',
  'bgn' => 'PK',
  'swe' => 'SE',
  'dz' => 'BT',
  'gle' => 'IE',
  'ccp' => 'BD',
  'saq' => 'KE',
  'zdj' => 'KM',
  'shi_Tfng' => 'MA',
  'ary' => 'MA',
  'ms_Arab' => 'MY',
  'ky' => 'KG',
  'bs_Latn' => 'BA',
  'ru' => 'RU',
  'lbe' => 'RU',
  'bam' => 'ML',
  'que' => 'PE',
  'tn' => 'ZA',
  'kw' => 'GB',
  'arq' => 'DZ',
  'mus' => 'US',
  'shi_Latn' => 'MA',
  'ven' => 'ZA',
  'hye' => 'AM',
  'gn' => 'PY',
  'ro' => 'RO',
  'zha' => 'CN',
  'osa' => 'US',
  'oss' => 'GE',
  'cgg' => 'UG',
  'cha' => 'GU',
  'bm_Nkoo' => 'ML',
  'mah' => 'MH',
  'lin' => 'CD',
  'eng' => 'US',
  'efi' => 'NG',
  'doi' => 'IN',
  'aym' => 'BO',
  'mai' => 'IN',
  'myv' => 'RU',
  'mfv' => 'SN',
  'kua' => 'NA',
  'yo' => 'NG',
  'mg' => 'MG',
  'uz_Latn' => 'UZ',
  'kxm' => 'TH',
  'rw' => 'RW',
  'ba' => 'RU',
  'ndc' => 'MZ',
  'ks_Deva' => 'IN',
  'khm' => 'KH',
  'mfa' => 'TH',
  'mzn' => 'IR',
  'bos_Latn' => 'BA',
  'sun_Latn' => 'ID',
  'bjt' => 'SN',
  'lug' => 'UG',
  'ibb' => 'NG',
  'wae' => 'CH',
  'nus' => 'SS',
  'ukr' => 'UA',
  'haz' => 'AF',
  'nd' => 'ZW',
  'tum' => 'MW',
  'mnu' => 'KE',
  'tgk' => 'TJ',
  'kea' => 'CV',
  'kkt' => 'RU',
  'chr' => 'US',
  'chu' => 'RU',
  'tg' => 'TJ',
  'el' => 'GR',
  'iu' => 'CA',
  'agq' => 'CM',
  'mlt' => 'MT',
  'co' => 'FR',
  'div' => 'MV',
  'id' => 'ID',
  'arz' => 'EG',
  'eng_Dsrt' => 'US',
  'mr' => 'IN',
  'brh' => 'PK',
  'uz_Arab' => 'AF',
  'oci' => 'FR',
  'shn' => 'MM',
  'kpe' => 'LR',
  'yav' => 'CM',
  'ndo' => 'NA',
  'kam' => 'KE',
  'mak' => 'ID',
  'msa' => 'MY',
  'bgc' => 'IN',
  'xh' => 'ZA',
  'sq' => 'AL',
  'tir' => 'ET',
  'uk' => 'UA',
  'bjj' => 'IN',
  'sn' => 'ZW',
  'glg' => 'ES',
  'iii' => 'CN',
  'bhk' => 'PH',
  'ken' => 'CM',
  'dua' => 'CM',
  'bul' => 'BG',
  'ind' => 'ID',
  'sid' => 'ET',
  'fur' => 'IT',
  'ful_Latn' => 'SN',
  'ff_Latn' => 'SN',
  'lit' => 'LT',
  'sot' => 'ZA',
  'am' => 'ET',
  'gv' => 'IM',
  'mri' => 'NZ',
  'grn' => 'PY',
  'tk' => 'TM',
  'bem' => 'ZM',
  'hun' => 'HU',
  'vi' => 'VN',
  'teo' => 'UG',
  'dv' => 'MV',
  'sqq' => 'TH',
  'lrc' => 'IR',
  'brx' => 'IN',
  'wtm' => 'IN',
  'sv' => 'SE',
  'nmg' => 'CM',
  'vmw' => 'MZ',
  'dyo' => 'SN',
  'swa' => 'TZ',
  'ti' => 'ET',
  'nl' => 'NL',
  'ca' => 'ES',
  'syr' => 'IQ',
  'khn' => 'IN',
  'swv' => 'IN',
  'run' => 'BI',
  'nb' => 'NO',
  'aar' => 'ET',
  'skr' => 'PK',
  'cy' => 'GB',
  'ilo' => 'PH',
  'twq' => 'NE',
  'bik' => 'PH',
  'fud' => 'WF',
  'heb' => 'IL',
  'ps' => 'AF',
  'tsg' => 'PH',
  'pau' => 'PW',
  'ssw' => 'ZA',
  'hin' => 'IN',
  'fy' => 'NL',
  'mal' => 'IN',
  'fuv' => 'NG',
  'fij' => 'FJ',
  'sus' => 'GN',
  'lag' => 'TZ',
  'kdx' => 'KE',
  'ful_Adlm' => 'GN',
  'hmo' => 'PG',
  'gom' => 'IN',
  'gu' => 'IN',
  'snd_Deva' => 'IN',
  'fo' => 'FO',
  'vie' => 'VN',
  'ug' => 'CN',
  'to' => 'TO',
  'mi' => 'NZ',
  'afr' => 'ZA',
  'dje' => 'NE',
  'zho_Hant' => 'TW',
  'zho_Hans' => 'CN',
  'nan' => 'CN',
  'pl' => 'PL',
  'dsb' => 'DE',
  'hsn' => 'CN',
  'dnj' => 'CI',
  'lat' => 'VA',
  'swb' => 'YT',
  'da' => 'DK',
  'rus' => 'RU',
  'jav' => 'ID',
  'sms' => 'FI',
  'kkj' => 'CM',
  'ewe' => 'GH',
  'srp_Cyrl' => 'RS',
  'kbd' => 'RU',
  'som' => 'SO',
  'ton' => 'TO',
  'kfy' => 'IN',
  'szl' => 'PL',
  'mar' => 'IN',
  'cic' => 'US',
  'san' => 'IN',
  'wln' => 'BE',
  'gcr' => 'GF',
  'wo' => 'SN',
  'bej' => 'SD',
  'bak' => 'RU',
  'asa' => 'TZ',
  'vun' => 'TZ',
  'luo' => 'KE',
  'tur' => 'TR',
  'hr' => 'HR',
  'jpn' => 'JP',
  'sat' => 'IN',
  'wal' => 'ET',
  'byn' => 'ER',
  'dcc' => 'IN',
  'quc' => 'GT',
  'glk' => 'IR',
  'iku_Latn' => 'CA',
  'kon' => 'CD',
  'ori' => 'IN',
  'fas' => 'IR',
  'my' => 'MM',
  'xho' => 'ZA',
  'kri' => 'SL',
  'mos' => 'BF',
  'tam' => 'IN',
  'zgh' => 'MA',
  'ny' => 'MW',
  'nod' => 'TH',
  'mgo' => 'CM',
  'wbq' => 'IN',
  'sat_Deva' => 'IN',
  'ksb' => 'TZ',
  'ksf' => 'CM',
  'kor' => 'KR',
  'as' => 'IN',
  'bis' => 'VU',
  'mfe' => 'MU',
  'ban' => 'ID',
  'mt' => 'MT',
  'se' => 'NO',
  'af' => 'ZA',
  'an' => 'ES',
  'eus' => 'ES',
  'sd_Arab' => 'PK',
  'fvr' => 'IT',
  'ksh' => 'DE',
  'rmt' => 'IR',
  'hau_Arab' => 'NG',
  'sin' => 'LK',
  'fil' => 'PH',
  'aze_Arab' => 'IR',
  'ewo' => 'CM',
  'jam' => 'JM',
  'mdh' => 'PH',
  'bss' => 'CM',
  'mon_Mong' => 'CN',
  'ln' => 'CD',
  'kom' => 'RU',
  'bos' => 'BA',
  'bhi' => 'IN',
  'en_Dsrt' => 'US',
  'mdf' => 'RU',
  'men' => 'SL',
  'ady' => 'RU',
  'tyv' => 'RU',
  'srr' => 'SN',
  'mk' => 'MK',
  'iu_Latn' => 'CA',
  'nds' => 'DE',
  'sco' => 'GB',
  'nep' => 'NP',
  'sr_Cyrl' => 'RS',
  'rm' => 'CH',
  'hak' => 'CN',
  'bhb' => 'IN',
  'rif' => 'MA',
  'tsn' => 'ZA',
  'kan' => 'IN',
  'umb' => 'AO',
  'oc' => 'FR',
  'cor' => 'GB',
  'br' => 'FR',
  'nr' => 'ZA',
  'gl' => 'ES',
  'lt' => 'LT',
  'ace' => 'ID',
  'ikt' => 'CA',
  'cch' => 'NG',
  'tzm' => 'MA',
  'ssy' => 'ER',
  'bel' => 'BY',
  'trv' => 'TW',
  'seh' => 'MZ',
  'srd' => 'IT',
  'tpi' => 'PG',
  'kok' => 'IN',
  'ita' => 'IT',
  'he' => 'IL',
  'kas_Deva' => 'IN',
  'eu' => 'ES',
  'hoj' => 'IN',
  'bre' => 'FR',
  'tmh' => 'NE',
  'ja' => 'JP',
  'tnr' => 'SN',
  'khq' => 'ML',
  'mni' => 'IN',
  'kin' => 'RW',
  'bg' => 'BG',
  'pol' => 'PL',
  'ff_Adlm' => 'GN',
  'luy' => 'KE',
  'cad' => 'US',
  'mas' => 'KE',
  'kn' => 'IN',
  'awa' => 'IN',
  'abk' => 'GE',
  'min' => 'ID',
  'yue_Hans' => 'CN',
  'yue_Hant' => 'HK',
  'ava' => 'RU',
  'buc' => 'YT',
  'sd_Deva' => 'IN',
  'pa_Guru' => 'IN',
  'ga' => 'IE',
  'shr_Tfng' => 'MA',
  'lav' => 'LV',
  'cv' => 'RU',
  'mni_Mtei' => 'IN',
  'lao' => 'LA',
  'fi' => 'FI',
  'bos_Cyrl' => 'BA',
  'mn' => 'MN',
  'kal' => 'GL',
  'jv' => 'ID',
  'hi' => 'IN',
  'gqr' => 'ID',
  'dan' => 'DK',
  'ife' => 'TG',
  'blt' => 'VN',
  'raj' => 'IN',
  'wni' => 'KM',
  'pt' => 'BR',
  'ses' => 'ML',
  'su_Latn' => 'ID',
  'az_Cyrl' => 'AZ',
  'lez' => 'RU',
  'uzb_Arab' => 'AF',
  'ach' => 'UG',
  'sdh' => 'IR',
  'mtr' => 'IN',
  'vai_Latn' => 'LR',
  'az_Latn' => 'AZ',
  'guz' => 'KE',
  'uzb_Cyrl' => 'UZ',
  'cat' => 'ES',
  'hat' => 'HT',
  'est' => 'EE',
  'unr' => 'IN',
  'aze_Latn' => 'AZ',
  'ha' => 'NG',
  'ceb' => 'PH',
  'glv' => 'IM',
  'nno' => 'NO',
  'pag' => 'PH',
  'sa' => 'IN',
  'zh_Hans' => 'CN',
  'nld' => 'NL',
  'tkl' => 'TK',
  'aa' => 'ET',
  'pus' => 'AF',
  'kur' => 'TR',
  'sc' => 'IT',
  'bmv' => 'CM',
  'hi_Latn' => 'IN',
  'wol' => 'SN',
  'kir' => 'KG'
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


