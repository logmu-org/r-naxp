# Check text against a naxp

`naxp_accepts()` says whether a naxp accepts each text, and
`naxp_canonical_form()` gives the form each accepted text decodes to.

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
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector, whose naxp is used. For
  [`naxp_decode()`](https://r-naxp.logmu.org/reference/naxp_encode.md),
  it is needed only where `x` is not a
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector.

## Value

- `naxp_accepts()`: a logical vector the same length as `text`, with its
  names. It is `FALSE`, never `NA`, for `NA` and for invalid text.

- `naxp_canonical_form()`: a character vector the same length as `text`,
  with its names, holding `NA` for `NA` and for invalid text.

## Details

Neither needs the text's encoded value, so both work for a naxp of any
size.

## Examples

``` r
nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

naxp_accepts(c("1012AB", "1012 AB", "1012-AB"), nl_postcode)
#> [1]  TRUE  TRUE FALSE
naxp_canonical_form(c("1012AB", "1012 AB", "1012-AB"), nl_postcode)
#> [1] "1012 AB" "1012 AB" NA       
```
