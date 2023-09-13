
use lib 'ISO-639-3/lib';
use ISO::639::3 qw/:all/;
use ISO::15924 qw/:all/;





print join(' ',default_script('deu')),"\n";
print join(' ',language_scripts('srp')),"\n";
print join(' ',language_scripts('srb')),"\n";
print join(' ',default_script('srb')),"\n";
print join(' ',language_scripts('zho')),"\n";
print join(' ',languages_with_script('Latn')),"\n";
print join(' ',languages_with_script('Arabic')),"\n";
print join(' ',language_territories('hbs')),"\n";
print join(' ',language_territories('hrv')),"\n";

print join(' ',primary_territories('hrv')),"\n";
print join(' ',secondary_territories('hrv')),"\n";
print default_territory('hrv'),"\n";

print join(' ',primary_languages_with_script('Latn')),"\n";
print join(' ',secondary_languages_with_script('Latn')),"\n";



print convert_iso639( 'iso639-1', 'fra' ),"\n";
print convert_iso639( 'iso639-1', 'English' ),"\n";
print convert_iso639( 'iso639-3', 'de' ),"\n";
print convert_iso639( 'name', 'fa' ),"\n";

print get_iso639_1( 'deu' ),"\n";
print get_iso639_1( 'English' ),"\n";
print get_iso639_3( 'de' ),"\n";
print get_language_name( 'de' ),"\n";
print get_language_name( 'eng' ),"\n";
print get_macro_language( 'yue' ),"\n";

