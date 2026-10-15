# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

# Compiled naxps, keyed by pattern. A naxp object holds only its pattern, so it
# survives saveRDS() and parallel workers; the compiled form is built here when
# first needed in a session.
naxp_cache <- new.env(parent = emptyenv())

#' Parse a naxp
#'
#' Parses the pattern of a naxp, checking that it is valid, and returns a naxp
#' for the other functions in the package.
#'
#' A naxp holds only its pattern. The compiled naxp is kept for the rest of the
#' session, so parsing the same pattern again is cheap, and a naxp saved with
#' [saveRDS()] or sent to a parallel worker is compiled again when first used.
#'
#' Every function that takes a naxp also accepts a pattern string, which it
#' parses in the same way.
#'
#' @param pattern A single string: the pattern of the naxp.
#'
#' @returns A naxp: an object of class `naxp` holding the pattern.
#'
#' @section Errors:
#' An invalid pattern raises a condition of class `naxp_error`, which is also an
#' `error`. Its fields are named as in the other naxp libraries:
#'
#' * `code`: the error code, such as `"NAXP1025"`, which is the same in every
#'   version.
#' * `message`: what is wrong, and where practical what to write instead.
#' * `offset`: where the error starts, in characters from the start of the
#'   pattern, counting from 0 as the other naxp libraries do.
#' * `length`: how many characters the error covers.
#' * `pattern`: the pattern.
#'
#' Each error code is explained at <https://naxp.org/error-codes/>.
#'
#' @seealso [naxp_encode()] to encode text, and [naxp_pattern()] for a naxp's
#'   properties.
#'
#' @examples
#' nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#' nl_postcode
#'
#' # An invalid pattern raises a naxp_error
#' tryCatch(
#'   naxp_parse(r"(\9\9\9\9 [A-)"),
#'   naxp_error = function(error) error$code
#' )
#' @export
naxp_parse <- function(pattern) {
  call <- sys.call()
  if (!is.character(pattern) || length(pattern) != 1L || is.na(pattern)) {
    raise("`pattern` must be a single string.", call)
  }
  pattern <- as.character(pattern)
  compiled_naxp(pattern, call)
  new_naxp(pattern)
}

#' @export
format.naxp <- function(x, ...) {
  as.character(x)
}

#' @export
print.naxp <- function(x, ...) {
  pointer <- pointer_of(x, sys.call())
  cat(
    "<naxp> ", as.character(x), "\n",
    "Maximum encoded value: ", cpp_naxp_max_encoded_value_text(pointer), "\n",
    sep = ""
  )
  invisible(x)
}

#' Properties of a naxp
#'
#' The pattern a naxp was parsed from, its largest encoded value, the length of
#' its longest canonical form, and the naxp an encoded vector carries.
#'
#' Encoded values run from 1 to the maximum with no gaps, so the maximum is also
#' the number of distinct encoded values. It is an integer where it is at most
#' 2^31 - 1 and a double where it is at most 2^53. Above 2^53, which is the
#' largest whole number R holds exactly, `naxp_max_encoded_value()` raises an
#' error, although printing the naxp still shows the maximum.
#'
#' @param naxp A naxp from [naxp_parse()], or a pattern string.
#' @param x A [naxp_encoded] vector.
#'
#' @returns
#' * `naxp_pattern()`: a single string.
#' * `naxp_max_encoded_value()`: a single integer or double.
#' * `naxp_max_length()`: a single integer.
#' * `naxp_of()`: a naxp.
#'
#' @examples
#' nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#' naxp_pattern(nl_postcode)
#' naxp_max_encoded_value(nl_postcode)
#' naxp_max_length(nl_postcode)
#'
#' codes <- naxp_encode(c("1012AB", "9999 ZZ"), nl_postcode)
#' naxp_of(codes)
#' @name naxp_properties
NULL

#' @rdname naxp_properties
#' @export
naxp_pattern <- function(naxp) {
  as.character(as_naxp(naxp, sys.call()))
}

