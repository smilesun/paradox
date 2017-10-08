#' @title Untyped Parameter Object
#' @format \code{\link{R6Class}} object
#'
#' @description
#' A \code{\link[R6]{R6Class}} to represent untyped parameters.
#'
#' @return [\code{\link{ParamUntyped}}].
#' @family ParamSimple
#' @export
ParamUntyped = R6Class(
  "ParamUntyped",
  inherit = ParamSimple,
  public = list(
    # member variables

    # constructor
    initialize = function(id, default = NULL, tags = NULL) {
      check = function(x, na.ok = FALSE, null.ok = FALSE) {
        if (!na.ok && identical(x, NA)) "Value is NA"
        if (!null.ok && is.null(x)) "Value is NULL"
        return(TRUE)
      }

      # construct super class
      super$initialize(id = id, type = "list", check = check, default = default, tags = tags)
    },

    # public methods
    sampleVector = function(n = 1L) {
      stop("Untped Param can not be sampled")
    },
    denormVector = function(x) {
      stop("Untyped Param can not be denormed")
    }
  )
)