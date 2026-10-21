# naxp: Encoded ASCII Expressions

Converts alphanumeric codes such as postcodes to whole numbers and back
again, following the 'naxp' standard <https://naxp.org/spec/>. A naxp
('encoded ASCII expression') is a pattern, defined using a similar
syntax to regular expressions, that maps each text it accepts to a
number from 1 to a fixed maximum, and any other text to 0. The same
pattern maps text to numbers identically across all 'naxp' libraries in
all languages on all platforms (subject only to the availability of
types able to store large enough integers). Standard naxps are defined
for common code systems and are built into all 'naxp' libraries. Two
naxps can be compared to determine, among other things, whether stored
values keep their meaning when one replaces the other. Wraps the 'naxp'
'C++' library <https://naxp.org/api/#cpp>.

## See also

Useful links:

- <https://naxp.org/>

- <https://github.com/logmu-org/r-naxp>

- <https://r-naxp.logmu.org/>

- Report bugs at <https://github.com/logmu-org/r-naxp/issues>

## Author

**Maintainer**: Tim Gordon <tim.gordon@btinternet.com>
([ORCID](https://orcid.org/0009-0006-3087-4384))

Authors:

- Tim Gordon <tim.gordon@btinternet.com>
  ([ORCID](https://orcid.org/0009-0006-3087-4384))
