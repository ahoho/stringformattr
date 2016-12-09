#' Concatenate two strings.
#'
#' \code{\%p\%} and \code{\%s\%} are wrappers for \code{paste0(..., collapse = '')} and
#' \code{paste0(..., collapse = ' ')}, respectively, that combine two character vectors.
#'
#' @param x,y A character vector
#'
#' @examples
#' 'the quick brown fox jum' %p% 'ped over the lazy dog'
#'
#' gen_sql <- function(column, table) "SELECT" %s% column %s% "FROM" %s% table
#' 
#' @name binary-string-concat

#' @rdname binary-string-concat
#' @export
`%p%` <- function(x, y){ paste0(x, y, collapse = '') }

#' @rdname binary-string-concat
#' @export
`%s%` <- function(x, y){ paste0(x, y, collapse = ' ') }

#' Pass variables into strings
#'
#' Pass variables into strings using pairs of curly brackets
#' to identify points of insertion.
#'
#' @param string A character vector
#' @param args A (possibly named) atomic vector
#'
#' @examples
#' # order matters when not using a named vector
#' 'the quick {} fox jumped {} the lazy {}' %f% c('brown', 'over', 'dog')
#'
#' # use a named vector to insert values by referencing them in the string
#' gen_sql_query <- function(column, table, id){
#'     query <- "SELECT {col} FROM {tab} WHERE pk = {id}"
#'     query %f% c(col = column, tab = table, id = id)
#' }
#'
#' gen_sql_query('LASTNAME', 'STUDENTS', '12345')
#'
#' # `%f%` is vectorized
#' v <- c('{vegetable}', '{animal}', '{mineral}', '{animal} and {mineral}')
#' v %f% c(vegetable = 'carrot', animal = 'porpoise', mineral = 'salt')
#'
#' # if the number of replacements is larger than the length of unnamed arguments,
#' # `%f%` will recycle the arguments (and give a warning)
#' c('{} {}', '{} {} {}', '{}') %f% c(0, 1)
#' 
#' # > "0 1" "0 1 0" "0"
#'   
#' @name format-string
#' @export
`%f%` <- function(string, args) {
  if (!is.character(string) || !is.atomic(args)) stop("string and args must be atomic vectors")

  if (is.null(names(args))) {
    num_subs <- max(stringr::str_count(string, '\\{\\}'))
    args_seq <- seq_along(args)
    
    names(args) <- args_seq
    sub_vec <- rep_len(args_seq, num_subs)

    if(num_subs > 0 && length(args) > 0 && length(args) != num_subs) {
      warning("Number of replacements in string differs from length of args")
    }

    string <- Reduce(.insert_num, sub_vec, init = string)
  }

  named_subs <- cbind(names(args), args)
  funs <- apply(named_subs, 1, .gsub_arg)

  Reduce(function(x, y) y(x), funs, init = string)
}

.gsub_arg <- function(named_sub) {
  function(s) gsub('\\{' %p% named_sub[1] %p% '\\}', named_sub[2], s)
}

.insert_num <- function(str, sub) {
  stringr::str_replace(str, '\\{\\}', '{' %p% sub %p% '}')
}
