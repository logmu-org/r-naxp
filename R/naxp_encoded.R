# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

#' Encoded values
#'
#' A `naxp_encoded` vector holds encoded values together with the naxp that
#' encoded them, so it can always be decoded. [naxp_encode()] returns one, and
#' `naxp_encoded()` makes one from bare values, such as values read from a
#' database or a file.
#'
#' The values are integers where the naxp's maximum encoded value is at most
#' 2^31 - 1, and doubles where it is at most 2^53. Above 2^53 is an error. 0
#' stands for text that is not valid. Encoded values are never `NA`.
#'
#' A `naxp_encoded` vector prints as the text it decodes to, with 0 shown as
#' `<invalid (0)>`. [as.character()] gives the text, with `NA` for 0, and
#' [as.integer()] or [as.numeric()] give the bare values.
#'
#' Subsetting, [rep()], [rev()], [unique()] and [sort()] return `naxp_encoded`
#' vectors with the same naxp, and [split()] returns a list of them. A
#' `naxp_encoded` vector can be a data frame column. [order()] and [match()]
#' return integer indices, and [table()] counts each distinct value, labelled
#' with its text, excluding 0. Assigning into a `naxp_encoded` vector accepts
#' another with the same naxp, or text, which is encoded. [c()] combines
#' `naxp_encoded` vectors with the same naxp.
#'
#' Encoded values are compared only for equality. `==` and `!=` compare a
#' `naxp_encoded` vector with one with the same naxp, with text, which is
#' encoded first, or with numbers as bare values, so `x == 0` finds the
#' invalid text. Arithmetic, `<`, `>` and summaries such as [max()] raise
#' errors. [sort()] and [order()] sort by encoded value.
#'
#' @param values An integer or double vector of whole numbers from 0 to the
#'   naxp's maximum encoded value. `NA` is an error.
#' @param naxp A naxp from [naxp_parse()], a pattern string or a [naxp_encoded]
#'   vector, whose naxp is used.
#'
#' @returns A `naxp_encoded` vector the same length as `values`, with its
#'   names.
#'
#' @examples
#' nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' codes <- naxp_encoded(c(684114, 0, 6760000), nl_postcode)
#' codes
#' codes == "1012 AB"
#' codes == 0
#'
#' data.frame(postcode = codes)
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

# Positions a vector gained by being lengthened hold NA; encoded values never do.
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
  raise(
    if (numbers_allowed) {
      paste(
        "A naxp_encoded vector can be compared only with one with the same naxp,",
        "with text, or with numbers as bare values."
      )
    } else {
      "Assign a naxp_encoded vector with the same naxp, or text, which is encoded."
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
  new_naxp_encoded(NextMethod(), attr(x, "naxp"))
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
          "Use as.numeric() for the bare values."
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
    sprintf("`%s()` is not defined for naxp_encoded values. Use as.numeric() for the bare values.", .Generic),
    sys.call()
  )
}

#' @export
Summary.naxp_encoded <- function(..., na.rm = FALSE) {
  raise(
    sprintf("`%s()` is not defined for naxp_encoded values. Use as.numeric() for the bare values.", .Generic),
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
