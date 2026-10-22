# Encode and decode text

`naxp_encode()` encodes text as encoded values under a naxp, and
`naxp_decode()` decodes them back to the canonical form of the text.

## Usage

``` r
naxp_encode(text, naxp)

naxp_decode(x, naxp = NULL)
```

## Arguments

- text:

  A character vector.

- naxp:

  A naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), a
  pattern string or a
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector, whose naxp is used. For `naxp_decode()`, it is needed only
  where `x` is not a
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector.

- x:

  A [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector, or an integer or double vector of encoded values. Bare values
  must be whole numbers from 0 to the naxp's maximum encoded value, or
  `NA`.

## Value

- `naxp_encode()`: a
  [naxp_encoded](https://r-naxp.logmu.org/reference/naxp_encoded.md)
  vector the same length as `text`, with its names.

- `naxp_decode()`: a character vector the same length as `x`, with its
  names, holding `NA` where a value is 0 or `NA`.

## Details

Each text a naxp accepts encodes to a whole number from 1 to its maximum
encoded value. Several texts may share a value, such as a postcode
written with and without a space, and each value decodes to one
canonical form.

Text the naxp does not accept is invalid and encodes to 0, as in every
naxp library. So does `NA`, and so does any text that is not ASCII,
whatever its marked encoding. Encoded values are never `NA`.
`naxp_decode()` returns `NA` for 0, because no other string can stand
for it: a naxp may accept the empty string.

Encoded values are held as integers where the naxp's maximum encoded
value is at most 2^31 - 1, and as doubles where it is at most 2^53.
Above 2^53, which is the largest whole number R holds exactly, both
functions raise an error.

## See also

[`naxp_accepts()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
and
[`naxp_canonical_form()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
to check text without encoding it.

## Examples

``` r
postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

postcodes <- naxp_encode(c("1012AB", "1012 AB", "not a postcode"), postcode_naxp)
postcodes
#> <naxp_encoded[3]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB       1012 AB       <invalid (0)>
as.integer(postcodes)
#> [1] 684114 684114      0

naxp_decode(postcodes)
#> [1] "1012 AB" "1012 AB" NA       
naxp_decode(684114L, postcode_naxp)
#> [1] "1012 AB"
```
