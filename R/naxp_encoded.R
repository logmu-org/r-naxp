# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

#' Encoded vectors
#'
#' @description
#' A `naxp_encoded` vector comprises the encoded values plus, as an attribute,
#' the naxp that encoded them, which means it can always be decoded back to
#' (canonical) text.
#'
#' Use [naxp_encode()] to create a `naxp_encoded` vector from a vector of text
#' and a naxp.
#'
#' # Storage
#'
#' The storage type used for the encoded values depends on the naxp's maximum
#' encoded value as follows:
#' - less than \eqn{2^{31}}{2^31} is `integer`,
#' - \eqn{2^{31}}{2^31} to \eqn{2^{53}}{2^53} is `double`, and
#' - more than \eqn{2^{53}}{2^53} raises an error (when a function that needs
#'   encoded values, such as [naxp_encode()], is called, *not* when a `naxp` is
#'   created).
#'
#' Invalid text is *always* stored as `0`, never `NA`.
#'
#' # Missing values
#'
#' [is.na()] and [anyNA()] treat an encoded value of 0 as missing, which ensures
#' that the encoded values of invalid text and `NA` text are both treated as
#' missing. In particular, `is.na(x)` matches `is.na(naxp_decode(x))` and
#' [na.omit()] drops missing values.
#'
#' Beware that code that reads the stored values directly will *not* treat the 0
#' as missing. For instance, [as.numeric()] passes 0 through unchanged, and
#' [complete.cases()] and functions built on vctrs, such as `tidyr::drop_na()`
#' and `dplyr::coalesce()`, treat 0 as present.
#'
#' # Printing and conversion
#'
#' A `naxp_encoded` vector prints as its canonical text, with 0 shown as
#' `<invalid (0)>`. [as.character()] produces the text, with `NA` for 0.
#'
#' Use [as.integer()] or [as.numeric()] to obtain the underlying encoded values.
#'
#' # Subsetting, assignment and combining
#'
#' Subsetting, [rep()], [rev()], [unique()] and [sort()] return `naxp_encoded`
#' vectors with the same naxp. [split()] returns a list of `naxp_encoded`
#' vectors, again with the same naxp. Indexing out of range or with `NA` gives
#' 0. A `naxp_encoded` vector can be a data frame column. [order()] and
#' [match()] return integer indices, and [table()] counts each distinct value,
#' labelled with its text, excluding 0.
#'
#' Assigning into a `naxp_encoded` vector accepts
#' - another `naxp_encoded` vector with the same naxp,
#' - text, which is encoded, or
#' - `NA`, which is mapped to 0.
#'
#' `is.na(x) <- i` sets those elements to 0.
#'
#' [c()] combines `naxp_encoded` vectors with the same naxp.
#'
#' # Comparison
#'
#' Encoded values are compared only for equality. `==` and `!=` compare a
#' `naxp_encoded` vector with one with the same naxp, with text, which is
#' encoded first, or with numbers as underlying values, so `x == 0` finds the
#' invalid text.
#'
#' [sort()] and [order()] sort by encoded value, but arithmetic, `<`, `>` and
#' summaries such as [max()] raise errors.
#'
#' @seealso [naxp_encode()] to create a `naxp_encoded` vector from text and a
#'   naxp.
#'
#' [naxp_encoded()] to recreate a `naxp_encoded` vector from its
#'   underlying values.
#'
#' @examples
#' postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' postcodes <- naxp_encode(c("1012AB", "9999 ZZ", "not a postcode"), postcode_naxp)
#' postcodes
#' as.integer(postcodes)
#' is.na(postcodes)
#'
#' postcodes == "1012 AB"
#' postcodes[2:3]
#' postcodes[3] <- "1012 AB"
#' postcodes
#'
#' data.frame(postcode = postcodes)
#' @name encoded-vectors
NULL

