# Standard naxps

`naxp_standard()` gives one of the standard naxps built into every naxp
library, and `naxp_standards()` lists them all.

## Usage

``` r
naxp_standard(id, variant = "default")

naxp_standards()
```

## Arguments

- id:

  A single string: the standard's id, such as `"uk-postcode"`.

- variant:

  A single string: the variant's id. `"default"` or `""` gives the
  default.

## Value

- `naxp_standard()`: a naxp.

- `naxp_standards()`: a data frame with one row per variant, each
  standard's default first, and character columns `id`, `name` (for
  display), `variant`, `pattern` and `notes` (what the variant accepts
  and prints, in Markdown).

## Details

The standard naxps are for widely used code systems such as postcodes.
Each has an id, such as `"uk-postcode"`, and one or more variants, one
of which is `"default"`. The id and the variant are matched without
regard to ASCII case. Once published, a standard naxp never changes, so
values encoded with it keep their meaning.

The standard naxps are described at <https://naxp.org/standard/>.

## Examples

``` r
uk_postcode <- naxp_standard("uk-postcode")
naxp_encode(c("EC4M 7AA", "EC4M7AA", "B1 1AA"), uk_postcode)
#> <naxp_encoded[3]> \A\A?\9\X? \s!! \9\A\A | GIR \s!! 0AA
#> [1] EC4M 7AA EC4M 7AA B1 1AA  

naxp_standard("nl-postcode", "no-separator")
#> <naxp> \9\9\9\9 \s!? \A\A
#> Maximum encoded value: 6760000

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
