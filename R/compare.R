# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

#' Compare two naxps
#'
#' `naxp_compare()` says how `b` stands to `a`: what happens to text and
#' encoded values held under `a` if `b` replaces it. `naxp_first_divergent_value()`
#' finds the lowest encoded value the two decode differently.
#'
#' `naxp_compare()` gives three set relationships, each from `a`'s point of
#' view:
#'
#' * `accepted_text`: how the strings `a` accepts stand to those `b` accepts.
#' * `encoding`: how the (text, encoded value) pairs `a` defines stand to those
#'   `b` defines. Replacing `a` with `b` is safe for stored values exactly when
#'   this is `"equal"` or `"subset_of"`.
#' * `canonical_forms`: how the canonical forms `a` prints stand to those `b`
#'   prints.
#'
#' Each is `"equal"`, `"subset_of"`, `"superset_of"` or `"incomparable"`.
#'
#' The encoding relationship is decided by walking the two naxps together,
#' which has a budget. No naxp anybody has reason to write comes near the
#' default, but a pair that does cannot be decided, and `naxp_compare()` then
#' raises an error rather than guess.
#'
#' @param a The naxp the data was encoded with: a naxp from [naxp_parse()], a
#'   pattern string or a [naxp_encoded] vector, whose naxp is used.
#' @param b The naxp proposed to replace it, likewise.
#' @param budget `NULL` for the library's default budget of 200 000 product
#'   states, or a positive whole number.
#'
#' @returns
#' * `naxp_compare()`: a named character vector with elements `accepted_text`,
#'   `encoding` and `canonical_forms`.
#' * `naxp_first_divergent_value()`: a single encoded value, or 0 where every
#'   value both naxps hold decodes alike. Values only one naxp holds do not
#'   count. It is an integer where both naxps' encoded values are integers, and
#'   otherwise a double.
#'
#' @examples
#' must_have_space <- naxp_parse(r"(\9\9\9\9 \s \A\A)")
#' prefers_space <- naxp_parse(r"(\9\9\9\9 \s!! \A\A)")
#' prefers_no_space <- naxp_parse(r"(\9\9\9\9 \s!? \A\A)")
#'
#' naxp_compare(must_have_space, prefers_space)
#'
#' naxp_compare(must_have_space, prefers_no_space)
#' naxp_first_divergent_value(must_have_space, prefers_no_space)
#' @export
naxp_compare <- function(a, b, budget = NULL) {
  call <- sys.call()
  a <- as_naxp(a, call, "a")
  b <- as_naxp(b, call, "b")
  if (is.null(budget)) {
    budget <- 0L
  } else {
    if (!is.numeric(budget) || length(budget) != 1L || is.na(budget) || budget < 1 ||
      budget != trunc(budget) || budget > .Machine$integer.max) {
      raise("`budget` must be NULL or a single positive whole number.", call)
    }
    budget <- as.integer(budget)
  }
  result <- cpp_naxp_compare(pointer_of(a, call), pointer_of(b, call), budget)
  if (is.null(result)) {
    budget <- if (budget > 0L) budget else cpp_naxp_default_budget()
    raise(
      sprintf(
        ngettext(
          budget,
          "The encoding relationship could not be decided within a budget of %d product state.",
          "The encoding relationship could not be decided within a budget of %d product states."
        ),
        budget
      ),
      call
    )
  }
  result
}

#' @rdname naxp_compare
#' @export
naxp_first_divergent_value <- function(a, b) {
  call <- sys.call()
  pointer_a <- pointer_of(as_naxp(a, call, "a"), call)
  pointer_b <- pointer_of(as_naxp(b, call, "b"), call)
  storage <- max(value_storage(pointer_a, call), value_storage(pointer_b, call))
  value <- cpp_naxp_first_divergent_value(pointer_a, pointer_b)
  if (storage == 0L) as.integer(value) else value
}

#' Emit a naxp as source code
#'
#' Writes a naxp as source code in another language: a fragment of declarations
#' that answer the same questions this package does, for that one naxp, with
#' no dependency on any naxp library. The header comment, includes, namespace
#' or wrapping class around it are yours to add.
#'
#' @param naxp A naxp from [naxp_parse()], a pattern string or a [naxp_encoded]
#'   vector, whose naxp is used.
#' @param language The language to emit: `"csharp"`, `"javascript"`, `"c"`
#'   (C99) or `"cpp"` (C++17).
#' @param prefix What every generated name starts with, so several naxps can
#'   share one scope. `""` gives the bare names. Each language applies its own
#'   casing convention to it.
#' @param value_type The integer type the generated code uses for encoded
#'   values. The naxp's maximum encoded value must fit it.
#' @param initial_indent What every line starts with ahead of its own
#'   indentation, so the fragment can sit inside an indented wrapper.
#' @param new_line What ends every line.
#' @param indent What one level of indentation is written as.
#'
#' @returns A single string: the fragment.
#'
#' @examples
#' cat(naxp_emit(r"(\9\9\9\9 \s!! \A\A)", "javascript", prefix = "postcodeNL"))
#' @export
naxp_emit <- function(
    naxp,
    language = c("csharp", "javascript", "c", "cpp"),
    prefix = "",
    value_type = c("uint64", "int64", "uint32", "int32", "uint16", "int16", "uint8", "int8"),
    initial_indent = "",
    new_line = "\n",
    indent = "\t") {
  call <- sys.call()
  naxp <- as_naxp(naxp, call)
  language <- match.arg(language)
  value_type <- match.arg(value_type)
  strings <- list(prefix = prefix, initial_indent = initial_indent, new_line = new_line, indent = indent)
  for (argument in names(strings)) {
    value <- strings[[argument]]
    if (!is.character(value) || length(value) != 1L || is.na(value)) {
      raise(sprintf("`%s` must be a single string.", argument), call)
    }
  }
  language_codes <- c(csharp = 0L, javascript = 1L, c = 2L, cpp = 3L)
  value_type_codes <- c(
    int8 = 0L, uint8 = 1L, int16 = 2L, uint16 = 3L,
    int32 = 4L, uint32 = 5L, int64 = 6L, uint64 = 7L
  )
  pointer <- pointer_of(naxp, call)
  with_call(
    cpp_naxp_emit(
      pointer,
      language_codes[[language]],
      prefix,
      value_type_codes[[value_type]],
      initial_indent,
      new_line,
      indent
    ),
    call
  )
}
