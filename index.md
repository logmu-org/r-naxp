# naxp

Dealing with postcodes, flight numbers and other alphanumeric data codes
is a common problem. Handling strings is cumbersome and the codes
themselves can often be written in multiple different ways – for
instance `EC1A1BB` and `EC1A 1BB` are the same UK postcode.

A **naxp** (‘encoded ASCII expression’) simplifies this by encoding each
distinct alphanumeric data code as an integer.

With a **naxp**, you define the code system once using a flexible
regex-like syntax, and then you’re done. Every **naxp** library, in
every language (R, C, C++, C# and JavaScript), produces exactly the same
encoding, which means that the encoded values are safe to store in
files, to use in databases, and to pass between different programs
written in different languages. And, as an added bonus, integers are
more performant than strings.

The [**naxp** website](https://naxp.org/) provides everything you need
to understand and write **naxp**s:

- A good place to start is the [**naxp** quick
  tour](https://naxp.org/#quick-tour).

- For common use cases, there are built-in [standard
  **naxp**s](https://naxp.org/standard/), which can be accessed direct
  from the R `naxp` package.

- The site also has an [interactive **naxp** design
  tool](https://naxp.org/interactive/) and a [**naxp** migration
  tester](https://naxp.org/migrate/).

## Installation

Install from CRAN:

``` r

install.packages("naxp")
```

Or install the latest development version from GitHub:

``` r

# install.packages("pak")
pak::pak("logmu-org/r-naxp")
```

## Example

``` r

library(naxp)

# Assume we have some UK postcodes
postcodes_as_text <- c(
  "CR2 6XH",
  "DN55 1PT",
  "M1 1AE",
  "EC1A1BB", # The mandated space is sometimes omitted
  "not a postcode")

# UK postcodes are complicated so let's grab the standard naxp
postcode_naxp <- naxp_standard("uk-postcode")
postcode_naxp
#> <naxp> \A\A?\9\X? \s!! \9\A\A | GIR \s!! 0AA
#> Maximum encoded value: 1755842401

# Encode the text postcodes
postcodes <- naxp_encode(postcodes_as_text, postcode_naxp)

# The encoded result looks like text ...
postcodes
#> <naxp_encoded[5]> \A\A?\9\X? \s!! \9\A\A | GIR \s!! 0AA
#> [1] CR2 6XH       DN55 1PT      M1 1AE        EC1A 1BB      <invalid (0)>

# ... but the underlying values are numerical,
# with 0 (not NA!) representing invalid text.
as.integer(postcodes)
#> [1] 180591302 238906246 743107201 277958384         0

# We can recover the canonical text form at any time.
# 0 (invalid text) decodes to NA.
naxp_decode(postcodes)
#> [1] "CR2 6XH"  "DN55 1PT" "M1 1AE"   "EC1A 1BB" NA
```

[Get started](https://r-naxp.logmu.org/articles/naxp.html)
