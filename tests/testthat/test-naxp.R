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
  lines <- strsplit(message, "\n", fixed = TRUE)[[1]]
  expect_identical(lines[[2]], paste0('  The error is at "[", after "', substr(pattern, 1, 9), '".'))
  expect_no_match(message, "^", fixed = TRUE)
  expect_match(message, "See https://naxp.org/error-codes/#naxp1025", fixed = TRUE)
})

test_that("a naxp_error says in words where the error is", {
  location <- function(pattern) {
    message <- conditionMessage(tryCatch(naxp_parse(pattern), naxp_error = identity))
    lines <- strsplit(message, "\n", fixed = TRUE)[[1]]
    sub("^  ", "", grep("^  The error is", lines, value = TRUE))
  }
  expect_identical(location("A{0}"), 'The error is at "{0}", after "A".')
  expect_identical(location("(A"), 'The error is at "(", at the start of the pattern.')
  expect_identical(location("A|"), "The error is at the end of the pattern.")
  # An error covering the whole pattern, or an empty one, adds no line.
  expect_identical(location("A!B!C"), character())
  expect_identical(location(""), character())
  # A long stretch before the error is shortened to its last 20 characters.
  expect_identical(
    location(paste0(strrep("A", 30), "{0}")),
    paste0('The error is at "{0}", after "...', strrep("A", 20), '".')
  )
})

test_that("a naxp_error for a non-ASCII pattern does not quote it", {
  error <- tryCatch(naxp_parse(paste0("AB", intToUtf8(0xA3))), naxp_error = identity)
  expect_s3_class(error, "naxp_error")
  expect_no_match(conditionMessage(error), "The error is", fixed = TRUE)
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

test_that("only a naxp, a single pattern string or a naxp_encoded vector is accepted as a naxp", {
  expected <- "must be a naxp, a single pattern string or a naxp_encoded vector"
  expect_error(naxp_encode("1012AB", c(nl_space, nl_space)), expected)
  expect_error(naxp_encode("1012AB", 1), expected)
  expect_error(naxp_compare(nl_space, 684114L), "`b` must be a naxp")
})

test_that("a naxp's properties are reported", {
  expect_identical(naxp_max_encoded_value(nl_space), 6760000L)
  expect_identical(naxp_max_length(nl_space), 7L)
  expect_identical(naxp_max_encoded_value(ten_digits), 1e10)
  expect_error(naxp_max_encoded_value(sixteen_digits), "10000000000000000, is above 2\\^53")
  expect_output(print(naxp_parse(sixteen_digits)), "Maximum encoded value: 10000000000000000", fixed = TRUE)
})

test_that("a naxp_encoded vector stands for the naxp that encoded it", {
  codes <- naxp_encode(c("1012AB", "junk"), nl_space)
  expect_identical(naxp_pattern(codes), nl_space)
  expect_identical(naxp_max_encoded_value(codes), 6760000L)
  expect_identical(naxp_encode("9999ZZ", codes), naxp_encode("9999ZZ", nl_space))
  expect_identical(naxp_accepts("1012-AB", codes), FALSE)
  expect_identical(naxp_decode(1L, codes), "0000 AA")
  expect_identical(naxp_encoded(1L, codes), naxp_encode("0000AA", nl_space))
  expect_identical(naxp_compare(codes, nl_hyphen)[["encoding"]], "subset_of")
  expect_match(naxp_emit(codes, "c"), "max_encoded_value", fixed = TRUE)
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
