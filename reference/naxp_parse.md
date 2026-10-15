# Parse a naxp

Parses the pattern of a naxp, checking that it is valid, and returns a
naxp for the other functions in the package.

## Usage

``` r
naxp_parse(pattern)
```

## Arguments

- pattern:

  A single string: the pattern of the naxp.

## Value

A naxp: an object of class `naxp` holding the pattern.

## Details

A naxp holds only its pattern. The compiled naxp is kept for the rest of
the session, so parsing the same pattern again is cheap, and a naxp
saved with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) or sent to
a parallel worker is compiled again when first used.

Every function that takes a naxp also accepts a pattern string, which it
parses in the same way.

## Errors

An invalid pattern raises a condition of class `naxp_error`, which is
also an `error`. Its fields are named as in the other naxp libraries:

- `code`: the error code, such as `"NAXP1025"`, which is the same in
  every version.

- `message`: what is wrong, and where practical what to write instead.

- `offset`: where the error starts, in characters from the start of the
  pattern, counting from 0 as the other naxp libraries do.

- `length`: how many characters the error covers.

- `pattern`: the pattern.

Each error code is explained at <https://naxp.org/error-codes/>.

## See also

[`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md) to
encode text, and
[`naxp_pattern()`](https://r-naxp.logmu.org/reference/naxp_properties.md)
for a naxp's properties.

## Examples

``` r
nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
nl_postcode
#> <naxp> \9\9\9\9 \s!! \A\A
#> Maximum encoded value: 6760000

# An invalid pattern raises a naxp_error
tryCatch(
  naxp_parse(r"(\9\9\9\9 [A-)"),
  naxp_error = function(error) error$code
)
#> [1] "NAXP1025"
```
