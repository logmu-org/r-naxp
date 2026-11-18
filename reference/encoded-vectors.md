# Encoded vectors

A `naxp_encoded` vector comprises the encoded values plus, as an
attribute, the naxp that encoded them, which means it can always be
decoded back to (canonical) text.

Use [`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
to create a `naxp_encoded` vector from a vector of text and a naxp.

## Storage

The storage type used for the encoded values depends on the naxp's
maximum encoded value as follows:

- less than \\2^{31}\\ is `integer`,

- \\2^{31}\\ to \\2^{53}\\ is `double`, and

- more than \\2^{53}\\ raises an error (when a function that needs
  encoded values, such as
  [`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md),
  is called, *not* when a `naxp` is created).

Invalid text is *always* stored as `0`, never `NA`.

## Missing values

[`is.na()`](https://rdrr.io/r/base/NA.html) and
[`anyNA()`](https://rdrr.io/r/base/NA.html) treat an encoded value of 0
as missing, which ensures that the encoded values of invalid text and
`NA` text are both treated as missing. In particular, `is.na(x)` matches
`is.na(naxp_decode(x))` and
[`na.omit()`](https://rdrr.io/r/stats/na.fail.html) drops missing
values.

Beware that code that reads the stored values directly will *not* treat
the 0 as missing. For instance,
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) passes 0 through
unchanged, and
[`complete.cases()`](https://rdrr.io/r/stats/complete.cases.html) and
functions built on vctrs, such as `tidyr::drop_na()` and
`dplyr::coalesce()`, treat 0 as present.

## Printing and conversion

A `naxp_encoded` vector prints as its canonical text, with 0 shown as
`<invalid (0)>`.
[`as.character()`](https://rdrr.io/r/base/character.html) produces the
text, with `NA` for 0.

Use [`as.integer()`](https://rdrr.io/r/base/integer.html) or
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) to obtain the
underlying encoded values.

## Subsetting, assignment and combining

Subsetting, [`rep()`](https://rdrr.io/r/base/rep.html),
[`rev()`](https://rdrr.io/r/base/rev.html),
[`unique()`](https://rdrr.io/r/base/unique.html) and
[`sort()`](https://rdrr.io/r/base/sort.html) return `naxp_encoded`
vectors with the same naxp.
[`split()`](https://rdrr.io/r/base/split.html) returns a list of
`naxp_encoded` vectors, again with the same naxp. Indexing out of range
or with `NA` gives 0. A `naxp_encoded` vector can be a data frame
column. [`order()`](https://rdrr.io/r/base/order.html) and
[`match()`](https://rdrr.io/r/base/match.html) return integer indices,
and [`table()`](https://rdrr.io/r/base/table.html) counts each distinct
value, labelled with its text, excluding 0.

Assigning into a `naxp_encoded` vector accepts

- another `naxp_encoded` vector with the same naxp,

- text, which is encoded, or

- `NA`, which is mapped to 0.

`is.na(x) <- i` sets those elements to 0.

[`c()`](https://rdrr.io/r/base/c.html) combines `naxp_encoded` vectors
with the same naxp.

## Comparison

Encoded values are compared only for equality. `==` and `!=` compare a
`naxp_encoded` vector with one with the same naxp, with text, which is
encoded first, or with numbers as underlying values, so `x == 0` finds
the invalid text.

[`sort()`](https://rdrr.io/r/base/sort.html) and
[`order()`](https://rdrr.io/r/base/order.html) sort by encoded value,
but arithmetic, `<`, `>` and summaries such as
[`max()`](https://rdrr.io/r/base/Extremes.html) raise errors.

## See also

[`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md) to
create a `naxp_encoded` vector from text and a naxp.

[`naxp_encoded()`](https://r-naxp.logmu.org/reference/naxp_encoded.md)
to recreate a `naxp_encoded` vector from its underlying values.

## Examples

``` r
postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")

postcodes <- naxp_encode(c("1012AB", "9999 ZZ", "not a postcode"), postcode_naxp)
postcodes
#> <naxp_encoded[3]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB       9999 ZZ       <invalid (0)>
as.integer(postcodes)
#> [1]  684114 6760000       0
is.na(postcodes)
#> [1] FALSE FALSE  TRUE

postcodes == "1012 AB"
#> [1]  TRUE FALSE FALSE
postcodes[2:3]
#> <naxp_encoded[2]> \9\9\9\9 \s!! \A\A
#> [1] 9999 ZZ       <invalid (0)>
postcodes[3] <- "1012 AB"
postcodes
#> <naxp_encoded[3]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB 9999 ZZ 1012 AB

data.frame(postcode = postcodes)
#>   postcode
#> 1  1012 AB
#> 2  9999 ZZ
#> 3  1012 AB
```
