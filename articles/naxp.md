# Get started with naxps

``` r

library(naxp)
```

A **naxp** maps text-based codes, e.g. postcodes, to integers and back
again.

If you haven’t already, please first take the [**naxp** quick
tour](https://naxp.org/#quick-tour).

## Create a **naxp**

For the purpose of illustration, we’ll roll our own Netherlands postcode
**naxp**[^1].

A Netherlands postcode is four digits followed by two letters,
officially with a space between the digits and the two letters, although
this is often omitted in electronic data.

This **naxp** accepts both forms (but treats the version with a space as
the canonical version):

``` r

NL_postcode_x <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
NL_postcode_x
#> <naxp> \9\9\9\9 \s!! \A\A
#> Maximum encoded value: 6760000
```

We’ve used a raw string, `r"(...)"`, because **naxp**s use backslashes
(like regexes) and in a normal string every backslash would have to be
doubled.

The `!!` syntax means

- the preceding item makes no difference to the encoding whether or not
  it’s present, and
- *include it* when decoding the encoded value back to text.

This **naxp** maps every postcode that fits the pattern to an integer
from 1 to 6 760 000, with no gaps.

Let’s take it for a test drive:

``` r

postcodes_as_text <- c("1012 AB", "1012AB", "1012-AB", "not a postcode")
postcodes <- naxp_encode(postcodes_as_text, NL_postcode_x)
postcodes
#> <naxp_encoded[4]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB       1012 AB       <invalid (0)> <invalid (0)>
as.integer(postcodes)
#> [1] 684114 684114      0      0
```

Note that both `1012 AB` and `1012AB` were mapped to the same encoded
value.

The invalid text, including `1012-AB`, was mapped to `0`[^2].

We can go in the other direction, i.e. decode the encoded value back to
text:

``` r

naxp_decode(postcodes) # No need for the naxp (NL_postcode_x)
#> [1] "1012 AB" "1012 AB" NA        NA
naxp_decode(684114L, NL_postcode_x) # Decoding raw numbers requires a naxp
#> [1] "1012 AB"
naxp_decode(0L, NL_postcode_x) # 0 means invalid -- it decodes to NA
#> [1] NA
```

As promised, decoding gives the form with the space, i.e. `1012 AB`.

Note that the first line above did not need the original **naxp**
because it is already included in the vector’s attributes.

Encoded values that are negative or greater than the maximum raise an
error:

``` r

naxp_decode(6760001L, NL_postcode_x)
#> Error in `naxp_decode()`:
#> ! x[1] is 6760001, above the naxp's maximum encoded value of 6760000.
```

For convenience, you can check whether text is valid for a **naxp** and
convert it to the canonical form *without encoding it* using the
following functions:

``` r

naxp_accepts(postcodes_as_text, NL_postcode_x)
#> [1]  TRUE  TRUE FALSE FALSE
naxp_canonical_form(postcodes_as_text, NL_postcode_x)
#> [1] "1012 AB" "1012 AB" NA        NA
```

You can obtain properties of a **naxp**:

``` r

writeLines(naxp_pattern(NL_postcode_x)) # Text pattern used to define the naxp
#> \9\9\9\9 \s!! \A\A
naxp_max_encoded_value(NL_postcode_x) # Maximum encoded value
#> [1] 6760000
naxp_max_length(NL_postcode_x) # Maximum decoded text length
#> [1] 7
```

## Encoded values in data

The [`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
function returns a `naxp_encoded` vector of encoded values, an S3 class.
As noted above, a `naxp_encoded` also includes the **naxp** used to
encode the values.

A `naxp_encoded` looks like text when printed, including when it’s part
of a data frame:

``` r

offices <- data.frame(
  office = c("Amsterdam", "Maastricht", "Head office"),
  postcode = naxp_encode(c("1012 AB", "6211 CA", "1012AB"), NL_postcode_x)
)
offices
#>        office postcode
#> 1   Amsterdam  1012 AB
#> 2  Maastricht  6211 CA
#> 3 Head office  1012 AB
offices[offices$postcode == "1012 AB", ]
#>        office postcode
#> 1   Amsterdam  1012 AB
#> 3 Head office  1012 AB
```

Comparing a `naxp_encoded` with text encodes the text before the
comparison. This is why, in the above, the encoded values for `"1012AB"`
and `"1012 AB"` both match `"1012 AB"`.

[`sort()`](https://rdrr.io/r/base/sort.html) sorts by encoded value.

To turn bare encoded values, e.g. values read back from a database or a
file, back into a `naxp_encoded` vector, use
[`naxp_encoded()`](https://r-naxp.logmu.org/reference/naxp_encoded.md):

``` r

naxp_encoded(c(684114, 0), NL_postcode_x)
#> <naxp_encoded[2]> \9\9\9\9 \s!! \A\A
#> [1] 1012 AB       <invalid (0)>
```

It checks every value, so an illegal one is an error:

``` r

naxp_encoded(6760001L, NL_postcode_x)
#> Error in `naxp_encoded()`:
#> ! values[1] is 6760001, above the naxp's maximum encoded value of 6760000.
```

## **naxp** constraints in R

The **naxp** specification permits up to 2⁶⁴−1 encoded values but R does
not have built-in 64-bit integers. Consequently,

- **naxp**s with a maximum encoded value up to 2³¹−1 are stored as
  `integer`,
- **naxp**s with a maximum encoded value up to 2⁵³ are stored as
  `double`, otherwise
- the functions that return or accept encoded values, such as
  [`naxp_encode()`](https://r-naxp.logmu.org/reference/naxp_encode.md)
  and
  [`naxp_decode()`](https://r-naxp.logmu.org/reference/naxp_encode.md),
  raise an error[^3].

## Standard **naxp**s

Standard **naxp**s are provided for widely used code systems. The
benefits are:

- Safety – a hand-written pattern can contain mistakes that silently
  change the encoding, whereas a standard one has been tested and is
  fixed for all time.
- Consistent encoding – all variants of a standard encode consistently,
  i.e. any text accepted by two variants results in the same encoded
  value.
- Commonality – the standards are the same in all languages in which
  **naxp**s are implemented.

``` r

naxp_standards()[, c("id", "variant")]
#>                   id           variant
#> 1        uk-postcode           default
#> 2        uk-postcode  padding-tolerant
#> 3        uk-postcode padding-canonical
#> 4            eircode           default
#> 5            eircode      no-separator
#> 6        nl-postcode           default
#> 7        nl-postcode      no-separator
#> 8        nl-postcode   hyphen-tolerant
#> 9  flight-designator           default
#> 10 flight-designator            strict
```

We could have created our Netherlands postcode **naxp** using

``` r

NL_postcode_x2 <- naxp_standard("nl-postcode")
naxp_compare(NL_postcode_x, NL_postcode_x2)
#>   accepted_text        encoding canonical_forms 
#>         "equal"         "equal"         "equal"
```

All three relationships are “equal”, which means that our **naxp** and
the standard one behave identically.

For detailed information on all available standard **naxp**s, see
[naxp.org/standard](https://naxp.org/standard/).

## Comparing and migrating **naxp**s

In the above, we used
[`naxp_compare()`](https://r-naxp.logmu.org/reference/naxp_compare.md)
to check that our hand-written Netherlands postcode **naxp** was the
same as the standard one. The definitions were the same so this was
trivially true, but things are not always so simple.

Let’s imagine that we have new incoming postcode data that uses hyphen
separators, e.g. `1012-AB` (which is not uncommon in the Netherlands).

The `naxp` package provides a `hyphen-tolerant` variant for Netherlands
postcodes, but is this safe to use without re-encoding the encoded
values we’ve already stored?

Let’s find out:

``` r

NL_postcode_HT_x <- naxp_standard("nl-postcode", "hyphen-tolerant")
naxp_compare(NL_postcode_x, NL_postcode_HT_x)
#>   accepted_text        encoding canonical_forms 
#>     "subset_of"     "subset_of"         "equal"
```

This comparison tells us:

- `accepted_text` being `"subset_of"` means the `hyphen-tolerant`
  **naxp** accepts all text the existing one does, and more.
- `encoding` being `"subset_of"` means every text accepted by the
  existing **naxp** has the same encoded value under the
  `hyphen-tolerant` **naxp**, *but* the `hyphen-tolerant` **naxp** also
  accepts text that is invalid under the existing **naxp**.
- `canonical_forms` being `"equal"` means both **naxp**s decode to the
  same texts.

This means it *is* safe to replace the existing **naxp** with the
`hyphen-tolerant` **naxp**. Here is the difference in practice:

``` r

postcodes_as_text
#> [1] "1012 AB"        "1012AB"         "1012-AB"        "not a postcode"

# Rejects "1012-AB":
as.integer(naxp_encode(postcodes_as_text, NL_postcode_x))
#> [1] 684114 684114      0      0

# Accepts "1012-AB":
as.integer(naxp_encode(postcodes_as_text, NL_postcode_HT_x))
#> [1] 684114 684114 684114      0
```

See [naxp.org/migrate](https://naxp.org/migrate/) to play with an
interactive version (which also helps interpret the results if you are
considering migrating a **naxp**).

## Errors

An invalid **naxp** pattern raises a `naxp_error`, which includes
diagnostics about the error and its location.

``` r

naxp_parse(r"(\9\9\9\9 [A-)")
#> Error in `naxp_parse()`:
#> ! NAXP1025 at 9..10: This character set is not closed. Add a ']'.
#>   The error is at "[", after "\9\9\9\9 ".
#> See https://naxp.org/error-codes/#naxp1025
```

Use [`tryCatch()`](https://rdrr.io/r/base/conditions.html) to obtain
more information:

``` r

error <- tryCatch(naxp_parse(r"(\9\9\9\9 [A-)"), naxp_error = identity)
error$code
#> [1] "NAXP1025"
error$offset
#> [1] 9
```

The `NAXP...` error codes are the same in every **naxp** library.

## Code generation

[`naxp_emit()`](https://r-naxp.logmu.org/reference/naxp_emit.md) allows
you to generate source code in other languages, including C++, C# and
JavaScript.

Go to [naxp.org/code-gen](https://naxp.org/code-gen/) to see this
working in practice.

[^1]: In practice, we’d use the [standard Netherlands postcode
    **naxp**](https://naxp.org/standard/#nl-postcode) instead. This is
    covered later on this page.

[^2]: Not `NA`! All **naxp** libraries *always* encode invalid text as
    `0`.

[^3]: For compatibility with other **naxp** implementations,
    [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md)
    still parses such a **naxp**, and
    [`naxp_accepts()`](https://r-naxp.logmu.org/reference/naxp_accepts.md),
    [`naxp_canonical_form()`](https://r-naxp.logmu.org/reference/naxp_accepts.md),
    [`naxp_compare()`](https://r-naxp.logmu.org/reference/naxp_compare.md)
    and [`naxp_emit()`](https://r-naxp.logmu.org/reference/naxp_emit.md)
    do *not* raise an error, but instead work in line with the **naxp**
    specification.
