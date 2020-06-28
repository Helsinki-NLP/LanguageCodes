
# LanguageCodes

Perl modules for working with language codes, language groups and language scripts.
Currently, there are 3 modules in this package:

* ISO::639::3 - conversion between ISO language codes
* ISO::639::5 - language groups and families according to ISO 639-5
* ISO::15924 - language scripts and their connection to languages


## ISO::639::3

A Perl modulino for retrieving and converting language codes from ISO 639.

### Overview

The module provides simple functions for retrieving language names and codes from the ISO-639 standards. The main
purpose is to convert between different variants of codes and to get the English names of languages from codes.
The module contains basic functions. There is no object-oriented interface. All functions can be exported.

```
use ISO::639::3 qw/:all/;

print convert_iso639( 'iso639-1', 'fra' );
print convert_iso639( 'iso639-3', 'de' );
print convert_iso639( 'name', 'fa' );

print get_iso639_1( 'deu' );
print get_iso639_3( 'de' );
print get_language_name( 'de' );
print get_language_name( 'eng' );
print get_macro_language( 'yue' );
```

The module can be run as a script:

```
perl ISO/639_3.pm [OPTIONS] LANGCODE*
```

This converts all language codes given as LANGCODE to corresponding language names. OPTIONS can be set to convert
between different variants of language codes or to convert from language names to codes. The same functionality is also available via the script `iso639` that is provided as executable in this package.


OPTIONS:

```
-2: convert to two-letter code (ISO 639-1)
-3: convert to three-letter code (ISO 639-3)
-m: convert to three-letter code but return the macro-language if available (ISO 639-3)
-n: don't print a final new line
```


### Subroutines


* `$converted = convert_iso639( $type, $id )`: 

Convert the language code or language name given in $id. The $type specifies the output type that is generated.
Possible types are "iso639-1" (two-letter code), "iso639-3" (three-letter-code), "macro" (three-letter code of the
corresponding macro language) or "name" (language name). Default is to return the language name. Regional codes
are stripped from the input language ID.


* `$iso639_1 = get_iso639_1( $id )`

Return the ISO 639-1 code for a given language or three-letter code. Returns the same code if it is a ISO 639-1
code or 'xx' if it is not recognized.


* `$iso639_3 = get_iso639_3( $id )`

Return the ISO 639-3 code for a given language or any ISO 639 code. Returns 'xxx' if the code is not recognized.


* `$macro_language = get_macro_language( $id )`

Return the ISO 639-3 code of the macro language for a given language or any ISO 639 code. Returns 'xxx' if the
code is not recognized.


* `$language = get_language_name( $id )`

Return the name of the language that corresponds to the given language code (any ISO639 code)

### ACKNOWLEDGEMENTS

The language codes are taken from SIL International <https://iso639-3.sil.org>. Please, check the terms of use
listed at <https://iso639-3.sil.org/code_tables/download_tables>. The current version uses the UTF-8 tables
distributed in "iso-639-3_Code_Tables_20200130.zip" from that website. This module adds some non-standard codes
that are not specified in the original tables to be compatible with some ad-hoc solutions in some resources and




## ISO::639::5

This module provides the definitions of language groups according to ISO 639-5. It allows to retrieve the languages inside of a group and the parent in the language tree for any given language supported by the standard.

```
use ISO::639::5 qw/:all/;

print join(' ',language_group('gmw'));
print join(' ',language_group('gem'));
print join(' ',language_group_children('gem'));
print language_parent('afr');
print language_parent('gmw');
```

### Executable script

The package provides the tool `langgroup` that can be used to retrieve languages in a given language group or group languages according to language groups. Look at the man-page of the tool for more information.



## ISO::15924

This module provides language scripts and territories

```
use ISO::15924 qw/:all/;

$script  = script_of_string('То је моја мачка.', 'srp');
$script  = script_of_string('你是我妈妈。');
%scripts = script_of_string('То је моја мачка. Ti si moja majka.');

$region = &default_territory('por')
$script = &default_script('tur')
```

### Executable script

The package provides the tool `langscript` that can be used to detect the script for a given string based on Unicode script patterns. A language can be given to narrow down the search. Look at the man-pages for more information.



### License and Copyright

This software is Copyright (c) 2020 by Joerg Tiedemann.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
