# Recreate encoded vectors from underlying values

`naxp_encoded()` constructs a
[naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
vector from its underlying encoded values.

*This is a specialised operation – normal practice is to use
[`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md) to
construct a `naxp_encoded` vector **from text**.*

`naxp_encoded()` is exported so that encoded values previously extracted
using [`as.integer()`](https://rdrr.io/r/base/integer.html) or
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) and saved in a
database or a file can be restored.

## Usage

``` r
naxp_encoded(values, naxp)
```

## Arguments

- values:

  An `integer` or `double` vector of non-negative integers up to the
  naxp's maximum encoded value. `NA` is an error.

- naxp:

  A naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector, whose naxp is used.

## Value

A `naxp_encoded` vector the same length as `values`. If the elements of
`values` are named then the same names are applied to the elements of
the returned vector.

## Details

`values` must be non-negative integers up to the naxp's maximum encoded
value, stored as either `integer` or `double`. `NA` is an error, because
an encoded value is *never* `NA`: 0 means invalid text.

It is `naxp`, not the type of `values`, that decides how the values are
stored:

- `integer` if the naxp's maximum encoded value is less than \\2^{31}\\,
  or

- `double` if it is in the range \\2^{31}\\ to \\2^{53}\\.

If `naxp` has a maximum encoded value over \\2^{53}\\ then an error is
raised.

## See also

[`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md) to
create a `naxp_encoded` vector from text and a naxp.

[naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
for working with a `naxp_encoded` vector.

## Examples

``` r
postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

# Values saved earlier, such as a column read from a database
postcode_values <- c(684114L, 0L, 6760000L)

postcodes <- naxp_encoded(postcode_values, postcode_naxp)
postcodes
#> <naxp_encoded[3]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB       <invalid (0)> 9999 ZZ      
```
