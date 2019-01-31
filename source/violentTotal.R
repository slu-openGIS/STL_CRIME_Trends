#' Calculate violent crime totals
#' 
violentTotal <- function(.data){
  
  .data %>%
    select(murder, rape, robbery, agAssault) %>% 
    rowSums(na.rm=FALSE) %>%
    as_tibble() %>%
    rename(violentTotal = value) %>%
    bind_cols(.data, .) %>%
    select(year, population, violentTotal, everything()) -> out

  return(out)  
  
}