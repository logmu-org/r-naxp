# Changelog

## naxp 0.0.0.9000

Initial version, wrapping the naxp C++ library 0.15.0.

- [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md)
  parses a naxp’s pattern, raising a `naxp_error` with the error’s code,
  message, offset and length where the pattern is invalid.
- [`naxp_standard()`](https://r-naxp.logmu.org/reference/naxp_standard.md)
  and
  [`naxp_standards()`](https://r-naxp.logmu.org/reference/naxp_standard.md)
  give the standard naxps built into every naxp library.
- [`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
  and
  [`naxp_decode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
  convert between text and encoded values. Invalid text encodes to 0,
  never `NA`.
- [`naxp_accepts()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
  and
  [`naxp_canonical_form()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
  check text without encoding it.
- `naxp_encoded` vectors carry their naxp, print as text with 0 shown as
  `<invalid (0)>`, and support `==` and `!=`, subsetting,
  [`c()`](https://rdrr.io/r/base/c.html),
  [`rep()`](https://rdrr.io/r/base/rep.html),
  [`unique()`](https://rdrr.io/r/base/unique.html),
  [`sort()`](https://rdrr.io/r/base/sort.html),
  [`match()`](https://rdrr.io/r/base/match.html) and use as a data frame
  or tibble column.
  [`naxp_encoded()`](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  makes one from bare values.
- [`naxp_pattern()`](https://r-naxp.logmu.org/reference/naxp_properties.md),
  [`naxp_max_encoded_value()`](https://r-naxp.logmu.org/reference/naxp_properties.md)
  and
  [`naxp_max_length()`](https://r-naxp.logmu.org/reference/naxp_properties.md)
  report a naxp’s properties.
- Every function that takes a naxp also takes a pattern string, or a
  `naxp_encoded` vector, whose naxp it uses.
- [`naxp_compare()`](https://r-naxp.logmu.org/reference/naxp_compare.md)
  and
  [`naxp_first_divergent_value()`](https://r-naxp.logmu.org/reference/naxp_compare.md)
  compare two naxps.
- [`naxp_emit()`](https://r-naxp.logmu.org/reference/naxp_emit.md)
  writes a naxp as source code in C#, JavaScript, C or C++.
