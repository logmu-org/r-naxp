# naxp: encoded ASCII expressions for R
#
# This file is licensed to you under the Apache Licence 2.0.
#
# Copyright (c) Tim Gordon

.onLoad <- function(libname, pkgname) {
  if (exists("mtfrm", envir = baseenv(), inherits = FALSE)) {
    registerS3method("mtfrm", "naxp_encoded", mtfrm_naxp_encoded, envir = baseenv())
  }
  register_suggested_method("pillar", "type_sum", "naxp_encoded", type_sum_naxp_encoded)
  register_suggested_method("pillar", "pillar_shaft", "naxp_encoded", pillar_shaft_naxp_encoded)
  invisible()
}

# Registers a method for a generic in a suggested package: now if the package is
# loaded, and otherwise whenever it is.
register_suggested_method <- function(package, generic, class, method) {
  register <- function(...) {
    registerS3method(generic, class, method, envir = asNamespace(package))
  }
  if (isNamespaceLoaded(package)) {
    register()
  }
  setHook(packageEvent(package, "onLoad"), register)
}
