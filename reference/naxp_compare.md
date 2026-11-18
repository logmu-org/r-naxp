# Compare two naxps

`naxp_compare()` describes how naxp `b` relates to naxp `a`, i.e. what
happens to text and encoded values stored under `a` if `b` replaces it.

## Usage

``` r
naxp_compare(a, b, budget = NULL)

naxp_first_divergent_value(a, b)
```

## Arguments

- a:

  The naxp that the data was encoded with: a naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector, whose naxp is used.

- b:

  The naxp proposed to replace it, likewise.

- budget:

  `NULL` for the library's default budget of 200 000 product states, or
  a positive integer.

## Value

- `naxp_compare()`: a named character vector with elements
  `accepted_text`, `encoding` and `canonical_forms`.

- `naxp_first_divergent_value()`: a single encoded value, or 0 if every
  encoded value that both naxps define decodes to the same text. Encoded
  values that only one naxp defines do not count. It is an `integer` if
  both naxps store their encoded values as `integer`, and otherwise a
  `double`.

## Details

`naxp_first_divergent_value()` finds the lowest encoded value that the
two naxps decode differently.

`naxp_compare()` returns three set relationships, each from `a`'s point
of view:

- `accepted_text`: how the texts that `a` accepts relate to those that
  `b` accepts.

- `encoding`: how the (text, encoded value) pairs that `a` defines
  relate to those that `b` defines. Replacing `a` with `b` is safe for
  stored values if and only if this is `"equal"` or `"subset_of"`.

- `canonical_forms`: how the canonical forms that `a` prints relate to
  those that `b` prints.

Each relationship is one of `"equal"`, `"subset_of"`, `"superset_of"` or
`"incomparable"`.

The `encoding` relationship is decided by walking the two naxps
together, which has a budget. No naxp that anybody has reason to write
comes near the default budget. If a pair of naxps does exceed it, the
relationship cannot be decided, and `naxp_compare()` raises an error
rather than guess.

## Examples

``` r
must_have_space <- naxp_parse(r"(\9\9\9\9 \s \A\A)")
prefers_space <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
prefers_no_space <- naxp_parse(r"(\9\9\9\9 \s!? \A\A)")

naxp_compare(must_have_space, prefers_space)
#>   accepted_text        encoding canonical_forms 
#>     "subset_of"     "subset_of"         "equal" 

naxp_compare(must_have_space, prefers_no_space)
#>   accepted_text        encoding canonical_forms 
#>     "subset_of"     "subset_of"  "incomparable" 
naxp_first_divergent_value(must_have_space, prefers_no_space)
#> [1] 1
```