#' Recreate encoded vectors from underlying values
#'
#' @description
#' `naxp_encoded()` constructs a [naxp_encoded][encoded-vectors] vector from
#' its underlying encoded values.
#'
#' *This is a specialised operation &ndash; normal practice is to use
#' [naxp_encode()] to construct a `naxp_encoded` vector **from text**.*
#'
#' `naxp_encoded()` is exported so that encoded values previously extracted
#' using [as.integer()] or [as.numeric()] and saved in a database or a file can
#' be restored.
#'
#' @details
#' `values` must be non-negative integers up to the naxp's maximum encoded
#' value, stored as either `integer` or `double`. `NA` is an error, because an
#' encoded value is *never* `NA`: 0 means invalid text.
#'
#' It is `naxp`, not the type of `values`, that decides how the values are
#' stored:
#'
#' - `integer` if the naxp's maximum encoded value is less than
#'   \eqn{2^{31}}{2^31}, or
#' - `double` if it is in the range \eqn{2^{31}}{2^31} to \eqn{2^{53}}{2^53}.
#'
#' If `naxp` has a maximum encoded value over \eqn{2^{53}}{2^53} then an error
#' is raised.
#'
#' @param values An `integer` or `double` vector of non-negative integers up to
#'   the naxp's maximum encoded value. `NA` is an error.
#' @param naxp A naxp from [naxp_parse()], a pattern string or a
#'   [naxp_encoded][encoded-vectors] vector, whose naxp is used.
#'
#' @returns A `naxp_encoded` vector the same length as `values`.
#'   If the elements of `values` are named then the same names are applied to
#'   the elements of the returned vector.
#'
#' @seealso [naxp_encode()] to create a `naxp_encoded` vector from text and a
#'   naxp.
#'
#' [naxp_encoded][encoded-vectors] for working with a `naxp_encoded` vector.
#'
#' @examples
#' postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' # Values saved earlier, such as a column read from a database
#' postcode_values <- c(684114L, 0L, 6760000L)
#'
#' postcodes <- naxp_encoded(postcode_values, postcode_naxp)
#' postcodes
#' @export
naxp_encoded <- function(values, naxp) {
  call <- sys.call()
  if (inherits(values, "naxp_encoded")) {
    raise("`values` is already a naxp_encoded vector.", call)
  }
  if (!is.numeric(values)) {
    raise("`values` must be integer or double.", call)
  }
  naxp <- as_naxp(naxp, call)
  pointer <- pointer_of(naxp, call)
  value_storage(pointer, call)
  checked <- with_call(cpp_naxp_check_values(pointer, values, "values"), call)
  names(checked) <- names(values)
  new_naxp_encoded(checked, naxp)
}

new_naxp_encoded <- function(values, naxp) {
  attr(values, "naxp") <- naxp
  class(values) <- "naxp_encoded"
  values
}

# The values without the class or the naxp, keeping names.
bare_values <- function(x) {
  x <- unclass(x)
  attr(x, "naxp") <- NULL
  x
}

# Positions a vector gained by being lengthened, or by indexing out of range or
# with NA, hold NA; encoded values never do.
fill_zero <- function(values) {
  if (anyNA(values)) {
    values[is.na(values)] <- if (is.integer(values)) 0L else 0
  }
  values
}

# Values to assign into, or compare with, a naxp_encoded vector under `naxp`.
values_under <- function(value, naxp, call, numbers_allowed) {
  if (inherits(value, "naxp_encoded")) {
    if (!same_naxp(attr(value, "naxp"), naxp)) {
      raise("These values were encoded with different naxps.", call)
    }
    return(bare_values(value))
  }
  if (is.character(value)) {
    return(cpp_naxp_encode(pointer_of(naxp, call), value))
  }
  if (numbers_allowed && is.numeric(value)) {
    return(value)
  }
  # Assigning NA stores 0, as encoding NA does.
  if (!numbers_allowed && is.logical(value) && all(is.na(value))) {
    return(integer(length(value)))
  }
  raise(
    if (numbers_allowed) {
      paste(
        "A naxp_encoded vector can be compared only with one with the same naxp,",
        "with text, or with numbers as underlying values."
      )
    } else {
      "Assign a naxp_encoded vector with the same naxp, text to encode, or NA."
    },
    call
  )
}

#' @export
format.naxp_encoded <- function(x, ...) {
  text <- naxp_decode(x)
  text[bare_values(x) == 0] <- "<invalid (0)>"
  text
}

#' @export
print.naxp_encoded <- function(x, ...) {
  cat("<naxp_encoded[", length(x), "]> ", as.character(attr(x, "naxp")), "\n", sep = "")
  if (length(x) > 0L) {
    print(format(x), quote = FALSE)
  }
  invisible(x)
}

#' @export
as.character.naxp_encoded <- function(x, ...) {
  text <- naxp_decode(x)
  names(text) <- NULL
  text
}

#' @export
is.na.naxp_encoded <- function(x) {
  bare_values(x) == 0
}

