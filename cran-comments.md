# CRAN submission comments: naxp 0.2.0

## Summary

This release fixes a bug and adds `NA` handling for encoded vectors.

- Indexing a `naxp_encoded` vector out of range or with `NA` stored `NA` in
  the vector, where an encoded value must be a whole number, with 0 standing
  for text that is not valid. It now stores 0.
- `is.na()` and `anyNA()` report an encoded value of 0 as missing.
- Assigning `NA` into a `naxp_encoded` vector stores 0.

The maintainer's email address has also changed.

## Maintainer email

The maintainer's email address has changed
- from: Tim Gordon <tim.gordon@btinternet.com>
- to: Tim Gordon <tim@timgord.com>

I can confirm the change from the old address.

## Timing

0.1.0 was published on 2026-11-03. I'm submitting this update sooner than
usual because of the bug above: a `naxp_encoded` vector holding `NA` prints
wrongly and gives `NA` in comparisons, and an ordinary data frame operation
such as `df[c(1, NA), ]` produces one.

## Changes in behaviour

`is.na()` on a `naxp_encoded` vector was `FALSE` everywhere and is now `TRUE`
for an encoded value of 0. The package has no reverse dependencies.

## Test environments

- Windows 11, R 4.6.1 (local), `R CMD check --as-cran`
- Windows (R-devel and R-release), via win-builder
- macOS-latest (R-release), Windows-latest (R-release and R 4.1.3),
  Ubuntu-latest (R-devel, R-release, R-oldrel-1 and R 4.1.3),
  via GitHub Actions (`r-lib/actions/check-r-package`)
- Linux (R-devel) with clang `AddressSanitizer` and
  `UndefinedBehaviorSanitizer`, via the R-hub `clang-asan` and `clang-ubsan`
  containers on GitHub Actions

## R CMD check results

0 errors | 0 warnings | 1 note

- New maintainer: the maintainer's email address has changed, as above.

The same note may report 'naxp' and 'naxps' as possibly misspelt words in
DESCRIPTION. A naxp ('encoded ASCII expression') is the name of the pattern
the standard defines, so the word is correct, and it is lower case by design.

## Bundled code

As in 0.1.0, `src/` includes the 'naxp' 'C++' library, version 0.15.0,
unchanged from its tagged release at <https://github.com/naxp-org/naxp>.
`LICENSE.note` records this.

## Reverse dependencies

There are no reverse dependencies.
