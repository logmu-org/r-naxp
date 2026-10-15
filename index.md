Implements naxp, the standard encoding of ASCII text as unsigned
integers \<<https://naxp.org/spec/>\>. A naxp is written in a syntax
like that of regular expressions. It encodes each text it accepts, such
as a postcode, as an integer from 1 to a fixed maximum, and decodes each
integer back to a canonical form of the text. Wraps the naxp 'C++'
library.
