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
  'Ital' => 'Old_Italic',
  'Batk' => 'Batak',
  'Buhd' => 'Buhid',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Plrd' => 'Miao',
  'Mult' => 'Multani',
  'Phag' => 'Phags_Pa',
  'Guru' => 'Gurmukhi',
  'Toto' => '',
  'Hanb' => '',
  'Avst' => 'Avestan',
  'Sgnw' => 'SignWriting',
  'Khoj' => 'Khojki',
  'Wara' => 'Warang_Citi',
  'Mong' => 'Mongolian',
  'Dupl' => 'Duployan',
  'Newa' => 'Newa',
  'Yezi' => 'Yezidi',
  'Cans' => 'Canadian_Aboriginal',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Kitl' => '',
  'Gong' => 'Gunjala_Gondi',
  'Cari' => 'Carian',
  'Lisu' => 'Lisu',
  'Osma' => 'Osmanya',
  'Nkgb' => '',
  'Phnx' => 'Phoenician',
  'Knda' => 'Kannada',
  'Tale' => 'Tai_Le',
  'Sogd' => 'Sogdian',
  'Ethi' => 'Ethiopic',
  'Blis' => '',
  'Cpmn' => '',
  'Gujr' => 'Gujarati',
  'Roro' => '',
  'Takr' => 'Takri',
  'Qabx' => '',
  'Cyrs' => '',
  'Deva' => 'Devanagari',
  'Cakm' => 'Chakma',
  'Sora' => 'Sora_Sompeng',
  'Syrn' => '',
  'Tavt' => 'Tai_Viet',
  'Grek' => 'Greek',
  'Hira' => 'Hiragana',
  'Cher' => 'Cherokee',
  'Tang' => 'Tangut',
  'Prti' => 'Inscriptional_Parthian',
  'Brai' => 'Braille',
  'Hans' => '',
  'Chrs' => 'Chorasmian',
  'Khar' => 'Kharoshthi',
  'Palm' => 'Palmyrene',
  'Thai' => 'Thai',
  'Qaaa' => '',
  'Mlym' => 'Malayalam',
  'Gran' => 'Grantha',
  'Afak' => '',
  'Latg' => '',
  'Lana' => 'Tai_Tham',
  'Goth' => 'Gothic',
  'Zzzz' => 'Unknown',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Beng' => 'Bengali',
  'Geok' => 'Georgian',
  'Adlm' => 'Adlam',
  'Kali' => 'Kayah_Li',
  'Mahj' => 'Mahajani',
  'Brah' => 'Brahmi',
  'Armi' => 'Imperial_Aramaic',
  'Laoo' => 'Lao',
  'Nkdb' => '',
  'Hmng' => 'Pahawh_Hmong',
  'Jamo' => '',
  'Nkoo' => 'Nko',
  'Lydi' => 'Lydian',
  'Hang' => 'Hangul',
  'Maka' => 'Makasar',
  'Aran' => '',
  'Rohg' => 'Hanifi_Rohingya',
  'Taml' => 'Tamil',
  'Moon' => '',
  'Hani' => 'Han',
  'Orya' => 'Oriya',
  'Zyyy' => 'Common',
  'Tagb' => 'Tagbanwa',
  'Elba' => 'Elbasan',
  'Wcho' => 'Wancho',
  'Thaa' => 'Thaana',
  'Bass' => 'Bassa_Vah',
  'Ogam' => 'Ogham',
  'Teng' => '',
  'Shui' => '',
  'Tirh' => 'Tirhuta',
  'Loma' => '',
  'Osge' => 'Osage',
  'Leke' => '',
  'Lina' => 'Linear_A',
  'Sund' => 'Sundanese',
  'Tglg' => 'Tagalog',
  'Syre' => '',
  'Runr' => 'Runic',
  'Linb' => 'Linear_B',
  'Medf' => 'Medefaidrin',
  'Modi' => 'Modi',
  'Sogo' => 'Old_Sogdian',
  'Egyh' => '',
  'Nshu' => 'Nushu',
  'Armn' => 'Armenian',
  'Soyo' => 'Soyombo',
  'Samr' => 'Samaritan',
  'Zinh' => 'Inherited',
  'Kits' => 'Khitan_Small_Script',
  'Lepc' => 'Lepcha',
  'Diak' => 'Dives_Akuru',
  'Zsym' => '',
  'Sylo' => 'Syloti_Nagri',
  'Zmth' => '',
  'Ugar' => 'Ugaritic',
  'Zsye' => '',
  'Orkh' => 'Old_Turkic',
  'Mtei' => 'Meetei_Mayek',
  'Gonm' => 'Masaram_Gondi',
  'Mroo' => 'Mro',
  'Jurc' => '',
  'Rjng' => 'Rejang',
  'Hebr' => 'Hebrew',
  'Piqd' => '',
  'Nand' => 'Nandinagari',
  'Aghb' => 'Caucasian_Albanian',
  'Kana' => 'Katakana',
  'Sind' => 'Khudawadi',
  'Hant' => '',
  'Bamu' => 'Bamum',
  'Bali' => 'Balinese',
  'Narb' => 'Old_North_Arabian',
  'Talu' => 'New_Tai_Lue',
  'Phlp' => 'Psalter_Pahlavi',
  'Cirt' => '',
  'Latf' => '',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Xsux' => 'Cuneiform',
  'Tfng' => 'Tifinagh',
  'Yiii' => 'Yi',
  'Maya' => '',
  'Cyrl' => 'Cyrillic',
  'Marc' => 'Marchen',
  'Perm' => 'Old_Permic',
  'Mend' => 'Mende_Kikakui',
  'Olck' => 'Ol_Chiki',
  'Bugi' => 'Buginese',
  'Sidd' => 'Siddham',
  'Syrj' => '',
  'Geor' => 'Georgian',
  'Arab' => 'Arabic',
  'Egyd' => '',
  'Bopo' => 'Bopomofo',
  'Phlv' => '',
  'Hatr' => 'Hatran',
  'Wole' => '',
  'Shrd' => 'Sharada',
  'Hung' => 'Old_Hungarian',
  'Glag' => 'Glagolitic',
  'Kore' => '',
  'Lyci' => 'Lycian',
  'Java' => 'Javanese',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Tibt' => 'Tibetan',
  'Mymr' => 'Myanmar',
  'Elym' => 'Elymaic',
  'Dsrt' => 'Deseret',
  'Mani' => 'Manichaean',
  'Kthi' => 'Kaithi',
  'Kpel' => '',
  'Vaii' => 'Vai',
  'Sarb' => 'Old_South_Arabian',
  'Sinh' => 'Sinhala',
  'Mand' => 'Mandaic',
  'Nbat' => 'Nabataean',
  'Jpan' => '',
  'Merc' => 'Meroitic_Cursive',
  'Bhks' => 'Bhaiksuki',
  'Cprt' => 'Cypriot',
  'Syrc' => 'Syriac',
  'Khmr' => 'Khmer',
  'Zanb' => 'Zanabazar_Square',
  'Limb' => 'Limbu',
  'Visp' => '',
  'Sara' => '',
  'Saur' => 'Saurashtra',
  'Pauc' => 'Pau_Cin_Hau',
  'Copt' => 'Coptic',
  'Ahom' => 'Ahom',
  'Shaw' => 'Shavian',
  'Zxxx' => '',
  'Telu' => 'Telugu',
  'Hano' => 'Hanunoo',
  'Latn' => 'Latin',
  'Inds' => '',
  'Dogr' => 'Dogra',
  'Cham' => 'Cham',
  'Phli' => 'Inscriptional_Pahlavi',
  'Xpeo' => 'Old_Persian'
};
$ScriptName2ScriptCode = {
  'Braille' => 'Brai',
  'Hanunoo' => 'Hano',
  'Lydian' => 'Lydi',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Nandinagari' => 'Nand',
  'Hanifi_Rohingya' => 'Rohg',
  'Warang_Citi' => 'Wara',
  'Tai_Viet' => 'Tavt',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Meroitic_Cursive' => 'Merc',
  'Devanagari' => 'Deva',
  'Mahajani' => 'Mahj',
  'Tagalog' => 'Tglg',
  'Limbu' => 'Limb',
  'Nushu' => 'Nshu',
  'Old_South_Arabian' => 'Sarb',
  'Hiragana' => 'Hira',
  'Bopomofo' => 'Bopo',
  'Pahawh_Hmong' => 'Hmng',
  '' => 'Zxxx',
  'Sharada' => 'Shrd',
  'Mandaic' => 'Mand',
  'Mongolian' => 'Mong',
  'Tagbanwa' => 'Tagb',
  'Buhid' => 'Buhd',
  'Pau_Cin_Hau' => 'Pauc',
  'Psalter_Pahlavi' => 'Phlp',
  'Armenian' => 'Armn',
  'Runic' => 'Runr',
  'Multani' => 'Mult',
  'Javanese' => 'Java',
  'Hatran' => 'Hatr',
  'Caucasian_Albanian' => 'Aghb',
  'Takri' => 'Takr',
  'Shavian' => 'Shaw',
  'Tibetan' => 'Tibt',
  'Adlam' => 'Adlm',
  'Coptic' => 'Copt',
  'Cuneiform' => 'Xsux',
  'Linear_A' => 'Lina',
  'Lycian' => 'Lyci',
  'Hebrew' => 'Hebr',
  'Old_North_Arabian' => 'Narb',
  'Gunjala_Gondi' => 'Gong',
  'Linear_B' => 'Linb',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Kannada' => 'Knda',
  'Telugu' => 'Telu',
  'Kayah_Li' => 'Kali',
  'Manichaean' => 'Mani',
  'Kaithi' => 'Kthi',
  'Phoenician' => 'Phnx',
  'Old_Italic' => 'Ital',
  'Arabic' => 'Arab',
  'Samaritan' => 'Samr',
  'Bamum' => 'Bamu',
  'Soyombo' => 'Soyo',
  'Tamil' => 'Taml',
  'Miao' => 'Plrd',
  'Batak' => 'Batk',
  'Tai_Le' => 'Tale',
  'Oriya' => 'Orya',
  'Malayalam' => 'Mlym',
  'Canadian_Aboriginal' => 'Cans',
  'Modi' => 'Modi',
  'Grantha' => 'Gran',
  'Syriac' => 'Syrc',
  'Kharoshthi' => 'Khar',
  'Elymaic' => 'Elym',
  'Cham' => 'Cham',
  'Old_Permic' => 'Perm',
  'Mro' => 'Mroo',
  'Ahom' => 'Ahom',
  'Masaram_Gondi' => 'Gonm',
  'Yezidi' => 'Yezi',
  'Khojki' => 'Khoj',
  'Inscriptional_Pahlavi' => 'Phli',
  'New_Tai_Lue' => 'Talu',
  'Sora_Sompeng' => 'Sora',
  'Georgian' => 'Geor',
  'Katakana' => 'Kana',
  'Marchen' => 'Marc',
  'Old_Turkic' => 'Orkh',
  'Old_Persian' => 'Xpeo',
  'Brahmi' => 'Brah',
  'Tai_Tham' => 'Lana',
  'Gujarati' => 'Gujr',
  'Osage' => 'Osge',
  'Bassa_Vah' => 'Bass',
  'Latin' => 'Latn',
  'Medefaidrin' => 'Medf',
  'Cyrillic' => 'Cyrl',
  'Cherokee' => 'Cher',
  'Tifinagh' => 'Tfng',
  'Osmanya' => 'Osma',
  'Yi' => 'Yiii',
  'Carian' => 'Cari',
  'Rejang' => 'Rjng',
  'Khudawadi' => 'Sind',
  'Siddham' => 'Sidd',
  'Ogham' => 'Ogam',
  'Old_Sogdian' => 'Sogo',
  'Nabataean' => 'Nbat',
  'Ugaritic' => 'Ugar',
  'Sinhala' => 'Sinh',
  'Tirhuta' => 'Tirh',
  'Meetei_Mayek' => 'Mtei',
  'SignWriting' => 'Sgnw',
  'Saurashtra' => 'Saur',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Mende_Kikakui' => 'Mend',
  'Greek' => 'Grek',
  'Inherited' => 'Zinh',
  'Thaana' => 'Thaa',
  'Cypriot' => 'Cprt',
  'Khitan_Small_Script' => 'Kits',
  'Khmer' => 'Khmr',
  'Gothic' => 'Goth',
  'Bengali' => 'Beng',
  'Sundanese' => 'Sund',
  'Lisu' => 'Lisu',
  'Ethiopic' => 'Ethi',
  'Makasar' => 'Maka',
  'Myanmar' => 'Mymr',
  'Han' => 'Hani',
  'Syloti_Nagri' => 'Sylo',
  'Newa' => 'Newa',
  'Lao' => 'Laoo',
  'Unknown' => 'Zzzz',
  'Tangut' => 'Tang',
  'Sogdian' => 'Sogd',
  'Dives_Akuru' => 'Diak',
  'Gurmukhi' => 'Guru',
  'Bhaiksuki' => 'Bhks',
  'Deseret' => 'Dsrt',
  'Chorasmian' => 'Chrs',
  'Vai' => 'Vaii',
  'Hangul' => 'Hang',
  'Palmyrene' => 'Palm',
  'Duployan' => 'Dupl',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Imperial_Aramaic' => 'Armi',
  'Balinese' => 'Bali',
  'Lepcha' => 'Lepc',
  'Common' => 'Zyyy',
  'Old_Hungarian' => 'Hung',
  'Ol_Chiki' => 'Olck',
  'Chakma' => 'Cakm',
  'Buginese' => 'Bugi',
  'Avestan' => 'Avst',
  'Inscriptional_Parthian' => 'Prti',
  'Wancho' => 'Wcho',
  'Dogra' => 'Dogr',
  'Elbasan' => 'Elba',
  'Thai' => 'Thai',
  'Phags_Pa' => 'Phag',
  'Glagolitic' => 'Glag',
  'Zanabazar_Square' => 'Zanb',
  'Nko' => 'Nkoo'
};
$ScriptId2ScriptCode = {
  '165' => 'Nkoo',
  '500' => 'Hani',
  '530' => 'Shui',
  '305' => 'Khar',
  '999' => 'Zzzz',
  '335' => 'Lepc',
  '263' => 'Pauc',
  '334' => 'Bhks',
  '226' => 'Elba',
  '260' => 'Osma',
  '503' => 'Hanb',
  '080' => 'Hluw',
  '127' => 'Hatr',
  '291' => 'Cirt',
  '225' => 'Glag',
  '347' => 'Mlym',
  '402' => 'Cpmn',
  '343' => 'Gran',
  '359' => 'Tavt',
  '319' => 'Shrd',
  '123' => 'Samr',
  '340' => 'Telu',
  '166' => 'Adlm',
  '351' => 'Lana',
  '311' => 'Nand',
  '120' => 'Tfng',
  '040' => 'Ugar',
  '336' => 'Limb',
  '323' => 'Mult',
  '292' => 'Sara',
  '900' => 'Qaaa',
  '159' => 'Nbat',
  '401' => 'Linb',
  '327' => 'Orya',
  '439' => 'Afak',
  '136' => 'Syrn',
  '020' => 'Xsux',
  '352' => 'Thai',
  '312' => 'Gong',
  '106' => 'Narb',
  '320' => 'Gujr',
  '286' => 'Hang',
  '140' => 'Mand',
  '366' => 'Maka',
  '135' => 'Syrc',
  '105' => 'Sarb',
  '285' => 'Bopo',
  '365' => 'Batk',
  '470' => 'Vaii',
  '218' => 'Moon',
  '364' => 'Leke',
  '200' => 'Grek',
  '230' => 'Armn',
  '284' => 'Jamo',
  '398' => 'Sora',
  '134' => 'Avst',
  '755' => 'Dupl',
  '161' => 'Aran',
  '132' => 'Phlp',
  '316' => 'Sylo',
  '356' => 'Laoo',
  '994' => 'Zinh',
  '282' => 'Plrd',
  '331' => 'Phag',
  '362' => 'Sund',
  '348' => 'Sinh',
  '339' => 'Zanb',
  '995' => 'Zmth',
  '412' => 'Hrkt',
  '128' => 'Elym',
  '420' => 'Nkgb',
  '610' => 'Inds',
  '070' => 'Egyd',
  '221' => 'Cyrs',
  '996' => 'Zsym',
  '314' => 'Mahj',
  '354' => 'Talu',
  '370' => 'Tglg',
  '315' => 'Deva',
  '355' => 'Khmr',
  '373' => 'Tagb',
  '294' => 'Toto',
  '550' => 'Blis',
  '510' => 'Jurc',
  '170' => 'Thaa',
  '241' => 'Geok',
  '210' => 'Ital',
  '250' => 'Dsrt',
  '435' => 'Bamu',
  '480' => 'Wole',
  '090' => 'Maya',
  '115' => 'Phnx',
  '217' => 'Latf',
  '131' => 'Phli',
  '949' => 'Qabx',
  '101' => 'Merc',
  '281' => 'Shaw',
  '116' => 'Lydi',
  '302' => 'Sidd',
  '361' => 'Java',
  '332' => 'Marc',
  '440' => 'Cans',
  '451' => 'Hmnp',
  '411' => 'Kana',
  '328' => 'Dogr',
  '109' => 'Chrs',
  '436' => 'Kpel',
  '139' => 'Mani',
  '215' => 'Latn',
  '430' => 'Ethi',
  '400' => 'Lina',
  '288' => 'Kits',
  '329' => 'Soyo',
  '175' => 'Orkh',
  '138' => 'Syre',
  '141' => 'Sogd',
  '321' => 'Takr',
  '437' => 'Loma',
  '095' => 'Sgnw',
  '403' => 'Cprt',
  '342' => 'Diak',
  '239' => 'Aghb',
  '502' => 'Hant',
  '216' => 'Latg',
  '262' => 'Wara',
  '201' => 'Cari',
  '176' => 'Hung',
  '445' => 'Cher',
  '993' => 'Zsye',
  '499' => 'Nshu',
  '501' => 'Hans',
  '997' => 'Zxxx',
  '261' => 'Olck',
  '202' => 'Lyci',
  '349' => 'Cakm',
  '353' => 'Tale',
  '460' => 'Yiii',
  '313' => 'Gonm',
  '338' => 'Ahom',
  '570' => 'Brai',
  '290' => 'Teng',
  '317' => 'Kthi',
  '357' => 'Kali',
  '142' => 'Sogo',
  '050' => 'Egyp',
  '293' => 'Piqd',
  '322' => 'Khoj',
  '310' => 'Guru',
  '350' => 'Mymr',
  '211' => 'Runr',
  '372' => 'Buhd',
  '240' => 'Geor',
  '324' => 'Modi',
  '399' => 'Lisu',
  '206' => 'Goth',
  '145' => 'Mong',
  '325' => 'Beng',
  '192' => 'Yezi',
  '520' => 'Tang',
  '259' => 'Bass',
  '219' => 'Osge',
  '438' => 'Mend',
  '204' => 'Copt',
  '360' => 'Bali',
  '413' => 'Jpan',
  '280' => 'Visp',
  '326' => 'Tirh',
  '100' => 'Mero',
  '130' => 'Prti',
  '060' => 'Egyh',
  '287' => 'Kore',
  '367' => 'Bugi',
  '133' => 'Phlv',
  '137' => 'Syrj',
  '450' => 'Hmng',
  '363' => 'Rjng',
  '410' => 'Hira',
  '620' => 'Roro',
  '283' => 'Wcho',
  '330' => 'Tibt',
  '300' => 'Brah',
  '264' => 'Mroo',
  '126' => 'Palm',
  '030' => 'Xpeo',
  '160' => 'Arab',
  '505' => 'Kitl',
  '346' => 'Taml',
  '085' => 'Nkdb',
  '337' => 'Mtei',
  '265' => 'Medf',
  '167' => 'Rohg',
  '318' => 'Sind',
  '358' => 'Cham',
  '333' => 'Newa',
  '344' => 'Saur',
  '371' => 'Hano',
  '212' => 'Ogam',
  '124' => 'Armi',
  '220' => 'Cyrl',
  '227' => 'Perm',
  '125' => 'Hebr',
  '998' => 'Zyyy',
  '345' => 'Knda'
};
$ScriptCode2EnglishName = {
  'Maya' => 'Mayan hieroglyphs',
  'Yiii' => 'Yi',
  'Tfng' => 'Tifinagh (Berber)',
  'Bugi' => 'Buginese',
  'Marc' => 'Marchen',
  'Perm' => 'Old Permic',
  'Mend' => 'Mende Kikakui',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Cyrl' => 'Cyrillic',
  'Bali' => 'Balinese',
  'Bamu' => 'Bamum',
  'Hant' => 'Han (Traditional variant)',
  'Sind' => 'Khudawadi, Sindhi',
  'Kana' => 'Katakana',
  'Nand' => 'Nandinagari',
  'Aghb' => 'Caucasian Albanian',
  'Egyp' => 'Egyptian hieroglyphs',
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Latf' => 'Latin (Fraktur variant)',
  'Talu' => 'New Tai Lue',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Phlp' => 'Psalter Pahlavi',
  'Cirt' => 'Cirth',
  'Zsye' => 'Symbols (Emoji variant)',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Ugar' => 'Ugaritic',
  'Sylo' => 'Syloti Nagri',
  'Zmth' => 'Mathematical notation',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Hebr' => 'Hebrew',
  'Mroo' => 'Mro, Mru',
  'Jurc' => 'Jurchen',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Gonm' => 'Masaram Gondi',
  'Samr' => 'Samaritan',
  'Sogo' => 'Old Sogdian',
  'Nshu' => "N\x{fc}shu",
  'Egyh' => 'Egyptian hieratic',
  'Armn' => 'Armenian',
  'Soyo' => 'Soyombo',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Diak' => 'Dives Akuru',
  'Zsym' => 'Symbols',
  'Zinh' => 'Code for inherited script',
  'Kits' => 'Khitan small script',
  'Telu' => 'Telugu',
  'Shaw' => 'Shavian (Shaw)',
  'Zxxx' => 'Code for unwritten documents',
  'Ahom' => 'Ahom, Tai Ahom',
  'Copt' => 'Coptic',
  'Pauc' => 'Pau Cin Hau',
  'Cham' => 'Cham',
  'Xpeo' => 'Old Persian',
  'Phli' => 'Inscriptional Pahlavi',
  'Latn' => 'Latin',
  'Inds' => 'Indus (Harappan)',
  'Dogr' => 'Dogra',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Syrc' => 'Syriac',
  'Cprt' => 'Cypriot syllabary',
  'Bhks' => 'Bhaiksuki',
  'Mand' => 'Mandaic, Mandaean',
  'Merc' => 'Meroitic Cursive',
  'Nbat' => 'Nabataean',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Sarb' => 'Old South Arabian',
  'Vaii' => 'Vai',
  'Sinh' => 'Sinhala',
  'Visp' => 'Visible Speech',
  'Saur' => 'Saurashtra',
  'Sara' => 'Sarati',
  'Limb' => 'Limbu',
  'Khmr' => 'Khmer',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Tibt' => 'Tibetan',
  'Java' => 'Javanese',
  'Kpel' => 'Kpelle',
  'Mani' => 'Manichaean',
  'Kthi' => 'Kaithi',
  'Mymr' => 'Myanmar (Burmese)',
  'Dsrt' => 'Deseret (Mormon)',
  'Elym' => 'Elymaic',
  'Phlv' => 'Book Pahlavi',
  'Bopo' => 'Bopomofo',
  'Egyd' => 'Egyptian demotic',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Syrj' => 'Syriac (Western variant)',
  'Arab' => 'Arabic',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Lyci' => 'Lycian',
  'Glag' => 'Glagolitic',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Wole' => 'Woleai',
  'Hatr' => 'Hatran',
  'Palm' => 'Palmyrene',
  'Thai' => 'Thai',
  'Hans' => 'Han (Simplified variant)',
  'Chrs' => 'Chorasmian',
  'Khar' => 'Kharoshthi',
  'Tang' => 'Tangut',
  'Prti' => 'Inscriptional Parthian',
  'Brai' => 'Braille',
  'Goth' => 'Gothic',
  'Zzzz' => 'Code for uncoded script',
  'Afak' => 'Afaka',
  'Latg' => 'Latin (Gaelic variant)',
  'Lana' => 'Tai Tham (Lanna)',
  'Qaaa' => 'Reserved for private use (start)',
  'Mlym' => 'Malayalam',
  'Gran' => 'Grantha',
  'Deva' => 'Devanagari (Nagari)',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Qabx' => 'Reserved for private use (end)',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Blis' => 'Blissymbols',
  'Cpmn' => 'Cypro-Minoan',
  'Gujr' => 'Gujarati',
  'Roro' => 'Rongorongo',
  'Cher' => 'Cherokee',
  'Hira' => 'Hiragana',
  'Grek' => 'Greek',
  'Cakm' => 'Chakma',
  'Sora' => 'Sora Sompeng',
  'Syrn' => 'Syriac (Eastern variant)',
  'Tavt' => 'Tai Viet',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Kitl' => 'Khitan large script',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Yezi' => 'Yezidi',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Khoj' => 'Khojki',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Mong' => 'Mongolian',
  'Knda' => 'Kannada',
  'Sogd' => 'Sogdian',
  'Tale' => 'Tai Le',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Osma' => 'Osmanya',
  'Phnx' => 'Phoenician',
  'Gong' => 'Gunjala Gondi',
  'Cari' => 'Carian',
  'Lisu' => 'Lisu (Fraser)',
  'Buhd' => 'Buhid',
  'Batk' => 'Batak',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Avst' => 'Avestan',
  'Sgnw' => 'SignWriting',
  'Guru' => 'Gurmukhi',
  'Toto' => 'Toto',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Phag' => 'Phags-pa',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Plrd' => 'Miao (Pollard)',
  'Mult' => 'Multani',
  'Lina' => 'Linear A',
  'Sund' => 'Sundanese',
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Syre' => 'Syriac (Estrangelo variant)',
  'Leke' => 'Leke',
  'Osge' => 'Osage',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Runr' => 'Runic',
  'Linb' => 'Linear B',
  'Elba' => 'Elbasan',
  'Ogam' => 'Ogham',
  'Teng' => 'Tengwar',
  'Tirh' => 'Tirhuta',
  'Loma' => 'Loma',
  'Shui' => 'Shuishu',
  'Bass' => 'Bassa Vah',
  'Thaa' => 'Thaana',
  'Wcho' => 'Wancho',
  'Lydi' => 'Lydian',
  'Nkoo' => "N\x{2019}Ko",
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Hmng' => 'Pahawh Hmong',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Orya' => 'Oriya (Odia)',
  'Tagb' => 'Tagbanwa',
  'Zyyy' => 'Code for undetermined script',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Rohg' => 'Hanifi Rohingya',
  'Taml' => 'Tamil',
  'Maka' => 'Makasar',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Adlm' => 'Adlam',
  'Beng' => 'Bengali (Bangla)',
  'Mero' => 'Meroitic Hieroglyphs',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Laoo' => 'Lao',
  'Brah' => 'Brahmi',
  'Armi' => 'Imperial Aramaic',
  'Kali' => 'Kayah Li',
  'Mahj' => 'Mahajani'
};
$ScriptCode2FrenchName = {
  'Afak' => 'afaka',
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Lana' => "ta\x{ef} tham (lanna)",
  'Goth' => 'gotique',
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Mlym' => "malay\x{e2}lam",
  'Gran' => 'grantha',
  'Palm' => "palmyr\x{e9}nien",
  'Thai' => "tha\x{ef}",
  'Tang' => 'tangoute',
  'Brai' => 'braille',
  'Prti' => 'parthe des inscriptions',
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Chrs' => 'chorasmien',
  'Khar' => "kharochth\x{ee}",
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Cakm' => 'chakma',
  'Sora' => 'sora sompeng',
  'Syrn' => 'syriaque (variante orientale)',
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Grek' => 'grec',
  'Hira' => 'hiragana',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Blis' => 'symboles Bliss',
  'Cpmn' => 'syllabaire chypro-minoen',
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Roro' => 'rongorongo',
  'Nkgb' => 'naxi geba, nakhi geba',
  'Osma' => 'osmanais',
  'Phnx' => "ph\x{e9}nicien",
  'Knda' => 'kannara (canara)',
  'Sogd' => 'sogdien',
  'Tale' => "ta\x{ef}-le",
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Gong' => "gunjala gond\x{ee}",
  'Cari' => 'carien',
  'Lisu' => 'lisu (Fraser)',
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Yezi' => "y\x{e9}zidi",
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Kitl' => "grande \x{e9}criture khitan",
  'Khoj' => "khojk\x{ee}",
  'Wara' => 'warang citi',
  'Mong' => 'mongol',
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Guru' => "gourmoukh\x{ee}",
  'Toto' => 'toto',
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Avst' => 'avestique',
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Hmnp' => 'nyiakeng puachue hmong',
  'Plrd' => 'miao (Pollard)',
  'Mult' => "multan\x{ee}",
  'Phag' => "\x{2019}phags pa",
  'Buhd' => 'bouhide',
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Batk' => 'batik',
  'Modi' => "mod\x{ee}",
  'Linb' => "lin\x{e9}aire B",
  'Runr' => 'runique',
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Leke' => "l\x{e9}k\x{e9}",
  'Lina' => "lin\x{e9}aire A",
  'Sund' => 'sundanais',
  'Tglg' => 'tagal (baybayin, alibata)',
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Osge' => 'osage',
  'Bass' => 'bassa',
  'Ogam' => 'ogam',
  'Teng' => 'tengwar',
  'Tirh' => 'tirhouta',
  'Loma' => 'loma',
  'Shui' => 'shuishu',
  'Wcho' => 'wantcho',
  'Thaa' => "th\x{e2}na",
  'Elba' => 'elbasan',
  'Moon' => "\x{e9}criture Moon",
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Orya' => "oriy\x{e2} (odia)",
  'Tagb' => 'tagbanoua',
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Maka' => 'makassar',
  'Aran' => 'arabe (variante nastalique)',
  'Rohg' => 'hanifi rohingya',
  'Taml' => 'tamoul',
  'Hmng' => 'pahawh hmong',
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Nkoo' => "n\x{2019}ko",
  'Lydi' => 'lydien',
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Laoo' => 'laotien',
  'Nkdb' => 'naxi dongba',
  'Kali' => 'kayah li',
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Brah' => 'brahma',
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Adlm' => 'adlam',
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Beng' => "bengal\x{ee} (bangla)",
  'Perm' => 'ancien permien',
  'Marc' => 'marchen',
  'Mend' => "mend\x{e9} kikakui",
  'Olck' => 'ol tchiki',
  'Bugi' => 'bouguis',
  'Cyrl' => 'cyrillique',
  'Yiii' => 'yi',
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Latf' => "latin (variante bris\x{e9}e)",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Talu' => "nouveau ta\x{ef}-lue",
  'Narb' => 'nord-arabique',
  'Cirt' => 'cirth',
  'Phlp' => 'pehlevi des psautiers',
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Bali' => 'balinais',
  'Bamu' => 'bamoum',
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Aghb' => 'aghbanien',
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Kana' => 'katakana',
  'Rjng' => 'redjang (kaganga)',
  'Hebr' => "h\x{e9}breu",
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Mtei' => 'meitei mayek',
  'Gonm' => "masaram gond\x{ee}",
  'Mroo' => 'mro',
  'Jurc' => 'jurchen',
  'Ugar' => 'ougaritique',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Orkh' => 'orkhon',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Zmth' => "notation math\x{e9}matique",
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Diak' => 'dives akuru',
  'Zsym' => 'symboles',
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Kits' => "petite \x{e9}criture khitan",
  'Sogo' => 'ancien sogdien',
  'Nshu' => "n\x{fc}shu",
  'Armn' => "arm\x{e9}nien",
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Soyo' => 'soyombo',
  'Samr' => 'samaritain',
  'Cham' => "cham (\x{10d}am, tcham)",
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Phli' => 'pehlevi des inscriptions',
  'Hano' => "hanoun\x{f3}o",
  'Latn' => 'latin',
  'Dogr' => 'dogra',
  'Inds' => 'indus',
  'Shaw' => 'shavien (Shaw)',
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Telu' => "t\x{e9}lougou",
  'Pauc' => 'paou chin haou',
  'Copt' => 'copte',
  'Ahom' => "\x{e2}hom",
  'Limb' => 'limbou',
  'Visp' => 'parole visible',
  'Sara' => 'sarati',
  'Saur' => 'saurachtra',
  'Khmr' => 'khmer',
  'Zanb' => 'zanabazar quadratique',
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Cprt' => 'syllabaire chypriote',
  'Syrc' => 'syriaque',
  'Vaii' => "va\x{ef}",
  'Sarb' => 'sud-arabique, himyarite',
  'Sinh' => 'singhalais',
  'Mand' => "mand\x{e9}en",
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Nbat' => "nabat\x{e9}en",
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Mymr' => 'birman',
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Mani' => "manich\x{e9}en",
  'Kthi' => "kaith\x{ee}",
  'Tibt' => "tib\x{e9}tain",
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Java' => 'javanais',
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Shrd' => 'charada, shard',
  'Glag' => 'glagolitique',
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Lyci' => 'lycien',
  'Hatr' => "hatr\x{e9}nien",
  'Wole' => "wol\x{e9}a\x{ef}",
  'Bopo' => 'bopomofo',
  'Phlv' => 'pehlevi des livres',
  'Sidd' => 'siddham',
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Syrj' => 'syriaque (variante occidentale)',
  'Arab' => 'arabe',
  'Egyd' => "d\x{e9}motique \x{e9}gyptien"
};
$ScriptCodeVersion = {
  'Sylo' => '4.1',
  'Zmth' => '3.2',
  'Ugar' => '4.0',
  'Zsye' => '6.0',
  'Orkh' => '5.2',
  'Mtei' => '5.2',
  'Gonm' => '10.0',
  'Mroo' => '7.0',
  'Jurc' => '',
  'Rjng' => '5.1',
  'Hebr' => '1.1',
  'Piqd' => '',
  'Nshu' => '10.0',
  'Armn' => '1.1',
  'Egyh' => '5.2',
  'Sogo' => '11.0',
  'Soyo' => '10.0',
  'Samr' => '5.2',
  'Kits' => '13.0',
  'Zinh' => '',
  'Diak' => '13.0',
  'Lepc' => '5.1',
  'Zsym' => '1.1',
  'Tfng' => '4.1',
  'Yiii' => '3.0',
  'Maya' => '',
  'Cyrl' => '1.1',
  'Marc' => '9.0',
  'Perm' => '7.0',
  'Olck' => '5.1',
  'Mend' => '7.0',
  'Bugi' => '4.1',
  'Nand' => '12.0',
  'Aghb' => '7.0',
  'Sind' => '7.0',
  'Kana' => '1.1',
  'Hant' => '1.1',
  'Bali' => '5.0',
  'Bamu' => '5.2',
  'Phlp' => '7.0',
  'Cirt' => '',
  'Talu' => '4.1',
  'Narb' => '7.0',
  'Latf' => '1.1',
  'Xsux' => '5.0',
  'Egyp' => '5.2',
  'Java' => '5.2',
  'Hluw' => '8.0',
  'Tibt' => '2.0',
  'Mymr' => '3.0',
  'Elym' => '12.0',
  'Dsrt' => '3.1',
  'Mani' => '7.0',
  'Kthi' => '5.2',
  'Kpel' => '',
  'Sidd' => '7.0',
  'Arab' => '1.1',
  'Syrj' => '3.0',
  'Geor' => '1.1',
  'Egyd' => '',
  'Bopo' => '1.1',
  'Phlv' => '',
  'Hatr' => '8.0',
  'Wole' => '',
  'Hung' => '8.0',
  'Shrd' => '6.1',
  'Glag' => '4.1',
  'Lyci' => '5.1',
  'Kore' => '1.1',
  'Pauc' => '7.0',
  'Copt' => '4.1',
  'Ahom' => '8.0',
  'Shaw' => '4.0',
  'Zxxx' => '',
  'Telu' => '1.1',
  'Hano' => '3.2',
  'Latn' => '1.1',
  'Inds' => '',
  'Dogr' => '11.0',
  'Phli' => '5.2',
  'Xpeo' => '4.1',
  'Cham' => '5.1',
  'Sarb' => '5.2',
  'Vaii' => '5.1',
  'Sinh' => '3.0',
  'Mand' => '6.0',
  'Merc' => '6.1',
  'Nbat' => '7.0',
  'Jpan' => '1.1',
  'Cprt' => '4.0',
  'Bhks' => '9.0',
  'Syrc' => '3.0',
  'Zanb' => '10.0',
  'Khmr' => '3.0',
  'Limb' => '4.0',
  'Visp' => '',
  'Saur' => '5.1',
  'Sara' => '',
  'Khoj' => '7.0',
  'Mong' => '3.0',
  'Wara' => '7.0',
  'Dupl' => '7.0',
  'Newa' => '9.0',
  'Yezi' => '13.0',
  'Hrkt' => '1.1',
  'Cans' => '3.0',
  'Kitl' => '',
  'Cari' => '5.1',
  'Gong' => '11.0',
  'Lisu' => '5.2',
  'Nkgb' => '',
  'Osma' => '4.0',
  'Phnx' => '5.0',
  'Tale' => '4.0',
  'Sogd' => '11.0',
  'Knda' => '1.1',
  'Ethi' => '3.0',
  'Ital' => '3.1',
  'Batk' => '6.0',
  'Buhd' => '3.2',
  'Plrd' => '6.1',
  'Hmnp' => '12.0',
  'Mult' => '8.0',
  'Phag' => '5.0',
  'Guru' => '1.1',
  'Hanb' => '1.1',
  'Toto' => '',
  'Avst' => '5.2',
  'Sgnw' => '8.0',
  'Tang' => '9.0',
  'Brai' => '3.0',
  'Prti' => '5.2',
  'Hans' => '1.1',
  'Khar' => '4.1',
  'Chrs' => '13.0',
  'Thai' => '1.1',
  'Palm' => '7.0',
  'Qaaa' => '',
  'Gran' => '7.0',
  'Mlym' => '1.1',
  'Afak' => '',
  'Latg' => '1.1',
  'Lana' => '5.2',
  'Zzzz' => '',
  'Goth' => '3.1',
  'Cpmn' => '',
  'Gujr' => '1.1',
  'Blis' => '',
  'Roro' => '',
  'Takr' => '6.1',
  'Cyrs' => '1.1',
  'Qabx' => '',
  'Deva' => '1.1',
  'Cakm' => '6.1',
  'Tavt' => '5.2',
  'Syrn' => '3.0',
  'Sora' => '6.1',
  'Hira' => '1.1',
  'Grek' => '1.1',
  'Cher' => '3.0',
  'Jamo' => '1.1',
  'Hmng' => '7.0',
  'Nkoo' => '5.0',
  'Lydi' => '5.1',
  'Hang' => '1.1',
  'Maka' => '11.0',
  'Aran' => '1.1',
  'Rohg' => '11.0',
  'Taml' => '1.1',
  'Moon' => '',
  'Orya' => '1.1',
  'Hani' => '1.1',
  'Tagb' => '3.2',
  'Zyyy' => '',
  'Mero' => '6.1',
  'Beng' => '1.1',
  'Adlm' => '9.0',
  'Geok' => '1.1',
  'Kali' => '5.1',
  'Mahj' => '7.0',
  'Brah' => '6.0',
  'Armi' => '5.2',
  'Laoo' => '1.1',
  'Nkdb' => '',
  'Osge' => '9.0',
  'Leke' => '',
  'Lina' => '7.0',
  'Sund' => '5.1',
  'Syre' => '3.0',
  'Tglg' => '3.2',
  'Runr' => '3.0',
  'Linb' => '4.0',
  'Medf' => '11.0',
  'Modi' => '7.0',
  'Elba' => '7.0',
  'Wcho' => '12.0',
  'Thaa' => '3.0',
  'Bass' => '7.0',
  'Ogam' => '3.0',
  'Loma' => '',
  'Tirh' => '7.0',
  'Shui' => '',
  'Teng' => ''
};
$ScriptCodeDate = {
  'Orkh' => '2009-06-01
',
  'Zsye' => '2015-12-16
',
  'Ugar' => '2004-05-01
',
  'Zmth' => '2007-11-26
',
  'Sylo' => '2006-06-21
',
  'Piqd' => '2015-12-16
',
  'Hebr' => '2004-05-01
',
  'Rjng' => '2009-02-23
',
  'Jurc' => '2010-12-21
',
  'Mroo' => '2016-12-05
',
  'Gonm' => '2017-07-26
',
  'Mtei' => '2009-06-01
',
  'Samr' => '2009-06-01
',
  'Soyo' => '2017-07-26
',
  'Sogo' => '2017-11-21
',
  'Egyh' => '2004-05-01
',
  'Nshu' => '2017-07-26
',
  'Armn' => '2004-05-01
',
  'Zsym' => '2007-11-26
',
  'Lepc' => '2007-07-02
',
  'Diak' => '2019-08-19
',
  'Zinh' => '2009-02-23
',
  'Kits' => '2015-07-15
',
  'Maya' => '2004-05-01
',
  'Yiii' => '2004-05-01
',
  'Tfng' => '2006-06-21
',
  'Bugi' => '2006-06-21
',
  'Mend' => '2014-11-15
',
  'Olck' => '2007-07-02
',
  'Perm' => '2014-11-15
',
  'Marc' => '2016-12-05
',
  'Cyrl' => '2004-05-01
',
  'Bamu' => '2009-06-01
',
  'Bali' => '2006-10-10
',
  'Hant' => '2004-05-29
',
  'Kana' => '2004-05-01
',
  'Sind' => '2014-11-15
',
  'Aghb' => '2014-11-15
',
  'Nand' => '2018-08-26
',
  'Xsux' => '2006-10-10
',
  'Egyp' => '2009-06-01
',
  'Latf' => '2004-05-01
',
  'Talu' => '2006-06-21
',
  'Narb' => '2014-11-15
',
  'Phlp' => '2014-11-15
',
  'Cirt' => '2004-05-01
',
  'Hluw' => '2015-07-07
',
  'Tibt' => '2004-05-01
',
  'Java' => '2009-06-01
',
  'Kpel' => '2010-03-26
',
  'Kthi' => '2009-06-01
',
  'Mani' => '2014-11-15
',
  'Dsrt' => '2004-05-01
',
  'Elym' => '2018-08-26
',
  'Mymr' => '2004-05-01
',
  'Phlv' => '2007-07-15
',
  'Bopo' => '2004-05-01
',
  'Egyd' => '2004-05-01
',
  'Syrj' => '2004-05-01
',
  'Geor' => '2016-12-05
',
  'Arab' => '2004-05-01
',
  'Sidd' => '2014-11-15
',
  'Kore' => '2007-06-13
',
  'Lyci' => '2007-07-02
',
  'Hung' => '2015-07-07
',
  'Shrd' => '2012-02-06
',
  'Glag' => '2006-06-21
',
  'Wole' => '2010-12-21
',
  'Hatr' => '2015-07-07
',
  'Telu' => '2004-05-01
',
  'Zxxx' => '2011-06-21
',
  'Shaw' => '2004-05-01
',
  'Copt' => '2006-06-21
',
  'Ahom' => '2015-07-07
',
  'Pauc' => '2014-11-15
',
  'Cham' => '2009-11-11
',
  'Phli' => '2009-06-01
',
  'Xpeo' => '2006-06-21
',
  'Inds' => '2004-05-01
',
  'Dogr' => '2016-12-05
',
  'Latn' => '2004-05-01
',
  'Hano' => '2004-05-29
',
  'Syrc' => '2004-05-01
',
  'Bhks' => '2016-12-05
',
  'Cprt' => '2017-07-26
',
  'Jpan' => '2006-06-21
',
  'Nbat' => '2014-11-15
',
  'Merc' => '2012-02-06
',
  'Mand' => '2010-07-23
',
  'Sinh' => '2004-05-01
',
  'Vaii' => '2007-07-02
',
  'Sarb' => '2009-06-01
',
  'Sara' => '2004-05-29
',
  'Saur' => '2007-07-02
',
  'Visp' => '2004-05-01
',
  'Limb' => '2004-05-29
',
  'Khmr' => '2004-05-29
',
  'Zanb' => '2017-07-26
',
  'Kitl' => '2015-07-15
',
  'Cans' => '2004-05-29
',
  'Hrkt' => '2011-06-21
',
  'Yezi' => '2019-08-19
',
  'Newa' => '2016-12-05
',
  'Dupl' => '2014-11-15
',
  'Wara' => '2014-11-15
',
  'Mong' => '2004-05-01
',
  'Khoj' => '2014-11-15
',
  'Ethi' => '2004-10-25
',
  'Knda' => '2004-05-29
',
  'Sogd' => '2017-11-21
',
  'Tale' => '2004-10-25
',
  'Phnx' => '2006-10-10
',
  'Nkgb' => '2017-07-26
',
  'Osma' => '2004-05-01
',
  'Lisu' => '2009-06-01
',
  'Gong' => '2016-12-05
',
  'Cari' => '2007-07-02
',
  'Buhd' => '2004-05-01
',
  'Batk' => '2010-07-23
',
  'Ital' => '2004-05-29
',
  'Sgnw' => '2015-07-07
',
  'Avst' => '2009-06-01
',
  'Toto' => '2020-04-16
',
  'Hanb' => '2016-01-19
',
  'Guru' => '2004-05-01
',
  'Phag' => '2006-10-10
',
  'Mult' => '2015-07-07
',
  'Hmnp' => '2017-07-26
',
  'Plrd' => '2012-02-06
',
  'Palm' => '2014-11-15
',
  'Thai' => '2004-05-01
',
  'Chrs' => '2019-08-19
',
  'Khar' => '2006-06-21
',
  'Hans' => '2004-05-29
',
  'Prti' => '2009-06-01
',
  'Brai' => '2004-05-01
',
  'Tang' => '2016-12-05
',
  'Goth' => '2004-05-01
',
  'Zzzz' => '2006-10-10
',
  'Lana' => '2009-06-01
',
  'Latg' => '2004-05-01
',
  'Afak' => '2010-12-21
',
  'Mlym' => '2004-05-01
',
  'Gran' => '2014-11-15
',
  'Qaaa' => '2004-05-29
',
  'Deva' => '2004-05-01
',
  'Cyrs' => '2004-05-01
',
  'Qabx' => '2004-05-29
',
  'Takr' => '2012-02-06
',
  'Roro' => '2004-05-01
',
  'Blis' => '2004-05-01
',
  'Cpmn' => '2017-07-26
',
  'Gujr' => '2004-05-01
',
  'Cher' => '2004-05-01
',
  'Hira' => '2004-05-01
',
  'Grek' => '2004-05-01
',
  'Sora' => '2012-02-06
',
  'Tavt' => '2009-06-01
',
  'Syrn' => '2004-05-01
',
  'Cakm' => '2012-02-06
',
  'Hang' => '2004-05-29
',
  'Lydi' => '2007-07-02
',
  'Nkoo' => '2006-10-10
',
  'Hmng' => '2014-11-15
',
  'Jamo' => '2016-01-19
',
  'Zyyy' => '2004-05-29
',
  'Tagb' => '2004-05-01
',
  'Hani' => '2009-02-23
',
  'Orya' => '2016-12-05
',
  'Moon' => '2006-12-11
',
  'Taml' => '2004-05-01
',
  'Rohg' => '2017-11-21
',
  'Aran' => '2014-11-15
',
  'Maka' => '2016-12-05
',
  'Geok' => '2012-10-16
',
  'Adlm' => '2016-12-05
',
  'Beng' => '2016-12-05
',
  'Mero' => '2012-02-06
',
  'Nkdb' => '2017-07-26
',
  'Laoo' => '2004-05-01
',
  'Armi' => '2009-06-01
',
  'Brah' => '2010-07-23
',
  'Mahj' => '2014-11-15
',
  'Kali' => '2007-07-02
',
  'Tglg' => '2009-02-23
',
  'Syre' => '2004-05-01
',
  'Lina' => '2014-11-15
',
  'Sund' => '2007-07-02
',
  'Leke' => '2015-07-07
',
  'Osge' => '2016-12-05
',
  'Modi' => '2014-11-15
',
  'Medf' => '2016-12-05
',
  'Linb' => '2004-05-29
',
  'Runr' => '2004-05-01
',
  'Elba' => '2014-11-15
',
  'Teng' => '2004-05-01
',
  'Tirh' => '2014-11-15
',
  'Shui' => '2017-07-26
',
  'Loma' => '2010-03-26
',
  'Ogam' => '2004-05-01
',
  'Bass' => '2014-11-15
',
  'Thaa' => '2004-05-01
',
  'Wcho' => '2017-07-26
'
};
$ScriptCodeId = {
  'Piqd' => '293',
  'Rjng' => '363',
  'Hebr' => '125',
  'Mroo' => '264',
  'Jurc' => '510',
  'Mtei' => '337',
  'Gonm' => '313',
  'Zsye' => '993',
  'Orkh' => '175',
  'Ugar' => '040',
  'Sylo' => '316',
  'Zmth' => '995',
  'Lepc' => '335',
  'Diak' => '342',
  'Zsym' => '996',
  'Zinh' => '994',
  'Kits' => '288',
  'Samr' => '123',
  'Sogo' => '142',
  'Armn' => '230',
  'Nshu' => '499',
  'Egyh' => '060',
  'Soyo' => '329',
  'Bugi' => '367',
  'Perm' => '227',
  'Marc' => '332',
  'Mend' => '438',
  'Olck' => '261',
  'Cyrl' => '220',
  'Maya' => '090',
  'Yiii' => '460',
  'Tfng' => '120',
  'Xsux' => '020',
  'Egyp' => '050',
  'Latf' => '217',
  'Talu' => '354',
  'Narb' => '106',
  'Cirt' => '291',
  'Phlp' => '132',
  'Bamu' => '435',
  'Bali' => '360',
  'Hant' => '502',
  'Kana' => '411',
  'Sind' => '318',
  'Nand' => '311',
  'Aghb' => '239',
  'Kpel' => '436',
  'Mani' => '139',
  'Kthi' => '317',
  'Mymr' => '350',
  'Elym' => '128',
  'Dsrt' => '250',
  'Hluw' => '080',
  'Tibt' => '330',
  'Java' => '361',
  'Kore' => '287',
  'Lyci' => '202',
  'Shrd' => '319',
  'Glag' => '225',
  'Hung' => '176',
  'Wole' => '480',
  'Hatr' => '127',
  'Phlv' => '133',
  'Bopo' => '285',
  'Egyd' => '070',
  'Sidd' => '302',
  'Syrj' => '137',
  'Geor' => '240',
  'Arab' => '160',
  'Cham' => '358',
  'Xpeo' => '030',
  'Phli' => '131',
  'Latn' => '215',
  'Inds' => '610',
  'Dogr' => '328',
  'Hano' => '371',
  'Telu' => '340',
  'Shaw' => '281',
  'Zxxx' => '997',
  'Ahom' => '338',
  'Copt' => '204',
  'Pauc' => '263',
  'Visp' => '280',
  'Saur' => '344',
  'Sara' => '292',
  'Limb' => '336',
  'Khmr' => '355',
  'Zanb' => '339',
  'Syrc' => '135',
  'Bhks' => '334',
  'Cprt' => '403',
  'Mand' => '140',
  'Jpan' => '413',
  'Nbat' => '159',
  'Merc' => '101',
  'Sarb' => '105',
  'Vaii' => '470',
  'Sinh' => '348',
  'Knda' => '345',
  'Tale' => '353',
  'Sogd' => '141',
  'Ethi' => '430',
  'Osma' => '260',
  'Nkgb' => '420',
  'Phnx' => '115',
  'Gong' => '312',
  'Cari' => '201',
  'Lisu' => '399',
  'Cans' => '440',
  'Hrkt' => '412',
  'Kitl' => '505',
  'Newa' => '333',
  'Yezi' => '192',
  'Dupl' => '755',
  'Khoj' => '322',
  'Wara' => '262',
  'Mong' => '145',
  'Avst' => '134',
  'Sgnw' => '095',
  'Guru' => '310',
  'Toto' => '294',
  'Hanb' => '503',
  'Phag' => '331',
  'Hmnp' => '451',
  'Plrd' => '282',
  'Mult' => '323',
  'Buhd' => '372',
  'Batk' => '365',
  'Ital' => '210',
  'Goth' => '206',
  'Zzzz' => '999',
  'Afak' => '439',
  'Latg' => '216',
  'Lana' => '351',
  'Qaaa' => '900',
  'Mlym' => '347',
  'Gran' => '343',
  'Palm' => '126',
  'Thai' => '352',
  'Hans' => '501',
  'Chrs' => '109',
  'Khar' => '305',
  'Tang' => '520',
  'Prti' => '130',
  'Brai' => '570',
  'Cher' => '445',
  'Grek' => '200',
  'Hira' => '410',
  'Cakm' => '349',
  'Sora' => '398',
  'Tavt' => '359',
  'Syrn' => '136',
  'Deva' => '315',
  'Takr' => '321',
  'Qabx' => '949',
  'Cyrs' => '221',
  'Blis' => '550',
  'Cpmn' => '402',
  'Gujr' => '320',
  'Roro' => '620',
  'Hani' => '500',
  'Orya' => '327',
  'Zyyy' => '998',
  'Tagb' => '373',
  'Moon' => '218',
  'Rohg' => '167',
  'Taml' => '346',
  'Maka' => '366',
  'Aran' => '161',
  'Lydi' => '116',
  'Nkoo' => '165',
  'Hang' => '286',
  'Hmng' => '450',
  'Jamo' => '284',
  'Nkdb' => '085',
  'Laoo' => '356',
  'Brah' => '300',
  'Armi' => '124',
  'Kali' => '357',
  'Mahj' => '314',
  'Geok' => '241',
  'Adlm' => '166',
  'Beng' => '325',
  'Mero' => '100',
  'Modi' => '324',
  'Medf' => '265',
  'Linb' => '401',
  'Runr' => '211',
  'Sund' => '362',
  'Lina' => '400',
  'Tglg' => '370',
  'Syre' => '138',
  'Leke' => '364',
  'Osge' => '219',
  'Ogam' => '212',
  'Teng' => '290',
  'Tirh' => '326',
  'Loma' => '437',
  'Shui' => '530',
  'Bass' => '259',
  'Thaa' => '170',
  'Wcho' => '283',
  'Elba' => '226'
};
$Lang2Territory = {
  'brh' => {
    'PK' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'lat' => {
    'VA' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'gan' => {
    'CN' => 2
  },
  'hno' => {
    'PK' => 2
  },
  'gsw' => {
    'DE' => 2,
    'CH' => 1,
    'LI' => 1
  },
  'mak' => {
    'ID' => 2
  },
  'tyv' => {
    'RU' => 2
  },
  'jav' => {
    'ID' => 2
  },
  'bem' => {
    'ZM' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'xog' => {
    'UG' => 2
  },
  'msa' => {
    'CC' => 2,
    'MY' => 1,
    'ID' => 2,
    'SG' => 1,
    'BN' => 1,
    'TH' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'hin' => {
    'IN' => 1,
    'FJ' => 2,
    'ZA' => 2
  },
  'bqi' => {
    'IR' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'zho' => {
    'MY' => 2,
    'CN' => 1,
    'MO' => 1,
    'ID' => 2,
    'SG' => 1,
    'TW' => 1,
    'HK' => 1,
    'US' => 2,
    'VN' => 2,
    'TH' => 2
  },
  'kir' => {
    'KG' => 1
  },
  'nbl' => {
    'ZA' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'mwr' => {
    'IN' => 2
  },
  'tah' => {
    'PF' => 1
  },
  'ilo' => {
    'PH' => 2
  },
  'ceb' => {
    'PH' => 2
  },
  'guz' => {
    'KE' => 2
  },
  'aze' => {
    'IQ' => 2,
    'RU' => 2,
    'IR' => 2,
    'AZ' => 1
  },
  'wol' => {
    'SN' => 1
  },
  'sat' => {
    'IN' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'aln' => {
    'XK' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'ary' => {
    'MA' => 2
  },
  'bgn' => {
    'PK' => 2
  },
  'bej' => {
    'SD' => 2
  },
  'kok' => {
    'IN' => 2
  },
  'fra' => {
    'CH' => 1,
    'MF' => 1,
    'TD' => 1,
    'CD' => 1,
    'HT' => 1,
    'GF' => 1,
    'BF' => 1,
    'DJ' => 1,
    'CA' => 1,
    'RE' => 1,
    'BI' => 1,
    'BJ' => 1,
    'TN' => 1,
    'PT' => 2,
    'PF' => 1,
    'MG' => 1,
    'GB' => 2,
    'PM' => 1,
    'DZ' => 1,
    'GP' => 1,
    'US' => 2,
    'LU' => 1,
    'VU' => 1,
    'CF' => 1,
    'RW' => 1,
    'GA' => 1,
    'GQ' => 1,
    'MU' => 1,
    'DE' => 2,
    'CI' => 1,
    'TF' => 2,
    'SC' => 1,
    'YT' => 1,
    'KM' => 1,
    'MQ' => 1,
    'MA' => 1,
    'CM' => 1,
    'MC' => 1,
    'NC' => 1,
    'RO' => 2,
    'TG' => 1,
    'SY' => 1,
    'IT' => 2,
    'WF' => 1,
    'NE' => 1,
    'CG' => 1,
    'BL' => 1,
    'FR' => 1,
    'ML' => 1,
    'GN' => 1,
    'BE' => 1,
    'SN' => 1,
    'NL' => 2
  },
  'shi' => {
    'MA' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'dzo' => {
    'BT' => 1
  },
  'shn' => {
    'MM' => 2
  },
  'hoj' => {
    'IN' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'suk' => {
    'TZ' => 2
  },
  'nyn' => {
    'UG' => 2
  },
  'tam' => {
    'IN' => 2,
    'SG' => 1,
    'LK' => 1,
    'MY' => 2
  },
  'ful' => {
    'GN' => 2,
    'ML' => 2,
    'NG' => 2,
    'SN' => 2,
    'NE' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'spa' => {
    'MX' => 1,
    'HN' => 1,
    'AR' => 1,
    'CO' => 1,
    'PT' => 2,
    'PH' => 2,
    'CR' => 1,
    'CL' => 1,
    'FR' => 2,
    'IC' => 1,
    'PA' => 1,
    'BO' => 1,
    'US' => 2,
    'PE' => 1,
    'GQ' => 1,
    'DE' => 2,
    'CU' => 1,
    'DO' => 1,
    'BZ' => 2,
    'NI' => 1,
    'SV' => 1,
    'GT' => 1,
    'EA' => 1,
    'ES' => 1,
    'AD' => 2,
    'GI' => 2,
    'EC' => 1,
    'PR' => 1,
    'UY' => 1,
    'VE' => 1,
    'PY' => 1,
    'RO' => 2
  },
  'kha' => {
    'IN' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'gaa' => {
    'GH' => 2
  },
  'tel' => {
    'IN' => 2
  },
  'uig' => {
    'CN' => 2
  },
  'sou' => {
    'TH' => 2
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'tvl' => {
    'TV' => 1
  },
  'bam' => {
    'ML' => 2
  },
  'ori' => {
    'IN' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'hne' => {
    'IN' => 2
  },
  'fin' => {
    'SE' => 2,
    'FI' => 1,
    'EE' => 2
  },
  'heb' => {
    'IL' => 1
  },
  'nld' => {
    'DE' => 2,
    'BE' => 1,
    'NL' => 1,
    'SR' => 1,
    'BQ' => 1,
    'AW' => 1,
    'CW' => 1,
    'SX' => 1
  },
  'gom' => {
    'IN' => 2
  },
  'hif' => {
    'FJ' => 1
  },
  'mzn' => {
    'IR' => 2
  },
  'ibb' => {
    'NG' => 2
  },
  'grn' => {
    'PY' => 1
  },
  'asm' => {
    'IN' => 2
  },
  'tem' => {
    'SL' => 2
  },
  'sas' => {
    'ID' => 2
  },
  'hoc' => {
    'IN' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'yor' => {
    'NG' => 1
  },
  'nso' => {
    'ZA' => 2
  },
  'ton' => {
    'TO' => 1
  },
  'bjn' => {
    'ID' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'udm' => {
    'RU' => 2
  },
  'bal' => {
    'IR' => 2,
    'PK' => 2,
    'AF' => 2
  },
  'oci' => {
    'FR' => 2
  },
  'kmb' => {
    'AO' => 2
  },
  'khn' => {
    'IN' => 2
  },
  'bug' => {
    'ID' => 2
  },
  'snk' => {
    'ML' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'nya' => {
    'MW' => 1,
    'ZM' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'bod' => {
    'CN' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'hbs' => {
    'HR' => 1,
    'SI' => 2,
    'ME' => 1,
    'AT' => 2,
    'XK' => 1,
    'BA' => 1,
    'RS' => 1
  },
  'kfy' => {
    'IN' => 2
  },
  'ben' => {
    'BD' => 1,
    'IN' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'glk' => {
    'IR' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'chv' => {
    'RU' => 2
  },
  'und' => {
    'BV' => 2,
    'HM' => 2,
    'CP' => 2,
    'AQ' => 2,
    'GS' => 2
  },
  'ell' => {
    'CY' => 1,
    'GR' => 1
  },
  'deu' => {
    'SI' => 2,
    'LI' => 1,
    'BE' => 1,
    'NL' => 2,
    'LU' => 1,
    'US' => 2,
    'FR' => 2,
    'CZ' => 2,
    'PL' => 2,
    'AT' => 1,
    'SK' => 2,
    'KZ' => 2,
    'GB' => 2,
    'DE' => 1,
    'DK' => 2,
    'HU' => 2,
    'CH' => 1,
    'BR' => 2
  },
  'kor' => {
    'US' => 2,
    'KR' => 1,
    'KP' => 1,
    'CN' => 2
  },
  'bin' => {
    'NG' => 2
  },
  'div' => {
    'MV' => 1
  },
  'syl' => {
    'BD' => 2
  },
  'fao' => {
    'FO' => 1
  },
  'afr' => {
    'NA' => 2,
    'ZA' => 2
  },
  'sav' => {
    'SN' => 2
  },
  'kbd' => {
    'RU' => 2
  },
  'ckb' => {
    'IQ' => 2,
    'IR' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'sme' => {
    'NO' => 2
  },
  'kik' => {
    'KE' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'hil' => {
    'PH' => 2
  },
  'nym' => {
    'TZ' => 2
  },
  'tum' => {
    'MW' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'pau' => {
    'PW' => 1
  },
  'ibo' => {
    'NG' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'glv' => {
    'IM' => 1
  },
  'nds' => {
    'NL' => 2,
    'DE' => 2
  },
  'buc' => {
    'YT' => 2
  },
  'mfv' => {
    'SN' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'aym' => {
    'BO' => 1
  },
  'chk' => {
    'FM' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'hun' => {
    'RS' => 2,
    'HU' => 1,
    'RO' => 2,
    'AT' => 2
  },
  'nor' => {
    'NO' => 1,
    'SJ' => 1
  },
  'orm' => {
    'ET' => 2
  },
  'kur' => {
    'TR' => 2,
    'IR' => 2,
    'IQ' => 2,
    'SY' => 2
  },
  'amh' => {
    'ET' => 1
  },
  'isl' => {
    'IS' => 1
  },
  'mya' => {
    'MM' => 1
  },
  'gon' => {
    'IN' => 2
  },
  'bum' => {
    'CM' => 2
  },
  'rus' => {
    'UA' => 1,
    'RU' => 1,
    'TJ' => 2,
    'BG' => 2,
    'PL' => 2,
    'LV' => 2,
    'UZ' => 2,
    'KZ' => 1,
    'LT' => 2,
    'DE' => 2,
    'EE' => 2,
    'BY' => 1,
    'KG' => 1,
    'SJ' => 2
  },
  'tig' => {
    'ER' => 2
  },
  'bgc' => {
    'IN' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'fon' => {
    'BJ' => 2
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'ban' => {
    'ID' => 2
  },
  'zha' => {
    'CN' => 2
  },
  'sot' => {
    'ZA' => 2,
    'LS' => 1
  },
  'wal' => {
    'ET' => 2
  },
  'khm' => {
    'KH' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'eus' => {
    'ES' => 2
  },
  'haz' => {
    'AF' => 2
  },
  'rkt' => {
    'BD' => 2,
    'IN' => 2
  },
  'mer' => {
    'KE' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'fud' => {
    'WF' => 2
  },
  'fil' => {
    'US' => 2,
    'PH' => 1
  },
  'por' => {
    'GQ' => 1,
    'TL' => 1,
    'CV' => 1,
    'BR' => 1,
    'ST' => 1,
    'GW' => 1,
    'MO' => 1,
    'PT' => 1,
    'MZ' => 1,
    'AO' => 1
  },
  'skr' => {
    'PK' => 2
  },
  'fij' => {
    'FJ' => 1
  },
  'bul' => {
    'BG' => 1
  },
  'gil' => {
    'KI' => 1
  },
  'arq' => {
    'DZ' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'luy' => {
    'KE' => 2
  },
  'sck' => {
    'IN' => 2
  },
  'sus' => {
    'GN' => 2
  },
  'wbr' => {
    'IN' => 2
  },
  'smo' => {
    'WS' => 1,
    'AS' => 1
  },
  'tkl' => {
    'TK' => 1
  },
  'fas' => {
    'PK' => 2,
    'AF' => 1,
    'IR' => 1
  },
  'bak' => {
    'RU' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'bew' => {
    'ID' => 2
  },
  'tiv' => {
    'NG' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'bos' => {
    'BA' => 1
  },
  'swe' => {
    'FI' => 1,
    'SE' => 1,
    'AX' => 1
  },
  'mni' => {
    'IN' => 2
  },
  'rmt' => {
    'IR' => 2
  },
  'tnr' => {
    'SN' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'mon' => {
    'CN' => 2,
    'MN' => 1
  },
  'bho' => {
    'MU' => 2,
    'NP' => 2,
    'IN' => 2
  },
  'srn' => {
    'SR' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'mfa' => {
    'TH' => 2
  },
  'lin' => {
    'CD' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'ewe' => {
    'TG' => 2,
    'GH' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'pol' => {
    'PL' => 1,
    'UA' => 2
  },
  'tsn' => {
    'BW' => 1,
    'ZA' => 2
  },
  'som' => {
    'DJ' => 2,
    'SO' => 1,
    'ET' => 2
  },
  'fvr' => {
    'SD' => 2
  },
  'kea' => {
    'CV' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'xho' => {
    'ZA' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'kde' => {
    'TZ' => 2
  },
  'ita' => {
    'VA' => 1,
    'CH' => 1,
    'IT' => 1,
    'MT' => 2,
    'DE' => 2,
    'FR' => 2,
    'SM' => 1,
    'HR' => 2,
    'US' => 2
  },
  'war' => {
    'PH' => 2
  },
  'nno' => {
    'NO' => 1
  },
  'wuu' => {
    'CN' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'dan' => {
    'DE' => 2,
    'DK' => 1
  },
  'bjt' => {
    'SN' => 2
  },
  'gcr' => {
    'GF' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'dnj' => {
    'CI' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'sag' => {
    'CF' => 1
  },
  'vmw' => {
    'MZ' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'fry' => {
    'NL' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'gbm' => {
    'IN' => 2
  },
  'dje' => {
    'NE' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'tur' => {
    'TR' => 1,
    'CY' => 1,
    'DE' => 2
  },
  'pan' => {
    'IN' => 2,
    'PK' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'vie' => {
    'US' => 2,
    'VN' => 1
  },
  'mkd' => {
    'MK' => 1
  },
  'mdf' => {
    'RU' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'crs' => {
    'SC' => 2
  },
  'ara' => {
    'SO' => 1,
    'KW' => 1,
    'AE' => 1,
    'PS' => 1,
    'DZ' => 2,
    'ER' => 1,
    'IQ' => 1,
    'MR' => 1,
    'QA' => 1,
    'EG' => 2,
    'SY' => 1,
    'TN' => 1,
    'YE' => 1,
    'SD' => 1,
    'JO' => 1,
    'IL' => 1,
    'DJ' => 1,
    'MA' => 2,
    'BH' => 1,
    'IR' => 2,
    'KM' => 1,
    'OM' => 1,
    'LB' => 1,
    'LY' => 1,
    'TD' => 1,
    'SS' => 2,
    'EH' => 1,
    'SA' => 1
  },
  'rif' => {
    'MA' => 2
  },
  'sid' => {
    'ET' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'sef' => {
    'CI' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'fuv' => {
    'NG' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'glg' => {
    'ES' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'kom' => {
    'RU' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'ces' => {
    'CZ' => 1,
    'SK' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'fuq' => {
    'NE' => 2
  },
  'kab' => {
    'DZ' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'ssw' => {
    'SZ' => 1,
    'ZA' => 2
  },
  'san' => {
    'IN' => 2
  },
  'ltz' => {
    'LU' => 1
  },
  'noe' => {
    'IN' => 2
  },
  'cat' => {
    'AD' => 1,
    'ES' => 2
  },
  'srd' => {
    'IT' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'luz' => {
    'IR' => 2
  },
  'kin' => {
    'RW' => 1
  },
  'aeb' => {
    'TN' => 2
  },
  'gle' => {
    'GB' => 2,
    'IE' => 1
  },
  'kaz' => {
    'CN' => 2,
    'KZ' => 1
  },
  'bis' => {
    'VU' => 1
  },
  'tgk' => {
    'TJ' => 1
  },
  'swb' => {
    'YT' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'kal' => {
    'DK' => 2,
    'GL' => 1
  },
  'lua' => {
    'CD' => 2
  },
  'mfe' => {
    'MU' => 2
  },
  'vls' => {
    'BE' => 2
  },
  'tir' => {
    'ET' => 2,
    'ER' => 1
  },
  'eng' => {
    'US' => 1,
    'GG' => 1,
    'AE' => 2,
    'SG' => 1,
    'DZ' => 2,
    'KY' => 1,
    'IQ' => 2,
    'MW' => 1,
    'NR' => 1,
    'CY' => 2,
    'LC' => 1,
    'VC' => 1,
    'GB' => 1,
    'MG' => 1,
    'FK' => 1,
    'SB' => 1,
    'EE' => 2,
    'CK' => 1,
    'BR' => 2,
    'CX' => 1,
    'KN' => 1,
    'LS' => 1,
    'SI' => 2,
    'AU' => 1,
    'IL' => 2,
    'GI' => 1,
    'PR' => 1,
    'TA' => 2,
    'CC' => 1,
    'ZA' => 1,
    'LK' => 2,
    'DG' => 1,
    'TH' => 2,
    'SZ' => 1,
    'BM' => 1,
    'IE' => 1,
    'NF' => 1,
    'MT' => 1,
    'NL' => 2,
    'BE' => 2,
    'VI' => 1,
    'IM' => 1,
    'TR' => 2,
    'FJ' => 1,
    'ER' => 1,
    'SX' => 1,
    'LT' => 2,
    'SK' => 2,
    'MY' => 2,
    'HK' => 1,
    'PH' => 1,
    'TO' => 1,
    'AR' => 2,
    'MX' => 2,
    'GY' => 1,
    'ZM' => 1,
    'SD' => 1,
    'RO' => 2,
    'VG' => 1,
    'GD' => 1,
    'CZ' => 2,
    'MS' => 1,
    'PL' => 2,
    'KZ' => 2,
    'NA' => 1,
    'SC' => 1,
    'NU' => 1,
    'TV' => 1,
    'IO' => 1,
    'LB' => 2,
    'FI' => 2,
    'DK' => 2,
    'UG' => 1,
    'KI' => 1,
    'BA' => 2,
    'SS' => 1,
    'VU' => 1,
    'HR' => 2,
    'LU' => 2,
    'WS' => 1,
    'CL' => 2,
    'DM' => 1,
    'BG' => 2,
    'MP' => 1,
    'PT' => 2,
    'BB' => 1,
    'NG' => 1,
    'TK' => 1,
    'BW' => 1,
    'GR' => 2,
    'YE' => 2,
    'KE' => 1,
    'NZ' => 1,
    'BI' => 1,
    'PW' => 1,
    'JE' => 1,
    'CA' => 1,
    'ES' => 2,
    'TC' => 1,
    'BZ' => 1,
    'GM' => 1,
    'AC' => 2,
    'IN' => 1,
    'AS' => 1,
    'PG' => 1,
    'CH' => 2,
    'AG' => 1,
    'SE' => 2,
    'FR' => 2,
    'ZW' => 1,
    'LV' => 2,
    'UM' => 1,
    'SL' => 1,
    'EG' => 2,
    'JM' => 1,
    'IT' => 2,
    'BD' => 2,
    'JO' => 2,
    'GU' => 1,
    'AI' => 1,
    'CM' => 1,
    'SH' => 1,
    'AT' => 2,
    'MA' => 2,
    'FM' => 1,
    'TZ' => 1,
    'GH' => 1,
    'TT' => 1,
    'DE' => 2,
    'MU' => 1,
    'PK' => 1,
    'PN' => 1,
    'ET' => 2,
    'RW' => 1,
    'BS' => 1,
    'MH' => 1,
    'HU' => 2,
    'LR' => 1
  },
  'que' => {
    'EC' => 1,
    'PE' => 1,
    'BO' => 1
  },
  'yue' => {
    'CN' => 2,
    'HK' => 2
  },
  'nep' => {
    'NP' => 1,
    'IN' => 2
  },
  'men' => {
    'SL' => 2
  },
  'unr' => {
    'IN' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'zgh' => {
    'MA' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'swa' => {
    'TZ' => 1,
    'UG' => 1,
    'CD' => 2,
    'KE' => 1
  },
  'dcc' => {
    'IN' => 2
  },
  'inh' => {
    'RU' => 2
  },
  'brx' => {
    'IN' => 2
  },
  'awa' => {
    'IN' => 2
  },
  'min' => {
    'ID' => 2
  },
  'ach' => {
    'UG' => 2
  },
  'seh' => {
    'MZ' => 2
  },
  'ron' => {
    'RS' => 2,
    'MD' => 1,
    'RO' => 1
  },
  'bhi' => {
    'IN' => 2
  },
  'dyu' => {
    'BF' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'tet' => {
    'TL' => 1
  },
  'kam' => {
    'KE' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'arz' => {
    'EG' => 2
  },
  'tha' => {
    'TH' => 1
  },
  'hau' => {
    'NE' => 2,
    'NG' => 2
  },
  'krc' => {
    'RU' => 2
  },
  'tpi' => {
    'PG' => 1
  },
  'rej' => {
    'ID' => 2
  },
  'gor' => {
    'ID' => 2
  },
  'srp' => {
    'RS' => 1,
    'ME' => 1,
    'BA' => 1,
    'XK' => 1
  },
  'mdh' => {
    'PH' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'tso' => {
    'ZA' => 2,
    'MZ' => 2
  },
  'bsc' => {
    'SN' => 2
  },
  'myx' => {
    'UG' => 2
  },
  'zdj' => {
    'KM' => 1
  },
  'mad' => {
    'ID' => 2
  },
  'tzm' => {
    'MA' => 1
  },
  'sqi' => {
    'AL' => 1,
    'RS' => 2,
    'MK' => 2,
    'XK' => 1
  },
  'che' => {
    'RU' => 2
  },
  'ukr' => {
    'UA' => 1,
    'RS' => 2
  },
  'bar' => {
    'AT' => 2,
    'DE' => 2
  },
  'lez' => {
    'RU' => 2
  },
  'est' => {
    'EE' => 1
  },
  'mri' => {
    'NZ' => 1
  },
  'iii' => {
    'CN' => 2
  },
  'pam' => {
    'PH' => 2
  },
  'run' => {
    'BI' => 1
  },
  'nod' => {
    'TH' => 2
  },
  'sah' => {
    'RU' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'slv' => {
    'SI' => 1,
    'AT' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'snd' => {
    'PK' => 2,
    'IN' => 2
  },
  'tcy' => {
    'IN' => 2
  },
  'mai' => {
    'NP' => 2,
    'IN' => 2
  },
  'man' => {
    'GN' => 2,
    'GM' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'haw' => {
    'US' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'hmo' => {
    'PG' => 1
  },
  'hsn' => {
    'CN' => 2
  },
  'hye' => {
    'RU' => 2,
    'AM' => 1
  },
  'lao' => {
    'LA' => 1
  },
  'hrv' => {
    'SI' => 2,
    'AT' => 2,
    'HR' => 1,
    'RS' => 2,
    'BA' => 1
  },
  'mlt' => {
    'MT' => 1
  },
  'pap' => {
    'AW' => 1,
    'BQ' => 2,
    'CW' => 1
  },
  'mag' => {
    'IN' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'lah' => {
    'PK' => 2
  },
  'uzb' => {
    'AF' => 2,
    'UZ' => 1
  },
  'efi' => {
    'NG' => 2
  },
  'sna' => {
    'ZW' => 1
  },
  'kua' => {
    'NA' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'tuk' => {
    'TM' => 1,
    'IR' => 2,
    'AF' => 2
  },
  'doi' => {
    'IN' => 2
  },
  'koi' => {
    'RU' => 2
  },
  'kon' => {
    'CD' => 2
  },
  'raj' => {
    'IN' => 2
  },
  'slk' => {
    'SK' => 1,
    'RS' => 2,
    'CZ' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'lug' => {
    'UG' => 2
  },
  'nob' => {
    'NO' => 1,
    'SJ' => 1
  },
  'ace' => {
    'ID' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'tat' => {
    'RU' => 2
  },
  'laj' => {
    'UG' => 2
  }
};
$Lang2Script = {
  'fas' => {
    'Arab' => 1
  },
  'bft' => {
    'Arab' => 1,
    'Tibt' => 2
  },
  'bew' => {
    'Latn' => 1
  },
  'aoz' => {
    'Latn' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'rom' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'mni' => {
    'Mtei' => 2,
    'Beng' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'wln' => {
    'Latn' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'mxc' => {
    'Latn' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'ndo' => {
    'Latn' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'arg' => {
    'Latn' => 1
  },
  'fvr' => {
    'Latn' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'som' => {
    'Latn' => 1,
    'Arab' => 2,
    'Osma' => 2
  },
  'scn' => {
    'Latn' => 1
  },
  'wbp' => {
    'Latn' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'tkr' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'kca' => {
    'Cyrl' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'trv' => {
    'Latn' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'mro' => {
    'Mroo' => 2,
    'Latn' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'gay' => {
    'Latn' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'kum' => {
    'Cyrl' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'srb' => {
    'Latn' => 1,
    'Sora' => 2
  },
  'luo' => {
    'Latn' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'gju' => {
    'Arab' => 1
  },
  'sdc' => {
    'Latn' => 1
  },
  'tsd' => {
    'Grek' => 1
  },
  'pms' => {
    'Latn' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'ind' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'osc' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'yao' => {
    'Latn' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'tur' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'kri' => {
    'Latn' => 1
  },
  'sid' => {
    'Latn' => 1
  },
  'rif' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'lag' => {
    'Latn' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'kom' => {
    'Cyrl' => 1,
    'Perm' => 2
  },
  'glg' => {
    'Latn' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'maz' => {
    'Latn' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'den' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'kgp' => {
    'Latn' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'noe' => {
    'Deva' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'vic' => {
    'Latn' => 1
  },
  'nde' => {
    'Latn' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'swb' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'bis' => {
    'Latn' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'byn' => {
    'Ethi' => 1
  },
  'gba' => {
    'Latn' => 1
  },
  'lim' => {
    'Latn' => 1
  },
  'eng' => {
    'Latn' => 1,
    'Dsrt' => 2,
    'Shaw' => 2
  },
  'men' => {
    'Mend' => 2,
    'Latn' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'khq' => {
    'Latn' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'swa' => {
    'Latn' => 1
  },
  'ven' => {
    'Latn' => 1
  },
  'crk' => {
    'Cans' => 1
  },
  'ron' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'inh' => {
    'Cyrl' => 1,
    'Latn' => 2,
    'Arab' => 2
  },
  'kyu' => {
    'Kali' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'kaj' => {
    'Latn' => 1
  },
  'arz' => {
    'Arab' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'moh' => {
    'Latn' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'rej' => {
    'Latn' => 1,
    'Rjng' => 2
  },
  'mgo' => {
    'Latn' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'myx' => {
    'Latn' => 1
  },
  'tso' => {
    'Latn' => 1
  },
  'mdh' => {
    'Latn' => 1
  },
  'srp' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'gor' => {
    'Latn' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'tzm' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'bar' => {
    'Latn' => 1
  },
  'kao' => {
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'lez' => {
    'Cyrl' => 1,
    'Aghb' => 2
  },
  'nod' => {
    'Lana' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'run' => {
    'Latn' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'bku' => {
    'Buhd' => 2,
    'Latn' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'snd' => {
    'Khoj' => 2,
    'Arab' => 1,
    'Sind' => 2,
    'Deva' => 1
  },
  'vai' => {
    'Latn' => 1,
    'Vaii' => 1
  },
  'sga' => {
    'Ogam' => 2,
    'Latn' => 2
  },
  'ssy' => {
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'aka' => {
    'Latn' => 1
  },
  'man' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'mai' => {
    'Deva' => 1,
    'Tirh' => 2
  },
  'hsn' => {
    'Hans' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'mrd' => {
    'Deva' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'pal' => {
    'Phlp' => 2,
    'Phli' => 2
  },
  'twq' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'uzb' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'cho' => {
    'Latn' => 1
  },
  'sun' => {
    'Latn' => 1,
    'Sund' => 2
  },
  'swg' => {
    'Latn' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'arc' => {
    'Armi' => 2,
    'Palm' => 2,
    'Nbat' => 2
  },
  'kon' => {
    'Latn' => 1
  },
  'rug' => {
    'Latn' => 1
  },
  'koi' => {
    'Cyrl' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'csb' => {
    'Latn' => 2
  },
  'bqv' => {
    'Latn' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'osa' => {
    'Osge' => 1,
    'Latn' => 2
  },
  'ave' => {
    'Avst' => 2
  },
  'ada' => {
    'Latn' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'tdd' => {
    'Tale' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'xsr' => {
    'Deva' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'bua' => {
    'Cyrl' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'mak' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'zho' => {
    'Bopo' => 2,
    'Hant' => 1,
    'Phag' => 2,
    'Hans' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'kir' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'aze' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'wol' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'mtr' => {
    'Deva' => 1
  },
  'ary' => {
    'Arab' => 1
  },
  'kas' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'fra' => {
    'Dupl' => 2,
    'Latn' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'gag' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'bmq' => {
    'Latn' => 1
  },
  'rar' => {
    'Latn' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'urd' => {
    'Arab' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'ikt' => {
    'Latn' => 1
  },
  'gaa' => {
    'Latn' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'sou' => {
    'Thai' => 1
  },
  'uig' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 2
  },
  'nov' => {
    'Latn' => 2
  },
  'lit' => {
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'ori' => {
    'Orya' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'cop' => {
    'Copt' => 2,
    'Grek' => 2,
    'Arab' => 2
  },
  'mzn' => {
    'Arab' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'hif' => {
    'Deva' => 1,
    'Latn' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'tem' => {
    'Latn' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'sas' => {
    'Latn' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'lzz' => {
    'Geor' => 1,
    'Latn' => 1
  },
  'oci' => {
    'Latn' => 1
  },
  'bal' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'bug' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'bzx' => {
    'Latn' => 1
  },
  'mdr' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'hbs' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'kfy' => {
    'Deva' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'ttj' => {
    'Latn' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'deu' => {
    'Runr' => 2,
    'Latn' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'fao' => {
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'hil' => {
    'Latn' => 1
  },
  'sme' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'aym' => {
    'Latn' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'hun' => {
    'Latn' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'bjj' => {
    'Deva' => 1
  },
  'ccp' => {
    'Cakm' => 1,
    'Beng' => 1
  },
  'tly' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'orm' => {
    'Ethi' => 2,
    'Latn' => 1
  },
  'frp' => {
    'Latn' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'amh' => {
    'Ethi' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'bum' => {
    'Latn' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'sot' => {
    'Latn' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'hnd' => {
    'Arab' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'rkt' => {
    'Beng' => 1
  },
  'nus' => {
    'Latn' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'iku' => {
    'Cans' => 1,
    'Latn' => 1
  },
  'nzi' => {
    'Latn' => 1
  },
  'fil' => {
    'Latn' => 1,
    'Tglg' => 2
  },
  'dyo' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'amo' => {
    'Latn' => 1
  },
  'ale' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'bra' => {
    'Deva' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'sck' => {
    'Deva' => 1
  },
  'jpn' => {
    'Jpan' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'mua' => {
    'Latn' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'nnh' => {
    'Latn' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'xav' => {
    'Latn' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'bos' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'anp' => {
    'Deva' => 1
  },
  'mon' => {
    'Phag' => 2,
    'Cyrl' => 1,
    'Mong' => 2
  },
  'cay' => {
    'Latn' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'sly' => {
    'Latn' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'frr' => {
    'Latn' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'kht' => {
    'Mymr' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'xsa' => {
    'Sarb' => 2
  },
  'loz' => {
    'Latn' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'nsk' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'ain' => {
    'Latn' => 2,
    'Kana' => 2
  },
  'war' => {
    'Latn' => 1
  },
  'aii' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'dtm' => {
    'Latn' => 1
  },
  'kan' => {
    'Knda' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'grt' => {
    'Beng' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'tru' => {
    'Latn' => 1,
    'Syrc' => 2
  },
  'pko' => {
    'Latn' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'was' => {
    'Latn' => 1
  },
  'sxn' => {
    'Latn' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'rcf' => {
    'Latn' => 1
  },
  'syr' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'atj' => {
    'Latn' => 1
  },
  'vmw' => {
    'Latn' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'vie' => {
    'Hani' => 2,
    'Latn' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'pan' => {
    'Guru' => 1,
    'Arab' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'hmn' => {
    'Laoo' => 1,
    'Hmng' => 2,
    'Plrd' => 1,
    'Latn' => 1
  },
  'thl' => {
    'Deva' => 1
  },
  'xnr' => {
    'Deva' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'fuv' => {
    'Latn' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'ava' => {
    'Cyrl' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'zap' => {
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'ina' => {
    'Latn' => 2
  },
  'ttt' => {
    'Arab' => 2,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'fuq' => {
    'Latn' => 1
  },
  'ssw' => {
    'Latn' => 1
  },
  'yap' => {
    'Latn' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'san' => {
    'Shrd' => 2,
    'Sidd' => 2,
    'Gran' => 2,
    'Sinh' => 2,
    'Deva' => 2
  },
  'srd' => {
    'Latn' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'kin' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'tgk' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'kaz' => {
    'Cyrl' => 1,
    'Arab' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'tir' => {
    'Ethi' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'lua' => {
    'Latn' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'yue' => {
    'Hans' => 1,
    'Hant' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'unr' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'zgh' => {
    'Tfng' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'mgp' => {
    'Deva' => 1
  },
  'maf' => {
    'Latn' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'ach' => {
    'Latn' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'bhi' => {
    'Deva' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'btv' => {
    'Deva' => 1
  },
  'non' => {
    'Runr' => 2
  },
  'kam' => {
    'Latn' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'hau' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'lcp' => {
    'Thai' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'lki' => {
    'Arab' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'sqi' => {
    'Elba' => 2,
    'Latn' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'kjg' => {
    'Laoo' => 1,
    'Latn' => 2
  },
  'lij' => {
    'Latn' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'bfq' => {
    'Taml' => 1
  },
  'iii' => {
    'Latn' => 2,
    'Yiii' => 1
  },
  'mri' => {
    'Latn' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'unx' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'pam' => {
    'Latn' => 1
  },
  'zea' => {
    'Latn' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'lui' => {
    'Latn' => 2
  },
  'tcy' => {
    'Knda' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'lfn' => {
    'Cyrl' => 2,
    'Latn' => 2
  },
  'chp' => {
    'Latn' => 1,
    'Cans' => 2
  },
  'hye' => {
    'Armn' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'hrv' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'lao' => {
    'Laoo' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'sam' => {
    'Hebr' => 2,
    'Samr' => 2
  },
  'sna' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'lah' => {
    'Arab' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'bbc' => {
    'Latn' => 1,
    'Batk' => 2
  },
  'tuk' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'fur' => {
    'Latn' => 1
  },
  'ltg' => {
    'Latn' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'doi' => {
    'Arab' => 1,
    'Takr' => 2,
    'Deva' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'slk' => {
    'Latn' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'cjm' => {
    'Cham' => 1,
    'Arab' => 2
  },
  'stq' => {
    'Latn' => 1
  },
  'taj' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'brh' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'pli' => {
    'Sinh' => 2,
    'Thai' => 2,
    'Deva' => 2
  },
  'thq' => {
    'Deva' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'phn' => {
    'Phnx' => 2
  },
  'bem' => {
    'Latn' => 1
  },
  'jav' => {
    'Java' => 2,
    'Latn' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'hin' => {
    'Mahj' => 2,
    'Deva' => 1,
    'Latn' => 2
  },
  'zza' => {
    'Latn' => 1
  },
  'msa' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'fia' => {
    'Arab' => 1
  },
  'bqi' => {
    'Arab' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'guz' => {
    'Latn' => 1
  },
  'aln' => {
    'Latn' => 1
  },
  'sat' => {
    'Beng' => 2,
    'Latn' => 2,
    'Deva' => 2,
    'Orya' => 2,
    'Olck' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'shi' => {
    'Latn' => 1,
    'Arab' => 1,
    'Tfng' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'bez' => {
    'Latn' => 1
  },
  'srx' => {
    'Deva' => 1
  },
  'nyn' => {
    'Latn' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'scs' => {
    'Latn' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'ful' => {
    'Latn' => 1,
    'Adlm' => 2
  },
  'bfd' => {
    'Latn' => 1
  },
  'kha' => {
    'Latn' => 1,
    'Beng' => 2
  },
  'grb' => {
    'Latn' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'jml' => {
    'Deva' => 1
  },
  'bam' => {
    'Nkoo' => 1,
    'Latn' => 1
  },
  'tvl' => {
    'Latn' => 1
  },
  'mdt' => {
    'Latn' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'tdg' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'nld' => {
    'Latn' => 1
  },
  'tog' => {
    'Latn' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'fin' => {
    'Latn' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'hai' => {
    'Latn' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'ibb' => {
    'Latn' => 1
  },
  'yor' => {
    'Latn' => 1
  },
  'kat' => {
    'Geor' => 1
  },
  'byv' => {
    'Latn' => 1
  },
  'grn' => {
    'Latn' => 1
  },
  'udm' => {
    'Cyrl' => 1,
    'Latn' => 2
  },
  'kln' => {
    'Latn' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'ton' => {
    'Latn' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'kmb' => {
    'Latn' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'hnn' => {
    'Hano' => 2,
    'Latn' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'vmf' => {
    'Latn' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'kiu' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'xpr' => {
    'Prti' => 2
  },
  'wae' => {
    'Latn' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'uga' => {
    'Ugar' => 2
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'syl' => {
    'Sylo' => 2,
    'Beng' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'dty' => {
    'Deva' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'kor' => {
    'Kore' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'grc' => {
    'Grek' => 2,
    'Linb' => 2,
    'Cprt' => 2
  },
  'afr' => {
    'Latn' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'arw' => {
    'Latn' => 2
  },
  'chu' => {
    'Cyrl' => 2
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'ett' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'nym' => {
    'Latn' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'kik' => {
    'Latn' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'egy' => {
    'Egyp' => 2
  },
  'tum' => {
    'Latn' => 1
  },
  'pau' => {
    'Latn' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'nxq' => {
    'Latn' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'mas' => {
    'Latn' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'bto' => {
    'Latn' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'kur' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'gon' => {
    'Deva' => 1,
    'Telu' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'cja' => {
    'Arab' => 1,
    'Cham' => 2
  },
  'ban' => {
    'Bali' => 2,
    'Latn' => 1
  },
  'pnt' => {
    'Latn' => 1,
    'Grek' => 1,
    'Cyrl' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'lmo' => {
    'Latn' => 1
  },
  'zha' => {
    'Latn' => 1,
    'Hans' => 2
  },
  'crj' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'kos' => {
    'Latn' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'dsb' => {
    'Latn' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'xum' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'haz' => {
    'Arab' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'mer' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'liv' => {
    'Latn' => 2
  },
  'avk' => {
    'Latn' => 2
  },
  'skr' => {
    'Arab' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'gil' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'sus' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'crh' => {
    'Cyrl' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'wbr' => {
    'Deva' => 1
  },
  'crl' => {
    'Latn' => 2,
    'Cans' => 1
  }
};
$Territory2Lang = {
  'SX' => {
    'nld' => 1,
    'eng' => 1
  },
  'MY' => {
    'eng' => 2,
    'zho' => 2,
    'tam' => 2,
    'msa' => 1
  },
  'SK' => {
    'deu' => 2,
    'eng' => 2,
    'slk' => 1,
    'ces' => 2
  },
  'LI' => {
    'gsw' => 1,
    'deu' => 1
  },
  'BE' => {
    'eng' => 2,
    'deu' => 1,
    'fra' => 1,
    'nld' => 1,
    'vls' => 2
  },
  'IM' => {
    'eng' => 1,
    'glv' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'AR' => {
    'eng' => 2,
    'spa' => 1
  },
  'TO' => {
    'eng' => 1,
    'ton' => 1
  },
  'KG' => {
    'rus' => 1,
    'kir' => 1
  },
  'MK' => {
    'sqi' => 2,
    'mkd' => 1
  },
  'SY' => {
    'fra' => 1,
    'ara' => 1,
    'kur' => 2
  },
  'HN' => {
    'spa' => 1
  },
  'MX' => {
    'spa' => 1,
    'eng' => 2
  },
  'GY' => {
    'eng' => 1
  },
  'BL' => {
    'fra' => 1
  },
  'PH' => {
    'eng' => 1,
    'mdh' => 2,
    'bik' => 2,
    'spa' => 2,
    'fil' => 1,
    'war' => 2,
    'hil' => 2,
    'pam' => 2,
    'bhk' => 2,
    'ilo' => 2,
    'ceb' => 2,
    'tsg' => 2,
    'pag' => 2
  },
  'WF' => {
    'wls' => 2,
    'fud' => 2,
    'fra' => 1
  },
  'PL' => {
    'deu' => 2,
    'eng' => 2,
    'rus' => 2,
    'pol' => 1,
    'lit' => 2,
    'csb' => 2
  },
  'BH' => {
    'ara' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'NA' => {
    'kua' => 2,
    'afr' => 2,
    'eng' => 1,
    'ndo' => 2
  },
  'RO' => {
    'fra' => 2,
    'spa' => 2,
    'ron' => 1,
    'hun' => 2,
    'eng' => 2
  },
  'SD' => {
    'fvr' => 2,
    'ara' => 1,
    'bej' => 2,
    'eng' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'VG' => {
    'eng' => 1
  },
  'CZ' => {
    'ces' => 1,
    'slk' => 2,
    'eng' => 2,
    'deu' => 2
  },
  'DK' => {
    'deu' => 2,
    'eng' => 2,
    'kal' => 2,
    'dan' => 1
  },
  'UG' => {
    'eng' => 1,
    'lug' => 2,
    'teo' => 2,
    'ach' => 2,
    'laj' => 2,
    'myx' => 2,
    'swa' => 1,
    'nyn' => 2,
    'xog' => 2,
    'cgg' => 2
  },
  'PE' => {
    'spa' => 1,
    'que' => 1
  },
  'BQ' => {
    'pap' => 2,
    'nld' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'YT' => {
    'swb' => 2,
    'fra' => 1,
    'buc' => 2
  },
  'LB' => {
    'eng' => 2,
    'ara' => 1
  },
  'IO' => {
    'eng' => 1
  },
  'MD' => {
    'ron' => 1
  },
  'CI' => {
    'fra' => 1,
    'bci' => 2,
    'dnj' => 2,
    'sef' => 2
  },
  'TV' => {
    'tvl' => 1,
    'eng' => 1
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'IQ' => {
    'ckb' => 2,
    'ara' => 1,
    'aze' => 2,
    'kur' => 2,
    'eng' => 2
  },
  'PM' => {
    'fra' => 1
  },
  'NR' => {
    'nau' => 1,
    'eng' => 1
  },
  'MW' => {
    'eng' => 1,
    'tum' => 2,
    'nya' => 1
  },
  'BO' => {
    'que' => 1,
    'aym' => 1,
    'spa' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'RU' => {
    'aze' => 2,
    'rus' => 1,
    'koi' => 2,
    'tyv' => 2,
    'ava' => 2,
    'kom' => 2,
    'mdf' => 2,
    'krc' => 2,
    'ady' => 2,
    'che' => 2,
    'sah' => 2,
    'bak' => 2,
    'kbd' => 2,
    'udm' => 2,
    'hye' => 2,
    'inh' => 2,
    'chv' => 2,
    'kum' => 2,
    'myv' => 2,
    'tat' => 2,
    'lbe' => 2,
    'lez' => 2
  },
  'KY' => {
    'eng' => 1
  },
  'SG' => {
    'tam' => 1,
    'msa' => 1,
    'eng' => 1,
    'zho' => 1
  },
  'GW' => {
    'por' => 1
  },
  'LS' => {
    'eng' => 1,
    'sot' => 1
  },
  'MG' => {
    'fra' => 1,
    'mlg' => 1,
    'eng' => 1
  },
  'PF' => {
    'fra' => 1,
    'tah' => 1
  },
  'LC' => {
    'eng' => 1
  },
  'EE' => {
    'rus' => 2,
    'fin' => 2,
    'est' => 1,
    'eng' => 2
  },
  'CN' => {
    'yue' => 2,
    'gan' => 2,
    'uig' => 2,
    'zho' => 1,
    'zha' => 2,
    'bod' => 2,
    'iii' => 2,
    'hak' => 2,
    'kaz' => 2,
    'kor' => 2,
    'hsn' => 2,
    'mon' => 2,
    'nan' => 2,
    'wuu' => 2
  },
  'FK' => {
    'eng' => 1
  },
  'GT' => {
    'quc' => 2,
    'spa' => 1
  },
  'BF' => {
    'dyu' => 2,
    'mos' => 2,
    'fra' => 1
  },
  'ZA' => {
    'ven' => 2,
    'tso' => 2,
    'hin' => 2,
    'nso' => 2,
    'xho' => 2,
    'tsn' => 2,
    'zul' => 2,
    'nbl' => 2,
    'sot' => 2,
    'afr' => 2,
    'ssw' => 2,
    'eng' => 1
  },
  'BV' => {
    'und' => 2
  },
  'ST' => {
    'por' => 1
  },
  'RE' => {
    'fra' => 1,
    'rcf' => 2
  },
  'IL' => {
    'ara' => 1,
    'heb' => 1,
    'eng' => 2
  },
  'UY' => {
    'spa' => 1
  },
  'CC' => {
    'msa' => 2,
    'eng' => 1
  },
  'MT' => {
    'eng' => 1,
    'ita' => 2,
    'mlt' => 1
  },
  'EH' => {
    'ara' => 1
  },
  'BM' => {
    'eng' => 1
  },
  'DG' => {
    'eng' => 1
  },
  'TH' => {
    'mfa' => 2,
    'kxm' => 2,
    'tha' => 1,
    'msa' => 2,
    'zho' => 2,
    'eng' => 2,
    'nod' => 2,
    'sou' => 2,
    'tts' => 2
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'ZW' => {
    'eng' => 1,
    'nde' => 1,
    'sna' => 1
  },
  'LV' => {
    'rus' => 2,
    'eng' => 2,
    'lav' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'KR' => {
    'kor' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'TJ' => {
    'rus' => 2,
    'tgk' => 1
  },
  'FR' => {
    'oci' => 2,
    'ita' => 2,
    'spa' => 2,
    'eng' => 2,
    'deu' => 2,
    'fra' => 1
  },
  'AW' => {
    'nld' => 1,
    'pap' => 1
  },
  'CP' => {
    'und' => 2
  },
  'JM' => {
    'eng' => 1,
    'jam' => 2
  },
  'CO' => {
    'spa' => 1
  },
  'TZ' => {
    'suk' => 2,
    'eng' => 1,
    'swa' => 1,
    'nym' => 2,
    'kde' => 2
  },
  'MA' => {
    'rif' => 2,
    'tzm' => 1,
    'zgh' => 2,
    'ary' => 2,
    'eng' => 2,
    'fra' => 1,
    'shi' => 2,
    'ara' => 2
  },
  'AT' => {
    'hun' => 2,
    'hrv' => 2,
    'hbs' => 2,
    'eng' => 2,
    'deu' => 1,
    'slv' => 2,
    'bar' => 2
  },
  'JP' => {
    'jpn' => 1
  },
  'CM' => {
    'fra' => 1,
    'eng' => 1,
    'bum' => 2
  },
  'JO' => {
    'ara' => 1,
    'eng' => 2
  },
  'GA' => {
    'fra' => 1
  },
  'CV' => {
    'kea' => 2,
    'por' => 1
  },
  'XK' => {
    'aln' => 2,
    'hbs' => 1,
    'srp' => 1,
    'sqi' => 1
  },
  'PN' => {
    'eng' => 1
  },
  'SA' => {
    'ara' => 1
  },
  'HU' => {
    'eng' => 2,
    'deu' => 2,
    'hun' => 1
  },
  'BS' => {
    'eng' => 1
  },
  'CF' => {
    'fra' => 1,
    'sag' => 1
  },
  'IS' => {
    'isl' => 1
  },
  'MR' => {
    'ara' => 1
  },
  'AX' => {
    'swe' => 1
  },
  'WS' => {
    'smo' => 1,
    'eng' => 1
  },
  'UA' => {
    'pol' => 2,
    'ukr' => 1,
    'rus' => 1
  },
  'LU' => {
    'deu' => 1,
    'eng' => 2,
    'ltz' => 1,
    'fra' => 1
  },
  'CL' => {
    'eng' => 2,
    'spa' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'GR' => {
    'ell' => 1,
    'eng' => 2
  },
  'TN' => {
    'fra' => 1,
    'aeb' => 2,
    'ara' => 1
  },
  'BJ' => {
    'fra' => 1,
    'fon' => 2
  },
  'SR' => {
    'nld' => 1,
    'srn' => 2
  },
  'VA' => {
    'lat' => 2,
    'ita' => 1
  },
  'RS' => {
    'srp' => 1,
    'slk' => 2,
    'hrv' => 2,
    'sqi' => 2,
    'ukr' => 2,
    'hbs' => 1,
    'ron' => 2,
    'hun' => 2
  },
  'NG' => {
    'ibb' => 2,
    'pcm' => 2,
    'bin' => 2,
    'ibo' => 2,
    'eng' => 1,
    'ful' => 2,
    'fuv' => 2,
    'tiv' => 2,
    'hau' => 2,
    'efi' => 2,
    'yor' => 1
  },
  'BB' => {
    'eng' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'ES' => {
    'spa' => 1,
    'cat' => 2,
    'glg' => 2,
    'eng' => 2,
    'ast' => 2,
    'eus' => 2
  },
  'OM' => {
    'ara' => 1
  },
  'HM' => {
    'und' => 2
  },
  'BI' => {
    'eng' => 1,
    'run' => 1,
    'fra' => 1
  },
  'JE' => {
    'eng' => 1
  },
  'EC' => {
    'que' => 1,
    'spa' => 1
  },
  'AD' => {
    'cat' => 1,
    'spa' => 2
  },
  'CH' => {
    'ita' => 1,
    'roh' => 2,
    'fra' => 1,
    'eng' => 2,
    'deu' => 1,
    'gsw' => 1
  },
  'BZ' => {
    'spa' => 2,
    'eng' => 1
  },
  'CU' => {
    'spa' => 1
  },
  'IN' => {
    'kok' => 2,
    'rkt' => 2,
    'hoc' => 2,
    'asm' => 2,
    'sat' => 2,
    'kas' => 2,
    'mal' => 2,
    'mtr' => 2,
    'kru' => 2,
    'mag' => 2,
    'urd' => 2,
    'wbr' => 2,
    'kha' => 2,
    'guj' => 2,
    'wbq' => 2,
    'sck' => 2,
    'tam' => 2,
    'kan' => 2,
    'swv' => 2,
    'raj' => 2,
    'san' => 2,
    'noe' => 2,
    'doi' => 2,
    'mar' => 2,
    'hoj' => 2,
    'khn' => 2,
    'nep' => 2,
    'unr' => 2,
    'gon' => 2,
    'tcy' => 2,
    'mni' => 2,
    'eng' => 1,
    'snd' => 2,
    'ben' => 2,
    'kfy' => 2,
    'tel' => 2,
    'bhb' => 2,
    'bjj' => 2,
    'mwr' => 2,
    'xnr' => 2,
    'bhi' => 2,
    'brx' => 2,
    'awa' => 2,
    'dcc' => 2,
    'gom' => 2,
    'lmn' => 2,
    'hne' => 2,
    'bgc' => 2,
    'pan' => 2,
    'bho' => 2,
    'hin' => 1,
    'ori' => 2,
    'mai' => 2,
    'gbm' => 2,
    'wtm' => 2
  },
  'ER' => {
    'eng' => 1,
    'tig' => 2,
    'tir' => 1,
    'ara' => 1
  },
  'CW' => {
    'nld' => 1,
    'pap' => 1
  },
  'UZ' => {
    'uzb' => 1,
    'rus' => 2
  },
  'LT' => {
    'lit' => 1,
    'eng' => 2,
    'rus' => 2
  },
  'VI' => {
    'eng' => 1
  },
  'SN' => {
    'wol' => 1,
    'fra' => 1,
    'tnr' => 2,
    'knf' => 2,
    'snf' => 2,
    'bsc' => 2,
    'mfv' => 2,
    'mey' => 2,
    'dyo' => 2,
    'srr' => 2,
    'bjt' => 2,
    'sav' => 2,
    'ful' => 2
  },
  'NL' => {
    'eng' => 2,
    'deu' => 2,
    'fry' => 2,
    'nld' => 1,
    'fra' => 2,
    'nds' => 2
  },
  'AO' => {
    'umb' => 2,
    'por' => 1,
    'kmb' => 2
  },
  'TR' => {
    'zza' => 2,
    'tur' => 1,
    'eng' => 2,
    'kur' => 2
  },
  'PA' => {
    'spa' => 1
  },
  'FJ' => {
    'hin' => 2,
    'eng' => 1,
    'hif' => 1,
    'fij' => 1
  },
  'GN' => {
    'fra' => 1,
    'sus' => 2,
    'ful' => 2,
    'man' => 2
  },
  'CG' => {
    'fra' => 1
  },
  'NE' => {
    'fra' => 1,
    'ful' => 2,
    'dje' => 2,
    'fuq' => 2,
    'hau' => 2,
    'tmh' => 2
  },
  'HK' => {
    'eng' => 1,
    'zho' => 1,
    'yue' => 2
  },
  'MN' => {
    'mon' => 1
  },
  'IR' => {
    'bal' => 2,
    'luz' => 2,
    'mzn' => 2,
    'tuk' => 2,
    'rmt' => 2,
    'glk' => 2,
    'bqi' => 2,
    'sdh' => 2,
    'kur' => 2,
    'ara' => 2,
    'ckb' => 2,
    'lrc' => 2,
    'aze' => 2,
    'fas' => 1
  },
  'MS' => {
    'eng' => 1
  },
  'AF' => {
    'bal' => 2,
    'uzb' => 2,
    'tuk' => 2,
    'haz' => 2,
    'fas' => 1,
    'pus' => 1
  },
  'KZ' => {
    'rus' => 1,
    'kaz' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'ZM' => {
    'bem' => 2,
    'eng' => 1,
    'nya' => 2
  },
  'MC' => {
    'fra' => 1
  },
  'GS' => {
    'und' => 2
  },
  'FI' => {
    'eng' => 2,
    'swe' => 1,
    'fin' => 1
  },
  'SS' => {
    'ara' => 2,
    'eng' => 1
  },
  'KI' => {
    'gil' => 1,
    'eng' => 1
  },
  'BA' => {
    'hrv' => 1,
    'eng' => 2,
    'hbs' => 1,
    'bos' => 1,
    'srp' => 1
  },
  'NU' => {
    'eng' => 1,
    'niu' => 1
  },
  'SC' => {
    'eng' => 1,
    'crs' => 2,
    'fra' => 1
  },
  'AM' => {
    'hye' => 1
  },
  'QA' => {
    'ara' => 1
  },
  'CY' => {
    'eng' => 2,
    'ell' => 1,
    'tur' => 1
  },
  'US' => {
    'vie' => 2,
    'fil' => 2,
    'spa' => 2,
    'ita' => 2,
    'zho' => 2,
    'kor' => 2,
    'deu' => 2,
    'eng' => 1,
    'fra' => 2,
    'haw' => 2
  },
  'DZ' => {
    'fra' => 1,
    'kab' => 2,
    'arq' => 2,
    'ara' => 2,
    'eng' => 2
  },
  'AE' => {
    'eng' => 2,
    'ara' => 1
  },
  'CK' => {
    'eng' => 1
  },
  'KN' => {
    'eng' => 1
  },
  'BR' => {
    'eng' => 2,
    'deu' => 2,
    'por' => 1
  },
  'CX' => {
    'eng' => 1
  },
  'SJ' => {
    'nob' => 1,
    'rus' => 2,
    'nor' => 1
  },
  'GB' => {
    'sco' => 2,
    'gle' => 2,
    'eng' => 1,
    'deu' => 2,
    'gla' => 2,
    'fra' => 2,
    'cym' => 2
  },
  'NO' => {
    'sme' => 2,
    'nor' => 1,
    'nno' => 1,
    'nob' => 1
  },
  'VC' => {
    'eng' => 1
  },
  'AL' => {
    'sqi' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'NP' => {
    'mai' => 2,
    'nep' => 1,
    'bho' => 2
  },
  'EA' => {
    'spa' => 1
  },
  'DJ' => {
    'ara' => 1,
    'som' => 2,
    'fra' => 1,
    'aar' => 2
  },
  'LK' => {
    'eng' => 2,
    'tam' => 1,
    'sin' => 1
  },
  'SI' => {
    'slv' => 1,
    'hbs' => 2,
    'deu' => 2,
    'eng' => 2,
    'hrv' => 2
  },
  'VN' => {
    'zho' => 2,
    'vie' => 1
  },
  'PR' => {
    'eng' => 1,
    'spa' => 1
  },
  'GI' => {
    'eng' => 1,
    'spa' => 2
  },
  'TA' => {
    'eng' => 2
  },
  'AU' => {
    'eng' => 1
  },
  'MZ' => {
    'mgh' => 2,
    'ndc' => 2,
    'por' => 1,
    'ngl' => 2,
    'vmw' => 2,
    'tso' => 2,
    'seh' => 2
  },
  'AQ' => {
    'und' => 2
  },
  'LY' => {
    'ara' => 1
  },
  'NF' => {
    'eng' => 1
  },
  'SZ' => {
    'ssw' => 1,
    'eng' => 1
  },
  'HT' => {
    'fra' => 1,
    'hat' => 1
  },
  'CD' => {
    'kon' => 2,
    'fra' => 1,
    'lub' => 2,
    'lin' => 2,
    'lua' => 2,
    'swa' => 2
  },
  'CR' => {
    'spa' => 1
  },
  'UM' => {
    'eng' => 1
  },
  'TW' => {
    'zho' => 1
  },
  'SE' => {
    'swe' => 1,
    'eng' => 2,
    'fin' => 2
  },
  'ML' => {
    'fra' => 1,
    'bam' => 2,
    'ffm' => 2,
    'ful' => 2,
    'snk' => 2
  },
  'GE' => {
    'kat' => 1,
    'abk' => 2,
    'oss' => 2
  },
  'BY' => {
    'rus' => 1,
    'bel' => 1
  },
  'KP' => {
    'kor' => 1
  },
  'IT' => {
    'eng' => 2,
    'ita' => 1,
    'srd' => 2,
    'fra' => 2
  },
  'FO' => {
    'fao' => 1
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'SL' => {
    'tem' => 2,
    'eng' => 1,
    'kri' => 2,
    'men' => 2
  },
  'EG' => {
    'eng' => 2,
    'ara' => 2,
    'arz' => 2
  },
  'ME' => {
    'hbs' => 1,
    'srp' => 1
  },
  'GL' => {
    'kal' => 1
  },
  'FM' => {
    'pon' => 2,
    'chk' => 2,
    'eng' => 1
  },
  'MQ' => {
    'fra' => 1
  },
  'SH' => {
    'eng' => 1
  },
  'KM' => {
    'zdj' => 1,
    'wni' => 1,
    'ara' => 1,
    'fra' => 1
  },
  'GH' => {
    'abr' => 2,
    'gaa' => 2,
    'eng' => 1,
    'aka' => 2,
    'ewe' => 2
  },
  'NC' => {
    'fra' => 1
  },
  'BD' => {
    'ben' => 1,
    'eng' => 2,
    'syl' => 2,
    'rkt' => 2
  },
  'PY' => {
    'spa' => 1,
    'grn' => 1
  },
  'AI' => {
    'eng' => 1
  },
  'GU' => {
    'eng' => 1,
    'cha' => 1
  },
  'ET' => {
    'aar' => 2,
    'eng' => 2,
    'amh' => 1,
    'orm' => 2,
    'wal' => 2,
    'sid' => 2,
    'som' => 2,
    'tir' => 2
  },
  'RW' => {
    'eng' => 1,
    'kin' => 1,
    'fra' => 1
  },
  'GQ' => {
    'por' => 1,
    'fra' => 1,
    'spa' => 1,
    'fan' => 2
  },
  'LR' => {
    'eng' => 1
  },
  'MH' => {
    'mah' => 1,
    'eng' => 1
  },
  'MU' => {
    'eng' => 1,
    'mfe' => 2,
    'bho' => 2,
    'fra' => 1
  },
  'AZ' => {
    'aze' => 1
  },
  'PK' => {
    'hno' => 2,
    'snd' => 2,
    'skr' => 2,
    'eng' => 1,
    'fas' => 2,
    'pus' => 2,
    'bgn' => 2,
    'bal' => 2,
    'pan' => 2,
    'urd' => 1,
    'lah' => 2,
    'brh' => 2
  },
  'TT' => {
    'eng' => 1
  },
  'DE' => {
    'bar' => 2,
    'eng' => 2,
    'nds' => 2,
    'nld' => 2,
    'gsw' => 2,
    'spa' => 2,
    'ita' => 2,
    'vmf' => 2,
    'deu' => 1,
    'fra' => 2,
    'tur' => 2,
    'rus' => 2,
    'dan' => 2
  },
  'GP' => {
    'fra' => 1
  },
  'SO' => {
    'ara' => 1,
    'som' => 1
  },
  'VU' => {
    'fra' => 1,
    'bis' => 1,
    'eng' => 1
  },
  'HR' => {
    'hrv' => 1,
    'ita' => 2,
    'eng' => 2,
    'hbs' => 1
  },
  'BG' => {
    'bul' => 1,
    'rus' => 2,
    'eng' => 2
  },
  'DM' => {
    'eng' => 1
  },
  'BW' => {
    'tsn' => 1,
    'eng' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'KE' => {
    'swa' => 1,
    'mer' => 2,
    'luo' => 2,
    'guz' => 2,
    'kln' => 2,
    'eng' => 1,
    'kam' => 2,
    'luy' => 2,
    'kik' => 2
  },
  'YE' => {
    'ara' => 1,
    'eng' => 2
  },
  'MP' => {
    'eng' => 1
  },
  'TK' => {
    'tkl' => 1,
    'eng' => 1
  },
  'MO' => {
    'zho' => 1,
    'por' => 1
  },
  'ID' => {
    'ace' => 2,
    'gor' => 2,
    'mak' => 2,
    'zho' => 2,
    'bbc' => 2,
    'sun' => 2,
    'ind' => 1,
    'rej' => 2,
    'ban' => 2,
    'min' => 2,
    'bew' => 2,
    'bjn' => 2,
    'sas' => 2,
    'bug' => 2,
    'msa' => 2,
    'jav' => 2,
    'mad' => 2,
    'ljp' => 2
  },
  'PT' => {
    'fra' => 2,
    'spa' => 2,
    'eng' => 2,
    'por' => 1
  },
  'CA' => {
    'eng' => 1,
    'ikt' => 2,
    'iku' => 2,
    'fra' => 1
  },
  'GF' => {
    'fra' => 1,
    'gcr' => 2
  },
  'BT' => {
    'dzo' => 1
  },
  'SV' => {
    'spa' => 1
  },
  'PW' => {
    'pau' => 1,
    'eng' => 1
  },
  'VE' => {
    'spa' => 1
  },
  'NZ' => {
    'eng' => 1,
    'mri' => 1
  },
  'MM' => {
    'mya' => 1,
    'shn' => 2
  },
  'AS' => {
    'smo' => 1,
    'eng' => 1
  },
  'MV' => {
    'div' => 1
  },
  'TD' => {
    'fra' => 1,
    'ara' => 1
  },
  'PG' => {
    'eng' => 1,
    'hmo' => 1,
    'tpi' => 1
  },
  'MF' => {
    'fra' => 1
  },
  'SM' => {
    'ita' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'KH' => {
    'khm' => 1
  },
  'DO' => {
    'spa' => 1
  },
  'GM' => {
    'eng' => 1,
    'man' => 2
  },
  'AC' => {
    'eng' => 2
  }
};
$Script2Lang = {
  'Cans' => {
    'crk' => 1,
    'chp' => 2,
    'csw' => 1,
    'nsk' => 1,
    'crj' => 1,
    'crm' => 1,
    'crl' => 1,
    'oji' => 1,
    'cre' => 1,
    'iku' => 1,
    'den' => 2
  },
  'Orkh' => {
    'otk' => 2
  },
  'Ugar' => {
    'uga' => 2
  },
  'Dupl' => {
    'fra' => 2
  },
  'Khoj' => {
    'snd' => 2
  },
  'Sylo' => {
    'syl' => 2
  },
  'Mong' => {
    'mnc' => 2,
    'mon' => 2
  },
  'Wara' => {
    'hoc' => 2
  },
  'Tale' => {
    'tdd' => 1
  },
  'Knda' => {
    'kan' => 1,
    'tcy' => 1
  },
  'Ethi' => {
    'byn' => 1,
    'tir' => 1,
    'gez' => 2,
    'wal' => 1,
    'amh' => 1,
    'tig' => 1,
    'orm' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Osma' => {
    'som' => 2
  },
  'Phnx' => {
    'phn' => 2
  },
  'Hebr' => {
    'jpr' => 1,
    'yid' => 1,
    'heb' => 1,
    'jrb' => 1,
    'sam' => 2,
    'lad' => 1
  },
  'Mroo' => {
    'mro' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Mtei' => {
    'mni' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Buhd' => {
    'bku' => 2
  },
  'Samr' => {
    'smp' => 2,
    'sam' => 2
  },
  'Batk' => {
    'bbc' => 2
  },
  'Armn' => {
    'hye' => 1
  },
  'Ital' => {
    'osc' => 2,
    'xum' => 2,
    'ett' => 2
  },
  'Lepc' => {
    'lep' => 1
  },
  'Avst' => {
    'ave' => 2
  },
  'Guru' => {
    'pan' => 1
  },
  'Phag' => {
    'zho' => 2,
    'mon' => 2
  },
  'Plrd' => {
    'hmd' => 1,
    'hmn' => 1
  },
  'Thai' => {
    'lwl' => 1,
    'pli' => 2,
    'lcp' => 1,
    'tts' => 1,
    'sou' => 1,
    'tha' => 1,
    'kdt' => 1,
    'kxm' => 1
  },
  'Palm' => {
    'arc' => 2
  },
  'Yiii' => {
    'iii' => 1
  },
  'Hans' => {
    'hak' => 1,
    'yue' => 1,
    'zho' => 1,
    'lzh' => 2,
    'gan' => 1,
    'nan' => 1,
    'zha' => 2,
    'hsn' => 1,
    'wuu' => 1
  },
  'Tfng' => {
    'tzm' => 1,
    'rif' => 1,
    'zgh' => 1,
    'shi' => 1,
    'zen' => 2
  },
  'Prti' => {
    'xpr' => 2
  },
  'Bugi' => {
    'mdr' => 2,
    'mak' => 2,
    'bug' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Olck' => {
    'sat' => 1
  },
  'Mend' => {
    'men' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Cyrl' => {
    'ttt' => 1,
    'udm' => 1,
    'tkr' => 1,
    'kca' => 1,
    'ude' => 1,
    'abk' => 1,
    'tuk' => 1,
    'myv' => 1,
    'srp' => 1,
    'aze' => 1,
    'ava' => 1,
    'sme' => 2,
    'oss' => 1,
    'kom' => 1,
    'krc' => 1,
    'uzb' => 1,
    'crh' => 1,
    'gag' => 2,
    'kaa' => 1,
    'kum' => 1,
    'tat' => 1,
    'lez' => 1,
    'bel' => 1,
    'bul' => 1,
    'koi' => 1,
    'evn' => 1,
    'yrk' => 1,
    'aii' => 1,
    'ukr' => 1,
    'che' => 1,
    'tab' => 1,
    'gld' => 1,
    'kjh' => 1,
    'chm' => 1,
    'alt' => 1,
    'uig' => 1,
    'bua' => 1,
    'kur' => 1,
    'rom' => 2,
    'chv' => 1,
    'lbe' => 1,
    'bos' => 1,
    'kpy' => 1,
    'hbs' => 1,
    'tgk' => 1,
    'tly' => 1,
    'kaz' => 1,
    'cjs' => 1,
    'syr' => 1,
    'ady' => 1,
    'sah' => 1,
    'bak' => 1,
    'kbd' => 1,
    'ron' => 2,
    'pnt' => 1,
    'inh' => 1,
    'chu' => 2,
    'dng' => 1,
    'mns' => 1,
    'sel' => 2,
    'kir' => 1,
    'rus' => 1,
    'tyv' => 1,
    'nog' => 1,
    'ckt' => 1,
    'lfn' => 2,
    'mon' => 1,
    'abq' => 1,
    'xal' => 1,
    'mdf' => 1,
    'dar' => 1,
    'mkd' => 1,
    'rue' => 1,
    'mrj' => 1
  },
  'Gran' => {
    'san' => 2
  },
  'Mlym' => {
    'mal' => 1
  },
  'Deva' => {
    'bfy' => 1,
    'bap' => 1,
    'kok' => 1,
    'mag' => 1,
    'kru' => 1,
    'btv' => 1,
    'mtr' => 1,
    'sat' => 2,
    'kas' => 1,
    'hoc' => 1,
    'sck' => 1,
    'bra' => 1,
    'gvr' => 1,
    'rjs' => 1,
    'wbr' => 1,
    'khn' => 1,
    'hoj' => 1,
    'mar' => 1,
    'doi' => 1,
    'noe' => 1,
    'srx' => 1,
    'new' => 1,
    'swv' => 1,
    'san' => 2,
    'raj' => 1,
    'jml' => 1,
    'pli' => 2,
    'thr' => 1,
    'snd' => 1,
    'thq' => 1,
    'xsr' => 1,
    'gon' => 1,
    'unr' => 1,
    'nep' => 1,
    'unx' => 1,
    'bjj' => 1,
    'bhb' => 1,
    'taj' => 1,
    'kfy' => 1,
    'gom' => 1,
    'tkt' => 1,
    'awa' => 1,
    'brx' => 1,
    'thl' => 1,
    'mrd' => 1,
    'bhi' => 1,
    'hif' => 1,
    'xnr' => 1,
    'mwr' => 1,
    'wtm' => 1,
    'tdh' => 1,
    'dty' => 1,
    'tdg' => 1,
    'anp' => 1,
    'mai' => 1,
    'gbm' => 1,
    'kfr' => 1,
    'bho' => 1,
    'hin' => 1,
    'lif' => 1,
    'mgp' => 1,
    'bgc' => 1,
    'hne' => 1
  },
  'Bamu' => {
    'bax' => 1
  },
  'Bali' => {
    'ban' => 2
  },
  'Takr' => {
    'doi' => 2
  },
  'Hant' => {
    'zho' => 1,
    'yue' => 1
  },
  'Gujr' => {
    'guj' => 1
  },
  'Sind' => {
    'snd' => 2
  },
  'Kana' => {
    'ain' => 2,
    'ryu' => 1
  },
  'Aghb' => {
    'lez' => 2
  },
  'Xsux' => {
    'akk' => 2,
    'hit' => 2
  },
  'Egyp' => {
    'egy' => 2
  },
  'Cher' => {
    'chr' => 1
  },
  'Grek' => {
    'pnt' => 1,
    'grc' => 2,
    'bgx' => 1,
    'cop' => 2,
    'tsd' => 1,
    'ell' => 1
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Tavt' => {
    'blt' => 1
  },
  'Phlp' => {
    'pal' => 2
  },
  'Talu' => {
    'khb' => 1
  },
  'Narb' => {
    'xna' => 2
  },
  'Sora' => {
    'srb' => 2
  },
  'Tibt' => {
    'tdg' => 2,
    'bft' => 2,
    'taj' => 2,
    'dzo' => 1,
    'bod' => 1,
    'tsj' => 1
  },
  'Nkoo' => {
    'man' => 1,
    'bam' => 1,
    'nqo' => 1
  },
  'Lydi' => {
    'xld' => 2
  },
  'Java' => {
    'jav' => 2
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Orya' => {
    'ori' => 1,
    'sat' => 2
  },
  'Hani' => {
    'vie' => 2
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Mani' => {
    'xmn' => 2
  },
  'Taml' => {
    'tam' => 1,
    'bfq' => 1
  },
  'Mymr' => {
    'mya' => 1,
    'mnw' => 1,
    'shn' => 1,
    'kht' => 1
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Bopo' => {
    'zho' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Beng' => {
    'bpy' => 1,
    'kha' => 2,
    'unr' => 1,
    'mni' => 1,
    'lus' => 1,
    'rkt' => 1,
    'ben' => 1,
    'grt' => 1,
    'sat' => 2,
    'asm' => 1,
    'syl' => 1,
    'unx' => 1,
    'ccp' => 1
  },
  'Sidd' => {
    'san' => 2
  },
  'Arab' => {
    'gjk' => 1,
    'uzb' => 1,
    'som' => 2,
    'lah' => 1,
    'ary' => 1,
    'hau' => 1,
    'kas' => 1,
    'arz' => 1,
    'wol' => 2,
    'aze' => 1,
    'hnd' => 1,
    'tuk' => 1,
    'dyo' => 2,
    'bal' => 1,
    'bej' => 1,
    'ttt' => 2,
    'bgn' => 1,
    'haz' => 1,
    'arq' => 1,
    'mvy' => 1,
    'kxp' => 1,
    'raj' => 1,
    'shi' => 1,
    'lki' => 1,
    'gbz' => 1,
    'zdj' => 1,
    'skr' => 1,
    'doi' => 1,
    'aeb' => 1,
    'khw' => 1,
    'urd' => 1,
    'luz' => 1,
    'sus' => 2,
    'ars' => 1,
    'brh' => 1,
    'lrc' => 1,
    'cjm' => 2,
    'fas' => 1,
    'tly' => 1,
    'gju' => 1,
    'tgk' => 1,
    'swb' => 1,
    'kaz' => 1,
    'rmt' => 1,
    'kvx' => 1,
    'wni' => 1,
    'bft' => 1,
    'ind' => 2,
    'glk' => 1,
    'uig' => 1,
    'kur' => 1,
    'snd' => 1,
    'hno' => 1,
    'sdh' => 1,
    'msa' => 1,
    'fia' => 1,
    'cop' => 2,
    'pan' => 1,
    'tur' => 2,
    'mzn' => 1,
    'mfa' => 1,
    'kir' => 1,
    'ckb' => 1,
    'ara' => 1,
    'cja' => 1,
    'prd' => 1,
    'pus' => 1,
    'inh' => 2,
    'dcc' => 1,
    'bqi' => 1
  },
  'Geor' => {
    'xmf' => 1,
    'lzz' => 1,
    'kat' => 1
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Kore' => {
    'kor' => 1
  },
  'Shrd' => {
    'san' => 2
  },
  'Laoo' => {
    'hmn' => 1,
    'hnj' => 1,
    'kjg' => 1,
    'lao' => 1
  },
  'Armi' => {
    'arc' => 2
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Mahj' => {
    'hin' => 2
  },
  'Telu' => {
    'lmn' => 1,
    'tel' => 1,
    'gon' => 1,
    'wbq' => 1
  },
  'Sund' => {
    'sun' => 2
  },
  'Lina' => {
    'lab' => 2
  },
  'Tglg' => {
    'fil' => 2
  },
  'Shaw' => {
    'eng' => 2
  },
  'Copt' => {
    'cop' => 2
  },
  'Osge' => {
    'osa' => 1
  },
  'Modi' => {
    'mar' => 2
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Phli' => {
    'pal' => 2
  },
  'Cham' => {
    'cja' => 2,
    'cjm' => 1
  },
  'Latn' => {
    'aro' => 1,
    'kaj' => 1,
    'mls' => 1,
    'dyu' => 1,
    'inh' => 2,
    'min' => 1,
    'ach' => 1,
    'seh' => 1,
    'maf' => 1,
    'ron' => 1,
    'ang' => 2,
    'ven' => 1,
    'swa' => 1,
    'pcm' => 1,
    'mgh' => 1,
    'pon' => 1,
    'lub' => 1,
    'ter' => 1,
    'khq' => 1,
    'hsb' => 1,
    'men' => 1,
    'eng' => 1,
    'gba' => 1,
    'que' => 1,
    'lim' => 1,
    'lua' => 1,
    'jgo' => 1,
    'nij' => 1,
    'nch' => 1,
    'mfe' => 1,
    'vls' => 1,
    'gle' => 1,
    'bis' => 1,
    'swb' => 2,
    'tgk' => 1,
    'cor' => 1,
    'bze' => 1,
    'kal' => 1,
    'est' => 1,
    'mri' => 1,
    'iii' => 2,
    'bbj' => 1,
    'kao' => 1,
    'bar' => 1,
    'vol' => 2,
    'gmh' => 2,
    'lij' => 1,
    'kjg' => 2,
    'tzm' => 1,
    'sqi' => 1,
    'rng' => 1,
    'pro' => 2,
    'mad' => 1,
    'gor' => 1,
    'rgn' => 1,
    'srp' => 1,
    'mdh' => 1,
    'tso' => 1,
    'sco' => 1,
    'nhw' => 1,
    'myx' => 1,
    'tpi' => 1,
    'mgo' => 1,
    'rej' => 1,
    'hau' => 1,
    'moh' => 1,
    'rmu' => 1,
    'ast' => 1,
    'tet' => 1,
    'kam' => 1,
    'ife' => 1,
    'quc' => 1,
    'arp' => 1,
    'hrv' => 1,
    'mlt' => 1,
    'del' => 1,
    'gos' => 1,
    'abr' => 1,
    'chp' => 1,
    'hmo' => 1,
    'lfn' => 2,
    'man' => 1,
    'aka' => 1,
    'rof' => 1,
    'nap' => 1,
    'haw' => 1,
    'eka' => 1,
    'ssy' => 1,
    'lui' => 2,
    'sga' => 2,
    'bla' => 1,
    'vai' => 1,
    'mwl' => 1,
    'lun' => 1,
    'kac' => 1,
    'bas' => 1,
    'bku' => 1,
    'slv' => 1,
    'zea' => 1,
    'rob' => 1,
    'moe' => 1,
    'pam' => 1,
    'lam' => 1,
    'run' => 1,
    'see' => 1,
    'ace' => 1,
    'zul' => 1,
    'laj' => 1,
    'lug' => 1,
    'nob' => 1,
    'osa' => 2,
    'ada' => 1,
    'gur' => 1,
    'slk' => 1,
    'bqv' => 1,
    'csb' => 2,
    'krj' => 1,
    'tli' => 1,
    'cos' => 1,
    'ltg' => 1,
    'rug' => 1,
    'kon' => 1,
    'fur' => 1,
    'krl' => 1,
    'tuk' => 1,
    'bbc' => 1,
    'rap' => 1,
    'swg' => 1,
    'cho' => 1,
    'sun' => 1,
    'dua' => 1,
    'zag' => 1,
    'uzb' => 1,
    'efi' => 1,
    'sna' => 1,
    'kua' => 1,
    'pap' => 1,
    'twq' => 1,
    'cym' => 1,
    'lin' => 1,
    'frr' => 1,
    'tmh' => 1,
    'ewe' => 1,
    'srn' => 1,
    'yrl' => 1,
    'mxc' => 1,
    'gla' => 1,
    'sly' => 1,
    'lbw' => 1,
    'tsg' => 1,
    'esu' => 1,
    'arn' => 1,
    'sad' => 1,
    'cay' => 1,
    'dtp' => 1,
    'yua' => 1,
    'kge' => 1,
    'wln' => 1,
    'hat' => 1,
    'bos' => 1,
    'swe' => 1,
    'rom' => 1,
    'xav' => 1,
    'fit' => 1,
    'aoz' => 1,
    'prg' => 2,
    'nnh' => 1,
    'bew' => 1,
    'tiv' => 1,
    'mua' => 1,
    'dum' => 2,
    'kfo' => 1,
    'saf' => 1,
    'gay' => 1,
    'pko' => 1,
    'gcr' => 1,
    'tru' => 1,
    'dtm' => 1,
    'dan' => 1,
    'mro' => 1,
    'war' => 1,
    'ain' => 2,
    'nsk' => 2,
    'nno' => 1,
    'enm' => 2,
    'trv' => 1,
    'xho' => 1,
    'cha' => 1,
    'kde' => 1,
    'ipk' => 1,
    'ita' => 1,
    'vro' => 1,
    'akz' => 1,
    'sei' => 1,
    'tkr' => 1,
    'wbp' => 1,
    'roh' => 1,
    'tsn' => 1,
    'scn' => 1,
    'pol' => 1,
    'tsi' => 1,
    'loz' => 1,
    'som' => 1,
    'lol' => 1,
    'kea' => 1,
    'fvr' => 1,
    'arg' => 1,
    'ngl' => 1,
    'egl' => 1,
    'ndo' => 1,
    'vep' => 1,
    'rtm' => 1,
    'rif' => 1,
    'njo' => 1,
    'sid' => 1,
    'hmn' => 1,
    'kri' => 1,
    'crs' => 1,
    'ria' => 1,
    'ndc' => 1,
    'kcg' => 1,
    'vie' => 1,
    'vun' => 1,
    'dje' => 1,
    'ljp' => 1,
    'ebu' => 1,
    'tur' => 1,
    'fry' => 1,
    'bik' => 1,
    'yao' => 1,
    'osc' => 2,
    'ind' => 1,
    'zun' => 1,
    'car' => 1,
    'sag' => 1,
    'vmw' => 1,
    'pms' => 1,
    'atj' => 1,
    'rcf' => 1,
    'sdc' => 1,
    'dnj' => 1,
    'sxn' => 1,
    'was' => 1,
    'ewo' => 1,
    'luo' => 1,
    'srb' => 1,
    'nde' => 1,
    'din' => 1,
    'vic' => 1,
    'kin' => 1,
    'kkj' => 1,
    'srd' => 1,
    'rup' => 1,
    'cat' => 1,
    'yap' => 1,
    'ltz' => 1,
    'kgp' => 1,
    'ssw' => 1,
    'fuq' => 1,
    'uli' => 1,
    'kab' => 1,
    'frs' => 1,
    'qug' => 1,
    'ces' => 1,
    'den' => 1,
    'vec' => 1,
    'jam' => 1,
    'umb' => 1,
    'ttt' => 1,
    'ina' => 2,
    'maz' => 1,
    'mic' => 1,
    'pag' => 1,
    'glg' => 1,
    'sms' => 1,
    'pcd' => 1,
    'lag' => 1,
    'pdc' => 1,
    'zap' => 1,
    'her' => 1,
    'sef' => 1,
    'mah' => 1,
    'chn' => 2,
    'nia' => 1,
    'fuv' => 1,
    'pfl' => 1,
    'cre' => 2,
    'nau' => 1,
    'lut' => 2,
    'arw' => 2,
    'afr' => 1,
    'fao' => 1,
    'sgs' => 1,
    'saq' => 1,
    'mwv' => 1,
    'deu' => 1,
    'bin' => 1,
    'cic' => 1,
    'ttj' => 1,
    'oji' => 2,
    'nav' => 1,
    'bci' => 1,
    'wae' => 1,
    'naq' => 1,
    'kiu' => 1,
    'frc' => 1,
    'vmf' => 1,
    'hbs' => 1,
    'hnn' => 1,
    'nyo' => 1,
    'asa' => 1,
    'mlg' => 1,
    'chk' => 1,
    'aym' => 1,
    'lav' => 1,
    'glv' => 1,
    'nds' => 1,
    'buc' => 1,
    'kck' => 1,
    'ibo' => 1,
    'nxq' => 1,
    'pau' => 1,
    'bkm' => 1,
    'dgr' => 1,
    'tum' => 1,
    'gwi' => 1,
    'sme' => 1,
    'kik' => 1,
    'mwk' => 1,
    'hil' => 1,
    'nym' => 1,
    'ett' => 2,
    'zha' => 1,
    'smj' => 1,
    'lmo' => 1,
    'dav' => 1,
    'pnt' => 1,
    'ban' => 1,
    'rmo' => 1,
    'niu' => 1,
    'fon' => 1,
    'zmi' => 1,
    'bvb' => 1,
    'bum' => 1,
    'ctd' => 1,
    'kau' => 1,
    'gub' => 1,
    'kur' => 1,
    'pdt' => 1,
    'izh' => 1,
    'frp' => 1,
    'isl' => 1,
    'orm' => 1,
    'bto' => 1,
    'cch' => 1,
    'mas' => 1,
    'tly' => 1,
    'hun' => 1,
    'nor' => 1,
    'crl' => 2,
    'smo' => 1,
    'tkl' => 1,
    'luy' => 1,
    'kut' => 1,
    'sus' => 1,
    'ksf' => 1,
    'gil' => 1,
    'fro' => 2,
    'nhe' => 1,
    'por' => 1,
    'fij' => 1,
    'avk' => 2,
    'ale' => 1,
    'liv' => 2,
    'amo' => 1,
    'mer' => 1,
    'dyo' => 1,
    'tbw' => 1,
    'fud' => 1,
    'fil' => 1,
    'iku' => 1,
    'nzi' => 1,
    'eus' => 1,
    'dak' => 1,
    'nus' => 1,
    'xum' => 2,
    'epo' => 1,
    'frm' => 2,
    'ksb' => 1,
    'kpe' => 1,
    'dsb' => 1,
    'cgg' => 1,
    'lkt' => 1,
    'kos' => 1,
    'sot' => 1,
    'crj' => 2,
    'kir' => 1,
    'nbl' => 1,
    'wls' => 1,
    'tah' => 1,
    'aar' => 1,
    'rmf' => 1,
    'xog' => 1,
    'msa' => 1,
    'zza' => 1,
    'hin' => 2,
    'mgy' => 1,
    'jav' => 1,
    'bem' => 1,
    'fan' => 1,
    'sbp' => 1,
    'gsw' => 1,
    'ksh' => 1,
    'mak' => 1,
    'mos' => 1,
    'lat' => 2,
    'ffm' => 1,
    'brh' => 2,
    'stq' => 1,
    'kvr' => 1,
    'ext' => 1,
    'jmc' => 1,
    'spa' => 1,
    'grb' => 1,
    'rar' => 1,
    'kha' => 1,
    'bmq' => 1,
    'gag' => 1,
    'bfd' => 1,
    'ses' => 1,
    'ful' => 1,
    'sma' => 1,
    'scs' => 1,
    'suk' => 1,
    'nyn' => 1,
    'cps' => 1,
    'jut' => 2,
    'bez' => 1,
    'fra' => 1,
    'shi' => 1,
    'puu' => 1,
    'yav' => 1,
    'rwk' => 1,
    'hop' => 1,
    'sli' => 1,
    'syi' => 1,
    'sat' => 2,
    'aln' => 1,
    'ilo' => 1,
    'ceb' => 1,
    'guz' => 1,
    'aze' => 1,
    'wol' => 1,
    'hai' => 1,
    'hif' => 1,
    'mus' => 1,
    'vot' => 2,
    'fin' => 1,
    'tog' => 1,
    'nld' => 1,
    'ybb' => 1,
    'nmg' => 1,
    'chy' => 1,
    'szl' => 1,
    'lit' => 1,
    'mdt' => 1,
    'bam' => 1,
    'tvl' => 1,
    'nov' => 2,
    'uig' => 2,
    'cad' => 1,
    'gaa' => 1,
    'bss' => 1,
    'ikt' => 1,
    'goh' => 2,
    'mdr' => 1,
    'srr' => 1,
    'bzx' => 1,
    'teo' => 1,
    'nya' => 1,
    'bug' => 1,
    'snk' => 1,
    'iba' => 1,
    'hup' => 1,
    'smn' => 1,
    'bal' => 2,
    'oci' => 1,
    'kmb' => 1,
    'lzz' => 1,
    'guc' => 1,
    'ton' => 1,
    'bjn' => 1,
    'kln' => 1,
    'agq' => 1,
    'udm' => 2,
    'grn' => 1,
    'byv' => 1,
    'tem' => 1,
    'sas' => 1,
    'yor' => 1,
    'nso' => 1,
    'ibb' => 1,
    'bre' => 1
  },
  'Hano' => {
    'hnn' => 2
  },
  'Linb' => {
    'grc' => 2
  },
  'Runr' => {
    'non' => 2,
    'deu' => 2
  },
  'Syrc' => {
    'ara' => 2,
    'syr' => 2,
    'tru' => 2,
    'aii' => 2
  },
  'Cprt' => {
    'grc' => 2
  },
  'Mand' => {
    'myz' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Nbat' => {
    'arc' => 2
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Vaii' => {
    'vai' => 1
  },
  'Sinh' => {
    'sin' => 1,
    'pli' => 2,
    'san' => 2
  },
  'Ogam' => {
    'sga' => 2
  },
  'Tirh' => {
    'mai' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Limb' => {
    'lif' => 1
  },
  'Khmr' => {
    'khm' => 1
  },
  'Thaa' => {
    'div' => 1
  }
};
$DefaultScript = {
  'pcm' => 'Latn',
  'nog' => 'Cyrl',
  'ckt' => 'Cyrl',
  'mgh' => 'Latn',
  'khq' => 'Latn',
  'ter' => 'Latn',
  'pon' => 'Latn',
  'lub' => 'Latn',
  'zgh' => 'Tfng',
  'kxm' => 'Thai',
  'mgp' => 'Deva',
  'crk' => 'Cans',
  'swa' => 'Latn',
  'ven' => 'Latn',
  'brx' => 'Deva',
  'inh' => 'Cyrl',
  'awa' => 'Deva',
  'dcc' => 'Arab',
  'maf' => 'Latn',
  'seh' => 'Latn',
  'ron' => 'Latn',
  'min' => 'Latn',
  'ach' => 'Latn',
  'jpr' => 'Hebr',
  'kyu' => 'Kali',
  'aro' => 'Latn',
  'bhi' => 'Deva',
  'kaj' => 'Latn',
  'dyu' => 'Latn',
  'mls' => 'Latn',
  'swb' => 'Arab',
  'gle' => 'Latn',
  'bis' => 'Latn',
  'bze' => 'Latn',
  'kal' => 'Latn',
  'hak' => 'Hans',
  'cor' => 'Latn',
  'nij' => 'Latn',
  'lua' => 'Latn',
  'jgo' => 'Latn',
  'nch' => 'Latn',
  'mfe' => 'Latn',
  'cjs' => 'Cyrl',
  'vls' => 'Latn',
  'tir' => 'Ethi',
  'eng' => 'Latn',
  'que' => 'Latn',
  'lim' => 'Latn',
  'gba' => 'Latn',
  'byn' => 'Ethi',
  'tsj' => 'Tibt',
  'hsb' => 'Latn',
  'nep' => 'Deva',
  'men' => 'Latn',
  'zdj' => 'Arab',
  'lki' => 'Arab',
  'mad' => 'Latn',
  'lcp' => 'Thai',
  'rng' => 'Latn',
  'kxp' => 'Arab',
  'lij' => 'Latn',
  'kjg' => 'Laoo',
  'ukr' => 'Cyrl',
  'sqi' => 'Latn',
  'che' => 'Cyrl',
  'bar' => 'Latn',
  'bfq' => 'Taml',
  'lep' => 'Lepc',
  'iii' => 'Yiii',
  'est' => 'Latn',
  'lez' => 'Cyrl',
  'mri' => 'Latn',
  'bbj' => 'Latn',
  'kao' => 'Latn',
  'kam' => 'Latn',
  'tet' => 'Latn',
  'ife' => 'Latn',
  'quc' => 'Latn',
  'btv' => 'Deva',
  'ast' => 'Latn',
  'arz' => 'Arab',
  'arp' => 'Latn',
  'tha' => 'Thai',
  'rmu' => 'Latn',
  'moh' => 'Latn',
  'krc' => 'Cyrl',
  'tpi' => 'Latn',
  'xmf' => 'Geor',
  'rej' => 'Latn',
  'mgo' => 'Latn',
  'mdh' => 'Latn',
  'gor' => 'Latn',
  'rgn' => 'Latn',
  'nhw' => 'Latn',
  'myx' => 'Latn',
  'tso' => 'Latn',
  'sco' => 'Latn',
  'aka' => 'Latn',
  'rof' => 'Latn',
  'mai' => 'Deva',
  'nap' => 'Latn',
  'haw' => 'Latn',
  'chp' => 'Latn',
  'hmo' => 'Latn',
  'abr' => 'Latn',
  'hsn' => 'Hans',
  'no' => 'Latn',
  'dng' => 'Cyrl',
  'hye' => 'Armn',
  'lao' => 'Laoo',
  'gos' => 'Latn',
  'mrd' => 'Deva',
  'hrv' => 'Latn',
  'mlt' => 'Latn',
  'del' => 'Latn',
  'saz' => 'Saur',
  'rob' => 'Latn',
  'moe' => 'Latn',
  'pam' => 'Latn',
  'nod' => 'Lana',
  'lam' => 'Latn',
  'run' => 'Latn',
  'bku' => 'Latn',
  'slv' => 'Latn',
  'lrc' => 'Arab',
  'sah' => 'Cyrl',
  'bhb' => 'Deva',
  'zea' => 'Latn',
  'lun' => 'Latn',
  'mwl' => 'Latn',
  'jrb' => 'Hebr',
  'bla' => 'Latn',
  'bas' => 'Latn',
  'kac' => 'Latn',
  'eka' => 'Latn',
  'ssy' => 'Latn',
  'tcy' => 'Knda',
  'cos' => 'Latn',
  'doi' => 'Arab',
  'krj' => 'Latn',
  'tli' => 'Latn',
  'rug' => 'Latn',
  'kon' => 'Latn',
  'koi' => 'Cyrl',
  'ltg' => 'Latn',
  'gur' => 'Latn',
  'chm' => 'Cyrl',
  'slk' => 'Latn',
  'bax' => 'Bamu',
  'ryu' => 'Kana',
  'raj' => 'Deva',
  'bqv' => 'Latn',
  'lug' => 'Latn',
  'osa' => 'Osge',
  'ada' => 'Latn',
  'nob' => 'Latn',
  'ace' => 'Latn',
  'zul' => 'Latn',
  'khw' => 'Arab',
  'see' => 'Latn',
  'laj' => 'Latn',
  'tat' => 'Cyrl',
  'twq' => 'Latn',
  'mag' => 'Deva',
  'pap' => 'Latn',
  'cym' => 'Latn',
  'zag' => 'Latn',
  'dua' => 'Latn',
  'sna' => 'Latn',
  'kua' => 'Latn',
  'lah' => 'Arab',
  'efi' => 'Latn',
  'bbc' => 'Latn',
  'rap' => 'Latn',
  'swg' => 'Latn',
  'yid' => 'Hebr',
  'sun' => 'Latn',
  'cho' => 'Latn',
  'krl' => 'Latn',
  'fur' => 'Latn',
  'anp' => 'Deva',
  'yua' => 'Latn',
  'kge' => 'Latn',
  'rue' => 'Cyrl',
  'tsg' => 'Latn',
  'esu' => 'Latn',
  'lbw' => 'Latn',
  'mrj' => 'Cyrl',
  'mon' => 'Cyrl',
  'bho' => 'Deva',
  'arn' => 'Latn',
  'cay' => 'Latn',
  'sad' => 'Latn',
  'dtp' => 'Latn',
  'srn' => 'Latn',
  'tkt' => 'Deva',
  'yrl' => 'Latn',
  'sly' => 'Latn',
  'mxc' => 'Latn',
  'gla' => 'Latn',
  'frr' => 'Latn',
  'mfa' => 'Arab',
  'lin' => 'Latn',
  'tmh' => 'Latn',
  'ewe' => 'Latn',
  'mua' => 'Latn',
  'kpy' => 'Cyrl',
  'fas' => 'Arab',
  'bgx' => 'Grek',
  'bak' => 'Cyrl',
  'aoz' => 'Latn',
  'nnh' => 'Latn',
  'sdh' => 'Arab',
  'fit' => 'Latn',
  'tiv' => 'Latn',
  'bft' => 'Arab',
  'bew' => 'Latn',
  'swe' => 'Latn',
  'wln' => 'Latn',
  'hat' => 'Latn',
  'rom' => 'Latn',
  'xav' => 'Latn',
  'mni' => 'Beng',
  'rmt' => 'Arab',
  'war' => 'Latn',
  'evn' => 'Cyrl',
  'aii' => 'Cyrl',
  'nsk' => 'Cans',
  'nno' => 'Latn',
  'gld' => 'Cyrl',
  'kjh' => 'Cyrl',
  'kan' => 'Knda',
  'wuu' => 'Hans',
  'lad' => 'Hebr',
  'grt' => 'Beng',
  'dan' => 'Latn',
  'mro' => 'Latn',
  'dtm' => 'Latn',
  'gay' => 'Latn',
  'pko' => 'Latn',
  'tru' => 'Latn',
  'gcr' => 'Latn',
  'hmd' => 'Plrd',
  'gvr' => 'Deva',
  'sin' => 'Sinh',
  'kum' => 'Cyrl',
  'kfo' => 'Latn',
  'saf' => 'Latn',
  'egl' => 'Latn',
  'ndo' => 'Latn',
  'ngl' => 'Latn',
  'vep' => 'Latn',
  'kht' => 'Mymr',
  'tsi' => 'Latn',
  'loz' => 'Latn',
  'tsn' => 'Latn',
  'pol' => 'Latn',
  'scn' => 'Latn',
  'fvr' => 'Latn',
  'kea' => 'Latn',
  'arg' => 'Latn',
  'som' => 'Latn',
  'lol' => 'Latn',
  'akz' => 'Latn',
  'kca' => 'Cyrl',
  'wbp' => 'Latn',
  'roh' => 'Latn',
  'sei' => 'Latn',
  'tts' => 'Thai',
  'trv' => 'Latn',
  'cha' => 'Latn',
  'xho' => 'Latn',
  'ita' => 'Latn',
  'vro' => 'Latn',
  'nqo' => 'Nkoo',
  'kde' => 'Latn',
  'ipk' => 'Latn',
  'gbm' => 'Deva',
  'dje' => 'Latn',
  'ebu' => 'Latn',
  'tur' => 'Latn',
  'ljp' => 'Latn',
  'mkd' => 'Cyrl',
  'vie' => 'Latn',
  'ndc' => 'Latn',
  'kmr' => 'Latn',
  'kcg' => 'Latn',
  'abq' => 'Cyrl',
  'mdf' => 'Cyrl',
  'vun' => 'Latn',
  'kri' => 'Latn',
  'crs' => 'Latn',
  'ara' => 'Arab',
  'ria' => 'Latn',
  'prd' => 'Arab',
  'njo' => 'Latn',
  'xnr' => 'Deva',
  'sid' => 'Latn',
  'rtm' => 'Latn',
  'thl' => 'Deva',
  'hmn' => 'Latn',
  'gju' => 'Arab',
  'dnj' => 'Latn',
  'sxn' => 'Latn',
  'luo' => 'Latn',
  'srb' => 'Latn',
  'was' => 'Latn',
  'ewo' => 'Latn',
  'sag' => 'Latn',
  'vmw' => 'Latn',
  'car' => 'Latn',
  'rcf' => 'Latn',
  'sdc' => 'Latn',
  'tsd' => 'Grek',
  'pms' => 'Latn',
  'atj' => 'Latn',
  'yao' => 'Latn',
  'ind' => 'Latn',
  'zun' => 'Latn',
  'fry' => 'Latn',
  'bik' => 'Latn',
  'lwl' => 'Thai',
  'ssw' => 'Latn',
  'gbz' => 'Arab',
  'kgp' => 'Latn',
  'alt' => 'Cyrl',
  'rup' => 'Latn',
  'noe' => 'Deva',
  'yap' => 'Latn',
  'cat' => 'Latn',
  'ltz' => 'Latn',
  'kaa' => 'Cyrl',
  'kkj' => 'Latn',
  'srd' => 'Latn',
  'vic' => 'Latn',
  'din' => 'Latn',
  'nde' => 'Latn',
  'luz' => 'Arab',
  'aeb' => 'Arab',
  'kin' => 'Latn',
  'sef' => 'Latn',
  'mah' => 'Latn',
  'her' => 'Latn',
  'ava' => 'Cyrl',
  'nia' => 'Latn',
  'zap' => 'Latn',
  'pfl' => 'Latn',
  'fuv' => 'Latn',
  'mic' => 'Latn',
  'pag' => 'Latn',
  'maz' => 'Latn',
  'mal' => 'Mlym',
  'kom' => 'Cyrl',
  'pdc' => 'Latn',
  'lag' => 'Latn',
  'nan' => 'Hans',
  'sms' => 'Latn',
  'gjk' => 'Arab',
  'pcd' => 'Latn',
  'glg' => 'Latn',
  'vec' => 'Latn',
  'abk' => 'Cyrl',
  'ces' => 'Latn',
  'den' => 'Latn',
  'jam' => 'Latn',
  'umb' => 'Latn',
  'bfy' => 'Deva',
  'fuq' => 'Latn',
  'uli' => 'Latn',
  'qug' => 'Latn',
  'kab' => 'Latn',
  'frs' => 'Latn',
  'myv' => 'Cyrl',
  'mwv' => 'Latn',
  'deu' => 'Latn',
  'kor' => 'Kore',
  'bin' => 'Latn',
  'syl' => 'Beng',
  'dty' => 'Deva',
  'div' => 'Thaa',
  'ttj' => 'Latn',
  'cic' => 'Latn',
  'saq' => 'Latn',
  'sgs' => 'Latn',
  'fao' => 'Latn',
  'afr' => 'Latn',
  'kbd' => 'Cyrl',
  'ckb' => 'Arab',
  'nau' => 'Latn',
  'mnw' => 'Mymr',
  'frc' => 'Latn',
  'vmf' => 'Latn',
  'hnn' => 'Latn',
  'ben' => 'Beng',
  'wae' => 'Latn',
  'kfy' => 'Deva',
  'kiu' => 'Latn',
  'naq' => 'Latn',
  'ady' => 'Cyrl',
  'glk' => 'Arab',
  'nav' => 'Latn',
  'bci' => 'Latn',
  'thr' => 'Deva',
  'oji' => 'Cans',
  'wni' => 'Arab',
  'chv' => 'Cyrl',
  'ell' => 'Grek',
  'ibo' => 'Latn',
  'eky' => 'Kali',
  'mar' => 'Deva',
  'nxq' => 'Latn',
  'new' => 'Deva',
  'mvy' => 'Arab',
  'glv' => 'Latn',
  'lav' => 'Latn',
  'kck' => 'Latn',
  'nds' => 'Latn',
  'buc' => 'Latn',
  'asa' => 'Latn',
  'nyo' => 'Latn',
  'mlg' => 'Latn',
  'chk' => 'Latn',
  'aym' => 'Latn',
  'mwk' => 'Latn',
  'hil' => 'Latn',
  'sme' => 'Latn',
  'kru' => 'Deva',
  'kik' => 'Latn',
  'nym' => 'Latn',
  'tum' => 'Latn',
  'dgr' => 'Latn',
  'oss' => 'Cyrl',
  'gwi' => 'Latn',
  'kdt' => 'Thai',
  'bkm' => 'Latn',
  'pau' => 'Latn',
  'bum' => 'Latn',
  'ctd' => 'Latn',
  'rus' => 'Cyrl',
  'tdh' => 'Deva',
  'niu' => 'Latn',
  'fon' => 'Latn',
  'blt' => 'Tavt',
  'bgc' => 'Deva',
  'tig' => 'Ethi',
  'rmo' => 'Latn',
  'bvb' => 'Latn',
  'kfr' => 'Deva',
  'zmi' => 'Latn',
  'dav' => 'Latn',
  'lus' => 'Beng',
  'cja' => 'Arab',
  'pus' => 'Arab',
  'ban' => 'Latn',
  'lmo' => 'Latn',
  'zha' => 'Latn',
  'crm' => 'Cans',
  'smj' => 'Latn',
  'mas' => 'Latn',
  'bjj' => 'Deva',
  'hun' => 'Latn',
  'nor' => 'Latn',
  'bto' => 'Latn',
  'orm' => 'Latn',
  'cch' => 'Latn',
  'izh' => 'Latn',
  'amh' => 'Ethi',
  'pdt' => 'Latn',
  'isl' => 'Latn',
  'frp' => 'Latn',
  'mya' => 'Mymr',
  'kau' => 'Latn',
  'gub' => 'Latn',
  'fij' => 'Latn',
  'skr' => 'Arab',
  'por' => 'Latn',
  'bul' => 'Cyrl',
  'amo' => 'Latn',
  'ale' => 'Latn',
  'tab' => 'Cyrl',
  'ksf' => 'Latn',
  'gil' => 'Latn',
  'nhe' => 'Latn',
  'arq' => 'Arab',
  'luy' => 'Latn',
  'jpn' => 'Jpan',
  'bra' => 'Deva',
  'sck' => 'Deva',
  'crh' => 'Cyrl',
  'kut' => 'Latn',
  'sus' => 'Latn',
  'smo' => 'Latn',
  'wbr' => 'Deva',
  'crl' => 'Cans',
  'rjs' => 'Deva',
  'tkl' => 'Latn',
  'hnd' => 'Arab',
  'lkt' => 'Latn',
  'crj' => 'Cans',
  'kos' => 'Latn',
  'sot' => 'Latn',
  'kpe' => 'Latn',
  'wal' => 'Ethi',
  'ksb' => 'Latn',
  'khm' => 'Khmr',
  'dsb' => 'Latn',
  'cgg' => 'Latn',
  'haz' => 'Arab',
  'dak' => 'Latn',
  'nus' => 'Latn',
  'nzi' => 'Latn',
  'eus' => 'Latn',
  'epo' => 'Latn',
  'rkt' => 'Beng',
  'tbw' => 'Latn',
  'bpy' => 'Beng',
  'mer' => 'Latn',
  'dyo' => 'Latn',
  'fud' => 'Latn',
  'fil' => 'Latn',
  'tyv' => 'Cyrl',
  'jav' => 'Latn',
  'bem' => 'Latn',
  'mgy' => 'Latn',
  'fan' => 'Latn',
  'fia' => 'Arab',
  'rmf' => 'Latn',
  'zza' => 'Latn',
  'hin' => 'Deva',
  'xog' => 'Latn',
  'bqi' => 'Arab',
  'aar' => 'Latn',
  'wls' => 'Latn',
  'mwr' => 'Deva',
  'nbl' => 'Latn',
  'mns' => 'Cyrl',
  'tah' => 'Latn',
  'kvr' => 'Latn',
  'stq' => 'Latn',
  'tdd' => 'Tale',
  'jmc' => 'Latn',
  'chr' => 'Cher',
  'ext' => 'Latn',
  'cjm' => 'Cham',
  'ars' => 'Arab',
  'taj' => 'Deva',
  'mos' => 'Latn',
  'ffm' => 'Latn',
  'brh' => 'Arab',
  'xsr' => 'Deva',
  'gan' => 'Hans',
  'thq' => 'Deva',
  'bua' => 'Cyrl',
  'hno' => 'Arab',
  'gsw' => 'Latn',
  'lis' => 'Lisu',
  'sbp' => 'Latn',
  'mak' => 'Latn',
  'ksh' => 'Latn',
  'cps' => 'Latn',
  'bez' => 'Latn',
  'bel' => 'Cyrl',
  'shn' => 'Mymr',
  'hoj' => 'Deva',
  'dzo' => 'Tibt',
  'fra' => 'Latn',
  'puu' => 'Latn',
  'scs' => 'Latn',
  'suk' => 'Latn',
  'swv' => 'Deva',
  'srx' => 'Deva',
  'nyn' => 'Latn',
  'gag' => 'Latn',
  'bfd' => 'Latn',
  'bmq' => 'Latn',
  'ses' => 'Latn',
  'tam' => 'Taml',
  'ful' => 'Latn',
  'sma' => 'Latn',
  'urd' => 'Arab',
  'grb' => 'Latn',
  'rar' => 'Latn',
  'kha' => 'Latn',
  'guj' => 'Gujr',
  'spa' => 'Latn',
  'wol' => 'Latn',
  'csw' => 'Cans',
  'ilo' => 'Latn',
  'ceb' => 'Latn',
  'guz' => 'Latn',
  'aln' => 'Latn',
  'syi' => 'Latn',
  'sat' => 'Olck',
  'ary' => 'Arab',
  'mtr' => 'Deva',
  'khb' => 'Talu',
  'ude' => 'Cyrl',
  'bgn' => 'Arab',
  'hnj' => 'Laoo',
  'sli' => 'Latn',
  'kok' => 'Deva',
  'rwk' => 'Latn',
  'yav' => 'Latn',
  'bej' => 'Arab',
  'hop' => 'Latn',
  'ori' => 'Orya',
  'chy' => 'Latn',
  'tdg' => 'Deva',
  'wtm' => 'Deva',
  'ybb' => 'Latn',
  'lmn' => 'Telu',
  'nmg' => 'Latn',
  'dar' => 'Cyrl',
  'hne' => 'Deva',
  'xal' => 'Cyrl',
  'tog' => 'Latn',
  'heb' => 'Hebr',
  'fin' => 'Latn',
  'nld' => 'Latn',
  'gom' => 'Deva',
  'hai' => 'Latn',
  'mus' => 'Latn',
  'mzn' => 'Arab',
  'bss' => 'Latn',
  'ikt' => 'Latn',
  'gaa' => 'Latn',
  'cad' => 'Latn',
  'tel' => 'Telu',
  'sou' => 'Thai',
  'jml' => 'Deva',
  'lit' => 'Latn',
  'mdt' => 'Latn',
  'lbe' => 'Cyrl',
  'kvx' => 'Arab',
  'szl' => 'Latn',
  'tvl' => 'Latn',
  'yrk' => 'Cyrl',
  'khn' => 'Deva',
  'bug' => 'Latn',
  'snk' => 'Latn',
  'hup' => 'Latn',
  'smn' => 'Latn',
  'iba' => 'Latn',
  'teo' => 'Latn',
  'bzx' => 'Latn',
  'nya' => 'Latn',
  'srr' => 'Latn',
  'mdr' => 'Latn',
  'wbq' => 'Telu',
  'bod' => 'Tibt',
  'bre' => 'Latn',
  'ibb' => 'Latn',
  'byv' => 'Latn',
  'tem' => 'Latn',
  'sas' => 'Latn',
  'hoc' => 'Deva',
  'kat' => 'Geor',
  'asm' => 'Beng',
  'grn' => 'Latn',
  'nso' => 'Latn',
  'yor' => 'Latn',
  'guc' => 'Latn',
  'ton' => 'Latn',
  'udm' => 'Cyrl',
  'bjn' => 'Latn',
  'agq' => 'Latn',
  'kln' => 'Latn',
  'kmb' => 'Latn',
  'oci' => 'Latn',
  'bal' => 'Arab',
  'bap' => 'Deva'
};
$DefaultTerritory = {
  'ssw' => 'ZA',
  'nr' => 'ZA',
  'san' => 'IN',
  'hy' => 'AM',
  'cat' => 'ES',
  'noe' => 'IN',
  'ltz' => 'LU',
  'mn' => 'MN',
  'lv' => 'LV',
  'srd' => 'IT',
  'kkj' => 'CM',
  'luz' => 'IR',
  'sr_Latn' => 'RS',
  'yo' => 'NG',
  'nde' => 'ZW',
  'mon_Mong' => 'CN',
  'kin' => 'RW',
  'aeb' => 'TN',
  'ig' => 'NG',
  'pa_Arab' => 'PK',
  'mah' => 'MH',
  'ava' => 'RU',
  'sef' => 'CI',
  'fuv' => 'NG',
  'pag' => 'PH',
  'glg' => 'ES',
  'sms' => 'FI',
  'lag' => 'TZ',
  'nan' => 'CN',
  'mal' => 'IN',
  'kom' => 'RU',
  'abk' => 'GE',
  'ces' => 'CZ',
  'msa_Arab' => 'MY',
  'ken' => 'CM',
  'jam' => 'JM',
  'umb' => 'AO',
  'fuq' => 'NE',
  'myv' => 'RU',
  'kab' => 'DZ',
  'dje' => 'NE',
  'uzb_Cyrl' => 'UZ',
  'gbm' => 'IN',
  'ljp' => 'ID',
  'ebu' => 'KE',
  'tur' => 'TR',
  'se' => 'NO',
  'pan_Guru' => 'IN',
  'kcg' => 'NG',
  'ndc' => 'MZ',
  'vie' => 'VN',
  'mkd' => 'MK',
  'vun' => 'TZ',
  'mdf' => 'RU',
  'kas_Arab' => 'IN',
  'kri' => 'SL',
  'mg' => 'MG',
  'sv' => 'SE',
  'crs' => 'SC',
  'rif' => 'MA',
  'sc' => 'IT',
  'ts' => 'ZA',
  'xnr' => 'IN',
  'sid' => 'ET',
  'aze_Arab' => 'IR',
  'ne' => 'NP',
  'dnj' => 'CI',
  'ee' => 'GH',
  'ewo' => 'CM',
  'sd_Deva' => 'IN',
  'id' => 'ID',
  'luo' => 'KE',
  'vmw' => 'MZ',
  'sag' => 'CF',
  'om' => 'ET',
  'rcf' => 'RE',
  'syr' => 'IQ',
  'si' => 'LK',
  'ind' => 'ID',
  'ka' => 'GE',
  'bik' => 'PH',
  'da' => 'DK',
  'fry' => 'NL',
  'mk' => 'MK',
  'war' => 'PH',
  'nno' => 'NO',
  'zu' => 'ZA',
  'bs_Latn' => 'BA',
  'kan' => 'IN',
  'wuu' => 'CN',
  'dan' => 'DK',
  'fy' => 'NL',
  'gcr' => 'GF',
  'bjt' => 'SN',
  'mt' => 'MT',
  'kum' => 'RU',
  'sin' => 'LK',
  'ngl' => 'MZ',
  'ndo' => 'NA',
  'uz_Cyrl' => 'UZ',
  'scn' => 'IT',
  'tsn' => 'ZA',
  'pol' => 'PL',
  'som' => 'SO',
  'qu' => 'PE',
  'arg' => 'ES',
  'fvr' => 'SD',
  'kea' => 'CV',
  'tts' => 'TH',
  'roh' => 'CH',
  'wbp' => 'AU',
  'xho' => 'ZA',
  'cha' => 'GU',
  'trv' => 'TW',
  'en_Dsrt' => 'US',
  'kde' => 'TZ',
  'nqo' => 'GN',
  'gl' => 'ES',
  'ita' => 'IT',
  'iu' => 'CA',
  'de' => 'DE',
  'tnr' => 'SN',
  'tsg' => 'PH',
  'arn' => 'CL',
  'mon' => 'MN',
  'srn' => 'SR',
  'dv' => 'MV',
  'it' => 'IT',
  'srp_Cyrl' => 'RS',
  'gla' => 'GB',
  'bos_Latn' => 'BA',
  'tmh' => 'NE',
  'lin' => 'CD',
  'mfa' => 'TH',
  'ewe' => 'GH',
  'fas' => 'IR',
  'aa' => 'ET',
  'mua' => 'CM',
  'bak' => 'RU',
  'ki' => 'KE',
  'sdh' => 'IR',
  'nnh' => 'CM',
  'bew' => 'ID',
  'tiv' => 'NG',
  'hat' => 'HT',
  'iu_Latn' => 'CA',
  'wln' => 'BE',
  'sa' => 'IN',
  'bos' => 'BA',
  'swe' => 'SE',
  'rmt' => 'IR',
  'mni' => 'IN',
  'cy' => 'GB',
  'ln' => 'CD',
  'uzb_Latn' => 'UZ',
  'doi' => 'IN',
  'cos' => 'FR',
  'koi' => 'RU',
  'kon' => 'CD',
  'raj' => 'IN',
  'slk' => 'SK',
  'csb' => 'PL',
  'lug' => 'UG',
  'nob' => 'NO',
  'vi' => 'VN',
  'osa' => 'US',
  'rn' => 'BI',
  'zul' => 'ZA',
  'sg' => 'CF',
  'sun_Latn' => 'ID',
  'ace' => 'ID',
  'tat' => 'RU',
  'laj' => 'UG',
  'mag' => 'IN',
  'snf' => 'SN',
  'twq' => 'NE',
  'mi' => 'NZ',
  'cym' => 'GB',
  'kw' => 'GB',
  'ro' => 'RO',
  'ak' => 'GH',
  'dua' => 'CM',
  'efi' => 'NG',
  'lah' => 'PK',
  'kua' => 'NA',
  'sna' => 'ZW',
  'lo' => 'LA',
  'bbc' => 'ID',
  'sk' => 'SK',
  'sun' => 'ID',
  'fur' => 'IT',
  've' => 'ZA',
  'tuk' => 'TM',
  'mai' => 'IN',
  'rof' => 'TZ',
  'jv' => 'ID',
  'aka' => 'GH',
  'sn' => 'ZW',
  'ku' => 'TR',
  'haw' => 'US',
  'nd' => 'ZW',
  'cs' => 'CZ',
  'abr' => 'GH',
  'hmo' => 'PG',
  'hsn' => 'CN',
  'uz_Latn' => 'UZ',
  'no' => 'NO',
  'hye' => 'AM',
  'an' => 'ES',
  'zho_Hant' => 'TW',
  'lao' => 'LA',
  'yue_Hans' => 'CN',
  'vai_Latn' => 'LR',
  'mlt' => 'MT',
  'xh' => 'ZA',
  'hrv' => 'HR',
  'zh_Hans' => 'CN',
  'lg' => 'UG',
  'pam' => 'PH',
  'en' => 'US',
  'nn' => 'NO',
  'ff_Adlm' => 'GN',
  'run' => 'BI',
  'nod' => 'TH',
  'ii' => 'CN',
  'sah' => 'RU',
  'slv' => 'SI',
  'kas_Deva' => 'IN',
  'sat_Deva' => 'IN',
  'lrc' => 'IR',
  'mr' => 'IN',
  'bhb' => 'IN',
  'bs_Cyrl' => 'BA',
  'mni_Beng' => 'IN',
  'so' => 'SO',
  'bas' => 'CM',
  'os' => 'GE',
  'tcy' => 'IN',
  'ssy' => 'ER',
  'sq' => 'AL',
  'lu' => 'CD',
  'zdj' => 'KM',
  'mn_Mong' => 'CN',
  'mad' => 'ID',
  'tzm' => 'MA',
  'zh_Hant' => 'TW',
  'che' => 'RU',
  'sqi' => 'AL',
  'ukr' => 'UA',
  'pt' => 'PT',
  'srp_Latn' => 'RS',
  'ru' => 'RU',
  'lt' => 'LT',
  'bos_Cyrl' => 'BA',
  'mri' => 'NZ',
  'lez' => 'RU',
  'est' => 'EE',
  'iii' => 'CN',
  'ast' => 'ES',
  'quc' => 'GT',
  'knf' => 'SN',
  'kam' => 'KE',
  'tet' => 'TL',
  'ife' => 'TG',
  'bm' => 'ML',
  'sw' => 'TZ',
  'arz' => 'EG',
  'tha' => 'TH',
  'hau' => 'NG',
  'krc' => 'RU',
  'moh' => 'CA',
  'tpi' => 'PG',
  'mgo' => 'CM',
  'kk' => 'KZ',
  'rej' => 'ID',
  'gor' => 'ID',
  'mdh' => 'PH',
  'tso' => 'ZA',
  'sco' => 'GB',
  'myx' => 'UG',
  'bsc' => 'SN',
  'mgh' => 'MZ',
  'pcm' => 'NG',
  'th' => 'TH',
  'lub' => 'CD',
  'pon' => 'FM',
  'kn' => 'IN',
  'khq' => 'ML',
  'sd_Arab' => 'PK',
  'kxm' => 'TH',
  'zgh' => 'MA',
  'ven' => 'ZA',
  'uz_Arab' => 'AF',
  'swa' => 'TZ',
  'dcc' => 'IN',
  'awa' => 'IN',
  'brx' => 'IN',
  'inh' => 'RU',
  'st' => 'ZA',
  'ach' => 'UG',
  'min' => 'ID',
  'ron' => 'RO',
  'seh' => 'MZ',
  'bhi' => 'IN',
  'kaj' => 'NG',
  'dyu' => 'BF',
  'bis' => 'VU',
  'gle' => 'IE',
  'kaz' => 'KZ',
  'sr_Cyrl' => 'RS',
  'eu' => 'ES',
  'swb' => 'YT',
  'tgk' => 'TJ',
  'cor' => 'GB',
  'hak' => 'CN',
  'kal' => 'GL',
  'af' => 'ZA',
  'jgo' => 'CM',
  'lua' => 'CD',
  'vls' => 'BE',
  'tir' => 'ET',
  'ja' => 'JP',
  'mfe' => 'MU',
  'que' => 'PE',
  'eng' => 'US',
  'ko' => 'KR',
  'byn' => 'ER',
  'et' => 'EE',
  'rw' => 'RW',
  'nep' => 'NP',
  'hsb' => 'DE',
  'men' => 'SL',
  'unr' => 'IN',
  'su_Latn' => 'ID',
  'ga' => 'IE',
  'ms_Arab' => 'MY',
  'shi_Tfng' => 'MA',
  'khn' => 'IN',
  'pl' => 'PL',
  'hi_Latn' => 'IN',
  'snk' => 'ML',
  'bug' => 'ID',
  'ha_Arab' => 'NG',
  'smn' => 'FI',
  'vai_Vaii' => 'LR',
  'srr' => 'SN',
  'he' => 'IL',
  'teo' => 'UG',
  'nya' => 'MW',
  'bn' => 'BD',
  'bod' => 'CN',
  'wbq' => 'IN',
  'ibb' => 'NG',
  'bre' => 'FR',
  'asm' => 'IN',
  'grn' => 'PY',
  'bo' => 'CN',
  'sas' => 'ID',
  'hoc' => 'IN',
  'kat' => 'GE',
  'tem' => 'SL',
  'yor' => 'NG',
  'nso' => 'ZA',
  'ton' => 'TO',
  'agq' => 'CM',
  'kln' => 'KE',
  'bjn' => 'ID',
  'udm' => 'RU',
  'fa' => 'IR',
  'az_Cyrl' => 'AZ',
  'oci' => 'FR',
  'kmb' => 'AO',
  'hi' => 'IN',
  'ori' => 'IN',
  'wtm' => 'IN',
  'bg' => 'BG',
  'sl' => 'SI',
  'hne' => 'IN',
  'lmn' => 'IN',
  'nmg' => 'CM',
  'ful_Adlm' => 'GN',
  'fin' => 'FI',
  'heb' => 'IL',
  'gom' => 'IN',
  'nld' => 'NL',
  'hif' => 'FJ',
  'ca' => 'ES',
  'mzn' => 'IR',
  'mus' => 'US',
  'nl' => 'NL',
  'ikt' => 'CA',
  'bss' => 'CM',
  'el' => 'GR',
  'eng_Dsrt' => 'US',
  'bhk' => 'PH',
  'tt' => 'RU',
  'cad' => 'US',
  'gaa' => 'GH',
  'ks_Deva' => 'IN',
  'tel' => 'IN',
  'hr' => 'HR',
  'uig' => 'CN',
  'sou' => 'TH',
  'szl' => 'PL',
  'lbe' => 'RU',
  'lit' => 'LT',
  'zho_Hans' => 'CN',
  'ny' => 'MW',
  'tvl' => 'TV',
  'km' => 'KH',
  'bam' => 'ML',
  'yue_Hant' => 'HK',
  'bez' => 'TZ',
  'tk' => 'TM',
  'shi' => 'MA',
  'fra' => 'FR',
  'hoj' => 'IN',
  'dzo' => 'BT',
  'shn' => 'MM',
  'bel' => 'BY',
  'swv' => 'IN',
  'suk' => 'TZ',
  'aze_Latn' => 'AZ',
  'nyn' => 'UG',
  'sma' => 'SE',
  'tam' => 'IN',
  'ses' => 'ML',
  'urd' => 'PK',
  'guj' => 'IN',
  'spa' => 'ES',
  'kha' => 'IN',
  'fi' => 'FI',
  'guz' => 'KE',
  'ceb' => 'PH',
  'ilo' => 'PH',
  'wol' => 'SN',
  'ms' => 'MY',
  'shi_Latn' => 'MA',
  'kas' => 'IN',
  'sat' => 'IN',
  'ha' => 'NG',
  'aln' => 'XK',
  'gv' => 'IM',
  'ary' => 'MA',
  'mtr' => 'IN',
  'rm' => 'CH',
  'tg' => 'TJ',
  'ur' => 'PK',
  'or' => 'IN',
  'pan_Arab' => 'PK',
  'snd_Deva' => 'IN',
  'wa' => 'BE',
  'bgn' => 'PK',
  'ful_Latn' => 'SN',
  'bej' => 'SD',
  'yav' => 'CM',
  'kok' => 'IN',
  'rwk' => 'TZ',
  'to' => 'TO',
  'jav' => 'ID',
  'bem' => 'ZM',
  'tyv' => 'RU',
  'kl' => 'GL',
  'fan' => 'GQ',
  'oc' => 'FR',
  'msa' => 'MY',
  'xog' => 'UG',
  'hin' => 'IN',
  'zza' => 'TR',
  'aar' => 'ET',
  'bqi' => 'IR',
  'bm_Nkoo' => 'ML',
  'ky' => 'KG',
  'kir' => 'KG',
  'mwr' => 'IN',
  'nbl' => 'ZA',
  'wls' => 'WF',
  'tah' => 'PF',
  'ce' => 'RU',
  'hin_Latn' => 'IN',
  'am' => 'ET',
  'jmc' => 'TZ',
  'chr' => 'US',
  'is' => 'IS',
  'ffm' => 'ML',
  'mos' => 'BF',
  'lat' => 'VA',
  'brh' => 'PK',
  'fr' => 'FR',
  'cv' => 'RU',
  'hno' => 'PK',
  'tn' => 'ZA',
  'gan' => 'CN',
  'sbp' => 'TZ',
  'gsw' => 'CH',
  'ksh' => 'DE',
  'mak' => 'ID',
  'por' => 'PT',
  'skr' => 'PK',
  'fij' => 'FJ',
  'bam_Nkoo' => 'ML',
  'bul' => 'BG',
  'ksf' => 'CM',
  'gil' => 'KI',
  'ml' => 'IN',
  'ff_Latn' => 'SN',
  'arq' => 'DZ',
  'my' => 'MM',
  'jpn' => 'JP',
  'luy' => 'KE',
  'sus' => 'GN',
  'sck' => 'IN',
  'be' => 'BY',
  'wbr' => 'IN',
  'iku_Latn' => 'CA',
  'tkl' => 'TK',
  'lkt' => 'US',
  'mni_Mtei' => 'IN',
  'sot' => 'ZA',
  'lb' => 'LU',
  'gez' => 'ET',
  'ksb' => 'TZ',
  'kpe' => 'LR',
  'wal' => 'ET',
  'cgg' => 'UG',
  'khm' => 'KH',
  'dsb' => 'DE',
  'eus' => 'ES',
  'iku' => 'CA',
  'nus' => 'SS',
  'haz' => 'AF',
  'dyo' => 'SN',
  'mer' => 'KE',
  'wo' => 'SN',
  'fud' => 'WF',
  'fil' => 'PH',
  'gu' => 'IN',
  'bum' => 'CM',
  'rus' => 'RU',
  'nb' => 'NO',
  'tig' => 'ER',
  'bgc' => 'IN',
  'blt' => 'VN',
  'fon' => 'BJ',
  'niu' => 'NU',
  'ta' => 'IN',
  'hau_Arab' => 'NG',
  'dav' => 'KE',
  'ban' => 'ID',
  'pus' => 'AF',
  'sat_Olck' => 'IN',
  'zha' => 'CN',
  'smj' => 'SE',
  'az_Arab' => 'IR',
  'mas' => 'KE',
  'dz' => 'BT',
  'cu' => 'RU',
  'ccp' => 'BD',
  'hun' => 'HU',
  'nor' => 'NO',
  'bjj' => 'IN',
  'orm' => 'ET',
  'cch' => 'NG',
  'kur' => 'TR',
  'amh' => 'ET',
  'isl' => 'IS',
  'mya' => 'MM',
  'br' => 'FR',
  'gon' => 'IN',
  'ibo' => 'NG',
  'mar' => 'IN',
  'snd_Arab' => 'PK',
  'lav' => 'LV',
  'glv' => 'IM',
  'tr' => 'TR',
  'buc' => 'YT',
  'ug' => 'CN',
  'nds' => 'DE',
  'hu' => 'HU',
  'gd' => 'GB',
  'asa' => 'TZ',
  'mey' => 'SN',
  'mfv' => 'SN',
  'chk' => 'FM',
  'aym' => 'BO',
  'mlg' => 'MG',
  'kru' => 'IN',
  'sme' => 'NO',
  'kik' => 'KE',
  'hil' => 'PH',
  'nym' => 'TZ',
  'ba' => 'RU',
  'tum' => 'MW',
  'ps' => 'AF',
  'oss' => 'GE',
  'uk' => 'UA',
  'pau' => 'PW',
  'fo' => 'FO',
  'gn' => 'PY',
  'az_Latn' => 'AZ',
  'kor' => 'KR',
  'bin' => 'NG',
  'deu' => 'DE',
  'cic' => 'US',
  'div' => 'MV',
  'syl' => 'BD',
  'es' => 'ES',
  'ks_Arab' => 'IN',
  'aze_Cyrl' => 'AZ',
  'saq' => 'KE',
  'co' => 'FR',
  'chu' => 'RU',
  'afr' => 'ZA',
  'fao' => 'FO',
  'uzb_Arab' => 'AF',
  'sav' => 'SN',
  'ckb' => 'IQ',
  'kbd' => 'RU',
  'ti' => 'ET',
  'nau' => 'NR',
  'vmf' => 'DE',
  'kfy' => 'IN',
  'wae' => 'CH',
  'ben' => 'BD',
  'pa_Guru' => 'IN',
  'ss' => 'ZA',
  'ady' => 'RU',
  'naq' => 'NA',
  'as' => 'IN',
  'te' => 'IN',
  'glk' => 'IR',
  'bci' => 'CI',
  'wni' => 'KM',
  'ell' => 'GR',
  'chv' => 'RU'
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
    my $langcode = ISO::639::3::get_iso639_3($_[0],1);
    return sort keys %{$$Lang2Script{$langcode}} if (exists $$Lang2Script{$langcode});
    $langcode = ISO::639::3::get_macro_language($langcode,1);
    return sort keys %{$$Lang2Script{$langcode}} if (exists $$Lang2Script{$langcode});
    print STDERR "unknown language $_[0]\n" if ($VERBOSE);
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


