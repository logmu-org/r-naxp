# Properties of a naxp

The pattern a naxp was parsed from, its largest encoded value and the
length of its longest canonical form.

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
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector, whose naxp is used.

## Value

- `naxp_pattern()`: a single string.

- `naxp_max_encoded_value()`: a single integer or double.

- `naxp_max_length()`: a single integer.

## Details

Encoded values run from 1 to the maximum with no gaps, so the maximum is
also the number of distinct encoded values. It is an integer where it is
at most 2^31 - 1 and a double where it is at most 2^53. Above 2^53,
which is the largest whole number R holds exactly,
`naxp_max_encoded_value()` raises an error, although printing the naxp
still shows the maximum.

## Examples

``` r
postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

naxp_pattern(postcode_naxp)
#> [1] "\\9\\9\\9\\9 \\s!! \\A\\A"
naxp_max_encoded_value(postcode_naxp)
#> [1] 6760000
naxp_max_length(postcode_naxp)
#> [1] 7

# An encoded vector stands for the naxp that encoded it
postcodes <- naxp_encode(c("1012AB", "9999 ZZ"), postcode_naxp)
naxp_pattern(postcodes)
#> [1] "\\9\\9\\9\\9 \\s!! \\A\\A"
```
