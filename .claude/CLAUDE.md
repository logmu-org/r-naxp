# CLAUDE guide for R package implementing naxp

R package for naxp (eNcoded Ascii eXPression): the standard encoding of ASCII expressions as unsigned integers using a RegEx-like syntax.

The brand name is **naxp**, all lower case. Treat it as a word rather than an acronym, e.g. write 'a naxp' rather than 'an naxp'.

## Project outline

- This is a CRAN-targeted R package developed in RStudio.
- It wraps the naxp C++ library, vendored in `src/` as the three amalgamated files `naxp.cpp`, `naxp.h` and `naxp.hpp` from a tagged release of `naxp-org/naxp`, checked against that release's `SHA256SUMS`.
- The conformance data in `tests/testthat/` comes from the same release.
- Its first user is likely to be the logmu package, which maps postcodes and other  geocodes to clusters, values or coordinates.
- Reading naxp map files (gzipped JSON, see `encoding/naxp-map-format.md` in naxp) is to be implemented (if at all) after the core functions.

## Relationship to the other naxp libraries

- The specification, the C++ library and the conformance data are developed in the private repo `naxp-draft` (`C:\Users\Tim Gordon\source\repos\naxp-org\naxp-draft`) and published from `naxp-org/naxp`. That is where any change to them is made.
- During development the vendored files may come from a local `node tools/amalgamate.js --out <dir>` run in `naxp-draft`. Before a release they must come from a tagged naxp release.
- Use the same names for the same things as the C#, JavaScript and C++ libraries, in Tidyverse snake_case.
- The terminology is that an invalid naxp produces an 'error', never a 'fault'. Errors have an error code (`NAXPnnnn`), message, offset and length, and link to `https://naxp.org/error-codes/`. Error codes are intended to be identical across versions. Error messages are informative and may change between versions.

## CRAN compliance

- Warn me if any changes will generate CRAN notes, warnings or errors on any current CRAN platform when I submit the package via `devtools::check_win_devel()` or similar checks.
- Check Roxygen2 comments for CRAN fails such as non-ASCII characters and missing `@returns` statements.
- Avoid Undefined Behaviour (UB).
- Never use pointer casting or unions for type punning.
- Code, including the vendored files, must compile warning-free and pass aggressive `-Wstrict-aliasing=2` optimisations.

## Standards

- R minimum version: **4.1.0**
- Required C++ standard: **C++17**, which is what the vendored library is written in.
- All R and C++ files other than those sourced externally must have a standard disclaimer at the top. This excludes auto-generated files (e.g. `cpp11.R`, `cpp11.cpp`) and the vendored files.

    The disclaimer for R files is:

    ```R
    # naxp: encoded ASCII expressions for R
    #
    # This file is licensed to you under the Apache Licence 2.0.
    #
    # Copyright (c) Tim Gordon
    ```

    The disclaimer for C++ (including `.cpp` and `.hpp`) files is:

    ```cpp
    // naxp: encoded ASCII expressions for R
    //
    // This file is licensed to you under the Apache Licence 2.0.
    //
    // Copyright (c) Tim Gordon
    ```

## Dependencies

- For R/C++ code interop use the `cpp11` package, i.e. `cpp11::` `doubles`, `integers`, `strings`, `sexp`, etc. and `[[cpp11::register]]`.
- Do *not* use `Rcpp`, `Rcpp::NumericVector`, or `Rcpp` macros.
- Keep the core free of runtime dependencies beyond base R.

## Code style

- For R code follow Tidyverse naming conventions.
- For C++ code (other than vendored code, which *must* be left intact), follow the naxp library's conventions:
    - Use modern C++17 idioms.
    - Use tabs for indentation.
    - Follow standard library naming: `snake_case` for types, functions, variables, namespaces and constants alike. Reserve `UPPER_SNAKE_CASE` for macros, and prefer `constexpr` and `inline` variables to macros. Template parameters may be `PascalCase`.
    - Inside a member function, write field access using `this->name`, not `name`.
    - Use Allman bracket style.
    - Check for `const T&`.
    - Use range-based for loops, `const auto&`, and explicit single-argument constructors.
    - Prefer wordy identifiers rather than abbreviations unless they are universal or keywords. For instance, prefer `literal` to `lit`.
    - Do *not* use indentation styles that rely on fixed width fonts.
    Specifically do *not* align to opening delimiters (`AlignAfterOpenBracket: Align` in CLang, `Align contents to opening parenthesis` Visual Studio etc).
    Instead use hanging / block indent with a fixed indentation level regardless of the function name's length.
    For example, do *not* do this:

        ```cpp
        int some_function(int a,
                          int b,
                          int c)
        ```

      but *do* do this:

        ```cpp
        int some_function(
        	int a,
        	int b,
        	int c)
        ```

## Language style

Act as a direct, clear human writer.

Always use British English and punctuation. In particular:
- When using a dash as a strong comma, colon, or parenthesis to create an emphatic pause, break in thought, or aside within a sentence, always use en dash (–) with spaces either side. Never use em dash (—).
- Use single quotation marks before double quotation marks.
- Never use 'off of' or 'outside of' -- use just 'off' or 'outside'.
- Always use 'named after' instead of 'named for' (unless you are giving the reason for the naming).

Do not use AI-tell phrasing:

- Do not use telegraphic appositive headlines or fragments ("One construct, three uses", "Same core, two bindings").
- Do not use rule-of-three parallelism for rhythm rather than content.
- Do not use "it isn't X, it's Y" reframes or em or en-dash reframes deployed for punch.
- Do introduce lists and points with plain lead-in clauses.
- Do not use any of these words: delve, realm, harness, unlock, tapestry, beacon, testament, symphony, navigate, journey, furthermore, moreover, ultimately, pivotal, broader, landscape.
- Do not use overly complex punctuation.
- Do not open with introductory filler or close with a summary.
- Vary your sentence length drastically -- make some punchy and one sentence long.
- Do not explain a concept and then immediately summarise it.

All that said, README.Rmd is in effect a marketing page and is permitted to be salesy.

## Things Claude should not do

- Do not amend this file `CLAUDE.md`.
- Do not request permission to amend this file `CLAUDE.md`.
- Do not amend any code without my permission.
- Do not amend the vendored files `src/naxp.cpp`, `src/naxp.h` or `src/naxp.hpp`. Changes to them are made in `naxp-draft` and vendored again.
- Do not download any software.
- Do not commit any changes without my permission.
- Do not offer to commit changes yourself (although you can suggest that I do commit changes at sensible stopping points).
- Do not add Claude credits e.g. "Co-Authored-By: Claude" in code comments or in git commit summaries or descriptions.
