# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

#' Standard naxps
#'
#' `naxp_standard()` gives one of the standard naxps built into every naxp
#' library, and `naxp_standards()` lists them all.
#'
#' The standard naxps are for widely used code systems such as postcodes. Each
#' has an id, such as `"uk-postcode"`, and one or more variants, one of which is
#' `"default"`. The id and the variant are matched without regard to ASCII case.
#' Once published, a standard naxp never changes, so values encoded with it
#' keep their meaning.
#'
#' The standard naxps are described at <https://naxp.org/standard/>.
#'
#' @param id A single string: the standard's id, such as `"uk-postcode"`.
#' @param variant A single string: the variant's id. `"default"` or `""` gives
#'   the default.
#'
#' @returns
#' * `naxp_standard()`: a naxp.
#' * `naxp_standards()`: a data frame with one row per variant, each
#'   standard's default first, and character columns `id`, `name` (for
#'   display), `variant`, `pattern` and `notes` (what the variant accepts and
#'   prints, in Markdown).
#'
#' @examples
#' uk_postcode <- naxp_standard("uk-postcode")
#' naxp_encode(c("EC4M 7AA", "EC4M7AA", "B1 1AA"), uk_postcode)
#'
#' naxp_standard("nl-postcode", "no-separator")
#'
#' naxp_standards()[, c("id", "variant")]
#' @export
naxp_standard <- function(id, variant = "default") {
  call <- sys.call()
  for (argument in c("id", "variant")) {
    value <- get(argument)
    if (!is.character(value) || length(value) != 1L || is.na(value)) {
      raise(sprintf("`%s` must be a single string.", argument), call)
    }
  }
  pattern <- cpp_naxp_standard_pattern(id, variant)
  if (is.na(pattern)) {
    standards <- naxp_standards()
    if (is.na(cpp_naxp_standard_pattern(id, ""))) {
      raise(
        sprintf(
          "There is no standard naxp with id \"%s\". The ids are %s.",
          id,
          paste(unique(standards$id), collapse = ", ")
        ),
        call
      )
    }
    raise(
      sprintf(
        "The standard naxp \"%s\" has no variant \"%s\". Its variants are %s.",
        id,
        variant,
        paste(standards$variant[standards$id == tolower(id)], collapse = ", ")
      ),
      call
    )
  }
  compiled_naxp(pattern, call)
  new_naxp(pattern)
}

#' @rdname naxp_standard
#' @export
naxp_standards <- function() {
  data.frame(cpp_naxp_all_standard_naxps())
}
