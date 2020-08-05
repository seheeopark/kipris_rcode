library(tidyverse)
library(httr) 
library(xml2)

# URL for KIPRIS Plus REST
url <- "http://plus.kipris.or.kr/openapi/rest/KpaBibliographicService/bibliographicInfo"

# Personal key to access the REST api 
mykey <- "use your own key" 

# Sample data 
df_abstracts <- readRDS("./sample_data/df_abstracts.rds")
df_sample <- df_abstracts[1:5, ]
application_no <- df_sample$applicationNo # 5 obs. 

# (1) Function: Get English abstract contents 
get_contents <- function(x) {
  application <- application_no[x]
  
  temp <- httr::GET(url, query = list(applicationNumber = application, 
                                      # I() "as is" is required to retain its original format. 
                                      accessKey = I(mykey)))
  
  # Extract xml information for the abstract content 
  temp_node <- temp %>% 
    read_xml() %>% 
    xml_find_all(xpath = "//astrtCont")
  
  temp_df <- tibble(
    applicationNo = application,
    key = temp_node %>% xml_name(), 
    value = temp_node %>% xml_text()
  ) %>% spread(key, value)
  
  # Give 0.5 sec interval between each applicant query: KIPRIS limits 50 inputs per sec. 
  Sys.sleep(0.5)
  
  # Mark if you do not want to check the loop status 
  print(paste0("application number: ", application))
  
  return(temp_df)
  
  # Warning message 1: API status
  if (temp$status_code != 200) {
    print(paste0("Error occurred! Inspect the API status code:", temp$status_code))
  }
  
  # Warning message 2: error message 
  if (nrow(temp_df) == 0) {
    resultMsg <- temp %>% read_xml() %>% xml_find_all(xpath = "//resultMsg") %>% xml_text()
    # No message if there is no error
    print(paste0("API access result: ", resultMsg))
  } else {
    print(paste0("API access result: ", "success"))
  }

} 

# (2) Get English abstract contents by patent application numbers 
df_contents <- map_dfr(seq_along(application_no), get_contents)

# (3) Join with the whole patent information by keyword search (result from "06_keyword_search.R")
df_abstracts_full <- left_join(df_sample, df_contents, by = "applicationNo")

