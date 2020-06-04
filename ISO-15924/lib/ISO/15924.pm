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



$ScriptCode2ScriptName = {
  'Cirt' => '',
  'Geor' => 'Georgian',
  'Hung' => 'Old_Hungarian',
  'Cans' => 'Canadian_Aboriginal',
  'Orkh' => 'Old_Turkic',
  'Prti' => 'Inscriptional_Parthian',
  'Beng' => 'Bengali',
  'Armn' => 'Armenian',
  'Ethi' => 'Ethiopic',
  'Dsrt' => 'Deseret',
  'Shrd' => 'Sharada',
  'Knda' => 'Kannada',
  'Hani' => 'Han',
  'Maka' => 'Makasar',
  'Guru' => 'Gurmukhi',
  'Maya' => '',
  'Blis' => '',
  'Lepc' => 'Lepcha',
  'Linb' => 'Linear_B',
  'Avst' => 'Avestan',
  'Bopo' => 'Bopomofo',
  'Diak' => 'Dives_Akuru',
  'Mult' => 'Multani',
  'Kali' => 'Kayah_Li',
  'Newa' => 'Newa',
  'Grek' => 'Greek',
  'Hant' => '',
  'Hang' => 'Hangul',
  'Elym' => 'Elymaic',
  'Ahom' => 'Ahom',
  'Inds' => '',
  'Hrkt' => 'Katakana_Or_Hiragana',
  'Sogd' => 'Sogdian',
  'Goth' => 'Gothic',
  'Leke' => '',
  'Thaa' => 'Thaana',
  'Brai' => 'Braille',
  'Mand' => 'Mandaic',
  'Sgnw' => 'SignWriting',
  'Laoo' => 'Lao',
  'Tglg' => 'Tagalog',
  'Shui' => '',
  'Mong' => 'Mongolian',
  'Syrc' => 'Syriac',
  'Phag' => 'Phags_Pa',
  'Taml' => 'Tamil',
  'Modi' => 'Modi',
  'Telu' => 'Telugu',
  'Mymr' => 'Myanmar',
  'Geok' => 'Georgian',
  'Syrn' => '',
  'Yezi' => 'Yezidi',
  'Nand' => 'Nandinagari',
  'Talu' => 'New_Tai_Lue',
  'Shaw' => 'Shavian',
  'Mtei' => 'Meetei_Mayek',
  'Armi' => 'Imperial_Aramaic',
  'Orya' => 'Oriya',
  'Hanb' => '',
  'Tagb' => 'Tagbanwa',
  'Takr' => 'Takri',
  'Zinh' => 'Inherited',
  'Zsym' => '',
  'Soyo' => 'Soyombo',
  'Tfng' => 'Tifinagh',
  'Sund' => 'Sundanese',
  'Wara' => 'Warang_Citi',
  'Lydi' => 'Lydian',
  'Phlp' => 'Psalter_Pahlavi',
  'Khar' => 'Kharoshthi',
  'Kana' => 'Katakana',
  'Loma' => '',
  'Perm' => 'Old_Permic',
  'Mend' => 'Mende_Kikakui',
  'Wole' => '',
  'Glag' => 'Glagolitic',
  'Cprt' => 'Cypriot',
  'Hira' => 'Hiragana',
  'Sara' => '',
  'Rjng' => 'Rejang',
  'Hmnp' => 'Nyiakeng_Puachue_Hmong',
  'Lana' => 'Tai_Tham',
  'Zanb' => 'Zanabazar_Square',
  'Bass' => 'Bassa_Vah',
  'Java' => 'Javanese',
  'Cyrl' => 'Cyrillic',
  'Toto' => '',
  'Zzzz' => 'Unknown',
  'Gran' => 'Grantha',
  'Zmth' => '',
  'Kitl' => '',
  'Mroo' => 'Mro',
  'Jamo' => '',
  'Hano' => 'Hanunoo',
  'Chrs' => 'Chorasmian',
  'Mahj' => 'Mahajani',
  'Hluw' => 'Anatolian_Hieroglyphs',
  'Tibt' => 'Tibetan',
  'Zxxx' => '',
  'Jpan' => '',
  'Nkdb' => '',
  'Yiii' => 'Yi',
  'Cyrs' => '',
  'Elba' => 'Elbasan',
  'Egyd' => '',
  'Kthi' => 'Kaithi',
  'Qaaa' => '',
  'Ogam' => 'Ogham',
  'Hatr' => 'Hatran',
  'Medf' => 'Medefaidrin',
  'Sind' => 'Khudawadi',
  'Wcho' => 'Wancho',
  'Osma' => 'Osmanya',
  'Visp' => '',
  'Nkoo' => 'Nko',
  'Sinh' => 'Sinhala',
  'Gonm' => 'Masaram_Gondi',
  'Khoj' => 'Khojki',
  'Copt' => 'Coptic',
  'Lina' => 'Linear_A',
  'Bugi' => 'Buginese',
  'Kits' => 'Khitan_Small_Script',
  'Egyh' => '',
  'Mlym' => 'Malayalam',
  'Limb' => 'Limbu',
  'Latf' => '',
  'Dogr' => 'Dogra',
  'Sidd' => 'Siddham',
  'Hmng' => 'Pahawh_Hmong',
  'Narb' => 'Old_North_Arabian',
  'Syrj' => '',
  'Kpel' => '',
  'Cher' => 'Cherokee',
  'Ital' => 'Old_Italic',
  'Arab' => 'Arabic',
  'Aran' => '',
  'Moon' => '',
  'Nbat' => 'Nabataean',
  'Deva' => 'Devanagari',
  'Latn' => 'Latin',
  'Mani' => 'Manichaean',
  'Bhks' => 'Bhaiksuki',
  'Osge' => 'Osage',
  'Hans' => '',
  'Phli' => 'Inscriptional_Pahlavi',
  'Brah' => 'Brahmi',
  'Aghb' => 'Caucasian_Albanian',
  'Jurc' => '',
  'Nkgb' => '',
  'Teng' => '',
  'Pauc' => 'Pau_Cin_Hau',
  'Samr' => 'Samaritan',
  'Cakm' => 'Chakma',
  'Runr' => 'Runic',
  'Xsux' => 'Cuneiform',
  'Zsye' => '',
  'Zyyy' => 'Common',
  'Marc' => 'Marchen',
  'Xpeo' => 'Old_Persian',
  'Tang' => 'Tangut',
  'Phnx' => 'Phoenician',
  'Lyci' => 'Lycian',
  'Dupl' => 'Duployan',
  'Rohg' => 'Hanifi_Rohingya',
  'Olck' => 'Ol_Chiki',
  'Hebr' => 'Hebrew',
  'Latg' => '',
  'Merc' => 'Meroitic_Cursive',
  'Roro' => '',
  'Sylo' => 'Syloti_Nagri',
  'Sora' => 'Sora_Sompeng',
  'Tavt' => 'Tai_Viet',
  'Afak' => '',
  'Sogo' => 'Old_Sogdian',
  'Gong' => 'Gunjala_Gondi',
  'Tirh' => 'Tirhuta',
  'Bali' => 'Balinese',
  'Vaii' => 'Vai',
  'Saur' => 'Saurashtra',
  'Gujr' => 'Gujarati',
  'Phlv' => '',
  'Cham' => 'Cham',
  'Plrd' => 'Miao',
  'Piqd' => '',
  'Batk' => 'Batak',
  'Syre' => '',
  'Qabx' => '',
  'Cpmn' => '',
  'Adlm' => 'Adlam',
  'Sarb' => 'Old_South_Arabian',
  'Cari' => 'Carian',
  'Thai' => 'Thai',
  'Kore' => '',
  'Egyp' => 'Egyptian_Hieroglyphs',
  'Nshu' => 'Nushu',
  'Lisu' => 'Lisu',
  'Ugar' => 'Ugaritic',
  'Palm' => 'Palmyrene',
  'Khmr' => 'Khmer',
  'Mero' => 'Meroitic_Hieroglyphs',
  'Tale' => 'Tai_Le',
  'Buhd' => 'Buhid',
  'Bamu' => 'Bamum'
};
$ScriptName2ScriptCode = {
  'Limbu' => 'Limb',
  'Medefaidrin' => 'Medf',
  'Georgian' => 'Geor',
  'Arabic' => 'Arab',
  'Javanese' => 'Java',
  'Samaritan' => 'Samr',
  'Lisu' => 'Lisu',
  'Osmanya' => 'Osma',
  'Devanagari' => 'Deva',
  'Tagbanwa' => 'Tagb',
  'Glagolitic' => 'Glag',
  'Tibetan' => 'Tibt',
  'Batak' => 'Batk',
  'Lycian' => 'Lyci',
  'Old_Permic' => 'Perm',
  'Cyrillic' => 'Cyrl',
  'Lepcha' => 'Lepc',
  'Rejang' => 'Rjng',
  'Gothic' => 'Goth',
  'Yezidi' => 'Yezi',
  'Khitan_Small_Script' => 'Kits',
  'Braille' => 'Brai',
  'Hanunoo' => 'Hano',
  'Kayah_Li' => 'Kali',
  'Hanifi_Rohingya' => 'Rohg',
  'Gurmukhi' => 'Guru',
  'Old_Italic' => 'Ital',
  'Inscriptional_Parthian' => 'Prti',
  'Tangut' => 'Tang',
  'Sundanese' => 'Sund',
  'Bamum' => 'Bamu',
  'Soyombo' => 'Soyo',
  'Elbasan' => 'Elba',
  'Takri' => 'Takr',
  'Thai' => 'Thai',
  'Nushu' => 'Nshu',
  'Inherited' => 'Zinh',
  'New_Tai_Lue' => 'Talu',
  'Lydian' => 'Lydi',
  'Nko' => 'Nkoo',
  'Runic' => 'Runr',
  'Malayalam' => 'Mlym',
  'Adlam' => 'Adlm',
  'Duployan' => 'Dupl',
  'Ugaritic' => 'Ugar',
  'Caucasian_Albanian' => 'Aghb',
  'Meroitic_Cursive' => 'Merc',
  'Vai' => 'Vaii',
  'Lao' => 'Laoo',
  'Pau_Cin_Hau' => 'Pauc',
  'Cuneiform' => 'Xsux',
  'Linear_B' => 'Linb',
  'Bassa_Vah' => 'Bass',
  'Thaana' => 'Thaa',
  'Canadian_Aboriginal' => 'Cans',
  'Osage' => 'Osge',
  'Brahmi' => 'Brah',
  'Old_Sogdian' => 'Sogo',
  'Carian' => 'Cari',
  'Psalter_Pahlavi' => 'Phlp',
  'Kaithi' => 'Kthi',
  'Cham' => 'Cham',
  'Greek' => 'Grek',
  'Dives_Akuru' => 'Diak',
  'Khojki' => 'Khoj',
  'Tai_Le' => 'Tale',
  'Mandaic' => 'Mand',
  'Makasar' => 'Maka',
  'Marchen' => 'Marc',
  'Armenian' => 'Armn',
  'Balinese' => 'Bali',
  'Linear_A' => 'Lina',
  'Coptic' => 'Copt',
  'Old_South_Arabian' => 'Sarb',
  'Hiragana' => 'Hira',
  'Old_Persian' => 'Xpeo',
  'Elymaic' => 'Elym',
  'Sharada' => 'Shrd',
  'Buhid' => 'Buhd',
  'Zanabazar_Square' => 'Zanb',
  'Avestan' => 'Avst',
  'Egyptian_Hieroglyphs' => 'Egyp',
  'Multani' => 'Mult',
  'Chakma' => 'Cakm',
  'Sora_Sompeng' => 'Sora',
  'Sinhala' => 'Sinh',
  'Yi' => 'Yiii',
  'Nyiakeng_Puachue_Hmong' => 'Hmnp',
  'Manichaean' => 'Mani',
  'Modi' => 'Modi',
  '' => 'Zxxx',
  'Mende_Kikakui' => 'Mend',
  'Old_Turkic' => 'Orkh',
  'Oriya' => 'Orya',
  'Deseret' => 'Dsrt',
  'Siddham' => 'Sidd',
  'Khmer' => 'Khmr',
  'Hatran' => 'Hatr',
  'Unknown' => 'Zzzz',
  'Cherokee' => 'Cher',
  'Hangul' => 'Hang',
  'Ahom' => 'Ahom',
  'Ol_Chiki' => 'Olck',
  'Wancho' => 'Wcho',
  'Katakana_Or_Hiragana' => 'Hrkt',
  'Bhaiksuki' => 'Bhks',
  'Tai_Viet' => 'Tavt',
  'Meetei_Mayek' => 'Mtei',
  'Pahawh_Hmong' => 'Hmng',
  'Tifinagh' => 'Tfng',
  'Old_Hungarian' => 'Hung',
  'Syloti_Nagri' => 'Sylo',
  'Mongolian' => 'Mong',
  'Anatolian_Hieroglyphs' => 'Hluw',
  'Meroitic_Hieroglyphs' => 'Mero',
  'Sogdian' => 'Sogd',
  'Kharoshthi' => 'Khar',
  'Bengali' => 'Beng',
  'SignWriting' => 'Sgnw',
  'Mahajani' => 'Mahj',
  'Kannada' => 'Knda',
  'Saurashtra' => 'Saur',
  'Syriac' => 'Syrc',
  'Telugu' => 'Telu',
  'Ethiopic' => 'Ethi',
  'Ogham' => 'Ogam',
  'Tirhuta' => 'Tirh',
  'Imperial_Aramaic' => 'Armi',
  'Cypriot' => 'Cprt',
  'Phags_Pa' => 'Phag',
  'Shavian' => 'Shaw',
  'Gunjala_Gondi' => 'Gong',
  'Masaram_Gondi' => 'Gonm',
  'Bopomofo' => 'Bopo',
  'Katakana' => 'Kana',
  'Grantha' => 'Gran',
  'Newa' => 'Newa',
  'Hebrew' => 'Hebr',
  'Latin' => 'Latn',
  'Tai_Tham' => 'Lana',
  'Han' => 'Hani',
  'Dogra' => 'Dogr',
  'Old_North_Arabian' => 'Narb',
  'Warang_Citi' => 'Wara',
  'Nabataean' => 'Nbat',
  'Nandinagari' => 'Nand',
  'Mro' => 'Mroo',
  'Tamil' => 'Taml',
  'Phoenician' => 'Phnx',
  'Khudawadi' => 'Sind',
  'Buginese' => 'Bugi',
  'Chorasmian' => 'Chrs',
  'Myanmar' => 'Mymr',
  'Miao' => 'Plrd',
  'Common' => 'Zyyy',
  'Gujarati' => 'Gujr',
  'Inscriptional_Pahlavi' => 'Phli',
  'Tagalog' => 'Tglg',
  'Palmyrene' => 'Palm'
};
$ScriptId2ScriptCode = {
  '050' => 'Egyp',
  '312' => 'Gong',
  '145' => 'Mong',
  '499' => 'Nshu',
  '329' => 'Soyo',
  '127' => 'Hatr',
  '399' => 'Lisu',
  '343' => 'Gran',
  '412' => 'Hrkt',
  '994' => 'Zinh',
  '318' => 'Sind',
  '439' => 'Afak',
  '225' => 'Glag',
  '351' => 'Lana',
  '372' => 'Buhd',
  '137' => 'Syrj',
  '451' => 'Hmnp',
  '200' => 'Grek',
  '206' => 'Goth',
  '339' => 'Zanb',
  '365' => 'Batk',
  '211' => 'Runr',
  '281' => 'Shaw',
  '359' => 'Tavt',
  '403' => 'Cprt',
  '105' => 'Sarb',
  '500' => 'Hani',
  '292' => 'Sara',
  '331' => 'Phag',
  '120' => 'Tfng',
  '126' => 'Palm',
  '020' => 'Xsux',
  '362' => 'Sund',
  '219' => 'Osge',
  '090' => 'Maya',
  '993' => 'Zsye',
  '949' => 'Qabx',
  '261' => 'Olck',
  '344' => 'Saur',
  '315' => 'Deva',
  '142' => 'Sogo',
  '030' => 'Xpeo',
  '136' => 'Syrn',
  '321' => 'Takr',
  '130' => 'Prti',
  '240' => 'Geor',
  '755' => 'Dupl',
  '291' => 'Cirt',
  '340' => 'Telu',
  '346' => 'Taml',
  '338' => 'Ahom',
  '109' => 'Chrs',
  '221' => 'Cyrs',
  '355' => 'Khmr',
  '440' => 'Cans',
  '285' => 'Bopo',
  '134' => 'Avst',
  '215' => 'Latn',
  '361' => 'Java',
  '332' => 'Marc',
  '438' => 'Mend',
  '319' => 'Shrd',
  '141' => 'Sogd',
  '398' => 'Sora',
  '262' => 'Wara',
  '328' => 'Dogr',
  '124' => 'Armi',
  '997' => 'Zxxx',
  '060' => 'Egyh',
  '322' => 'Khoj',
  '160' => 'Arab',
  '259' => 'Bass',
  '166' => 'Adlm',
  '347' => 'Mlym',
  '311' => 'Nand',
  '300' => 'Brah',
  '265' => 'Medf',
  '239' => 'Aghb',
  '070' => 'Egyd',
  '170' => 'Thaa',
  '123' => 'Samr',
  '176' => 'Hung',
  '411' => 'Kana',
  '503' => 'Hanb',
  '204' => 'Copt',
  '325' => 'Beng',
  '400' => 'Lina',
  '080' => 'Hluw',
  '116' => 'Lydi',
  '218' => 'Moon',
  '288' => 'Kits',
  '133' => 'Phlv',
  '352' => 'Thai',
  '371' => 'Hano',
  '435' => 'Bamu',
  '101' => 'Merc',
  '282' => 'Plrd',
  '212' => 'Ogam',
  '167' => 'Rohg',
  '996' => 'Zsym',
  '335' => 'Lepc',
  '358' => 'Cham',
  '348' => 'Sinh',
  '313' => 'Gonm',
  '330' => 'Tibt',
  '336' => 'Limb',
  '995' => 'Zmth',
  '501' => 'Hans',
  '115' => 'Phnx',
  '085' => 'Nkdb',
  '413' => 'Jpan',
  '342' => 'Diak',
  '900' => 'Qaaa',
  '436' => 'Kpel',
  '430' => 'Ethi',
  '510' => 'Jurc',
  '217' => 'Latf',
  '241' => 'Geok',
  '364' => 'Leke',
  '287' => 'Kore',
  '326' => 'Tirh',
  '373' => 'Tagb',
  '131' => 'Phli',
  '320' => 'Gujr',
  '620' => 'Roro',
  '570' => 'Brai',
  '305' => 'Khar',
  '260' => 'Osma',
  '159' => 'Nbat',
  '175' => 'Orkh',
  '294' => 'Toto',
  '357' => 'Kali',
  '420' => 'Nkgb',
  '293' => 'Piqd',
  '337' => 'Mtei',
  '139' => 'Mani',
  '165' => 'Nkoo',
  '402' => 'Cpmn',
  '363' => 'Rjng',
  '302' => 'Sidd',
  '437' => 'Loma',
  '286' => 'Hang',
  '445' => 'Cher',
  '280' => 'Visp',
  '216' => 'Latg',
  '210' => 'Ital',
  '201' => 'Cari',
  '327' => 'Orya',
  '450' => 'Hmng',
  '345' => 'Knda',
  '314' => 'Mahj',
  '356' => 'Laoo',
  '998' => 'Zyyy',
  '350' => 'Mymr',
  '367' => 'Bugi',
  '284' => 'Jamo',
  '401' => 'Linb',
  '250' => 'Dsrt',
  '135' => 'Syrc',
  '530' => 'Shui',
  '480' => 'Wole',
  '410' => 'Hira',
  '227' => 'Perm',
  '333' => 'Newa',
  '354' => 'Talu',
  '316' => 'Sylo',
  '310' => 'Guru',
  '610' => 'Inds',
  '470' => 'Vaii',
  '125' => 'Hebr',
  '202' => 'Lyci',
  '263' => 'Pauc',
  '520' => 'Tang',
  '095' => 'Sgnw',
  '106' => 'Narb',
  '100' => 'Mero',
  '323' => 'Mult',
  '370' => 'Tglg',
  '505' => 'Kitl',
  '349' => 'Cakm',
  '366' => 'Maka',
  '999' => 'Zzzz',
  '360' => 'Bali',
  '324' => 'Modi',
  '192' => 'Yezi',
  '460' => 'Yiii',
  '128' => 'Elym',
  '226' => 'Elba',
  '220' => 'Cyrl',
  '264' => 'Mroo',
  '317' => 'Kthi',
  '502' => 'Hant',
  '290' => 'Teng',
  '161' => 'Aran',
  '353' => 'Tale',
  '132' => 'Phlp',
  '334' => 'Bhks',
  '230' => 'Armn',
  '138' => 'Syre',
  '040' => 'Ugar',
  '283' => 'Wcho',
  '140' => 'Mand',
  '550' => 'Blis'
};
$ScriptCode2EnglishName = {
  'Leke' => 'Leke',
  'Goth' => 'Gothic',
  'Sogd' => 'Sogdian',
  'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
  'Inds' => 'Indus (Harappan)',
  'Ahom' => 'Ahom, Tai Ahom',
  'Elym' => 'Elymaic',
  'Hang' => "Hangul (Hang\x{16d}l, Hangeul)",
  'Tglg' => 'Tagalog (Baybayin, Alibata)',
  'Laoo' => 'Lao',
  'Sgnw' => 'SignWriting',
  'Mand' => 'Mandaic, Mandaean',
  'Brai' => 'Braille',
  'Thaa' => 'Thaana',
  'Mymr' => 'Myanmar (Burmese)',
  'Telu' => 'Telugu',
  'Modi' => "Modi, Mo\x{1e0d}\x{12b}",
  'Taml' => 'Tamil',
  'Syrc' => 'Syriac',
  'Phag' => 'Phags-pa',
  'Shui' => 'Shuishu',
  'Mong' => 'Mongolian',
  'Nand' => 'Nandinagari',
  'Yezi' => 'Yezidi',
  'Syrn' => 'Syriac (Eastern variant)',
  'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
  'Beng' => 'Bengali (Bangla)',
  'Prti' => 'Inscriptional Parthian',
  'Orkh' => 'Old Turkic, Orkhon Runic',
  'Cans' => 'Unified Canadian Aboriginal Syllabics',
  'Hung' => 'Old Hungarian (Hungarian Runic)',
  'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
  'Cirt' => 'Cirth',
  'Maka' => 'Makasar',
  'Hani' => 'Han (Hanzi, Kanji, Hanja)',
  'Knda' => 'Kannada',
  'Shrd' => "Sharada, \x{15a}\x{101}rad\x{101}",
  'Dsrt' => 'Deseret (Mormon)',
  'Armn' => 'Armenian',
  'Ethi' => "Ethiopic (Ge\x{2bb}ez)",
  'Linb' => 'Linear B',
  'Blis' => 'Blissymbols',
  'Lepc' => "Lepcha (R\x{f3}ng)",
  'Maya' => 'Mayan hieroglyphs',
  'Guru' => 'Gurmukhi',
  'Hant' => 'Han (Traditional variant)',
  'Grek' => 'Greek',
  'Newa' => "Newa, Newar, Newari, Nep\x{101}la lipi",
  'Kali' => 'Kayah Li',
  'Mult' => 'Multani',
  'Diak' => 'Dives Akuru',
  'Bopo' => 'Bopomofo',
  'Avst' => 'Avestan',
  'Bass' => 'Bassa Vah',
  'Zanb' => "Zanabazar Square (Zanabazarin D\x{f6}rb\x{f6}ljin Useg, Xewtee D\x{f6}rb\x{f6}ljin Bicig, Horizontal Square Script)",
  'Lana' => 'Tai Tham (Lanna)',
  'Hmnp' => 'Nyiakeng Puachue Hmong',
  'Rjng' => 'Rejang (Redjang, Kaganga)',
  'Sara' => 'Sarati',
  'Hira' => 'Hiragana',
  'Cprt' => 'Cypriot syllabary',
  'Glag' => 'Glagolitic',
  'Wole' => 'Woleai',
  'Zzzz' => 'Code for uncoded script',
  'Toto' => 'Toto',
  'Cyrl' => 'Cyrillic',
  'Java' => 'Javanese',
  'Kitl' => 'Khitan large script',
  'Zmth' => 'Mathematical notation',
  'Gran' => 'Grantha',
  'Nkdb' => "Naxi Dongba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} to\x{b3}\x{b3}ba\x{b2}\x{b9}, Nakhi Tomba)",
  'Jpan' => 'Japanese (alias for Han + Hiragana + Katakana)',
  'Zxxx' => 'Code for unwritten documents',
  'Tibt' => 'Tibetan',
  'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
  'Mahj' => 'Mahajani',
  'Chrs' => 'Chorasmian',
  'Hano' => "Hanunoo (Hanun\x{f3}o)",
  'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
  'Mroo' => 'Mro, Mru',
  'Tagb' => 'Tagbanwa',
  'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
  'Orya' => 'Oriya (Odia)',
  'Armi' => 'Imperial Aramaic',
  'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
  'Shaw' => 'Shavian (Shaw)',
  'Talu' => 'New Tai Lue',
  'Soyo' => 'Soyombo',
  'Zsym' => 'Symbols',
  'Zinh' => 'Code for inherited script',
  'Takr' => "Takri, \x{1e6c}\x{101}kr\x{12b}, \x{1e6c}\x{101}\x{1e45}kr\x{12b}",
  'Wara' => 'Warang Citi (Varang Kshiti)',
  'Sund' => 'Sundanese',
  'Tfng' => 'Tifinagh (Berber)',
  'Mend' => 'Mende Kikakui',
  'Perm' => 'Old Permic',
  'Loma' => 'Loma',
  'Kana' => 'Katakana',
  'Khar' => 'Kharoshthi',
  'Phlp' => 'Psalter Pahlavi',
  'Lydi' => 'Lydian',
  'Cher' => 'Cherokee',
  'Kpel' => 'Kpelle',
  'Syrj' => 'Syriac (Western variant)',
  'Narb' => 'Old North Arabian (Ancient North Arabian)',
  'Hmng' => 'Pahawh Hmong',
  'Sidd' => "Siddham, Siddha\x{1e43}, Siddham\x{101}t\x{1e5b}k\x{101}",
  'Dogr' => 'Dogra',
  'Osge' => 'Osage',
  'Bhks' => 'Bhaiksuki',
  'Latn' => 'Latin',
  'Mani' => 'Manichaean',
  'Deva' => 'Devanagari (Nagari)',
  'Nbat' => 'Nabataean',
  'Aran' => 'Arabic (Nastaliq variant)',
  'Moon' => 'Moon (Moon code, Moon script, Moon type)',
  'Arab' => 'Arabic',
  'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
  'Pauc' => 'Pau Cin Hau',
  'Nkgb' => "Naxi Geba (na\x{b2}\x{b9}\x{255}i\x{b3}\x{b3} g\x{28c}\x{b2}\x{b9}ba\x{b2}\x{b9}, 'Na-'Khi \x{b2}Gg\x{14f}-\x{b9}baw, Nakhi Geba)",
  'Teng' => 'Tengwar',
  'Jurc' => 'Jurchen',
  'Aghb' => 'Caucasian Albanian',
  'Brah' => 'Brahmi',
  'Phli' => 'Inscriptional Pahlavi',
  'Hans' => 'Han (Simplified variant)',
  'Marc' => 'Marchen',
  'Zyyy' => 'Code for undetermined script',
  'Zsye' => 'Symbols (Emoji variant)',
  'Xsux' => 'Cuneiform, Sumero-Akkadian',
  'Runr' => 'Runic',
  'Cakm' => 'Chakma',
  'Samr' => 'Samaritan',
  'Ogam' => 'Ogham',
  'Qaaa' => 'Reserved for private use (start)',
  'Kthi' => 'Kaithi',
  'Elba' => 'Elbasan',
  'Egyd' => 'Egyptian demotic',
  'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
  'Yiii' => 'Yi',
  'Wcho' => 'Wancho',
  'Medf' => "Medefaidrin (Oberi Okaime, Oberi \x{186}kaim\x{25b})",
  'Sind' => 'Khudawadi, Sindhi',
  'Hatr' => 'Hatran',
  'Sinh' => 'Sinhala',
  'Nkoo' => "N\x{2019}Ko",
  'Visp' => 'Visible Speech',
  'Osma' => 'Osmanya',
  'Limb' => 'Limbu',
  'Latf' => 'Latin (Fraktur variant)',
  'Mlym' => 'Malayalam',
  'Egyh' => 'Egyptian hieratic',
  'Kits' => 'Khitan small script',
  'Bugi' => 'Buginese',
  'Lina' => 'Linear A',
  'Copt' => 'Coptic',
  'Khoj' => 'Khojki',
  'Gonm' => 'Masaram Gondi',
  'Cpmn' => 'Cypro-Minoan',
  'Piqd' => 'Klingon (KLI pIqaD)',
  'Qabx' => 'Reserved for private use (end)',
  'Batk' => 'Batak',
  'Syre' => 'Syriac (Estrangelo variant)',
  'Plrd' => 'Miao (Pollard)',
  'Nshu' => "N\x{fc}shu",
  'Egyp' => 'Egyptian hieroglyphs',
  'Kore' => 'Korean (alias for Hangul + Han)',
  'Thai' => 'Thai',
  'Cari' => 'Carian',
  'Adlm' => 'Adlam',
  'Sarb' => 'Old South Arabian',
  'Ugar' => 'Ugaritic',
  'Lisu' => 'Lisu (Fraser)',
  'Bamu' => 'Bamum',
  'Tale' => 'Tai Le',
  'Buhd' => 'Buhid',
  'Mero' => 'Meroitic Hieroglyphs',
  'Khmr' => 'Khmer',
  'Palm' => 'Palmyrene',
  'Hebr' => 'Hebrew',
  'Olck' => "Ol Chiki (Ol Cemet\x{2019}, Ol, Santali)",
  'Rohg' => 'Hanifi Rohingya',
  'Dupl' => 'Duployan shorthand, Duployan stenography',
  'Lyci' => 'Lycian',
  'Phnx' => 'Phoenician',
  'Tang' => 'Tangut',
  'Xpeo' => 'Old Persian',
  'Roro' => 'Rongorongo',
  'Merc' => 'Meroitic Cursive',
  'Latg' => 'Latin (Gaelic variant)',
  'Gong' => 'Gunjala Gondi',
  'Sogo' => 'Old Sogdian',
  'Tavt' => 'Tai Viet',
  'Afak' => 'Afaka',
  'Sora' => 'Sora Sompeng',
  'Sylo' => 'Syloti Nagri',
  'Cham' => 'Cham',
  'Phlv' => 'Book Pahlavi',
  'Gujr' => 'Gujarati',
  'Saur' => 'Saurashtra',
  'Vaii' => 'Vai',
  'Bali' => 'Balinese',
  'Tirh' => 'Tirhuta'
};
$ScriptCode2FrenchName = {
  'Zsym' => 'symboles',
  'Zinh' => "codet pour \x{e9}criture h\x{e9}rit\x{e9}e",
  'Soyo' => 'soyombo',
  'Takr' => "t\x{e2}kr\x{ee}",
  'Hanb' => 'han avec bopomofo (alias pour han + bopomofo)',
  'Tagb' => 'tagbanoua',
  'Armi' => "aram\x{e9}en imp\x{e9}rial",
  'Mtei' => 'meitei mayek',
  'Orya' => "oriy\x{e2} (odia)",
  'Talu' => "nouveau ta\x{ef}-lue",
  'Shaw' => 'shavien (Shaw)',
  'Mend' => "mend\x{e9} kikakui",
  'Loma' => 'loma',
  'Perm' => 'ancien permien',
  'Khar' => "kharochth\x{ee}",
  'Kana' => 'katakana',
  'Lydi' => 'lydien',
  'Phlp' => 'pehlevi des psautiers',
  'Wara' => 'warang citi',
  'Sund' => 'sundanais',
  'Tfng' => "tifinagh (berb\x{e8}re)",
  'Zzzz' => "codet pour \x{e9}criture non cod\x{e9}e",
  'Cyrl' => 'cyrillique',
  'Toto' => 'toto',
  'Java' => 'javanais',
  'Bass' => 'bassa',
  'Zanb' => 'zanabazar quadratique',
  'Hmnp' => 'nyiakeng puachue hmong',
  'Rjng' => 'redjang (kaganga)',
  'Lana' => "ta\x{ef} tham (lanna)",
  'Cprt' => 'syllabaire chypriote',
  'Sara' => 'sarati',
  'Hira' => 'hiragana',
  'Wole' => "wol\x{e9}a\x{ef}",
  'Glag' => 'glagolitique',
  'Jpan' => 'japonais (alias pour han + hiragana + katakana)',
  'Nkdb' => 'naxi dongba',
  'Tibt' => "tib\x{e9}tain",
  'Hluw' => "hi\x{e9}roglyphes anatoliens (hi\x{e9}roglyphes louvites, hi\x{e9}roglyphes hittites)",
  'Zxxx' => "codet pour les documents non \x{e9}crits",
  'Chrs' => 'chorasmien',
  'Hano' => "hanoun\x{f3}o",
  'Mahj' => "mah\x{e2}jan\x{ee}",
  'Mroo' => 'mro',
  'Jamo' => "jamo (alias pour le sous-ensemble jamo du hang\x{fb}l)",
  'Kitl' => "grande \x{e9}criture khitan",
  'Zmth' => "notation math\x{e9}matique",
  'Gran' => 'grantha',
  'Hani' => "id\x{e9}ogrammes han (sinogrammes)",
  'Maka' => 'makassar',
  'Knda' => 'kannara (canara)',
  'Shrd' => 'charada, shard',
  'Ethi' => "\x{e9}thiopien (ge\x{2bb}ez, gu\x{e8}ze)",
  'Armn' => "arm\x{e9}nien",
  'Dsrt' => "d\x{e9}seret (mormon)",
  'Beng' => "bengal\x{ee} (bangla)",
  'Orkh' => 'orkhon',
  'Prti' => 'parthe des inscriptions',
  'Cans' => "syllabaire autochtone canadien unifi\x{e9}",
  'Geor' => "g\x{e9}orgien (mkh\x{e9}drouli et mtavrouli)",
  'Cirt' => 'cirth',
  'Hung' => 'runes hongroises (ancien hongrois)',
  'Kali' => 'kayah li',
  'Grek' => 'grec',
  'Hant' => "id\x{e9}ogrammes han (variante traditionnelle)",
  'Newa' => "n\x{e9}wa, n\x{e9}war, n\x{e9}wari, nep\x{101}la lipi",
  'Diak' => 'dives akuru',
  'Mult' => "multan\x{ee}",
  'Avst' => 'avestique',
  'Bopo' => 'bopomofo',
  'Linb' => "lin\x{e9}aire B",
  'Blis' => 'symboles Bliss',
  'Lepc' => "lepcha (r\x{f3}ng)",
  'Guru' => "gourmoukh\x{ee}",
  'Maya' => "hi\x{e9}roglyphes mayas",
  'Laoo' => 'laotien',
  'Tglg' => 'tagal (baybayin, alibata)',
  'Sgnw' => "Sign\x{c9}criture, SignWriting",
  'Mand' => "mand\x{e9}en",
  'Brai' => 'braille',
  'Thaa' => "th\x{e2}na",
  'Leke' => "l\x{e9}k\x{e9}",
  'Goth' => 'gotique',
  'Sogd' => 'sogdien',
  'Hrkt' => 'syllabaires japonais (alias pour hiragana + katakana)',
  'Inds' => 'indus',
  'Hang' => "hang\x{fb}l (hang\x{16d}l, hangeul)",
  'Ahom' => "\x{e2}hom",
  'Elym' => "\x{e9}lyma\x{ef}que",
  'Nand' => "nandin\x{e2}gar\x{ee}",
  'Yezi' => "y\x{e9}zidi",
  'Syrn' => 'syriaque (variante orientale)',
  'Geok' => 'khoutsouri (assomtavrouli et nouskhouri)',
  'Mymr' => 'birman',
  'Telu' => "t\x{e9}lougou",
  'Modi' => "mod\x{ee}",
  'Taml' => 'tamoul',
  'Mong' => 'mongol',
  'Shui' => 'shuishu',
  'Syrc' => 'syriaque',
  'Phag' => "\x{2019}phags pa",
  'Roro' => 'rongorongo',
  'Latg' => "latin (variante ga\x{e9}lique)",
  'Merc' => "cursif m\x{e9}ro\x{ef}tique",
  'Hebr' => "h\x{e9}breu",
  'Olck' => 'ol tchiki',
  'Rohg' => 'hanifi rohingya',
  'Dupl' => "st\x{e9}nographie Duploy\x{e9}",
  'Lyci' => 'lycien',
  'Xpeo' => "cun\x{e9}iforme pers\x{e9}politain",
  'Phnx' => "ph\x{e9}nicien",
  'Tang' => 'tangoute',
  'Cham' => "cham (\x{10d}am, tcham)",
  'Phlv' => 'pehlevi des livres',
  'Gujr' => "goudjar\x{e2}t\x{ee} (gujr\x{e2}t\x{ee})",
  'Vaii' => "va\x{ef}",
  'Saur' => 'saurachtra',
  'Bali' => 'balinais',
  'Tirh' => 'tirhouta',
  'Sora' => 'sora sompeng',
  'Gong' => "gunjala gond\x{ee}",
  'Tavt' => "ta\x{ef} vi\x{ea}t",
  'Afak' => 'afaka',
  'Sogo' => 'ancien sogdien',
  'Sylo' => "sylot\x{ee} n\x{e2}gr\x{ee}",
  'Egyp' => "hi\x{e9}roglyphes \x{e9}gyptiens",
  'Nshu' => "n\x{fc}shu",
  'Sarb' => 'sud-arabique, himyarite',
  'Adlm' => 'adlam',
  'Cari' => 'carien',
  'Kore' => "cor\x{e9}en (alias pour hang\x{fb}l + han)",
  'Thai' => "tha\x{ef}",
  'Cpmn' => 'syllabaire chypro-minoen',
  'Piqd' => 'klingon (pIqaD du KLI)',
  'Batk' => 'batik',
  'Syre' => "syriaque (variante estrangh\x{e9}lo)",
  'Qabx' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (fin)",
  'Plrd' => 'miao (Pollard)',
  'Bamu' => 'bamoum',
  'Tale' => "ta\x{ef}-le",
  'Buhd' => 'bouhide',
  'Mero' => "hi\x{e9}roglyphes m\x{e9}ro\x{ef}tiques",
  'Palm' => "palmyr\x{e9}nien",
  'Khmr' => 'khmer',
  'Ugar' => 'ougaritique',
  'Lisu' => 'lisu (Fraser)',
  'Wcho' => 'wantcho',
  'Medf' => "m\x{e9}d\x{e9}fa\x{ef}drine",
  'Sind' => "khoudawad\x{ee}, sindh\x{ee}",
  'Hatr' => "hatr\x{e9}nien",
  'Qaaa' => "r\x{e9}serv\x{e9} \x{e0} l\x{2019}usage priv\x{e9} (d\x{e9}but)",
  'Ogam' => 'ogam',
  'Egyd' => "d\x{e9}motique \x{e9}gyptien",
  'Elba' => 'elbasan',
  'Kthi' => "kaith\x{ee}",
  'Yiii' => 'yi',
  'Cyrs' => 'cyrillique (variante slavonne)',
  'Mlym' => "malay\x{e2}lam",
  'Limb' => 'limbou',
  'Latf' => "latin (variante bris\x{e9}e)",
  'Bugi' => 'bouguis',
  'Lina' => "lin\x{e9}aire A",
  'Copt' => 'copte',
  'Egyh' => "hi\x{e9}ratique \x{e9}gyptien",
  'Kits' => "petite \x{e9}criture khitan",
  'Khoj' => "khojk\x{ee}",
  'Gonm' => "masaram gond\x{ee}",
  'Nkoo' => "n\x{2019}ko",
  'Sinh' => 'singhalais',
  'Visp' => 'parole visible',
  'Osma' => 'osmanais',
  'Deva' => "d\x{e9}van\x{e2}gar\x{ee}",
  'Latn' => 'latin',
  'Mani' => "manich\x{e9}en",
  'Osge' => 'osage',
  'Bhks' => "bha\x{ef}ksuk\x{ee}",
  'Nbat' => "nabat\x{e9}en",
  'Ital' => "ancien italique (\x{e9}trusque, osque, etc.)",
  'Aran' => 'arabe (variante nastalique)',
  'Moon' => "\x{e9}criture Moon",
  'Arab' => 'arabe',
  'Cher' => "tch\x{e9}rok\x{ee}",
  'Syrj' => 'syriaque (variante occidentale)',
  'Narb' => 'nord-arabique',
  'Kpel' => "kp\x{e8}ll\x{e9}",
  'Hmng' => 'pahawh hmong',
  'Dogr' => 'dogra',
  'Sidd' => 'siddham',
  'Marc' => 'marchen',
  'Zsye' => "symboles (variante \x{e9}moji)",
  'Zyyy' => "codet pour \x{e9}criture ind\x{e9}termin\x{e9}e",
  'Xsux' => "cun\x{e9}iforme sum\x{e9}ro-akkadien",
  'Cakm' => 'chakma',
  'Samr' => 'samaritain',
  'Runr' => 'runique',
  'Pauc' => 'paou chin haou',
  'Jurc' => 'jurchen',
  'Nkgb' => 'naxi geba, nakhi geba',
  'Teng' => 'tengwar',
  'Aghb' => 'aghbanien',
  'Hans' => "id\x{e9}ogrammes han (variante simplifi\x{e9}e)",
  'Brah' => 'brahma',
  'Phli' => 'pehlevi des inscriptions'
};
$ScriptCodeVersion = {
  'Cher' => '3.0',
  'Kpel' => '',
  'Syrj' => '3.0',
  'Narb' => '7.0',
  'Hmng' => '7.0',
  'Sidd' => '7.0',
  'Dogr' => '11.0',
  'Osge' => '9.0',
  'Bhks' => '9.0',
  'Mani' => '7.0',
  'Latn' => '1.1',
  'Deva' => '1.1',
  'Nbat' => '7.0',
  'Aran' => '1.1',
  'Moon' => '',
  'Arab' => '1.1',
  'Ital' => '3.1',
  'Pauc' => '7.0',
  'Nkgb' => '',
  'Teng' => '',
  'Jurc' => '',
  'Aghb' => '7.0',
  'Phli' => '5.2',
  'Brah' => '6.0',
  'Hans' => '1.1',
  'Marc' => '9.0',
  'Zyyy' => '',
  'Zsye' => '6.0',
  'Xsux' => '5.0',
  'Runr' => '3.0',
  'Cakm' => '6.1',
  'Samr' => '5.2',
  'Ogam' => '3.0',
  'Qaaa' => '',
  'Kthi' => '5.2',
  'Elba' => '7.0',
  'Egyd' => '',
  'Cyrs' => '1.1',
  'Yiii' => '3.0',
  'Wcho' => '12.0',
  'Sind' => '7.0',
  'Medf' => '11.0',
  'Hatr' => '8.0',
  'Sinh' => '3.0',
  'Nkoo' => '5.0',
  'Visp' => '',
  'Osma' => '4.0',
  'Latf' => '1.1',
  'Limb' => '4.0',
  'Mlym' => '1.1',
  'Egyh' => '5.2',
  'Kits' => '13.0',
  'Bugi' => '4.1',
  'Copt' => '4.1',
  'Lina' => '7.0',
  'Khoj' => '7.0',
  'Gonm' => '10.0',
  'Cpmn' => '',
  'Batk' => '6.0',
  'Piqd' => '',
  'Qabx' => '',
  'Syre' => '3.0',
  'Plrd' => '6.1',
  'Nshu' => '10.0',
  'Egyp' => '5.2',
  'Kore' => '1.1',
  'Thai' => '1.1',
  'Sarb' => '5.2',
  'Adlm' => '9.0',
  'Cari' => '5.1',
  'Ugar' => '4.0',
  'Lisu' => '5.2',
  'Bamu' => '5.2',
  'Buhd' => '3.2',
  'Tale' => '4.0',
  'Mero' => '6.1',
  'Khmr' => '3.0',
  'Palm' => '7.0',
  'Hebr' => '1.1',
  'Olck' => '5.1',
  'Rohg' => '11.0',
  'Lyci' => '5.1',
  'Dupl' => '7.0',
  'Phnx' => '5.0',
  'Tang' => '9.0',
  'Xpeo' => '4.1',
  'Roro' => '',
  'Merc' => '6.1',
  'Latg' => '1.1',
  'Gong' => '11.0',
  'Tavt' => '5.2',
  'Afak' => '',
  'Sogo' => '11.0',
  'Sora' => '6.1',
  'Sylo' => '4.1',
  'Cham' => '5.1',
  'Phlv' => '',
  'Gujr' => '1.1',
  'Saur' => '5.1',
  'Vaii' => '5.1',
  'Bali' => '5.0',
  'Tirh' => '7.0',
  'Leke' => '',
  'Goth' => '3.1',
  'Sogd' => '11.0',
  'Hrkt' => '1.1',
  'Inds' => '',
  'Hang' => '1.1',
  'Elym' => '12.0',
  'Ahom' => '8.0',
  'Tglg' => '3.2',
  'Laoo' => '1.1',
  'Sgnw' => '8.0',
  'Mand' => '6.0',
  'Brai' => '3.0',
  'Thaa' => '3.0',
  'Mymr' => '3.0',
  'Telu' => '1.1',
  'Modi' => '7.0',
  'Taml' => '1.1',
  'Syrc' => '3.0',
  'Phag' => '5.0',
  'Shui' => '',
  'Mong' => '3.0',
  'Nand' => '12.0',
  'Syrn' => '3.0',
  'Yezi' => '13.0',
  'Geok' => '1.1',
  'Beng' => '1.1',
  'Prti' => '5.2',
  'Orkh' => '5.2',
  'Cans' => '3.0',
  'Hung' => '8.0',
  'Cirt' => '',
  'Geor' => '1.1',
  'Maka' => '11.0',
  'Hani' => '1.1',
  'Knda' => '1.1',
  'Shrd' => '6.1',
  'Dsrt' => '3.1',
  'Ethi' => '3.0',
  'Armn' => '1.1',
  'Linb' => '4.0',
  'Lepc' => '5.1',
  'Blis' => '',
  'Guru' => '1.1',
  'Maya' => '',
  'Grek' => '1.1',
  'Hant' => '1.1',
  'Newa' => '9.0',
  'Kali' => '5.1',
  'Mult' => '8.0',
  'Diak' => '13.0',
  'Bopo' => '1.1',
  'Avst' => '5.2',
  'Bass' => '7.0',
  'Zanb' => '10.0',
  'Lana' => '5.2',
  'Hmnp' => '12.0',
  'Rjng' => '5.1',
  'Sara' => '',
  'Hira' => '1.1',
  'Cprt' => '4.0',
  'Glag' => '4.1',
  'Wole' => '',
  'Zzzz' => '',
  'Toto' => '',
  'Cyrl' => '1.1',
  'Java' => '5.2',
  'Kitl' => '',
  'Zmth' => '3.2',
  'Gran' => '7.0',
  'Jpan' => '1.1',
  'Nkdb' => '',
  'Zxxx' => '',
  'Tibt' => '2.0',
  'Hluw' => '8.0',
  'Mahj' => '7.0',
  'Chrs' => '13.0',
  'Hano' => '3.2',
  'Jamo' => '1.1',
  'Mroo' => '7.0',
  'Tagb' => '3.2',
  'Hanb' => '1.1',
  'Orya' => '1.1',
  'Armi' => '5.2',
  'Mtei' => '5.2',
  'Shaw' => '4.0',
  'Talu' => '4.1',
  'Soyo' => '10.0',
  'Zsym' => '1.1',
  'Zinh' => '',
  'Takr' => '6.1',
  'Wara' => '7.0',
  'Sund' => '5.1',
  'Tfng' => '4.1',
  'Mend' => '7.0',
  'Perm' => '7.0',
  'Loma' => '',
  'Kana' => '1.1',
  'Khar' => '4.1',
  'Phlp' => '7.0',
  'Lydi' => '5.1'
};
$ScriptCodeDate = {
  'Beng' => '2016-12-05
',
  'Orkh' => '2009-06-01
',
  'Prti' => '2009-06-01
',
  'Cans' => '2004-05-29
',
  'Geor' => '2016-12-05
',
  'Cirt' => '2004-05-01
',
  'Hung' => '2015-07-07
',
  'Hani' => '2009-02-23
',
  'Maka' => '2016-12-05
',
  'Knda' => '2004-05-29
',
  'Shrd' => '2012-02-06
',
  'Ethi' => '2004-10-25
',
  'Armn' => '2004-05-01
',
  'Dsrt' => '2004-05-01
',
  'Linb' => '2004-05-29
',
  'Blis' => '2004-05-01
',
  'Lepc' => '2007-07-02
',
  'Guru' => '2004-05-01
',
  'Maya' => '2004-05-01
',
  'Kali' => '2007-07-02
',
  'Newa' => '2016-12-05
',
  'Hant' => '2004-05-29
',
  'Grek' => '2004-05-01
',
  'Diak' => '2019-08-19
',
  'Mult' => '2015-07-07
',
  'Avst' => '2009-06-01
',
  'Bopo' => '2004-05-01
',
  'Goth' => '2004-05-01
',
  'Leke' => '2015-07-07
',
  'Hrkt' => '2011-06-21
',
  'Sogd' => '2017-11-21
',
  'Ahom' => '2015-07-07
',
  'Elym' => '2018-08-26
',
  'Hang' => '2004-05-29
',
  'Inds' => '2004-05-01
',
  'Laoo' => '2004-05-01
',
  'Tglg' => '2009-02-23
',
  'Sgnw' => '2015-07-07
',
  'Brai' => '2004-05-01
',
  'Mand' => '2010-07-23
',
  'Thaa' => '2004-05-01
',
  'Mymr' => '2004-05-01
',
  'Modi' => '2014-11-15
',
  'Telu' => '2004-05-01
',
  'Taml' => '2004-05-01
',
  'Shui' => '2017-07-26
',
  'Mong' => '2004-05-01
',
  'Syrc' => '2004-05-01
',
  'Phag' => '2006-10-10
',
  'Yezi' => '2019-08-19
',
  'Syrn' => '2004-05-01
',
  'Nand' => '2018-08-26
',
  'Geok' => '2012-10-16
',
  'Hanb' => '2016-01-19
',
  'Tagb' => '2004-05-01
',
  'Mtei' => '2009-06-01
',
  'Armi' => '2009-06-01
',
  'Orya' => '2016-12-05
',
  'Talu' => '2006-06-21
',
  'Shaw' => '2004-05-01
',
  'Zinh' => '2009-02-23
',
  'Zsym' => '2007-11-26
',
  'Soyo' => '2017-07-26
',
  'Takr' => '2012-02-06
',
  'Wara' => '2014-11-15
',
  'Sund' => '2007-07-02
',
  'Tfng' => '2006-06-21
',
  'Mend' => '2014-11-15
',
  'Loma' => '2010-03-26
',
  'Perm' => '2014-11-15
',
  'Khar' => '2006-06-21
',
  'Kana' => '2004-05-01
',
  'Lydi' => '2007-07-02
',
  'Phlp' => '2014-11-15
',
  'Zanb' => '2017-07-26
',
  'Bass' => '2014-11-15
',
  'Rjng' => '2009-02-23
',
  'Hmnp' => '2017-07-26
',
  'Lana' => '2009-06-01
',
  'Cprt' => '2017-07-26
',
  'Hira' => '2004-05-01
',
  'Sara' => '2004-05-29
',
  'Wole' => '2010-12-21
',
  'Glag' => '2006-06-21
',
  'Zzzz' => '2006-10-10
',
  'Cyrl' => '2004-05-01
',
  'Toto' => '2020-04-16
',
  'Java' => '2009-06-01
',
  'Kitl' => '2015-07-15
',
  'Zmth' => '2007-11-26
',
  'Gran' => '2014-11-15
',
  'Nkdb' => '2017-07-26
',
  'Jpan' => '2006-06-21
',
  'Hluw' => '2015-07-07
',
  'Tibt' => '2004-05-01
',
  'Zxxx' => '2011-06-21
',
  'Hano' => '2004-05-29
',
  'Chrs' => '2019-08-19
',
  'Mahj' => '2014-11-15
',
  'Mroo' => '2016-12-05
',
  'Jamo' => '2016-01-19
',
  'Qaaa' => '2004-05-29
',
  'Ogam' => '2004-05-01
',
  'Egyd' => '2004-05-01
',
  'Elba' => '2014-11-15
',
  'Kthi' => '2009-06-01
',
  'Yiii' => '2004-05-01
',
  'Cyrs' => '2004-05-01
',
  'Wcho' => '2017-07-26
',
  'Sind' => '2014-11-15
',
  'Medf' => '2016-12-05
',
  'Hatr' => '2015-07-07
',
  'Nkoo' => '2006-10-10
',
  'Sinh' => '2004-05-01
',
  'Osma' => '2004-05-01
',
  'Visp' => '2004-05-01
',
  'Mlym' => '2004-05-01
',
  'Latf' => '2004-05-01
',
  'Limb' => '2004-05-29
',
  'Copt' => '2006-06-21
',
  'Lina' => '2014-11-15
',
  'Bugi' => '2006-06-21
',
  'Kits' => '2015-07-15
',
  'Egyh' => '2004-05-01
',
  'Gonm' => '2017-07-26
',
  'Khoj' => '2014-11-15
',
  'Cher' => '2004-05-01
',
  'Narb' => '2014-11-15
',
  'Syrj' => '2004-05-01
',
  'Kpel' => '2010-03-26
',
  'Hmng' => '2014-11-15
',
  'Dogr' => '2016-12-05
',
  'Sidd' => '2014-11-15
',
  'Deva' => '2004-05-01
',
  'Mani' => '2014-11-15
',
  'Latn' => '2004-05-01
',
  'Bhks' => '2016-12-05
',
  'Osge' => '2016-12-05
',
  'Nbat' => '2014-11-15
',
  'Ital' => '2004-05-29
',
  'Arab' => '2004-05-01
',
  'Moon' => '2006-12-11
',
  'Aran' => '2014-11-15
',
  'Pauc' => '2014-11-15
',
  'Jurc' => '2010-12-21
',
  'Teng' => '2004-05-01
',
  'Nkgb' => '2017-07-26
',
  'Aghb' => '2014-11-15
',
  'Hans' => '2004-05-29
',
  'Phli' => '2009-06-01
',
  'Brah' => '2010-07-23
',
  'Marc' => '2016-12-05
',
  'Zsye' => '2015-12-16
',
  'Zyyy' => '2004-05-29
',
  'Xsux' => '2006-10-10
',
  'Samr' => '2009-06-01
',
  'Cakm' => '2012-02-06
',
  'Runr' => '2004-05-01
',
  'Hebr' => '2004-05-01
',
  'Rohg' => '2017-11-21
',
  'Olck' => '2007-07-02
',
  'Dupl' => '2014-11-15
',
  'Lyci' => '2007-07-02
',
  'Xpeo' => '2006-06-21
',
  'Tang' => '2016-12-05
',
  'Phnx' => '2006-10-10
',
  'Roro' => '2004-05-01
',
  'Merc' => '2012-02-06
',
  'Latg' => '2004-05-01
',
  'Sora' => '2012-02-06
',
  'Afak' => '2010-12-21
',
  'Tavt' => '2009-06-01
',
  'Sogo' => '2017-11-21
',
  'Gong' => '2016-12-05
',
  'Sylo' => '2006-06-21
',
  'Cham' => '2009-11-11
',
  'Gujr' => '2004-05-01
',
  'Phlv' => '2007-07-15
',
  'Vaii' => '2007-07-02
',
  'Saur' => '2007-07-02
',
  'Tirh' => '2014-11-15
',
  'Bali' => '2006-10-10
',
  'Cpmn' => '2017-07-26
',
  'Batk' => '2010-07-23
',
  'Piqd' => '2015-12-16
',
  'Syre' => '2004-05-01
',
  'Qabx' => '2004-05-29
',
  'Plrd' => '2012-02-06
',
  'Egyp' => '2009-06-01
',
  'Nshu' => '2017-07-26
',
  'Sarb' => '2009-06-01
',
  'Adlm' => '2016-12-05
',
  'Cari' => '2007-07-02
',
  'Thai' => '2004-05-01
',
  'Kore' => '2007-06-13
',
  'Ugar' => '2004-05-01
',
  'Lisu' => '2009-06-01
',
  'Bamu' => '2009-06-01
',
  'Tale' => '2004-10-25
',
  'Buhd' => '2004-05-01
',
  'Mero' => '2012-02-06
',
  'Palm' => '2014-11-15
',
  'Khmr' => '2004-05-29
'
};
$ScriptCodeId = {
  'Toto' => '294',
  'Cyrl' => '220',
  'Java' => '361',
  'Zzzz' => '999',
  'Sara' => '292',
  'Hira' => '410',
  'Cprt' => '403',
  'Glag' => '225',
  'Wole' => '480',
  'Bass' => '259',
  'Zanb' => '339',
  'Lana' => '351',
  'Hmnp' => '451',
  'Rjng' => '363',
  'Mahj' => '314',
  'Chrs' => '109',
  'Hano' => '371',
  'Jamo' => '284',
  'Mroo' => '264',
  'Jpan' => '413',
  'Nkdb' => '085',
  'Zxxx' => '997',
  'Tibt' => '330',
  'Hluw' => '080',
  'Gran' => '343',
  'Kitl' => '505',
  'Zmth' => '995',
  'Takr' => '321',
  'Soyo' => '329',
  'Zsym' => '996',
  'Zinh' => '994',
  'Orya' => '327',
  'Armi' => '124',
  'Mtei' => '337',
  'Shaw' => '281',
  'Talu' => '354',
  'Tagb' => '373',
  'Hanb' => '503',
  'Kana' => '411',
  'Khar' => '305',
  'Phlp' => '132',
  'Lydi' => '116',
  'Mend' => '438',
  'Perm' => '227',
  'Loma' => '437',
  'Sund' => '362',
  'Tfng' => '120',
  'Wara' => '262',
  'Mand' => '140',
  'Brai' => '570',
  'Thaa' => '170',
  'Tglg' => '370',
  'Laoo' => '356',
  'Sgnw' => '095',
  'Sogd' => '141',
  'Hrkt' => '412',
  'Inds' => '610',
  'Elym' => '128',
  'Ahom' => '338',
  'Hang' => '286',
  'Leke' => '364',
  'Goth' => '206',
  'Geok' => '241',
  'Nand' => '311',
  'Syrn' => '136',
  'Yezi' => '192',
  'Taml' => '346',
  'Syrc' => '135',
  'Phag' => '331',
  'Mong' => '145',
  'Shui' => '530',
  'Mymr' => '350',
  'Telu' => '340',
  'Modi' => '324',
  'Shrd' => '319',
  'Dsrt' => '250',
  'Armn' => '230',
  'Ethi' => '430',
  'Maka' => '366',
  'Hani' => '500',
  'Knda' => '345',
  'Cans' => '440',
  'Hung' => '176',
  'Cirt' => '291',
  'Geor' => '240',
  'Beng' => '325',
  'Prti' => '130',
  'Orkh' => '175',
  'Mult' => '323',
  'Diak' => '342',
  'Bopo' => '285',
  'Avst' => '134',
  'Hant' => '502',
  'Grek' => '200',
  'Newa' => '333',
  'Kali' => '357',
  'Guru' => '310',
  'Maya' => '090',
  'Linb' => '401',
  'Blis' => '550',
  'Lepc' => '335',
  'Kore' => '287',
  'Thai' => '352',
  'Cari' => '201',
  'Adlm' => '166',
  'Sarb' => '105',
  'Nshu' => '499',
  'Egyp' => '050',
  'Syre' => '138',
  'Piqd' => '293',
  'Batk' => '365',
  'Qabx' => '949',
  'Plrd' => '282',
  'Cpmn' => '402',
  'Mero' => '100',
  'Khmr' => '355',
  'Palm' => '126',
  'Bamu' => '435',
  'Buhd' => '372',
  'Tale' => '353',
  'Lisu' => '399',
  'Ugar' => '040',
  'Latg' => '216',
  'Merc' => '101',
  'Roro' => '620',
  'Lyci' => '202',
  'Dupl' => '755',
  'Phnx' => '115',
  'Tang' => '520',
  'Xpeo' => '030',
  'Hebr' => '125',
  'Olck' => '261',
  'Rohg' => '167',
  'Saur' => '344',
  'Vaii' => '470',
  'Bali' => '360',
  'Tirh' => '326',
  'Cham' => '358',
  'Phlv' => '133',
  'Gujr' => '320',
  'Gong' => '312',
  'Tavt' => '359',
  'Afak' => '439',
  'Sogo' => '142',
  'Sora' => '398',
  'Sylo' => '316',
  'Moon' => '218',
  'Aran' => '161',
  'Arab' => '160',
  'Ital' => '210',
  'Osge' => '219',
  'Bhks' => '334',
  'Latn' => '215',
  'Deva' => '315',
  'Mani' => '139',
  'Nbat' => '159',
  'Hmng' => '450',
  'Sidd' => '302',
  'Dogr' => '328',
  'Cher' => '445',
  'Kpel' => '436',
  'Syrj' => '137',
  'Narb' => '106',
  'Xsux' => '020',
  'Runr' => '211',
  'Cakm' => '349',
  'Samr' => '123',
  'Marc' => '332',
  'Zsye' => '993',
  'Zyyy' => '998',
  'Aghb' => '239',
  'Brah' => '300',
  'Phli' => '131',
  'Hans' => '501',
  'Pauc' => '263',
  'Nkgb' => '420',
  'Teng' => '290',
  'Jurc' => '510',
  'Sind' => '318',
  'Medf' => '265',
  'Hatr' => '127',
  'Wcho' => '283',
  'Kthi' => '317',
  'Elba' => '226',
  'Egyd' => '070',
  'Cyrs' => '221',
  'Yiii' => '460',
  'Ogam' => '212',
  'Qaaa' => '900',
  'Khoj' => '322',
  'Gonm' => '313',
  'Latf' => '217',
  'Limb' => '336',
  'Mlym' => '347',
  'Egyh' => '060',
  'Kits' => '288',
  'Bugi' => '367',
  'Lina' => '400',
  'Copt' => '204',
  'Visp' => '280',
  'Osma' => '260',
  'Sinh' => '348',
  'Nkoo' => '165'
};
$Lang2Territory = {
  'srd' => {
    'IT' => 2
  },
  'fuq' => {
    'NE' => 2
  },
  'ban' => {
    'ID' => 2
  },
  'noe' => {
    'IN' => 2
  },
  'seh' => {
    'MZ' => 2
  },
  'ful' => {
    'NE' => 2,
    'SN' => 2,
    'NG' => 2,
    'GN' => 2,
    'ML' => 2
  },
  'lmn' => {
    'IN' => 2
  },
  'smo' => {
    'WS' => 1,
    'AS' => 1
  },
  'rus' => {
    'LT' => 2,
    'KG' => 1,
    'KZ' => 1,
    'PL' => 2,
    'SJ' => 2,
    'BY' => 1,
    'BG' => 2,
    'UZ' => 2,
    'DE' => 2,
    'UA' => 1,
    'LV' => 2,
    'EE' => 2,
    'RU' => 1,
    'TJ' => 2
  },
  'hau' => {
    'NE' => 2,
    'NG' => 2
  },
  'shr' => {
    'MA' => 2
  },
  'doi' => {
    'IN' => 2
  },
  'wol' => {
    'SN' => 1
  },
  'bjn' => {
    'ID' => 2
  },
  'kok' => {
    'IN' => 2
  },
  'fon' => {
    'BJ' => 2
  },
  'tam' => {
    'MY' => 2,
    'SG' => 1,
    'IN' => 2,
    'LK' => 1
  },
  'lez' => {
    'RU' => 2
  },
  'mey' => {
    'SN' => 2
  },
  'udm' => {
    'RU' => 2
  },
  'mah' => {
    'MH' => 1
  },
  'aeb' => {
    'TN' => 2
  },
  'ssw' => {
    'ZA' => 2,
    'SZ' => 1
  },
  'ori' => {
    'IN' => 2
  },
  'ron' => {
    'RO' => 1,
    'MD' => 1,
    'RS' => 2
  },
  'ljp' => {
    'ID' => 2
  },
  'gla' => {
    'GB' => 2
  },
  'snd' => {
    'PK' => 2,
    'IN' => 2
  },
  'hoj' => {
    'IN' => 2
  },
  'jav' => {
    'ID' => 2
  },
  'ikt' => {
    'CA' => 2
  },
  'ava' => {
    'RU' => 2
  },
  'kor' => {
    'US' => 2,
    'KP' => 1,
    'KR' => 1,
    'CN' => 2
  },
  'vmf' => {
    'DE' => 2
  },
  'kkt' => {
    'RU' => 2
  },
  'mos' => {
    'BF' => 2
  },
  'sck' => {
    'IN' => 2
  },
  'ton' => {
    'TO' => 1
  },
  'srn' => {
    'SR' => 2
  },
  'nde' => {
    'ZW' => 1
  },
  'kfy' => {
    'IN' => 2
  },
  'kaz' => {
    'KZ' => 1,
    'CN' => 2
  },
  'snf' => {
    'SN' => 2
  },
  'lit' => {
    'LT' => 1,
    'PL' => 2
  },
  'yor' => {
    'NG' => 1
  },
  'suk' => {
    'TZ' => 2
  },
  'tir' => {
    'ET' => 2,
    'ER' => 1
  },
  'kin' => {
    'RW' => 1
  },
  'pcm' => {
    'NG' => 2
  },
  'crs' => {
    'SC' => 2
  },
  'kri' => {
    'SL' => 2
  },
  'kal' => {
    'DK' => 2,
    'GL' => 1
  },
  'kas' => {
    'IN' => 2
  },
  'aar' => {
    'ET' => 2,
    'DJ' => 2
  },
  'luz' => {
    'IR' => 2
  },
  'mar' => {
    'IN' => 2
  },
  'bhk' => {
    'PH' => 2
  },
  'guj' => {
    'IN' => 2
  },
  'eng' => {
    'PT' => 2,
    'SK' => 2,
    'SB' => 1,
    'SD' => 1,
    'WS' => 1,
    'DG' => 1,
    'SC' => 1,
    'NU' => 1,
    'JE' => 1,
    'NF' => 1,
    'JO' => 2,
    'MH' => 1,
    'CA' => 1,
    'BR' => 2,
    'ET' => 2,
    'AT' => 2,
    'NG' => 1,
    'NA' => 1,
    'FR' => 2,
    'MU' => 1,
    'EE' => 2,
    'AE' => 2,
    'LV' => 2,
    'JM' => 1,
    'ZA' => 1,
    'BW' => 1,
    'KE' => 1,
    'GR' => 2,
    'MA' => 2,
    'TC' => 1,
    'CH' => 2,
    'MG' => 1,
    'LU' => 2,
    'TK' => 1,
    'RW' => 1,
    'BS' => 1,
    'PL' => 2,
    'KZ' => 2,
    'KY' => 1,
    'AG' => 1,
    'VI' => 1,
    'DM' => 1,
    'YE' => 2,
    'EG' => 2,
    'BB' => 1,
    'CX' => 1,
    'AU' => 1,
    'BD' => 2,
    'MY' => 2,
    'FJ' => 1,
    'PG' => 1,
    'CM' => 1,
    'VG' => 1,
    'DZ' => 2,
    'HU' => 2,
    'US' => 1,
    'AI' => 1,
    'IQ' => 2,
    'FK' => 1,
    'DE' => 2,
    'MT' => 1,
    'SS' => 1,
    'MP' => 1,
    'IN' => 1,
    'GB' => 1,
    'CL' => 2,
    'GD' => 1,
    'CY' => 2,
    'TR' => 2,
    'MX' => 2,
    'CZ' => 2,
    'VU' => 1,
    'NZ' => 1,
    'KI' => 1,
    'NL' => 2,
    'PH' => 1,
    'LT' => 2,
    'ZM' => 1,
    'DK' => 2,
    'AR' => 2,
    'SG' => 1,
    'UG' => 1,
    'IO' => 1,
    'ER' => 1,
    'CK' => 1,
    'CC' => 1,
    'TH' => 2,
    'GY' => 1,
    'IE' => 1,
    'IL' => 2,
    'PR' => 1,
    'BM' => 1,
    'LC' => 1,
    'ES' => 2,
    'SI' => 2,
    'SH' => 1,
    'LK' => 2,
    'LB' => 2,
    'IT' => 2,
    'RO' => 2,
    'FM' => 1,
    'AS' => 1,
    'BZ' => 1,
    'IM' => 1,
    'TA' => 2,
    'HR' => 2,
    'PW' => 1,
    'TV' => 1,
    'GM' => 1,
    'BE' => 2,
    'TO' => 1,
    'AC' => 2,
    'SX' => 1,
    'FI' => 2,
    'UM' => 1,
    'KN' => 1,
    'LS' => 1,
    'PN' => 1,
    'TZ' => 1,
    'BG' => 2,
    'BA' => 2,
    'ZW' => 1,
    'GI' => 1,
    'GH' => 1,
    'MW' => 1,
    'PK' => 1,
    'NR' => 1,
    'MS' => 1,
    'LR' => 1,
    'SZ' => 1,
    'VC' => 1,
    'SL' => 1,
    'GU' => 1,
    'SE' => 2,
    'TT' => 1,
    'GG' => 1,
    'BI' => 1,
    'HK' => 1
  },
  'som' => {
    'DJ' => 2,
    'ET' => 2,
    'SO' => 1
  },
  'glk' => {
    'IR' => 2
  },
  'mtr' => {
    'IN' => 2
  },
  'und' => {
    'AQ' => 2,
    'GS' => 2,
    'CP' => 2,
    'HM' => 2,
    'BV' => 2
  },
  'mzn' => {
    'IR' => 2
  },
  'niu' => {
    'NU' => 1
  },
  'sav' => {
    'SN' => 2
  },
  'kdh' => {
    'SL' => 2
  },
  'swe' => {
    'SE' => 1,
    'AX' => 1,
    'FI' => 1
  },
  'fao' => {
    'FO' => 1
  },
  'wbr' => {
    'IN' => 2
  },
  'quc' => {
    'GT' => 2
  },
  'abk' => {
    'GE' => 2
  },
  'nds' => {
    'NL' => 2,
    'DE' => 2
  },
  'tyv' => {
    'RU' => 2
  },
  'bew' => {
    'ID' => 2
  },
  'hno' => {
    'PK' => 2
  },
  'khm' => {
    'KH' => 1
  },
  'ara' => {
    'IL' => 1,
    'JO' => 1,
    'KM' => 1,
    'ER' => 1,
    'YE' => 1,
    'EG' => 2,
    'SD' => 1,
    'SA' => 1,
    'LY' => 1,
    'KW' => 1,
    'IR' => 2,
    'BH' => 1,
    'MR' => 1,
    'TD' => 1,
    'MA' => 2,
    'SO' => 1,
    'QA' => 1,
    'PS' => 1,
    'DJ' => 1,
    'SS' => 2,
    'EH' => 1,
    'AE' => 1,
    'SY' => 1,
    'OM' => 1,
    'DZ' => 2,
    'TN' => 1,
    'LB' => 1,
    'IQ' => 1
  },
  'lrc' => {
    'IR' => 2
  },
  'bjj' => {
    'IN' => 2
  },
  'kum' => {
    'RU' => 2
  },
  'men' => {
    'SL' => 2
  },
  'abr' => {
    'GH' => 2
  },
  'tel' => {
    'IN' => 2
  },
  'myx' => {
    'UG' => 2
  },
  'por' => {
    'ST' => 1,
    'GQ' => 1,
    'CV' => 1,
    'GW' => 1,
    'MZ' => 1,
    'BR' => 1,
    'PT' => 1,
    'AO' => 1,
    'MO' => 1,
    'TL' => 1
  },
  'cgg' => {
    'UG' => 2
  },
  'war' => {
    'PH' => 2
  },
  'slv' => {
    'AT' => 2,
    'SI' => 1
  },
  'xnr' => {
    'IN' => 2
  },
  'lao' => {
    'LA' => 1
  },
  'eus' => {
    'ES' => 2
  },
  'mlt' => {
    'MT' => 1
  },
  'san' => {
    'IN' => 2
  },
  'urd' => {
    'PK' => 1,
    'IN' => 2
  },
  'bis' => {
    'VU' => 1
  },
  'mak' => {
    'ID' => 2
  },
  'bal' => {
    'AF' => 2,
    'IR' => 2,
    'PK' => 2
  },
  'tig' => {
    'ER' => 2
  },
  'swv' => {
    'IN' => 2
  },
  'skr' => {
    'PK' => 2
  },
  'hak' => {
    'CN' => 2
  },
  'sot' => {
    'ZA' => 2,
    'LS' => 1
  },
  'pan' => {
    'PK' => 2,
    'IN' => 2
  },
  'iku' => {
    'CA' => 2
  },
  'mnu' => {
    'KE' => 2
  },
  'nob' => {
    'SJ' => 1,
    'NO' => 1
  },
  'run' => {
    'BI' => 1
  },
  'lah' => {
    'PK' => 2
  },
  'sin' => {
    'LK' => 1
  },
  'ibb' => {
    'NG' => 2
  },
  'ind' => {
    'ID' => 1
  },
  'nyn' => {
    'UG' => 2
  },
  'zul' => {
    'ZA' => 2
  },
  'mkd' => {
    'MK' => 1
  },
  'mwr' => {
    'IN' => 2
  },
  'buc' => {
    'YT' => 2
  },
  'knf' => {
    'SN' => 2
  },
  'hsn' => {
    'CN' => 2
  },
  'kea' => {
    'CV' => 2
  },
  'tah' => {
    'PF' => 1
  },
  'sid' => {
    'ET' => 2
  },
  'mdf' => {
    'RU' => 2
  },
  'hat' => {
    'HT' => 1
  },
  'mfa' => {
    'TH' => 2
  },
  'aze' => {
    'AZ' => 1,
    'IR' => 2,
    'RU' => 2,
    'IQ' => 2
  },
  'fud' => {
    'WF' => 2
  },
  'chk' => {
    'FM' => 2
  },
  'ngl' => {
    'MZ' => 2
  },
  'mon' => {
    'CN' => 2,
    'MN' => 1
  },
  'rej' => {
    'ID' => 2
  },
  'gon' => {
    'IN' => 2
  },
  'nau' => {
    'NR' => 1
  },
  'fuv' => {
    'NG' => 2
  },
  'wtm' => {
    'IN' => 2
  },
  'tnr' => {
    'SN' => 2
  },
  'sco' => {
    'GB' => 2
  },
  'kur' => {
    'TR' => 2,
    'SY' => 2,
    'IR' => 2,
    'IQ' => 2
  },
  'rcf' => {
    'RE' => 2
  },
  'gbm' => {
    'IN' => 2
  },
  'cym' => {
    'GB' => 2
  },
  'tkl' => {
    'TK' => 1
  },
  'kab' => {
    'DZ' => 2
  },
  'ffm' => {
    'ML' => 2
  },
  'kan' => {
    'IN' => 2
  },
  'hye' => {
    'AM' => 1,
    'RU' => 2
  },
  'bug' => {
    'ID' => 2
  },
  'kbd' => {
    'RU' => 2
  },
  'nno' => {
    'NO' => 1
  },
  'spa' => {
    'PE' => 1,
    'DO' => 1,
    'BZ' => 2,
    'MX' => 1,
    'CL' => 1,
    'PH' => 2,
    'IC' => 1,
    'PY' => 1,
    'NI' => 1,
    'RO' => 2,
    'US' => 2,
    'BO' => 1,
    'CO' => 1,
    'HN' => 1,
    'FR' => 2,
    'ES' => 1,
    'GT' => 1,
    'DE' => 2,
    'GQ' => 1,
    'UY' => 1,
    'GI' => 2,
    'CR' => 1,
    'PA' => 1,
    'PR' => 1,
    'PT' => 2,
    'CU' => 1,
    'AR' => 1,
    'AD' => 2,
    'SV' => 1,
    'VE' => 1,
    'EC' => 1,
    'EA' => 1
  },
  'kha' => {
    'IN' => 2
  },
  'hun' => {
    'AT' => 2,
    'HU' => 1,
    'RS' => 2,
    'RO' => 2
  },
  'lat' => {
    'VA' => 2
  },
  'kua' => {
    'NA' => 2
  },
  'bsc' => {
    'SN' => 2
  },
  'guz' => {
    'KE' => 2
  },
  'swb' => {
    'YT' => 2
  },
  'lub' => {
    'CD' => 2
  },
  'mlg' => {
    'MG' => 1
  },
  'glg' => {
    'ES' => 2
  },
  'fra' => {
    'RE' => 1,
    'TF' => 2,
    'MF' => 1,
    'BE' => 1,
    'BL' => 1,
    'DJ' => 1,
    'TD' => 1,
    'TG' => 1,
    'MA' => 1,
    'MG' => 1,
    'MC' => 1,
    'CI' => 1,
    'CH' => 1,
    'LU' => 1,
    'RW' => 1,
    'HT' => 1,
    'GP' => 1,
    'MQ' => 1,
    'TN' => 1,
    'FR' => 1,
    'MU' => 1,
    'IT' => 2,
    'RO' => 2,
    'CF' => 1,
    'NC' => 1,
    'CA' => 1,
    'SN' => 1,
    'CG' => 1,
    'CD' => 1,
    'KM' => 1,
    'PM' => 1,
    'PT' => 2,
    'SC' => 1,
    'YT' => 1,
    'NL' => 2,
    'GF' => 1,
    'GB' => 2,
    'GA' => 1,
    'NE' => 1,
    'BI' => 1,
    'VU' => 1,
    'DE' => 2,
    'GQ' => 1,
    'DZ' => 1,
    'US' => 2,
    'WF' => 1,
    'GN' => 1,
    'SY' => 1,
    'BJ' => 1,
    'BF' => 1,
    'CM' => 1,
    'PF' => 1,
    'ML' => 1
  },
  'afr' => {
    'ZA' => 2,
    'NA' => 2
  },
  'bho' => {
    'MU' => 2,
    'NP' => 2,
    'IN' => 2
  },
  'luy' => {
    'KE' => 2
  },
  'tcy' => {
    'IN' => 2
  },
  'tat' => {
    'RU' => 2
  },
  'tpi' => {
    'PG' => 1
  },
  'bgc' => {
    'IN' => 2
  },
  'ace' => {
    'ID' => 2
  },
  'zdj' => {
    'KM' => 1
  },
  'nod' => {
    'TH' => 2
  },
  'iii' => {
    'CN' => 2
  },
  'tsn' => {
    'BW' => 1,
    'ZA' => 2
  },
  'cha' => {
    'GU' => 1
  },
  'awa' => {
    'IN' => 2
  },
  'myv' => {
    'RU' => 2
  },
  'kln' => {
    'KE' => 2
  },
  'heb' => {
    'IL' => 1
  },
  'sdh' => {
    'IR' => 2
  },
  'fvr' => {
    'SD' => 2
  },
  'ady' => {
    'RU' => 2
  },
  'ukr' => {
    'RS' => 2,
    'UA' => 1
  },
  'sas' => {
    'ID' => 2
  },
  'haw' => {
    'US' => 2
  },
  'ven' => {
    'ZA' => 2
  },
  'bem' => {
    'ZM' => 2
  },
  'brx' => {
    'IN' => 2
  },
  'kom' => {
    'RU' => 2
  },
  'mag' => {
    'IN' => 2
  },
  'bin' => {
    'NG' => 2
  },
  'tsg' => {
    'PH' => 2
  },
  'yue' => {
    'HK' => 2,
    'CN' => 2
  },
  'tts' => {
    'TH' => 2
  },
  'tvl' => {
    'TV' => 1
  },
  'sme' => {
    'NO' => 2
  },
  'bej' => {
    'SD' => 2
  },
  'sqq' => {
    'TH' => 2
  },
  'pap' => {
    'BQ' => 2,
    'CW' => 1,
    'AW' => 1
  },
  'pmn' => {
    'PH' => 2
  },
  'xog' => {
    'UG' => 2
  },
  'haz' => {
    'AF' => 2
  },
  'vmw' => {
    'MZ' => 2
  },
  'ilo' => {
    'PH' => 2
  },
  'teo' => {
    'UG' => 2
  },
  'ibo' => {
    'NG' => 2
  },
  'ces' => {
    'SK' => 2,
    'CZ' => 1
  },
  'uig' => {
    'CN' => 2
  },
  'glv' => {
    'IM' => 1
  },
  'nym' => {
    'TZ' => 2
  },
  'roh' => {
    'CH' => 2
  },
  'gan' => {
    'CN' => 2
  },
  'tmh' => {
    'NE' => 2
  },
  'man' => {
    'GM' => 2,
    'GN' => 2
  },
  'hin' => {
    'IN' => 1,
    'FJ' => 2,
    'ZA' => 2
  },
  'que' => {
    'PE' => 1,
    'BO' => 1,
    'EC' => 1
  },
  'tso' => {
    'ZA' => 2,
    'MZ' => 2
  },
  'sna' => {
    'ZW' => 1
  },
  'ndo' => {
    'NA' => 2
  },
  'gom' => {
    'IN' => 2
  },
  'syl' => {
    'BD' => 2
  },
  'sef' => {
    'CI' => 2
  },
  'fas' => {
    'IR' => 1,
    'AF' => 1,
    'PK' => 2
  },
  'unr' => {
    'IN' => 2
  },
  'ast' => {
    'ES' => 2
  },
  'ach' => {
    'UG' => 2
  },
  'bqi' => {
    'IR' => 2
  },
  'krc' => {
    'RU' => 2
  },
  'pus' => {
    'PK' => 2,
    'AF' => 1
  },
  'fij' => {
    'FJ' => 1
  },
  'vls' => {
    'BE' => 2
  },
  'bos' => {
    'BA' => 1
  },
  'zha' => {
    'CN' => 2
  },
  'uzb' => {
    'AF' => 2,
    'UZ' => 1
  },
  'ary' => {
    'MA' => 2
  },
  'tum' => {
    'MW' => 2
  },
  'mad' => {
    'ID' => 2
  },
  'sat' => {
    'IN' => 2
  },
  'kmb' => {
    'AO' => 2
  },
  'ckb' => {
    'IQ' => 2,
    'IR' => 2
  },
  'pon' => {
    'FM' => 2
  },
  'isl' => {
    'IS' => 1
  },
  'hif' => {
    'FJ' => 1
  },
  'aln' => {
    'XK' => 2
  },
  'che' => {
    'RU' => 2
  },
  'slk' => {
    'CZ' => 2,
    'SK' => 1,
    'RS' => 2
  },
  'grn' => {
    'PY' => 1
  },
  'dyu' => {
    'BF' => 2
  },
  'nan' => {
    'CN' => 2
  },
  'nld' => {
    'AW' => 1,
    'SX' => 1,
    'SR' => 1,
    'CW' => 1,
    'NL' => 1,
    'BE' => 1,
    'DE' => 2,
    'BQ' => 1
  },
  'lug' => {
    'UG' => 2
  },
  'rkt' => {
    'IN' => 2,
    'BD' => 2
  },
  'orm' => {
    'ET' => 2
  },
  'kxm' => {
    'TH' => 2
  },
  'msa' => {
    'ID' => 2,
    'TH' => 2,
    'CC' => 2,
    'MY' => 1,
    'BN' => 1,
    'SG' => 1
  },
  'aym' => {
    'BO' => 1
  },
  'tiv' => {
    'NG' => 2
  },
  'hbs' => {
    'ME' => 1,
    'AT' => 2,
    'RS' => 1,
    'SI' => 2,
    'BA' => 1,
    'HR' => 1,
    'XK' => 1
  },
  'bjt' => {
    'SN' => 2
  },
  'bar' => {
    'DE' => 2,
    'AT' => 2
  },
  'bhb' => {
    'IN' => 2
  },
  'luo' => {
    'KE' => 2
  },
  'sun' => {
    'ID' => 2
  },
  'dyo' => {
    'SN' => 2
  },
  'zza' => {
    'TR' => 2
  },
  'lbe' => {
    'RU' => 2
  },
  'tzm' => {
    'MA' => 1
  },
  'zgh' => {
    'MA' => 2
  },
  'kik' => {
    'KE' => 2
  },
  'shn' => {
    'MM' => 2
  },
  'fin' => {
    'SE' => 2,
    'EE' => 2,
    'FI' => 1
  },
  'brh' => {
    'PK' => 2
  },
  'sqi' => {
    'AL' => 1,
    'RS' => 2,
    'XK' => 1,
    'MK' => 2
  },
  'oss' => {
    'GE' => 2
  },
  'gil' => {
    'KI' => 1
  },
  'pau' => {
    'PW' => 1
  },
  'bak' => {
    'RU' => 2
  },
  'pag' => {
    'PH' => 2
  },
  'ndc' => {
    'MZ' => 2
  },
  'snk' => {
    'ML' => 2
  },
  'hne' => {
    'IN' => 2
  },
  'kir' => {
    'KG' => 1
  },
  'rmt' => {
    'IR' => 2
  },
  'bgn' => {
    'PK' => 2
  },
  'ben' => {
    'BD' => 1,
    'IN' => 2
  },
  'kon' => {
    'CD' => 2
  },
  'sah' => {
    'RU' => 2
  },
  'lin' => {
    'CD' => 2
  },
  'rif' => {
    'MA' => 2
  },
  'mgh' => {
    'MZ' => 2
  },
  'dnj' => {
    'CI' => 2
  },
  'gcr' => {
    'GF' => 2
  },
  'kru' => {
    'IN' => 2
  },
  'gsw' => {
    'DE' => 2,
    'LI' => 1,
    'CH' => 1
  },
  'ltz' => {
    'LU' => 1
  },
  'ell' => {
    'CY' => 1,
    'GR' => 1
  },
  'oci' => {
    'FR' => 2
  },
  'mfe' => {
    'MU' => 2
  },
  'srr' => {
    'SN' => 2
  },
  'dan' => {
    'DK' => 1,
    'DE' => 2
  },
  'kat' => {
    'GE' => 1
  },
  'lua' => {
    'CD' => 2
  },
  'swa' => {
    'UG' => 1,
    'KE' => 1,
    'CD' => 2,
    'TZ' => 1
  },
  'fry' => {
    'NL' => 2
  },
  'jam' => {
    'JM' => 2
  },
  'mdh' => {
    'PH' => 2
  },
  'wni' => {
    'KM' => 1
  },
  'wls' => {
    'WF' => 2
  },
  'xho' => {
    'ZA' => 2
  },
  'vie' => {
    'VN' => 1,
    'US' => 2
  },
  'bam' => {
    'ML' => 2
  },
  'wbq' => {
    'IN' => 2
  },
  'tgk' => {
    'TJ' => 1
  },
  'amh' => {
    'ET' => 1
  },
  'sag' => {
    'CF' => 1
  },
  'jpn' => {
    'JP' => 1
  },
  'hrv' => {
    'SI' => 2,
    'BA' => 1,
    'AT' => 2,
    'HR' => 1,
    'RS' => 2
  },
  'bbc' => {
    'ID' => 2
  },
  'mal' => {
    'IN' => 2
  },
  'hil' => {
    'PH' => 2
  },
  'hmo' => {
    'PG' => 1
  },
  'dje' => {
    'NE' => 2
  },
  'aka' => {
    'GH' => 2
  },
  'tha' => {
    'TH' => 1
  },
  'bik' => {
    'PH' => 2
  },
  'bod' => {
    'CN' => 2
  },
  'efi' => {
    'NG' => 2
  },
  'mri' => {
    'NZ' => 1
  },
  'bul' => {
    'BG' => 1
  },
  'mfv' => {
    'SN' => 2
  },
  'wal' => {
    'ET' => 2
  },
  'nor' => {
    'NO' => 1,
    'SJ' => 1
  },
  'arz' => {
    'EG' => 2
  },
  'fan' => {
    'GQ' => 2
  },
  'cat' => {
    'ES' => 2,
    'AD' => 1
  },
  'lav' => {
    'LV' => 1
  },
  'div' => {
    'MV' => 1
  },
  'bmv' => {
    'CM' => 2
  },
  'srp' => {
    'XK' => 1,
    'RS' => 1,
    'BA' => 1,
    'ME' => 1
  },
  'kde' => {
    'TZ' => 2
  },
  'tet' => {
    'TL' => 1
  },
  'nep' => {
    'IN' => 2,
    'NP' => 1
  },
  'nya' => {
    'MW' => 1,
    'ZM' => 2
  },
  'pol' => {
    'PL' => 1,
    'UA' => 2
  },
  'inh' => {
    'RU' => 2
  },
  'mni' => {
    'IN' => 2
  },
  'gqr' => {
    'ID' => 2
  },
  'nso' => {
    'ZA' => 2
  },
  'mai' => {
    'IN' => 2,
    'NP' => 2
  },
  'gle' => {
    'IE' => 1,
    'GB' => 2
  },
  'arq' => {
    'DZ' => 2
  },
  'dzo' => {
    'BT' => 1
  },
  'sus' => {
    'GN' => 2
  },
  'raj' => {
    'IN' => 2
  },
  'tuk' => {
    'AF' => 2,
    'IR' => 2,
    'TM' => 1
  },
  'fil' => {
    'US' => 2,
    'PH' => 1
  },
  'deu' => {
    'DE' => 1,
    'LI' => 1,
    'SK' => 2,
    'DK' => 2,
    'US' => 2,
    'HU' => 2,
    'FR' => 2,
    'SI' => 2,
    'BE' => 1,
    'NL' => 2,
    'AT' => 1,
    'KZ' => 2,
    'PL' => 2,
    'LU' => 1,
    'CZ' => 2,
    'CH' => 1,
    'BR' => 2,
    'GB' => 2
  },
  'asm' => {
    'IN' => 2
  },
  'mya' => {
    'MM' => 1
  },
  'zho' => {
    'TH' => 2,
    'US' => 2,
    'SG' => 1,
    'TW' => 1,
    'CN' => 1,
    'HK' => 1,
    'MO' => 1,
    'MY' => 2,
    'VN' => 2,
    'ID' => 2
  },
  'min' => {
    'ID' => 2
  },
  'csb' => {
    'PL' => 2
  },
  'bci' => {
    'CI' => 2
  },
  'chv' => {
    'RU' => 2
  },
  'hoc' => {
    'IN' => 2
  },
  'ceb' => {
    'PH' => 2
  },
  'est' => {
    'EE' => 1
  },
  'nbl' => {
    'ZA' => 2
  },
  'khn' => {
    'IN' => 2
  },
  'tur' => {
    'DE' => 2,
    'CY' => 1,
    'TR' => 1
  },
  'wuu' => {
    'CN' => 2
  },
  'ita' => {
    'VA' => 1,
    'FR' => 2,
    'US' => 2,
    'CH' => 1,
    'HR' => 2,
    'IT' => 1,
    'SM' => 1,
    'MT' => 2,
    'DE' => 2
  },
  'dcc' => {
    'IN' => 2
  },
  'bel' => {
    'BY' => 1
  },
  'bhi' => {
    'IN' => 2
  },
  'umb' => {
    'AO' => 2
  },
  'ttb' => {
    'GH' => 2
  },
  'laj' => {
    'UG' => 2
  },
  'ewe' => {
    'TG' => 2,
    'GH' => 2
  },
  'kdx' => {
    'KE' => 2
  }
};
$Lang2Script = {
  'hrv' => {
    'Latn' => 1
  },
  'sag' => {
    'Latn' => 1
  },
  'khb' => {
    'Talu' => 1
  },
  'xpr' => {
    'Prti' => 2
  },
  'ina' => {
    'Latn' => 2
  },
  'mri' => {
    'Latn' => 1
  },
  'efi' => {
    'Latn' => 1
  },
  'ksf' => {
    'Latn' => 1
  },
  'bod' => {
    'Tibt' => 1
  },
  'dje' => {
    'Latn' => 1
  },
  'hmo' => {
    'Latn' => 1
  },
  'hnn' => {
    'Latn' => 1,
    'Hano' => 2
  },
  'hil' => {
    'Latn' => 1
  },
  'mal' => {
    'Mlym' => 1
  },
  'sgs' => {
    'Latn' => 1
  },
  'bbc' => {
    'Latn' => 1,
    'Batk' => 2
  },
  'mas' => {
    'Latn' => 1
  },
  'lua' => {
    'Latn' => 1
  },
  'pms' => {
    'Latn' => 1
  },
  'kvr' => {
    'Latn' => 1
  },
  'xmr' => {
    'Merc' => 2
  },
  'bam' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'vie' => {
    'Latn' => 1,
    'Hani' => 2
  },
  'wls' => {
    'Latn' => 1
  },
  'pnt' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Grek' => 1
  },
  'car' => {
    'Latn' => 1
  },
  'hnd' => {
    'Arab' => 1
  },
  'mni' => {
    'Beng' => 1,
    'Mtei' => 2
  },
  'inh' => {
    'Cyrl' => 1,
    'Latn' => 2,
    'Arab' => 2
  },
  'pol' => {
    'Latn' => 1
  },
  'abq' => {
    'Cyrl' => 1
  },
  'cat' => {
    'Latn' => 1
  },
  'nor' => {
    'Latn' => 1
  },
  'bul' => {
    'Cyrl' => 1
  },
  'kfo' => {
    'Latn' => 1
  },
  'kde' => {
    'Latn' => 1
  },
  'srp' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'bmv' => {
    'Latn' => 1
  },
  'kpe' => {
    'Latn' => 1
  },
  'dum' => {
    'Latn' => 2
  },
  'hop' => {
    'Latn' => 1
  },
  'akk' => {
    'Xsux' => 2
  },
  'bft' => {
    'Tibt' => 2,
    'Arab' => 1
  },
  'sus' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'kiu' => {
    'Latn' => 1
  },
  'rmo' => {
    'Latn' => 1
  },
  'fil' => {
    'Tglg' => 2,
    'Latn' => 1
  },
  'bqv' => {
    'Latn' => 1
  },
  'sei' => {
    'Latn' => 1
  },
  'sbp' => {
    'Latn' => 1
  },
  'crk' => {
    'Cans' => 1
  },
  'raj' => {
    'Deva' => 1,
    'Arab' => 1
  },
  'cja' => {
    'Arab' => 1,
    'Cham' => 2
  },
  'rmu' => {
    'Latn' => 1
  },
  'nxq' => {
    'Latn' => 1
  },
  'naq' => {
    'Latn' => 1
  },
  'twq' => {
    'Latn' => 1
  },
  'iba' => {
    'Latn' => 1
  },
  'ksb' => {
    'Latn' => 1
  },
  'dzo' => {
    'Tibt' => 1
  },
  'chn' => {
    'Latn' => 2
  },
  'arq' => {
    'Arab' => 1
  },
  'lmo' => {
    'Latn' => 1
  },
  'lis' => {
    'Lisu' => 1
  },
  'bhi' => {
    'Deva' => 1
  },
  'kos' => {
    'Latn' => 1
  },
  'smn' => {
    'Latn' => 1
  },
  'dcc' => {
    'Arab' => 1
  },
  'lab' => {
    'Lina' => 2
  },
  'ita' => {
    'Latn' => 1
  },
  'maz' => {
    'Latn' => 1
  },
  'ewe' => {
    'Latn' => 1
  },
  'laj' => {
    'Latn' => 1
  },
  'umb' => {
    'Latn' => 1
  },
  'bto' => {
    'Latn' => 1
  },
  'chv' => {
    'Cyrl' => 1
  },
  'hoc' => {
    'Wara' => 2,
    'Deva' => 1
  },
  'bci' => {
    'Latn' => 1
  },
  'mya' => {
    'Mymr' => 1
  },
  'tab' => {
    'Cyrl' => 1
  },
  'deu' => {
    'Latn' => 1,
    'Runr' => 2
  },
  'bzx' => {
    'Latn' => 1
  },
  'wuu' => {
    'Hans' => 1
  },
  'tur' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'taj' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'mwv' => {
    'Latn' => 1
  },
  'nbl' => {
    'Latn' => 1
  },
  'trv' => {
    'Latn' => 1
  },
  'lut' => {
    'Latn' => 2
  },
  'est' => {
    'Latn' => 1
  },
  'mua' => {
    'Latn' => 1
  },
  'nog' => {
    'Cyrl' => 1
  },
  'kkj' => {
    'Latn' => 1
  },
  'teo' => {
    'Latn' => 1
  },
  'vmw' => {
    'Latn' => 1
  },
  'gld' => {
    'Cyrl' => 1
  },
  'tso' => {
    'Latn' => 1
  },
  'gwi' => {
    'Latn' => 1
  },
  'glv' => {
    'Latn' => 1
  },
  'sqq' => {
    'Thai' => 1
  },
  'lij' => {
    'Latn' => 1
  },
  'bmq' => {
    'Latn' => 1
  },
  'haz' => {
    'Arab' => 1
  },
  'xsa' => {
    'Sarb' => 2
  },
  'jml' => {
    'Deva' => 1
  },
  'xog' => {
    'Latn' => 1
  },
  'pap' => {
    'Latn' => 1
  },
  'lcp' => {
    'Thai' => 1
  },
  'sat' => {
    'Orya' => 2,
    'Latn' => 2,
    'Deva' => 2,
    'Beng' => 2,
    'Olck' => 1
  },
  'prg' => {
    'Latn' => 2
  },
  'tum' => {
    'Latn' => 1
  },
  'xcr' => {
    'Cari' => 2
  },
  'uzb' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'zha' => {
    'Latn' => 1,
    'Hans' => 2
  },
  'rjs' => {
    'Deva' => 1
  },
  'slk' => {
    'Latn' => 1
  },
  'aln' => {
    'Latn' => 1
  },
  'hif' => {
    'Deva' => 1,
    'Latn' => 1
  },
  'isl' => {
    'Latn' => 1
  },
  'maf' => {
    'Latn' => 1
  },
  'kmb' => {
    'Latn' => 1
  },
  'fas' => {
    'Arab' => 1
  },
  'kpy' => {
    'Cyrl' => 1
  },
  'nmg' => {
    'Latn' => 1
  },
  'syl' => {
    'Beng' => 1,
    'Sylo' => 2
  },
  'yao' => {
    'Latn' => 1
  },
  'fij' => {
    'Latn' => 1
  },
  'bqi' => {
    'Arab' => 1
  },
  'kau' => {
    'Latn' => 1
  },
  'unr' => {
    'Deva' => 1,
    'Beng' => 1
  },
  'zza' => {
    'Latn' => 1
  },
  'lif' => {
    'Limb' => 1,
    'Deva' => 1
  },
  'yap' => {
    'Latn' => 1
  },
  'bar' => {
    'Latn' => 1
  },
  'eka' => {
    'Latn' => 1
  },
  'bub' => {
    'Cyrl' => 1
  },
  'sqi' => {
    'Latn' => 1,
    'Elba' => 2
  },
  'shn' => {
    'Mymr' => 1
  },
  'kik' => {
    'Latn' => 1
  },
  'vec' => {
    'Latn' => 1
  },
  'nan' => {
    'Hans' => 1
  },
  'kxp' => {
    'Arab' => 1
  },
  'dgr' => {
    'Latn' => 1
  },
  'grn' => {
    'Latn' => 1
  },
  'arn' => {
    'Latn' => 1
  },
  'aym' => {
    'Latn' => 1
  },
  'orm' => {
    'Ethi' => 2,
    'Latn' => 1
  },
  'lug' => {
    'Latn' => 1
  },
  'scn' => {
    'Latn' => 1
  },
  'gsw' => {
    'Latn' => 1
  },
  'vep' => {
    'Latn' => 1
  },
  'xav' => {
    'Latn' => 1
  },
  'xsr' => {
    'Deva' => 1
  },
  'dua' => {
    'Latn' => 1
  },
  'mgh' => {
    'Latn' => 1
  },
  'rif' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'sah' => {
    'Cyrl' => 1
  },
  'ben' => {
    'Beng' => 1
  },
  'kac' => {
    'Latn' => 1
  },
  'lep' => {
    'Lepc' => 1
  },
  'nch' => {
    'Latn' => 1
  },
  'mfe' => {
    'Latn' => 1
  },
  'ell' => {
    'Grek' => 1
  },
  'cjm' => {
    'Arab' => 2,
    'Cham' => 1
  },
  'pau' => {
    'Latn' => 1
  },
  'gay' => {
    'Latn' => 1
  },
  'gil' => {
    'Latn' => 1
  },
  'oss' => {
    'Cyrl' => 1
  },
  'rug' => {
    'Latn' => 1
  },
  'amo' => {
    'Latn' => 1
  },
  'ude' => {
    'Cyrl' => 1
  },
  'tli' => {
    'Latn' => 1
  },
  'nyo' => {
    'Latn' => 1
  },
  'snk' => {
    'Latn' => 1
  },
  'mrd' => {
    'Deva' => 1
  },
  'zea' => {
    'Latn' => 1
  },
  'nav' => {
    'Latn' => 1
  },
  'gur' => {
    'Latn' => 1
  },
  'nia' => {
    'Latn' => 1
  },
  'tsj' => {
    'Tibt' => 1
  },
  'ext' => {
    'Latn' => 1
  },
  'buc' => {
    'Latn' => 1
  },
  'mwr' => {
    'Deva' => 1
  },
  'zul' => {
    'Latn' => 1
  },
  'ind' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'chr' => {
    'Cher' => 1
  },
  'pfl' => {
    'Latn' => 1
  },
  'kck' => {
    'Latn' => 1
  },
  'hak' => {
    'Hans' => 1
  },
  'sot' => {
    'Latn' => 1
  },
  'skr' => {
    'Arab' => 1
  },
  'gez' => {
    'Ethi' => 2
  },
  'del' => {
    'Latn' => 1
  },
  'sin' => {
    'Sinh' => 1
  },
  'run' => {
    'Latn' => 1
  },
  'ang' => {
    'Latn' => 2
  },
  'wbp' => {
    'Latn' => 1
  },
  'iku' => {
    'Cans' => 1,
    'Latn' => 1
  },
  'vol' => {
    'Latn' => 2
  },
  'rcf' => {
    'Latn' => 1
  },
  'kaj' => {
    'Latn' => 1
  },
  'kur' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'lol' => {
    'Latn' => 1
  },
  'bfd' => {
    'Latn' => 1
  },
  'kab' => {
    'Latn' => 1
  },
  'tkl' => {
    'Latn' => 1
  },
  'gbm' => {
    'Deva' => 1
  },
  'pdc' => {
    'Latn' => 1
  },
  'ife' => {
    'Latn' => 1
  },
  'mdf' => {
    'Cyrl' => 1
  },
  'bax' => {
    'Bamu' => 1
  },
  'sid' => {
    'Latn' => 1
  },
  'vun' => {
    'Latn' => 1
  },
  'kut' => {
    'Latn' => 1
  },
  'arg' => {
    'Latn' => 1
  },
  'fuv' => {
    'Latn' => 1
  },
  'rej' => {
    'Latn' => 1,
    'Rjng' => 2
  },
  'frr' => {
    'Latn' => 1
  },
  'ngl' => {
    'Latn' => 1
  },
  'lun' => {
    'Latn' => 1
  },
  'mxc' => {
    'Latn' => 1
  },
  'fud' => {
    'Latn' => 1
  },
  'bre' => {
    'Latn' => 1
  },
  'aze' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'zag' => {
    'Latn' => 1
  },
  'loz' => {
    'Latn' => 1
  },
  'fra' => {
    'Dupl' => 2,
    'Latn' => 1
  },
  'glg' => {
    'Latn' => 1
  },
  'mlg' => {
    'Latn' => 1
  },
  'pko' => {
    'Latn' => 1
  },
  'swb' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'nzi' => {
    'Latn' => 1
  },
  'sma' => {
    'Latn' => 1
  },
  'nod' => {
    'Lana' => 1
  },
  'ace' => {
    'Latn' => 1
  },
  'cch' => {
    'Latn' => 1
  },
  'bgc' => {
    'Deva' => 1
  },
  'unx' => {
    'Beng' => 1,
    'Deva' => 1
  },
  'yua' => {
    'Latn' => 1
  },
  'tcy' => {
    'Knda' => 1
  },
  'xmn' => {
    'Mani' => 2
  },
  'nov' => {
    'Latn' => 2
  },
  'hun' => {
    'Latn' => 1
  },
  'egy' => {
    'Egyp' => 2
  },
  'spa' => {
    'Latn' => 1
  },
  'nno' => {
    'Latn' => 1
  },
  'ttt' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 2
  },
  'kbd' => {
    'Cyrl' => 1
  },
  'rgn' => {
    'Latn' => 1
  },
  'xlc' => {
    'Lyci' => 2
  },
  'cad' => {
    'Latn' => 1
  },
  'crj' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'kua' => {
    'Latn' => 1
  },
  'vic' => {
    'Latn' => 1
  },
  'haw' => {
    'Latn' => 1
  },
  'uli' => {
    'Latn' => 1
  },
  'non' => {
    'Runr' => 2
  },
  'ewo' => {
    'Latn' => 1
  },
  'ady' => {
    'Cyrl' => 1
  },
  'saq' => {
    'Latn' => 1
  },
  'prd' => {
    'Arab' => 1
  },
  'agq' => {
    'Latn' => 1
  },
  'bin' => {
    'Latn' => 1
  },
  'khw' => {
    'Arab' => 1
  },
  'bem' => {
    'Latn' => 1
  },
  'hsb' => {
    'Latn' => 1
  },
  'myv' => {
    'Cyrl' => 1
  },
  'awa' => {
    'Deva' => 1
  },
  'dng' => {
    'Cyrl' => 1
  },
  'gju' => {
    'Arab' => 1
  },
  'cha' => {
    'Latn' => 1
  },
  'nus' => {
    'Latn' => 1
  },
  'fvr' => {
    'Latn' => 1
  },
  'sdh' => {
    'Arab' => 1
  },
  'dtm' => {
    'Latn' => 1
  },
  'heb' => {
    'Hebr' => 1
  },
  'kln' => {
    'Latn' => 1
  },
  'ebu' => {
    'Latn' => 1
  },
  'lez' => {
    'Cyrl' => 1,
    'Aghb' => 2
  },
  'bfq' => {
    'Taml' => 1
  },
  'kok' => {
    'Deva' => 1
  },
  'bjn' => {
    'Latn' => 1
  },
  'gla' => {
    'Latn' => 1
  },
  'dak' => {
    'Latn' => 1
  },
  'ljp' => {
    'Latn' => 1
  },
  'ori' => {
    'Orya' => 1
  },
  'aeb' => {
    'Arab' => 1
  },
  'gba' => {
    'Latn' => 1
  },
  'seh' => {
    'Latn' => 1
  },
  'ban' => {
    'Bali' => 2,
    'Latn' => 1
  },
  'fuq' => {
    'Latn' => 1
  },
  'ckt' => {
    'Cyrl' => 1
  },
  'cor' => {
    'Latn' => 1
  },
  'peo' => {
    'Xpeo' => 2
  },
  'grt' => {
    'Beng' => 1
  },
  'qug' => {
    'Latn' => 1
  },
  'shr' => {
    'Tfng' => 1,
    'Arab' => 1,
    'Latn' => 1
  },
  'hau' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'rmf' => {
    'Latn' => 1
  },
  'suk' => {
    'Latn' => 1
  },
  'thl' => {
    'Deva' => 1
  },
  'rng' => {
    'Latn' => 1
  },
  'crs' => {
    'Latn' => 1
  },
  'egl' => {
    'Latn' => 1
  },
  'crl' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'jmc' => {
    'Latn' => 1
  },
  'ipk' => {
    'Latn' => 1
  },
  'rtm' => {
    'Latn' => 1
  },
  'rof' => {
    'Latn' => 1
  },
  'vmf' => {
    'Latn' => 1
  },
  'ava' => {
    'Cyrl' => 1
  },
  'sly' => {
    'Latn' => 1
  },
  'hoj' => {
    'Deva' => 1
  },
  'rap' => {
    'Latn' => 1
  },
  'kaz' => {
    'Cyrl' => 1,
    'Arab' => 1
  },
  'kfy' => {
    'Deva' => 1
  },
  'lzz' => {
    'Geor' => 1,
    'Latn' => 1
  },
  'bkm' => {
    'Latn' => 1
  },
  'mos' => {
    'Latn' => 1
  },
  'gos' => {
    'Latn' => 1
  },
  'osc' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'mtr' => {
    'Deva' => 1
  },
  'mic' => {
    'Latn' => 1
  },
  'gvr' => {
    'Deva' => 1
  },
  'srb' => {
    'Sora' => 2,
    'Latn' => 1
  },
  'bbj' => {
    'Latn' => 1
  },
  'sad' => {
    'Latn' => 1
  },
  'moe' => {
    'Latn' => 1
  },
  'fao' => {
    'Latn' => 1
  },
  'swe' => {
    'Latn' => 1
  },
  'akz' => {
    'Latn' => 1
  },
  'kas' => {
    'Arab' => 1,
    'Deva' => 1
  },
  'kal' => {
    'Latn' => 1
  },
  'kri' => {
    'Latn' => 1
  },
  'chm' => {
    'Cyrl' => 1
  },
  'zen' => {
    'Tfng' => 2
  },
  'uga' => {
    'Ugar' => 2
  },
  'som' => {
    'Osma' => 2,
    'Latn' => 1,
    'Arab' => 2
  },
  'aoz' => {
    'Latn' => 1
  },
  'cre' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'urd' => {
    'Arab' => 1
  },
  'ltg' => {
    'Latn' => 1
  },
  'san' => {
    'Sinh' => 2,
    'Sidd' => 2,
    'Gran' => 2,
    'Shrd' => 2,
    'Deva' => 2
  },
  'frm' => {
    'Latn' => 2
  },
  'mlt' => {
    'Latn' => 1
  },
  'lao' => {
    'Laoo' => 1
  },
  'eus' => {
    'Latn' => 1
  },
  'lui' => {
    'Latn' => 2
  },
  'sxn' => {
    'Latn' => 1
  },
  'war' => {
    'Latn' => 1
  },
  'dsb' => {
    'Latn' => 1
  },
  'pli' => {
    'Deva' => 2,
    'Sinh' => 2,
    'Thai' => 2
  },
  'mak' => {
    'Bugi' => 2,
    'Latn' => 1
  },
  'kvx' => {
    'Arab' => 1
  },
  'alt' => {
    'Cyrl' => 1
  },
  'ara' => {
    'Arab' => 1,
    'Syrc' => 2
  },
  'rob' => {
    'Latn' => 1
  },
  'bvb' => {
    'Latn' => 1
  },
  'tyv' => {
    'Cyrl' => 1
  },
  'jut' => {
    'Latn' => 2
  },
  'myx' => {
    'Latn' => 1
  },
  'tel' => {
    'Telu' => 1
  },
  'zmi' => {
    'Latn' => 1
  },
  'abr' => {
    'Latn' => 1
  },
  'gjk' => {
    'Arab' => 1
  },
  'kum' => {
    'Cyrl' => 1
  },
  'jpn' => {
    'Jpan' => 1
  },
  'rom' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'amh' => {
    'Ethi' => 1
  },
  'ryu' => {
    'Kana' => 1
  },
  'tgk' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'pcd' => {
    'Latn' => 1
  },
  'bik' => {
    'Latn' => 1
  },
  'tha' => {
    'Thai' => 1
  },
  'bez' => {
    'Latn' => 1
  },
  'aka' => {
    'Latn' => 1
  },
  'gmh' => {
    'Latn' => 2
  },
  'ses' => {
    'Latn' => 1
  },
  'din' => {
    'Latn' => 1
  },
  'wni' => {
    'Arab' => 1
  },
  'sel' => {
    'Cyrl' => 2
  },
  'mdh' => {
    'Latn' => 1
  },
  'bap' => {
    'Deva' => 1
  },
  'jam' => {
    'Latn' => 1
  },
  'fry' => {
    'Latn' => 1
  },
  'smj' => {
    'Latn' => 1
  },
  'swa' => {
    'Latn' => 1
  },
  'kat' => {
    'Geor' => 1
  },
  'wbq' => {
    'Telu' => 1
  },
  'guc' => {
    'Latn' => 1
  },
  'mgo' => {
    'Latn' => 1
  },
  'xho' => {
    'Latn' => 1
  },
  'chy' => {
    'Latn' => 1
  },
  'epo' => {
    'Latn' => 1
  },
  'nep' => {
    'Deva' => 1
  },
  'mls' => {
    'Latn' => 1
  },
  'gqr' => {
    'Latn' => 1
  },
  'crh' => {
    'Cyrl' => 1
  },
  'bze' => {
    'Latn' => 1
  },
  'ter' => {
    'Latn' => 1
  },
  'nya' => {
    'Latn' => 1
  },
  'szl' => {
    'Latn' => 1
  },
  'lav' => {
    'Latn' => 1
  },
  'ada' => {
    'Latn' => 1
  },
  'phn' => {
    'Phnx' => 2
  },
  'fan' => {
    'Latn' => 1
  },
  'arz' => {
    'Arab' => 1
  },
  'wal' => {
    'Ethi' => 1
  },
  'lad' => {
    'Hebr' => 1
  },
  'was' => {
    'Latn' => 1
  },
  'cic' => {
    'Latn' => 1
  },
  'tet' => {
    'Latn' => 1
  },
  'div' => {
    'Thaa' => 1
  },
  'goh' => {
    'Latn' => 2
  },
  'moh' => {
    'Latn' => 1
  },
  'mdr' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'wae' => {
    'Latn' => 1
  },
  'lwl' => {
    'Thai' => 1
  },
  'byn' => {
    'Ethi' => 1
  },
  'cos' => {
    'Latn' => 1
  },
  'kjh' => {
    'Cyrl' => 1
  },
  'xal' => {
    'Cyrl' => 1
  },
  'gbz' => {
    'Arab' => 1
  },
  'tuk' => {
    'Arab' => 1,
    'Cyrl' => 1,
    'Latn' => 1
  },
  'her' => {
    'Latn' => 1
  },
  'gle' => {
    'Latn' => 1
  },
  'lzh' => {
    'Hans' => 2
  },
  'mai' => {
    'Tirh' => 2,
    'Deva' => 1
  },
  'mdt' => {
    'Latn' => 1
  },
  'nso' => {
    'Latn' => 1
  },
  'bgx' => {
    'Grek' => 1
  },
  'scs' => {
    'Latn' => 1
  },
  'tly' => {
    'Latn' => 1,
    'Cyrl' => 1,
    'Arab' => 1
  },
  'tog' => {
    'Latn' => 1
  },
  'ale' => {
    'Latn' => 1
  },
  'ars' => {
    'Arab' => 1
  },
  'evn' => {
    'Cyrl' => 1
  },
  'nij' => {
    'Latn' => 1
  },
  'mgp' => {
    'Deva' => 1
  },
  'bel' => {
    'Cyrl' => 1
  },
  'see' => {
    'Latn' => 1
  },
  'xum' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'ttj' => {
    'Latn' => 1
  },
  'byv' => {
    'Latn' => 1
  },
  'kdx' => {
    'Latn' => 1
  },
  'ttb' => {
    'Latn' => 1
  },
  'bss' => {
    'Latn' => 1
  },
  'ave' => {
    'Avst' => 2
  },
  'cps' => {
    'Latn' => 1
  },
  'csb' => {
    'Latn' => 2
  },
  'tdg' => {
    'Tibt' => 2,
    'Deva' => 1
  },
  'mns' => {
    'Cyrl' => 1
  },
  'min' => {
    'Latn' => 1
  },
  'zho' => {
    'Hant' => 1,
    'Phag' => 2,
    'Bopo' => 2,
    'Hans' => 1
  },
  'thr' => {
    'Deva' => 1
  },
  'bpy' => {
    'Beng' => 1
  },
  'otk' => {
    'Orkh' => 2
  },
  'asm' => {
    'Beng' => 1
  },
  'got' => {
    'Goth' => 2
  },
  'hnj' => {
    'Laoo' => 1
  },
  'yrk' => {
    'Cyrl' => 1
  },
  'khn' => {
    'Deva' => 1
  },
  'ain' => {
    'Latn' => 2,
    'Kana' => 2
  },
  'kaa' => {
    'Cyrl' => 1
  },
  'ceb' => {
    'Latn' => 1
  },
  'ces' => {
    'Latn' => 1
  },
  'ibo' => {
    'Latn' => 1
  },
  'ilo' => {
    'Latn' => 1
  },
  'que' => {
    'Latn' => 1
  },
  'dty' => {
    'Deva' => 1
  },
  'hin' => {
    'Deva' => 1,
    'Latn' => 2,
    'Mahj' => 2
  },
  'man' => {
    'Latn' => 1,
    'Nkoo' => 1
  },
  'tmh' => {
    'Latn' => 1
  },
  'gan' => {
    'Hans' => 1
  },
  'roh' => {
    'Latn' => 1
  },
  'lfn' => {
    'Cyrl' => 2,
    'Latn' => 2
  },
  'nym' => {
    'Latn' => 1
  },
  'uig' => {
    'Arab' => 1,
    'Latn' => 2,
    'Cyrl' => 1
  },
  'bla' => {
    'Latn' => 1
  },
  'bej' => {
    'Arab' => 1
  },
  'tvl' => {
    'Latn' => 1
  },
  'sme' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'kfr' => {
    'Deva' => 1
  },
  'tts' => {
    'Thai' => 1
  },
  'yue' => {
    'Hans' => 1,
    'Hant' => 1
  },
  'tsg' => {
    'Latn' => 1
  },
  'tdh' => {
    'Deva' => 1
  },
  'rup' => {
    'Latn' => 1
  },
  'wln' => {
    'Latn' => 1
  },
  'pmn' => {
    'Latn' => 1
  },
  'mrj' => {
    'Cyrl' => 1
  },
  'mad' => {
    'Latn' => 1
  },
  'aii' => {
    'Syrc' => 2,
    'Cyrl' => 1
  },
  'kjg' => {
    'Latn' => 2,
    'Laoo' => 1
  },
  'ary' => {
    'Arab' => 1
  },
  'crm' => {
    'Cans' => 1
  },
  'bos' => {
    'Cyrl' => 1,
    'Latn' => 1
  },
  'che' => {
    'Cyrl' => 1
  },
  'grb' => {
    'Latn' => 1
  },
  'pon' => {
    'Latn' => 1
  },
  'hai' => {
    'Latn' => 1
  },
  'ckb' => {
    'Arab' => 1
  },
  'sef' => {
    'Latn' => 1
  },
  'gom' => {
    'Deva' => 1
  },
  'ndo' => {
    'Latn' => 1
  },
  'new' => {
    'Deva' => 1
  },
  'sna' => {
    'Latn' => 1
  },
  'vls' => {
    'Latn' => 1
  },
  'pus' => {
    'Arab' => 1
  },
  'krc' => {
    'Cyrl' => 1
  },
  'pro' => {
    'Latn' => 2
  },
  'ach' => {
    'Latn' => 1
  },
  'ast' => {
    'Latn' => 1
  },
  'lbe' => {
    'Cyrl' => 1
  },
  'dyo' => {
    'Latn' => 1,
    'Arab' => 2
  },
  'sun' => {
    'Latn' => 1,
    'Sund' => 2
  },
  'luo' => {
    'Latn' => 1
  },
  'dav' => {
    'Latn' => 1
  },
  'bhb' => {
    'Deva' => 1
  },
  'nsk' => {
    'Cans' => 1,
    'Latn' => 2
  },
  'liv' => {
    'Latn' => 2
  },
  'vai' => {
    'Vaii' => 1,
    'Latn' => 1
  },
  'brh' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'kge' => {
    'Latn' => 1
  },
  'fin' => {
    'Latn' => 1
  },
  'xld' => {
    'Lydi' => 2
  },
  'tzm' => {
    'Latn' => 1,
    'Tfng' => 1
  },
  'zgh' => {
    'Tfng' => 1
  },
  'hup' => {
    'Latn' => 1
  },
  'nld' => {
    'Latn' => 1
  },
  'mwl' => {
    'Latn' => 1
  },
  'dyu' => {
    'Latn' => 1
  },
  'asa' => {
    'Latn' => 1
  },
  'esu' => {
    'Latn' => 1
  },
  'hbs' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'tiv' => {
    'Latn' => 1
  },
  'nqo' => {
    'Nkoo' => 1
  },
  'msa' => {
    'Arab' => 1,
    'Latn' => 1
  },
  'kxm' => {
    'Thai' => 1
  },
  'rkt' => {
    'Beng' => 1
  },
  'swg' => {
    'Latn' => 1
  },
  'kru' => {
    'Deva' => 1
  },
  'gcr' => {
    'Latn' => 1
  },
  'dnj' => {
    'Latn' => 1
  },
  'bra' => {
    'Deva' => 1
  },
  'vot' => {
    'Latn' => 2
  },
  'lin' => {
    'Latn' => 1
  },
  'kon' => {
    'Latn' => 1
  },
  'sms' => {
    'Latn' => 1
  },
  'ssy' => {
    'Latn' => 1
  },
  'dan' => {
    'Latn' => 1
  },
  'syi' => {
    'Latn' => 1
  },
  'srr' => {
    'Latn' => 1
  },
  'tkt' => {
    'Deva' => 1
  },
  'oci' => {
    'Latn' => 1
  },
  'frs' => {
    'Latn' => 1
  },
  'mvy' => {
    'Arab' => 1
  },
  'ltz' => {
    'Latn' => 1
  },
  'atj' => {
    'Latn' => 1
  },
  'nhw' => {
    'Latn' => 1
  },
  'bak' => {
    'Cyrl' => 1
  },
  'lkt' => {
    'Latn' => 1
  },
  'bgn' => {
    'Arab' => 1
  },
  'rmt' => {
    'Arab' => 1
  },
  'blt' => {
    'Tavt' => 1
  },
  'kir' => {
    'Cyrl' => 1,
    'Latn' => 1,
    'Arab' => 1
  },
  'tkr' => {
    'Latn' => 1,
    'Cyrl' => 1
  },
  'hne' => {
    'Deva' => 1
  },
  'ndc' => {
    'Latn' => 1
  },
  'khq' => {
    'Latn' => 1
  },
  'pag' => {
    'Latn' => 1
  },
  'mkd' => {
    'Cyrl' => 1
  },
  'nyn' => {
    'Latn' => 1
  },
  'ibb' => {
    'Latn' => 1
  },
  'tah' => {
    'Latn' => 1
  },
  'kea' => {
    'Latn' => 1
  },
  'hsn' => {
    'Hans' => 1
  },
  'cay' => {
    'Latn' => 1
  },
  'saz' => {
    'Saur' => 1
  },
  'nhe' => {
    'Latn' => 1
  },
  'jgo' => {
    'Latn' => 1
  },
  'ybb' => {
    'Latn' => 1
  },
  'swv' => {
    'Deva' => 1
  },
  'tig' => {
    'Ethi' => 1
  },
  'bas' => {
    'Latn' => 1
  },
  'bal' => {
    'Arab' => 1,
    'Latn' => 2
  },
  'sli' => {
    'Latn' => 1
  },
  'lah' => {
    'Arab' => 1
  },
  'nob' => {
    'Latn' => 1
  },
  'csw' => {
    'Cans' => 1
  },
  'ett' => {
    'Ital' => 2,
    'Latn' => 2
  },
  'mnu' => {
    'Latn' => 1
  },
  'srx' => {
    'Deva' => 1
  },
  'pan' => {
    'Arab' => 1,
    'Guru' => 1
  },
  'izh' => {
    'Latn' => 1
  },
  'lbw' => {
    'Latn' => 1
  },
  'zap' => {
    'Latn' => 1
  },
  'sco' => {
    'Latn' => 1
  },
  'wtm' => {
    'Deva' => 1
  },
  'aro' => {
    'Latn' => 1
  },
  'mro' => {
    'Latn' => 1,
    'Mroo' => 2
  },
  'ksh' => {
    'Latn' => 1
  },
  'ffm' => {
    'Latn' => 1
  },
  'cym' => {
    'Latn' => 1
  },
  'mus' => {
    'Latn' => 1
  },
  'tbw' => {
    'Tagb' => 2,
    'Latn' => 1
  },
  'hat' => {
    'Latn' => 1
  },
  'mfa' => {
    'Arab' => 1
  },
  'mwk' => {
    'Latn' => 1
  },
  'njo' => {
    'Latn' => 1
  },
  'nau' => {
    'Latn' => 1
  },
  'gon' => {
    'Deva' => 1,
    'Telu' => 1
  },
  'mon' => {
    'Phag' => 2,
    'Mong' => 2,
    'Cyrl' => 1
  },
  'kht' => {
    'Mymr' => 1
  },
  'chk' => {
    'Latn' => 1
  },
  'snx' => {
    'Hebr' => 2,
    'Samr' => 2
  },
  'kca' => {
    'Cyrl' => 1
  },
  'luy' => {
    'Latn' => 1
  },
  'cop' => {
    'Grek' => 2,
    'Arab' => 2,
    'Copt' => 2
  },
  'afr' => {
    'Latn' => 1
  },
  'bho' => {
    'Deva' => 1
  },
  'lub' => {
    'Latn' => 1
  },
  'ctd' => {
    'Latn' => 1
  },
  'guz' => {
    'Latn' => 1
  },
  'mnc' => {
    'Mong' => 2
  },
  'zdj' => {
    'Arab' => 1
  },
  'tpi' => {
    'Latn' => 1
  },
  'tat' => {
    'Cyrl' => 1
  },
  'kha' => {
    'Beng' => 2,
    'Latn' => 1
  },
  'bug' => {
    'Latn' => 1,
    'Bugi' => 2
  },
  'nap' => {
    'Latn' => 1
  },
  'jpr' => {
    'Hebr' => 1
  },
  'hye' => {
    'Armn' => 1
  },
  'kan' => {
    'Knda' => 1
  },
  'arp' => {
    'Latn' => 1
  },
  'osa' => {
    'Osge' => 1,
    'Latn' => 2
  },
  'lat' => {
    'Latn' => 2
  },
  'tsd' => {
    'Grek' => 1
  },
  'ven' => {
    'Latn' => 1
  },
  'syr' => {
    'Cyrl' => 1,
    'Syrc' => 2
  },
  'sas' => {
    'Latn' => 1
  },
  'lki' => {
    'Arab' => 1
  },
  'grc' => {
    'Grek' => 2,
    'Linb' => 2,
    'Cprt' => 2
  },
  'ukr' => {
    'Cyrl' => 1
  },
  'arc' => {
    'Nbat' => 2,
    'Palm' => 2,
    'Armi' => 2
  },
  'gag' => {
    'Cyrl' => 2,
    'Latn' => 1
  },
  'xmf' => {
    'Geor' => 1
  },
  'yav' => {
    'Latn' => 1
  },
  'kyu' => {
    'Kali' => 1
  },
  'mag' => {
    'Deva' => 1
  },
  'rar' => {
    'Latn' => 1
  },
  'lim' => {
    'Latn' => 1
  },
  'kom' => {
    'Perm' => 2,
    'Cyrl' => 1
  },
  'brx' => {
    'Deva' => 1
  },
  'dtp' => {
    'Latn' => 1
  },
  'tsn' => {
    'Latn' => 1
  },
  'iii' => {
    'Yiii' => 1,
    'Latn' => 2
  },
  'anp' => {
    'Deva' => 1
  },
  'stq' => {
    'Latn' => 1
  },
  'krj' => {
    'Latn' => 1
  },
  'bfy' => {
    'Deva' => 1
  },
  'udm' => {
    'Latn' => 2,
    'Cyrl' => 1
  },
  'zun' => {
    'Latn' => 1
  },
  'tam' => {
    'Taml' => 1
  },
  'fon' => {
    'Latn' => 1
  },
  'rwk' => {
    'Latn' => 1
  },
  'doi' => {
    'Takr' => 2,
    'Arab' => 1,
    'Deva' => 1
  },
  'wol' => {
    'Arab' => 2,
    'Latn' => 1
  },
  'kdt' => {
    'Thai' => 1
  },
  'ron' => {
    'Latn' => 1,
    'Cyrl' => 2
  },
  'ssw' => {
    'Latn' => 1
  },
  'kcg' => {
    'Latn' => 1
  },
  'fit' => {
    'Latn' => 1
  },
  'mah' => {
    'Latn' => 1
  },
  'krl' => {
    'Latn' => 1
  },
  'ful' => {
    'Adlm' => 2,
    'Latn' => 1
  },
  'noe' => {
    'Deva' => 1
  },
  'lam' => {
    'Latn' => 1
  },
  'yid' => {
    'Hebr' => 1
  },
  'srd' => {
    'Latn' => 1
  },
  'fro' => {
    'Latn' => 2
  },
  'xna' => {
    'Narb' => 2
  },
  'den' => {
    'Cans' => 2,
    'Latn' => 1
  },
  'rus' => {
    'Cyrl' => 1
  },
  'smo' => {
    'Latn' => 1
  },
  'mgy' => {
    'Latn' => 1
  },
  'lmn' => {
    'Telu' => 1
  },
  'eky' => {
    'Kali' => 1
  },
  'yrl' => {
    'Latn' => 1
  },
  'sga' => {
    'Ogam' => 2,
    'Latn' => 2
  },
  'tir' => {
    'Ethi' => 1
  },
  'btv' => {
    'Deva' => 1
  },
  'yor' => {
    'Latn' => 1
  },
  'cho' => {
    'Latn' => 1
  },
  'lit' => {
    'Latn' => 1
  },
  'thq' => {
    'Deva' => 1
  },
  'tsi' => {
    'Latn' => 1
  },
  'pcm' => {
    'Latn' => 1
  },
  'nnh' => {
    'Latn' => 1
  },
  'kin' => {
    'Latn' => 1
  },
  'myz' => {
    'Mand' => 2
  },
  'kkt' => {
    'Cyrl' => 1
  },
  'enm' => {
    'Latn' => 2
  },
  'kor' => {
    'Kore' => 1
  },
  'ikt' => {
    'Latn' => 1
  },
  'vro' => {
    'Latn' => 1
  },
  'chu' => {
    'Cyrl' => 2
  },
  'jav' => {
    'Latn' => 1,
    'Java' => 2
  },
  'snd' => {
    'Deva' => 1,
    'Sind' => 2,
    'Arab' => 1,
    'Khoj' => 2
  },
  'tdd' => {
    'Tale' => 1
  },
  'lus' => {
    'Beng' => 1
  },
  'abw' => {
    'Phlp' => 2,
    'Phli' => 2
  },
  'tru' => {
    'Latn' => 1,
    'Syrc' => 2
  },
  'nde' => {
    'Latn' => 1
  },
  'kgp' => {
    'Latn' => 1
  },
  'srn' => {
    'Latn' => 1
  },
  'ton' => {
    'Latn' => 1
  },
  'sck' => {
    'Deva' => 1
  },
  'jrb' => {
    'Hebr' => 1
  },
  'dar' => {
    'Cyrl' => 1
  },
  'pdt' => {
    'Latn' => 1
  },
  'niu' => {
    'Latn' => 1
  },
  'mzn' => {
    'Arab' => 1
  },
  'oji' => {
    'Latn' => 2,
    'Cans' => 1
  },
  'glk' => {
    'Arab' => 1
  },
  'saf' => {
    'Latn' => 1
  },
  'nds' => {
    'Latn' => 1
  },
  'arw' => {
    'Latn' => 2
  },
  'abk' => {
    'Cyrl' => 1
  },
  'quc' => {
    'Latn' => 1
  },
  'hit' => {
    'Xsux' => 2
  },
  'wbr' => {
    'Deva' => 1
  },
  'ccp' => {
    'Beng' => 1,
    'Cakm' => 1
  },
  'kdh' => {
    'Latn' => 1
  },
  'sdc' => {
    'Latn' => 1
  },
  'luz' => {
    'Arab' => 1
  },
  'aar' => {
    'Latn' => 1
  },
  'gub' => {
    'Latn' => 1
  },
  'puu' => {
    'Latn' => 1
  },
  'frc' => {
    'Latn' => 1
  },
  'hmd' => {
    'Plrd' => 1
  },
  'eng' => {
    'Latn' => 1,
    'Shaw' => 2,
    'Dsrt' => 2
  },
  'chp' => {
    'Latn' => 1,
    'Cans' => 2
  },
  'bku' => {
    'Buhd' => 2,
    'Latn' => 1
  },
  'guj' => {
    'Gujr' => 1
  },
  'mar' => {
    'Deva' => 1,
    'Modi' => 2
  },
  'cjs' => {
    'Cyrl' => 1
  },
  'smp' => {
    'Samr' => 2
  },
  'xnr' => {
    'Deva' => 1
  },
  'slv' => {
    'Latn' => 1
  },
  'mnw' => {
    'Mymr' => 1
  },
  'fia' => {
    'Arab' => 1
  },
  'frp' => {
    'Latn' => 1
  },
  'rue' => {
    'Cyrl' => 1
  },
  'ria' => {
    'Latn' => 1
  },
  'bis' => {
    'Latn' => 1
  },
  'bjj' => {
    'Deva' => 1
  },
  'lrc' => {
    'Arab' => 1
  },
  'hmn' => {
    'Hmng' => 2,
    'Laoo' => 1,
    'Latn' => 1,
    'Plrd' => 1
  },
  'khm' => {
    'Khmr' => 1
  },
  'hno' => {
    'Arab' => 1
  },
  'kax' => {
    'Latn' => 1
  },
  'bew' => {
    'Latn' => 1
  },
  'cgg' => {
    'Latn' => 1
  },
  'por' => {
    'Latn' => 1
  },
  'lag' => {
    'Latn' => 1
  },
  'men' => {
    'Latn' => 1,
    'Mend' => 2
  },
  'avk' => {
    'Latn' => 2
  }
};
$Territory2Lang = {
  'BM' => {
    'eng' => 1
  },
  'KR' => {
    'kor' => 1
  },
  'IE' => {
    'gle' => 1,
    'eng' => 1
  },
  'GL' => {
    'kal' => 1
  },
  'CK' => {
    'eng' => 1
  },
  'GY' => {
    'eng' => 1
  },
  'CD' => {
    'fra' => 1,
    'lua' => 2,
    'swa' => 2,
    'lub' => 2,
    'kon' => 2,
    'lin' => 2
  },
  'SV' => {
    'spa' => 1
  },
  'UG' => {
    'myx' => 2,
    'ach' => 2,
    'nyn' => 2,
    'lug' => 2,
    'xog' => 2,
    'swa' => 1,
    'teo' => 2,
    'cgg' => 2,
    'laj' => 2,
    'eng' => 1
  },
  'IO' => {
    'eng' => 1
  },
  'AR' => {
    'eng' => 2,
    'spa' => 1
  },
  'CN' => {
    'hak' => 2,
    'zho' => 1,
    'kor' => 2,
    'nan' => 2,
    'iii' => 2,
    'zha' => 2,
    'yue' => 2,
    'wuu' => 2,
    'bod' => 2,
    'mon' => 2,
    'kaz' => 2,
    'gan' => 2,
    'hsn' => 2,
    'uig' => 2
  },
  'SA' => {
    'ara' => 1
  },
  'GM' => {
    'man' => 2,
    'eng' => 1
  },
  'TV' => {
    'tvl' => 1,
    'eng' => 1
  },
  'KW' => {
    'ara' => 1
  },
  'TF' => {
    'fra' => 2
  },
  'MD' => {
    'ron' => 1
  },
  'TA' => {
    'eng' => 2
  },
  'MK' => {
    'sqi' => 2,
    'mkd' => 1
  },
  'PS' => {
    'ara' => 1
  },
  'BL' => {
    'fra' => 1
  },
  'BY' => {
    'rus' => 1,
    'bel' => 1
  },
  'DJ' => {
    'ara' => 1,
    'fra' => 1,
    'aar' => 2,
    'som' => 2
  },
  'FM' => {
    'chk' => 2,
    'pon' => 2,
    'eng' => 1
  },
  'IT' => {
    'fra' => 2,
    'ita' => 1,
    'srd' => 2,
    'eng' => 2
  },
  'AW' => {
    'pap' => 1,
    'nld' => 1
  },
  'ES' => {
    'eng' => 2,
    'ast' => 2,
    'glg' => 2,
    'eus' => 2,
    'spa' => 1,
    'cat' => 2
  },
  'MN' => {
    'mon' => 1
  },
  'LB' => {
    'eng' => 2,
    'ara' => 1
  },
  'LK' => {
    'eng' => 2,
    'tam' => 1,
    'sin' => 1
  },
  'NR' => {
    'eng' => 1,
    'nau' => 1
  },
  'ST' => {
    'por' => 1
  },
  'GI' => {
    'eng' => 1,
    'spa' => 2
  },
  'GH' => {
    'abr' => 2,
    'ttb' => 2,
    'aka' => 2,
    'eng' => 1,
    'ewe' => 2
  },
  'MW' => {
    'nya' => 1,
    'eng' => 1,
    'tum' => 2
  },
  'BG' => {
    'rus' => 2,
    'eng' => 2,
    'bul' => 1
  },
  'CR' => {
    'spa' => 1
  },
  'TZ' => {
    'suk' => 2,
    'nym' => 2,
    'kde' => 2,
    'swa' => 1,
    'eng' => 1
  },
  'KN' => {
    'eng' => 1
  },
  'EC' => {
    'spa' => 1,
    'que' => 1
  },
  'AD' => {
    'cat' => 1,
    'spa' => 2
  },
  'TO' => {
    'eng' => 1,
    'ton' => 1
  },
  'UM' => {
    'eng' => 1
  },
  'FI' => {
    'eng' => 2,
    'swe' => 1,
    'fin' => 1
  },
  'MR' => {
    'ara' => 1
  },
  'BH' => {
    'ara' => 1
  },
  'BI' => {
    'run' => 1,
    'fra' => 1,
    'eng' => 1
  },
  'SO' => {
    'ara' => 1,
    'som' => 1
  },
  'CW' => {
    'pap' => 1,
    'nld' => 1
  },
  'GG' => {
    'eng' => 1
  },
  'UY' => {
    'spa' => 1
  },
  'TT' => {
    'eng' => 1
  },
  'SE' => {
    'eng' => 2,
    'swe' => 1,
    'fin' => 2
  },
  'SZ' => {
    'ssw' => 1,
    'eng' => 1
  },
  'VC' => {
    'eng' => 1
  },
  'LR' => {
    'eng' => 1
  },
  'WF' => {
    'wls' => 2,
    'fra' => 1,
    'fud' => 2
  },
  'CF' => {
    'sag' => 1,
    'fra' => 1
  },
  'NA' => {
    'ndo' => 2,
    'eng' => 1,
    'afr' => 2,
    'kua' => 2
  },
  'GS' => {
    'und' => 2
  },
  'AT' => {
    'hrv' => 2,
    'hun' => 2,
    'hbs' => 2,
    'eng' => 2,
    'slv' => 2,
    'deu' => 1,
    'bar' => 2
  },
  'CV' => {
    'kea' => 2,
    'por' => 1
  },
  'PM' => {
    'fra' => 1
  },
  'NF' => {
    'eng' => 1
  },
  'JO' => {
    'eng' => 2,
    'ara' => 1
  },
  'SN' => {
    'knf' => 2,
    'bjt' => 2,
    'wol' => 1,
    'mfv' => 2,
    'tnr' => 2,
    'sav' => 2,
    'fra' => 1,
    'mey' => 2,
    'snf' => 2,
    'srr' => 2,
    'ful' => 2,
    'dyo' => 2,
    'bsc' => 2
  },
  'CA' => {
    'fra' => 1,
    'iku' => 2,
    'eng' => 1,
    'ikt' => 2
  },
  'JE' => {
    'eng' => 1
  },
  'NU' => {
    'niu' => 1,
    'eng' => 1
  },
  'KP' => {
    'kor' => 1
  },
  'CU' => {
    'spa' => 1
  },
  'SB' => {
    'eng' => 1
  },
  'SK' => {
    'ces' => 2,
    'slk' => 1,
    'eng' => 2,
    'deu' => 2
  },
  'DG' => {
    'eng' => 1
  },
  'SD' => {
    'bej' => 2,
    'fvr' => 2,
    'ara' => 1,
    'eng' => 1
  },
  'MV' => {
    'div' => 1
  },
  'RS' => {
    'ukr' => 2,
    'srp' => 1,
    'sqi' => 2,
    'slk' => 2,
    'hun' => 2,
    'hrv' => 2,
    'hbs' => 1,
    'ron' => 2
  },
  'BS' => {
    'eng' => 1
  },
  'PL' => {
    'csb' => 2,
    'lit' => 2,
    'rus' => 2,
    'deu' => 2,
    'eng' => 2,
    'pol' => 1
  },
  'KZ' => {
    'rus' => 1,
    'deu' => 2,
    'eng' => 2,
    'kaz' => 1
  },
  'PY' => {
    'spa' => 1,
    'grn' => 1
  },
  'HM' => {
    'und' => 2
  },
  'IR' => {
    'bal' => 2,
    'glk' => 2,
    'ara' => 2,
    'kur' => 2,
    'mzn' => 2,
    'lrc' => 2,
    'luz' => 2,
    'fas' => 1,
    'aze' => 2,
    'ckb' => 2,
    'tuk' => 2,
    'bqi' => 2,
    'rmt' => 2,
    'sdh' => 2
  },
  'JP' => {
    'jpn' => 1
  },
  'MF' => {
    'fra' => 1
  },
  'TD' => {
    'fra' => 1,
    'ara' => 1
  },
  'MA' => {
    'fra' => 1,
    'ara' => 2,
    'eng' => 2,
    'shr' => 2,
    'zgh' => 2,
    'tzm' => 1,
    'rif' => 2,
    'ary' => 2
  },
  'AO' => {
    'kmb' => 2,
    'umb' => 2,
    'por' => 1
  },
  'TK' => {
    'eng' => 1,
    'tkl' => 1
  },
  'LU' => {
    'eng' => 2,
    'deu' => 1,
    'fra' => 1,
    'ltz' => 1
  },
  'KE' => {
    'kln' => 2,
    'guz' => 2,
    'swa' => 1,
    'kik' => 2,
    'mnu' => 2,
    'eng' => 1,
    'luo' => 2,
    'kdx' => 2,
    'luy' => 2
  },
  'AE' => {
    'eng' => 2,
    'ara' => 1
  },
  'LV' => {
    'eng' => 2,
    'lav' => 1,
    'rus' => 2
  },
  'TN' => {
    'aeb' => 2,
    'ara' => 1,
    'fra' => 1
  },
  'LA' => {
    'lao' => 1
  },
  'MU' => {
    'fra' => 1,
    'mfe' => 2,
    'eng' => 1,
    'bho' => 2
  },
  'AZ' => {
    'aze' => 1
  },
  'ME' => {
    'hbs' => 1,
    'srp' => 1
  },
  'PG' => {
    'eng' => 1,
    'hmo' => 1,
    'tpi' => 1
  },
  'FJ' => {
    'hin' => 2,
    'hif' => 1,
    'fij' => 1,
    'eng' => 1
  },
  'TW' => {
    'zho' => 1
  },
  'XK' => {
    'aln' => 2,
    'sqi' => 1,
    'hbs' => 1,
    'srp' => 1
  },
  'MZ' => {
    'por' => 1,
    'seh' => 2,
    'tso' => 2,
    'vmw' => 2,
    'ndc' => 2,
    'mgh' => 2,
    'ngl' => 2
  },
  'AU' => {
    'eng' => 1
  },
  'DM' => {
    'eng' => 1
  },
  'CP' => {
    'und' => 2
  },
  'EG' => {
    'arz' => 2,
    'ara' => 2,
    'eng' => 2
  },
  'YE' => {
    'ara' => 1,
    'eng' => 2
  },
  'AF' => {
    'haz' => 2,
    'tuk' => 2,
    'bal' => 2,
    'uzb' => 2,
    'fas' => 1,
    'pus' => 1
  },
  'BQ' => {
    'nld' => 1,
    'pap' => 2
  },
  'MO' => {
    'por' => 1,
    'zho' => 1
  },
  'VI' => {
    'eng' => 1
  },
  'SR' => {
    'nld' => 1,
    'srn' => 2
  },
  'NP' => {
    'nep' => 1,
    'mai' => 2,
    'bho' => 2
  },
  'PH' => {
    'ilo' => 2,
    'war' => 2,
    'tsg' => 2,
    'mdh' => 2,
    'spa' => 2,
    'hil' => 2,
    'pmn' => 2,
    'pag' => 2,
    'bhk' => 2,
    'ceb' => 2,
    'fil' => 1,
    'bik' => 2,
    'eng' => 1
  },
  'ZM' => {
    'bem' => 2,
    'eng' => 1,
    'nya' => 2
  },
  'LT' => {
    'eng' => 2,
    'lit' => 1,
    'rus' => 2
  },
  'YT' => {
    'fra' => 1,
    'swb' => 2,
    'buc' => 2
  },
  'NZ' => {
    'eng' => 1,
    'mri' => 1
  },
  'ID' => {
    'bbc' => 2,
    'ace' => 2,
    'ljp' => 2,
    'gqr' => 2,
    'mak' => 2,
    'msa' => 2,
    'rej' => 2,
    'sas' => 2,
    'ind' => 1,
    'bjn' => 2,
    'bew' => 2,
    'jav' => 2,
    'sun' => 2,
    'mad' => 2,
    'bug' => 2,
    'ban' => 2,
    'zho' => 2,
    'min' => 2
  },
  'CZ' => {
    'ces' => 1,
    'slk' => 2,
    'deu' => 2,
    'eng' => 2
  },
  'TR' => {
    'tur' => 1,
    'zza' => 2,
    'eng' => 2,
    'kur' => 2
  },
  'NE' => {
    'dje' => 2,
    'ful' => 2,
    'tmh' => 2,
    'fra' => 1,
    'fuq' => 2,
    'hau' => 2
  },
  'EH' => {
    'ara' => 1
  },
  'MP' => {
    'eng' => 1
  },
  'NO' => {
    'nno' => 1,
    'nob' => 1,
    'nor' => 1,
    'sme' => 2
  },
  'IN' => {
    'ori' => 2,
    'wbr' => 2,
    'hin' => 1,
    'bgc' => 2,
    'mal' => 2,
    'raj' => 2,
    'tcy' => 2,
    'mtr' => 2,
    'mwr' => 2,
    'bho' => 2,
    'kok' => 2,
    'doi' => 2,
    'tam' => 2,
    'bhb' => 2,
    'eng' => 1,
    'wbq' => 2,
    'lmn' => 2,
    'mar' => 2,
    'pan' => 2,
    'rkt' => 2,
    'guj' => 2,
    'kas' => 2,
    'noe' => 2,
    'kha' => 2,
    'swv' => 2,
    'kan' => 2,
    'mai' => 2,
    'mag' => 2,
    'mni' => 2,
    'gbm' => 2,
    'brx' => 2,
    'urd' => 2,
    'kru' => 2,
    'bhi' => 2,
    'sat' => 2,
    'san' => 2,
    'nep' => 2,
    'ben' => 2,
    'wtm' => 2,
    'dcc' => 2,
    'xnr' => 2,
    'gon' => 2,
    'kfy' => 2,
    'khn' => 2,
    'unr' => 2,
    'tel' => 2,
    'hne' => 2,
    'sck' => 2,
    'awa' => 2,
    'gom' => 2,
    'bjj' => 2,
    'hoc' => 2,
    'snd' => 2,
    'hoj' => 2,
    'asm' => 2
  },
  'MT' => {
    'eng' => 1,
    'ita' => 2,
    'mlt' => 1
  },
  'GQ' => {
    'fan' => 2,
    'spa' => 1,
    'por' => 1,
    'fra' => 1
  },
  'BJ' => {
    'fon' => 2,
    'fra' => 1
  },
  'VG' => {
    'eng' => 1
  },
  'CO' => {
    'spa' => 1
  },
  'US' => {
    'fra' => 2,
    'eng' => 1,
    'zho' => 2,
    'kor' => 2,
    'fil' => 2,
    'haw' => 2,
    'spa' => 2,
    'ita' => 2,
    'deu' => 2,
    'vie' => 2
  },
  'NC' => {
    'fra' => 1
  },
  'GE' => {
    'oss' => 2,
    'kat' => 1,
    'abk' => 2
  },
  'IL' => {
    'ara' => 1,
    'heb' => 1,
    'eng' => 2
  },
  'PR' => {
    'eng' => 1,
    'spa' => 1
  },
  'FO' => {
    'fao' => 1
  },
  'TH' => {
    'sqq' => 2,
    'mfa' => 2,
    'nod' => 2,
    'kxm' => 2,
    'msa' => 2,
    'zho' => 2,
    'eng' => 2,
    'tha' => 1,
    'tts' => 2
  },
  'CC' => {
    'msa' => 2,
    'eng' => 1
  },
  'BT' => {
    'dzo' => 1
  },
  'UA' => {
    'pol' => 2,
    'ukr' => 1,
    'rus' => 1
  },
  'ER' => {
    'tig' => 2,
    'tir' => 1,
    'ara' => 1,
    'eng' => 1
  },
  'DK' => {
    'dan' => 1,
    'deu' => 2,
    'kal' => 2,
    'eng' => 2
  },
  'SG' => {
    'zho' => 1,
    'eng' => 1,
    'msa' => 1,
    'tam' => 1
  },
  'BE' => {
    'vls' => 2,
    'nld' => 1,
    'deu' => 1,
    'eng' => 2,
    'fra' => 1
  },
  'PW' => {
    'pau' => 1,
    'eng' => 1
  },
  'RE' => {
    'rcf' => 2,
    'fra' => 1
  },
  'HR' => {
    'ita' => 2,
    'eng' => 2,
    'hrv' => 1,
    'hbs' => 1
  },
  'MC' => {
    'fra' => 1
  },
  'IM' => {
    'glv' => 1,
    'eng' => 1
  },
  'TG' => {
    'fra' => 1,
    'ewe' => 2
  },
  'BZ' => {
    'eng' => 1,
    'spa' => 2
  },
  'QA' => {
    'ara' => 1
  },
  'GT' => {
    'quc' => 2,
    'spa' => 1
  },
  'MQ' => {
    'fra' => 1
  },
  'AS' => {
    'eng' => 1,
    'smo' => 1
  },
  'GP' => {
    'fra' => 1
  },
  'RO' => {
    'eng' => 2,
    'fra' => 2,
    'spa' => 2,
    'ron' => 1,
    'hun' => 2
  },
  'SH' => {
    'eng' => 1
  },
  'SI' => {
    'eng' => 2,
    'deu' => 2,
    'slv' => 1,
    'hbs' => 2,
    'hrv' => 2
  },
  'LC' => {
    'eng' => 1
  },
  'BO' => {
    'aym' => 1,
    'que' => 1,
    'spa' => 1
  },
  'BF' => {
    'mos' => 2,
    'fra' => 1,
    'dyu' => 2
  },
  'AQ' => {
    'und' => 2
  },
  'MS' => {
    'eng' => 1
  },
  'PK' => {
    'snd' => 2,
    'bal' => 2,
    'hno' => 2,
    'skr' => 2,
    'urd' => 1,
    'fas' => 2,
    'pan' => 2,
    'brh' => 2,
    'eng' => 1,
    'pus' => 2,
    'bgn' => 2,
    'lah' => 2
  },
  'BV' => {
    'und' => 2
  },
  'TL' => {
    'por' => 1,
    'tet' => 1
  },
  'ZW' => {
    'eng' => 1,
    'sna' => 1,
    'nde' => 1
  },
  'BA' => {
    'bos' => 1,
    'eng' => 2,
    'srp' => 1,
    'hrv' => 1,
    'hbs' => 1
  },
  'PN' => {
    'eng' => 1
  },
  'SM' => {
    'ita' => 1
  },
  'LS' => {
    'sot' => 1,
    'eng' => 1
  },
  'AC' => {
    'eng' => 2
  },
  'SX' => {
    'eng' => 1,
    'nld' => 1
  },
  'RU' => {
    'sah' => 2,
    'ava' => 2,
    'lez' => 2,
    'tyv' => 2,
    'ady' => 2,
    'hye' => 2,
    'chv' => 2,
    'mdf' => 2,
    'myv' => 2,
    'kbd' => 2,
    'udm' => 2,
    'lbe' => 2,
    'bak' => 2,
    'kkt' => 2,
    'che' => 2,
    'rus' => 1,
    'tat' => 2,
    'aze' => 2,
    'kum' => 2,
    'kom' => 2,
    'inh' => 2,
    'krc' => 2
  },
  'GF' => {
    'gcr' => 2,
    'fra' => 1
  },
  'TM' => {
    'tuk' => 1
  },
  'VN' => {
    'vie' => 1,
    'zho' => 2
  },
  'HK' => {
    'yue' => 2,
    'zho' => 1,
    'eng' => 1
  },
  'GA' => {
    'fra' => 1
  },
  'UZ' => {
    'uzb' => 1,
    'rus' => 2
  },
  'GU' => {
    'cha' => 1,
    'eng' => 1
  },
  'SL' => {
    'men' => 2,
    'eng' => 1,
    'kdh' => 2,
    'kri' => 2
  },
  'SY' => {
    'ara' => 1,
    'fra' => 1,
    'kur' => 2
  },
  'HN' => {
    'spa' => 1
  },
  'NG' => {
    'ibo' => 2,
    'yor' => 1,
    'ful' => 2,
    'ibb' => 2,
    'hau' => 2,
    'eng' => 1,
    'pcm' => 2,
    'bin' => 2,
    'fuv' => 2,
    'tiv' => 2,
    'efi' => 2
  },
  'ET' => {
    'aar' => 2,
    'som' => 2,
    'tir' => 2,
    'sid' => 2,
    'eng' => 2,
    'amh' => 1,
    'orm' => 2,
    'wal' => 2
  },
  'GW' => {
    'por' => 1
  },
  'IS' => {
    'isl' => 1
  },
  'BR' => {
    'por' => 1,
    'deu' => 2,
    'eng' => 2
  },
  'KM' => {
    'ara' => 1,
    'fra' => 1,
    'zdj' => 1,
    'wni' => 1
  },
  'MH' => {
    'eng' => 1,
    'mah' => 1
  },
  'CG' => {
    'fra' => 1
  },
  'VE' => {
    'spa' => 1
  },
  'AM' => {
    'hye' => 1
  },
  'AX' => {
    'swe' => 1
  },
  'PT' => {
    'spa' => 2,
    'fra' => 2,
    'por' => 1,
    'eng' => 2
  },
  'LI' => {
    'gsw' => 1,
    'deu' => 1
  },
  'WS' => {
    'eng' => 1,
    'smo' => 1
  },
  'SC' => {
    'crs' => 2,
    'eng' => 1,
    'fra' => 1
  },
  'TJ' => {
    'tgk' => 1,
    'rus' => 2
  },
  'KY' => {
    'eng' => 1
  },
  'NI' => {
    'spa' => 1
  },
  'TC' => {
    'eng' => 1
  },
  'MG' => {
    'fra' => 1,
    'eng' => 1,
    'mlg' => 1
  },
  'CH' => {
    'gsw' => 1,
    'eng' => 2,
    'fra' => 1,
    'roh' => 2,
    'deu' => 1,
    'ita' => 1
  },
  'CI' => {
    'bci' => 2,
    'sef' => 2,
    'dnj' => 2,
    'fra' => 1
  },
  'RW' => {
    'fra' => 1,
    'kin' => 1,
    'eng' => 1
  },
  'PE' => {
    'que' => 1,
    'spa' => 1
  },
  'BW' => {
    'tsn' => 1,
    'eng' => 1
  },
  'ZA' => {
    'zul' => 2,
    'xho' => 2,
    'tsn' => 2,
    'nso' => 2,
    'afr' => 2,
    'hin' => 2,
    'sot' => 2,
    'ven' => 2,
    'tso' => 2,
    'nbl' => 2,
    'eng' => 1,
    'ssw' => 2
  },
  'SJ' => {
    'nob' => 1,
    'rus' => 2,
    'nor' => 1
  },
  'GR' => {
    'ell' => 1,
    'eng' => 2
  },
  'JM' => {
    'eng' => 1,
    'jam' => 2
  },
  'HT' => {
    'hat' => 1,
    'fra' => 1
  },
  'EE' => {
    'est' => 1,
    'rus' => 2,
    'fin' => 2,
    'eng' => 2
  },
  'AL' => {
    'sqi' => 1
  },
  'FR' => {
    'ita' => 2,
    'deu' => 2,
    'spa' => 2,
    'fra' => 1,
    'oci' => 2,
    'eng' => 2
  },
  'CM' => {
    'fra' => 1,
    'eng' => 1,
    'bmv' => 2
  },
  'KG' => {
    'rus' => 1,
    'kir' => 1
  },
  'PA' => {
    'spa' => 1
  },
  'PF' => {
    'fra' => 1,
    'tah' => 1
  },
  'MY' => {
    'tam' => 2,
    'msa' => 1,
    'eng' => 2,
    'zho' => 2
  },
  'ML' => {
    'ful' => 2,
    'snk' => 2,
    'ffm' => 2,
    'bam' => 2,
    'fra' => 1
  },
  'BB' => {
    'eng' => 1
  },
  'BD' => {
    'rkt' => 2,
    'ben' => 1,
    'eng' => 2,
    'syl' => 2
  },
  'CX' => {
    'eng' => 1
  },
  'EA' => {
    'spa' => 1
  },
  'AG' => {
    'eng' => 1
  },
  'BN' => {
    'msa' => 1
  },
  'LY' => {
    'ara' => 1
  },
  'NL' => {
    'nld' => 1,
    'fry' => 2,
    'nds' => 2,
    'deu' => 2,
    'eng' => 2,
    'fra' => 2
  },
  'KH' => {
    'khm' => 1
  },
  'KI' => {
    'gil' => 1,
    'eng' => 1
  },
  'IC' => {
    'spa' => 1
  },
  'MM' => {
    'mya' => 1,
    'shn' => 2
  },
  'MX' => {
    'spa' => 1,
    'eng' => 2
  },
  'DO' => {
    'spa' => 1
  },
  'VU' => {
    'eng' => 1,
    'bis' => 1,
    'fra' => 1
  },
  'GB' => {
    'sco' => 2,
    'deu' => 2,
    'eng' => 1,
    'cym' => 2,
    'fra' => 2,
    'gle' => 2,
    'gla' => 2
  },
  'CL' => {
    'eng' => 2,
    'spa' => 1
  },
  'CY' => {
    'tur' => 1,
    'eng' => 2,
    'ell' => 1
  },
  'GD' => {
    'eng' => 1
  },
  'SS' => {
    'eng' => 1,
    'ara' => 2
  },
  'DE' => {
    'vmf' => 2,
    'fra' => 2,
    'eng' => 2,
    'nds' => 2,
    'dan' => 2,
    'gsw' => 2,
    'tur' => 2,
    'spa' => 2,
    'nld' => 2,
    'ita' => 2,
    'bar' => 2,
    'deu' => 1,
    'rus' => 2
  },
  'GN' => {
    'ful' => 2,
    'sus' => 2,
    'fra' => 1,
    'man' => 2
  },
  'OM' => {
    'ara' => 1
  },
  'VA' => {
    'lat' => 2,
    'ita' => 1
  },
  'DZ' => {
    'kab' => 2,
    'arq' => 2,
    'eng' => 2,
    'ara' => 2,
    'fra' => 1
  },
  'IQ' => {
    'ara' => 1,
    'ckb' => 2,
    'kur' => 2,
    'aze' => 2,
    'eng' => 2
  },
  'FK' => {
    'eng' => 1
  },
  'AI' => {
    'eng' => 1
  },
  'HU' => {
    'eng' => 2,
    'deu' => 2,
    'hun' => 1
  }
};
$Script2Lang = {
  'Hebr' => {
    'yid' => 1,
    'snx' => 2,
    'jrb' => 1,
    'jpr' => 1,
    'lad' => 1,
    'heb' => 1
  },
  'Olck' => {
    'sat' => 1
  },
  'Tagb' => {
    'tbw' => 2
  },
  'Mtei' => {
    'mni' => 2
  },
  'Armi' => {
    'arc' => 2
  },
  'Orya' => {
    'sat' => 2,
    'ori' => 1
  },
  'Lyci' => {
    'xlc' => 2
  },
  'Dupl' => {
    'fra' => 2
  },
  'Xpeo' => {
    'peo' => 2
  },
  'Talu' => {
    'khb' => 1
  },
  'Shaw' => {
    'eng' => 2
  },
  'Phnx' => {
    'phn' => 2
  },
  'Merc' => {
    'xmr' => 2
  },
  'Takr' => {
    'doi' => 2
  },
  'Wara' => {
    'hoc' => 2
  },
  'Sora' => {
    'srb' => 2
  },
  'Tavt' => {
    'blt' => 1
  },
  'Sund' => {
    'sun' => 2
  },
  'Tfng' => {
    'zgh' => 1,
    'tzm' => 1,
    'zen' => 2,
    'shr' => 1,
    'rif' => 1
  },
  'Sylo' => {
    'syl' => 2
  },
  'Mend' => {
    'men' => 2
  },
  'Cham' => {
    'cja' => 2,
    'cjm' => 1
  },
  'Gujr' => {
    'guj' => 1
  },
  'Perm' => {
    'kom' => 2
  },
  'Vaii' => {
    'vai' => 1
  },
  'Kana' => {
    'ryu' => 1,
    'ain' => 2
  },
  'Saur' => {
    'saz' => 1
  },
  'Lydi' => {
    'xld' => 2
  },
  'Tirh' => {
    'mai' => 2
  },
  'Bali' => {
    'ban' => 2
  },
  'Phlp' => {
    'abw' => 2
  },
  'Rjng' => {
    'rej' => 2
  },
  'Lana' => {
    'nod' => 1
  },
  'Cprt' => {
    'grc' => 2
  },
  'Batk' => {
    'bbc' => 2
  },
  'Plrd' => {
    'hmd' => 1,
    'hmn' => 1
  },
  'Egyp' => {
    'egy' => 2
  },
  'Cyrl' => {
    'udm' => 1,
    'rom' => 2,
    'lbe' => 1,
    'kca' => 1,
    'nog' => 1,
    'lez' => 1,
    'mkd' => 1,
    'kjh' => 1,
    'tgk' => 1,
    'bub' => 1,
    'xal' => 1,
    'gld' => 1,
    'abk' => 1,
    'ron' => 2,
    'lfn' => 2,
    'tat' => 1,
    'tuk' => 1,
    'uig' => 1,
    'sel' => 2,
    'ttt' => 1,
    'kbd' => 1,
    'sme' => 2,
    'chm' => 1,
    'ckt' => 1,
    'tly' => 1,
    'hbs' => 1,
    'evn' => 1,
    'rus' => 1,
    'cjs' => 1,
    'mrj' => 1,
    'bel' => 1,
    'syr' => 1,
    'aii' => 1,
    'pnt' => 1,
    'kur' => 1,
    'sah' => 1,
    'ady' => 1,
    'ukr' => 1,
    'bos' => 1,
    'uzb' => 1,
    'crh' => 1,
    'inh' => 1,
    'rue' => 1,
    'gag' => 2,
    'alt' => 1,
    'che' => 1,
    'kom' => 1,
    'abq' => 1,
    'mdf' => 1,
    'kpy' => 1,
    'chv' => 1,
    'myv' => 1,
    'bak' => 1,
    'kkt' => 1,
    'mns' => 1,
    'ava' => 1,
    'dng' => 1,
    'oss' => 1,
    'tyv' => 1,
    'bul' => 1,
    'tab' => 1,
    'chu' => 2,
    'ude' => 1,
    'mon' => 1,
    'yrk' => 1,
    'kaz' => 1,
    'kir' => 1,
    'krc' => 1,
    'dar' => 1,
    'tkr' => 1,
    'srp' => 1,
    'kaa' => 1,
    'kum' => 1,
    'aze' => 1
  },
  'Java' => {
    'jav' => 2
  },
  'Sarb' => {
    'xsa' => 2
  },
  'Adlm' => {
    'ful' => 2
  },
  'Cari' => {
    'xcr' => 2
  },
  'Thai' => {
    'kxm' => 1,
    'tha' => 1,
    'kdt' => 1,
    'lcp' => 1,
    'sqq' => 1,
    'pli' => 2,
    'lwl' => 1,
    'tts' => 1
  },
  'Kore' => {
    'kor' => 1
  },
  'Ugar' => {
    'uga' => 2
  },
  'Lisu' => {
    'lis' => 1
  },
  'Gran' => {
    'san' => 2
  },
  'Jpan' => {
    'jpn' => 1
  },
  'Bamu' => {
    'bax' => 1
  },
  'Tibt' => {
    'tdg' => 2,
    'taj' => 2,
    'bft' => 2,
    'tsj' => 1,
    'dzo' => 1,
    'bod' => 1
  },
  'Tale' => {
    'tdd' => 1
  },
  'Buhd' => {
    'bku' => 2
  },
  'Hano' => {
    'hnn' => 2
  },
  'Mahj' => {
    'hin' => 2
  },
  'Palm' => {
    'arc' => 2
  },
  'Mroo' => {
    'mro' => 2
  },
  'Khmr' => {
    'khm' => 1
  },
  'Beng' => {
    'unr' => 1,
    'rkt' => 1,
    'ccp' => 1,
    'unx' => 1,
    'mni' => 1,
    'lus' => 1,
    'grt' => 1,
    'ben' => 1,
    'asm' => 1,
    'bpy' => 1,
    'syl' => 1,
    'sat' => 2,
    'kha' => 2
  },
  'Ogam' => {
    'sga' => 2
  },
  'Orkh' => {
    'otk' => 2
  },
  'Prti' => {
    'xpr' => 2
  },
  'Elba' => {
    'sqi' => 2
  },
  'Cans' => {
    'oji' => 1,
    'crm' => 1,
    'crl' => 1,
    'nsk' => 1,
    'crj' => 1,
    'csw' => 1,
    'crk' => 1,
    'chp' => 2,
    'cre' => 1,
    'den' => 2,
    'iku' => 1
  },
  'Geor' => {
    'lzz' => 1,
    'xmf' => 1,
    'kat' => 1
  },
  'Yiii' => {
    'iii' => 1
  },
  'Hani' => {
    'vie' => 2
  },
  'Knda' => {
    'kan' => 1,
    'tcy' => 1
  },
  'Sind' => {
    'snd' => 2
  },
  'Shrd' => {
    'san' => 2
  },
  'Ethi' => {
    'orm' => 2,
    'tig' => 1,
    'byn' => 1,
    'wal' => 1,
    'tir' => 1,
    'amh' => 1,
    'gez' => 2
  },
  'Armn' => {
    'hye' => 1
  },
  'Dsrt' => {
    'eng' => 2
  },
  'Linb' => {
    'grc' => 2
  },
  'Nkoo' => {
    'bam' => 1,
    'nqo' => 1,
    'man' => 1
  },
  'Sinh' => {
    'sin' => 1,
    'san' => 2,
    'pli' => 2
  },
  'Lepc' => {
    'lep' => 1
  },
  'Guru' => {
    'pan' => 1
  },
  'Osma' => {
    'som' => 2
  },
  'Kali' => {
    'eky' => 1,
    'kyu' => 1
  },
  'Mlym' => {
    'mal' => 1
  },
  'Limb' => {
    'lif' => 1
  },
  'Hant' => {
    'yue' => 1,
    'zho' => 1
  },
  'Grek' => {
    'pnt' => 1,
    'grc' => 2,
    'ell' => 1,
    'bgx' => 1,
    'tsd' => 1,
    'cop' => 2
  },
  'Copt' => {
    'cop' => 2
  },
  'Lina' => {
    'lab' => 2
  },
  'Bugi' => {
    'mdr' => 2,
    'mak' => 2,
    'bug' => 2
  },
  'Avst' => {
    'ave' => 2
  },
  'Bopo' => {
    'zho' => 2
  },
  'Khoj' => {
    'snd' => 2
  },
  'Goth' => {
    'got' => 2
  },
  'Cher' => {
    'chr' => 1
  },
  'Narb' => {
    'xna' => 2
  },
  'Hmng' => {
    'hmn' => 2
  },
  'Sidd' => {
    'san' => 2
  },
  'Laoo' => {
    'hnj' => 1,
    'kjg' => 1,
    'lao' => 1,
    'hmn' => 1
  },
  'Mani' => {
    'xmn' => 2
  },
  'Latn' => {
    'kua' => 1,
    'lat' => 2,
    'vic' => 1,
    'cad' => 1,
    'crj' => 2,
    'arp' => 1,
    'osa' => 2,
    'bug' => 1,
    'nap' => 1,
    'rgn' => 1,
    'kha' => 1,
    'hun' => 1,
    'ttt' => 1,
    'nno' => 1,
    'spa' => 1,
    'nov' => 2,
    'yua' => 1,
    'ace' => 1,
    'sma' => 1,
    'cch' => 1,
    'tpi' => 1,
    'lub' => 1,
    'nzi' => 1,
    'guz' => 1,
    'ctd' => 1,
    'swb' => 2,
    'pko' => 1,
    'glg' => 1,
    'fra' => 1,
    'mlg' => 1,
    'zag' => 1,
    'afr' => 1,
    'loz' => 1,
    'luy' => 1,
    'kln' => 1,
    'krj' => 1,
    'dtm' => 1,
    'fvr' => 1,
    'stq' => 1,
    'tsn' => 1,
    'cha' => 1,
    'nus' => 1,
    'iii' => 2,
    'dtp' => 1,
    'hsb' => 1,
    'bem' => 1,
    'rar' => 1,
    'lim' => 1,
    'gag' => 1,
    'bin' => 1,
    'yav' => 1,
    'agq' => 1,
    'saq' => 1,
    'sas' => 1,
    'ewo' => 1,
    'ven' => 1,
    'uli' => 1,
    'haw' => 1,
    'iku' => 1,
    'wbp' => 1,
    'izh' => 1,
    'mnu' => 1,
    'ett' => 2,
    'del' => 1,
    'nob' => 1,
    'ang' => 2,
    'run' => 1,
    'bas' => 1,
    'sli' => 1,
    'bal' => 2,
    'ybb' => 1,
    'sot' => 1,
    'jgo' => 1,
    'nhe' => 1,
    'cay' => 1,
    'pfl' => 1,
    'kck' => 1,
    'kea' => 1,
    'tah' => 1,
    'ind' => 1,
    'ibb' => 1,
    'nyn' => 1,
    'zul' => 1,
    'buc' => 1,
    'ext' => 1,
    'nia' => 1,
    'fud' => 1,
    'bre' => 1,
    'mxc' => 1,
    'aze' => 1,
    'lun' => 1,
    'ngl' => 1,
    'frr' => 1,
    'chk' => 1,
    'rej' => 1,
    'arg' => 1,
    'nau' => 1,
    'njo' => 1,
    'fuv' => 1,
    'mwk' => 1,
    'kut' => 1,
    'vun' => 1,
    'sid' => 1,
    'pdc' => 1,
    'hat' => 1,
    'ife' => 1,
    'tbw' => 1,
    'cym' => 1,
    'mus' => 1,
    'ffm' => 1,
    'tkl' => 1,
    'kab' => 1,
    'mro' => 1,
    'ksh' => 1,
    'bfd' => 1,
    'lol' => 1,
    'aro' => 1,
    'kur' => 1,
    'sco' => 1,
    'lbw' => 1,
    'zap' => 1,
    'rcf' => 1,
    'kaj' => 1,
    'vol' => 2,
    'chp' => 1,
    'cre' => 2,
    'bku' => 1,
    'eng' => 1,
    'aoz' => 1,
    'som' => 1,
    'frc' => 1,
    'puu' => 1,
    'kri' => 1,
    'kal' => 1,
    'aar' => 1,
    'gub' => 1,
    'sdc' => 1,
    'kdh' => 1,
    'swe' => 1,
    'akz' => 1,
    'moe' => 1,
    'sad' => 1,
    'fao' => 1,
    'bbj' => 1,
    'arw' => 2,
    'nds' => 1,
    'quc' => 1,
    'srb' => 1,
    'saf' => 1,
    'osc' => 2,
    'mic' => 1,
    'oji' => 2,
    'niu' => 1,
    'pdt' => 1,
    'men' => 1,
    'avk' => 2,
    'myx' => 1,
    'abr' => 1,
    'lag' => 1,
    'zmi' => 1,
    'cgg' => 1,
    'por' => 1,
    'jut' => 2,
    'bew' => 1,
    'kax' => 1,
    'rob' => 1,
    'hmn' => 1,
    'bvb' => 1,
    'bis' => 1,
    'mak' => 1,
    'ria' => 1,
    'frp' => 1,
    'dsb' => 1,
    'war' => 1,
    'slv' => 1,
    'sxn' => 1,
    'lui' => 2,
    'eus' => 1,
    'mlt' => 1,
    'ltg' => 1,
    'frm' => 2,
    'yrl' => 1,
    'rmf' => 1,
    'den' => 1,
    'smo' => 1,
    'mgy' => 1,
    'hau' => 1,
    'shr' => 1,
    'qug' => 1,
    'srd' => 1,
    'fro' => 2,
    'lam' => 1,
    'cor' => 1,
    'fuq' => 1,
    'ban' => 1,
    'seh' => 1,
    'ful' => 1,
    'mah' => 1,
    'krl' => 1,
    'fit' => 1,
    'gba' => 1,
    'kcg' => 1,
    'ssw' => 1,
    'ljp' => 1,
    'ron' => 1,
    'dak' => 1,
    'gla' => 1,
    'bjn' => 1,
    'wol' => 1,
    'fon' => 1,
    'rwk' => 1,
    'udm' => 2,
    'ebu' => 1,
    'zun' => 1,
    'mos' => 1,
    'bkm' => 1,
    'gos' => 1,
    'kgp' => 1,
    'nde' => 1,
    'ton' => 1,
    'srn' => 1,
    'lzz' => 1,
    'tru' => 1,
    'rap' => 1,
    'vro' => 1,
    'jav' => 1,
    'sly' => 1,
    'ikt' => 1,
    'vmf' => 1,
    'enm' => 2,
    'kin' => 1,
    'rtm' => 1,
    'rof' => 1,
    'pcm' => 1,
    'nnh' => 1,
    'ipk' => 1,
    'tsi' => 1,
    'crs' => 1,
    'jmc' => 1,
    'crl' => 2,
    'egl' => 1,
    'lit' => 1,
    'rng' => 1,
    'cho' => 1,
    'yor' => 1,
    'sga' => 2,
    'suk' => 1,
    'ale' => 1,
    'tog' => 1,
    'chn' => 2,
    'nij' => 1,
    'scs' => 1,
    'tly' => 1,
    'iba' => 1,
    'nso' => 1,
    'twq' => 1,
    'ksb' => 1,
    'naq' => 1,
    'mdt' => 1,
    'gle' => 1,
    'nxq' => 1,
    'rmu' => 1,
    'her' => 1,
    'tuk' => 1,
    'sbp' => 1,
    'sei' => 1,
    'fil' => 1,
    'bqv' => 1,
    'sus' => 1,
    'rmo' => 1,
    'kiu' => 1,
    'cos' => 1,
    'wae' => 1,
    'hop' => 1,
    'mdr' => 1,
    'dum' => 2,
    'ceb' => 1,
    'lut' => 2,
    'trv' => 1,
    'ain' => 2,
    'est' => 1,
    'mwv' => 1,
    'nbl' => 1,
    'tur' => 1,
    'bzx' => 1,
    'deu' => 1,
    'min' => 1,
    'bto' => 1,
    'csb' => 2,
    'bci' => 1,
    'umb' => 1,
    'cps' => 1,
    'bss' => 1,
    'laj' => 1,
    'ewe' => 1,
    'ttb' => 1,
    'byv' => 1,
    'kdx' => 1,
    'maz' => 1,
    'ita' => 1,
    'ttj' => 1,
    'see' => 1,
    'xum' => 2,
    'kos' => 1,
    'smn' => 1,
    'lmo' => 1,
    'mgo' => 1,
    'wls' => 1,
    'xho' => 1,
    'vie' => 1,
    'guc' => 1,
    'bam' => 1,
    'pms' => 1,
    'kvr' => 1,
    'swa' => 1,
    'lua' => 1,
    'fry' => 1,
    'smj' => 1,
    'jam' => 1,
    'ses' => 1,
    'mdh' => 1,
    'din' => 1,
    'bbc' => 1,
    'sgs' => 1,
    'mas' => 1,
    'hmo' => 1,
    'dje' => 1,
    'hil' => 1,
    'gmh' => 2,
    'hnn' => 1,
    'bik' => 1,
    'bez' => 1,
    'aka' => 1,
    'pcd' => 1,
    'efi' => 1,
    'mri' => 1,
    'ksf' => 1,
    'ina' => 2,
    'tgk' => 1,
    'sag' => 1,
    'rom' => 1,
    'hrv' => 1,
    'goh' => 2,
    'moh' => 1,
    'srp' => 1,
    'bmv' => 1,
    'kpe' => 1,
    'tet' => 1,
    'kfo' => 1,
    'cic' => 1,
    'kde' => 1,
    'nor' => 1,
    'was' => 1,
    'fan' => 1,
    'lav' => 1,
    'ada' => 1,
    'cat' => 1,
    'szl' => 1,
    'nya' => 1,
    'ter' => 1,
    'pol' => 1,
    'gqr' => 1,
    'bze' => 1,
    'inh' => 2,
    'mls' => 1,
    'car' => 1,
    'epo' => 1,
    'pnt' => 1,
    'chy' => 1,
    'swg' => 1,
    'orm' => 1,
    'lug' => 1,
    'scn' => 1,
    'aym' => 1,
    'msa' => 1,
    'hbs' => 1,
    'arn' => 1,
    'tiv' => 1,
    'esu' => 1,
    'grn' => 1,
    'dgr' => 1,
    'asa' => 1,
    'dyu' => 1,
    'mwl' => 1,
    'vec' => 1,
    'nld' => 1,
    'hup' => 1,
    'kik' => 1,
    'tzm' => 1,
    'fin' => 1,
    'kge' => 1,
    'vai' => 1,
    'brh' => 2,
    'nsk' => 2,
    'liv' => 2,
    'sqi' => 1,
    'eka' => 1,
    'yap' => 1,
    'bar' => 1,
    'dav' => 1,
    'luo' => 1,
    'sun' => 1,
    'dyo' => 1,
    'zza' => 1,
    'gur' => 1,
    'pag' => 1,
    'nav' => 1,
    'zea' => 1,
    'snk' => 1,
    'tkr' => 1,
    'khq' => 1,
    'ndc' => 1,
    'tli' => 1,
    'kir' => 1,
    'nyo' => 1,
    'rug' => 1,
    'amo' => 1,
    'lkt' => 1,
    'gil' => 1,
    'gay' => 1,
    'pau' => 1,
    'atj' => 1,
    'nhw' => 1,
    'frs' => 1,
    'ltz' => 1,
    'mfe' => 1,
    'oci' => 1,
    'nch' => 1,
    'srr' => 1,
    'dan' => 1,
    'syi' => 1,
    'ssy' => 1,
    'sms' => 1,
    'kon' => 1,
    'kac' => 1,
    'rif' => 1,
    'mgh' => 1,
    'lin' => 1,
    'vot' => 2,
    'gcr' => 1,
    'dnj' => 1,
    'dua' => 1,
    'gsw' => 1,
    'xav' => 1,
    'vep' => 1,
    'pap' => 1,
    'pmn' => 1,
    'xog' => 1,
    'wln' => 1,
    'rup' => 1,
    'tsg' => 1,
    'bmq' => 1,
    'sme' => 1,
    'tvl' => 1,
    'lij' => 1,
    'bla' => 1,
    'uig' => 2,
    'glv' => 1,
    'roh' => 1,
    'nym' => 1,
    'lfn' => 2,
    'tmh' => 1,
    'man' => 1,
    'que' => 1,
    'tso' => 1,
    'hin' => 2,
    'gwi' => 1,
    'ilo' => 1,
    'teo' => 1,
    'vmw' => 1,
    'kkj' => 1,
    'ibo' => 1,
    'ces' => 1,
    'mua' => 1,
    'ast' => 1,
    'kau' => 1,
    'ach' => 1,
    'pro' => 2,
    'fij' => 1,
    'vls' => 1,
    'yao' => 1,
    'sna' => 1,
    'ndo' => 1,
    'nmg' => 1,
    'sef' => 1,
    'hai' => 1,
    'maf' => 1,
    'pon' => 1,
    'isl' => 1,
    'kmb' => 1,
    'hif' => 1,
    'grb' => 1,
    'aln' => 1,
    'slk' => 1,
    'zha' => 1,
    'uzb' => 1,
    'bos' => 1,
    'tum' => 1,
    'prg' => 2,
    'kjg' => 2,
    'mad' => 1,
    'sat' => 2
  },
  'Deva' => {
    'raj' => 1,
    'dty' => 1,
    'bgc' => 1,
    'hin' => 1,
    'wbr' => 1,
    'unx' => 1,
    'gvr' => 1,
    'bhb' => 1,
    'kok' => 1,
    'doi' => 1,
    'lif' => 1,
    'bho' => 1,
    'mtr' => 1,
    'mwr' => 1,
    'srx' => 1,
    'jml' => 1,
    'mar' => 1,
    'mai' => 1,
    'tdh' => 1,
    'swv' => 1,
    'bap' => 1,
    'noe' => 1,
    'kas' => 1,
    'kfr' => 1,
    'hif' => 1,
    'brx' => 1,
    'gbm' => 1,
    'pli' => 2,
    'tkt' => 1,
    'rjs' => 1,
    'mag' => 1,
    'bra' => 1,
    'thl' => 1,
    'xnr' => 1,
    'thq' => 1,
    'wtm' => 1,
    'nep' => 1,
    'kru' => 1,
    'sat' => 2,
    'san' => 2,
    'bhi' => 1,
    'mgp' => 1,
    'xsr' => 1,
    'btv' => 1,
    'hne' => 1,
    'mrd' => 1,
    'sck' => 1,
    'unr' => 1,
    'bfy' => 1,
    'anp' => 1,
    'taj' => 1,
    'gon' => 1,
    'khn' => 1,
    'kfy' => 1,
    'thr' => 1,
    'new' => 1,
    'hoj' => 1,
    'snd' => 1,
    'bjj' => 1,
    'hoc' => 1,
    'tdg' => 1,
    'awa' => 1,
    'gom' => 1
  },
  'Tglg' => {
    'fil' => 2
  },
  'Osge' => {
    'osa' => 1
  },
  'Nbat' => {
    'arc' => 2
  },
  'Mand' => {
    'myz' => 2
  },
  'Ital' => {
    'ett' => 2,
    'osc' => 2,
    'xum' => 2
  },
  'Arab' => {
    'bal' => 1,
    'wni' => 1,
    'ttt' => 2,
    'skr' => 1,
    'bej' => 1,
    'luz' => 1,
    'kxp' => 1,
    'kas' => 1,
    'haz' => 1,
    'ars' => 1,
    'pan' => 1,
    'arq' => 1,
    'tly' => 1,
    'som' => 2,
    'lah' => 1,
    'shr' => 1,
    'hau' => 1,
    'msa' => 1,
    'sus' => 2,
    'swb' => 1,
    'wol' => 2,
    'doi' => 1,
    'tgk' => 1,
    'ind' => 2,
    'mzn' => 1,
    'cop' => 2,
    'dyo' => 2,
    'glk' => 1,
    'bft' => 1,
    'tuk' => 1,
    'raj' => 1,
    'cja' => 1,
    'uig' => 1,
    'zdj' => 1,
    'aeb' => 1,
    'brh' => 1,
    'gbz' => 1,
    'gju' => 1,
    'arz' => 1,
    'snd' => 1,
    'fas' => 1,
    'mfa' => 1,
    'lrc' => 1,
    'hno' => 1,
    'ara' => 1,
    'aze' => 1,
    'gjk' => 1,
    'bgn' => 1,
    'tur' => 2,
    'rmt' => 1,
    'bqi' => 1,
    'kaz' => 1,
    'kir' => 1,
    'pus' => 1,
    'sdh' => 1,
    'ary' => 1,
    'dcc' => 1,
    'lki' => 1,
    'fia' => 1,
    'hnd' => 1,
    'uzb' => 1,
    'urd' => 1,
    'kur' => 1,
    'mvy' => 1,
    'cjm' => 2,
    'kvx' => 1,
    'ckb' => 1,
    'inh' => 2,
    'prd' => 1,
    'khw' => 1
  },
  'Thaa' => {
    'div' => 1
  },
  'Mymr' => {
    'kht' => 1,
    'mya' => 1,
    'mnw' => 1,
    'shn' => 1
  },
  'Modi' => {
    'mar' => 2
  },
  'Telu' => {
    'wbq' => 1,
    'tel' => 1,
    'gon' => 1,
    'lmn' => 1
  },
  'Aghb' => {
    'lez' => 2
  },
  'Taml' => {
    'bfq' => 1,
    'tam' => 1
  },
  'Mong' => {
    'mnc' => 2,
    'mon' => 2
  },
  'Hans' => {
    'hak' => 1,
    'wuu' => 1,
    'hsn' => 1,
    'nan' => 1,
    'gan' => 1,
    'lzh' => 2,
    'zho' => 1,
    'yue' => 1,
    'zha' => 2
  },
  'Syrc' => {
    'ara' => 2,
    'aii' => 2,
    'syr' => 2,
    'tru' => 2
  },
  'Phag' => {
    'zho' => 2,
    'mon' => 2
  },
  'Phli' => {
    'abw' => 2
  },
  'Xsux' => {
    'akk' => 2,
    'hit' => 2
  },
  'Samr' => {
    'snx' => 2,
    'smp' => 2
  },
  'Cakm' => {
    'ccp' => 1
  },
  'Runr' => {
    'deu' => 2,
    'non' => 2
  }
};
$DefaultScript = {
  'arn' => 'Latn',
  'tiv' => 'Latn',
  'kxm' => 'Thai',
  'nqo' => 'Nkoo',
  'aym' => 'Latn',
  'lug' => 'Latn',
  'scn' => 'Latn',
  'swg' => 'Latn',
  'rkt' => 'Beng',
  'orm' => 'Latn',
  'hup' => 'Latn',
  'nld' => 'Latn',
  'vec' => 'Latn',
  'kxp' => 'Arab',
  'nan' => 'Hans',
  'mwl' => 'Latn',
  'asa' => 'Latn',
  'dyu' => 'Latn',
  'grn' => 'Latn',
  'dgr' => 'Latn',
  'esu' => 'Latn',
  'sqi' => 'Latn',
  'bub' => 'Cyrl',
  'eka' => 'Latn',
  'nsk' => 'Cans',
  'brh' => 'Arab',
  'shn' => 'Mymr',
  'fin' => 'Latn',
  'kge' => 'Latn',
  'zgh' => 'Tfng',
  'kik' => 'Latn',
  'dyo' => 'Latn',
  'sun' => 'Latn',
  'zza' => 'Latn',
  'lbe' => 'Cyrl',
  'luo' => 'Latn',
  'bhb' => 'Deva',
  'dav' => 'Latn',
  'bar' => 'Latn',
  'yap' => 'Latn',
  'ude' => 'Cyrl',
  'bgn' => 'Arab',
  'lkt' => 'Latn',
  'amo' => 'Latn',
  'rug' => 'Latn',
  'blt' => 'Tavt',
  'rmt' => 'Arab',
  'nyo' => 'Latn',
  'tli' => 'Latn',
  'khq' => 'Latn',
  'mrd' => 'Deva',
  'ndc' => 'Latn',
  'snk' => 'Latn',
  'hne' => 'Deva',
  'gur' => 'Latn',
  'pag' => 'Latn',
  'nav' => 'Latn',
  'zea' => 'Latn',
  'bak' => 'Cyrl',
  'pau' => 'Latn',
  'oss' => 'Cyrl',
  'gil' => 'Latn',
  'gay' => 'Latn',
  'tkt' => 'Deva',
  'lep' => 'Lepc',
  'srr' => 'Latn',
  'syi' => 'Latn',
  'dan' => 'Latn',
  'ell' => 'Grek',
  'oci' => 'Latn',
  'mfe' => 'Latn',
  'nch' => 'Latn',
  'ltz' => 'Latn',
  'mvy' => 'Arab',
  'frs' => 'Latn',
  'cjm' => 'Cham',
  'nhw' => 'Latn',
  'atj' => 'Latn',
  'vep' => 'Latn',
  'xav' => 'Latn',
  'kru' => 'Deva',
  'gsw' => 'Latn',
  'dnj' => 'Latn',
  'dua' => 'Latn',
  'xsr' => 'Deva',
  'gcr' => 'Latn',
  'sah' => 'Cyrl',
  'lin' => 'Latn',
  'bra' => 'Deva',
  'mgh' => 'Latn',
  'kac' => 'Latn',
  'ben' => 'Beng',
  'ssy' => 'Latn',
  'kon' => 'Latn',
  'sms' => 'Latn',
  'rup' => 'Latn',
  'wln' => 'Latn',
  'pmn' => 'Latn',
  'jml' => 'Deva',
  'xog' => 'Latn',
  'haz' => 'Arab',
  'pap' => 'Latn',
  'bej' => 'Arab',
  'sqq' => 'Thai',
  'bla' => 'Latn',
  'lij' => 'Latn',
  'kfr' => 'Deva',
  'tvl' => 'Latn',
  'sme' => 'Latn',
  'tts' => 'Thai',
  'tsg' => 'Latn',
  'bmq' => 'Latn',
  'tdh' => 'Deva',
  'hin' => 'Deva',
  'gwi' => 'Latn',
  'dty' => 'Deva',
  'que' => 'Latn',
  'tso' => 'Latn',
  'gld' => 'Cyrl',
  'gan' => 'Hans',
  'tmh' => 'Latn',
  'nym' => 'Latn',
  'roh' => 'Latn',
  'glv' => 'Latn',
  'mua' => 'Latn',
  'ces' => 'Latn',
  'ibo' => 'Latn',
  'nog' => 'Cyrl',
  'kkj' => 'Latn',
  'vmw' => 'Latn',
  'ilo' => 'Latn',
  'teo' => 'Latn',
  'vls' => 'Latn',
  'yao' => 'Latn',
  'bqi' => 'Arab',
  'krc' => 'Cyrl',
  'pus' => 'Arab',
  'fij' => 'Latn',
  'ach' => 'Latn',
  'kau' => 'Latn',
  'ast' => 'Latn',
  'nmg' => 'Latn',
  'kpy' => 'Cyrl',
  'sef' => 'Latn',
  'fas' => 'Arab',
  'ndo' => 'Latn',
  'gom' => 'Deva',
  'syl' => 'Beng',
  'sna' => 'Latn',
  'new' => 'Deva',
  'rjs' => 'Deva',
  'slk' => 'Latn',
  'grb' => 'Latn',
  'aln' => 'Latn',
  'che' => 'Cyrl',
  'kmb' => 'Latn',
  'ckb' => 'Arab',
  'hai' => 'Latn',
  'pon' => 'Latn',
  'isl' => 'Latn',
  'maf' => 'Latn',
  'mad' => 'Latn',
  'lcp' => 'Thai',
  'sat' => 'Olck',
  'mrj' => 'Cyrl',
  'kjg' => 'Laoo',
  'aii' => 'Cyrl',
  'crm' => 'Cans',
  'ary' => 'Arab',
  'tum' => 'Latn',
  'zha' => 'Latn',
  'scs' => 'Latn',
  'bgx' => 'Grek',
  'dzo' => 'Tibt',
  'nij' => 'Latn',
  'evn' => 'Cyrl',
  'ale' => 'Latn',
  'ars' => 'Arab',
  'tog' => 'Latn',
  'arq' => 'Arab',
  'her' => 'Latn',
  'nxq' => 'Latn',
  'rmu' => 'Latn',
  'gle' => 'Latn',
  'mdt' => 'Latn',
  'naq' => 'Latn',
  'mai' => 'Deva',
  'ksb' => 'Latn',
  'iba' => 'Latn',
  'nso' => 'Latn',
  'twq' => 'Latn',
  'xal' => 'Cyrl',
  'bqv' => 'Latn',
  'fil' => 'Latn',
  'sei' => 'Latn',
  'gbz' => 'Arab',
  'sbp' => 'Latn',
  'crk' => 'Cans',
  'cja' => 'Arab',
  'raj' => 'Deva',
  'hop' => 'Latn',
  'mdr' => 'Latn',
  'wae' => 'Latn',
  'bft' => 'Arab',
  'rmo' => 'Latn',
  'cos' => 'Latn',
  'kiu' => 'Latn',
  'sus' => 'Latn',
  'byn' => 'Ethi',
  'lwl' => 'Thai',
  'kjh' => 'Cyrl',
  'tur' => 'Latn',
  'wuu' => 'Hans',
  'bzx' => 'Latn',
  'nbl' => 'Latn',
  'hnj' => 'Laoo',
  'yrk' => 'Cyrl',
  'khn' => 'Deva',
  'mwv' => 'Latn',
  'taj' => 'Deva',
  'est' => 'Latn',
  'kaa' => 'Cyrl',
  'trv' => 'Latn',
  'ceb' => 'Latn',
  'hoc' => 'Deva',
  'chv' => 'Cyrl',
  'bci' => 'Latn',
  'bto' => 'Latn',
  'min' => 'Latn',
  'mns' => 'Cyrl',
  'tdg' => 'Deva',
  'bpy' => 'Beng',
  'thr' => 'Deva',
  'asm' => 'Beng',
  'deu' => 'Latn',
  'tab' => 'Cyrl',
  'mya' => 'Mymr',
  'kdx' => 'Latn',
  'byv' => 'Latn',
  'ttb' => 'Latn',
  'laj' => 'Latn',
  'ewe' => 'Latn',
  'bss' => 'Latn',
  'cps' => 'Latn',
  'umb' => 'Latn',
  'mgp' => 'Deva',
  'bhi' => 'Deva',
  'lis' => 'Lisu',
  'lmo' => 'Latn',
  'kos' => 'Latn',
  'smn' => 'Latn',
  'bel' => 'Cyrl',
  'see' => 'Latn',
  'dcc' => 'Arab',
  'ttj' => 'Latn',
  'ita' => 'Latn',
  'maz' => 'Latn',
  'wbq' => 'Telu',
  'pms' => 'Latn',
  'kvr' => 'Latn',
  'guc' => 'Latn',
  'vie' => 'Latn',
  'wls' => 'Latn',
  'xho' => 'Latn',
  'mgo' => 'Latn',
  'mdh' => 'Latn',
  'wni' => 'Arab',
  'din' => 'Latn',
  'ses' => 'Latn',
  'jam' => 'Latn',
  'bap' => 'Deva',
  'smj' => 'Latn',
  'fry' => 'Latn',
  'kat' => 'Geor',
  'lua' => 'Latn',
  'swa' => 'Latn',
  'bod' => 'Tibt',
  'ksf' => 'Latn',
  'efi' => 'Latn',
  'pcd' => 'Latn',
  'mri' => 'Latn',
  'aka' => 'Latn',
  'bez' => 'Latn',
  'tha' => 'Thai',
  'bik' => 'Latn',
  'hnn' => 'Latn',
  'hil' => 'Latn',
  'hmo' => 'Latn',
  'dje' => 'Latn',
  'mas' => 'Latn',
  'bbc' => 'Latn',
  'sgs' => 'Latn',
  'mal' => 'Mlym',
  'khb' => 'Talu',
  'sag' => 'Latn',
  'rom' => 'Latn',
  'jpn' => 'Jpan',
  'hrv' => 'Latn',
  'amh' => 'Ethi',
  'ryu' => 'Kana',
  'kde' => 'Latn',
  'tet' => 'Latn',
  'kfo' => 'Latn',
  'cic' => 'Latn',
  'div' => 'Thaa',
  'bmv' => 'Latn',
  'kpe' => 'Latn',
  'moh' => 'Latn',
  'cat' => 'Latn',
  'ada' => 'Latn',
  'lav' => 'Latn',
  'arz' => 'Arab',
  'fan' => 'Latn',
  'lad' => 'Hebr',
  'was' => 'Latn',
  'bul' => 'Cyrl',
  'wal' => 'Ethi',
  'bze' => 'Latn',
  'inh' => 'Cyrl',
  'mni' => 'Beng',
  'crh' => 'Cyrl',
  'gqr' => 'Latn',
  'pol' => 'Latn',
  'ter' => 'Latn',
  'abq' => 'Cyrl',
  'nya' => 'Latn',
  'szl' => 'Latn',
  'chy' => 'Latn',
  'epo' => 'Latn',
  'car' => 'Latn',
  'nep' => 'Deva',
  'mls' => 'Latn',
  'hnd' => 'Arab',
  'hmd' => 'Plrd',
  'frc' => 'Latn',
  'aoz' => 'Latn',
  'som' => 'Latn',
  'eng' => 'Latn',
  'guj' => 'Gujr',
  'bku' => 'Latn',
  'chp' => 'Latn',
  'mar' => 'Deva',
  'gub' => 'Latn',
  'aar' => 'Latn',
  'luz' => 'Arab',
  'kal' => 'Latn',
  'chm' => 'Cyrl',
  'kri' => 'Latn',
  'puu' => 'Latn',
  'quc' => 'Latn',
  'abk' => 'Cyrl',
  'bbj' => 'Latn',
  'nds' => 'Latn',
  'fao' => 'Latn',
  'sad' => 'Latn',
  'wbr' => 'Deva',
  'moe' => 'Latn',
  'akz' => 'Latn',
  'kdh' => 'Latn',
  'swe' => 'Latn',
  'sdc' => 'Latn',
  'mzn' => 'Arab',
  'niu' => 'Latn',
  'pdt' => 'Latn',
  'mic' => 'Latn',
  'glk' => 'Arab',
  'oji' => 'Cans',
  'mtr' => 'Deva',
  'saf' => 'Latn',
  'gvr' => 'Deva',
  'srb' => 'Latn',
  'por' => 'Latn',
  'cgg' => 'Latn',
  'lag' => 'Latn',
  'abr' => 'Latn',
  'zmi' => 'Latn',
  'tel' => 'Telu',
  'myx' => 'Latn',
  'kum' => 'Cyrl',
  'gjk' => 'Arab',
  'men' => 'Latn',
  'lrc' => 'Arab',
  'bjj' => 'Deva',
  'bvb' => 'Latn',
  'khm' => 'Khmr',
  'hno' => 'Arab',
  'ara' => 'Arab',
  'rob' => 'Latn',
  'hmn' => 'Latn',
  'tyv' => 'Cyrl',
  'bew' => 'Latn',
  'kax' => 'Latn',
  'frp' => 'Latn',
  'rue' => 'Cyrl',
  'dsb' => 'Latn',
  'ria' => 'Latn',
  'mak' => 'Latn',
  'alt' => 'Cyrl',
  'kvx' => 'Arab',
  'bis' => 'Latn',
  'cjs' => 'Cyrl',
  'ltg' => 'Latn',
  'urd' => 'Arab',
  'eus' => 'Latn',
  'lao' => 'Laoo',
  'mlt' => 'Latn',
  'slv' => 'Latn',
  'sxn' => 'Latn',
  'xnr' => 'Deva',
  'war' => 'Latn',
  'fia' => 'Arab',
  'mnw' => 'Mymr',
  'qug' => 'Latn',
  'smo' => 'Latn',
  'mgy' => 'Latn',
  'rus' => 'Cyrl',
  'den' => 'Latn',
  'yrl' => 'Latn',
  'eky' => 'Kali',
  'rmf' => 'Latn',
  'lmn' => 'Telu',
  'seh' => 'Latn',
  'ful' => 'Latn',
  'fuq' => 'Latn',
  'ban' => 'Latn',
  'noe' => 'Deva',
  'yid' => 'Hebr',
  'cor' => 'Latn',
  'ckt' => 'Cyrl',
  'lam' => 'Latn',
  'grt' => 'Beng',
  'srd' => 'Latn',
  'ljp' => 'Latn',
  'ron' => 'Latn',
  'dak' => 'Latn',
  'gla' => 'Latn',
  'kdt' => 'Thai',
  'aeb' => 'Arab',
  'kcg' => 'Latn',
  'ssw' => 'Latn',
  'ori' => 'Orya',
  'gba' => 'Latn',
  'fit' => 'Latn',
  'krl' => 'Latn',
  'mah' => 'Latn',
  'ebu' => 'Latn',
  'zun' => 'Latn',
  'udm' => 'Cyrl',
  'rwk' => 'Latn',
  'lez' => 'Cyrl',
  'tam' => 'Taml',
  'bfq' => 'Taml',
  'fon' => 'Latn',
  'doi' => 'Arab',
  'wol' => 'Latn',
  'kok' => 'Deva',
  'bjn' => 'Latn',
  'lus' => 'Beng',
  'rap' => 'Latn',
  'tdd' => 'Tale',
  'kfy' => 'Deva',
  'tru' => 'Latn',
  'sck' => 'Deva',
  'ton' => 'Latn',
  'jrb' => 'Hebr',
  'dar' => 'Cyrl',
  'srn' => 'Latn',
  'kgp' => 'Latn',
  'nde' => 'Latn',
  'gos' => 'Latn',
  'mos' => 'Latn',
  'bkm' => 'Latn',
  'kor' => 'Kore',
  'vmf' => 'Latn',
  'kkt' => 'Cyrl',
  'ikt' => 'Latn',
  'sly' => 'Latn',
  'ava' => 'Cyrl',
  'hoj' => 'Deva',
  'jav' => 'Latn',
  'vro' => 'Latn',
  'jmc' => 'Latn',
  'crl' => 'Cans',
  'egl' => 'Latn',
  'tsi' => 'Latn',
  'crs' => 'Latn',
  'ipk' => 'Latn',
  'pcm' => 'Latn',
  'nnh' => 'Latn',
  'rof' => 'Latn',
  'rtm' => 'Latn',
  'kin' => 'Latn',
  'suk' => 'Latn',
  'tir' => 'Ethi',
  'yor' => 'Latn',
  'cho' => 'Latn',
  'btv' => 'Deva',
  'rng' => 'Latn',
  'lit' => 'Latn',
  'thl' => 'Deva',
  'thq' => 'Deva',
  'osa' => 'Osge',
  'arp' => 'Latn',
  'crj' => 'Cans',
  'cad' => 'Latn',
  'vic' => 'Latn',
  'tsd' => 'Grek',
  'kua' => 'Latn',
  'kbd' => 'Cyrl',
  'spa' => 'Latn',
  'nno' => 'Latn',
  'kha' => 'Latn',
  'hun' => 'Latn',
  'nap' => 'Latn',
  'rgn' => 'Latn',
  'bug' => 'Latn',
  'jpr' => 'Hebr',
  'kan' => 'Knda',
  'hye' => 'Armn',
  'tpi' => 'Latn',
  'bgc' => 'Deva',
  'cch' => 'Latn',
  'ace' => 'Latn',
  'zdj' => 'Arab',
  'nod' => 'Lana',
  'sma' => 'Latn',
  'tcy' => 'Knda',
  'tat' => 'Cyrl',
  'yua' => 'Latn',
  'bho' => 'Deva',
  'loz' => 'Latn',
  'afr' => 'Latn',
  'luy' => 'Latn',
  'kca' => 'Cyrl',
  'zag' => 'Latn',
  'mlg' => 'Latn',
  'fra' => 'Latn',
  'glg' => 'Latn',
  'pko' => 'Latn',
  'nzi' => 'Latn',
  'guz' => 'Latn',
  'swb' => 'Arab',
  'ctd' => 'Latn',
  'lub' => 'Latn',
  'anp' => 'Deva',
  'stq' => 'Latn',
  'sdh' => 'Arab',
  'fvr' => 'Latn',
  'krj' => 'Latn',
  'dtm' => 'Latn',
  'bfy' => 'Deva',
  'kln' => 'Latn',
  'heb' => 'Hebr',
  'myv' => 'Cyrl',
  'hsb' => 'Latn',
  'awa' => 'Deva',
  'gju' => 'Arab',
  'dng' => 'Cyrl',
  'dtp' => 'Latn',
  'nus' => 'Latn',
  'iii' => 'Yiii',
  'tsn' => 'Latn',
  'cha' => 'Latn',
  'agq' => 'Latn',
  'prd' => 'Arab',
  'mag' => 'Deva',
  'xmf' => 'Geor',
  'yav' => 'Latn',
  'kyu' => 'Kali',
  'khw' => 'Arab',
  'gag' => 'Latn',
  'bin' => 'Latn',
  'lim' => 'Latn',
  'rar' => 'Latn',
  'bem' => 'Latn',
  'kom' => 'Cyrl',
  'brx' => 'Deva',
  'haw' => 'Latn',
  'uli' => 'Latn',
  'ven' => 'Latn',
  'ewo' => 'Latn',
  'sas' => 'Latn',
  'ady' => 'Cyrl',
  'ukr' => 'Cyrl',
  'saq' => 'Latn',
  'lki' => 'Arab',
  'nob' => 'Latn',
  'run' => 'Latn',
  'lah' => 'Arab',
  'del' => 'Latn',
  'sin' => 'Sinh',
  'csw' => 'Cans',
  'srx' => 'Deva',
  'mnu' => 'Latn',
  'izh' => 'Latn',
  'wbp' => 'Latn',
  'skr' => 'Arab',
  'swv' => 'Deva',
  'ybb' => 'Latn',
  'hak' => 'Hans',
  'sot' => 'Latn',
  'tig' => 'Ethi',
  'bal' => 'Arab',
  'sli' => 'Latn',
  'bas' => 'Latn',
  'kea' => 'Latn',
  'chr' => 'Cher',
  'tah' => 'Latn',
  'kck' => 'Latn',
  'hsn' => 'Hans',
  'pfl' => 'Latn',
  'saz' => 'Saur',
  'cay' => 'Latn',
  'jgo' => 'Latn',
  'nhe' => 'Latn',
  'tsj' => 'Tibt',
  'nia' => 'Latn',
  'mwr' => 'Deva',
  'ext' => 'Latn',
  'buc' => 'Latn',
  'nyn' => 'Latn',
  'zul' => 'Latn',
  'mkd' => 'Cyrl',
  'ibb' => 'Latn',
  'ind' => 'Latn',
  'fuv' => 'Latn',
  'njo' => 'Latn',
  'nau' => 'Latn',
  'arg' => 'Latn',
  'rej' => 'Latn',
  'mon' => 'Cyrl',
  'kht' => 'Mymr',
  'chk' => 'Latn',
  'lun' => 'Latn',
  'frr' => 'Latn',
  'ngl' => 'Latn',
  'fud' => 'Latn',
  'bre' => 'Latn',
  'mxc' => 'Latn',
  'mdf' => 'Cyrl',
  'pdc' => 'Latn',
  'ife' => 'Latn',
  'mfa' => 'Arab',
  'hat' => 'Latn',
  'tbw' => 'Latn',
  'sid' => 'Latn',
  'bax' => 'Bamu',
  'vun' => 'Latn',
  'kut' => 'Latn',
  'mwk' => 'Latn',
  'ksh' => 'Latn',
  'bfd' => 'Latn',
  'lol' => 'Latn',
  'mro' => 'Latn',
  'tkl' => 'Latn',
  'kab' => 'Latn',
  'ffm' => 'Latn',
  'mus' => 'Latn',
  'gbm' => 'Deva',
  'cym' => 'Latn',
  'rcf' => 'Latn',
  'kaj' => 'Latn',
  'zap' => 'Latn',
  'lbw' => 'Latn',
  'sco' => 'Latn',
  'aro' => 'Latn',
  'wtm' => 'Deva'
};
$DefaultTerritory = {
  'lit' => 'LT',
  'suk' => 'TZ',
  'tir' => 'ET',
  'gaa' => 'GH',
  'srp_Cyrl' => 'RS',
  'co' => 'FR',
  'yor' => 'NG',
  'mn_Mong' => 'CN',
  'rof' => 'TZ',
  'id' => 'ID',
  'fi' => 'FI',
  'kin' => 'RW',
  'jmc' => 'TZ',
  'ff_Adlm' => 'GN',
  'crs' => 'SC',
  'nnh' => 'CM',
  'pcm' => 'NG',
  'bm_Nkoo' => 'ML',
  'mr' => 'IN',
  'ikt' => 'CA',
  'ava' => 'RU',
  'hoj' => 'IN',
  'jav' => 'ID',
  'chu' => 'RU',
  'km' => 'KH',
  'kor' => 'KR',
  'vai_Latn' => 'LR',
  'vmf' => 'DE',
  'kkt' => 'RU',
  'sck' => 'IN',
  'ton' => 'TO',
  'iu_Latn' => 'CA',
  'srn' => 'SR',
  'nde' => 'ZW',
  'sc' => 'IT',
  'mos' => 'BF',
  'sun_Latn' => 'ID',
  'snf' => 'SN',
  'kaz' => 'KZ',
  'kfy' => 'IN',
  'ko' => 'KR',
  'rwk' => 'TZ',
  'tam' => 'IN',
  'lez' => 'RU',
  'fon' => 'BJ',
  'be' => 'BY',
  'doi' => 'IN',
  'wol' => 'SN',
  'bjn' => 'ID',
  'kok' => 'IN',
  'rw' => 'RW',
  'ebu' => 'KE',
  'udm' => 'RU',
  'mey' => 'SN',
  'vi' => 'VN',
  'mah' => 'MH',
  'ron' => 'RO',
  'ljp' => 'ID',
  'gla' => 'GB',
  'da' => 'DK',
  'aeb' => 'TN',
  'ssw' => 'ZA',
  'ori' => 'IN',
  'kcg' => 'NG',
  'yo' => 'NG',
  'gn' => 'PY',
  'cor' => 'GB',
  'mn' => 'MN',
  'srd' => 'IT',
  'ti' => 'ET',
  'kk' => 'KZ',
  'seh' => 'MZ',
  'dv' => 'MV',
  'fuq' => 'NE',
  'ban' => 'ID',
  'noe' => 'IN',
  'rus' => 'RU',
  'nb' => 'NO',
  'lmn' => 'IN',
  'ug' => 'CN',
  'nl' => 'NL',
  'shr' => 'MA',
  'an' => 'ES',
  'hau' => 'NG',
  'bg' => 'BG',
  'slv' => 'SI',
  'xnr' => 'IN',
  'war' => 'PH',
  'aa' => 'ET',
  'san' => 'IN',
  'urd' => 'PK',
  'ky' => 'KG',
  'lao' => 'LA',
  'eus' => 'ES',
  'mlt' => 'MT',
  'nr' => 'ZA',
  'mni_Mtei' => 'IN',
  'bis' => 'VU',
  'om' => 'ET',
  'sg' => 'CF',
  'dsb' => 'DE',
  'ga' => 'IE',
  'mak' => 'ID',
  'hi' => 'IN',
  'mt' => 'MT',
  'pan_Arab' => 'PK',
  'tyv' => 'RU',
  'bew' => 'ID',
  'se' => 'NO',
  'hin_Latn' => 'IN',
  'lrc' => 'IR',
  'bjj' => 'IN',
  'hno' => 'PK',
  'khm' => 'KH',
  'gv' => 'IM',
  'abr' => 'GH',
  'lag' => 'TZ',
  'tel' => 'IN',
  'myx' => 'UG',
  'kum' => 'RU',
  'men' => 'SL',
  'ss' => 'ZA',
  'por' => 'BR',
  'bs_Cyrl' => 'BA',
  'cgg' => 'UG',
  'cy' => 'GB',
  'ml' => 'IN',
  'mzn' => 'IR',
  'niu' => 'NU',
  'gl' => 'ES',
  'glk' => 'IR',
  'mtr' => 'IN',
  'sav' => 'SN',
  'ccp' => 'BD',
  'kdh' => 'SL',
  'swe' => 'SE',
  'nn' => 'NO',
  'uz_Cyrl' => 'UZ',
  'quc' => 'GT',
  'abk' => 'GE',
  'nds' => 'DE',
  'fao' => 'FO',
  'wbr' => 'IN',
  'kri' => 'SL',
  'aze_Arab' => 'IR',
  'wa' => 'BE',
  'aar' => 'ET',
  'luz' => 'IR',
  'kal' => 'GL',
  'kas' => 'IN',
  'guj' => 'IN',
  'bhk' => 'PH',
  'mar' => 'IN',
  'uzb_Latn' => 'UZ',
  'yue_Hans' => 'CN',
  'bos_Latn' => 'BA',
  'uz_Arab' => 'AF',
  'som' => 'SO',
  'eng' => 'US',
  'bs_Latn' => 'BA',
  'tnr' => 'SN',
  'sk' => 'SK',
  'rn' => 'BI',
  'wtm' => 'IN',
  'kaj' => 'NG',
  'rcf' => 'RE',
  'sco' => 'GB',
  'kur' => 'TR',
  'tkl' => 'TK',
  'kab' => 'DZ',
  'ffm' => 'ML',
  'mus' => 'US',
  'cym' => 'GB',
  'gbm' => 'IN',
  'ks_Arab' => 'IN',
  'ksh' => 'DE',
  'vun' => 'TZ',
  'mdf' => 'RU',
  'ife' => 'TG',
  'mfa' => 'TH',
  'hat' => 'HT',
  'sid' => 'ET',
  'so' => 'SO',
  'tr' => 'TR',
  'cu' => 'RU',
  'chk' => 'FM',
  'ngl' => 'MZ',
  'bre' => 'FR',
  'fud' => 'WF',
  'fuv' => 'NG',
  'nau' => 'NR',
  'et' => 'EE',
  'arg' => 'ES',
  'bos_Cyrl' => 'BA',
  'zho_Hans' => 'CN',
  'rej' => 'ID',
  'mon' => 'MN',
  'gon' => 'IN',
  'kas_Arab' => 'IN',
  'uzb_Cyrl' => 'UZ',
  'nyn' => 'UG',
  'zul' => 'ZA',
  'mkd' => 'MK',
  'ibb' => 'NG',
  'ind' => 'ID',
  'ps' => 'AF',
  'mwr' => 'IN',
  'buc' => 'YT',
  'ln' => 'CD',
  'el' => 'GR',
  'su_Latn' => 'ID',
  'jgo' => 'CM',
  'knf' => 'SN',
  'kea' => 'CV',
  'tah' => 'PF',
  'chr' => 'US',
  'hsn' => 'CN',
  'fr' => 'FR',
  'ku' => 'TR',
  'tig' => 'ER',
  'bas' => 'CM',
  'skr' => 'PK',
  'swv' => 'IN',
  'uz_Latn' => 'UZ',
  'os' => 'GE',
  'mi' => 'NZ',
  'hak' => 'CN',
  'sot' => 'ZA',
  'sat_Deva' => 'IN',
  'iu' => 'CA',
  'gez' => 'ET',
  'ha' => 'NG',
  'tn' => 'ZA',
  'mnu' => 'KE',
  'shr_Tfng' => 'MA',
  'iku' => 'CA',
  'wbp' => 'AU',
  'nob' => 'NO',
  'run' => 'BI',
  'lah' => 'PK',
  'sin' => 'LK',
  'qu' => 'PE',
  'lv' => 'LV',
  'ewo' => 'CM',
  'sas' => 'ID',
  'ady' => 'RU',
  'ukr' => 'UA',
  'saq' => 'KE',
  'ce' => 'RU',
  'haw' => 'US',
  'ven' => 'ZA',
  'syr' => 'IQ',
  'lt' => 'LT',
  'ta' => 'IN',
  'bem' => 'ZM',
  'kom' => 'RU',
  'brx' => 'IN',
  'ff_Latn' => 'SN',
  'agq' => 'CM',
  'cs' => 'CZ',
  'mag' => 'IN',
  'yav' => 'CM',
  'mon_Mong' => 'CN',
  'bin' => 'NG',
  'shi_Latn' => 'MA',
  'sq' => 'AL',
  'ha_Arab' => 'NG',
  'nus' => 'SS',
  'af' => 'ZA',
  'iii' => 'CN',
  'tsn' => 'ZA',
  'cha' => 'GU',
  'myv' => 'RU',
  'hsb' => 'DE',
  'hau_Arab' => 'NG',
  'awa' => 'IN',
  'bm' => 'ML',
  'tt' => 'RU',
  'kln' => 'KE',
  'heb' => 'IL',
  'fvr' => 'IT',
  'sdh' => 'IR',
  'sd_Arab' => 'PK',
  'srp_Latn' => 'RS',
  'hi_Latn' => 'IN',
  'guz' => 'KE',
  'swb' => 'YT',
  'lub' => 'CD',
  'bo' => 'CN',
  'afr' => 'ZA',
  'luy' => 'KE',
  'mlg' => 'MG',
  'glg' => 'ES',
  'fra' => 'FR',
  'tcy' => 'IN',
  'tat' => 'RU',
  'hr' => 'HR',
  'is' => 'IS',
  'bgc' => 'IN',
  'tpi' => 'PG',
  'cch' => 'NG',
  'ace' => 'ID',
  'nod' => 'TH',
  'zdj' => 'KM',
  'sma' => 'SE',
  'oc' => 'FR',
  'kan' => 'IN',
  'fa' => 'IR',
  'hye' => 'AM',
  'kbd' => 'RU',
  'uk' => 'UA',
  'spa' => 'ES',
  'nno' => 'NO',
  'kha' => 'IN',
  'hun' => 'HU',
  'lb' => 'LU',
  'bug' => 'ID',
  'kua' => 'NA',
  'lat' => 'VA',
  'snd_Arab' => 'PK',
  'bsc' => 'SN',
  'ig' => 'NG',
  'osa' => 'US',
  'en' => 'US',
  'cad' => 'US',
  'ary' => 'MA',
  'tum' => 'MW',
  'bos' => 'BA',
  'zha' => 'CN',
  'mad' => 'ID',
  'sat' => 'IN',
  'aze_Cyrl' => 'AZ',
  'hif' => 'FJ',
  'aln' => 'XK',
  'br' => 'FR',
  'che' => 'RU',
  'kmb' => 'AO',
  'sr_Cyrl' => 'RS',
  'ckb' => 'IQ',
  'pon' => 'FM',
  'isl' => 'IS',
  'slk' => 'SK',
  'ur' => 'PK',
  'mer' => 'KE',
  'sl' => 'SI',
  'sna' => 'ZW',
  'nmg' => 'CM',
  'sef' => 'CI',
  'fas' => 'IR',
  'ndo' => 'NA',
  'gom' => 'IN',
  'syl' => 'BD',
  'ach' => 'UG',
  'unr' => 'IN',
  'ast' => 'ES',
  'vls' => 'BE',
  'krc' => 'RU',
  'bqi' => 'IR',
  'fij' => 'FJ',
  'pus' => 'AF',
  'ful_Adlm' => 'GN',
  'kkj' => 'CM',
  'vmw' => 'MZ',
  'ilo' => 'PH',
  'teo' => 'UG',
  'mua' => 'CM',
  'fy' => 'NL',
  'ces' => 'CZ',
  'ibo' => 'NG',
  'mg' => 'MG',
  'sa' => 'IN',
  'xh' => 'ZA',
  'nym' => 'TZ',
  'bn' => 'BD',
  'roh' => 'CH',
  'uig' => 'CN',
  'glv' => 'IM',
  'hin' => 'IN',
  'que' => 'PE',
  'tso' => 'ZA',
  'gan' => 'CN',
  'tmh' => 'NE',
  'tts' => 'TH',
  'shi_Tfng' => 'MA',
  'tsg' => 'PH',
  'bej' => 'SD',
  'sqq' => 'TH',
  'ms' => 'MY',
  'sme' => 'NO',
  'tvl' => 'TV',
  'pmn' => 'PH',
  'xog' => 'UG',
  'as' => 'IN',
  'haz' => 'AF',
  'st' => 'ZA',
  'sv' => 'SE',
  'eng_Dsrt' => 'US',
  'wln' => 'BE',
  'zho_Hant' => 'TW',
  'sah' => 'RU',
  'lin' => 'CD',
  'rif' => 'MA',
  'mgh' => 'MZ',
  'ben' => 'BD',
  'fo' => 'FO',
  'sat_Olck' => 'IN',
  'ssy' => 'ER',
  'sms' => 'FI',
  'kon' => 'CD',
  'shr_Latn' => 'MA',
  'gsw' => 'CH',
  'kru' => 'IN',
  'dnj' => 'CI',
  'dua' => 'CM',
  'jv' => 'ID',
  'zu' => 'ZA',
  'gcr' => 'GF',
  'ltz' => 'LU',
  'srr' => 'SN',
  'kw' => 'GB',
  'ful_Latn' => 'SN',
  'dan' => 'DK',
  'ell' => 'GR',
  'ro' => 'RO',
  'oci' => 'FR',
  'mfe' => 'MU',
  'ms_Arab' => 'MY',
  'pau' => 'PW',
  'oss' => 'GE',
  'gil' => 'KI',
  'ba' => 'RU',
  'bak' => 'RU',
  'khq' => 'ML',
  'ndc' => 'MZ',
  'snk' => 'ML',
  'hne' => 'IN',
  'sn' => 'ZW',
  'de' => 'DE',
  'bam_Nkoo' => 'ML',
  'pag' => 'PH',
  'bgn' => 'PK',
  'mni_Beng' => 'IN',
  'lkt' => 'US',
  'ja' => 'JP',
  'kir' => 'KG',
  'blt' => 'VN',
  'rmt' => 'IR',
  'ne' => 'NP',
  'bhb' => 'IN',
  'dav' => 'KE',
  'hy' => 'AM',
  'bjt' => 'SN',
  'dyo' => 'SN',
  'sun' => 'ID',
  'zza' => 'TR',
  'dz' => 'BT',
  'lbe' => 'RU',
  'luo' => 'KE',
  'ki' => 'KE',
  'shn' => 'MM',
  'fin' => 'FI',
  'zgh' => 'MA',
  'tzm' => 'MA',
  'lo' => 'LA',
  'kik' => 'KE',
  'sqi' => 'AL',
  'gu' => 'IN',
  'brh' => 'PK',
  'az_Arab' => 'IR',
  'ii' => 'CN',
  'tk' => 'TM',
  'asa' => 'TZ',
  'dyu' => 'BF',
  'grn' => 'PY',
  'vai_Vaii' => 'LR',
  'nld' => 'NL',
  'nan' => 'CN',
  'zh_Hant' => 'TW',
  'az_Cyrl' => 'AZ',
  'lug' => 'UG',
  'scn' => 'IT',
  'orm' => 'ET',
  'kam' => 'KE',
  'to' => 'TO',
  'arn' => 'CL',
  'tiv' => 'NG',
  'rm' => 'CH',
  'msa' => 'MY',
  'kxm' => 'TH',
  'nqo' => 'GN',
  'aym' => 'BO',
  'nep' => 'NP',
  'ken' => 'CM',
  'it' => 'IT',
  'szl' => 'PL',
  'nya' => 'MW',
  'nd' => 'ZW',
  'inh' => 'RU',
  'mni' => 'IN',
  'gqr' => 'ID',
  'pol' => 'PL',
  'fan' => 'GQ',
  'arz' => 'EG',
  'ka' => 'GE',
  'mfv' => 'SN',
  'bul' => 'BG',
  'or' => 'IN',
  'wal' => 'ET',
  'cat' => 'ES',
  'lav' => 'LV',
  'hu' => 'HU',
  'msa_Arab' => 'MY',
  'en_Dsrt' => 'US',
  'div' => 'MV',
  'bmv' => 'CM',
  'kpe' => 'LR',
  'moh' => 'CA',
  'my' => 'MM',
  'ks_Deva' => 'IN',
  'kde' => 'TZ',
  'tet' => 'TL',
  'cic' => 'US',
  'tg' => 'TJ',
  'snd_Deva' => 'IN',
  'eu' => 'ES',
  'tgk' => 'TJ',
  'sag' => 'CF',
  'jpn' => 'JP',
  'hrv' => 'HR',
  've' => 'ZA',
  'az_Latn' => 'AZ',
  'amh' => 'ET',
  'hil' => 'PH',
  'hmo' => 'PG',
  'dje' => 'NE',
  'mas' => 'KE',
  'bbc' => 'ID',
  'mal' => 'IN',
  'bod' => 'CN',
  'ksf' => 'CM',
  'efi' => 'NG',
  'cv' => 'RU',
  'mri' => 'NZ',
  'aka' => 'GH',
  'bez' => 'TZ',
  'tha' => 'TH',
  'bik' => 'PH',
  'pan_Guru' => 'IN',
  'ts' => 'ZA',
  'lg' => 'UG',
  'smj' => 'SE',
  'fry' => 'NL',
  'kat' => 'GE',
  'lua' => 'CD',
  'swa' => 'TZ',
  'mdh' => 'PH',
  'wni' => 'KM',
  'ses' => 'ML',
  'jam' => 'JM',
  'ca' => 'ES',
  'kl' => 'GL',
  'vie' => 'VN',
  'wls' => 'WF',
  'xho' => 'ZA',
  'mgo' => 'CM',
  'wbq' => 'IN',
  'pa_Arab' => 'PK',
  'te' => 'IN',
  'bam' => 'ML',
  'dcc' => 'IN',
  'pa_Guru' => 'IN',
  'am' => 'ET',
  'iku_Latn' => 'CA',
  'he' => 'IL',
  'ita' => 'IT',
  'ny' => 'MW',
  'pt' => 'BR',
  'bhi' => 'IN',
  'wo' => 'SN',
  'kas_Deva' => 'IN',
  'smn' => 'FI',
  'bel' => 'BY',
  'sd_Deva' => 'IN',
  'bss' => 'CM',
  'umb' => 'AO',
  'kdx' => 'KE',
  'ttb' => 'GH',
  'laj' => 'UG',
  'ewe' => 'GH',
  'asm' => 'IN',
  'deu' => 'DE',
  'gd' => 'GB',
  'mya' => 'MM',
  'csb' => 'PL',
  'hoc' => 'IN',
  'chv' => 'RU',
  'bci' => 'CI',
  'sr_Latn' => 'RS',
  'min' => 'ID',
  'zh_Hans' => 'CN',
  'est' => 'EE',
  'trv' => 'TW',
  'ceb' => 'PH',
  'yue_Hant' => 'HK',
  'tur' => 'TR',
  'wuu' => 'CN',
  'si' => 'LK',
  'nbl' => 'ZA',
  'khn' => 'IN',
  'ru' => 'RU',
  'cos' => 'FR',
  'byn' => 'ER',
  'sus' => 'GN',
  'aze_Latn' => 'AZ',
  'fur' => 'IT',
  'ak' => 'GH',
  'wae' => 'CH',
  'th' => 'TH',
  'sbp' => 'TZ',
  'mk' => 'MK',
  'tuk' => 'TM',
  'raj' => 'IN',
  'uzb_Arab' => 'AF',
  'kn' => 'IN',
  'fil' => 'PH',
  'pl' => 'PL',
  'mai' => 'IN',
  'naq' => 'NA',
  'ksb' => 'TZ',
  'nso' => 'ZA',
  'twq' => 'NE',
  'ee' => 'GH',
  'gle' => 'IE',
  'dzo' => 'BT',
  'arq' => 'DZ',
  'lu' => 'CD',
  'sw' => 'TZ',
  'es' => 'ES'
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
	my $count = undef;
	if ($count = contains_script($s, $str, 1)){
	    $char{$$UnicodeScriptCode{$s}} = $count;
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
    print STDERR "unknown language $_[0]\n";
    return undef;
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
    print STDERR "unknown language $_[0]\n";
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
    print STDERR "unknown language $_[0]\n";
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


