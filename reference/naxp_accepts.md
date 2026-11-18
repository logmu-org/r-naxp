# Check text against a naxp

`naxp_accepts()` tests whether a naxp accepts each text, and
`naxp_canonical_form()` returns the canonical form that each accepted
text decodes to.

## Usage

``` r
naxp_accepts(text, naxp)

naxp_canonical_form(text, naxp)
```

## Arguments

- text:

  A character vector.

- naxp:

  A naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector, whose naxp is used. For
  [`naxp_decode()`](https://r-naxp.logmu.org/reference/naxp_encode.md),
  it is needed only if `x` is not a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector.

## Value

- `naxp_accepts()`: a logical vector the same length as `text`. It is
  `FALSE`, never `NA`, for `NA` and for invalid text. If the elements of
  `text` are named then the same names are applied to the elements of
  the returned vector.

- `naxp_canonical_form()`: a character vector the same length as `text`.
  Where `text` is `NA` or invalid, the canonical form is `NA`. If the
  elements of `text` are named then the same names are applied to the
  elements of the returned vector.

## Details

Neither function needs the text's encoded value, so both work for a naxp
of any size, including one whose maximum encoded value is over
\\2^{53}\\.

## Examples

``` r
postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

naxp_accepts(c("1012AB", "1012 AB", "1012-AB"), postcode_naxp)
#> [1]  TRUE  TRUE FALSE
naxp_canonical_form(c("1012AB", "1012 AB", "1012-AB"), postcode_naxp)
#> [1] "1012 AB" "1012 AB" NA       
```
