# naxp 0.0.0.9000

Initial version, wrapping the naxp C++ library 0.15.0.

- `naxp_parse()` parses a naxp's pattern, raising a `naxp_error` with the
  error's code, message, offset and length where the pattern is invalid.
- `naxp_standard()` and `naxp_standards()` give the standard naxps built into
  every naxp library.
- `naxp_encode()` and `naxp_decode()` convert between text and encoded values.
  Invalid text encodes to 0, never `NA`.
- `naxp_accepts()` and `naxp_canonical_form()` check text without encoding it.
- `naxp_encoded` vectors carry their naxp, print as text with 0 shown as
  `<invalid (0)>`, and support `==` and `!=`, subsetting, `c()`, `rep()`,
  `unique()`, `sort()`, `match()` and use as a data frame or tibble column.
  `naxp_encoded()` makes one from bare values.
- `naxp_pattern()`, `naxp_max_encoded_value()` and `naxp_max_length()` report
  a naxp's properties.
- Every function that takes a naxp also takes a pattern string, or a
  `naxp_encoded` vector, whose naxp it uses.
- `naxp_compare()` and `naxp_first_divergent_value()` compare two naxps.
- `naxp_emit()` writes a naxp as source code in C#, JavaScript, C or C++.
