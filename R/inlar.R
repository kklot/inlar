#' Wrapper to add class to INLA's output
#' 
#' See \code{\link[INLA]{inla.posterior.sample}}
#'
#' @inheritParams INLA::inla.posterior.sample
#' @export
inla.posterior.sample <- function(...) {
    o <- INLA::inla.posterior.sample(...)
    class(o) <- "inla.posterior.sample"
    o
}

#' as_tibble generic
#'
#' @param x Object to foo.
#' @export
as_tibble <- function(...) UseMethod("as_tibble")

#' Convert posterior sample to tibble long format
#'
#'
#' @param obj return obj from \code{\link[inlar]{inla.posterior.sample}}.
#' @export
as_tibble.inla.posterior.sample <- function(obj, var = c('hyperpar', 'latent', 'logdens')) 
{
    if (!inherits(obj, "inla.posterior.sample"))
        stop("Obj need to be a result of inla.posterior.sample")
    var <- match.arg(var)

    if (var == "logdens")
        o <- obj %>%
            purrr::map(var) %>%
            purrr::map_dfr(tibble::as_tibble, rownames = "term", .id = "sid")

    if (var == "latent")
        o <- obj %>%
            purrr::map(var) %>%
            purrr::map_dfr(tibble::as_tibble, rownames = "term", .name_repair = ~"sample", .id = "sid") %>%
            dplyr::mutate(term = stringr::str_split(term, ":")) %>%
            tidyr::unnest_wider(term, names_sep = "_") %>%
            dplyr::rename_with(~ char(sample_id, term, term_id, value)) %>%
            dplyr::mutate(dplyr::across(c(sample_id, term_id), as.numeric))

    if (var == "hyperpar")
        o <- obj %>%
            purrr::map(var) %>%
            purrr::map_dfr(tibble::as_tibble, rownames = "term", .name_repair = ~"sample", .id = "sid") %>%
            dplyr::rename_with(~ char(sample_id, term, value))  %>%
            dplyr::mutate(dplyr::across(c(sample_id), as.numeric))
    o
} 
