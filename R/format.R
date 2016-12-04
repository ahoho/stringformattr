#' Concatenate two strings.
#'
#' `%p%`and `%s%` are wrappers for `paste0(..., collapse = '')` and
#' `paste0(..., collapse = ' ')`, respectively, that combine two character vectors.
#'
#' @usage
#' x %p% y
#' x %s% y
#'
#' @param x A character vector
#' @param y A character vector
#'
#' @examples
#' 'the quick brown fox jum' %p% 'ped over the lazy dog'
#'
#' gen_sql <- function(column, table) "SELECT" %s% column %s% "FROM" %s% table
#' @name contat-two-strings

#' @rdname contat-two-strings
#' @export
`%p%` <- function(x, y){ paste0(x, y, collapse = '') }

#' @rdname contat-two-strings
#' @export
`%s%` <- function(x, y){ paste0(x, y, collapse = ' ') }

#' Pass variables into strings
#'
#' Pass variables into strings using pairs of curly brackets
#' to identify points of insertion.
#'
#' @usage
#' x %f% kwargs
#'
#' @param x A character vector
#' @param kwargs A (possibly named) character vector
#'
#' @examples
#' # order matters when not using a named vector
#' 'the quick {} fox jumped {} the lazy {}' %f% c('brown', 'over', 'dog')
#'
#' gen_sql_query <- function(column, table, id){
#'     query <- "SELECT {col} FROM {tab} WHERE pk = {id}"
#'     query %f% c('col' = column, 'tab' = table, 'id' = id)
#' }
#'
#' gen_sql_query('LASTNAME', 'STUDENTS', '12345')
#'
#' @name format-string
#' @export
`%f%` <- function(string, kwargs) {
  if (is.character(string) || is.atomic(kwargs)) stop("string and kwargs must be atomic vectors")

  if (is.null(names(kwargs))) {
    names(kwargs) <- seq_along(kwargs)
    num_subs <- max(str_count(string, '\\{\\}'))

    if(length(kwargs) > 1 & length(kwargs) != num_subs) {
      warning("Number of replacements in string differs from length of kwargs, recycling")
    }

    string <- Reduce(.insert_num, num_blanks, init = string)
  }

  kw_subs <- cbind(names(kwargs), kwargs)
  funs <- apply(kw_subs, 1, .gsub_kwarg)

  Reduce(function(x, y) y(x), funs, init = string)
}

.gsub_kwarg <- function(kw_sub) {
  function(s) gsub('\\{' %p% kw_sub[1] %p% '\\}', kw_sub[2], s)
}

.insert_num <- function(str, sub) {
  str_replace('{' %p% str %p% '}', '\\{\\}', sub)
}
