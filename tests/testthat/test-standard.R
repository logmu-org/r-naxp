# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

test_that("naxp_standards() lists every variant, each standard's default first", {
  standards <- naxp_standards()
  expect_s3_class(standards, "data.frame")
  expect_named(standards, c("id", "name", "variant", "pattern", "notes"))
  for (column in names(standards)) {
    expect_type(standards[[column]], "character")
  }
  expect_true(all(c("uk-postcode", "eircode", "nl-postcode", "flight-designator") %in% standards$id))
  for (id in unique(standards$id)) {
    variants <- standards$variant[standards$id == id]
    expect_identical(variants[[1]], "default")
    expect_false(anyDuplicated(variants) > 0)
  }
})

test_that("every listed variant is given by naxp_standard()", {
  standards <- naxp_standards()
  for (row in seq_len(nrow(standards))) {
    naxp <- naxp_standard(standards$id[[row]], standards$variant[[row]])
    expect_s3_class(naxp, "naxp")
    expect_identical(naxp_pattern(naxp), standards$pattern[[row]])
  }
})

test_that("ids and variants are matched without regard to ASCII case, and \"\" is the default", {
  expect_identical(
    naxp_standard("UK-Postcode", "PADDING-TOLERANT"),
    naxp_standard("uk-postcode", "padding-tolerant")
  )
  expect_identical(naxp_standard("nl-postcode", ""), naxp_standard("nl-postcode"))
  expect_identical(naxp_standard("nl-postcode", "DEFAULT"), naxp_standard("nl-postcode"))
})

test_that("the standard naxps encode as in the other naxp libraries", {
  # The value naxp.org's map format example gives for EC4M 7AA.
  uk <- naxp_standard("uk-postcode")
  expect_identical(as.integer(naxp_encode(c("EC4M 7AA", "EC4M7AA"), uk)), c(278793893L, 278793893L))
  expect_identical(naxp_max_encoded_value(uk), 1755842401L)
  expect_identical(naxp_pattern(naxp_standard("nl-postcode")), nl_space)
  expect_identical(naxp_pattern(naxp_standard("nl-postcode", "no-separator")), nl_no_separator)
  expect_identical(naxp_pattern(naxp_standard("nl-postcode", "hyphen-tolerant")), nl_hyphen)
})

test_that("an unknown id or variant is an error naming the valid ones", {
  expect_error(naxp_standard("us-zip-code"), "no standard naxp with id \"us-zip-code\".*uk-postcode")
  expect_error(
    naxp_standard("uk-postcode", "padded"),
    "\"uk-postcode\" has no variant \"padded\".*default, padding-tolerant, padding-canonical"
  )
  expect_error(naxp_standard(NA_character_), "`id` must be a single string")
  expect_error(naxp_standard(c("uk-postcode", "eircode")), "`id` must be a single string")
  expect_error(naxp_standard("uk-postcode", NA_character_), "`variant` must be a single string")
})
