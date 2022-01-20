#' Character encode
#' 
#' @param ... list of unquote variables
#' @export
char <- function(...) as.character(substitute(...()))
