library(tidyverse)
library(httr) 
library(xml2)

# URL for KIPRIS Plus REST
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getAdvancedSearch"

# Personal key to access the REST api 
mykey <- "use your key"

#  Single applicant, Multi pages 

# Set variables 
# applicant_name <- c("성우하이텍")
cumul_df <- tibble() 
i <- 1

repeat {
  temp <- httr::GET(url, query = list(applicant = applicant_name, 
                                      # Set your preferred dates here. Keep the forma. 
                                      applicationDate = "20130101~20191231",
                                      # Extract patents: TRUE 
                                      patent = TRUE, 
                                      # Do not extract utilities: FALSE 
                                      utility = FALSE, 
                                      # The final dataset does not distinguish patents from utilites. 
                                      # Hence I prefer to extract them in separate dataframes. 
                                      # Set the maximun number of patents per applicant. 
                                      numOfRows = 500, # default == 20 
                                      # multi pages
                                      pageNo = i, # default == 1
                                      # I() "as is" is required to retain its original format. 
                                      ServiceKey = I(mykey)))
  
  # Give 0.1 sec interval between each applicant query: KIPRIS limits 50 inputs per sec. 
  Sys.sleep(0.1)
  
  # Extract xml information 
  temp_node <- temp %>% 
    read_xml() %>% 
    xml_find_all(xpath = "//item") 
  
  # Bind data into one tibble format, only when there are one or more patents. 
  if (length(temp_node) == 0) {
    # Unmark if you want to check the loop status 
    # print(paste0("applicant: ", applicant_name))
    # print(paste0("page: ", i))
    # print(paste0("no_patents: ", length(temp_node)))
    break
  } else {
    temp_df <- map_dfr(seq_along(temp_node), function(y) {
      temp_row <- xml_find_all(temp_node[y], './*')
      tibble(
        name = applicant_name, 
        page = i, 
        idx = y,
        key = temp_row %>% xml_name(), 
        value = temp_row %>% xml_text()
      )
    }
    ) %>% spread(key, value) 
    
    # check the repeat status 
    print(paste0("applicant: ", applicant_name))
    print(paste0("page: ", i))
    print(paste0("no_patents: ", nrow(temp_df)))
    
    # Increase page number 
    i <- i + 1
  } 
  
  # Cumulated patents dataframe per applicant
  cumul_df <- rbind(cumul_df, temp_df)
  print(paste0("cumul patents: ", nrow(cumul_df)))

  if (length(temp_node) < 500) {
    break
  }
  # If status_code !=200, there was an error in the API call. 
  # If status_code == 200 and df has no observation, there is no patent under the given applicant names. 
  if (temp$status_code != 200) {
    print(paste0("Error occurred! Inspect the API status code:", temp$status_code))
  } 
  if (length(cumul_df) == 0) {
    temp %>% read_xml() %>% xml_find_all(xpath = "//resultMsg") %>% xml_text() 
    # No message if there is no error 
    print(paste0("API access result: ", resultMsg))
  }
}
# return (cumul_df)

