# naxp 0.2.0

- `is.na()` and `anyNA()` report an encoded value of `0` as missing in a
  `naxp_encoded` vector. The stored value is still `0`, so `as.numeric()`,
  `complete.cases()` and functions built on vctrs, such as `tidyr::drop_na()`,
  still see `0`.
- Assigning `NA` into a `naxp_encoded` vector stores `0`, so `x[i] <- NA` and
  `is.na(x) <- i` work.
- Indexing a `naxp_encoded` vector out of range or with `NA` gives `0`, not
  `NA`.

# naxp 0.1.0

Initial CRAN release. It wraps the naxp C++ library 0.15.0.

- `naxp_parse()` parses a naxp's pattern, raising a `naxp_error` with the
  error's code, message, offset and length where the pattern is invalid.
- `naxp_standard()` and `naxp_standards()` return the standard naxps built into
  every naxp library.
- `naxp_encode()` and `naxp_decode()` convert between text and encoded values.
  Invalid text encodes to `0`, never `NA`.
- `naxp_accepts()` and `naxp_canonical_form()` check text without encoding it.
- `naxp_encoded` vectors
    - retain their naxp as an attribute,
    - print as decoded text, with `0` shown as `<invalid (0)>`,
    - support `==` and `!=`, subsetting, `c()`, `rep()`, `unique()`,
      `sort()` and `match()`, and
    - can be used as columns in a data frame or tibble.
- `naxp_encoded()` creates a `naxp_encoded` vector from a numeric vector and
  a naxp.
- `naxp_pattern()`, `naxp_max_encoded_value()` and `naxp_max_length()` report
  a naxp's properties.
- Every function that takes a naxp parameter can instead take in its place
    - a naxp pattern string, parsed as a naxp, or
    - a `naxp_encoded` vector, whose naxp is used.
- `naxp_compare()` and `naxp_first_divergent_value()` compare two naxps.
- `naxp_emit()` generates source code for a naxp in any of the languages
  C, C++, C# or JavaScript.
