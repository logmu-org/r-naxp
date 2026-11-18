# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

#' Encode and decode text
#'
#' `naxp_encode()` encodes text using a naxp, and `naxp_decode()` decodes the
#' encoded values back to the canonical form of the text.
#'
#' Each text that a naxp accepts is encoded as an integer from 1 to the naxp's
#' maximum encoded value. Several texts may share an encoded value (for
#' instance, a postcode written with and without a space), but each encoded
#' value decodes to exactly one canonical form.
#'
#' # Invalid text
#'
#' Text that the naxp does not accept is invalid and is encoded as 0, as in
#' every naxp library. The same applies to
#' - `NA`, and
#' - any text that is not ASCII, whatever its marked encoding.
#'
#' Encoded values are *never* `NA`, although [is.na()] reports 0 as missing in
#' a [naxp_encoded][encoded-vectors] vector.
#'
#' `naxp_decode()` returns `NA` for 0. No string can represent 0, because a
#' naxp may accept the empty string.
#'
#' # Storage
#'
#' Encoded values are stored as
#' - `integer` if the naxp's maximum encoded value is less than
#'   \eqn{2^{31}}{2^31}, or
#' - `double` if it is in the range \eqn{2^{31}}{2^31} to \eqn{2^{53}}{2^53}.
#'
#' If the maximum encoded value is over \eqn{2^{53}}{2^53}, both functions
#' raise an error, because a `double` cannot store every integer over
#' \eqn{2^{53}}{2^53} exactly.
#'
#' @param text A character vector.
#' @param naxp A naxp from [naxp_parse()], a pattern string or a
#'   [naxp_encoded][encoded-vectors] vector, whose naxp is used. For
#'   `naxp_decode()`, it is needed only if `x` is not a
#'   [naxp_encoded][encoded-vectors] vector.
#' @param x A [naxp_encoded][encoded-vectors] vector, or an `integer` or
#'   `double` vector of underlying encoded values. Underlying encoded values
#'   must be non-negative integers up to the naxp's maximum encoded value, or
#'   `NA`.
#'
#' @returns
#' * `naxp_encode()`: a [naxp_encoded][encoded-vectors] vector the same
#'   length as `text`. If the elements of `text` are named then the same names
#'   are applied to the elements of the returned vector.
#' * `naxp_decode()`: a character vector of the decoded text, the same length
#'   as `x`. Where a value is 0 or `NA`, the text is `NA`. If the elements of
#'   `x` are named then the same names are applied to the elements of the
#'   returned vector.
#'
#' @seealso [naxp_accepts()] and [naxp_canonical_form()] to check text without
#'   encoding it.
#'
#'   Use [naxp_encoded()] to construct a [naxp_encoded][encoded-vectors]
#'   vector from its underlying values (e.g. when reading encoded values from a
#'   file or database).
#'
#' @examples
#' postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' postcodes <- naxp_encode(c("1012AB", "1012 AB", "not a postcode"), postcode_naxp)
#' postcodes
#' as.integer(postcodes)
#'
#' naxp_decode(postcodes)
#' naxp_decode(684114L, postcode_naxp)
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
#' `naxp_accepts()` tests whether a naxp accepts each text, and
#' `naxp_canonical_form()` returns the canonical form that each accepted text
#' decodes to.
#'
#' Neither function needs the text's encoded value, so both work for a naxp of
#' any size, including one whose maximum encoded value is over
#' \eqn{2^{53}}{2^53}.
#'
#' @inheritParams naxp_encode
#'
#' @returns
#' * `naxp_accepts()`: a logical vector the same length as `text`. It is
#'   `FALSE`, never `NA`, for `NA` and for invalid text. If the elements of
#'   `text` are named then the same names are applied to the elements of the
#'   returned vector.
#' * `naxp_canonical_form()`: a character vector the same length as `text`.
#'   Where `text` is `NA` or invalid, the canonical form is `NA`. If the
#'   elements of `text` are named then the same names are applied to the
#'   elements of the returned vector.
#'
#' @examples
#' postcode_naxp <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#'
#' naxp_accepts(c("1012AB", "1012 AB", "1012-AB"), postcode_naxp)
#' naxp_canonical_form(c("1012AB", "1012 AB", "1012-AB"), postcode_naxp)
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
