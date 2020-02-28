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

