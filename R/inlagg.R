#' Autoplot INLA obj
#' 
#' With \code{\link[inlar]{as_tibble}}, plotting the result is straightforward
#' with ggplot, here is just some basic quick plots which might not be what you
#' want.
#' 
#' @param  obj INLA model 
#' @param term term to plot 
#' @param type summary or marginal 
#' @param plot default to FALSE retrun a tibble available on assign.
#' @export 
autoplot.inla <- function(
    obj, 
    type = char(summary), # TODO: add suport for marginals type
    term = char(random, fitted.values) # TODO: add support for linear.predictor
    )
{
    .args <- as.list(match.call()[-1])
    o <- do.call(as_tibble, .args)
    if (term=='random')
        o <- o %>%
            ggplot(aes(id, q50, ymin = q025, ymax = q975)) +
            geom_line() +
            geom_ribbon(aes(fill = var), alpha = .5) +
            facet_wrap(~var)
    if (term == "fitted.values") {
        y_name <- obj$.args$formula %>% as.list() %>% purrr::pluck(2)
        o <- o %>% ggplot(aes(q50, !!y_name)) + geom_point()
    }
    o
}