#' @export
anyNA.naxp_encoded <- function(x, recursive = FALSE) {
  any(bare_values(x) == 0)
}

#' @export
as.data.frame.naxp_encoded <- function(
    x,
    row.names = NULL,
    optional = FALSE,
    ...,
    nm = deparse1(substitute(x))) {
  as.data.frame.vector(x, row.names = row.names, optional = optional, ..., nm = nm)
}

#' @export
`[.naxp_encoded` <- function(x, ...) {
  new_naxp_encoded(fill_zero(NextMethod()), attr(x, "naxp"))
}

#' @export
`[[.naxp_encoded` <- function(x, ...) {
  new_naxp_encoded(NextMethod(), attr(x, "naxp"))
}

#' @export
`[<-.naxp_encoded` <- function(x, ..., value) {
  naxp <- attr(x, "naxp")
  value <- values_under(value, naxp, sys.call(), numbers_allowed = FALSE)
  x <- bare_values(x)
  x[...] <- value
  new_naxp_encoded(fill_zero(x), naxp)
}

#' @export
`[[<-.naxp_encoded` <- function(x, ..., value) {
  naxp <- attr(x, "naxp")
  value <- values_under(value, naxp, sys.call(), numbers_allowed = FALSE)
  x <- bare_values(x)
  x[[...]] <- value
  new_naxp_encoded(fill_zero(x), naxp)
}

#' @export
`length<-.naxp_encoded` <- function(x, value) {
  naxp <- attr(x, "naxp")
  x <- bare_values(x)
  length(x) <- value
  new_naxp_encoded(fill_zero(x), naxp)
}

#' @export
c.naxp_encoded <- function(...) {
  parts <- Filter(Negate(is.null), list(...))
  naxp <- attr(parts[[1L]], "naxp")
  for (part in parts) {
    if (!inherits(part, "naxp_encoded") || !same_naxp(attr(part, "naxp"), naxp)) {
      raise("Only naxp_encoded vectors with the same naxp can be combined.", sys.call())
    }
  }
  new_naxp_encoded(unlist(lapply(parts, bare_values)), naxp)
}

#' @export
rep.naxp_encoded <- function(x, ...) {
  new_naxp_encoded(NextMethod(), attr(x, "naxp"))
}

#' @export
unique.naxp_encoded <- function(x, incomparables = FALSE, ...) {
  new_naxp_encoded(unique(bare_values(x), incomparables = incomparables, ...), attr(x, "naxp"))
}

#' @export
xtfrm.naxp_encoded <- function(x) {
  bare_values(x)
}

# Registered on base's mtfrm() in .onLoad where that generic exists, so match()
# and %in% compare encoded values without decoding them.
mtfrm_naxp_encoded <- function(x) {
  bare_values(x)
}

#' @export
Ops.naxp_encoded <- function(e1, e2) {
  call <- sys.call()
  if (!(.Generic %in% c("==", "!="))) {
    raise(
      sprintf(
        paste(
          "`%s` is not defined for naxp_encoded values, which support only == and !=.",
          "Use as.numeric() for the underlying values."
        ),
        .Generic
      ),
      call
    )
  }
  naxp <- if (inherits(e1, "naxp_encoded")) attr(e1, "naxp") else attr(e2, "naxp")
  e1 <- values_under(e1, naxp, call, numbers_allowed = TRUE)
  e2 <- values_under(e2, naxp, call, numbers_allowed = TRUE)
  if (.Generic == "==") e1 == e2 else e1 != e2
}

#' @export
Math.naxp_encoded <- function(x, ...) {
  raise(
    sprintf("`%s()` is not defined for naxp_encoded values. Use as.numeric() for the underlying values.", .Generic),
    sys.call()
  )
}

#' @export
Summary.naxp_encoded <- function(..., na.rm = FALSE) {
  raise(
    sprintf("`%s()` is not defined for naxp_encoded values. Use as.numeric() for the underlying values.", .Generic),
    sys.call()
  )
}

# Shown by pillar, and so by tibble, where pillar is installed.
type_sum_naxp_encoded <- function(x) {
  "naxp"
}

pillar_shaft_naxp_encoded <- function(x, ...) {
  text <- format(x)
  invalid <- bare_values(x) == 0
  text[invalid] <- pillar::style_subtle(text[invalid])
  pillar::new_pillar_shaft_simple(text, align = "left")
}
