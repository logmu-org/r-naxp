# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

test_that("naxp_parse() returns a naxp holding its pattern", {
  nl <- naxp_parse(nl_space)
  expect_s3_class(nl, "naxp")
  expect_identical(naxp_pattern(nl), nl_space)
  expect_identical(format(nl), nl_space)
  expect_output(print(nl), "<naxp> \\9\\9\\9\\9 \\s!! \\A\\A", fixed = TRUE)
  expect_output(print(nl), "Maximum encoded value: 6760000", fixed = TRUE)
})

test_that("naxp_parse() checks its argument", {
  expect_error(naxp_parse(NA_character_), "single string")
  expect_error(naxp_parse(c(nl_space, nl_space)), "single string")
  expect_error(naxp_parse(1), "single string")
})

test_that("an invalid pattern raises a naxp_error with its parts", {
  pattern <- r"(\9\9\9\9 [A-)"
  error <- tryCatch(naxp_parse(pattern), naxp_error = identity)
  expect_s3_class(error, c("naxp_error", "error", "condition"))
  expect_identical(error$code, "NAXP1025")
  expect_identical(error$offset, 9L)
  expect_identical(error$length, 1L)
  expect_identical(error$pattern, pattern)
  expect_match(error$message, "not closed")
  expect_no_match(error$message, "NAXP1025")

  message <- conditionMessage(error)
  expect_match(message, "NAXP1025 at 9..10: ", fixed = TRUE)
  expect_match(message, paste0("\n  ", pattern, "\n           ^\n"), fixed = TRUE)
  expect_match(message, "See https://naxp.org/error-codes/#naxp1025", fixed = TRUE)
})

test_that("a naxp_error for a non-ASCII pattern has no caret line", {
  error <- tryCatch(naxp_parse(paste0("AB", intToUtf8(0xA3))), naxp_error = identity)
  expect_s3_class(error, "naxp_error")
  expect_no_match(conditionMessage(error), "^", fixed = TRUE)
})

test_that("an invalid pattern is reported wherever a pattern string is accepted", {
  expect_error(naxp_encode("1012AB", r"(\9\9\9\9 [A-)"), class = "naxp_error")
  expect_error(naxp_accepts("1012AB", r"(\9\9\9\9 [A-)"), class = "naxp_error")
})

test_that("a pattern string works wherever a naxp does", {
  nl <- naxp_parse(nl_space)
  expect_identical(naxp_encode("1012AB", nl_space), naxp_encode("1012AB", nl))
  expect_identical(naxp_max_length(nl_space), naxp_max_length(nl))
})

test_that("only a naxp or a single pattern string is accepted as a naxp", {
  expect_error(naxp_encode("1012AB", c(nl_space, nl_space)), "naxp or a single pattern string")
  expect_error(naxp_encode("1012AB", 1), "naxp or a single pattern string")
  codes <- naxp_encode("1012AB", nl_space)
  expect_error(naxp_encode("1012AB", codes), "naxp_of")
})

test_that("a naxp's properties are reported", {
  expect_identical(naxp_max_encoded_value(nl_space), 6760000L)
  expect_identical(naxp_max_length(nl_space), 7L)
  expect_identical(naxp_max_encoded_value(ten_digits), 1e10)
  expect_error(naxp_max_encoded_value(sixteen_digits), "10000000000000000, is above 2\\^53")
  expect_output(print(naxp_parse(sixteen_digits)), "Maximum encoded value: 10000000000000000", fixed = TRUE)
})

test_that("naxp_of() gives the naxp of an encoded vector", {
  codes <- naxp_encode("1012AB", nl_space)
  expect_identical(naxp_of(codes), naxp_parse(nl_space))
  expect_error(naxp_of(684114L), "naxp_encoded")
})

test_that("a naxp is compiled again after the cache is emptied or it is reloaded", {
  nl <- naxp_parse(nl_space)
  file <- tempfile(fileext = ".rds")
  on.exit(unlink(file))
  saveRDS(nl, file)
  rm(list = ls(naxp_cache, all.names = TRUE), envir = naxp_cache)
  expect_identical(as.integer(naxp_encode("1012AB", readRDS(file))), 684114L)
  expect_true(exists(nl_space, envir = naxp_cache, inherits = FALSE))
})
