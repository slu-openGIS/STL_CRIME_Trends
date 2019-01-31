#' Estimate Population for Individual Years
#' 
popCalc <- function(.data, start, end){
  
  start1 <- start+1
  end1 <- end-1
  
  .data %>%
    filter(year == start | year == end) %>%
    add_row(year = start1:end1, .before = 2) -> out
  
  startPop <- out$population[1]
  endPop <- out$population[11]
  delta <- endPop-startPop
  yearlyDelta <- delta/10
  
  out %>%
    mutate(x = str_sub(as.character(year),-1,-1)) %>%
    mutate(population = ifelse(is.na(population) == TRUE, 
                               startPop+(yearlyDelta*as.integer(x)), 
                               population)) %>%
    select(-x) -> out
  
  return(out)
  
}
