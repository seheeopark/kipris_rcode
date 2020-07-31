library(tidyverse)
library(httr) 
library(xml2)

# URL for KIPRIS Plus REST
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getAdvancedSearch"

# Personal key to access the REST api 
mykey <- "use your key"

# Single applicant & Single page (up to 500 patents) # 

# applicant_name <- c("네오위즈")

temp <- httr::GET(url, query = list(applicant = applicant_name, 
                                    # Set your preferred dates here. Keep the forma. 
                                    applicationDate = "20170101~20191231",
                                    # Extract patents: TRUE 
                                    patent = TRUE, 
                                    # Do not extract utilities: FALSE 
                                    utility = FALSE, 
                                    # The final dataset does not distinguish patents from utilites. 
                                    # Hence I prefer to extract them in separate dataframes. 
                                    # Set the maximun number of patents per applicant. 
                                    numOfRows = 500, # default == 20 
                                    # I() "as is" is required to retain its original format. 
                                    ServiceKey = I(mykey)))

# Give 0.1 sec interval between each applicant query: KIPRIS limits 50 inputs per sec. 
Sys.sleep(0.1) 

# Extract xml information 
temp_node <- temp %>% 
  read_xml() %>% 
  xml_find_all(xpath = "//item") 

# xml nodes and its text 
if(length(temp_node) != 0) {
  temp_df <- map_dfr(seq_along(temp_node), function(y) {
    temp_row <- xml_find_all(temp_node[y], './*')
    tibble(
      name = applicant_name,  
      idx = y,
      key = temp_row %>% xml_name(), 
      value = temp_row %>% xml_text()
      )
    }
  ) %>% spread(key, value) 
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
