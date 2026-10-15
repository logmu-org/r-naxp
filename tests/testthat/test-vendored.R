# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

test_that("the vendored naxp library is 0.13.0", {
  expect_identical(cpp_naxp_version(), "0.13.0")
})
