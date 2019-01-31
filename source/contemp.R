#' Clean up Modern Data Release Names
#' 
contempNames <- function(.data, year){
  
  .data %>% 
    clean_names() %>%
    rename(
      murder = murder_and_nonnegligent_manslaughter,
      agAssault = aggravated_assault,
      larceny = larceny_theft,
      mvLarceny = motor_vehicle_theft
    ) -> out
  
  if (year == 2015){
    
    out %>% 
      rename(rape = rape_revised_definition_1) -> out
    
  } else if (year == 2016){
    
    out %>% 
      rename(rape = rape_revised_definition1) -> out
    
  } else if (year == 2017){
    
    out %>%
      rename(rape = rape1) -> out
    
  }
  
  return(out)
  
}

#' Subset Modern Data
#' 
contempSubset <- function(.data, year){
 
  if (year == 2017){
    
    .data <- rename(.data, city = state)
    
  }
  
  .data %>%
    filter(city == "St. Louis") %>%
    select(year, everything(), -city, -violent_crime, -property_crime) -> out
  
  if (year == 2015){
    
    out %>%
      select(-rape_legacy_definition_2) -> out
    
  } else if (year == 2016){
    
    out %>%
      select(-rape_legacy_definition2) -> out
    
  }
  
  return(out)
  
}
