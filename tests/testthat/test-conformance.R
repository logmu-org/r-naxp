# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

# The language-neutral conformance data that every naxp library passes, vendored
# unchanged from the naxp release. It was generated from the specification, not
# from any implementation. Encoded values are decimal strings in it, because a
# naxp may have up to 2^64 - 1 of them.
conformance_data <- function() {
  skip_if_not_installed("jsonlite")
  jsonlite::fromJSON(test_path("naxp-v0.10.json"), simplifyVector = FALSE)
}

# Cases whose encoded values R can hold exactly.
holds_values <- function(case) {
  as.numeric(case$maxEncodedValue) <= 2^53
}

test_that("every conformance case parses, with the stated maximum encoded value", {
  for (case in conformance_data()$cases) {
    naxp <- naxp_parse(case$naxp)
    if (holds_values(case)) {
      expect_identical(
        format(naxp_max_encoded_value(naxp), scientific = FALSE),
        case$maxEncodedValue,
        info = case$naxp
      )
    } else {
      expect_error(naxp_max_encoded_value(naxp), "above 2\\^53", info = case$naxp)
    }
  }
})

test_that("conformance values encode, decode and canonicalise as stated", {
  for (case in conformance_data()$cases) {
    if (!holds_values(case)) {
      next
    }
    naxp <- naxp_parse(case$naxp)
    text <- vapply(case$values, function(value) value[["in"]], "")
    values <- as.numeric(vapply(case$values, function(value) value[["out"]], ""))
    canonical <- vapply(case$values, function(value) value[["canon"]], "")

    expect_identical(as.numeric(naxp_encode(text, naxp)), values, info = case$naxp)
    expect_identical(naxp_accepts(text, naxp), rep(TRUE, length(text)), info = case$naxp)
    expect_identical(naxp_canonical_form(text, naxp), canonical, info = case$naxp)
    expect_identical(naxp_decode(values, naxp), canonical, info = case$naxp)
    expect_identical(as.numeric(naxp_encode(canonical, naxp)), values, info = case$naxp)
  }
})

test_that("complete conformance cases are a bijection onto 1 to the maximum", {
  for (case in conformance_data()$cases) {
    if (!isTRUE(case$complete) || !holds_values(case)) {
      next
    }
    values <- as.numeric(vapply(case$values, function(value) value[["out"]], ""))
    expect_identical(
      sort(unique(values)),
      as.numeric(seq_len(as.numeric(case$maxEncodedValue))),
      info = case$naxp
    )
  }
})

test_that("conformance cases' invalid text encodes to 0", {
  for (case in conformance_data()$cases) {
    invalid <- unlist(case$invalid)
    if (length(invalid) == 0L) {
      next
    }
    naxp <- naxp_parse(case$naxp)
    expect_identical(naxp_accepts(invalid, naxp), rep(FALSE, length(invalid)), info = case$naxp)
    expect_identical(naxp_canonical_form(invalid, naxp), rep(NA_character_, length(invalid)), info = case$naxp)
    if (holds_values(case)) {
      expect_identical(as.numeric(naxp_encode(invalid, naxp)), rep(0, length(invalid)), info = case$naxp)
    }
  }
})

test_that("conformance cases above 2^53 still check text, but don't encode it", {
  large <- Filter(Negate(holds_values), conformance_data()$cases)
  expect_gt(length(large), 0L)
  for (case in large) {
    naxp <- naxp_parse(case$naxp)
    text <- vapply(case$values, function(value) value[["in"]], "")
    canonical <- vapply(case$values, function(value) value[["canon"]], "")
    expect_identical(naxp_canonical_form(text, naxp), canonical, info = case$naxp)
    expect_error(naxp_encode(text, naxp), "above 2\\^53", info = case$naxp)
  }
})

test_that("every invalid naxp in the conformance data raises a naxp_error", {
  for (invalid in conformance_data()$invalidNaxps) {
    expect_error(
      naxp_parse(invalid$naxp),
      class = "naxp_error",
      info = paste0(invalid$naxp, " (", invalid$rule, ")")
    )
  }
})
