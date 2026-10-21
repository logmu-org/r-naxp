# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

relationships <- function(accepted_text, encoding, canonical_forms) {
  c(accepted_text = accepted_text, encoding = encoding, canonical_forms = canonical_forms)
}

test_that("naxp_compare() gives the three relationships from a's point of view", {
  expect_identical(
    naxp_compare(nl_space, nl_no_separator),
    relationships("equal", "equal", "incomparable")
  )
  expect_identical(
    naxp_compare(nl_space, nl_hyphen),
    relationships("subset_of", "subset_of", "equal")
  )
  expect_identical(
    naxp_compare(nl_hyphen, nl_space),
    relationships("superset_of", "superset_of", "equal")
  )
  expect_identical(
    naxp_compare(nl_space, ten_digits),
    relationships("incomparable", "incomparable", "incomparable")
  )
})

test_that("naxp_compare() raises an error when the budget is too small", {
  expect_error(naxp_compare(nl_space, nl_hyphen, budget = 1), "budget of 1 product state\\.")
  expect_identical(naxp_compare(nl_space, nl_hyphen, budget = 200000)[["encoding"]], "subset_of")
})

test_that("naxp_compare() checks the budget", {
  expect_error(naxp_compare(nl_space, nl_hyphen, budget = 0), "positive whole number")
  expect_error(naxp_compare(nl_space, nl_hyphen, budget = 1.5), "positive whole number")
  expect_error(naxp_compare(nl_space, nl_hyphen, budget = "1"), "positive whole number")
  expect_error(naxp_compare(nl_space, nl_hyphen, budget = c(1, 2)), "positive whole number")
})

test_that("naxp_first_divergent_value() finds the lowest value decoded differently", {
  expect_identical(naxp_first_divergent_value(nl_space, nl_no_separator), 1L)
  expect_identical(naxp_first_divergent_value(nl_space, nl_hyphen), 0L)
  expect_identical(naxp_first_divergent_value(ten_digits, ten_digits), 0)
  expect_error(naxp_first_divergent_value(nl_space, sixteen_digits), "above 2\\^53")
})

test_that("naxp_emit() writes source in each language", {
  for (language in c("csharp", "javascript", "c", "cpp")) {
    source <- naxp_emit(nl_space, language, prefix = "postcode")
    expect_type(source, "character")
    expect_length(source, 1)
    expect_match(source, "postcode", ignore.case = TRUE)
  }
  expect_match(naxp_emit(nl_space, "c", new_line = "\r\n"), "\r\n", fixed = TRUE)
})

test_that("naxp_emit() checks its arguments", {
  expect_error(naxp_emit(nl_space, "fortran"), "should be one of")
  expect_error(naxp_emit(nl_space, "c", value_type = "int8"), "does not fit")
  expect_error(naxp_emit(nl_space, "c", prefix = "1 bad"))
  expect_error(naxp_emit(nl_space, "c", prefix = NA_character_), "single string")
})
