# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

test_that("text encodes to its encoded value and decodes to its canonical form", {
  codes <- naxp_encode(c("1012AB", "1012 AB", "0000 AA", "9999ZZ"), nl_space)
  expect_s3_class(codes, "naxp_encoded")
  expect_identical(as.integer(codes), c(684114L, 684114L, 1L, 6760000L))
  expect_identical(naxp_decode(codes), c("1012 AB", "1012 AB", "0000 AA", "9999 ZZ"))
})

test_that("decoding then encoding gives back the same values", {
  values <- c(seq(1L, 6760000L, by = 6761L), 6760000L)
  text <- naxp_decode(values, nl_space)
  expect_false(anyNA(text))
  expect_identical(as.integer(naxp_encode(text, nl_space)), values)
})

test_that("invalid text, NA and non-ASCII text all encode to 0", {
  latin1 <- "1012AB\xc4"
  Encoding(latin1) <- "latin1"
  bytes <- "1012\xc4B"
  Encoding(bytes) <- "bytes"
  text <- c("1012-AB", NA, "", paste0("1012 ", intToUtf8(0xC4), "B"), latin1, bytes)
  expect_identical(as.integer(naxp_encode(text, nl_space)), rep(0L, 6))
  expect_identical(naxp_accepts(text, nl_space), rep(FALSE, 6))
  expect_identical(naxp_canonical_form(text, nl_space), rep(NA_character_, 6))
})

test_that("NA encodes to 0 even where the naxp accepts the text \"NA\"", {
  codes <- naxp_encode(c(NA, "NA"), r"(\A\A)")
  expect_identical(as.integer(codes)[[1]], 0L)
  expect_gt(as.integer(codes)[[2]], 0L)
  expect_identical(naxp_accepts(c(NA, "NA"), r"(\A\A)"), c(FALSE, TRUE))
  expect_identical(naxp_canonical_form(c(NA, "NA"), r"(\A\A)"), c(NA, "NA"))
})

test_that("0 and NA decode to NA, and nothing else does", {
  expect_identical(naxp_decode(c(0L, NA, 684114L), nl_space), c(NA, NA, "1012 AB"))
  expect_identical(naxp_decode(c(0, NA, NaN, 684114), nl_space), c(NA, NA, NA, "1012 AB"))
})

test_that("a naxp can accept the empty string, so it is not the decoding of 0", {
  codes <- naxp_encode(c("", "A", "B"), "A?")
  expect_identical(as.integer(codes), c(1L, 2L, 0L))
  expect_identical(naxp_decode(codes), c("", "A", NA))
})

test_that("names are kept", {
  text <- c(a = "1012AB", b = "junk")
  expect_named(naxp_encode(text, nl_space), c("a", "b"))
  expect_named(naxp_accepts(text, nl_space), c("a", "b"))
  expect_named(naxp_canonical_form(text, nl_space), c("a", "b"))
  expect_named(naxp_decode(naxp_encode(text, nl_space)), c("a", "b"))
  expect_named(naxp_decode(c(a = 1L, b = 0L), nl_space), c("a", "b"))
})

test_that("empty input gives empty output", {
  codes <- naxp_encode(character(), nl_space)
  expect_s3_class(codes, "naxp_encoded")
  expect_length(codes, 0)
  expect_identical(naxp_decode(codes), character())
  expect_identical(naxp_accepts(character(), nl_space), logical())
})

test_that("naxp_accepts() and naxp_canonical_form() check text", {
  text <- c("1012AB", "1012 AB", "1012-AB")
  expect_identical(naxp_accepts(text, nl_space), c(TRUE, TRUE, FALSE))
  expect_identical(naxp_canonical_form(text, nl_space), c("1012 AB", "1012 AB", NA))
  expect_identical(naxp_canonical_form(text, nl_no_separator), c("1012AB", "1012AB", NA))
  expect_identical(naxp_canonical_form(text, nl_hyphen), c("1012 AB", "1012 AB", "1012 AB"))
})

test_that("text must be a character vector, and comes first", {
  expect_error(naxp_encode(factor("1012AB"), nl_space), "factor")
  expect_error(naxp_encode(1012, nl_space), "character vector")
  expect_error(naxp_encode(naxp_parse(nl_space), "1012AB"), "text comes first")
  expect_error(naxp_accepts(factor("1012AB"), nl_space), "factor")
  expect_error(naxp_canonical_form(1012, nl_space), "character vector")
})

test_that("naxp_decode() checks bare values", {
  expect_error(naxp_decode(c(1, 2.5), nl_space), "x\\[2\\] is 2.5, which is not a whole number")
  expect_error(naxp_decode(-1L, nl_space), "x\\[1\\] is -1, which is negative")
  expect_error(naxp_decode(6760001, nl_space), "above the naxp's maximum encoded value of 6760000")
  expect_error(naxp_decode(Inf, nl_space), "not a whole number")
  expect_error(naxp_decode("1", nl_space), "integer or double")
  expect_error(naxp_decode(1L), "`naxp` is needed")
})

test_that("naxp_decode() checks the naxp of an encoded vector", {
  codes <- naxp_encode("1012AB", nl_space)
  expect_identical(naxp_decode(codes, nl_space), "1012 AB")
  expect_error(naxp_decode(codes, nl_no_separator), "not the naxp")
})

test_that("encoded values are doubles above 2^31 - 1", {
  codes <- naxp_encode(c("0000000000", "9999999999"), ten_digits)
  expect_type(unclass(codes), "double")
  expect_identical(as.numeric(codes), c(1, 1e10))
  expect_identical(naxp_decode(codes), c("0000000000", "9999999999"))
})

test_that("encoded values above 2^53 are an error, but checking text is not", {
  text <- "1234567890123456"
  expect_error(naxp_encode(text, sixteen_digits), "above 2\\^53")
  expect_error(naxp_decode(1, sixteen_digits), "above 2\\^53")
  expect_error(naxp_encoded(1, sixteen_digits), "above 2\\^53")
  expect_true(naxp_accepts(text, sixteen_digits))
  expect_identical(naxp_canonical_form(text, sixteen_digits), text)
})

test_that("naxp_encoded() checks bare values and holds them in the naxp's storage", {
  codes <- naxp_encoded(c(a = 684114, b = 0), nl_space)
  expect_s3_class(codes, "naxp_encoded")
  expect_type(unclass(codes), "integer")
  expect_named(codes, c("a", "b"))
  expect_identical(naxp_decode(codes), c(a = "1012 AB", b = NA))
  expect_type(unclass(naxp_encoded(1L, ten_digits)), "double")

  expect_error(naxp_encoded(c(1, NA), nl_space), "values\\[2\\] is NA, but encoded values are never NA")
  expect_error(naxp_encoded(1.5, nl_space), "values\\[1\\] is 1.5")
  expect_error(naxp_encoded(6760001L, nl_space), "above the naxp's maximum")
  expect_error(naxp_encoded("1", nl_space), "integer or double")
  expect_error(naxp_encoded(codes, nl_space), "already a naxp_encoded")
})
