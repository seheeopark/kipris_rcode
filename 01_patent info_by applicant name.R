####################################
#   Scrapping Korean patent data   #  
#            from KIPRIS           # 
#         December 20, 2019        # 
#           Sehee O. Park          # 
####################################

# This r script produces a tibble (dataframe) of Korean patent data with applicant (organization) names. 
library(tidyverse)
library(httr)
library(XML)
library(xml2)

# URL for KIPRIS Plus REST
url <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getAdvancedSearch"

# Personal key to access the REST api 
mykey <- "1q0r3cpWXcmSCQcSsjizBf2PB7peV8hEMt4242fWW2c="

# Load your applicant data. 
applicants <- readRDS("./sample_data/sample_applicant.rds") 

# Prepare an empty vector to record the presence of patents per applicant 
no_patents <- vector(mode = "double")
# Prepare an empty tibble dataframe to store extracted patent data 
df_patent <- tibble() 

# This code will extract patents according to the applicant names in a tibble dataframe. 
for(i in seq_along(applicants)) {
  # Get API data: Modify your own query here 
  temp <- httr::GET(url, query = list(applicant = applicants[i], 
                                      # Set your preferred dates here. Keep the forma. 
                                      applicationDate = "20080101~20171231",
                                      # Extract patents: TRUE 
                                      patent = TRUE, 
                                      # Do not extract utilities: FALSE 
                                      utility = FALSE, 
                                      # The final dataset does not distinguish patents from utilites. 
                                      # Hence I prefer to extract them in separate dataframes. 
                                      # Set the maximun number of patents per applicant. 
                                      numOfRows = 1000, # default == 20 
                                      # I() "as is" is required to retain its original format. 
                                      ServiceKey = I(mykey)))
  
  # Give 0.2 sec interval between each applicant query: KIPRIS limits 50 inputs per sec. 
  Sys.sleep(0.2) 
  
  # Extract xml information 
  raw_xml <- xml2::read_xml(temp)
  nodes <- xml2::xml_find_all(raw_xml, xpath = "//item")
  
  # Bind data into one tibble format, only when there are one or more patents. 
  if(length(nodes) != 0) {
    temp_df <- lapply(seq_along(nodes), 
                      function(x) {
                        temp_row <- xml_find_all(nodes[x], './*')
                        tibble(
                          idx = x,
                          key = temp_row %>% xml_name(), 
                          value = temp_row %>% xml_text()
                        ) %>% return()
                      }
    ) %>% bind_rows() %>% 
      spread(key, value) %>% 
      select(nodes %>% xml_children() %>% xml_name);
    # Bind all patent information into one dataframe
    df_patent <- bind_rows(df_patent, temp_df);
    # Record the number of patents, if there is one or more patents by the applicant name 
    no_patents[i] <- length(nodes)
  } else {
    # Record NA, if there is no patents by the applicant name 
    no_patents[i] <- NA
  }
}

sample_applicant <- sample_applicant %>% 
  mutate(Name = str_remove_all(Name, "\\(주\\)"))
saveRDS(sample_applicant, "./sample_data/sample_applicant.rds")
