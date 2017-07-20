# library(readr)
# library(dplyr)
# library(graphics)
# library(maps)
# library(tidyr)

#' @title Read a csv file into datatable
#'
#' @description This function read the file and put it on a data.frame structure.
#' please note, this is a low-level function, check \code{\link{fars_read_years}} for a more userfriendly interface.
#'
#' @param filename is a character string with the file to be read
#'
#' @return a \code{data.frame} containing the csv data if file exists.
#' if file do not exists, the function do stop.
#' @export
#'
#' @importFrom readr read_csv
#'
#' @examples
#' \dontrun{
#' fars_read(make_filename(2017))
#' }
#' @seealso \code{\link{make_filename}}
fars_read <- function(filename) {
  if(!file.exists(filename))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(filename, progress = FALSE)
  })
  dplyr::tbl_df(data)
}

#' Generate the filename for a particolar year
#'
#' @param year Integer, the year you want the file belong to
#'
#' @return a character string with filename for the requested year
#' @export
#'
#' @examples make_filename(2016)
make_filename <- function(year) {
year <- as.integer(year)
system.file("extdata",
  sprintf("accident_%d.csv.bz2", year), package = "courseraPack")
}

#' Read data by years
#'
#' load fars data of a list of year
#' The fucntion warns if invalid year are requested and return a NULL for that entry of the list.
#'
#' @param years a list of integer as years to load
#'
#' @importFrom dplyr mutate select
#' @return a /code{list} of /code{data.frame} each containing one year data.
#' @export
#'
#' @examples  fars_read_years(c(2015,2014))
fars_read_years<- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)
    tryCatch({
      dat <- fars_read(file)
      dplyr::mutate(dat, year = year) %>%
        dplyr::select(MONTH, year)
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}


#' Summary of years
#'
#' Summarize fars data of many year
#'
#' @param years a list of years to summarize
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#' @return a tibble, summary with obs. for months in columsn and year in rows of fars data
#' @export
#'\dontrun{
#' @examples fars_summarize_years(c(2015,2014))
#' }
fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}

#' Plot far a map
#'
#' This function generate a map of the fars data releted to a specific year and state.
#'
#' @param state.num integer, the state you want to plot
#' @param year  integer, the year you want to plot
#'
#' @importFrom  maps map
#' @importFrom  graphics points
#' @return generate a map with a point for every location, return a NULL.
#' @export
#'
#' @examples
#' \dontrun{
#' fars_map_state(12,2014)
#' }
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}