#' @rdname naxp_properties
#' @export
naxp_max_encoded_value <- function(naxp) {
  call <- sys.call()
  pointer <- pointer_of(as_naxp(naxp, call), call)
  storage <- value_storage(pointer, call)
  value <- cpp_naxp_max_encoded_value(pointer)
  if (storage == 0L) as.integer(value) else value
}

#' @rdname naxp_properties
#' @export
naxp_max_length <- function(naxp) {
  call <- sys.call()
  cpp_naxp_max_length(pointer_of(as_naxp(naxp, call), call))
}

#' @rdname naxp_properties
#' @export
naxp_of <- function(x) {
  if (!inherits(x, "naxp_encoded")) {
    raise("`x` must be a naxp_encoded vector.", sys.call())
  }
  attr(x, "naxp")
}

new_naxp <- function(pattern) {
  structure(pattern, class = "naxp")
}

# A naxp from either a naxp or a pattern string.
as_naxp <- function(naxp, call, argument = "naxp") {
  if (inherits(naxp, "naxp")) {
    return(naxp)
  }
  if (inherits(naxp, "naxp_encoded")) {
    raise(sprintf("`%s` is a naxp_encoded vector. Use naxp_of() for its naxp.", argument), call)
  }
  if (is.character(naxp) && length(naxp) == 1L && !is.na(naxp)) {
    pattern <- as.character(naxp)
    compiled_naxp(pattern, call)
    return(new_naxp(pattern))
  }
  raise(sprintf("`%s` must be a naxp or a single pattern string.", argument), call)
}

same_naxp <- function(a, b) {
  identical(as.character(a), as.character(b))
}

pointer_of <- function(naxp, call) {
  compiled_naxp(as.character(naxp), call)
}

# The compiled naxp for a pattern, from the cache where possible. Only valid
# patterns are cached, and they are always non-empty ASCII.
compiled_naxp <- function(pattern, call) {
  cacheable <- nzchar(pattern) && all(charToRaw(pattern) < as.raw(0x80))
  if (cacheable) {
    pointer <- naxp_cache[[pattern]]
    if (!is.null(pointer)) {
      return(pointer)
    }
  }
  result <- cpp_naxp_parse(pattern)
  if (is.null(result$pointer)) {
    stop(new_naxp_error(result, pattern, call))
  }
  if (cacheable) {
    assign(pattern, result$pointer, envir = naxp_cache)
  }
  result$pointer
}

# 0 where a naxp's encoded values are integers, 1 where they are doubles. Raises
# an error where they are too large for R to hold exactly.
value_storage <- function(pointer, call) {
  storage <- cpp_naxp_storage(pointer)
  if (storage == 2L) {
    raise(
      sprintf(
        paste(
          "This naxp's maximum encoded value, %s, is above 2^53, the largest",
          "whole number R holds exactly, so its encoded values are not supported in R."
        ),
        cpp_naxp_max_encoded_value_text(pointer)
      ),
      call
    )
  }
  storage
}

new_naxp_error <- function(parts, pattern, call) {
  structure(
    class = c("naxp_error", "error", "condition"),
    list(
      message = parts$message,
      call = call,
      code = parts$code,
      offset = as.integer(parts$offset),
      length = as.integer(parts$length),
      pattern = pattern,
      summary = parts$summary
    )
  )
}

#' @export
conditionMessage.naxp_error <- function(c) {
  lines <- c$summary
  if (c$length > 0L && !grepl("[^ -~]", c$pattern, useBytes = TRUE)) {
    lines <- c(
      lines,
      paste0("  ", c$pattern),
      paste0("  ", strrep(" ", c$offset), strrep("^", c$length))
    )
  }
  lines <- c(lines, paste0("See https://naxp.org/error-codes/#", tolower(c$code)))
  paste(lines, collapse = "\n")
}

raise <- function(message, call) {
  stop(simpleError(message, call))
}
