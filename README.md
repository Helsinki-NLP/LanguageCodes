
# ISO639

A Perl modulino for retrieving and converting language codes from ISO 639.

## Overview

The module provides simple functions for retrieving language names and codes from the ISO-639 standards. The main
purpose is to convert between different variants of codes and to get the English names of languages from codes.
The module contains basic functions. There is no object-oriented interface. All functions can be exported.

```
use ISO::639_3 qw/:all/;

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
between different variants of language codes or to convert from language names to codes.

OPTIONS:

```
-2: convert to two-letter code (ISO 639-1)
-3: convert to three-letter code (ISO 639-3)
-m: convert to three-letter code but return the macro-language if available (ISO 639-3)
-n: don't print a final new line
```


## Subroutines


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


## ACKNOWLEDGEMENTS

The language codes are taken from SIL International <https://iso639-3.sil.org>. Please, check the terms of use
listed at <https://iso639-3.sil.org/code_tables/download_tables>. The current version uses the UTF-8 tables
distributed in "iso-639-3_Code_Tables_20200130.zip" from that website. This module adds some non-standard codes
that are not specified in the original tables to be compatible with some ad-hoc solutions in some resources and



## License and Copyright

This software is Copyright (c) 2020 by Joerg Tiedemann.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
