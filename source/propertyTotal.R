#' Calculate Property Crime Totals (with arson)
#' 
propertyTotal <- function(.data){
  
  .data %>%
    select(theftTotal, arson) %>%
    rowSums(na.rm=FALSE) %>%
    as_tibble() %>%
    rename(propertyTotal = value) %>%
    bind_cols(.data, .) %>%
    select(year, population, violentTotal, murder, rape, robbery, agAssault, 
           propertyTotal, theftTotal, everything()) -> out
  
  return(out)
  
}
