#' Calculate Burglary/Larceny Crime Totals
#' 
theftTotal <- function(.data){
  
  .data %>%
    select(burglary, larceny, mvLarceny) %>% 
    rowSums(na.rm=FALSE) %>%
    as_tibble() %>%
    rename(theftTotal = value) %>%
    bind_cols(.data, .) %>%
    select(year, population, violentTotal, murder, rape, robbery, agAssault, 
           theftTotal, everything()) -> out
  
  return(out)
  
}
