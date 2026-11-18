# Properties of a naxp

Get the pattern that a naxp was parsed from, its maximum encoded value
and the length of its longest canonical form.

## Usage

``` r
naxp_pattern(naxp)

naxp_max_encoded_value(naxp)

naxp_max_length(naxp)
```

## Arguments

- naxp:

  A naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector, whose naxp is used.

## Value

- `naxp_pattern()`: a single string.

- `naxp_max_encoded_value()`: a single `integer` or `double`.

- `naxp_max_length()`: a single integer.

## Details

Encoded values run from 1 to the maximum encoded value with no gaps,
which means that the maximum is also the number of distinct non-zero
encoded values.

`naxp_max_encoded_value()` returns

- an `integer` if the maximum is less than \\2^{31}\\, or

- a `double` if it is in the range \\2^{31}\\ to \\2^{53}\\.

If the maximum is over \\2^{53}\\, `naxp_max_encoded_value()` raises an
error, because a `double` cannot store every integer over \\2^{53}\\
exactly. Printing the naxp still shows the maximum.

## Examples

``` r
postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

naxp_pattern(postcode_naxp)
#> [1] "\\9\\9\\9\\9 \\s!! \\A\\A"
naxp_max_encoded_value(postcode_naxp)
#> [1] 6760000
naxp_max_length(postcode_naxp)
#> [1] 7

# An encoded vector can be used in place of the naxp that encoded it
postcodes <- naxp_encode(c("1012AB", "9999 ZZ"), postcode_naxp)
naxp_pattern(postcodes)
#> [1] "\\9\\9\\9\\9 \\s!! \\A\\A"
```
