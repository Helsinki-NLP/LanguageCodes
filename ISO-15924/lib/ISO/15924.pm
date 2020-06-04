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
    language_scripts
    default_script
    languages_with_script
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



$ScriptCode2ScriptName = {
  'Java' => 'Javanese',
  'Elym' => 'Elymaic',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Gong' => 'Gunjala_Gondi',
  'Leke' => '',
  'Shui' => '',
  'Egyd' => '',
  'Vaii' => 'Vai',
  'Cyrs' => '',
  'Avst' => 'Avestan',
  'Kali' => 'Kayah_Li',
  'Perm' => 'Old_Permic',
  'Orya' => 'Oriya',
  'Nbat' => 'Nabataean',
  'Tirh' => 'Tirhuta',
  'Zmth' => '',
  'Wole' => '',
  'Adlm' => 'Adlam',
  'Cari' => 'Carian',
  'Zzzz' => 'Unknown',
  'Toto' => '',
  'Kore' => '',
  'Teng' => '',
  'Olck' => 'Ol_Chiki',
  'Rohg' => 'Hanifi_Rohingya',
  'Cakm' => 'Chakma',
  'Mani' => 'Manichaean',
  'Linb' => 'Linear_B',
  'Palm' => 'Palmyrene',
  'Lisu' => 'Lisu',
  'Ugar' => 'Ugaritic',
  'Egyh' => '',
  'Hebr' => 'Hebrew',
  'Moon' => '',
  'Samr' => 'Samaritan',
  'Zyyy' => 'Common',
  'Marc' => 'Marchen',
  'Dogr' => 'Dogra',
  'Zanb' => 'Zanabazar_Square',
  'Tibt' => 'Tibetan',
  'Soyo' => 'Soyombo',
  'Tagb' => 'Tagbanwa',
  'Lina' => 'Linear_A',
  'Syrn' => '',
  'Grek' => 'Greek',
  'Shrd' => 'Sharada',
  'Tglg' => 'Tagalog',
  'Qabx' => '',
  'Beng' => 'Bengali',
  'Limb' => 'Limbu',
  'Thaa' => 'Thaana',
  'Medf' => 'Medefaidrin',
  'Ahom' => 'Ahom',
  'Phlp' => 'Psalter_Pahlavi',
  'Cprt' => 'Cypriot',
  'Bamu' => 'Bamum',
  'Deva' => 'Devanagari',
  'Copt' => 'Coptic',
  'Yezi' => 'Yezidi',
  'Qaaa' => '',
  'Modi' => 'Modi',
  'Aran' => '',
  'Orkh' => 'Old_Turkic',
  'Wara' => 'Warang_Citi',
  'Gran' => 'Grantha',
  'Bhks' => 'Bhaiksuki',
  'Bugi' => 'Buginese',
  'Ital' => 'Old_Italic',
  'Gujr' => 'Gujarati',
  'Xpeo' => 'Old_Persian',
  'Mand' => 'Mandaic',
  'Gonm' => 'Masaram_Gondi',
  'Mroo' => 'Mro',
  'Taml' => 'Tamil',
  'Hira' => 'Hiragana',
  'Tfng' => 'Tifinagh',
  'Loma' => '',
  'Hans' => '',
  'Sidd' => 'Siddham',
  'Hant' => '',
  'Osge' => 'Osage',
  'Sarb' => 'Old_South_Arabian',
  'Sind' => 'Khudawadi',
  'Sgnw' => 'SignWriting',
  'Mong' => 'Mongolian',
  'Saur' => 'Saurashtra',
  'Lydi' => 'Lydian',
  'Roro' => '',
  'Jpan' => '',
  'Aghb' => 'Caucasian_Albanian',
  'Narb' => 'Old_North_Arabian',
  'Mtei' => 'Meetei_Mayek',
  'Chrs' => 'Chorasmian',
  'Cpmn' => '',
  'Jurc' => '',
  'Piqd' => '',
  'Tang' => 'Tangut',
  'Khoj' => 'Khojki',
  'Plrd' => 'Miao',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Brai' => 'Braille',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Phag' => 'Phags_Pa',
  'Kpel' => '',
  'Glag' => 'Glagolitic',
  'Latg' => '',
  'Zinh' => 'Inherited',
  'Cirt' => '',
  'Visp' => '',
  'Elba' => 'Elbasan',
  'Hanb' => '',
  'Laoo' => 'Lao',
  'Khmr' => 'Khmer',
  'Nkoo' => 'Nko',
  'Zsym' => '',
  'Nkgb' => '',
  'Brah' => 'Brahmi',
  'Bopo' => 'Bopomofo',
  'Sara' => '',
  'Jamo' => '',
  'Newa' => 'Newa',
  'Hatr' => 'Hatran',
  'Kits' => 'Khitan_Small_Script',
  'Dupl' => 'Duployan',
  'Cham' => 'Cham',
  'Sund' => 'Sundanese',
  'Telu' => 'Telugu',
  'Kthi' => 'Kaithi',
  'Maya' => '',
  'Inds' => '',
  'Kana' => 'Katakana',
  'Mend' => 'Mende_Kikakui',
  'Hani' => 'Han',
  'Blis' => '',
  'Sogd' => 'Sogdian',
  'Thai' => 'Thai',
  'Afak' => '',
  'Armi' => 'Imperial_Aramaic',
  'Sora' => 'Sora_Sompeng',
  'Hang' => 'Hangul',
  'Prti' => 'Inscriptional_Parthian',
  'Batk' => 'Batak',
  'Runr' => 'Runic',
  'Syre' => '',
  'Lepc' => 'Lepcha',
  'Dsrt' => 'Deseret',
  'Latn' => 'Latin',
  'Shaw' => 'Shavian',
  'Phnx' => 'Phoenician',
  'Nand' => 'Nandinagari',
  'Kitl' => '',
  'Yiii' => 'Yi',
  'Nkdb' => '',
  'Pauc' => 'Pau_Cin_Hau',
  'Geor' => 'Georgian',
  'Latf' => '',
  'Lyci' => 'Lycian',
  'Knda' => 'Kannada',
  'Arab' => 'Arabic',
  'Cyrl' => 'Cyrillic',
  'Lana' => 'Tai_Tham',
  'Hung' => 'Old_Hungarian',
  'Guru' => 'Gurmukhi',
  'Zsye' => '',
  'Phlv' => '',
  'Phli' => 'Inscriptional_Pahlavi',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Tavt' => 'Tai_Viet',
  'Bali' => 'Balinese',
  'Ethi' => 'Ethiopic',
  'Xsux' => 'Cuneiform',
  'Rjng' => 'Rejang',
  'Hano' => 'Hanunoo',
  'Nshu' => 'Nushu',
  'Syrj' => '',
  'Mult' => 'Multani',
  'Osma' => 'Osmanya',
  'Khar' => 'Kharoshthi',
  'Maka' => 'Makasar',
  'Bass' => 'Bassa_Vah',
  'Zxxx' => '',
  'Armn' => 'Armenian',
  'Talu' => 'New_Tai_Lue',
  'Buhd' => 'Buhid',
  'Sinh' => 'Sinhala',
  'Hmng' => 'Pahawh_Hmong',
  'Cher' => 'Cherokee',
  'Wcho' => 'Wancho',
  'Mlym' => 'Malayalam',
  'Ogam' => 'Ogham',
  'Sogo' => 'Old_Sogdian',
  'Cans' => 'Canadian_Aboriginal',
  'Merc' => 'Meroitic_Cursive',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Sylo' => 'Syloti_Nagri',
  'Tale' => 'Tai_Le',
  'Mahj' => 'Mahajani',
  'Mymr' => 'Myanmar',
  'Geok' => 'Georgian',
  'Diak' => 'Dives_Akuru',
  'Goth' => 'Gothic',
  'Syrc' => 'Syriac',
  'Takr' => 'Takri'
};
$ScriptName2ScriptCode = {
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Armenian' => 'Armn',
  'Warang_Citi' => 'Wara',
  'Hanunoo' => 'Hano',
  'Gujarati' => 'Gujr',
  'Common' => 'Zyyy',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Carian' => 'Cari',
  'Tai_Le' => 'Tale',
  'Katakana' => 'Kana',
  'Dives_Akuru' => 'Diak',
  'Ogham' => 'Ogam',
  'Greek' => 'Grek',
  'Myanmar' => 'Mymr',
  'Kaithi' => 'Kthi',
  'Thaana' => 'Thaa',
  'Sora_Sompeng' => 'Sora',
  'Elbasan' => 'Elba',
  'Old_Sogdian' => 'Sogo',
  'Nko' => 'Nkoo',
  'Imperial_Aramaic' => 'Armi',
  'Telugu' => 'Telu',
  'Soyombo' => 'Soyo',
  'Runic' => 'Runr',
  'Lisu' => 'Lisu',
  'Caucasian_Albanian' => 'Aghb',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Han' => 'Hani',
  'Bengali' => 'Beng',
  'Deseret' => 'Dsrt',
  'Sogdian' => 'Sogd',
  'Canadian_Aboriginal' => 'Cans',
  'Old_Permic' => 'Perm',
  'Psalter_Pahlavi' => 'Phlp',
  'Elymaic' => 'Elym',
  'Hiragana' => 'Hira',
  'Lepcha' => 'Lepc',
  'Yi' => 'Yiii',
  'Linear_B' => 'Linb',
  'Medefaidrin' => 'Medf',
  'Dogra' => 'Dogr',
  'Kharoshthi' => 'Khar',
  'Cyrillic' => 'Cyrl',
  'Ethiopic' => 'Ethi',
  'Mro' => 'Mroo',
  'Tibetan' => 'Tibt',
  'Ahom' => 'Ahom',
  'Lao' => 'Laoo',
  'SignWriting' => 'Sgnw',
  'Avestan' => 'Avst',
  'Marchen' => 'Marc',
  'Bamum' => 'Bamu',
  'Bhaiksuki' => 'Bhks',
  'Malayalam' => 'Mlym',
  'Modi' => 'Modi',
  'Gurmukhi' => 'Guru',
  'Nandinagari' => 'Nand',
  'Inherited' => 'Zinh',
  'Pau_Cin_Hau' => 'Pauc',
  'Lydian' => 'Lydi',
  'Siddham' => 'Sidd',
  'Gothic' => 'Goth',
  'Khmer' => 'Khmr',
  'Unknown' => 'Zzzz',
  'Mandaic' => 'Mand',
  'Tagbanwa' => 'Tagb',
  'Gunjala_Gondi' => 'Gong',
  'Latin' => 'Latn',
  'Tirhuta' => 'Tirh',
  'Hatran' => 'Hatr',
  'Ol_Chiki' => 'Olck',
  'Yezidi' => 'Yezi',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Hanifi_Rohingya' => 'Rohg',
  'Osage' => 'Osge',
  'Meroitic_Cursive' => 'Merc',
  'Mongolian' => 'Mong',
  'Syriac' => 'Syrc',
  'Newa' => 'Newa',
  'Kayah_Li' => 'Kali',
  'Bopomofo' => 'Bopo',
  'New_Tai_Lue' => 'Talu',
  '' => 'Zxxx',
  'Cypriot' => 'Cprt',
  'Georgian' => 'Geor',
  'Thai' => 'Thai',
  'Kannada' => 'Knda',
  'Limbu' => 'Limb',
  'Batak' => 'Batk',
  'Cham' => 'Cham',
  'Chorasmian' => 'Chrs',
  'Inscriptional_Pahlavi' => 'Phli',
  'Chakma' => 'Cakm',
  'Mende_Kikakui' => 'Mend',
  'Duployan' => 'Dupl',
  'Glagolitic' => 'Glag',
  'Takri' => 'Takr',
  'Sinhala' => 'Sinh',
  'Old_North_Arabian' => 'Narb',
  'Saurashtra' => 'Saur',
  'Samaritan' => 'Samr',
  'Tagalog' => 'Tglg',
  'Sundanese' => 'Sund',
  'Hebrew' => 'Hebr',
  'Buhid' => 'Buhd',
  'Javanese' => 'Java',
  'Miao' => 'Plrd',
  'Manichaean' => 'Mani',
  'Inscriptional_Parthian' => 'Prti',
  'Grantha' => 'Gran',
  'Osmanya' => 'Osma',
  'Khitan_Small_Script' => 'Kits',
  'Oriya' => 'Orya',
  'Old_Turkic' => 'Orkh',
  'Ugaritic' => 'Ugar',
  'Bassa_Vah' => 'Bass',
  'Braille' => 'Brai',
  'Brahmi' => 'Brah',
  'Sharada' => 'Shrd',
  'Old_South_Arabian' => 'Sarb',
  'Tai_Viet' => 'Tavt',
  'Rejang' => 'Rjng',
  'Tangut' => 'Tang',
  'Hangul' => 'Hang',
  'Coptic' => 'Copt',
  'Vai' => 'Vaii',
  'Phoenician' => 'Phnx',
  'Multani' => 'Mult',
  'Tamil' => 'Taml',
  'Old_Italic' => 'Ital',
  'Zanabazar_Square' => 'Zanb',
  'Nushu' => 'Nshu',
  'Makasar' => 'Maka',
  'Khudawadi' => 'Sind',
  'Adlam' => 'Adlm',
  'Khojki' => 'Khoj',
  'Masaram_Gondi' => 'Gonm',
  'Shavian' => 'Shaw',
  'Cherokee' => 'Cher',
  'Balinese' => 'Bali',
  'Nabataean' => 'Nbat',
  'Mahajani' => 'Mahj',
  'Cuneiform' => 'Xsux',
  'Palmyrene' => 'Palm',
  'Buginese' => 'Bugi',
  'Arabic' => 'Arab',
  'Old_Persian' => 'Xpeo',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Pahawh_Hmong' => 'Hmng',
  'Linear_A' => 'Lina',
  'Meetei_Mayek' => 'Mtei',
  'Syloti_Nagri' => 'Sylo',
  'Wancho' => 'Wcho',
  'Lycian' => 'Lyci',
  'Tifinagh' => 'Tfng',
  'Devanagari' => 'Deva',
  'Tai_Tham' => 'Lana',
  'Old_Hungarian' => 'Hung',
  'Phags_Pa' => 'Phag'
};
$ScriptId2ScriptCode = {
  '305' => 'Khar',
  '503' => 'Hanb',
  '343' => 'Gran',
  '330' => 'Tibt',
  '030' => 'Xpeo',
  '132' => 'Phlp',
  '355' => 'Khmr',
  '159' => 'Nbat',
  '264' => 'Mroo',
  '500' => 'Hani',
  '106' => 'Narb',
  '123' => 'Samr',
  '225' => 'Glag',
  '314' => 'Mahj',
  '126' => 'Palm',
  '335' => 'Lepc',
  '323' => 'Mult',
  '109' => 'Chrs',
  '221' => 'Cyrs',
  '445' => 'Cher',
  '262' => 'Wara',
  '161' => 'Aran',
  '202' => 'Lyci',
  '217' => 'Latf',
  '501' => 'Hans',
  '332' => 'Marc',
  '900' => 'Qaaa',
  '358' => 'Cham',
  '436' => 'Kpel',
  '357' => 'Kali',
  '413' => 'Jpan',
  '324' => 'Modi',
  '353' => 'Tale',
  '101' => 'Merc',
  '403' => 'Cprt',
  '115' => 'Phnx',
  '090' => 'Maya',
  '400' => 'Lina',
  '020' => 'Xsux',
  '124' => 'Armi',
  '322' => 'Khoj',
  '399' => 'Lisu',
  '333' => 'Newa',
  '290' => 'Teng',
  '294' => 'Toto',
  '460' => 'Yiii',
  '367' => 'Bugi',
  '300' => 'Brah',
  '364' => 'Leke',
  '398' => 'Sora',
  '230' => 'Armn',
  '192' => 'Yezi',
  '412' => 'Hrkt',
  '135' => 'Syrc',
  '204' => 'Copt',
  '361' => 'Java',
  '346' => 'Taml',
  '998' => 'Zyyy',
  '366' => 'Maka',
  '949' => 'Qabx',
  '354' => 'Talu',
  '996' => 'Zsym',
  '755' => 'Dupl',
  '344' => 'Saur',
  '331' => 'Phag',
  '100' => 'Mero',
  '520' => 'Tang',
  '167' => 'Rohg',
  '997' => 'Zxxx',
  '370' => 'Tglg',
  '176' => 'Hung',
  '999' => 'Zzzz',
  '160' => 'Arab',
  '175' => 'Orkh',
  '437' => 'Loma',
  '281' => 'Shaw',
  '505' => 'Kitl',
  '352' => 'Thai',
  '362' => 'Sund',
  '502' => 'Hant',
  '095' => 'Sgnw',
  '372' => 'Buhd',
  '220' => 'Cyrl',
  '287' => 'Kore',
  '402' => 'Cpmn',
  '265' => 'Medf',
  '326' => 'Tirh',
  '348' => 'Sinh',
  '356' => 'Laoo',
  '120' => 'Tfng',
  '239' => 'Aghb',
  '620' => 'Roro',
  '311' => 'Nand',
  '302' => 'Sidd',
  '070' => 'Egyd',
  '321' => 'Takr',
  '319' => 'Shrd',
  '550' => 'Blis',
  '420' => 'Nkgb',
  '325' => 'Beng',
  '350' => 'Mymr',
  '438' => 'Mend',
  '510' => 'Jurc',
  '329' => 'Soyo',
  '200' => 'Grek',
  '291' => 'Cirt',
  '315' => 'Deva',
  '360' => 'Bali',
  '226' => 'Elba',
  '040' => 'Ugar',
  '219' => 'Osge',
  '334' => 'Bhks',
  '142' => 'Sogo',
  '165' => 'Nkoo',
  '170' => 'Thaa',
  '138' => 'Syre',
  '327' => 'Orya',
  '133' => 'Phlv',
  '451' => 'Hmnp',
  '310' => 'Guru',
  '401' => 'Linb',
  '131' => 'Phli',
  '994' => 'Zinh',
  '210' => 'Ital',
  '328' => 'Dogr',
  '050' => 'Egyp',
  '320' => 'Gujr',
  '450' => 'Hmng',
  '313' => 'Gonm',
  '206' => 'Goth',
  '116' => 'Lydi',
  '410' => 'Hira',
  '280' => 'Visp',
  '347' => 'Mlym',
  '145' => 'Mong',
  '430' => 'Ethi',
  '137' => 'Syrj',
  '241' => 'Geok',
  '250' => 'Dsrt',
  '342' => 'Diak',
  '312' => 'Gong',
  '282' => 'Plrd',
  '317' => 'Kthi',
  '127' => 'Hatr',
  '130' => 'Prti',
  '285' => 'Bopo',
  '530' => 'Shui',
  '227' => 'Perm',
  '211' => 'Runr',
  '373' => 'Tagb',
  '351' => 'Lana',
  '435' => 'Bamu',
  '365' => 'Batk',
  '218' => 'Moon',
  '140' => 'Mand',
  '261' => 'Olck',
  '283' => 'Wcho',
  '293' => 'Piqd',
  '105' => 'Sarb',
  '349' => 'Cakm',
  '166' => 'Adlm',
  '240' => 'Geor',
  '371' => 'Hano',
  '480' => 'Wole',
  '085' => 'Nkdb',
  '284' => 'Jamo',
  '259' => 'Bass',
  '260' => 'Osma',
  '136' => 'Syrn',
  '212' => 'Ogam',
  '339' => 'Zanb',
  '318' => 'Sind',
  '216' => 'Latg',
  '345' => 'Knda',
  '134' => 'Avst',
  '499' => 'Nshu',
  '060' => 'Egyh',
  '363' => 'Rjng',
  '610' => 'Inds',
  '080' => 'Hluw',
  '411' => 'Kana',
  '292' => 'Sara',
  '263' => 'Pauc',
  '286' => 'Hang',
  '440' => 'Cans',
  '288' => 'Kits',
  '359' => 'Tavt',
  '336' => 'Limb',
  '316' => 'Sylo',
  '128' => 'Elym',
  '201' => 'Cari',
  '141' => 'Sogd',
  '125' => 'Hebr',
  '340' => 'Telu',
  '139' => 'Mani',
  '338' => 'Ahom',
  '337' => 'Mtei',
  '215' => 'Latn',
  '993' => 'Zsye',
  '470' => 'Vaii',
  '439' => 'Afak',
  '570' => 'Brai',
  '995' => 'Zmth'
};
$ScriptCode2EnglishName = {
  'Mero' => 'Meroitic Hieroglyphs',
  'Gong' => 'Gunjala Gondi',
  'Shui' => 'Shuishu',
  'Leke' => 'Leke',
  'Java' => 'Javanese',
  'Elym' => 'Elymaic',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Avst' => 'Avestan',
  'Kali' => 'Kayah Li',
  'Perm' => 'Old Permic',
  'Egyd' => 'Egyptian demotic',
  'Vaii' => 'Vai',
  'Tirh' => 'Tirhuta',
  'Zmth' => 'Mathematical notation',
  'Wole' => 'Woleai',
  'Orya' => 'Oriya (Odia)',
  'Nbat' => 'Nabataean',
  'Cari' => 'Carian',
  'Zzzz' => 'Code for uncoded script',
  'Toto' => 'Toto',
  'Adlm' => 'Adlam',
  'Rohg' => 'Hanifi Rohingya',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Cakm' => 'Chakma',
  'Mani' => 'Manichaean',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Teng' => 'Tengwar',
  'Ugar' => 'Ugaritic',
  'Egyh' => 'Egyptian hieratic',
  'Hebr' => 'Hebrew',
  'Linb' => 'Linear B',
  'Palm' => 'Palmyrene',
  'Lisu' => 'Lisu (Fraser)',
  'Zyyy' => 'Code for undetermined script',
  'Samr' => 'Samaritan',
  'Marc' => 'Marchen',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Lina' => 'Linear A',
  'Grek' => 'Greek',
  'Syrn' => 'Syriac (Eastern variant)',
  'Dogr' => 'Dogra',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Tibt' => 'Tibetan',
  'Soyo' => 'Soyombo',
  'Tagb' => 'Tagbanwa',
  'Thaa' => 'Thaana',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Ahom' => 'Ahom, Tai Ahom',
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Qabx' => 'Reserved for private use (end)',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Beng' => 'Bengali (Bangla)',
  'Limb' => 'Limbu',
  'Cprt' => 'Cypriot syllabary',
  'Bamu' => 'Bamum',
  'Deva' => 'Devanagari (Nagari)',
  'Copt' => 'Coptic',
  'Phlp' => 'Psalter Pahlavi',
  'Gran' => 'Grantha',
  'Yezi' => 'Yezidi',
  'Qaaa' => 'Reserved for private use (start)',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Aran' => 'Arabic (Nastaliq variant)',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Bhks' => 'Bhaiksuki',
  'Bugi' => 'Buginese',
  'Xpeo' => 'Old Persian',
  'Mand' => 'Mandaic, Mandaean',
  'Mroo' => 'Mro, Mru',
  'Gonm' => 'Masaram Gondi',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Gujr' => 'Gujarati',
  'Osge' => 'Osage',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Hant' => 'Han (Traditional variant)',
  'Taml' => 'Tamil',
  'Hira' => 'Hiragana',
  'Tfng' => 'Tifinagh (Berber)',
  'Loma' => 'Loma',
  'Hans' => 'Han (Simplified variant)',
  'Chrs' => 'Chorasmian',
  'Cpmn' => 'Cypro-Minoan',
  'Sind' => 'Khudawadi, Sindhi',
  'Sarb' => 'Old South Arabian',
  'Sgnw' => 'SignWriting',
  'Saur' => 'Saurashtra',
  'Mong' => 'Mongolian',
  'Lydi' => 'Lydian',
  'Roro' => 'Rongorongo',
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Aghb' => 'Caucasian Albanian',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Brai' => 'Braille',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Phag' => 'Phags-pa',
  'Kpel' => 'Kpelle',
  'Jurc' => 'Jurchen',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Tang' => 'Tangut',
  'Khoj' => 'Khojki',
  'Plrd' => 'Miao (Pollard)',
  'Visp' => 'Visible Speech',
  'Elba' => 'Elbasan',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Khmr' => 'Khmer',
  'Laoo' => 'Lao',
  'Nkoo' => "N\x{2019}Ko",
  'Zsym' => 'Symbols',
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Latg' => 'Latin (Gaelic variant)',
  'Glag' => 'Glagolitic',
  'Zinh' => 'Code for inherited script',
  'Cirt' => 'Cirth',
  'Hatr' => 'Hatran',
  'Kits' => 'Khitan small script',
  'Brah' => 'Brahmi',
  'Bopo' => 'Bopomofo',
  'Sara' => 'Sarati',
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Kthi' => 'Kaithi',
  'Maya' => 'Mayan hieroglyphs',
  'Inds' => 'Indus (Harappan)',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Sund' => 'Sundanese',
  'Cham' => 'Cham',
  'Telu' => 'Telugu',
  'Thai' => 'Thai',
  'Afak' => 'Afaka',
  'Armi' => 'Imperial Aramaic',
  'Mend' => 'Mende Kikakui',
  'Kana' => 'Katakana',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Blis' => 'Blissymbols',
  'Sogd' => 'Sogdian',
  'Prti' => 'Inscriptional Parthian',
  'Batk' => 'Batak',
  'Sora' => 'Sora Sompeng',
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Syre' => 'Syriac (Estrangelo variant)',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Runr' => 'Runic',
  'Nand' => 'Nandinagari',
  'Kitl' => 'Khitan large script',
  'Yiii' => 'Yi',
  'Pauc' => 'Pau Cin Hau',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Dsrt' => 'Deseret (Mormon)',
  'Latn' => 'Latin',
  'Shaw' => 'Shavian (Shaw)',
  'Phnx' => 'Phoenician',
  'Arab' => 'Arabic',
  'Cyrl' => 'Cyrillic',
  'Latf' => 'Latin (Fraktur variant)',
  'Lyci' => 'Lycian',
  'Knda' => 'Kannada',
  'Zsye' => 'Symbols (Emoji variant)',
  'Lana' => 'Tai Tham (Lanna)',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Guru' => 'Gurmukhi',
  'Bali' => 'Balinese',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Phlv' => 'Book Pahlavi',
  'Phli' => 'Inscriptional Pahlavi',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Tavt' => 'Tai Viet',
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Bass' => 'Bassa Vah',
  'Nshu' => "N\x{fc}shu",
  'Syrj' => 'Syriac (Western variant)',
  'Mult' => 'Multani',
  'Osma' => 'Osmanya',
  'Maka' => 'Makasar',
  'Khar' => 'Kharoshthi',
  'Armn' => 'Armenian',
  'Talu' => 'New Tai Lue',
  'Buhd' => 'Buhid',
  'Sinh' => 'Sinhala',
  'Zxxx' => 'Code for unwritten documents',
  'Wcho' => 'Wancho',
  'Mlym' => 'Malayalam',
  'Ogam' => 'Ogham',
  'Hmng' => 'Pahawh Hmong',
  'Cher' => 'Cherokee',
  'Egyp' => 'Egyptian hieroglyphs',
  'Sylo' => 'Syloti Nagri',
  'Mahj' => 'Mahajani',
  'Tale' => 'Tai Le',
  'Sogo' => 'Old Sogdian',
  'Merc' => 'Meroitic Cursive',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Mymr' => 'Myanmar (Burmese)',
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Diak' => 'Dives Akuru',
  'Goth' => 'Gothic',
  'Syrc' => 'Syriac'
};
$ScriptCode2FrenchName = {
  'Sinh' => 'singhalais',
  'Armn' => "arm\x{e9}nien",
  'Talu' => "nouveau ta\x{ef}-lue",
  'Buhd' => 'bouhide',
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Ogam' => 'ogam',
  'Wcho' => 'wantcho',
  'Mlym' => "malay\x{e2}lam",
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Hmng' => 'pahawh hmong',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Tale' => "ta\x{ef}-le",
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Sogo' => 'ancien sogdien',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Diak' => 'dives akuru',
  'Syrc' => 'syriaque',
  'Goth' => 'gotique',
  'Mymr' => 'birman',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Guru' => "gourmoukh\x{ee}",
  'Lana' => "ta\x{ef} tham (lanna)",
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Bali' => 'balinais',
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Phli' => 'pehlevi des inscriptions',
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Phlv' => 'pehlevi des livres',
  'Hano' => "hanoun\x{f3}o",
  'Rjng' => 'redjang (kaganga)',
  'Bass' => 'bassa',
  'Osma' => 'osmanais',
  'Syrj' => 'syriaque (variante occidentale)',
  'Mult' => "multan\x{ee}",
  'Khar' => "kharochth\x{ee}",
  'Maka' => 'makassar',
  'Nshu' => "n\x{fc}shu",
  'Prti' => 'parthe des inscriptions',
  'Batk' => 'batik',
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Sora' => 'sora sompeng',
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Runr' => 'runique',
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Kitl' => "grande \x{e9}criture khitan",
  'Yiii' => 'yi',
  'Pauc' => 'paou chin haou',
  'Nkdb' => 'naxi dongba',
  'Phnx' => "ph\x{e9}nicien",
  'Latn' => 'latin',
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Shaw' => 'shavien (Shaw)',
  'Arab' => 'arabe',
  'Cyrl' => 'cyrillique',
  'Knda' => 'kannara (canara)',
  'Latf' => "latin (variante bris\x{e9}e)",
  'Lyci' => 'lycien',
  'Zsym' => 'symboles',
  'Nkgb' => 'naxi geba, nakhi geba',
  'Visp' => 'parole visible',
  'Laoo' => 'laotien',
  'Elba' => 'elbasan',
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Nkoo' => "n\x{2019}ko",
  'Khmr' => 'khmer',
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Glag' => 'glagolitique',
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Cirt' => 'cirth',
  'Hatr' => "hatr\x{e9}nien",
  'Kits' => "petite \x{e9}criture khitan",
  'Bopo' => 'bopomofo',
  'Sara' => 'sarati',
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Brah' => 'brahma',
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Inds' => 'indus',
  'Kthi' => "kaith\x{ee}",
  'Cham' => "cham (\x{10d}am, tcham)",
  'Sund' => 'sundanais',
  'Telu' => "t\x{e9}lougou",
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Thai' => "tha\x{ef}",
  'Afak' => 'afaka',
  'Blis' => 'symboles Bliss',
  'Sogd' => 'sogdien',
  'Kana' => 'katakana',
  'Mend' => "mend\x{e9} kikakui",
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Mand' => "mand\x{e9}en",
  'Gonm' => "masaram gond\x{ee}",
  'Mroo' => 'mro',
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Sidd' => 'siddham',
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Osge' => 'osage',
  'Taml' => 'tamoul',
  'Hira' => 'hiragana',
  'Loma' => 'loma',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Chrs' => 'chorasmien',
  'Cpmn' => 'syllabaire chypro-minoen',
  'Aghb' => 'aghbanien',
  'Roro' => 'rongorongo',
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Narb' => 'nord-arabique',
  'Mtei' => 'meitei mayek',
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Sarb' => 'sud-arabique, himyarite',
  'Mong' => 'mongol',
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Saur' => 'saurachtra',
  'Lydi' => 'lydien',
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Phag' => "\x{2019}phags pa",
  'Brai' => 'braille',
  'Hmnp' => 'nyiakeng puachue hmong',
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Khoj' => "khojk\x{ee}",
  'Plrd' => 'miao (Pollard)',
  'Jurc' => 'jurchen',
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Tang' => 'tangoute',
  'Ahom' => "\x{e2}hom",
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Thaa' => "th\x{e2}na",
  'Limb' => 'limbou',
  'Shrd' => 'charada, shard',
  'Tglg' => 'tagal (baybayin, alibata)',
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Beng' => "bengal\x{ee} (bangla)",
  'Bamu' => 'bamoum',
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Copt' => 'copte',
  'Cprt' => 'syllabaire chypriote',
  'Phlp' => 'pehlevi des psautiers',
  'Gran' => 'grantha',
  'Orkh' => 'orkhon',
  'Wara' => 'warang citi',
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Yezi' => "y\x{e9}zidi",
  'Aran' => 'arabe (variante nastalique)',
  'Modi' => "mod\x{ee}",
  'Bugi' => 'bouguis',
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Olck' => 'ol tchiki',
  'Rohg' => 'hanifi rohingya',
  'Cakm' => 'chakma',
  'Mani' => "manich\x{e9}en",
  'Teng' => 'tengwar',
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Hebr' => "h\x{e9}breu",
  'Ugar' => 'ougaritique',
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Linb' => "lin\x{e9}aire B",
  'Palm' => "palmyr\x{e9}nien",
  'Lisu' => 'lisu (Fraser)',
  'Marc' => 'marchen',
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Samr' => 'samaritain',
  'Moon' => "\x{e9}criture Moon",
  'Syrn' => 'syriaque (variante orientale)',
  'Grek' => 'grec',
  'Lina' => "lin\x{e9}aire A",
  'Soyo' => 'soyombo',
  'Tagb' => 'tagbanoua',
  'Dogr' => 'dogra',
  'Tibt' => "tib\x{e9}tain",
  'Zanb' => 'zanabazar quadratique',
  'Gong' => "gunjala gond\x{ee}",
  'Leke' => "l\x{e9}k\x{e9}",
  'Shui' => 'shuishu',
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Java' => 'javanais',
  'Perm' => 'ancien permien',
  'Kali' => 'kayah li',
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Avst' => 'avestique',
  'Vaii' => "va\x{ef}",
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Zmth' => "notation math\x{e9}matique",
  'Tirh' => 'tirhouta',
  'Wole' => "wol\x{e9}a\x{ef}",
  'Orya' => "oriy\x{e2} (odia)",
  'Nbat' => "nabat\x{e9}en",
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Cari' => 'carien',
  'Toto' => 'toto',
  'Adlm' => 'adlam'
};
$ScriptCodeVersion = {
  'Linb' => '4.0',
  'Palm' => '7.0',
  'Lisu' => '5.2',
  'Hebr' => '1.1',
  'Ugar' => '4.0',
  'Egyh' => '5.2',
  'Teng' => '',
  'Kore' => '1.1',
  'Rohg' => '11.0',
  'Olck' => '5.1',
  'Mani' => '7.0',
  'Cakm' => '6.1',
  'Soyo' => '10.0',
  'Tagb' => '3.2',
  'Dogr' => '11.0',
  'Tibt' => '2.0',
  'Zanb' => '10.0',
  'Grek' => '1.1',
  'Syrn' => '3.0',
  'Lina' => '7.0',
  'Moon' => '',
  'Marc' => '9.0',
  'Zyyy' => '',
  'Samr' => '5.2',
  'Vaii' => '5.1',
  'Egyd' => '',
  'Perm' => '7.0',
  'Kali' => '5.1',
  'Avst' => '5.2',
  'Cyrs' => '1.1',
  'Java' => '5.2',
  'Elym' => '12.0',
  'Gong' => '11.0',
  'Leke' => '',
  'Shui' => '',
  'Mero' => '6.1',
  'Adlm' => '9.0',
  'Zzzz' => '',
  'Cari' => '5.1',
  'Toto' => '',
  'Orya' => '1.1',
  'Nbat' => '7.0',
  'Zmth' => '3.2',
  'Tirh' => '7.0',
  'Wole' => '',
  'Hira' => '1.1',
  'Taml' => '1.1',
  'Tfng' => '4.1',
  'Loma' => '',
  'Hans' => '1.1',
  'Sidd' => '7.0',
  'Osge' => '9.0',
  'Hant' => '1.1',
  'Ital' => '3.1',
  'Gujr' => '1.1',
  'Mand' => '6.0',
  'Gonm' => '10.0',
  'Mroo' => '7.0',
  'Xpeo' => '4.1',
  'Khoj' => '7.0',
  'Plrd' => '6.1',
  'Jurc' => '',
  'Tang' => '9.0',
  'Piqd' => '',
  'Phag' => '5.0',
  'Kpel' => '',
  'Brai' => '3.0',
  'Hmnp' => '12.0',
  'Hluw' => '8.0',
  'Aghb' => '7.0',
  'Roro' => '',
  'Jpan' => '1.1',
  'Narb' => '7.0',
  'Mtei' => '5.2',
  'Sind' => '7.0',
  'Sarb' => '5.2',
  'Saur' => '5.1',
  'Sgnw' => '8.0',
  'Lydi' => '5.1',
  'Mong' => '3.0',
  'Chrs' => '13.0',
  'Cpmn' => '',
  'Phlp' => '7.0',
  'Bamu' => '5.2',
  'Copt' => '4.1',
  'Deva' => '1.1',
  'Cprt' => '4.0',
  'Limb' => '4.0',
  'Shrd' => '6.1',
  'Tglg' => '3.2',
  'Qabx' => '',
  'Beng' => '1.1',
  'Medf' => '11.0',
  'Ahom' => '8.0',
  'Thaa' => '3.0',
  'Bugi' => '4.1',
  'Bhks' => '9.0',
  'Orkh' => '5.2',
  'Wara' => '7.0',
  'Qaaa' => '',
  'Yezi' => '13.0',
  'Modi' => '7.0',
  'Aran' => '1.1',
  'Gran' => '7.0',
  'Runr' => '3.0',
  'Lepc' => '5.1',
  'Syre' => '3.0',
  'Hang' => '1.1',
  'Sora' => '6.1',
  'Prti' => '5.2',
  'Batk' => '6.0',
  'Knda' => '1.1',
  'Latf' => '1.1',
  'Lyci' => '5.1',
  'Arab' => '1.1',
  'Cyrl' => '1.1',
  'Phnx' => '5.0',
  'Latn' => '1.1',
  'Dsrt' => '3.1',
  'Shaw' => '4.0',
  'Geor' => '1.1',
  'Kitl' => '',
  'Nand' => '12.0',
  'Yiii' => '3.0',
  'Nkdb' => '',
  'Pauc' => '7.0',
  'Bopo' => '1.1',
  'Sara' => '',
  'Jamo' => '1.1',
  'Newa' => '9.0',
  'Brah' => '6.0',
  'Hatr' => '8.0',
  'Kits' => '13.0',
  'Latg' => '1.1',
  'Glag' => '4.1',
  'Cirt' => '',
  'Zinh' => '',
  'Zsym' => '1.1',
  'Nkgb' => '',
  'Visp' => '',
  'Elba' => '7.0',
  'Hanb' => '1.1',
  'Laoo' => '1.1',
  'Khmr' => '3.0',
  'Nkoo' => '5.0',
  'Blis' => '',
  'Sogd' => '11.0',
  'Kana' => '1.1',
  'Mend' => '7.0',
  'Hani' => '1.1',
  'Armi' => '5.2',
  'Thai' => '1.1',
  'Afak' => '',
  'Sund' => '5.1',
  'Cham' => '5.1',
  'Telu' => '1.1',
  'Dupl' => '7.0',
  'Maya' => '',
  'Inds' => '',
  'Kthi' => '5.2',
  'Cher' => '3.0',
  'Hmng' => '7.0',
  'Ogam' => '3.0',
  'Wcho' => '12.0',
  'Mlym' => '1.1',
  'Zxxx' => '',
  'Sinh' => '3.0',
  'Talu' => '4.1',
  'Armn' => '1.1',
  'Buhd' => '3.2',
  'Diak' => '13.0',
  'Geok' => '1.1',
  'Syrc' => '3.0',
  'Goth' => '3.1',
  'Mymr' => '3.0',
  'Takr' => '6.1',
  'Cans' => '3.0',
  'Merc' => '6.1',
  'Sogo' => '11.0',
  'Sylo' => '4.1',
  'Mahj' => '7.0',
  'Tale' => '4.0',
  'Egyp' => '5.2',
  'Phli' => '5.2',
  'Tavt' => '5.2',
  'Hrkt' => '1.1',
  'Phlv' => '',
  'Xsux' => '5.0',
  'Bali' => '5.0',
  'Ethi' => '3.0',
  'Guru' => '1.1',
  'Lana' => '5.2',
  'Hung' => '8.0',
  'Zsye' => '6.0',
  'Mult' => '8.0',
  'Syrj' => '3.0',
  'Osma' => '4.0',
  'Khar' => '4.1',
  'Maka' => '11.0',
  'Nshu' => '10.0',
  'Bass' => '7.0',
  'Hano' => '3.2',
  'Rjng' => '5.1'
};
$ScriptCodeDate = {
  'Bugi' => '2006-06-21
',
  'Bhks' => '2016-12-05
',
  'Gran' => '2014-11-15
',
  'Orkh' => '2009-06-01
',
  'Wara' => '2014-11-15
',
  'Qaaa' => '2004-05-29
',
  'Yezi' => '2019-08-19
',
  'Modi' => '2014-11-15
',
  'Aran' => '2014-11-15
',
  'Bamu' => '2009-06-01
',
  'Copt' => '2006-06-21
',
  'Deva' => '2004-05-01
',
  'Cprt' => '2017-07-26
',
  'Phlp' => '2014-11-15
',
  'Ahom' => '2015-07-07
',
  'Medf' => '2016-12-05
',
  'Thaa' => '2004-05-01
',
  'Limb' => '2004-05-29
',
  'Tglg' => '2009-02-23
',
  'Qabx' => '2004-05-29
',
  'Shrd' => '2012-02-06
',
  'Beng' => '2016-12-05
',
  'Phag' => '2006-10-10
',
  'Kpel' => '2010-03-26
',
  'Brai' => '2004-05-01
',
  'Hmnp' => '2017-07-26
',
  'Hluw' => '2015-07-07
',
  'Plrd' => '2012-02-06
',
  'Khoj' => '2014-11-15
',
  'Jurc' => '2010-12-21
',
  'Tang' => '2016-12-05
',
  'Piqd' => '2015-12-16
',
  'Chrs' => '2019-08-19
',
  'Cpmn' => '2017-07-26
',
  'Aghb' => '2014-11-15
',
  'Roro' => '2004-05-01
',
  'Jpan' => '2006-06-21
',
  'Narb' => '2014-11-15
',
  'Mtei' => '2009-06-01
',
  'Sind' => '2014-11-15
',
  'Sarb' => '2009-06-01
',
  'Lydi' => '2007-07-02
',
  'Sgnw' => '2015-07-07
',
  'Saur' => '2007-07-02
',
  'Mong' => '2004-05-01
',
  'Sidd' => '2014-11-15
',
  'Hant' => '2004-05-29
',
  'Osge' => '2016-12-05
',
  'Hira' => '2004-05-01
',
  'Taml' => '2004-05-01
',
  'Loma' => '2010-03-26
',
  'Tfng' => '2006-06-21
',
  'Hans' => '2004-05-29
',
  'Mand' => '2010-07-23
',
  'Mroo' => '2016-12-05
',
  'Gonm' => '2017-07-26
',
  'Xpeo' => '2006-06-21
',
  'Ital' => '2004-05-29
',
  'Gujr' => '2004-05-01
',
  'Cari' => '2007-07-02
',
  'Zzzz' => '2006-10-10
',
  'Toto' => '2020-04-16
',
  'Adlm' => '2016-12-05
',
  'Tirh' => '2014-11-15
',
  'Zmth' => '2007-11-26
',
  'Wole' => '2010-12-21
',
  'Orya' => '2016-12-05
',
  'Nbat' => '2014-11-15
',
  'Kali' => '2007-07-02
',
  'Perm' => '2014-11-15
',
  'Cyrs' => '2004-05-01
',
  'Avst' => '2009-06-01
',
  'Vaii' => '2007-07-02
',
  'Egyd' => '2004-05-01
',
  'Gong' => '2016-12-05
',
  'Leke' => '2015-07-07
',
  'Shui' => '2017-07-26
',
  'Mero' => '2012-02-06
',
  'Java' => '2009-06-01
',
  'Elym' => '2018-08-26
',
  'Grek' => '2004-05-01
',
  'Syrn' => '2004-05-01
',
  'Lina' => '2014-11-15
',
  'Soyo' => '2017-07-26
',
  'Tagb' => '2004-05-01
',
  'Dogr' => '2016-12-05
',
  'Tibt' => '2004-05-01
',
  'Zanb' => '2017-07-26
',
  'Marc' => '2016-12-05
',
  'Samr' => '2009-06-01
',
  'Zyyy' => '2004-05-29
',
  'Moon' => '2006-12-11
',
  'Hebr' => '2004-05-01
',
  'Ugar' => '2004-05-01
',
  'Egyh' => '2004-05-01
',
  'Linb' => '2004-05-29
',
  'Palm' => '2014-11-15
',
  'Lisu' => '2009-06-01
',
  'Olck' => '2007-07-02
',
  'Rohg' => '2017-11-21
',
  'Mani' => '2014-11-15
',
  'Cakm' => '2012-02-06
',
  'Teng' => '2004-05-01
',
  'Kore' => '2007-06-13
',
  'Bass' => '2014-11-15
',
  'Osma' => '2004-05-01
',
  'Syrj' => '2004-05-01
',
  'Mult' => '2015-07-07
',
  'Maka' => '2016-12-05
',
  'Khar' => '2006-06-21
',
  'Nshu' => '2017-07-26
',
  'Hano' => '2004-05-29
',
  'Rjng' => '2009-02-23
',
  'Xsux' => '2006-10-10
',
  'Bali' => '2006-10-10
',
  'Ethi' => '2004-10-25
',
  'Phli' => '2009-06-01
',
  'Hrkt' => '2011-06-21
',
  'Tavt' => '2009-06-01
',
  'Phlv' => '2007-07-15
',
  'Zsye' => '2015-12-16
',
  'Guru' => '2004-05-01
',
  'Lana' => '2009-06-01
',
  'Hung' => '2015-07-07
',
  'Takr' => '2012-02-06
',
  'Diak' => '2019-08-19
',
  'Geok' => '2012-10-16
',
  'Goth' => '2004-05-01
',
  'Syrc' => '2004-05-01
',
  'Mymr' => '2004-05-01
',
  'Sylo' => '2006-06-21
',
  'Tale' => '2004-10-25
',
  'Mahj' => '2014-11-15
',
  'Egyp' => '2009-06-01
',
  'Cans' => '2004-05-29
',
  'Merc' => '2012-02-06
',
  'Sogo' => '2017-11-21
',
  'Ogam' => '2004-05-01
',
  'Wcho' => '2017-07-26
',
  'Mlym' => '2004-05-01
',
  'Cher' => '2004-05-01
',
  'Hmng' => '2014-11-15
',
  'Sinh' => '2004-05-01
',
  'Talu' => '2006-06-21
',
  'Armn' => '2004-05-01
',
  'Buhd' => '2004-05-01
',
  'Zxxx' => '2011-06-21
',
  'Armi' => '2009-06-01
',
  'Thai' => '2004-05-01
',
  'Afak' => '2010-12-21
',
  'Blis' => '2004-05-01
',
  'Sogd' => '2017-11-21
',
  'Kana' => '2004-05-01
',
  'Mend' => '2014-11-15
',
  'Hani' => '2009-02-23
',
  'Maya' => '2004-05-01
',
  'Inds' => '2004-05-01
',
  'Kthi' => '2009-06-01
',
  'Cham' => '2009-11-11
',
  'Sund' => '2007-07-02
',
  'Telu' => '2004-05-01
',
  'Dupl' => '2014-11-15
',
  'Hatr' => '2015-07-07
',
  'Kits' => '2015-07-15
',
  'Sara' => '2004-05-29
',
  'Bopo' => '2004-05-01
',
  'Jamo' => '2016-01-19
',
  'Newa' => '2016-12-05
',
  'Brah' => '2010-07-23
',
  'Zsym' => '2007-11-26
',
  'Nkgb' => '2017-07-26
',
  'Visp' => '2004-05-01
',
  'Elba' => '2014-11-15
',
  'Hanb' => '2016-01-19
',
  'Laoo' => '2004-05-01
',
  'Nkoo' => '2006-10-10
',
  'Khmr' => '2004-05-29
',
  'Latg' => '2004-05-01
',
  'Glag' => '2006-06-21
',
  'Zinh' => '2009-02-23
',
  'Cirt' => '2004-05-01
',
  'Arab' => '2004-05-01
',
  'Cyrl' => '2004-05-01
',
  'Knda' => '2004-05-29
',
  'Latf' => '2004-05-01
',
  'Lyci' => '2007-07-02
',
  'Geor' => '2016-12-05
',
  'Kitl' => '2015-07-15
',
  'Nand' => '2018-08-26
',
  'Yiii' => '2004-05-01
',
  'Pauc' => '2014-11-15
',
  'Nkdb' => '2017-07-26
',
  'Phnx' => '2006-10-10
',
  'Latn' => '2004-05-01
',
  'Dsrt' => '2004-05-01
',
  'Shaw' => '2004-05-01
',
  'Lepc' => '2007-07-02
',
  'Syre' => '2004-05-01
',
  'Runr' => '2004-05-01
',
  'Batk' => '2010-07-23
',
  'Prti' => '2009-06-01
',
  'Hang' => '2004-05-29
',
  'Sora' => '2012-02-06
'
};
$ScriptCodeId = {
  'Latf' => '217',
  'Lyci' => '202',
  'Knda' => '345',
  'Arab' => '160',
  'Cyrl' => '220',
  'Latn' => '215',
  'Dsrt' => '250',
  'Shaw' => '281',
  'Phnx' => '115',
  'Kitl' => '505',
  'Nand' => '311',
  'Nkdb' => '085',
  'Yiii' => '460',
  'Pauc' => '263',
  'Geor' => '240',
  'Runr' => '211',
  'Syre' => '138',
  'Lepc' => '335',
  'Sora' => '398',
  'Hang' => '286',
  'Prti' => '130',
  'Batk' => '365',
  'Mend' => '438',
  'Kana' => '411',
  'Hani' => '500',
  'Blis' => '550',
  'Sogd' => '141',
  'Thai' => '352',
  'Afak' => '439',
  'Armi' => '124',
  'Dupl' => '755',
  'Sund' => '362',
  'Cham' => '358',
  'Telu' => '340',
  'Kthi' => '317',
  'Maya' => '090',
  'Inds' => '610',
  'Brah' => '300',
  'Sara' => '292',
  'Bopo' => '285',
  'Newa' => '333',
  'Jamo' => '284',
  'Hatr' => '127',
  'Kits' => '288',
  'Latg' => '216',
  'Glag' => '225',
  'Cirt' => '291',
  'Zinh' => '994',
  'Visp' => '280',
  'Khmr' => '355',
  'Hanb' => '503',
  'Elba' => '226',
  'Laoo' => '356',
  'Nkoo' => '165',
  'Zsym' => '996',
  'Nkgb' => '420',
  'Mymr' => '350',
  'Diak' => '342',
  'Geok' => '241',
  'Goth' => '206',
  'Syrc' => '135',
  'Takr' => '321',
  'Sogo' => '142',
  'Cans' => '440',
  'Merc' => '101',
  'Egyp' => '050',
  'Sylo' => '316',
  'Mahj' => '314',
  'Tale' => '353',
  'Hmng' => '450',
  'Cher' => '445',
  'Wcho' => '283',
  'Mlym' => '347',
  'Ogam' => '212',
  'Zxxx' => '997',
  'Talu' => '354',
  'Armn' => '230',
  'Buhd' => '372',
  'Sinh' => '348',
  'Nshu' => '499',
  'Mult' => '323',
  'Syrj' => '137',
  'Osma' => '260',
  'Khar' => '305',
  'Maka' => '366',
  'Bass' => '259',
  'Rjng' => '363',
  'Hano' => '371',
  'Phlv' => '133',
  'Phli' => '131',
  'Tavt' => '359',
  'Hrkt' => '412',
  'Bali' => '360',
  'Ethi' => '430',
  'Xsux' => '020',
  'Lana' => '351',
  'Hung' => '176',
  'Guru' => '310',
  'Zsye' => '993',
  'Dogr' => '328',
  'Tibt' => '330',
  'Zanb' => '339',
  'Soyo' => '329',
  'Tagb' => '373',
  'Lina' => '400',
  'Grek' => '200',
  'Syrn' => '136',
  'Moon' => '218',
  'Zyyy' => '998',
  'Samr' => '123',
  'Marc' => '332',
  'Linb' => '401',
  'Palm' => '126',
  'Lisu' => '399',
  'Ugar' => '040',
  'Egyh' => '060',
  'Hebr' => '125',
  'Kore' => '287',
  'Teng' => '290',
  'Rohg' => '167',
  'Olck' => '261',
  'Cakm' => '349',
  'Mani' => '139',
  'Adlm' => '166',
  'Cari' => '201',
  'Zzzz' => '999',
  'Toto' => '294',
  'Orya' => '327',
  'Nbat' => '159',
  'Tirh' => '326',
  'Zmth' => '995',
  'Wole' => '480',
  'Egyd' => '070',
  'Vaii' => '470',
  'Cyrs' => '221',
  'Avst' => '134',
  'Kali' => '357',
  'Perm' => '227',
  'Java' => '361',
  'Elym' => '128',
  'Mero' => '100',
  'Gong' => '312',
  'Leke' => '364',
  'Shui' => '530',
  'Jurc' => '510',
  'Tang' => '520',
  'Piqd' => '293',
  'Plrd' => '282',
  'Khoj' => '322',
  'Brai' => '570',
  'Hmnp' => '451',
  'Hluw' => '080',
  'Kpel' => '436',
  'Phag' => '331',
  'Sarb' => '105',
  'Sind' => '318',
  'Saur' => '344',
  'Sgnw' => '095',
  'Mong' => '145',
  'Lydi' => '116',
  'Roro' => '620',
  'Aghb' => '239',
  'Jpan' => '413',
  'Narb' => '106',
  'Mtei' => '337',
  'Chrs' => '109',
  'Cpmn' => '402',
  'Taml' => '346',
  'Hira' => '410',
  'Tfng' => '120',
  'Loma' => '437',
  'Hans' => '501',
  'Sidd' => '302',
  'Osge' => '219',
  'Hant' => '502',
  'Ital' => '210',
  'Gujr' => '320',
  'Xpeo' => '030',
  'Mand' => '140',
  'Mroo' => '264',
  'Gonm' => '313',
  'Bhks' => '334',
  'Bugi' => '367',
  'Qaaa' => '900',
  'Yezi' => '192',
  'Modi' => '324',
  'Aran' => '161',
  'Wara' => '262',
  'Orkh' => '175',
  'Gran' => '343',
  'Phlp' => '132',
  'Cprt' => '403',
  'Bamu' => '435',
  'Copt' => '204',
  'Deva' => '315',
  'Shrd' => '319',
  'Tglg' => '370',
  'Qabx' => '949',
  'Beng' => '325',
  'Limb' => '336',
  'Thaa' => '170',
  'Ahom' => '338',
  'Medf' => '265'
};
$Lang2Territory = {
  'fao' => {
    'FO' => 1
  },
  'heb' => {
    'IL' => 1
  },
  'dnj' => {
    'CI' => 2
  },
  'fry' => {
    'NL' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'zha' => {
    'CN' => 2
  },
  'men' => {
    'SL' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'mfa' => {
    'TH' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'que' => {
    'BO' => 1,
    'EC' => 1,
    'PE' => 1
  },
  'awa' => {
    'IN' => 2
  },
  'lah' => {
    'PK' => 2
  },
  'wuu' => {
    'CN' => 2
  },
  'bak' => {
    'RU' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'bul' => {
    'BG' => 1
  },
  'zdj' => {
    'KM' => 1
  },
  'fij' => {
    'FJ' => 1
  },
  'fuq' => {
    'NE' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'tuk' => {
    'AF' => 2,
    'TM' => 1,
    'IR' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'dyu' => {
    'BF' => 2
  },
  'tah' => {
    'PF' => 1
  },
  'nyn' => {
    'UG' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'sme' => {
    'NO' => 2
  },
  'lez' => {
    'RU' => 2
  },
  'kir' => {
    'KG' => 1
  },
  'khn' => {
    'IN' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'wbr' => {
    'IN' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'inh' => {
    'RU' => 2
  },
  'laj' => {
    'UG' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'srr' => {
    'SN' => 2
  },
  'hye' => {
    'RU' => 2,
    'AM' => 1
  },
  'kaz' => {
    'KZ' => 1,
    'CN' => 2
  },
  'mag' => {
    'IN' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'swb' => {
    'YT' => 2
  },
  'lrc' => {
    'IR' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'brx' => {
    'IN' => 2
  },
  'bsc' => {
    'SN' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'kom' => {
    'RU' => 2
  },
  'eng' => {
    'LU' => 2,
    'VU' => 1,
    'SB' => 1,
    'LB' => 2,
    'AS' => 1,
    'BR' => 2,
    'NF' => 1,
    'SX' => 1,
    'IL' => 2,
    'YE' => 2,
    'UM' => 1,
    'PN' => 1,
    'ER' => 1,
    'MA' => 2,
    'GD' => 1,
    'DG' => 1,
    'NG' => 1,
    'IT' => 2,
    'KE' => 1,
    'KI' => 1,
    'CL' => 2,
    'GH' => 1,
    'AR' => 2,
    'MX' => 2,
    'PT' => 2,
    'SH' => 1,
    'JM' => 1,
    'BZ' => 1,
    'PK' => 1,
    'IN' => 1,
    'DZ' => 2,
    'BS' => 1,
    'GU' => 1,
    'NL' => 2,
    'TZ' => 1,
    'DE' => 2,
    'VC' => 1,
    'CM' => 1,
    'DK' => 2,
    'TA' => 2,
    'TT' => 1,
    'ZM' => 1,
    'CC' => 1,
    'SE' => 2,
    'VI' => 1,
    'FM' => 1,
    'BG' => 2,
    'NU' => 1,
    'ES' => 2,
    'SZ' => 1,
    'EE' => 2,
    'SL' => 1,
    'ZA' => 1,
    'AC' => 2,
    'FR' => 2,
    'GI' => 1,
    'AT' => 2,
    'SS' => 1,
    'PR' => 1,
    'US' => 1,
    'MW' => 1,
    'MH' => 1,
    'CK' => 1,
    'VG' => 1,
    'LK' => 2,
    'IE' => 1,
    'CH' => 2,
    'WS' => 1,
    'LC' => 1,
    'GY' => 1,
    'BD' => 2,
    'SC' => 1,
    'AI' => 1,
    'MG' => 1,
    'BW' => 1,
    'TR' => 2,
    'CA' => 1,
    'AE' => 2,
    'IO' => 1,
    'TV' => 1,
    'AU' => 1,
    'TK' => 1,
    'BI' => 1,
    'CX' => 1,
    'NA' => 1,
    'CY' => 2,
    'LV' => 2,
    'TO' => 1,
    'MU' => 1,
    'NZ' => 1,
    'GR' => 2,
    'MT' => 1,
    'JE' => 1,
    'FJ' => 1,
    'SK' => 2,
    'LT' => 2,
    'JO' => 2,
    'GM' => 1,
    'BA' => 2,
    'HR' => 2,
    'SI' => 2,
    'KN' => 1,
    'KZ' => 2,
    'TC' => 1,
    'LS' => 1,
    'IQ' => 2,
    'CZ' => 2,
    'SG' => 1,
    'FI' => 2,
    'PL' => 2,
    'AG' => 1,
    'KY' => 1,
    'BE' => 2,
    'IM' => 1,
    'BB' => 1,
    'RW' => 1,
    'PG' => 1,
    'LR' => 1,
    'BM' => 1,
    'PH' => 1,
    'HU' => 2,
    'TH' => 2,
    'DM' => 1,
    'MS' => 1,
    'MP' => 1,
    'GG' => 1,
    'RO' => 2,
    'FK' => 1,
    'PW' => 1,
    'ET' => 2,
    'ZW' => 1,
    'UG' => 1,
    'GB' => 1,
    'EG' => 2,
    'MY' => 2,
    'SD' => 1,
    'NR' => 1,
    'HK' => 1
  },
  'roh' => {
    'CH' => 2
  },
  'kas' => {
    'IN' => 2
  },
  'raj' => {
    'IN' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'mfe' => {
    'MU' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'sav' => {
    'SN' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'kal' => {
    'DK' => 2,
    'GL' => 1
  },
  'kde' => {
    'TZ' => 2
  },
  'bmv' => {
    'CM' => 2
  },
  'pap' => {
    'AW' => 1,
    'BQ' => 2,
    'CW' => 1
  },
  'amh' => {
    'ET' => 1
  },
  'bis' => {
    'VU' => 1
  },
  'san' => {
    'IN' => 2
  },
  'pmn' => {
    'PH' => 2
  },
  'bod' => {
    'CN' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'fra' => {
    'GF' => 1,
    'GB' => 2,
    'RE' => 1,
    'PM' => 1,
    'US' => 2,
    'GP' => 1,
    'TF' => 2,
    'BL' => 1,
    'NL' => 2,
    'WF' => 1,
    'CH' => 1,
    'CG' => 1,
    'DJ' => 1,
    'DZ' => 1,
    'RO' => 2,
    'FR' => 1,
    'TG' => 1,
    'MQ' => 1,
    'BJ' => 1,
    'IT' => 2,
    'CD' => 1,
    'GN' => 1,
    'NC' => 1,
    'MU' => 1,
    'PT' => 2,
    'KM' => 1,
    'BF' => 1,
    'MA' => 1,
    'MC' => 1,
    'CA' => 1,
    'NE' => 1,
    'BI' => 1,
    'TD' => 1,
    'RW' => 1,
    'CF' => 1,
    'GA' => 1,
    'HT' => 1,
    'MF' => 1,
    'CM' => 1,
    'PF' => 1,
    'DE' => 2,
    'CI' => 1,
    'VU' => 1,
    'LU' => 1,
    'MG' => 1,
    'BE' => 1,
    'TN' => 1,
    'ML' => 1,
    'SY' => 1,
    'YT' => 1,
    'SN' => 1,
    'GQ' => 1,
    'SC' => 1
  },
  'fas' => {
    'AF' => 1,
    'PK' => 2,
    'IR' => 1
  },
  'glk' => {
    'IR' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'ban' => {
    'ID' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'pol' => {
    'PL' => 1,
    'UA' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'sqq' => {
    'TH' => 2
  },
  'lao' => {
    'LA' => 1
  },
  'bej' => {
    'SD' => 2
  },
  'ita' => {
    'FR' => 2,
    'IT' => 1,
    'SM' => 1,
    'DE' => 2,
    'US' => 2,
    'MT' => 2,
    'CH' => 1,
    'HR' => 2,
    'VA' => 1
  },
  'pan' => {
    'PK' => 2,
    'IN' => 2
  },
  'sdh' => {
    'IR' => 2
  },
  'ces' => {
    'CZ' => 1,
    'SK' => 2
  },
  'ben' => {
    'BD' => 1,
    'IN' => 2
  },
  'ibb' => {
    'NG' => 2
  },
  'swe' => {
    'FI' => 1,
    'SE' => 1,
    'AX' => 1
  },
  'bqi' => {
    'IR' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'ful' => {
    'SN' => 2,
    'NE' => 2,
    'NG' => 2,
    'GN' => 2,
    'ML' => 2
  },
  'bgc' => {
    'IN' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'ach' => {
    'UG' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'lug' => {
    'UG' => 2
  },
  'bos' => {
    'BA' => 1
  },
  'ibo' => {
    'NG' => 2
  },
  'dan' => {
    'DE' => 2,
    'DK' => 1
  },
  'hsn' => {
    'CN' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'ukr' => {
    'RS' => 2,
    'UA' => 1
  },
  'hno' => {
    'PK' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'tum' => {
    'MW' => 2
  },
  'hif' => {
    'FJ' => 1
  },
  'kbd' => {
    'RU' => 2
  },
  'sot' => {
    'LS' => 1,
    'ZA' => 2
  },
  'fon' => {
    'BJ' => 2
  },
  'kha' => {
    'IN' => 2
  },
  'cat' => {
    'AD' => 1,
    'ES' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'nya' => {
    'MW' => 1,
    'ZM' => 2
  },
  'nbl' => {
    'ZA' => 2
  },
  'bhi' => {
    'IN' => 2
  },
  'kdx' => {
    'KE' => 2
  },
  'ara' => {
    'TD' => 1,
    'SD' => 1,
    'QA' => 1,
    'KW' => 1,
    'DZ' => 2,
    'DJ' => 1,
    'JO' => 1,
    'EG' => 2,
    'IR' => 2,
    'AE' => 1,
    'BH' => 1,
    'MA' => 2,
    'ER' => 1,
    'IL' => 1,
    'SY' => 1,
    'SS' => 2,
    'YE' => 1,
    'TN' => 1,
    'KM' => 1,
    'PS' => 1,
    'EH' => 1,
    'SA' => 1,
    'LY' => 1,
    'IQ' => 1,
    'OM' => 1,
    'MR' => 1,
    'SO' => 1,
    'LB' => 1
  },
  'sas' => {
    'ID' => 2
  },
  'war' => {
    'PH' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'rej' => {
    'ID' => 2
  },
  'bik' => {
    'PH' => 2
  },
  'hil' => {
    'PH' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'sna' => {
    'ZW' => 1
  },
  'hoj' => {
    'IN' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'aym' => {
    'BO' => 1
  },
  'kln' => {
    'KE' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'eus' => {
    'ES' => 2
  },
  'ttb' => {
    'GH' => 2
  },
  'jpn' => {
    'JP' => 1
  },
  'grn' => {
    'PY' => 1
  },
  'tnr' => {
    'SN' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'aeb' => {
    'TN' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'tet' => {
    'TL' => 1
  },
  'snk' => {
    'ML' => 2
  },
  'bjn' => {
    'ID' => 2
  },
  'tam' => {
    'LK' => 1,
    'SG' => 1,
    'MY' => 2,
    'IN' => 2
  },
  'lin' => {
    'CD' => 2
  },
  'gbm' => {
    'IN' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'shn' => {
    'MM' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'tig' => {
    'ER' => 2
  },
  'orm' => {
    'ET' => 2
  },
  'hrv' => {
    'BA' => 1,
    'HR' => 1,
    'AT' => 2,
    'RS' => 2,
    'SI' => 2
  },
  'gle' => {
    'GB' => 2,
    'IE' => 1
  },
  'tvl' => {
    'TV' => 1
  },
  'tha' => {
    'TH' => 1
  },
  'bem' => {
    'ZM' => 2
  },
  'lat' => {
    'VA' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'rmt' => {
    'IR' => 2
  },
  'bho' => {
    'IN' => 2,
    'NP' => 2,
    'MU' => 2
  },
  'kdh' => {
    'SL' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'min' => {
    'ID' => 2
  },
  'bam' => {
    'ML' => 2
  },
  'uig' => {
    'CN' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'kik' => {
    'KE' => 2
  },
  'haz' => {
    'AF' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'smo' => {
    'AS' => 1,
    'WS' => 1
  },
  'zho' => {
    'MO' => 1,
    'HK' => 1,
    'ID' => 2,
    'TW' => 1,
    'TH' => 2,
    'US' => 2,
    'VN' => 2,
    'SG' => 1,
    'MY' => 2,
    'CN' => 1
  },
  'myx' => {
    'UG' => 2
  },
  'kur' => {
    'IQ' => 2,
    'SY' => 2,
    'IR' => 2,
    'TR' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'luz' => {
    'IR' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'nym' => {
    'TZ' => 2
  },
  'glv' => {
    'IM' => 1
  },
  'dje' => {
    'NE' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'gan' => {
    'CN' => 2
  },
  'bew' => {
    'ID' => 2
  },
  'hbs' => {
    'ME' => 1,
    'AT' => 2,
    'SI' => 2,
    'RS' => 1,
    'BA' => 1,
    'XK' => 1,
    'HR' => 1
  },
  'hin' => {
    'FJ' => 2,
    'IN' => 1,
    'ZA' => 2
  },
  'rkt' => {
    'IN' => 2,
    'BD' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'yor' => {
    'NG' => 1
  },
  'oci' => {
    'FR' => 2
  },
  'yue' => {
    'CN' => 2,
    'HK' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'tsn' => {
    'BW' => 1,
    'ZA' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'pcm' => {
    'NG' => 2
  },
  'afr' => {
    'NA' => 2,
    'ZA' => 2
  },
  'sus' => {
    'GN' => 2
  },
  'tir' => {
    'ET' => 2,
    'ER' => 1
  },
  'bgn' => {
    'PK' => 2
  },
  'gsw' => {
    'CH' => 1,
    'DE' => 2,
    'LI' => 1
  },
  'run' => {
    'BI' => 1
  },
  'kea' => {
    'CV' => 2
  },
  'lav' => {
    'LV' => 1
  },
  'ron' => {
    'RS' => 2,
    'MD' => 1,
    'RO' => 1
  },
  'nod' => {
    'TH' => 2
  },
  'ckb' => {
    'IR' => 2,
    'IQ' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'sck' => {
    'IN' => 2
  },
  'ell' => {
    'GR' => 1,
    'CY' => 1
  },
  'doi' => {
    'IN' => 2
  },
  'tat' => {
    'RU' => 2
  },
  'est' => {
    'EE' => 1
  },
  'uzb' => {
    'UZ' => 1,
    'AF' => 2
  },
  'che' => {
    'RU' => 2
  },
  'vmw' => {
    'MZ' => 2
  },
  'kab' => {
    'DZ' => 2
  },
  'srn' => {
    'SR' => 2
  },
  'rif' => {
    'MA' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'bar' => {
    'AT' => 2,
    'DE' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'ary' => {
    'MA' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'ilo' => {
    'PH' => 2
  },
  'zgh' => {
    'MA' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'pau' => {
    'PW' => 1
  },
  'iii' => {
    'CN' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'tyv' => {
    'RU' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'nor' => {
    'NO' => 1,
    'SJ' => 1
  },
  'tel' => {
    'IN' => 2
  },
  'por' => {
    'BR' => 1,
    'MO' => 1,
    'GQ' => 1,
    'MZ' => 1,
    'PT' => 1,
    'AO' => 1,
    'GW' => 1,
    'TL' => 1,
    'ST' => 1,
    'CV' => 1
  },
  'aln' => {
    'XK' => 2
  },
  'haw' => {
    'US' => 2
  },
  'krc' => {
    'RU' => 2
  },
  'rus' => {
    'BY' => 1,
    'TJ' => 2,
    'SJ' => 2,
    'LV' => 2,
    'KG' => 1,
    'UA' => 1,
    'PL' => 2,
    'BG' => 2,
    'EE' => 2,
    'UZ' => 2,
    'RU' => 1,
    'KZ' => 1,
    'DE' => 2,
    'LT' => 2
  },
  'ndo' => {
    'NA' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'deu' => {
    'DK' => 2,
    'CZ' => 2,
    'FR' => 2,
    'PL' => 2,
    'LU' => 1,
    'SI' => 2,
    'DE' => 1,
    'HU' => 2,
    'KZ' => 2,
    'BE' => 1,
    'LI' => 1,
    'BR' => 2,
    'AT' => 1,
    'GB' => 2,
    'SK' => 2,
    'US' => 2,
    'CH' => 1,
    'NL' => 2
  },
  'pus' => {
    'AF' => 1,
    'PK' => 2
  },
  'skr' => {
    'PK' => 2
  },
  'slk' => {
    'CZ' => 2,
    'SK' => 1,
    'RS' => 2
  },
  'mai' => {
    'IN' => 2,
    'NP' => 2
  },
  'mzn' => {
    'IR' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'sef' => {
    'CI' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'hau' => {
    'NG' => 2,
    'NE' => 2
  },
  'mon' => {
    'CN' => 2,
    'MN' => 1
  },
  'msa' => {
    'ID' => 2,
    'SG' => 1,
    'MY' => 1,
    'BN' => 1,
    'CC' => 2,
    'TH' => 2
  },
  'ltz' => {
    'LU' => 1
  },
  'mni' => {
    'IN' => 2
  },
  'ssw' => {
    'ZA' => 2,
    'SZ' => 1
  },
  'sqi' => {
    'AL' => 1,
    'XK' => 1,
    'MK' => 2,
    'RS' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'xnr' => {
    'IN' => 2
  },
  'div' => {
    'MV' => 1
  },
  'nds' => {
    'NL' => 2,
    'DE' => 2
  },
  'bjt' => {
    'SN' => 2
  },
  'bin' => {
    'NG' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'snd' => {
    'IN' => 2,
    'PK' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'lub' => {
    'CD' => 2
  },
  'ton' => {
    'TO' => 1
  },
  'kat' => {
    'GE' => 1
  },
  'hmo' => {
    'PG' => 1
  },
  'som' => {
    'DJ' => 2,
    'ET' => 2,
    'SO' => 1
  },
  'gcr' => {
    'GF' => 2
  },
  'nld' => {
    'CW' => 1,
    'DE' => 2,
    'AW' => 1,
    'BQ' => 1,
    'SX' => 1,
    'SR' => 1,
    'BE' => 1,
    'NL' => 1
  },
  'jav' => {
    'ID' => 2
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'hoc' => {
    'IN' => 2
  },
  'man' => {
    'GM' => 2,
    'GN' => 2
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'tiv' => {
    'NG' => 2
  },
  'srd' => {
    'IT' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'kkt' => {
    'RU' => 2
  },
  'tcy' => {
    'IN' => 2
  },
  'noe' => {
    'IN' => 2
  },
  'mwr' => {
    'IN' => 2
  },
  'mdh' => {
    'PH' => 2
  },
  'mak' => {
    'ID' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'gon' => {
    'IN' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'shr' => {
    'MA' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'mdf' => {
    'RU' => 2
  },
  'kok' => {
    'IN' => 2
  },
  'arz' => {
    'EG' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'wol' => {
    'SN' => 1
  },
  'vmf' => {
    'DE' => 2
  },
  'buc' => {
    'YT' => 2
  },
  'fuv' => {
    'NG' => 2
  },
  'suk' => {
    'TZ' => 2
  },
  'unr' => {
    'IN' => 2
  },
  'lua' => {
    'CD' => 2
  },
  'arq' => {
    'DZ' => 2
  },
  'sat' => {
    'IN' => 2
  },
  'khm' => {
    'KH' => 1
  },
  'guz' => {
    'KE' => 2
  },
  'tpi' => {
    'PG' => 1
  },
  'nno' => {
    'NO' => 1
  },
  'glg' => {
    'ES' => 2
  },
  'spa' => {
    'ES' => 1,
    'PY' => 1,
    'PH' => 2,
    'CU' => 1,
    'VE' => 1,
    'GQ' => 1,
    'CO' => 1,
    'DE' => 2,
    'UY' => 1,
    'AD' => 2,
    'PA' => 1,
    'CR' => 1,
    'BO' => 1,
    'DO' => 1,
    'HN' => 1,
    'SV' => 1,
    'EA' => 1,
    'US' => 2,
    'BZ' => 2,
    'GT' => 1,
    'IC' => 1,
    'PT' => 2,
    'GI' => 2,
    'PR' => 1,
    'PE' => 1,
    'NI' => 1,
    'EC' => 1,
    'RO' => 2,
    'AR' => 1,
    'FR' => 2,
    'MX' => 1,
    'CL' => 1
  },
  'vls' => {
    'BE' => 2
  },
  'udm' => {
    'RU' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'fud' => {
    'WF' => 2
  },
  'swa' => {
    'UG' => 1,
    'TZ' => 1,
    'CD' => 2,
    'KE' => 1
  },
  'mya' => {
    'MM' => 1
  },
  'xog' => {
    'UG' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'gil' => {
    'KI' => 1
  },
  'sin' => {
    'LK' => 1
  },
  'bal' => {
    'AF' => 2,
    'IR' => 2,
    'PK' => 2
  },
  'srp' => {
    'BA' => 1,
    'XK' => 1,
    'ME' => 1,
    'RS' => 1
  },
  'gom' => {
    'IN' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'dzo' => {
    'BT' => 1
  },
  'kon' => {
    'CD' => 2
  },
  'syl' => {
    'BD' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'fin' => {
    'EE' => 2,
    'FI' => 1,
    'SE' => 2
  },
  'hun' => {
    'AT' => 2,
    'HU' => 1,
    'RS' => 2,
    'RO' => 2
  },
  'nep' => {
    'IN' => 2,
    'NP' => 1
  },
  'fvr' => {
    'SD' => 2
  },
  'mlt' => {
    'MT' => 1
  },
  'mfv' => {
    'SN' => 2
  },
  'xho' => {
    'ZA' => 2
  },
  'ceb' => {
    'PH' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'sah' => {
    'RU' => 2
  },
  'hne' => {
    'IN' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'crs' => {
    'SC' => 2
  },
  'tur' => {
    'TR' => 1,
    'CY' => 1,
    'DE' => 2
  },
  'und' => {
    'HM' => 2,
    'BV' => 2,
    'GS' => 2,
    'CP' => 2,
    'AQ' => 2
  },
  'gqr' => {
    'ID' => 2
  },
  'fil' => {
    'PH' => 1,
    'US' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'kin' => {
    'RW' => 1
  },
  'ewe' => {
    'GH' => 2,
    'TG' => 2
  },
  'tzm' => {
    'MA' => 1
  },
  'seh' => {
    'MZ' => 2
  },
  'ori' => {
    'IN' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'slv' => {
    'AT' => 2,
    'SI' => 1
  },
  'mad' => {
    'ID' => 2
  },
  'sag' => {
    'CF' => 1
  },
  'kmb' => {
    'AO' => 2
  },
  'kfy' => {
    'IN' => 2
  },
  'tso' => {
    'ZA' => 2,
    'MZ' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'brh' => {
    'PK' => 2
  },
  'sid' => {
    'ET' => 2
  },
  'wls' => {
    'WF' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'nob' => {
    'NO' => 1,
    'SJ' => 1
  },
  'nau' => {
    'NR' => 1
  },
  'bug' => {
    'ID' => 2
  },
  'aze' => {
    'IQ' => 2,
    'IR' => 2,
    'AZ' => 1,
    'RU' => 2
  },
  'kor' => {
    'KR' => 1,
    'US' => 2,
    'KP' => 1,
    'CN' => 2
  },
  'mnu' => {
    'KE' => 2
  }
};
$Lang2Script = {
  'swe' => {
    'Latn' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'ibb' => {
    'Latn' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'bqi' => {
    'Arab' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'byn' => {
    'Ethi' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'lui' => {
    'Latn' => 2
  },
  'swg' => {
    'Latn' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'kri' => {
    'Latn' => 1
  },
  'hsn' => {
    'Hans' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'sdc' => {
    'Latn' => 1
  },
  'atj' => {
    'Latn' => 1
  },
  'ina' => {
    'Latn' => 2
  },
  'cop' => {
    'Grek' => 2,
    'Copt' => 2,
    'Arab' => 2
  },
  'srx' => {
    'Deva' => 1
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'ngl' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'ach' => {
    'Latn' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'rug' => {
    'Latn' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'bmv' => {
    'Latn' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'raj' => {
    'Arab' => 1,
    'Deva' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'amo' => {
    'Latn' => 1
  },
  'eng' => {
    'Dsrt' => 2,
    'Latn' => 1,
    'Shaw' => 2
  },
  'zea' => {
    'Latn' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'ita' => {
    'Latn' => 1
  },
  'lao' => {
    'Laoo' => 1
  },
  'pol' => {
    'Latn' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'ban' => {
    'Latn' => 1,
    'Bali' => 2
  },
  'bez' => {
    'Latn' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'pmn' => {
    'Latn' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'ttj' => {
    'Latn' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'inh' => {
    'Cyrl' => 1,
    'Arab' => 2,
    'Latn' => 2
  },
  'hmd' => {
    'Plrd' => 1
  },
  'kir' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'sme' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'nyn' => {
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'lki' => {
    'Arab' => 1
  },
  'sga' => {
    'Ogam' => 2,
    'Latn' => 2
  },
  'snx' => {
    'Samr' => 2,
    'Hebr' => 2
  },
  'kom' => {
    'Cyrl' => 1,
    'Perm' => 2
  },
  'kac' => {
    'Latn' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'bub' => {
    'Cyrl' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'swb' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'mgp' => {
    'Deva' => 1
  },
  'frp' => {
    'Latn' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'bft' => {
    'Tibt' => 2,
    'Arab' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'zha' => {
    'Latn' => 1,
    'Hans' => 2
  },
  'fry' => {
    'Latn' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'fuq' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'mri' => {
    'Latn' => 1
  },
  'ewo' => {
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'nym' => {
    'Latn' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'kur' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'avk' => {
    'Latn' => 2
  },
  'smo' => {
    'Latn' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'myx' => {
    'Latn' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'yue' => {
    'Hant' => 1,
    'Hans' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'arc' => {
    'Palm' => 2,
    'Nbat' => 2,
    'Armi' => 2
  },
  'yor' => {
    'Latn' => 1
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'hbs' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'tkr' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'rkt' => {
    'Beng' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'mua' => {
    'Latn' => 1
  },
  'bem' => {
    'Latn' => 1
  },
  'sli' => {
    'Latn' => 1
  },
  'rom' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'gle' => {
    'Latn' => 1
  },
  'hrv' => {
    'Latn' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'kax' => {
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'shn' => {
    'Mymr' => 1
  },
  'bbc' => {
    'Batk' => 2,
    'Latn' => 1
  },
  'lin' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'uig' => {
    'Latn' => 2,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'nnh' => {
    'Latn' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'dtm' => {
    'Latn' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'rcf' => {
    'Latn' => 1
  },
  'xum' => {
    'Latn' => 2,
    'Ital' => 2
  },
  'maf' => {
    'Latn' => 1
  },
  'cja' => {
    'Cham' => 2,
    'Arab' => 1
  },
  'aym' => {
    'Latn' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'rej' => {
    'Rjng' => 2,
    'Latn' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'dyo' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'hil' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'jpn' => {
    'Jpan' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'thl' => {
    'Deva' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'osa' => {
    'Latn' => 2,
    'Osge' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'tum' => {
    'Latn' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'sas' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'nus' => {
    'Latn' => 1
  },
  'hmn' => {
    'Laoo' => 1,
    'Latn' => 1,
    'Hmng' => 2,
    'Plrd' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'aii' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'jav' => {
    'Latn' => 1,
    'Java' => 2
  },
  'lit' => {
    'Latn' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'bmq' => {
    'Latn' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'tdd' => {
    'Tale' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'aoz' => {
    'Latn' => 1
  },
  'kat' => {
    'Geor' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'cad' => {
    'Latn' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'srd' => {
    'Latn' => 1
  },
  'vie' => {
    'Hani' => 2,
    'Latn' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'kau' => {
    'Latn' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'tru' => {
    'Syrc' => 2,
    'Latn' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'hoc' => {
    'Deva' => 1,
    'Wara' => 2
  },
  'bra' => {
    'Deva' => 1
  },
  'chr' => {
    'Cher' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'ven' => {
    'Latn' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'snd' => {
    'Sind' => 2,
    'Khoj' => 2,
    'Arab' => 1,
    'Deva' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'crl' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'div' => {
    'Thaa' => 1
  },
  'ttt' => {
    'Latn' => 1,
    'Arab' => 2,
    'Cyrl' => 1
  },
  'gag' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'kxp' => {
    'Arab' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'sqi' => {
    'Latn' => 1,
    'Elba' => 2
  },
  'xnr' => {
    'Deva' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'ale' => {
    'Latn' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'ssw' => {
    'Latn' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'egl' => {
    'Latn' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'grt' => {
    'Beng' => 1
  },
  'ary' => {
    'Arab' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'xav' => {
    'Latn' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'thq' => {
    'Deva' => 1
  },
  'rif' => {
    'Tfng' => 1,
    'Latn' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'bfq' => {
    'Taml' => 1
  },
  'xpr' => {
    'Prti' => 2
  },
  'khq' => {
    'Latn' => 1
  },
  'ndo' => {
    'Latn' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'bto' => {
    'Latn' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'tir' => {
    'Ethi' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'sus' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'kht' => {
    'Mymr' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'taj' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'dsb' => {
    'Latn' => 1
  },
  'cps' => {
    'Latn' => 1
  },
  'uzb' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'ett' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'liv' => {
    'Latn' => 2
  },
  'sbp' => {
    'Latn' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'doi' => {
    'Takr' => 2,
    'Deva' => 1,
    'Arab' => 1
  },
  'est' => {
    'Latn' => 1
  },
  'arg' => {
    'Latn' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'bfd' => {
    'Latn' => 1
  },
  'pnt' => {
    'Latn' => 1,
    'Grek' => 1,
    'Cyrl' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'hnn' => {
    'Hano' => 2,
    'Latn' => 1
  },
  'tso' => {
    'Latn' => 1
  },
  'kmb' => {
    'Latn' => 1
  },
  'kfy' => {
    'Deva' => 1
  },
  'kjg' => {
    'Laoo' => 1,
    'Latn' => 2
  },
  'bax' => {
    'Bamu' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'sly' => {
    'Latn' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'maz' => {
    'Latn' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'abk' => {
    'Cyrl' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'seh' => {
    'Latn' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'grc' => {
    'Linb' => 2,
    'Cprt' => 2,
    'Grek' => 2
  },
  'lcp' => {
    'Thai' => 1
  },
  'aze' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'bug' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'vai' => {
    'Latn' => 1,
    'Vaii' => 1
  },
  'sid' => {
    'Latn' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'wls' => {
    'Latn' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'hnj' => {
    'Laoo' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'fvr' => {
    'Latn' => 1
  },
  'hun' => {
    'Latn' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'mlt' => {
    'Latn' => 1
  },
  'hai' => {
    'Latn' => 1
  },
  'dty' => {
    'Deva' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'srp' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'syl' => {
    'Sylo' => 2,
    'Beng' => 1
  },
  'kon' => {
    'Latn' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'kin' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'tsi' => {
    'Latn' => 1
  },
  'kca' => {
    'Cyrl' => 1
  },
  'rmu' => {
    'Latn' => 1
  },
  'ssy' => {
    'Latn' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'tgk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'mro' => {
    'Mroo' => 2,
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'ccp' => {
    'Beng' => 1,
    'Cakm' => 1
  },
  'gay' => {
    'Latn' => 1
  },
  'stq' => {
    'Latn' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'arq' => {
    'Arab' => 1
  },
  'bku' => {
    'Latn' => 1,
    'Buhd' => 2
  },
  'lmo' => {
    'Latn' => 1
  },
  'bal' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'gil' => {
    'Latn' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'sxn' => {
    'Latn' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'swa' => {
    'Latn' => 1
  },
  'udm' => {
    'Cyrl' => 1,
    'Latn' => 2
  },
  'crk' => {
    'Cans' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'shr' => {
    'Tfng' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'frr' => {
    'Latn' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'gon' => {
    'Telu' => 1,
    'Deva' => 1
  },
  'was' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'btv' => {
    'Deva' => 1
  },
  'mdh' => {
    'Latn' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'mak' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'non' => {
    'Runr' => 2
  },
  'unr' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'wol' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'fuv' => {
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'kgp' => {
    'Latn' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'pan' => {
    'Guru' => 1,
    'Arab' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'dan' => {
    'Latn' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'bos' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'uga' => {
    'Ugar' => 2
  },
  'xmf' => {
    'Geor' => 1
  },
  'ava' => {
    'Cyrl' => 1
  },
  'ful' => {
    'Latn' => 1,
    'Adlm' => 2
  },
  'lut' => {
    'Latn' => 2
  },
  'amh' => {
    'Ethi' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'san' => {
    'Shrd' => 2,
    'Gran' => 2,
    'Deva' => 2,
    'Sinh' => 2,
    'Sidd' => 2
  },
  'bis' => {
    'Latn' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'nov' => {
    'Latn' => 2
  },
  'kas' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'sqq' => {
    'Thai' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'chu' => {
    'Cyrl' => 2
  },
  'xmr' => {
    'Merc' => 2
  },
  'fas' => {
    'Arab' => 1
  },
  'fra' => {
    'Latn' => 1,
    'Dupl' => 2
  },
  'bod' => {
    'Tibt' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'rjs' => {
    'Deva' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'lez' => {
    'Cyrl' => 1,
    'Aghb' => 2
  },
  'lag' => {
    'Latn' => 1
  },
  'wbr' => {
    'Deva' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'phn' => {
    'Phnx' => 2
  },
  'cgg' => {
    'Latn' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'ind' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'srb' => {
    'Sora' => 2,
    'Latn' => 1
  },
  'kan' => {
    'Knda' => 1
  },
  'crj' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'luo' => {
    'Latn' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'kaz' => {
    'Cyrl' => 1,
    'Arab' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'men' => {
    'Mend' => 2,
    'Latn' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'fao' => {
    'Latn' => 1
  },
  'tuk' => {
    'Latn' => 1,
    'Arab' => 1,
    'Cyrl' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'fia' => {
    'Arab' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'esu' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'zdj' => {
    'Arab' => 1
  },
  'rar' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'lah' => {
    'Arab' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'bew' => {
    'Latn' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'asm' => {
    'Beng' => 1
  },
  'zho' => {
    'Bopo' => 2,
    'Hans' => 1,
    'Phag' => 2,
    'Hant' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'xsa' => {
    'Sarb' => 2
  },
  'tly' => {
    'Cyrl' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'nzi' => {
    'Latn' => 1
  },
  'nsk' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'oci' => {
    'Latn' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'ses' => {
    'Latn' => 1
  },
  'fan' => {
    'Latn' => 1
  },
  'pli' => {
    'Thai' => 2,
    'Deva' => 2,
    'Sinh' => 2
  },
  'mxc' => {
    'Latn' => 1
  },
  'hin' => {
    'Mahj' => 2,
    'Deva' => 1,
    'Latn' => 2
  },
  'gju' => {
    'Arab' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'orm' => {
    'Latn' => 1,
    'Ethi' => 2
  },
  'tvl' => {
    'Latn' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'unx' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'cho' => {
    'Latn' => 1
  },
  'kik' => {
    'Latn' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'ikt' => {
    'Latn' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'bam' => {
    'Nkoo' => 1,
    'Latn' => 1
  },
  'kdh' => {
    'Latn' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'lat' => {
    'Latn' => 2
  },
  'ndc' => {
    'Latn' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'lim' => {
    'Latn' => 1
  },
  'zap' => {
    'Latn' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'crh' => {
    'Cyrl' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'grn' => {
    'Latn' => 1
  },
  'ttb' => {
    'Latn' => 1
  },
  'kln' => {
    'Latn' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'kha' => {
    'Latn' => 1,
    'Beng' => 2
  },
  'sot' => {
    'Latn' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'hif' => {
    'Deva' => 1,
    'Latn' => 1
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'sad' => {
    'Latn' => 1
  },
  'lfn' => {
    'Latn' => 2,
    'Cyrl' => 2
  },
  'war' => {
    'Latn' => 1
  },
  'del' => {
    'Latn' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'kdx' => {
    'Latn' => 1
  },
  'syr' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'bhi' => {
    'Deva' => 1
  },
  'rob' => {
    'Latn' => 1
  },
  'nld' => {
    'Latn' => 1
  },
  'wae' => {
    'Latn' => 1
  },
  'wln' => {
    'Latn' => 1
  },
  'cjm' => {
    'Arab' => 2,
    'Cham' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'som' => {
    'Arab' => 2,
    'Latn' => 1,
    'Osma' => 2
  },
  'tdg' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'mdt' => {
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'kkt' => {
    'Cyrl' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'bjj' => {
    'Deva' => 1
  },
  'man' => {
    'Nkoo' => 1,
    'Latn' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'ave' => {
    'Avst' => 2
  },
  'tli' => {
    'Latn' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'msa' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'hau' => {
    'Latn' => 1,
    'Arab' => 1
  },
  'mon' => {
    'Phag' => 2,
    'Cyrl' => 1,
    'Mong' => 2
  },
  'lus' => {
    'Beng' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'agq' => {
    'Latn' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'bzx' => {
    'Latn' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'tsd' => {
    'Grek' => 1
  },
  'jml' => {
    'Deva' => 1
  },
  'lif' => {
    'Deva' => 1,
    'Limb' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'mni' => {
    'Mtei' => 2,
    'Beng' => 1
  },
  'xsr' => {
    'Deva' => 1
  },
  'aln' => {
    'Latn' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'kiu' => {
    'Latn' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'pau' => {
    'Latn' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'nde' => {
    'Latn' => 1
  },
  'kaj' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'zgh' => {
    'Tfng' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'vmw' => {
    'Latn' => 1
  },
  'sun' => {
    'Sund' => 2,
    'Latn' => 1
  },
  'mai' => {
    'Tirh' => 2,
    'Deva' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'slk' => {
    'Latn' => 1
  },
  'moh' => {
    'Latn' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'deu' => {
    'Latn' => 1,
    'Runr' => 2
  },
  'ang' => {
    'Latn' => 2
  },
  'skr' => {
    'Arab' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'wbp' => {
    'Latn' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'mrd' => {
    'Deva' => 1
  },
  'nap' => {
    'Latn' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'ron' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'run' => {
    'Latn' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'gvr' => {
    'Deva' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'cay' => {
    'Latn' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'afr' => {
    'Latn' => 1
  },
  'gba' => {
    'Latn' => 1
  },
  'byv' => {
    'Latn' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'chm' => {
    'Cyrl' => 1
  },
  'chp' => {
    'Latn' => 1,
    'Cans' => 2
  },
  'pms' => {
    'Latn' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'iku' => {
    'Cans' => 1,
    'Latn' => 1
  },
  'anp' => {
    'Deva' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'nod' => {
    'Lana' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'ain' => {
    'Kana' => 2,
    'Latn' => 2
  },
  'sck' => {
    'Deva' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'vic' => {
    'Latn' => 1
  },
  'brh' => {
    'Latn' => 2,
    'Arab' => 1
  },
  'mtr' => {
    'Deva' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'tzm' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'ori' => {
    'Orya' => 1
  },
  'kor' => {
    'Kore' => 1
  },
  'mnu' => {
    'Latn' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'frm' => {
    'Latn' => 2
  },
  'krl' => {
    'Latn' => 1
  },
  'urd' => {
    'Arab' => 1
  },
  'fin' => {
    'Latn' => 1
  },
  'xna' => {
    'Narb' => 2
  },
  'kkj' => {
    'Latn' => 1
  },
  'yao' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'fil' => {
    'Tglg' => 2,
    'Latn' => 1
  },
  'zza' => {
    'Latn' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'abw' => {
    'Phlp' => 2,
    'Phli' => 2
  },
  'crs' => {
    'Latn' => 1
  },
  'hop' => {
    'Latn' => 1
  },
  'gqr' => {
    'Latn' => 1
  },
  'tur' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'kyu' => {
    'Kali' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'kge' => {
    'Latn' => 1
  },
  'lzz' => {
    'Latn' => 1,
    'Geor' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'tog' => {
    'Latn' => 1
  },
  'glg' => {
    'Latn' => 1
  },
  'den' => {
    'Latn' => 1,
    'Cans' => 2
  },
  'guz' => {
    'Latn' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'ksh' => {
    'Latn' => 1
  },
  'sat' => {
    'Beng' => 2,
    'Orya' => 2,
    'Latn' => 2,
    'Deva' => 2,
    'Olck' => 1
  },
  'lua' => {
    'Latn' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'spa' => {
    'Latn' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'osc' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'yap' => {
    'Latn' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'mas' => {
    'Latn' => 1
  },
  'ltg' => {
    'Latn' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'pko' => {
    'Latn' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'mdr' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'vmf' => {
    'Latn' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'egy' => {
    'Egyp' => 2
  },
  'kok' => {
    'Deva' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'kum' => {
    'Cyrl' => 1
  },
  'arz' => {
    'Arab' => 1
  }
};
$Territory2Lang = {
  'PY' => {
    'grn' => 1,
    'spa' => 1
  },
  'AE' => {
    'eng' => 2,
    'ara' => 1
  },
  'IR' => {
    'mzn' => 2,
    'ara' => 2,
    'ckb' => 2,
    'rmt' => 2,
    'fas' => 1,
    'lrc' => 2,
    'glk' => 2,
    'kur' => 2,
    'sdh' => 2,
    'luz' => 2,
    'aze' => 2,
    'tuk' => 2,
    'bal' => 2,
    'bqi' => 2
  },
  'MV' => {
    'div' => 1
  },
  'CA' => {
    'eng' => 1,
    'ikt' => 2,
    'iku' => 2,
    'fra' => 1
  },
  'MC' => {
    'fra' => 1
  },
  'SY' => {
    'kur' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'MG' => {
    'mlg' => 1,
    'eng' => 1,
    'fra' => 1
  },
  'BW' => {
    'eng' => 1,
    'tsn' => 1
  },
  'GQ' => {
    'spa' => 1,
    'fan' => 2,
    'por' => 1,
    'fra' => 1
  },
  'AI' => {
    'eng' => 1
  },
  'SA' => {
    'ara' => 1
  },
  'RU' => {
    'hye' => 2,
    'ava' => 2,
    'mdf' => 2,
    'kum' => 2,
    'udm' => 2,
    'bak' => 2,
    'sah' => 2,
    'rus' => 1,
    'kkt' => 2,
    'kom' => 2,
    'aze' => 2,
    'tat' => 2,
    'lbe' => 2,
    'lez' => 2,
    'kbd' => 2,
    'ady' => 2,
    'che' => 2,
    'krc' => 2,
    'inh' => 2,
    'chv' => 2,
    'myv' => 2,
    'tyv' => 2
  },
  'CI' => {
    'bci' => 2,
    'sef' => 2,
    'fra' => 1,
    'dnj' => 2
  },
  'SM' => {
    'ita' => 1
  },
  'HR' => {
    'eng' => 2,
    'hbs' => 1,
    'hrv' => 1,
    'ita' => 2
  },
  'BT' => {
    'dzo' => 1
  },
  'AD' => {
    'cat' => 1,
    'spa' => 2
  },
  'DJ' => {
    'ara' => 1,
    'fra' => 1,
    'som' => 2,
    'aar' => 2
  },
  'RS' => {
    'hrv' => 2,
    'hun' => 2,
    'slk' => 2,
    'ron' => 2,
    'ukr' => 2,
    'srp' => 1,
    'hbs' => 1,
    'sqi' => 2
  },
  'RE' => {
    'rcf' => 2,
    'fra' => 1
  },
  'BV' => {
    'und' => 2
  },
  'BA' => {
    'srp' => 1,
    'hrv' => 1,
    'hbs' => 1,
    'eng' => 2,
    'bos' => 1
  },
  'SK' => {
    'eng' => 2,
    'deu' => 2,
    'ces' => 2,
    'slk' => 1
  },
  'SV' => {
    'spa' => 1
  },
  'LT' => {
    'eng' => 2,
    'rus' => 2,
    'lit' => 1
  },
  'GR' => {
    'ell' => 1,
    'eng' => 2
  },
  'NZ' => {
    'mri' => 1,
    'eng' => 1
  },
  'MT' => {
    'mlt' => 1,
    'eng' => 1,
    'ita' => 2
  },
  'MU' => {
    'fra' => 1,
    'mfe' => 2,
    'bho' => 2,
    'eng' => 1
  },
  'EC' => {
    'que' => 1,
    'spa' => 1
  },
  'CX' => {
    'eng' => 1
  },
  'NA' => {
    'kua' => 2,
    'eng' => 1,
    'afr' => 2,
    'ndo' => 2
  },
  'CY' => {
    'ell' => 1,
    'tur' => 1,
    'eng' => 2
  },
  'TD' => {
    'ara' => 1,
    'fra' => 1
  },
  'PH' => {
    'bhk' => 2,
    'fil' => 1,
    'war' => 2,
    'pag' => 2,
    'ilo' => 2,
    'spa' => 2,
    'mdh' => 2,
    'pmn' => 2,
    'eng' => 1,
    'ceb' => 2,
    'tsg' => 2,
    'bik' => 2,
    'hil' => 2
  },
  'BB' => {
    'eng' => 1
  },
  'IM' => {
    'glv' => 1,
    'eng' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'KY' => {
    'eng' => 1
  },
  'LS' => {
    'eng' => 1,
    'sot' => 1
  },
  'CZ' => {
    'slk' => 2,
    'ces' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'SG' => {
    'tam' => 1,
    'eng' => 1,
    'zho' => 1,
    'msa' => 1
  },
  'SI' => {
    'slv' => 1,
    'hbs' => 2,
    'eng' => 2,
    'hrv' => 2,
    'deu' => 2
  },
  'UZ' => {
    'uzb' => 1,
    'rus' => 2
  },
  'KZ' => {
    'kaz' => 1,
    'rus' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'KN' => {
    'eng' => 1
  },
  'NR' => {
    'nau' => 1,
    'eng' => 1
  },
  'HK' => {
    'yue' => 2,
    'zho' => 1,
    'eng' => 1
  },
  'MY' => {
    'msa' => 1,
    'eng' => 2,
    'zho' => 2,
    'tam' => 2
  },
  'BH' => {
    'ara' => 1
  },
  'ZW' => {
    'sna' => 1,
    'nde' => 1,
    'eng' => 1
  },
  'ET' => {
    'tir' => 2,
    'orm' => 2,
    'som' => 2,
    'wal' => 2,
    'aar' => 2,
    'amh' => 1,
    'sid' => 2,
    'eng' => 2
  },
  'PE' => {
    'que' => 1,
    'spa' => 1
  },
  'MS' => {
    'eng' => 1
  },
  'MP' => {
    'eng' => 1
  },
  'MR' => {
    'ara' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'DM' => {
    'eng' => 1
  },
  'TH' => {
    'sqq' => 2,
    'tha' => 1,
    'msa' => 2,
    'mfa' => 2,
    'tts' => 2,
    'kxm' => 2,
    'nod' => 2,
    'zho' => 2,
    'eng' => 2
  },
  'HM' => {
    'und' => 2
  },
  'NG' => {
    'pcm' => 2,
    'eng' => 1,
    'ful' => 2,
    'fuv' => 2,
    'hau' => 2,
    'efi' => 2,
    'yor' => 1,
    'tiv' => 2,
    'bin' => 2,
    'ibb' => 2,
    'ibo' => 2
  },
  'GA' => {
    'fra' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'MN' => {
    'mon' => 1
  },
  'PN' => {
    'eng' => 1
  },
  'ER' => {
    'ara' => 1,
    'eng' => 1,
    'tig' => 2,
    'tir' => 1
  },
  'YE' => {
    'ara' => 1,
    'eng' => 2
  },
  'BR' => {
    'deu' => 2,
    'eng' => 2,
    'por' => 1
  },
  'SX' => {
    'nld' => 1,
    'eng' => 1
  },
  'LB' => {
    'eng' => 2,
    'ara' => 1
  },
  'VU' => {
    'eng' => 1,
    'bis' => 1,
    'fra' => 1
  },
  'BS' => {
    'eng' => 1
  },
  'NL' => {
    'nds' => 2,
    'eng' => 2,
    'deu' => 2,
    'fry' => 2,
    'nld' => 1,
    'fra' => 2
  },
  'TZ' => {
    'suk' => 2,
    'swa' => 1,
    'eng' => 1,
    'kde' => 2,
    'nym' => 2
  },
  'DZ' => {
    'eng' => 2,
    'kab' => 2,
    'arq' => 2,
    'ara' => 2,
    'fra' => 1
  },
  'AX' => {
    'swe' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'ST' => {
    'por' => 1
  },
  'BZ' => {
    'eng' => 1,
    'spa' => 2
  },
  'EA' => {
    'spa' => 1
  },
  'SH' => {
    'eng' => 1
  },
  'GH' => {
    'aka' => 2,
    'abr' => 2,
    'ttb' => 2,
    'ewe' => 2,
    'eng' => 1
  },
  'AR' => {
    'eng' => 2,
    'spa' => 1
  },
  'MX' => {
    'eng' => 2,
    'spa' => 1
  },
  'GW' => {
    'por' => 1
  },
  'KI' => {
    'eng' => 1,
    'gil' => 1
  },
  'SR' => {
    'srn' => 2,
    'nld' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'AZ' => {
    'aze' => 1
  },
  'HT' => {
    'hat' => 1,
    'fra' => 1
  },
  'ES' => {
    'eus' => 2,
    'spa' => 1,
    'eng' => 2,
    'ast' => 2,
    'glg' => 2,
    'cat' => 2
  },
  'CF' => {
    'sag' => 1,
    'fra' => 1
  },
  'SZ' => {
    'eng' => 1,
    'ssw' => 1
  },
  'IS' => {
    'isl' => 1
  },
  'VE' => {
    'spa' => 1
  },
  'BG' => {
    'eng' => 2,
    'bul' => 1,
    'rus' => 2
  },
  'ML' => {
    'fra' => 1,
    'snk' => 2,
    'ffm' => 2,
    'bam' => 2,
    'ful' => 2
  },
  'CC' => {
    'msa' => 2,
    'eng' => 1
  },
  'DK' => {
    'eng' => 2,
    'deu' => 2,
    'kal' => 2,
    'dan' => 1
  },
  'AQ' => {
    'und' => 2
  },
  'VC' => {
    'eng' => 1
  },
  'PF' => {
    'fra' => 1,
    'tah' => 1
  },
  'WF' => {
    'fud' => 2,
    'fra' => 1,
    'wls' => 2
  },
  'BO' => {
    'que' => 1,
    'spa' => 1,
    'aym' => 1
  },
  'PA' => {
    'spa' => 1
  },
  'LK' => {
    'sin' => 1,
    'eng' => 2,
    'tam' => 1
  },
  'BL' => {
    'fra' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'US' => {
    'fra' => 2,
    'eng' => 1,
    'zho' => 2,
    'spa' => 2,
    'kor' => 2,
    'haw' => 2,
    'ita' => 2,
    'vie' => 2,
    'fil' => 2,
    'deu' => 2
  },
  'MW' => {
    'eng' => 1,
    'nya' => 1,
    'tum' => 2
  },
  'CK' => {
    'eng' => 1
  },
  'LI' => {
    'deu' => 1,
    'gsw' => 1
  },
  'AC' => {
    'eng' => 2
  },
  'OM' => {
    'ara' => 1
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'EE' => {
    'fin' => 2,
    'rus' => 2,
    'est' => 1,
    'eng' => 2
  },
  'SL' => {
    'kri' => 2,
    'kdh' => 2,
    'men' => 2,
    'eng' => 1
  },
  'BI' => {
    'fra' => 1,
    'run' => 1,
    'eng' => 1
  },
  'TV' => {
    'tvl' => 1,
    'eng' => 1
  },
  'AU' => {
    'eng' => 1
  },
  'TK' => {
    'eng' => 1,
    'tkl' => 1
  },
  'BF' => {
    'dyu' => 2,
    'fra' => 1,
    'mos' => 2
  },
  'IO' => {
    'eng' => 1
  },
  'FO' => {
    'fao' => 1
  },
  'TR' => {
    'eng' => 2,
    'zza' => 2,
    'tur' => 1,
    'kur' => 2
  },
  'SC' => {
    'eng' => 1,
    'fra' => 1,
    'crs' => 2
  },
  'ME' => {
    'hbs' => 1,
    'srp' => 1
  },
  'LC' => {
    'eng' => 1
  },
  'GY' => {
    'eng' => 1
  },
  'CP' => {
    'und' => 2
  },
  'BD' => {
    'rkt' => 2,
    'ben' => 1,
    'syl' => 2,
    'eng' => 2
  },
  'CG' => {
    'fra' => 1
  },
  'BY' => {
    'rus' => 1,
    'bel' => 1
  },
  'TW' => {
    'zho' => 1
  },
  'SJ' => {
    'rus' => 2,
    'nor' => 1,
    'nob' => 1
  },
  'BQ' => {
    'nld' => 1,
    'pap' => 2
  },
  'JO' => {
    'ara' => 1,
    'eng' => 2
  },
  'PM' => {
    'fra' => 1
  },
  'GM' => {
    'man' => 2,
    'eng' => 1
  },
  'UA' => {
    'pol' => 2,
    'ukr' => 1,
    'rus' => 1
  },
  'GS' => {
    'und' => 2
  },
  'GT' => {
    'spa' => 1,
    'quc' => 2
  },
  'JE' => {
    'eng' => 1
  },
  'FJ' => {
    'hin' => 2,
    'eng' => 1,
    'fij' => 1,
    'hif' => 1
  },
  'MD' => {
    'ron' => 1
  },
  'LV' => {
    'lav' => 1,
    'rus' => 2,
    'eng' => 2
  },
  'TO' => {
    'eng' => 1,
    'ton' => 1
  },
  'MQ' => {
    'fra' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'RW' => {
    'kin' => 1,
    'fra' => 1,
    'eng' => 1
  },
  'PG' => {
    'hmo' => 1,
    'eng' => 1,
    'tpi' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'BM' => {
    'eng' => 1
  },
  'CV' => {
    'kea' => 2,
    'por' => 1
  },
  'BE' => {
    'eng' => 2,
    'deu' => 1,
    'vls' => 2,
    'nld' => 1,
    'fra' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'YT' => {
    'buc' => 2,
    'fra' => 1,
    'swb' => 2
  },
  'LY' => {
    'ara' => 1
  },
  'IQ' => {
    'ckb' => 2,
    'ara' => 1,
    'kur' => 2,
    'aze' => 2,
    'eng' => 2
  },
  'FI' => {
    'fin' => 1,
    'swe' => 1,
    'eng' => 2
  },
  'AW' => {
    'nld' => 1,
    'pap' => 1
  },
  'MF' => {
    'fra' => 1
  },
  'PL' => {
    'lit' => 2,
    'csb' => 2,
    'rus' => 2,
    'deu' => 2,
    'eng' => 2,
    'pol' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'SD' => {
    'fvr' => 2,
    'eng' => 1,
    'bej' => 2,
    'ara' => 1
  },
  'GB' => {
    'gla' => 2,
    'fra' => 2,
    'cym' => 2,
    'eng' => 1,
    'sco' => 2,
    'deu' => 2,
    'gle' => 2
  },
  'EG' => {
    'ara' => 2,
    'eng' => 2,
    'arz' => 2
  },
  'AL' => {
    'sqi' => 1
  },
  'KP' => {
    'kor' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'UG' => {
    'ach' => 2,
    'myx' => 2,
    'eng' => 1,
    'nyn' => 2,
    'swa' => 1,
    'teo' => 2,
    'xog' => 2,
    'lug' => 2,
    'cgg' => 2,
    'laj' => 2
  },
  'GN' => {
    'ful' => 2,
    'sus' => 2,
    'man' => 2,
    'fra' => 1
  },
  'VA' => {
    'lat' => 2,
    'ita' => 1
  },
  'PW' => {
    'pau' => 1,
    'eng' => 1
  },
  'MZ' => {
    'mgh' => 2,
    'seh' => 2,
    'vmw' => 2,
    'ngl' => 2,
    'ndc' => 2,
    'por' => 1,
    'tso' => 2
  },
  'BJ' => {
    'fon' => 2,
    'fra' => 1
  },
  'NP' => {
    'bho' => 2,
    'mai' => 2,
    'nep' => 1
  },
  'FK' => {
    'eng' => 1
  },
  'RO' => {
    'spa' => 2,
    'hun' => 2,
    'eng' => 2,
    'fra' => 2,
    'ron' => 1
  },
  'HU' => {
    'deu' => 2,
    'hun' => 1,
    'eng' => 2
  },
  'AO' => {
    'kmb' => 2,
    'umb' => 2,
    'por' => 1
  },
  'DG' => {
    'eng' => 1
  },
  'JP' => {
    'jpn' => 1
  },
  'UM' => {
    'eng' => 1
  },
  'NE' => {
    'fuq' => 2,
    'hau' => 2,
    'ful' => 2,
    'tmh' => 2,
    'fra' => 1,
    'dje' => 2
  },
  'CW' => {
    'nld' => 1,
    'pap' => 1
  },
  'MA' => {
    'shr' => 2,
    'ara' => 2,
    'fra' => 1,
    'ary' => 2,
    'zgh' => 2,
    'eng' => 2,
    'tzm' => 1,
    'rif' => 2
  },
  'IL' => {
    'ara' => 1,
    'heb' => 1,
    'eng' => 2
  },
  'TN' => {
    'aeb' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'CO' => {
    'spa' => 1
  },
  'SN' => {
    'ful' => 2,
    'snf' => 2,
    'srr' => 2,
    'mey' => 2,
    'dyo' => 2,
    'fra' => 1,
    'bsc' => 2,
    'wol' => 1,
    'tnr' => 2,
    'sav' => 2,
    'bjt' => 2,
    'knf' => 2,
    'mfv' => 2
  },
  'AS' => {
    'smo' => 1,
    'eng' => 1
  },
  'NF' => {
    'eng' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'LU' => {
    'deu' => 1,
    'eng' => 2,
    'ltz' => 1,
    'fra' => 1
  },
  'UY' => {
    'spa' => 1
  },
  'KR' => {
    'kor' => 1
  },
  'XK' => {
    'hbs' => 1,
    'srp' => 1,
    'aln' => 2,
    'sqi' => 1
  },
  'TJ' => {
    'tgk' => 1,
    'rus' => 2
  },
  'GU' => {
    'cha' => 1,
    'eng' => 1
  },
  'PK' => {
    'bal' => 2,
    'snd' => 2,
    'brh' => 2,
    'pus' => 2,
    'bgn' => 2,
    'skr' => 2,
    'urd' => 1,
    'fas' => 2,
    'pan' => 2,
    'eng' => 1,
    'lah' => 2,
    'hno' => 2
  },
  'GF' => {
    'fra' => 1,
    'gcr' => 2
  },
  'IN' => {
    'brx' => 2,
    'bjj' => 2,
    'tam' => 2,
    'tcy' => 2,
    'mar' => 2,
    'noe' => 2,
    'mai' => 2,
    'bgc' => 2,
    'hin' => 1,
    'mag' => 2,
    'rkt' => 2,
    'hoc' => 2,
    'kan' => 2,
    'kfy' => 2,
    'hoj' => 2,
    'tel' => 2,
    'ben' => 2,
    'mtr' => 2,
    'ori' => 2,
    'khn' => 2,
    'pan' => 2,
    'dcc' => 2,
    'sat' => 2,
    'wbr' => 2,
    'asm' => 2,
    'kru' => 2,
    'wbq' => 2,
    'doi' => 2,
    'swv' => 2,
    'unr' => 2,
    'snd' => 2,
    'guj' => 2,
    'awa' => 2,
    'kok' => 2,
    'mni' => 2,
    'bhi' => 2,
    'lmn' => 2,
    'hne' => 2,
    'xnr' => 2,
    'sck' => 2,
    'bhb' => 2,
    'bho' => 2,
    'kha' => 2,
    'nep' => 2,
    'gon' => 2,
    'san' => 2,
    'mwr' => 2,
    'eng' => 1,
    'gom' => 2,
    'gbm' => 2,
    'raj' => 2,
    'kas' => 2,
    'urd' => 2,
    'mal' => 2,
    'wtm' => 2
  },
  'MK' => {
    'mkd' => 1,
    'sqi' => 2
  },
  'GP' => {
    'fra' => 1
  },
  'NC' => {
    'fra' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'JM' => {
    'jam' => 2,
    'eng' => 1
  },
  'CD' => {
    'lin' => 2,
    'kon' => 2,
    'fra' => 1,
    'lub' => 2,
    'lua' => 2,
    'swa' => 2
  },
  'KM' => {
    'zdj' => 1,
    'wni' => 1,
    'ara' => 1,
    'fra' => 1
  },
  'PT' => {
    'spa' => 2,
    'eng' => 2,
    'por' => 1,
    'fra' => 2
  },
  'EH' => {
    'ara' => 1
  },
  'MO' => {
    'por' => 1,
    'zho' => 1
  },
  'CL' => {
    'spa' => 1,
    'eng' => 2
  },
  'GL' => {
    'kal' => 1
  },
  'SO' => {
    'som' => 1,
    'ara' => 1
  },
  'IT' => {
    'fra' => 2,
    'ita' => 1,
    'eng' => 2,
    'srd' => 2
  },
  'KE' => {
    'kik' => 2,
    'luy' => 2,
    'mnu' => 2,
    'guz' => 2,
    'kdx' => 2,
    'luo' => 2,
    'swa' => 1,
    'kln' => 2,
    'eng' => 1
  },
  'MM' => {
    'shn' => 2,
    'mya' => 1
  },
  'NU' => {
    'eng' => 1,
    'niu' => 1
  },
  'AF' => {
    'uzb' => 2,
    'bal' => 2,
    'haz' => 2,
    'tuk' => 2,
    'fas' => 1,
    'pus' => 1
  },
  'VN' => {
    'zho' => 2,
    'vie' => 1
  },
  'CU' => {
    'spa' => 1
  },
  'FM' => {
    'pon' => 2,
    'chk' => 2,
    'eng' => 1
  },
  'SE' => {
    'swe' => 1,
    'fin' => 2,
    'eng' => 2
  },
  'VI' => {
    'eng' => 1
  },
  'TT' => {
    'eng' => 1
  },
  'ZM' => {
    'eng' => 1,
    'bem' => 2,
    'nya' => 2
  },
  'KG' => {
    'kir' => 1,
    'rus' => 1
  },
  'CM' => {
    'fra' => 1,
    'bmv' => 2,
    'eng' => 1
  },
  'TA' => {
    'eng' => 2
  },
  'TL' => {
    'tet' => 1,
    'por' => 1
  },
  'DE' => {
    'eng' => 2,
    'spa' => 2,
    'rus' => 2,
    'fra' => 2,
    'bar' => 2,
    'tur' => 2,
    'deu' => 1,
    'nds' => 2,
    'vmf' => 2,
    'gsw' => 2,
    'dan' => 2,
    'nld' => 2,
    'ita' => 2
  },
  'QA' => {
    'ara' => 1
  },
  'DO' => {
    'spa' => 1
  },
  'HN' => {
    'spa' => 1
  },
  'CH' => {
    'fra' => 1,
    'ita' => 1,
    'deu' => 1,
    'eng' => 2,
    'roh' => 2,
    'gsw' => 1
  },
  'WS' => {
    'eng' => 1,
    'smo' => 1
  },
  'CR' => {
    'spa' => 1
  },
  'AM' => {
    'hye' => 1
  },
  'KH' => {
    'khm' => 1
  },
  'NO' => {
    'nor' => 1,
    'nno' => 1,
    'sme' => 2,
    'nob' => 1
  },
  'VG' => {
    'eng' => 1
  },
  'IE' => {
    'eng' => 1,
    'gle' => 1
  },
  'MH' => {
    'mah' => 1,
    'eng' => 1
  },
  'GE' => {
    'abk' => 2,
    'oss' => 2,
    'kat' => 1
  },
  'SS' => {
    'ara' => 2,
    'eng' => 1
  },
  'ID' => {
    'jav' => 2,
    'bew' => 2,
    'msa' => 2,
    'mad' => 2,
    'bbc' => 2,
    'ace' => 2,
    'rej' => 2,
    'zho' => 2,
    'mak' => 2,
    'sun' => 2,
    'bjn' => 2,
    'ban' => 2,
    'sas' => 2,
    'bug' => 2,
    'ind' => 1,
    'gqr' => 2,
    'min' => 2,
    'ljp' => 2
  },
  'PR' => {
    'spa' => 1,
    'eng' => 1
  },
  'GI' => {
    'eng' => 1,
    'spa' => 2
  },
  'AT' => {
    'slv' => 2,
    'bar' => 2,
    'hun' => 2,
    'hbs' => 2,
    'hrv' => 2,
    'deu' => 1,
    'eng' => 2
  },
  'CN' => {
    'nan' => 2,
    'bod' => 2,
    'zho' => 1,
    'wuu' => 2,
    'kaz' => 2,
    'kor' => 2,
    'yue' => 2,
    'hsn' => 2,
    'gan' => 2,
    'hak' => 2,
    'iii' => 2,
    'mon' => 2,
    'uig' => 2,
    'zha' => 2
  },
  'FR' => {
    'spa' => 2,
    'eng' => 2,
    'deu' => 2,
    'oci' => 2,
    'fra' => 1,
    'ita' => 2
  },
  'ZA' => {
    'tsn' => 2,
    'tso' => 2,
    'zul' => 2,
    'sot' => 2,
    'ven' => 2,
    'afr' => 2,
    'nbl' => 2,
    'nso' => 2,
    'xho' => 2,
    'eng' => 1,
    'hin' => 2,
    'ssw' => 2
  }
};
$Script2Lang = {
  'Thaa' => {
    'div' => 1
  },
  'Beng' => {
    'lus' => 1,
    'ccp' => 1,
    'unx' => 1,
    'sat' => 2,
    'asm' => 1,
    'mni' => 1,
    'syl' => 1,
    'rkt' => 1,
    'unr' => 1,
    'bpy' => 1,
    'kha' => 2,
    'grt' => 1,
    'ben' => 1
  },
  'Shrd' => {
    'san' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Tglg' => {
    'fil' => 2
  },
  'Guru' => {
    'pan' => 1
  },
  'Limb' => {
    'lif' => 1
  },
  'Ethi' => {
    'byn' => 1,
    'amh' => 1,
    'wal' => 1,
    'tir' => 1,
    'tig' => 1,
    'orm' => 2,
    'gez' => 2
  },
  'Cprt' => {
    'grc' => 2
  },
  'Bali' => {
    'ban' => 2
  },
  'Xsux' => {
    'akk' => 2,
    'hit' => 2
  },
  'Deva' => {
    'gvr' => 1,
    'nep' => 1,
    'gon' => 1,
    'san' => 2,
    'bra' => 1,
    'thl' => 1,
    'gbm' => 1,
    'bfy' => 1,
    'taj' => 1,
    'mwr' => 1,
    'gom' => 1,
    'unx' => 1,
    'thr' => 1,
    'wtm' => 1,
    'dty' => 1,
    'hif' => 1,
    'kas' => 1,
    'raj' => 1,
    'btv' => 1,
    'jml' => 1,
    'kru' => 1,
    'kfr' => 1,
    'doi' => 1,
    'swv' => 1,
    'snd' => 1,
    'unr' => 1,
    'bap' => 1,
    'new' => 1,
    'rjs' => 1,
    'bhi' => 1,
    'xsr' => 1,
    'hne' => 1,
    'awa' => 1,
    'kok' => 1,
    'xnr' => 1,
    'bho' => 1,
    'sck' => 1,
    'bhb' => 1,
    'lif' => 1,
    'anp' => 1,
    'tdg' => 1,
    'kfy' => 1,
    'hoj' => 1,
    'mtr' => 1,
    'thq' => 1,
    'tdh' => 1,
    'sat' => 2,
    'wbr' => 1,
    'khn' => 1,
    'bjj' => 1,
    'brx' => 1,
    'noe' => 1,
    'mar' => 1,
    'mai' => 1,
    'tkt' => 1,
    'mag' => 1,
    'hoc' => 1,
    'mrd' => 1,
    'hin' => 1,
    'bgc' => 1,
    'srx' => 1,
    'pli' => 2,
    'mgp' => 1
  },
  'Copt' => {
    'cop' => 2
  },
  'Bamu' => {
    'bax' => 1
  },
  'Phlp' => {
    'abw' => 2
  },
  'Tavt' => {
    'blt' => 1
  },
  'Phli' => {
    'abw' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Gran' => {
    'san' => 2
  },
  'Hano' => {
    'hnn' => 2
  },
  'Modi' => {
    'mar' => 2
  },
  'Wara' => {
    'hoc' => 2
  },
  'Orkh' => {
    'otk' => 2
  },
  'Bugi' => {
    'mdr' => 2,
    'mak' => 2,
    'bug' => 2
  },
  'Osma' => {
    'som' => 2
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Buhd' => {
    'bku' => 2
  },
  'Armn' => {
    'hye' => 1
  },
  'Talu' => {
    'khb' => 1
  },
  'Sinh' => {
    'san' => 2,
    'pli' => 2,
    'sin' => 1
  },
  'Mroo' => {
    'mro' => 2
  },
  'Mand' => {
    'myz' => 2
  },
  'Gujr' => {
    'guj' => 1
  },
  'Ital' => {
    'ett' => 2,
    'xum' => 2,
    'osc' => 2
  },
  'Mlym' => {
    'mal' => 1
  },
  'Osge' => {
    'osa' => 1
  },
  'Hant' => {
    'zho' => 1,
    'yue' => 1
  },
  'Sidd' => {
    'san' => 2
  },
  'Ogam' => {
    'sga' => 2
  },
  'Tfng' => {
    'shr' => 1,
    'zgh' => 1,
    'zen' => 2,
    'rif' => 1,
    'tzm' => 1
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Hans' => {
    'hsn' => 1,
    'hak' => 1,
    'gan' => 1,
    'yue' => 1,
    'zha' => 2,
    'nan' => 1,
    'wuu' => 1,
    'lzh' => 2,
    'zho' => 1
  },
  'Taml' => {
    'bfq' => 1,
    'tam' => 1
  },
  'Cher' => {
    'chr' => 1
  },
  'Egyp' => {
    'egy' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Tale' => {
    'tdd' => 1
  },
  'Sylo' => {
    'syl' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Lydi' => {
    'xld' => 2
  },
  'Mong' => {
    'mon' => 2,
    'mnc' => 2
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Sind' => {
    'snd' => 2
  },
  'Narb' => {
    'xna' => 2
  },
  'Mtei' => {
    'mni' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Cans' => {
    'nsk' => 1,
    'crm' => 1,
    'crl' => 1,
    'den' => 2,
    'cre' => 1,
    'csw' => 1,
    'crk' => 1,
    'chp' => 2,
    'iku' => 1,
    'oji' => 1,
    'crj' => 1
  },
  'Aghb' => {
    'lez' => 2
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Phag' => {
    'mon' => 2,
    'zho' => 2
  },
  'Takr' => {
    'doi' => 2
  },
  'Mymr' => {
    'shn' => 1,
    'mya' => 1,
    'mnw' => 1,
    'kht' => 1
  },
  'Khoj' => {
    'snd' => 2
  },
  'Plrd' => {
    'hmn' => 1,
    'hmd' => 1
  },
  'Syrc' => {
    'aii' => 2,
    'syr' => 2,
    'tru' => 2,
    'ara' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Nkoo' => {
    'nqo' => 1,
    'bam' => 1,
    'man' => 1
  },
  'Khmr' => {
    'khm' => 1
  },
  'Laoo' => {
    'hnj' => 1,
    'lao' => 1,
    'kjg' => 1,
    'hmn' => 1
  },
  'Java' => {
    'jav' => 2
  },
  'Avst' => {
    'ave' => 2
  },
  'Perm' => {
    'kom' => 2
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Vaii' => {
    'vai' => 1
  },
  'Bopo' => {
    'zho' => 2
  },
  'Tirh' => {
    'mai' => 2
  },
  'Nbat' => {
    'arc' => 2
  },
  'Dupl' => {
    'fra' => 2
  },
  'Orya' => {
    'ori' => 1,
    'sat' => 2
  },
  'Telu' => {
    'wbq' => 1,
    'gon' => 1,
    'tel' => 1,
    'lmn' => 1
  },
  'Sund' => {
    'sun' => 2
  },
  'Cham' => {
    'cja' => 2,
    'cjm' => 1
  },
  'Thai' => {
    'lwl' => 1,
    'tha' => 1,
    'sqq' => 1,
    'tts' => 1,
    'lcp' => 1,
    'kxm' => 1,
    'pli' => 2,
    'kdt' => 1
  },
  'Cari' => {
    'xcr' => 2
  },
  'Armi' => {
    'arc' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Hani' => {
    'vie' => 2
  },
  'Kana' => {
    'ain' => 2,
    'ryu' => 1
  },
  'Mend' => {
    'men' => 2
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Mani' => {
    'xmn' => 2
  },
  'Olck' => {
    'sat' => 1
  },
  'Prti' => {
    'xpr' => 2
  },
  'Batk' => {
    'bbc' => 2
  },
  'Kore' => {
    'kor' => 1
  },
  'Sora' => {
    'srb' => 2
  },
  'Ugar' => {
    'uga' => 2
  },
  'Lepc' => {
    'lep' => 1
  },
  'Hebr' => {
    'jrb' => 1,
    'lad' => 1,
    'yid' => 1,
    'heb' => 1,
    'snx' => 2,
    'jpr' => 1
  },
  'Runr' => {
    'deu' => 2,
    'non' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Palm' => {
    'arc' => 2
  },
  'Linb' => {
    'grc' => 2
  },
  'Yiii' => {
    'iii' => 1
  },
  'Samr' => {
    'snx' => 2,
    'smp' => 2
  },
  'Geor' => {
    'xmf' => 1,
    'lzz' => 1,
    'kat' => 1
  },
  'Shaw' => {
    'eng' => 2
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Latn' => {
    'wls' => 1,
    'sid' => 1,
    'jmc' => 1,
    'vai' => 1,
    'frm' => 2,
    'cym' => 1,
    'gur' => 1,
    'aze' => 1,
    'bug' => 1,
    'nau' => 1,
    'nob' => 1,
    'cre' => 2,
    'mnu' => 1,
    'nhe' => 1,
    'vot' => 2,
    'seh' => 1,
    'rmf' => 1,
    'tzm' => 1,
    'nhw' => 1,
    'maz' => 1,
    'ewe' => 1,
    'sag' => 1,
    'sly' => 1,
    'mad' => 1,
    'slv' => 1,
    'saf' => 1,
    'kmb' => 1,
    'kjg' => 2,
    'brh' => 2,
    'hnn' => 1,
    'tso' => 1,
    'vic' => 1,
    'tgk' => 1,
    'bqv' => 1,
    'hat' => 1,
    'kge' => 1,
    'lzz' => 1,
    'xho' => 1,
    'ceb' => 1,
    'gqr' => 1,
    'tur' => 1,
    'ssy' => 1,
    'din' => 1,
    'hop' => 1,
    'crs' => 1,
    'rmu' => 1,
    'aar' => 1,
    'zza' => 1,
    'tsi' => 1,
    'fil' => 1,
    'arn' => 1,
    'bze' => 1,
    'kin' => 1,
    'kon' => 1,
    'yao' => 1,
    'quc' => 1,
    'moe' => 1,
    'srp' => 1,
    'kkj' => 1,
    'krl' => 1,
    'fin' => 1,
    'hai' => 1,
    'mlt' => 1,
    'nij' => 1,
    'fvr' => 1,
    'frs' => 1,
    'hun' => 1,
    'sgs' => 1,
    'udm' => 2,
    'vls' => 1,
    'pfl' => 1,
    'spa' => 1,
    'osc' => 2,
    'swa' => 1,
    'fud' => 1,
    'nch' => 1,
    'teo' => 1,
    'sxn' => 1,
    'gil' => 1,
    'xog' => 1,
    'sco' => 1,
    'bal' => 2,
    'lmo' => 1,
    'dak' => 1,
    'sat' => 2,
    'stq' => 1,
    'gay' => 1,
    'bku' => 1,
    'lua' => 1,
    'ksh' => 1,
    'nno' => 1,
    'tpi' => 1,
    'guz' => 1,
    'mls' => 1,
    'den' => 1,
    'kck' => 1,
    'mro' => 1,
    'tog' => 1,
    'bbj' => 1,
    'glg' => 1,
    'kgp' => 1,
    'smj' => 1,
    'ada' => 1,
    'fuv' => 1,
    'buc' => 1,
    'vmf' => 1,
    'wol' => 1,
    'suk' => 1,
    'mdr' => 1,
    'mak' => 1,
    'mdh' => 1,
    'fro' => 2,
    'vun' => 1,
    'pko' => 1,
    'naq' => 1,
    'ltg' => 1,
    'mas' => 1,
    'ksf' => 1,
    'was' => 1,
    'shr' => 1,
    'frr' => 1,
    'her' => 1,
    'yap' => 1,
    'aka' => 1,
    'scs' => 1,
    'tli' => 1,
    'bss' => 1,
    'eka' => 1,
    'tru' => 1,
    'man' => 1,
    'krj' => 1,
    'kau' => 1,
    'cos' => 1,
    'srd' => 1,
    'vie' => 1,
    'tiv' => 1,
    'akz' => 1,
    'mlg' => 1,
    'cad' => 1,
    'ton' => 1,
    'lub' => 1,
    'mdt' => 1,
    'aoz' => 1,
    'bkm' => 1,
    'bmq' => 1,
    'som' => 1,
    'hmo' => 1,
    'lit' => 1,
    'nld' => 1,
    'jav' => 1,
    'gcr' => 1,
    'wae' => 1,
    'wln' => 1,
    'egl' => 1,
    'ssw' => 1,
    'dum' => 2,
    'kos' => 1,
    'ria' => 1,
    'ale' => 1,
    'gag' => 1,
    'sqi' => 1,
    'ttt' => 1,
    'nds' => 1,
    'crl' => 2,
    'umb' => 1,
    'ter' => 1,
    'bin' => 1,
    'bzx' => 1,
    'tsg' => 1,
    'scn' => 1,
    'cic' => 1,
    'yua' => 1,
    'pro' => 2,
    'agq' => 1,
    'msa' => 1,
    'hau' => 1,
    'sef' => 1,
    'ven' => 1,
    'ltz' => 1,
    'bto' => 1,
    'saq' => 1,
    'kvr' => 1,
    'csb' => 2,
    'wbp' => 1,
    'trv' => 1,
    'ndo' => 1,
    'smn' => 1,
    'khq' => 1,
    'ang' => 2,
    'deu' => 1,
    'slk' => 1,
    'moh' => 1,
    'sun' => 1,
    'rif' => 1,
    'srn' => 1,
    'kab' => 1,
    'vmw' => 1,
    'xav' => 1,
    'gla' => 1,
    'ilo' => 1,
    'nde' => 1,
    'kaj' => 1,
    'bar' => 1,
    'mgh' => 1,
    'nor' => 1,
    'iii' => 2,
    'pau' => 1,
    'rwk' => 1,
    'loz' => 1,
    'dav' => 1,
    'kiu' => 1,
    'haw' => 1,
    'aln' => 1,
    'por' => 1,
    'jut' => 2,
    'pdt' => 1,
    'pnt' => 1,
    'bfd' => 1,
    'ain' => 2,
    'tmh' => 1,
    'iku' => 1,
    'prg' => 2,
    'est' => 1,
    'arg' => 1,
    'sbp' => 1,
    'mgy' => 1,
    'liv' => 2,
    'kcg' => 1,
    'uzb' => 1,
    'pms' => 1,
    'ett' => 2,
    'cps' => 1,
    'dsb' => 1,
    'chp' => 1,
    'pcm' => 1,
    'byv' => 1,
    'uli' => 1,
    'nso' => 1,
    'sus' => 1,
    'afr' => 1,
    'gba' => 1,
    'run' => 1,
    'kea' => 1,
    'gsw' => 1,
    'cay' => 1,
    'gmh' => 2,
    'ron' => 1,
    'ybb' => 1,
    'lav' => 1,
    'nap' => 1,
    'tkr' => 1,
    'mua' => 1,
    'yav' => 1,
    'mwl' => 1,
    'kua' => 1,
    'yrl' => 1,
    'hin' => 2,
    'hbs' => 1,
    'car' => 1,
    'fan' => 1,
    'mxc' => 1,
    'oji' => 2,
    'ffm' => 1,
    'ses' => 1,
    'oci' => 1,
    'rtm' => 1,
    'ife' => 1,
    'nsk' => 2,
    'bvb' => 1,
    'yor' => 1,
    'tsn' => 1,
    'tly' => 1,
    'nzi' => 1,
    'myx' => 1,
    'ebu' => 1,
    'smo' => 1,
    'ast' => 1,
    'avk' => 2,
    'kur' => 1,
    'rgn' => 1,
    'dtp' => 1,
    'zul' => 1,
    'nym' => 1,
    'nyo' => 1,
    'kfo' => 1,
    'bew' => 1,
    'mri' => 1,
    'ewo' => 1,
    'gub' => 1,
    'glv' => 1,
    'mic' => 1,
    'dje' => 1,
    'rcf' => 1,
    'maf' => 1,
    'xum' => 2,
    'lat' => 2,
    'dtm' => 1,
    'tkl' => 1,
    'kdh' => 1,
    'min' => 1,
    'grb' => 1,
    'nnh' => 1,
    'ikt' => 1,
    'uig' => 2,
    'bam' => 1,
    'rup' => 1,
    'aro' => 1,
    'kik' => 1,
    'cho' => 1,
    'arp' => 1,
    'lin' => 1,
    'kax' => 1,
    'bbc' => 1,
    'sms' => 1,
    'tvl' => 1,
    'gle' => 1,
    'hrv' => 1,
    'orm' => 1,
    'ctd' => 1,
    'rom' => 1,
    'bem' => 1,
    'sli' => 1,
    'sma' => 1,
    'kln' => 1,
    'ttb' => 1,
    'eus' => 1,
    'grn' => 1,
    'pcd' => 1,
    'tet' => 1,
    'bci' => 1,
    'puu' => 1,
    'bjn' => 1,
    'lbw' => 1,
    'snk' => 1,
    'zap' => 1,
    'dyo' => 1,
    'mwk' => 1,
    'hil' => 1,
    'bik' => 1,
    'rej' => 1,
    'vep' => 1,
    'lim' => 1,
    'chy' => 1,
    'sna' => 1,
    'sei' => 1,
    'cch' => 1,
    'syi' => 1,
    'nmg' => 1,
    'aym' => 1,
    'ndc' => 1,
    'nbl' => 1,
    'rob' => 1,
    'hmn' => 1,
    'izh' => 1,
    'nus' => 1,
    'del' => 1,
    'kdx' => 1,
    'lfn' => 2,
    'war' => 1,
    'njo' => 1,
    'kpe' => 1,
    'sad' => 1,
    'sas' => 1,
    'abr' => 1,
    'enm' => 2,
    'tbw' => 1,
    'nia' => 1,
    'hif' => 1,
    'tum' => 1,
    'ipk' => 1,
    'osa' => 2,
    'kha' => 1,
    'gwi' => 1,
    'sot' => 1,
    'fon' => 1,
    'nya' => 1,
    'cat' => 1,
    'isl' => 1,
    'lut' => 2,
    'ach' => 1,
    'asa' => 1,
    'vol' => 2,
    'ful' => 1,
    'ngl' => 1,
    'lkt' => 1,
    'chk' => 1,
    'atj' => 1,
    'ina' => 2,
    'cor' => 1,
    'bos' => 1,
    'sdc' => 1,
    'lug' => 1,
    'chn' => 2,
    'kri' => 1,
    'ext' => 1,
    'swg' => 1,
    'lui' => 2,
    'ibo' => 1,
    'dan' => 1,
    'zag' => 1,
    'mwv' => 1,
    'ces' => 1,
    'nav' => 1,
    'swe' => 1,
    'vec' => 1,
    'bas' => 1,
    'iba' => 1,
    'ibb' => 1,
    'ljp' => 1,
    'ttj' => 1,
    'pdc' => 1,
    'pmn' => 1,
    'qug' => 1,
    'fra' => 1,
    'bez' => 1,
    'rof' => 1,
    'efi' => 1,
    'pol' => 1,
    'gos' => 1,
    'ban' => 1,
    'hsb' => 1,
    'mus' => 1,
    'ita' => 1,
    'zea' => 1,
    'roh' => 1,
    'amo' => 1,
    'eng' => 1,
    'mfe' => 1,
    'pag' => 1,
    'kde' => 1,
    'nov' => 2,
    'kal' => 1,
    'bmv' => 1,
    'zun' => 1,
    'rug' => 1,
    'mah' => 1,
    'szl' => 1,
    'twq' => 1,
    'frc' => 1,
    'bis' => 1,
    'bre' => 1,
    'pap' => 1,
    'srr' => 1,
    'lam' => 1,
    'crj' => 2,
    'luo' => 1,
    'lol' => 1,
    'frp' => 1,
    'swb' => 2,
    'ind' => 1,
    'srb' => 1,
    'ksb' => 1,
    'rap' => 1,
    'bla' => 1,
    'kac' => 1,
    'epo' => 1,
    'cgg' => 1,
    'sga' => 2,
    'sme' => 1,
    'lij' => 1,
    'tah' => 1,
    'nyn' => 1,
    'ace' => 1,
    'lag' => 1,
    'cha' => 1,
    'kir' => 1,
    'guc' => 1,
    'mgo' => 1,
    'laj' => 1,
    'niu' => 1,
    'inh' => 2,
    'nxq' => 1,
    'luy' => 1,
    'mos' => 1,
    'que' => 1,
    'vro' => 1,
    'dua' => 1,
    'dgr' => 1,
    'rar' => 1,
    'goh' => 2,
    'fij' => 1,
    'fuq' => 1,
    'esu' => 1,
    'arw' => 2,
    'dyu' => 1,
    'pon' => 1,
    'tuk' => 1,
    'lun' => 1,
    'fao' => 1,
    'rng' => 1,
    'hup' => 1,
    'kut' => 1,
    'jgo' => 1,
    'dnj' => 1,
    'men' => 1,
    'zha' => 1,
    'fry' => 1,
    'see' => 1,
    'zmi' => 1,
    'jam' => 1,
    'rmo' => 1,
    'fit' => 1
  },
  'Phnx' => {
    'phn' => 2
  },
  'Cyrl' => {
    'rom' => 2,
    'mon' => 1,
    'bel' => 1,
    'cjs' => 1,
    'srp' => 1,
    'kjh' => 1,
    'ttt' => 1,
    'chu' => 2,
    'uig' => 1,
    'evn' => 1,
    'kca' => 1,
    'gag' => 2,
    'sah' => 1,
    'tgk' => 1,
    'sel' => 2,
    'gld' => 1,
    'kur' => 1,
    'dng' => 1,
    'abk' => 1,
    'tly' => 1,
    'kkt' => 1,
    'aze' => 1,
    'bos' => 1,
    'mrj' => 1,
    'tkr' => 1,
    'hbs' => 1,
    'yrk' => 1,
    'ava' => 1,
    'ron' => 2,
    'tab' => 1,
    'kaa' => 1,
    'kbd' => 1,
    'lbe' => 1,
    'chm' => 1,
    'rue' => 1,
    'ukr' => 1,
    'uzb' => 1,
    'tuk' => 1,
    'tat' => 1,
    'lfn' => 2,
    'bul' => 1,
    'kpy' => 1,
    'ckt' => 1,
    'aii' => 1,
    'bak' => 1,
    'kum' => 1,
    'syr' => 1,
    'mdf' => 1,
    'pnt' => 1,
    'mns' => 1,
    'inh' => 1,
    'krc' => 1,
    'abq' => 1,
    'tyv' => 1,
    'alt' => 1,
    'xal' => 1,
    'ude' => 1,
    'chv' => 1,
    'myv' => 1,
    'kir' => 1,
    'lez' => 1,
    'ady' => 1,
    'oss' => 1,
    'che' => 1,
    'sme' => 2,
    'kom' => 1,
    'crh' => 1,
    'mkd' => 1,
    'nog' => 1,
    'bub' => 1,
    'dar' => 1,
    'rus' => 1,
    'kaz' => 1,
    'udm' => 1
  },
  'Arab' => {
    'gju' => 1,
    'khw' => 1,
    'cop' => 2,
    'aze' => 1,
    'tly' => 1,
    'kur' => 1,
    'kvx' => 1,
    'pan' => 1,
    'luz' => 1,
    'som' => 2,
    'sdh' => 1,
    'bqi' => 1,
    'brh' => 1,
    'cjm' => 2,
    'cja' => 1,
    'tgk' => 1,
    'glk' => 1,
    'tur' => 2,
    'kxp' => 1,
    'rmt' => 1,
    'prd' => 1,
    'fas' => 1,
    'ttt' => 2,
    'uig' => 1,
    'snd' => 1,
    'bej' => 1,
    'haz' => 1,
    'gjk' => 1,
    'mzn' => 1,
    'urd' => 1,
    'kas' => 1,
    'raj' => 1,
    'hau' => 1,
    'msa' => 1,
    'kaz' => 1,
    'mvy' => 1,
    'swb' => 1,
    'lrc' => 1,
    'skr' => 1,
    'ind' => 2,
    'pus' => 1,
    'aeb' => 1,
    'bal' => 1,
    'lki' => 1,
    'dyo' => 2,
    'arq' => 1,
    'kir' => 1,
    'ary' => 1,
    'dcc' => 1,
    'inh' => 2,
    'wni' => 1,
    'arz' => 1,
    'lah' => 1,
    'ckb' => 1,
    'ara' => 1,
    'ars' => 1,
    'zdj' => 1,
    'wol' => 2,
    'doi' => 1,
    'uzb' => 1,
    'fia' => 1,
    'tuk' => 1,
    'hno' => 1,
    'gbz' => 1,
    'sus' => 2,
    'bgn' => 1,
    'mfa' => 1,
    'bft' => 1,
    'hnd' => 1,
    'shr' => 1
  },
  'Lina' => {
    'lab' => 2
  },
  'Grek' => {
    'cop' => 2,
    'grc' => 2,
    'tsd' => 1,
    'bgx' => 1,
    'ell' => 1,
    'pnt' => 1
  },
  'Tibt' => {
    'tsj' => 1,
    'bod' => 1,
    'bft' => 2,
    'taj' => 2,
    'tdg' => 2,
    'dzo' => 1
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Knda' => {
    'kan' => 1,
    'tcy' => 1
  }
};
$DefaultScript = {
  'zdj' => 'Arab',
  'bul' => 'Cyrl',
  'esu' => 'Latn',
  'fia' => 'Arab',
  'bpy' => 'Beng',
  'nqo' => 'Nkoo',
  'mos' => 'Latn',
  'bak' => 'Cyrl',
  'que' => 'Latn',
  'lah' => 'Arab',
  'rar' => 'Latn',
  'tsj' => 'Tibt',
  'dgr' => 'Latn',
  'tts' => 'Thai',
  'men' => 'Latn',
  'wal' => 'Ethi',
  'see' => 'Latn',
  'mnw' => 'Mymr',
  'tab' => 'Cyrl',
  'fit' => 'Latn',
  'fao' => 'Latn',
  'rue' => 'Cyrl',
  'hup' => 'Latn',
  'jgo' => 'Latn',
  'ind' => 'Latn',
  'srb' => 'Latn',
  'epo' => 'Latn',
  'bla' => 'Latn',
  'rap' => 'Latn',
  'cgg' => 'Latn',
  'mag' => 'Deva',
  'lam' => 'Latn',
  'hye' => 'Armn',
  'lol' => 'Latn',
  'luo' => 'Latn',
  'crj' => 'Cans',
  'kan' => 'Knda',
  'guc' => 'Latn',
  'mgo' => 'Latn',
  'niu' => 'Latn',
  'wni' => 'Arab',
  'laj' => 'Latn',
  'abq' => 'Cyrl',
  'nxq' => 'Latn',
  'tah' => 'Latn',
  'oss' => 'Cyrl',
  'tdh' => 'Deva',
  'ace' => 'Latn',
  'wbr' => 'Deva',
  'lag' => 'Latn',
  'dcc' => 'Arab',
  'lez' => 'Cyrl',
  'rof' => 'Latn',
  'swv' => 'Deva',
  'kru' => 'Deva',
  'efi' => 'Latn',
  'hsb' => 'Latn',
  'sqq' => 'Thai',
  'lmn' => 'Telu',
  'rjs' => 'Deva',
  'bod' => 'Tibt',
  'pdc' => 'Latn',
  'fra' => 'Latn',
  'fas' => 'Arab',
  'pag' => 'Latn',
  'kde' => 'Latn',
  'szl' => 'Latn',
  'twq' => 'Latn',
  'mah' => 'Latn',
  'bis' => 'Latn',
  'pap' => 'Latn',
  'amh' => 'Ethi',
  'roh' => 'Latn',
  'mfe' => 'Latn',
  'cor' => 'Latn',
  'lug' => 'Latn',
  'mar' => 'Deva',
  'dan' => 'Latn',
  'ful' => 'Latn',
  'ava' => 'Cyrl',
  'xmf' => 'Geor',
  'lkt' => 'Latn',
  'chk' => 'Latn',
  'ces' => 'Latn',
  'mwv' => 'Latn',
  'vec' => 'Latn',
  'iba' => 'Latn',
  'war' => 'Latn',
  'sad' => 'Latn',
  'rob' => 'Latn',
  'bhi' => 'Deva',
  'ara' => 'Arab',
  'kdx' => 'Latn',
  'del' => 'Latn',
  'gwi' => 'Latn',
  'sot' => 'Latn',
  'kha' => 'Latn',
  'isl' => 'Latn',
  'nya' => 'Latn',
  'tbw' => 'Latn',
  'ukr' => 'Cyrl',
  'kbd' => 'Cyrl',
  'thr' => 'Deva',
  'mkd' => 'Cyrl',
  'crh' => 'Cyrl',
  'tet' => 'Latn',
  'puu' => 'Latn',
  'aeb' => 'Arab',
  'bci' => 'Latn',
  'snk' => 'Latn',
  'ttb' => 'Latn',
  'kln' => 'Latn',
  'grn' => 'Latn',
  'pcd' => 'Latn',
  'cch' => 'Latn',
  'syi' => 'Latn',
  'hoj' => 'Deva',
  'nmg' => 'Latn',
  'kxm' => 'Thai',
  'myv' => 'Cyrl',
  'ryu' => 'Kana',
  'ndc' => 'Latn',
  'mwk' => 'Latn',
  'zap' => 'Latn',
  'chy' => 'Latn',
  'lim' => 'Latn',
  'rup' => 'Latn',
  'ikt' => 'Latn',
  'new' => 'Deva',
  'kik' => 'Latn',
  'bho' => 'Deva',
  'kdh' => 'Latn',
  'tvl' => 'Latn',
  'orm' => 'Latn',
  'ctd' => 'Latn',
  'tha' => 'Thai',
  'cho' => 'Latn',
  'arp' => 'Latn',
  'sms' => 'Latn',
  'ife' => 'Latn',
  'rtm' => 'Latn',
  'oci' => 'Latn',
  'nsk' => 'Cans',
  'nzi' => 'Latn',
  'tsn' => 'Latn',
  'yid' => 'Hebr',
  'yav' => 'Latn',
  'gju' => 'Arab',
  'hin' => 'Deva',
  'mxc' => 'Latn',
  'fan' => 'Latn',
  'ses' => 'Latn',
  'zul' => 'Latn',
  'dtp' => 'Latn',
  'blt' => 'Tavt',
  'bew' => 'Latn',
  'gan' => 'Hans',
  'glv' => 'Latn',
  'gub' => 'Latn',
  'asm' => 'Beng',
  'tat' => 'Cyrl',
  'pms' => 'Latn',
  'sck' => 'Deva',
  'anp' => 'Deva',
  'nod' => 'Lana',
  'cay' => 'Latn',
  'gvr' => 'Deva',
  'bgn' => 'Arab',
  'run' => 'Latn',
  'gsw' => 'Latn',
  'ron' => 'Latn',
  'nap' => 'Latn',
  'lav' => 'Latn',
  'chp' => 'Latn',
  'chm' => 'Cyrl',
  'bfy' => 'Deva',
  'uli' => 'Latn',
  'byv' => 'Latn',
  'gba' => 'Latn',
  'afr' => 'Latn',
  'skr' => 'Arab',
  'deu' => 'Latn',
  'pus' => 'Arab',
  'smn' => 'Latn',
  'moh' => 'Latn',
  'slk' => 'Latn',
  'lad' => 'Hebr',
  'mai' => 'Deva',
  'mrd' => 'Deva',
  'rus' => 'Cyrl',
  'saq' => 'Latn',
  'wbp' => 'Latn',
  'trv' => 'Latn',
  'tyv' => 'Cyrl',
  'mgh' => 'Latn',
  'tel' => 'Telu',
  'alt' => 'Cyrl',
  'rwk' => 'Latn',
  'pau' => 'Latn',
  'chv' => 'Cyrl',
  'kiu' => 'Latn',
  'loz' => 'Latn',
  'dav' => 'Latn',
  'krc' => 'Cyrl',
  'aln' => 'Latn',
  'sun' => 'Latn',
  'vmw' => 'Latn',
  'kab' => 'Latn',
  'zgh' => 'Tfng',
  'ilo' => 'Latn',
  'gla' => 'Latn',
  'nan' => 'Hans',
  'kaj' => 'Latn',
  'nde' => 'Latn',
  'jml' => 'Deva',
  'tsd' => 'Grek',
  'ter' => 'Latn',
  'bin' => 'Latn',
  'umb' => 'Latn',
  'xsr' => 'Deva',
  'mni' => 'Beng',
  'bhb' => 'Deva',
  'mon' => 'Cyrl',
  'ltz' => 'Latn',
  'tsg' => 'Latn',
  'bzx' => 'Latn',
  'csw' => 'Cans',
  'mzn' => 'Arab',
  'scn' => 'Latn',
  'wtm' => 'Deva',
  'agq' => 'Latn',
  'lus' => 'Beng',
  'bjj' => 'Deva',
  'cos' => 'Latn',
  'tiv' => 'Latn',
  'kkt' => 'Cyrl',
  'bss' => 'Latn',
  'tli' => 'Latn',
  'tdg' => 'Deva',
  'som' => 'Latn',
  'hmo' => 'Latn',
  'wln' => 'Latn',
  'wae' => 'Latn',
  'gcr' => 'Latn',
  'cjm' => 'Cham',
  'nld' => 'Latn',
  'dng' => 'Cyrl',
  'mdt' => 'Latn',
  'kvx' => 'Arab',
  'vmf' => 'Latn',
  'mdr' => 'Latn',
  'arz' => 'Arab',
  'kum' => 'Cyrl',
  'mdf' => 'Cyrl',
  'kok' => 'Deva',
  'mas' => 'Latn',
  'ksf' => 'Latn',
  'scs' => 'Latn',
  'yap' => 'Latn',
  'pko' => 'Latn',
  'vun' => 'Latn',
  'ltg' => 'Latn',
  'sin' => 'Sinh',
  'spa' => 'Latn',
  'pfl' => 'Latn',
  'fud' => 'Latn',
  'nch' => 'Latn',
  'mvy' => 'Arab',
  'ksh' => 'Latn',
  'ude' => 'Cyrl',
  'guz' => 'Latn',
  'den' => 'Latn',
  'glg' => 'Latn',
  'tog' => 'Latn',
  'dak' => 'Latn',
  'lua' => 'Latn',
  'sat' => 'Olck',
  'zza' => 'Latn',
  'aar' => 'Latn',
  'fil' => 'Latn',
  'bze' => 'Latn',
  'arn' => 'Latn',
  'kjh' => 'Cyrl',
  'hne' => 'Deva',
  'bqv' => 'Latn',
  'kge' => 'Latn',
  'kyu' => 'Kali',
  'tur' => 'Latn',
  'gqr' => 'Latn',
  'crs' => 'Latn',
  'hop' => 'Latn',
  'dzo' => 'Tibt',
  'gjk' => 'Arab',
  'yao' => 'Latn',
  'kkj' => 'Latn',
  'urd' => 'Arab',
  'fin' => 'Latn',
  'krl' => 'Latn',
  'gur' => 'Latn',
  'nob' => 'Latn',
  'mnu' => 'Latn',
  'kor' => 'Kore',
  'cym' => 'Latn',
  'crm' => 'Cans',
  'mtr' => 'Deva',
  'brh' => 'Arab',
  'vic' => 'Latn',
  'ori' => 'Orya',
  'sag' => 'Latn',
  'slv' => 'Latn',
  'mad' => 'Latn',
  'jpr' => 'Hebr',
  'fuq' => 'Latn',
  'fij' => 'Latn',
  'guj' => 'Gujr',
  'dyu' => 'Latn',
  'pon' => 'Latn',
  'lun' => 'Latn',
  'wuu' => 'Hans',
  'awa' => 'Deva',
  'vro' => 'Latn',
  'dua' => 'Latn',
  'fry' => 'Latn',
  'zha' => 'Latn',
  'mfa' => 'Arab',
  'bft' => 'Arab',
  'zmi' => 'Latn',
  'rmo' => 'Latn',
  'jam' => 'Latn',
  'kaa' => 'Cyrl',
  'rng' => 'Latn',
  'heb' => 'Hebr',
  'dnj' => 'Latn',
  'kut' => 'Latn',
  'ksb' => 'Latn',
  'kac' => 'Latn',
  'brx' => 'Deva',
  'bub' => 'Cyrl',
  'kom' => 'Cyrl',
  'lki' => 'Arab',
  'srr' => 'Latn',
  'dar' => 'Cyrl',
  'swb' => 'Arab',
  'frp' => 'Latn',
  'mgp' => 'Deva',
  'lrc' => 'Arab',
  'hmd' => 'Plrd',
  'mns' => 'Cyrl',
  'eky' => 'Kali',
  'inh' => 'Cyrl',
  'luy' => 'Latn',
  'lij' => 'Latn',
  'saz' => 'Saur',
  'nyn' => 'Latn',
  'sme' => 'Latn',
  'cha' => 'Latn',
  'khn' => 'Deva',
  'bez' => 'Latn',
  'gos' => 'Latn',
  'ban' => 'Latn',
  'pol' => 'Latn',
  'wbq' => 'Telu',
  'lao' => 'Laoo',
  'mus' => 'Latn',
  'ita' => 'Latn',
  'bej' => 'Arab',
  'bap' => 'Deva',
  'ttj' => 'Latn',
  'ljp' => 'Latn',
  'pmn' => 'Latn',
  'glk' => 'Arab',
  'qug' => 'Latn',
  'prd' => 'Arab',
  'bmv' => 'Latn',
  'kal' => 'Latn',
  'lep' => 'Lepc',
  'rug' => 'Latn',
  'zun' => 'Latn',
  'frc' => 'Latn',
  'bre' => 'Latn',
  'zea' => 'Latn',
  'eng' => 'Latn',
  'amo' => 'Latn',
  'bel' => 'Cyrl',
  'raj' => 'Deva',
  'atj' => 'Latn',
  'sdc' => 'Latn',
  'ext' => 'Latn',
  'hsn' => 'Hans',
  'kri' => 'Latn',
  'ibo' => 'Latn',
  'swg' => 'Latn',
  'ach' => 'Latn',
  'ngl' => 'Latn',
  'asa' => 'Latn',
  'yrk' => 'Cyrl',
  'khw' => 'Arab',
  'bgc' => 'Deva',
  'srx' => 'Deva',
  'ben' => 'Beng',
  'sdh' => 'Arab',
  'bqi' => 'Arab',
  'nav' => 'Latn',
  'ibb' => 'Latn',
  'bas' => 'Latn',
  'swe' => 'Latn',
  'zag' => 'Latn',
  'byn' => 'Ethi',
  'njo' => 'Latn',
  'kpe' => 'Latn',
  'sas' => 'Latn',
  'abr' => 'Latn',
  'ckt' => 'Cyrl',
  'nbl' => 'Latn',
  'aii' => 'Cyrl',
  'hmn' => 'Latn',
  'nus' => 'Latn',
  'izh' => 'Latn',
  'osa' => 'Osge',
  'ipk' => 'Latn',
  'fon' => 'Latn',
  'cat' => 'Latn',
  'thl' => 'Deva',
  'hno' => 'Arab',
  'nia' => 'Latn',
  'gbz' => 'Arab',
  'tum' => 'Latn',
  'lbe' => 'Cyrl',
  'bjn' => 'Latn',
  'tam' => 'Taml',
  'lbw' => 'Latn',
  'jpn' => 'Jpan',
  'sma' => 'Latn',
  'eus' => 'Latn',
  'aym' => 'Latn',
  'bik' => 'Latn',
  'hil' => 'Latn',
  'dyo' => 'Latn',
  'ady' => 'Cyrl',
  'rej' => 'Latn',
  'vep' => 'Latn',
  'sei' => 'Latn',
  'sna' => 'Latn',
  'aro' => 'Latn',
  'haz' => 'Arab',
  'maf' => 'Latn',
  'cja' => 'Arab',
  'rcf' => 'Latn',
  'grb' => 'Latn',
  'tkl' => 'Latn',
  'min' => 'Latn',
  'dtm' => 'Latn',
  'nnh' => 'Latn',
  'rmt' => 'Arab',
  'tig' => 'Ethi',
  'hrv' => 'Latn',
  'gle' => 'Latn',
  'rom' => 'Latn',
  'sli' => 'Latn',
  'bem' => 'Latn',
  'gbm' => 'Deva',
  'lin' => 'Latn',
  'shn' => 'Mymr',
  'bbc' => 'Latn',
  'mal' => 'Mlym',
  'kax' => 'Latn',
  'cjs' => 'Cyrl',
  'yor' => 'Latn',
  'bvb' => 'Latn',
  'lis' => 'Lisu',
  'tkt' => 'Deva',
  'mua' => 'Latn',
  'rkt' => 'Beng',
  'mwl' => 'Latn',
  'kua' => 'Latn',
  'car' => 'Latn',
  'yrl' => 'Latn',
  'oji' => 'Cans',
  'ffm' => 'Latn',
  'nym' => 'Latn',
  'kfo' => 'Latn',
  'luz' => 'Arab',
  'nyo' => 'Latn',
  'mri' => 'Latn',
  'ewo' => 'Latn',
  'gld' => 'Cyrl',
  'mic' => 'Latn',
  'dje' => 'Latn',
  'myx' => 'Latn',
  'smo' => 'Latn',
  'ebu' => 'Latn',
  'ast' => 'Latn',
  'rgn' => 'Latn',
  'est' => 'Latn',
  'arg' => 'Latn',
  'doi' => 'Arab',
  'sbp' => 'Latn',
  'mgy' => 'Latn',
  'lwl' => 'Thai',
  'kcg' => 'Latn',
  'dsb' => 'Latn',
  'cps' => 'Latn',
  'pdt' => 'Latn',
  'bfd' => 'Latn',
  'ell' => 'Grek',
  'ckb' => 'Arab',
  'ars' => 'Arab',
  'tmh' => 'Latn',
  'kea' => 'Latn',
  'tir' => 'Ethi',
  'jrb' => 'Hebr',
  'ybb' => 'Latn',
  'pcm' => 'Latn',
  'nso' => 'Latn',
  'taj' => 'Deva',
  'kht' => 'Mymr',
  'sus' => 'Latn',
  'khq' => 'Latn',
  'bfq' => 'Taml',
  'bto' => 'Latn',
  'kvr' => 'Latn',
  'ndo' => 'Latn',
  'grt' => 'Beng',
  'iii' => 'Yiii',
  'haw' => 'Latn',
  'por' => 'Latn',
  'srn' => 'Latn',
  'thq' => 'Deva',
  'che' => 'Cyrl',
  'xav' => 'Latn',
  'bar' => 'Latn',
  'ary' => 'Arab',
  'crl' => 'Cans',
  'div' => 'Thaa',
  'nds' => 'Latn',
  'egl' => 'Latn',
  'kos' => 'Latn',
  'ssw' => 'Latn',
  'ale' => 'Latn',
  'ria' => 'Latn',
  'xnr' => 'Deva',
  'bgx' => 'Grek',
  'evn' => 'Cyrl',
  'sqi' => 'Latn',
  'kxp' => 'Arab',
  'gag' => 'Latn',
  'ven' => 'Latn',
  'sef' => 'Latn',
  'chr' => 'Cher',
  'bra' => 'Deva',
  'yua' => 'Latn',
  'cic' => 'Latn',
  'vie' => 'Latn',
  'srd' => 'Latn',
  'noe' => 'Deva',
  'tcy' => 'Knda',
  'hoc' => 'Deva',
  'eka' => 'Latn',
  'tru' => 'Latn',
  'kau' => 'Latn',
  'krj' => 'Latn',
  'bmq' => 'Latn',
  'lit' => 'Latn',
  'jav' => 'Latn',
  'akz' => 'Latn',
  'cad' => 'Latn',
  'mlg' => 'Latn',
  'kat' => 'Geor',
  'aoz' => 'Latn',
  'bkm' => 'Latn',
  'tdd' => 'Tale',
  'ton' => 'Latn',
  'lub' => 'Latn',
  'fuv' => 'Latn',
  'wol' => 'Latn',
  'kpy' => 'Cyrl',
  'kfr' => 'Deva',
  'buc' => 'Latn',
  'suk' => 'Latn',
  'kgp' => 'Latn',
  'smj' => 'Latn',
  'ada' => 'Latn',
  'kdt' => 'Thai',
  'was' => 'Latn',
  'her' => 'Latn',
  'hnd' => 'Arab',
  'frr' => 'Latn',
  'hak' => 'Hans',
  'aka' => 'Latn',
  'mak' => 'Latn',
  'mwr' => 'Deva',
  'mdh' => 'Latn',
  'btv' => 'Deva',
  'naq' => 'Latn',
  'sxn' => 'Latn',
  'nog' => 'Cyrl',
  'sco' => 'Latn',
  'xog' => 'Latn',
  'gil' => 'Latn',
  'bal' => 'Arab',
  'lmo' => 'Latn',
  'vls' => 'Latn',
  'udm' => 'Cyrl',
  'crk' => 'Cans',
  'swa' => 'Latn',
  'mya' => 'Mymr',
  'teo' => 'Latn',
  'nno' => 'Latn',
  'tpi' => 'Latn',
  'xal' => 'Cyrl',
  'mls' => 'Latn',
  'kck' => 'Latn',
  'khb' => 'Talu',
  'mro' => 'Latn',
  'bbj' => 'Latn',
  'arq' => 'Arab',
  'bku' => 'Latn',
  'gay' => 'Latn',
  'stq' => 'Latn',
  'khm' => 'Khmr',
  'tsi' => 'Latn',
  'kin' => 'Latn',
  'sah' => 'Cyrl',
  'xho' => 'Latn',
  'ceb' => 'Latn',
  'hat' => 'Latn',
  'ssy' => 'Latn',
  'din' => 'Latn',
  'rmu' => 'Latn',
  'kca' => 'Cyrl',
  'mlt' => 'Latn',
  'frs' => 'Latn',
  'nep' => 'Deva',
  'hun' => 'Latn',
  'fvr' => 'Latn',
  'nij' => 'Latn',
  'sgs' => 'Latn',
  'hnj' => 'Laoo',
  'kon' => 'Latn',
  'syl' => 'Beng',
  'gom' => 'Deva',
  'moe' => 'Latn',
  'quc' => 'Latn',
  'dty' => 'Deva',
  'hai' => 'Latn',
  'nau' => 'Latn',
  'lcp' => 'Thai',
  'bug' => 'Latn',
  'nhe' => 'Latn',
  'wls' => 'Latn',
  'sid' => 'Latn',
  'jmc' => 'Latn',
  'mrj' => 'Cyrl',
  'saf' => 'Latn',
  'bax' => 'Bamu',
  'kjg' => 'Laoo',
  'kmb' => 'Latn',
  'kfy' => 'Deva',
  'tso' => 'Latn',
  'hnn' => 'Latn',
  'rmf' => 'Latn',
  'seh' => 'Latn',
  'abk' => 'Cyrl',
  'maz' => 'Latn',
  'ewe' => 'Latn',
  'nhw' => 'Latn',
  'sly' => 'Latn'
};
$DefaultTerritory = {
  'shr_Tfng' => 'MA',
  'mkd' => 'MK',
  'su_Latn' => 'ID',
  'kn' => 'IN',
  'id' => 'ID',
  'ta' => 'IN',
  'tam' => 'IN',
  'ha' => 'NG',
  'gd' => 'GB',
  'ii' => 'CN',
  'kln' => 'KE',
  'ttb' => 'GH',
  'eus' => 'ES',
  'km' => 'KH',
  'sma' => 'SE',
  'jpn' => 'JP',
  'grn' => 'PY',
  'nmg' => 'CM',
  'myv' => 'RU',
  'cch' => 'NG',
  'ky' => 'KG',
  'dyo' => 'SN',
  'sna' => 'ZW',
  'ml' => 'IN',
  'ms_Arab' => 'MY',
  'dz' => 'BT',
  'kpe' => 'LR',
  'syr' => 'IQ',
  'gv' => 'IM',
  'nbl' => 'ZA',
  'eng_Dsrt' => 'US',
  'aa' => 'ET',
  'kdx' => 'KE',
  'nus' => 'SS',
  'mon_Mong' => 'CN',
  'sot' => 'ZA',
  'kas_Arab' => 'IN',
  'osa' => 'US',
  'fo' => 'FO',
  'pt' => 'BR',
  'nya' => 'MW',
  'isl' => 'IS',
  'nl' => 'NL',
  'cat' => 'ES',
  'ful_Latn' => 'SN',
  'ukr' => 'UA',
  'lb' => 'LU',
  'ss' => 'ZA',
  'iu_Latn' => 'CA',
  'yor' => 'NG',
  'oci' => 'FR',
  'ife' => 'TG',
  'sw' => 'TZ',
  'tsn' => 'ZA',
  'be' => 'BY',
  'hin' => 'IN',
  'ks_Deva' => 'IN',
  'mua' => 'CM',
  'yav' => 'CM',
  'te' => 'IN',
  'kl' => 'GL',
  'iku_Latn' => 'CA',
  'ses' => 'ML',
  'ka' => 'GE',
  'sk' => 'SK',
  'zul' => 'ZA',
  'dje' => 'NE',
  'msa_Arab' => 'MY',
  'glv' => 'IM',
  'mri' => 'NZ',
  'blt' => 'VN',
  'ewo' => 'CM',
  'ebu' => 'KE',
  'ast' => 'ES',
  'cs' => 'CZ',
  'asm' => 'IN',
  'kur' => 'TR',
  'mg' => 'MG',
  'uig' => 'CN',
  'bam' => 'ML',
  'kik' => 'KE',
  'kam' => 'KE',
  'ff_Adlm' => 'GN',
  'ha_Arab' => 'NG',
  'ku' => 'TR',
  'bg' => 'BG',
  'tk' => 'TM',
  'pan_Arab' => 'PK',
  'nnh' => 'CM',
  'gle' => 'IE',
  'el' => 'GR',
  'tig' => 'ER',
  'orm' => 'ET',
  'hrv' => 'HR',
  'om' => 'ET',
  'vai_Vaii' => 'LR',
  'bem' => 'ZM',
  'ee' => 'GH',
  'dv' => 'MV',
  'tha' => 'TH',
  'cv' => 'RU',
  'vi' => 'VN',
  'fur' => 'IT',
  'lin' => 'CD',
  'sms' => 'FI',
  'mal' => 'IN',
  'lu' => 'CD',
  'brx' => 'IN',
  'mn_Mong' => 'CN',
  'ksb' => 'TZ',
  'ind' => 'ID',
  'ts' => 'ZA',
  'ig' => 'NG',
  'cgg' => 'UG',
  'fy' => 'NL',
  'hye' => 'AM',
  'mer' => 'KE',
  'af' => 'ZA',
  'az_Arab' => 'IR',
  'kaz' => 'KZ',
  'lrc' => 'IR',
  'si' => 'LK',
  'kan' => 'IN',
  'luo' => 'KE',
  'mgo' => 'CM',
  'luy' => 'KE',
  'cu' => 'RU',
  'sme' => 'NO',
  'en_Dsrt' => 'US',
  'oss' => 'GE',
  'nyn' => 'UG',
  'ps' => 'AF',
  'kir' => 'KG',
  'lag' => 'TZ',
  'co' => 'FR',
  'bul' => 'BG',
  'nr' => 'ZA',
  'ko' => 'KR',
  'tuk' => 'TM',
  'sa' => 'IN',
  'am' => 'ET',
  'guj' => 'IN',
  'az_Cyrl' => 'AZ',
  'que' => 'PE',
  'bak' => 'RU',
  'az_Latn' => 'AZ',
  'nqo' => 'GN',
  'dua' => 'CM',
  'qu' => 'PE',
  'wal' => 'ET',
  'sg' => 'CF',
  'da' => 'DK',
  'fry' => 'NL',
  'fi' => 'FI',
  'fao' => 'FO',
  'mk' => 'MK',
  'jgo' => 'CM',
  'heb' => 'IL',
  'es' => 'ES',
  'ug' => 'CN',
  'ne' => 'NP',
  'aze_Arab' => 'IR',
  'lug' => 'UG',
  'cor' => 'GB',
  'uzb_Arab' => 'AF',
  'ibo' => 'NG',
  'dan' => 'DK',
  'mar' => 'IN',
  'asa' => 'TZ',
  'ja' => 'JP',
  'bn' => 'BD',
  'ga' => 'IE',
  'lkt' => 'US',
  'yue_Hans' => 'CN',
  'ces' => 'CZ',
  'sdh' => 'IR',
  'ben' => 'BD',
  'bas' => 'CM',
  'swe' => 'SE',
  'ki' => 'KE',
  'shi_Tfng' => 'MA',
  'byn' => 'ER',
  'sl' => 'SI',
  'pan_Guru' => 'IN',
  'fr' => 'FR',
  'rm' => 'CH',
  'pol' => 'PL',
  'sv' => 'SE',
  'se' => 'NO',
  'bez' => 'TZ',
  'chu' => 'RU',
  'rof' => 'TZ',
  'hsb' => 'DE',
  'mus' => 'US',
  'ita' => 'IT',
  'sd_Arab' => 'PK',
  'lao' => 'LA',
  'bod' => 'CN',
  'fas' => 'IR',
  'fra' => 'FR',
  'szl' => 'PL',
  'twq' => 'NE',
  'mn' => 'MN',
  'kde' => 'TZ',
  'kal' => 'GL',
  'amh' => 'ET',
  'bre' => 'FR',
  'san' => 'IN',
  'srp_Cyrl' => 'RS',
  'eng' => 'US',
  'roh' => 'CH',
  'snd_Arab' => 'PK',
  'mfe' => 'MU',
  'bel' => 'BY',
  'sin' => 'LK',
  'xog' => 'UG',
  'eu' => 'ES',
  'sc' => 'IT',
  'spa' => 'ES',
  'to' => 'TO',
  'ful_Adlm' => 'GN',
  'teo' => 'UG',
  'mya' => 'MM',
  'swa' => 'TZ',
  'guz' => 'KE',
  'uzb_Cyrl' => 'UZ',
  'ksh' => 'DE',
  'br' => 'FR',
  'nno' => 'NO',
  'glg' => 'ES',
  'sun_Latn' => 'ID',
  'rn' => 'BI',
  'bm' => 'ML',
  'ny' => 'MW',
  'ur' => 'PK',
  'tt' => 'RU',
  'sd_Deva' => 'IN',
  'ccp' => 'BD',
  'th' => 'TH',
  'khm' => 'KH',
  'gn' => 'PY',
  'rw' => 'RW',
  'wol' => 'SN',
  'en' => 'US',
  'bm_Nkoo' => 'ML',
  'bs_Latn' => 'BA',
  'kok' => 'IN',
  'smj' => 'SE',
  'snd_Deva' => 'IN',
  'bam_Nkoo' => 'ML',
  'ken' => 'CM',
  'hi_Latn' => 'IN',
  'ksf' => 'CM',
  'uz_Arab' => 'AF',
  'mas' => 'KE',
  'lt' => 'LT',
  'zho_Hant' => 'TW',
  'aka' => 'GH',
  'tr' => 'TR',
  'kw' => 'GB',
  'vun' => 'TZ',
  'kas_Deva' => 'IN',
  'sat_Deva' => 'IN',
  'ks_Arab' => 'IN',
  'it' => 'IT',
  'naq' => 'NA',
  'bos_Cyrl' => 'BA',
  'nob' => 'NO',
  'kk' => 'KZ',
  'kor' => 'KR',
  'mnu' => 'KE',
  'uk' => 'UA',
  'oc' => 'FR',
  'jmc' => 'TZ',
  'sid' => 'ET',
  'wo' => 'SN',
  'wa' => 'BE',
  'cym' => 'GB',
  'tso' => 'ZA',
  'tzm' => 'MA',
  'ewe' => 'GH',
  'zh_Hant' => 'TW',
  'hi' => 'IN',
  'seh' => 'MZ',
  'ori' => 'IN',
  'uz_Cyrl' => 'UZ',
  'slv' => 'SI',
  'sag' => 'CF',
  'bos_Latn' => 'BA',
  'fil' => 'PH',
  'aar' => 'ET',
  'shi_Latn' => 'MA',
  'kin' => 'RW',
  'arn' => 'CL',
  'sn' => 'ZW',
  'xho' => 'ZA',
  'ceb' => 'PH',
  'mr' => 'IN',
  'tgk' => 'TJ',
  'aze_Cyrl' => 'AZ',
  'cy' => 'GB',
  'mi' => 'NZ',
  'sah' => 'RU',
  'zu' => 'ZA',
  'os' => 'GE',
  'tur' => 'TR',
  'ssy' => 'ER',
  'yo' => 'NG',
  'fvr' => 'IT',
  'hun' => 'HU',
  'uz_Latn' => 'UZ',
  'tn' => 'ZA',
  'nep' => 'NP',
  'mlt' => 'MT',
  'ms' => 'MY',
  'tg' => 'TJ',
  'hin_Latn' => 'IN',
  'quc' => 'GT',
  'pl' => 'PL',
  'lv' => 'LV',
  'hr' => 'HR',
  'gl' => 'ES',
  'ln' => 'CD',
  'dzo' => 'BT',
  'fin' => 'FI',
  'urd' => 'PK',
  'kkj' => 'CM',
  'smn' => 'FI',
  've' => 'ZA',
  'khq' => 'ML',
  'deu' => 'DE',
  'pus' => 'AF',
  'de' => 'DE',
  'mai' => 'IN',
  'slk' => 'SK',
  'moh' => 'CA',
  'mt' => 'MT',
  'saq' => 'KE',
  'hy' => 'AM',
  'gez' => 'ET',
  'uzb_Latn' => 'UZ',
  'sq' => 'AL',
  'rus' => 'RU',
  'pa_Arab' => 'PK',
  'pa_Guru' => 'IN',
  'trv' => 'TW',
  'wbp' => 'AU',
  'iii' => 'CN',
  'chv' => 'RU',
  'bs_Cyrl' => 'BA',
  'rwk' => 'TZ',
  'tel' => 'IN',
  'mgh' => 'MZ',
  'por' => 'BR',
  'dav' => 'KE',
  'haw' => 'US',
  'kab' => 'DZ',
  'che' => 'RU',
  'nn' => 'NO',
  'nde' => 'ZW',
  'nb' => 'NO',
  'kaj' => 'NG',
  'gla' => 'GB',
  'zgh' => 'MA',
  'aze_Latn' => 'AZ',
  'sbp' => 'TZ',
  'est' => 'EE',
  'arg' => 'ES',
  'gaa' => 'GH',
  'tat' => 'RU',
  'dsb' => 'DE',
  'kcg' => 'NG',
  'iku' => 'CA',
  'ckb' => 'IQ',
  'ell' => 'GR',
  'st' => 'ZA',
  'ti' => 'ET',
  'tir' => 'ET',
  'kea' => 'CV',
  'so' => 'SO',
  'run' => 'BI',
  'gsw' => 'CH',
  'bgn' => 'PK',
  'zh_Hans' => 'CN',
  'lav' => 'LV',
  'sat_Olck' => 'IN',
  'ron' => 'RO',
  'he' => 'IL',
  'nso' => 'ZA',
  'bo' => 'CN',
  'fa' => 'IR',
  'pcm' => 'NG',
  'ba' => 'RU',
  'afr' => 'ZA',
  'srd' => 'IT',
  'vie' => 'VN',
  'sr_Cyrl' => 'RS',
  'cos' => 'FR',
  'et' => 'EE',
  'hu' => 'HU',
  'hau_Arab' => 'NG',
  'jv' => 'ID',
  'bss' => 'CM',
  'lg' => 'UG',
  'ca' => 'ES',
  'my' => 'MM',
  'som' => 'SO',
  'is' => 'IS',
  'nld' => 'NL',
  'jav' => 'ID',
  'wae' => 'CH',
  'wln' => 'BE',
  'lit' => 'LT',
  'mlg' => 'MG',
  'cad' => 'US',
  'mni_Beng' => 'IN',
  'nd' => 'ZW',
  'lub' => 'CD',
  'ton' => 'TO',
  'kat' => 'GE',
  'ak' => 'GH',
  'nds' => 'DE',
  'gu' => 'IN',
  'div' => 'MV',
  'iu' => 'CA',
  'zho_Hans' => 'CN',
  'yue_Hant' => 'HK',
  'srp_Latn' => 'RS',
  'ru' => 'RU',
  'vai_Latn' => 'LR',
  'ssw' => 'ZA',
  'or' => 'IN',
  'sr_Latn' => 'RS',
  'an' => 'ES',
  'as' => 'IN',
  'sqi' => 'AL',
  'ff_Latn' => 'SN',
  'ven' => 'ZA',
  'ce' => 'RU',
  'shr_Latn' => 'MA',
  'msa' => 'MY',
  'hau' => 'NG',
  'mon' => 'MN',
  'chr' => 'US',
  'lo' => 'LA',
  'ltz' => 'LU',
  'scn' => 'IT',
  'xh' => 'ZA',
  'mzn' => 'IR',
  'mni_Mtei' => 'IN',
  'agq' => 'CM',
  'cic' => 'US',
  'ro' => 'RO'
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
    print STDERR "unsupported script $_[0]\n";
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
	if (my $count = contains_script($s, $str, 1)){
	    $char{$$UnicodeScriptCode{$s}} = $count;
	    $covered += $count;
	}
    }

    ## if we have matched less characters than length of the string
    ## then continue looking for other kinds of scripts
    ## TODO: this is an approximate condition as we can have property overlaps!
    if ($covered < length($str)){
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
    return $$ScriptName2ScriptCode{$_[0]} if (exists $$ScriptName2ScriptCode{$_[0]});
    print STDERR "unknown script $_[0]\n";
    return undef;
}

sub script_name{
    return $$ScriptCode2ScriptName{$_[0]} if (exists $$ScriptCode2ScriptName{$_[0]});
    print STDERR "unknown script $_[0]\n";
    return undef;
}

sub language_scripts{
    return sort keys %{$$Lang2Script{$_[0]}} if (exists $$Lang2Script{$_[0]});
    print STDERR "unknown language $_[0] (require ISO-639-3 code)\n";
    return ();
}

sub default_script{
    return $$DefaultScript{$_[0]} if (exists $$DefaultScript{$_[0]});
    print STDERR "unknown language $_[0] (require ISO-639-3 code)\n";
    return undef;
}

sub languages_with_script{
    return sort keys %{$$Script2Lang{$_[0]}} if (exists $$Script2Lang{$_[0]});
    my $code = script_code($_[0]);
    return sort keys %{$$Script2Lang{$code}} if (exists $$Script2Lang{$code});
    print STDERR "unknown script $_[0]\n";
    return ();
}

sub primary_languages_with_script{
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
    return keys %{$$Lang2Territory{$_[0]}} if (exists $$Lang2Territory{$_[0]});
    print STDERR "unknown language $_[0] (require ISO-639-3 code)\n";
    return undef;
}

sub default_territory{
    return $$DefaultTerritory{$_[0]} if (exists $$DefaultTerritory{$_[0]});
    print STDERR "unknown language $_[0] (require ISO-639-3 code)\n";
    return undef;
}

sub primary_territories{
    if (exists $$Lang2Territory{$_[0]}){
	return grep($$Lang2Territory{$_[0]}{$_} == 1, keys %{$$Lang2Territory{$_[0]}});
    }
    print STDERR "unknown language $_[0] (require ISO-639-3 code)\n";
    return ();
}

sub secondary_territories{
    if (exists $$Lang2Territory{$_[0]}){
	return grep($$Lang2Territory{$_[0]}{$_} == 2, keys %{$$Lang2Territory{$_[0]}});
    }
    print STDERR "unknown language $_[0] (require ISO-639-3 code)\n";
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


