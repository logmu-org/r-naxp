# CRAN submission comments: naxp 0.1.0

## Summary

This is a new submission. 'naxp' implements the naxp standard for encoding
ASCII text, typically alphanumeric codes such as postcodes, as integers
and back again, as specified at <https://naxp.org/spec/>.

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

- This is a new submission.

'naxp' and 'naxps' may be reported as possibly misspelt words in
DESCRIPTION. A naxp ('encoded ASCII expression') is the name of the pattern
the standard defines, so the word is correct, and it is lower case by design.

## Bundled code

`src/` includes the 'naxp' 'C++' library, version 0.15.0, by the same author
and under the same licence (Apache 2.0), unchanged from its tagged release at
<https://github.com/naxp-org/naxp>. Its C++ header is vendored as
`src/naxp_cpp.h`, renamed from `naxp.hpp` because `R CMD check` accepts only
`.h` headers at the top of `src/`. `LICENSE.note` records this.

The library is written in C++17, so `src/Makevars` sets `CXX_STD = CXX17`
and `DESCRIPTION` declares `SystemRequirements: C++17`.

## Reverse dependencies

This is a new package, so it has no reverse dependencies.
