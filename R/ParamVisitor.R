#' @title Visitor to traverse ParamHandle
#' @format \code{\link{R6Class}} object
#'
#' @description
#' A \code{\link[R6]{R6Class}} to visit ParamHandle.
#'
#' @return [\code{\link{ParamVisitor}}].
#' @family ParamHelpers
#' @export

ParamVisitor = R6Class("ParamVisitor",
  inherit = ParamBase, # FIXME: Are we sure? Yes!
  public = list(

    # member variables
    host = NULL,
    # constructor
    initialize = function(host) {
      self$host = host
    },

    # public methods

    traverseMand = function(arg)
    {
      if(length(self$host$mand.children) == 0) return(FALSE)
      for(name in names(self$host$mand.children)) {
        handle = self$host$mand.children[[name]]
        if(handle$visitor$traverse(arg)) {
          #self$host$addCondChild(ParamHandle$new(id = arg$id, val = arg$val))
          return(TRUE)
        }
      }
      return(FALSE)
    },
    traverseCond = function(arg) {
      if(length(self$host$cond.children) == 0) return(FALSE)
      for(name in names(self$host$cond.children)) {
        handle = self$host$cond.children[[name]]
        if(handle$visitor$traverse(arg)) {
          #self$host$addCondChild(ParamHandle$new(id = arg$id, val = arg$val))
          return(TRUE)
        }
      }
      return(FALSE)
    },
    fun.hit = function(x, args) {
      return(TRUE)
    },
    parseFlat = function(node.list) {
      len = length(node.list)
      SAFECOUNTER = 0
      while(length(node.list) != 0) {
        for(name in names(node.list)) {
          catf("parsing %s",name)
          if(self$traverse(node.list[[name]])) node.list[[name]] = NULL
          catf("number in wait list left %d",length(node.list))
        }
        SAFECOUNTER = SAFECOUNTER + 1
        if(SAFECOUNTER > 10 * len) stop("wrong flat input!")
      }
    },
    ## traverse the tree to find out if the the arg could be inserted
    traverse = function(arg) {
      # always check arg$depend not null!!
      if(is.null(arg$depend)) {
        catf("hit %s", arg$id)
        self$host$addMandChild(ParamHandle$new(id = arg$id, val = arg$val))
        return(TRUE)
      }
      # now the input arg has a field called depend
      if(is.null(arg$depend$val)) stop("missing val filed in depend!")
      if(is.null(self$host$val)) {  # always try to expore the possibility to explore true first
        if(self$traverseMand(arg)) return(TRUE)  # child will be added inside the recursion
        if(self$traverseCond(arg)) return(TRUE)  # child will be added inside the recursion
      }
      # now the self$host$val is not null
      if(self$host$val == arg$depend$val)
      {
        catf("hit %s", arg$id)
        self$host$addMandChild(ParamHandle$new(id = arg$id, val = arg$val))
        return(TRUE)
      }
      if(self$traverseMand(arg)) return(TRUE)  # child will be added inside the recursion
      if(self$traverseCond(arg)) return(TRUE)  # child will be added inside the recursion
      return(FALSE)
    },

    # check if the flat form of paramset violates the dependency
    checkValidFromFlat = function(input = list(model = list(val = "svm"), kernel = list(val = "rbf", depend = list(val = "svm")), gamma =list(val = "0.3" ,depend = list(val = "rbf")))) {
      fq = list()  # finished queue
      wq = input   # waiting queue
      hit = TRUE
      findDependNode = function(fq, node) {
        for(name in names(fq)) {
          if(node$depend$val == fq[[name]]$val) return(TRUE)
        }
        return(FALSE)
      }
      while(hit)
      {
        hit = FALSE
        for(name in names(wq)) {
          if(is.null(wq[[name]]$depend) | findDependNode(wq[[name]])) {
            regi(name)
            fq[[name]] =  wq[[name]]
            wq[[name]] = NULL
            hit = TRUE
          }
        }
      }
      if(length(wq) > 0) stop("invalid parameter set!")
    }
  )
)
