# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

#' Encode and decode text
#'
#' `naxp_encode()` encodes text as encoded values under a naxp, and
#' `naxp_decode()` decodes them back to the canonical form of the text.
#'
#' Each text a naxp accepts encodes to a whole number from 1 to its maximum
#' encoded value. Several texts may share a value, such as a postcode written
#' with and without a space, and each value decodes to one canonical form.
#'
#' Text the naxp does not accept is invalid and encodes to 0, as in every naxp
#' library. So does `NA`, and so does any text that is not ASCII, whatever its
#' marked encoding. Encoded values are never `NA`. `naxp_decode()` returns
#' `NA` for 0, because no other string can stand for it: a naxp may accept the
#' empty string.
#'
#' Encoded values are held as integers where the naxp's maximum encoded value
#' is at most 2^31 - 1, and as doubles where it is at most 2^53. Above 2^53,
#' which is the largest whole number R holds exactly, both functions raise an
#' error.
#'
#' @param text A character vector.
#' @param naxp A naxp from [naxp_parse()], a pattern string or a [naxp_encoded]
#'   vector, whose naxp is used. For `naxp_decode()`, it is needed only where
#'   `x` is not a [naxp_encoded] vector.
#' @param x A [naxp_encoded] vector, or an integer or double vector of encoded
#'   values. Bare values must be whole numbers from 0 to the naxp's maximum
#'   encoded value, or `NA`.
#'
#' @returns
#' * `naxp_encode()`: a [naxp_encoded] vector the same length as `text`, with
#'   its names.
#' * `naxp_decode()`: a character vector the same length as `x`, with its
#'   names, holding `NA` where a value is 0 or `NA`.
#'
#' @seealso [naxp_accepts()] and [naxp_canonical_form()] to check text without
#'   encoding it.
#'
#' @examples
#' nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' codes <- naxp_encode(c("1012AB", "1012 AB", "not a postcode"), nl_postcode)
#' codes
#' as.integer(codes)
#'
#' naxp_decode(codes)
#' naxp_decode(684114L, nl_postcode)
#' @export
naxp_encode <- function(text, naxp) {
  call <- sys.call()
  check_text(text, call)
  naxp <- as_naxp(naxp, call)
  pointer <- pointer_of(naxp, call)
  value_storage(pointer, call)
  values <- cpp_naxp_encode(pointer, text)
  names(values) <- names(text)
  new_naxp_encoded(values, naxp)
}

#' @rdname naxp_encode
#' @export
naxp_decode <- function(x, naxp = NULL) {
  call <- sys.call()
  if (inherits(x, "naxp_encoded")) {
    own <- attr(x, "naxp")
    if (!is.null(naxp) && !same_naxp(as_naxp(naxp, call), own)) {
      raise("`naxp` is not the naxp `x` was encoded with.", call)
    }
    naxp <- own
    values <- bare_values(x)
  } else {
    if (!is.numeric(x)) {
      raise("`x` must be a naxp_encoded vector, or integer or double.", call)
    }
    if (is.null(naxp)) {
      raise("`naxp` is needed where `x` is not a naxp_encoded vector.", call)
    }
    naxp <- as_naxp(naxp, call)
    values <- x
  }
  pointer <- pointer_of(naxp, call)
  value_storage(pointer, call)
  text <- with_call(cpp_naxp_decode(pointer, values, "x"), call)
  names(text) <- names(x)
  text
}

#' Check text against a naxp
#'
#' `naxp_accepts()` says whether a naxp accepts each text, and
#' `naxp_canonical_form()` gives the form each accepted text decodes to.
#'
#' Neither needs the text's encoded value, so both work for a naxp of any
#' size.
#'
#' @inheritParams naxp_encode
#'
#' @returns
#' * `naxp_accepts()`: a logical vector the same length as `text`, with its
#'   names. It is `FALSE`, never `NA`, for `NA` and for invalid text.
#' * `naxp_canonical_form()`: a character vector the same length as `text`,
#'   with its names, holding `NA` for `NA` and for invalid text.
#'
#' @examples
#' nl_postcode <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' naxp_accepts(c("1012AB", "1012 AB", "1012-AB"), nl_postcode)
#' naxp_canonical_form(c("1012AB", "1012 AB", "1012-AB"), nl_postcode)
#' @export
naxp_accepts <- function(text, naxp) {
  call <- sys.call()
  check_text(text, call)
  result <- cpp_naxp_accepts(pointer_of(as_naxp(naxp, call), call), text)
  names(result) <- names(text)
  result
}

#' @rdname naxp_accepts
#' @export
naxp_canonical_form <- function(text, naxp) {
  call <- sys.call()
  check_text(text, call)
  result <- cpp_naxp_canonical_form(pointer_of(as_naxp(naxp, call), call), text)
  names(result) <- names(text)
  result
}

check_text <- function(text, call) {
  if (inherits(text, "naxp")) {
    raise("`text` is a naxp, but the text comes first, as in naxp_encode(text, naxp).", call)
  }
  if (is.factor(text)) {
    raise("`text` is a factor. Convert it with as.character() first.", call)
  }
  if (!is.character(text)) {
    raise("`text` must be a character vector.", call)
  }
}
