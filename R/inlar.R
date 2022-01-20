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

#' Convert posterior sample to tibble long format
#'
#'
#' @param obj return obj from \code{\link[inlar]{inla.posterior.sample}}.
#' @param type summary or marginals>
#' @param term which of the random, linear.predictor, or fitted.values
#' @export 
as_tibble.inla <- function(obj, 
    type = char(summary, marginals), 
    term = char(random, linear.predictor, fitted.values)) 
{
    if (!inherits(obj, "inla")) stop("Obj is not an INLA model")

    type <- match.arg(type)
    term <- match.arg(term)

    tt <- paste(type, term, sep = ".")
    it <- obj %>% purrr::pluck(tt, .default = "not_exist")

    if (length(it) == 1 && it == "not_exist") stop("You didn't tell INLA to compute it.")

    if (type == "summary") {
        if (term == "random") 
            o <- dplyr::bind_rows(it, .id = "var") %>%
                dplyr::select(1:7) %>%
                dplyr::rename_with(~ char(var, id, mean, sd, q025, q50, q975))

        if (term %in% c("fitted.values", "linear.predictor")) 
            o <- tibble::as_tibble(it, rownames = "term") %>%
                dplyr::select(1:6) %>%
                dplyr::rename_with(~ char(subj_id, mean, sd, q025, q50, q975)) %>%
                dplyr::bind_cols(obj$.args$data)
    }

    if (type == "marginals") {
        if (term == "random") 
            o <- purrr::map(it, purrr::map_dfr, tibble::as_tibble, rownames = "id", .id = "id") %>%
                dplyr::bind_rows(.id = "var") %>%
                dplyr::mutate(id = as.numeric(stringr::str_extract(id, "[0-9]+")))
        else 
            o <- purrr::map_dfr(it, tibble::as_tibble, .id = "id") %>%
                dplyr::mutate(id = as.numeric(stringr::str_extract(id, "[0-9]+$")))
    }
    o
}

