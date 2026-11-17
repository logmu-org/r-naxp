# Encoded values

A `naxp_encoded` vector holds encoded values together with the naxp that
encoded them, so it can always be decoded.
[`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
returns one, and `naxp_encoded()` makes one from bare values, such as
values read from a database or a file.

## Usage

``` r
naxp_encoded(values, naxp)
```

## Arguments

- values:

  An integer or double vector of whole numbers from 0 to the naxp's
  maximum encoded value. `NA` is an error.

- naxp:

  A naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a naxp_encoded vector, whose naxp is used.

## Value

A `naxp_encoded` vector the same length as `values`, with its names.

## Details

The values are integers where the naxp's maximum encoded value is at
most 2^31 - 1, and doubles where it is at most 2^53. Above 2^53 is an
error. 0 stands for text that is not valid. Encoded values are never
`NA`.

A `naxp_encoded` vector prints as the text it decodes to, with 0 shown
as `<invalid (0)>`.
[`as.character()`](https://rdrr.io/r/base/character.html) gives the
text, with `NA` for 0, and
[`as.integer()`](https://rdrr.io/r/base/integer.html) or
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) give the bare
values.

Subsetting, [`rep()`](https://rdrr.io/r/base/rep.html),
[`rev()`](https://rdrr.io/r/base/rev.html),
[`unique()`](https://rdrr.io/r/base/unique.html) and
[`sort()`](https://rdrr.io/r/base/sort.html) return `naxp_encoded`
vectors with the same naxp, and
[`split()`](https://rdrr.io/r/base/split.html) returns a list of them. A
`naxp_encoded` vector can be a data frame column.
[`order()`](https://rdrr.io/r/base/order.html) and
[`match()`](https://rdrr.io/r/base/match.html) return integer indices,
and [`table()`](https://rdrr.io/r/base/table.html) counts each distinct
value, labelled with its text, excluding 0. Assigning into a
`naxp_encoded` vector accepts another with the same naxp, or text, which
is encoded. [`c()`](https://rdrr.io/r/base/c.html) combines
`naxp_encoded` vectors with the same naxp.

Encoded values are compared only for equality. `==` and `!=` compare a
`naxp_encoded` vector with one with the same naxp, with text, which is
encoded first, or with numbers as bare values, so `x == 0` finds the
invalid text. Arithmetic, `<`, `>` and summaries such as
[`max()`](https://rdrr.io/r/base/Extremes.html) raise errors.
[`sort()`](https://rdrr.io/r/base/sort.html) and
[`order()`](https://rdrr.io/r/base/order.html) sort by encoded value.

## Examples

``` r
nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

codes <- naxp_encoded(c(684114, 0, 6760000), nl_postcode)
codes
#> <naxp_encoded[3]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB       <invalid (0)> 9999 ZZ      
codes == "1012 AB"
#> [1]  TRUE FALSE FALSE
codes == 0
#> [1] FALSE  TRUE FALSE

data.frame(postcode = codes)
#>        postcode
#> 1       1012 AB
#> 2 <invalid (0)>
#> 3       9999 ZZ
```
