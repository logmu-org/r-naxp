# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

# Netherlands postcodes, from naxp.org's standard naxps: printed with a space,
# without one, and accepting a hyphen. 6 760 000 encoded values.
nl_space <- r"(\9\9\9\9 \s!! \A\A)"
nl_no_separator <- r"(\9\9\9\9 \s!? \A\A)"
nl_hyphen <- r"(\9\9\9\9 (\s|\-)?!(\s) \A\A)"

# Ten digits: 10^10 encoded values, held as doubles.
ten_digits <- r"(\9{10})"

# Sixteen digits: 10^16 encoded values, above 2^53.
sixteen_digits <- r"(\9{16})"
