# Encode and decode text

`naxp_encode()` encodes text using a naxp, and `naxp_decode()` decodes
the encoded values back to the canonical form of the text.

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
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector, whose naxp is used. For `naxp_decode()`, it is needed only if
  `x` is not a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector.

- x:

  A
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector, or an `integer` or `double` vector of underlying encoded
  values. Underlying encoded values must be non-negative integers up to
  the naxp's maximum encoded value, or `NA`.

## Value

- `naxp_encode()`: a
  [naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
  vector the same length as `text`. If the elements of `text` are named
  then the same names are applied to the elements of the returned
  vector.

- `naxp_decode()`: a character vector of the decoded text, the same
  length as `x`. Where a value is 0 or `NA`, the text is `NA`. If the
  elements of `x` are named then the same names are applied to the
  elements of the returned vector.

## Details

Each text that a naxp accepts is encoded as an integer from 1 to the
naxp's maximum encoded value. Several texts may share an encoded value
(for instance, a postcode written with and without a space), but each
encoded value decodes to exactly one canonical form.

## Invalid text

Text that the naxp does not accept is invalid and is encoded as 0, as in
every naxp library. The same applies to

- `NA`, and

- any text that is not ASCII, whatever its marked encoding.

Encoded values are *never* `NA`, although
[`is.na()`](https://rdrr.io/r/base/NA.html) reports 0 as missing in a
[naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
vector.

`naxp_decode()` returns `NA` for 0. No string can represent 0, because a
naxp may accept the empty string.

## Storage

Encoded values are stored as

- `integer` if the naxp's maximum encoded value is less than \\2^{31}\\,
  or

- `double` if it is in the range \\2^{31}\\ to \\2^{53}\\.

If the maximum encoded value is over \\2^{53}\\, both functions raise an
error, because a `double` cannot store every integer over \\2^{53}\\
exactly.

## See also

[`naxp_accepts()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
and
[`naxp_canonical_form()`](https://r-naxp.logmu.org/reference/naxp_accepts.md)
to check text without encoding it.

Use
[`naxp_encoded()`](https://r-naxp.logmu.org/reference/naxp_encoded.md)
to construct a
[naxp_encoded](https://r-naxp.logmu.org/reference/encoded-vectors.md)
vector from its underlying values (e.g. when reading encoded values from
a file or database).

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
