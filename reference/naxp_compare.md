# Compare two naxps

`naxp_compare()` says how `b` stands to `a`: what happens to text and
encoded values held under `a` if `b` replaces it.
`naxp_first_divergent_value()` finds the lowest encoded value the two
decode differently.

## Usage

``` r
naxp_compare(a, b, budget = NULL)

naxp_first_divergent_value(a, b)
```

## Arguments

- a:

  The naxp the data was encoded with: a naxp from
  [`naxp_parse()`](https://r-naxp.logmu.org/reference/naxp_parse.md), or
  a pattern string.

- b:

  The naxp proposed to replace it, likewise.

- budget:

  `NULL` for the library's default budget of 200 000 product states, or
  a positive whole number.

## Value

- `naxp_compare()`: a named character vector with elements
  `accepted_text`, `encoding` and `printed_text`.

- `naxp_first_divergent_value()`: a single encoded value, or 0 where
  every value both naxps hold decodes alike. Values only one naxp holds
  do not count. It is an integer where both naxps' encoded values are
  integers, and otherwise a double.

## Details

`naxp_compare()` gives three set relationships, each from `a`'s point of
view:

- `accepted_text`: how the strings `a` accepts stand to those `b`
  accepts.

- `encoding`: how the (text, encoded value) pairs `a` defines stand to
  those `b` defines. Replacing `a` with `b` is safe for stored values
  exactly when this is `"equal"` or `"subset_of"`.

- `printed_text`: how the canonical forms `a` prints stand to those `b`
  prints.

Each is `"equal"`, `"subset_of"`, `"superset_of"` or `"incomparable"`.

The encoding relationship is decided by walking the two naxps together,
which has a budget. No naxp anybody has reason to write comes near the
default, but a pair that does cannot be decided, and `naxp_compare()`
then raises an error rather than guess.

## Examples

``` r
with_space <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
without_space <- naxp_parse(r"(\9\9\9\9 \s!? \A\A)")

naxp_compare(with_space, without_space)
#>  accepted_text       encoding   printed_text 
#>        "equal"        "equal" "incomparable" 
naxp_first_divergent_value(with_space, without_space)
#> [1] 1
```
