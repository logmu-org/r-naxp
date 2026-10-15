# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

codes_of <- function(text) {
  naxp_encode(text, nl_space)
}

test_that("a naxp_encoded vector shows its text, with 0 as <invalid (0)>", {
  codes <- codes_of(c("1012AB", "junk"))
  expect_identical(format(codes), c("1012 AB", "<invalid (0)>"))
  expect_output(print(codes), "<naxp_encoded[2]> \\9\\9\\9\\9 \\s!! \\A\\A", fixed = TRUE)
  expect_output(print(codes), "1012 AB +<invalid \\(0\\)>")
  expect_output(print(codes_of(character())), "<naxp_encoded[0]>", fixed = TRUE)
})

test_that("conversion gives the text, with NA for 0, or the bare values", {
  codes <- codes_of(c(a = "1012AB", b = "junk"))
  expect_identical(as.character(codes), c("1012 AB", NA))
  expect_identical(as.integer(codes), c(684114L, 0L))
  expect_identical(as.numeric(codes), c(684114, 0))
  expect_identical(is.na(codes), c(a = FALSE, b = FALSE))
})

test_that("subsetting and repeating keep the naxp", {
  codes <- codes_of(c("1012AB", "9999ZZ", "junk"))
  expect_identical(codes[2:3], codes_of(c("9999ZZ", "junk")))
  expect_identical(codes[[1]], codes_of("1012AB"))
  expect_identical(rep(codes[1], 2), codes_of(c("1012AB", "1012AB")))
  expect_identical(rev(codes), codes_of(c("junk", "9999ZZ", "1012AB")))
  expect_identical(unique(codes[c(1, 1, 3)]), codes_of(c("1012AB", "junk")))
  expect_identical(head(codes, 1), codes_of("1012AB"))
})

test_that("lengthening fills with 0, never NA", {
  codes <- codes_of("1012AB")
  length(codes) <- 3
  expect_identical(as.integer(codes), c(684114L, 0L, 0L))
  codes[5] <- "9999ZZ"
  expect_identical(as.integer(codes), c(684114L, 0L, 0L, 0L, 6760000L))
  codes[[7]] <- "0000AA"
  expect_identical(as.integer(codes), c(684114L, 0L, 0L, 0L, 6760000L, 0L, 1L))
})

test_that("assignment takes text, or values with the same naxp", {
  codes <- codes_of(c("1012AB", "9999ZZ"))
  codes[1] <- "0000 AA"
  expect_identical(as.integer(codes), c(1L, 6760000L))
  codes[2] <- codes_of("1012AB")
  expect_identical(as.integer(codes), c(1L, 684114L))
  codes[[1]] <- "junk"
  expect_identical(as.integer(codes), c(0L, 684114L))
  expect_error(codes[1] <- 5L, "Assign a naxp_encoded vector")
  expect_error(codes[1] <- naxp_encode("1012AB", nl_no_separator), "different naxps")
})

test_that("c() combines vectors with the same naxp only", {
  combined <- c(codes_of("1012AB"), codes_of("junk"), NULL)
  expect_identical(combined, codes_of(c("1012AB", "junk")))
  expect_error(c(codes_of("1012AB"), naxp_encode("1012AB", nl_no_separator)), "same naxp")
  expect_error(c(codes_of("1012AB"), 5L), "same naxp")
})

test_that("== and != compare values, text and bare numbers", {
  codes <- codes_of(c("1012AB", "9999ZZ", "junk"))
  expect_identical(codes == "1012 AB", c(TRUE, FALSE, FALSE))
  expect_identical("1012AB" == codes, c(TRUE, FALSE, FALSE))
  expect_identical(codes != "1012AB", c(FALSE, TRUE, TRUE))
  expect_identical(codes == 0, c(FALSE, FALSE, TRUE))
  expect_identical(codes == codes_of("9999 ZZ"), c(FALSE, TRUE, FALSE))
  expect_error(codes == naxp_encode("1012AB", nl_no_separator), "different naxps")
  expect_error(codes == list(1), "compared only")
})

test_that("arithmetic, ordering operators and summaries are errors", {
  codes <- codes_of(c("1012AB", "9999ZZ"))
  expect_error(codes + 1, "`\\+` is not defined")
  expect_error(codes < codes, "`<` is not defined")
  expect_error(-codes, "`-` is not defined")
  expect_error(!codes, "`!` is not defined")
  expect_error(max(codes), "`max\\(\\)` is not defined")
  expect_error(sum(codes), "`sum\\(\\)` is not defined")
  expect_error(abs(codes), "`abs\\(\\)` is not defined")
})

test_that("sorting and ordering go by encoded value", {
  codes <- codes_of(c("9999ZZ", "junk", "1012AB"))
  expect_identical(sort(codes), codes_of(c("junk", "1012AB", "9999ZZ")))
  expect_identical(order(codes), c(2L, 3L, 1L))
  expect_identical(xtfrm(codes), c(6760000L, 0L, 684114L))
})

test_that("match() and %in% compare encoded values", {
  codes <- codes_of(c("1012AB", "9999ZZ", "junk"))
  expect_identical(match(codes, codes_of("9999 ZZ")), c(NA, 1L, NA))
  expect_identical(codes %in% codes_of(c("1012AB", "junk")), c(TRUE, FALSE, TRUE))
  # Values, not text, so text matches nothing; == encodes text instead.
  expect_identical(codes %in% "1012 AB", c(FALSE, FALSE, FALSE))
})

test_that("split() and table() work", {
  codes <- codes_of(c("1012AB", "9999ZZ", "1012 AB"))
  parts <- split(codes, c(1, 2, 1))
  expect_identical(parts[["1"]], codes_of(c("1012AB", "1012AB")))
  counts <- table(codes)
  expect_identical(names(counts), c("1012 AB", "9999 ZZ"))
  expect_identical(as.vector(counts), c(2L, 1L))
})

test_that("a naxp_encoded vector works as a data frame column", {
  codes <- codes_of(c("1012AB", "junk"))
  frame <- data.frame(id = 1:2, postcode = codes)
  expect_identical(frame$postcode, codes)
  expect_output(print(frame), "<invalid (0)>", fixed = TRUE)
  expect_identical(rbind(frame, frame)$postcode, codes_of(c("1012AB", "junk", "1012AB", "junk")))
  merged <- merge(frame, data.frame(postcode = codes_of("1012 AB"), value = 5))
  expect_identical(merged$id, 1L)
  expect_identical(merged$postcode, codes_of("1012AB"))
})

test_that("a naxp_encoded vector survives saveRDS() and readRDS()", {
  codes <- codes_of(c("1012AB", "junk"))
  file <- tempfile(fileext = ".rds")
  on.exit(unlink(file))
  saveRDS(codes, file)
  restored <- readRDS(file)
  expect_identical(restored, codes)
  expect_identical(naxp_decode(restored), c("1012 AB", NA))
})

test_that("pillar shows the naxp type and the text", {
  skip_if_not_installed("pillar")
  codes <- codes_of(c("1012AB", "junk"))
  expect_identical(pillar::type_sum(codes), "naxp")
  shaft <- format(pillar::pillar_shaft(codes), width = 20)
  expect_match(as.character(shaft)[[1]], "1012 AB", fixed = TRUE)
  expect_match(as.character(shaft)[[2]], "<invalid (0)>", fixed = TRUE)
})
