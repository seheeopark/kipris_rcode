library(tidyverse)
library(httr) 
library(xml2)

# URL for KIPRIS Plus REST
url_ipcNumber <- "http://plus.kipris.or.kr/kipo-api/kipi/patUtiModInfoSearchSevice/getAdvancedSearch"

# Personal key to access the REST api 
mykey <- "use your own key"

# Sample ipc numbers 
ipc_sample <- c("G06K 9/00", "B60K 6/36")

# (1) Function: multiple ipc numbers, multiple pages 

get_full_patents <- function(x) {
  # Set variables for each ipc number 
  ipc <- ipc_sample[x] 
  cumul_df <- tibble() 
  i <- 1
  # repeated patent extracts if there is more than one page (500 patents) 
  repeat {
    temp <- httr::GET(url_ipcNumber, query = list(ipcNumber = ipc, 
                                        # Set your preferred dates here. Keep the forma. 
                                        applicationDate = "20191001~20191231",
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
    
    # Extract xml information 
    temp_node <- temp %>% 
      read_xml() %>% 
      xml_find_all(xpath = "//item")  

    # Bind data into one tibble format, only when there are one or more patents. 
    if (length(temp_node) == 0) {
      # Unmark if you want to check the loop status 
      print(paste0("ipcNumber: ", ipc))
      print(paste0("page: ", i))
      print(paste0("no_patents: ", length(temp_node)))
      break
    } else {
      temp_df <- map_dfr(seq_along(temp_node), function(y) {
        temp_row <- xml_find_all(temp_node[y], './*')
        tibble(
          ipcNumber = ipc, 
          page = i, 
          idx = y,
          key = temp_row %>% xml_name(), 
          value = temp_row %>% xml_text()
        )
      }
      ) %>% spread(key, value) 
      
      # Unmark if you want to check the loop status 
      print(paste0("ipcNumber: ", ipc))
      print(paste0("page: ", i))
      print(paste0("no_patents: ", nrow(temp_df)))
      
      # Increase page number 
      i <- i + 1
      
      # Give 0.1 sec interval between each applicant query: KIPRIS limits 50 inputs per sec. 
      Sys.sleep(0.1)
    }
    
    # Cumulated patents dataframe per applicant
    cumul_df <- rbind(cumul_df, temp_df)
    # cumul_df <- bind_rows(cumul_df, temp_df) : bind_rows() does not work here. 
    
    # Unmark if you want to check the loop status of cumul_df 
    # print(paste0("cumul patents: ", nrow(cumul_df)))
    
    if (length(temp_node) < 500) {
      break
    }
  } 
  return (cumul_df)
  if (temp$status_code != 200) {
    print(paste0("Error occurred! Inspect the API status code:", temp$status_code))
  } 
  if (length(cumul_df) == 0) {
    resultMsg <- temp %>% read_xml() %>% xml_find_all(xpath = "//resultMsg") %>% xml_text() 
    # No message if there is no error 
    print(paste0("API access result: ", resultMsg))
  }
} 

# (2)  Get real patent data from a vector of ipc numbers 
df_full_patents <- map_dfr(seq_along(ipc_sample), get_full_patents)

