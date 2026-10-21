# Changelog

## naxp 0.1.0

Initial CRAN release. It wraps the naxp C++ library 0.15.0.

- [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md)
  parses a naxp’s pattern, raising a `naxp_error` with the error’s code,
  message, offset and length where the pattern is invalid.
- [`naxp_standard()`](https://r-naxp.logmu.org/reference/naxp_standard.md)
  and
  [`naxp_standards()`](https://r-naxp.logmu.org/reference/naxp_standard.md)
  return the standard naxps built into every naxp library.
- [`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
  and
  [`naxp_decode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
  convert between text and encoded values. Invalid text encodes to `0`,
  never `NA`.
- [`naxp_accepts()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
  and
  [`naxp_canonical_form()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
  check text without encoding it.
- `naxp_encoded` vectors
  - retain their naxp as an attribute,
  - print as decoded text, with `0` shown as `<invalid (0)>`,
  - support `==` and `!=`, subsetting,
    [`c()`](https://rdrr.io/r/base/c.html),
    [`rep()`](https://rdrr.io/r/base/rep.html),
    [`unique()`](https://rdrr.io/r/base/unique.html),
    [`sort()`](https://rdrr.io/r/base/sort.html) and
    [`match()`](https://rdrr.io/r/base/match.html), and
  - can be used as columns in a data frame or tibble.
- [`naxp_encoded()`](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  creates a `naxp_encoded` vector from a numeric vector and a naxp.
- [`naxp_pattern()`](https://r-naxp.logmu.org/reference/naxp_properties.md),
  [`naxp_max_encoded_value()`](https://r-naxp.logmu.org/reference/naxp_properties.md)
  and
  [`naxp_max_length()`](https://r-naxp.logmu.org/reference/naxp_properties.md)
  report a naxp’s properties.
- Every function that takes a naxp parameter can instead take in its
  place
  - a naxp pattern string, parsed as a naxp, or
  - a `naxp_encoded` vector, whose naxp is used.
- [`naxp_compare()`](https://r-naxp.logmu.org/reference/naxp_compare.md)
  and
  [`naxp_first_divergent_value()`](https://r-naxp.logmu.org/reference/naxp_compare.md)
  compare two naxps.
- [`naxp_emit()`](https://r-naxp.logmu.org/reference/naxp_emit.md)
  generates source code for a naxp in any of the languages C, C++, C# or
  JavaScript.
