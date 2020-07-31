library(tidyverse)
library(httr) 
library(xml2)

# URL for KIPRIS Plus REST
url <- "http://plus.kipris.or.kr/openapi/rest/KpaGeneralSearchService/anySearch"

# Personal key to access the REST api 
mykey <- "use your own key"

# Sample keywords:
# You can use a vector of multiple keywords using operators: AND(*), OR(+) NOT(!)
keywords_sample <- c("sodium*ion*battery", "sodium*rechargeable*battery") 

# (1) Function: multiple ipc numbers, multiple pages 

get_abstracts <- function(x) {
  # Set variables for each applicant 
  keyword <- keywords_sample[x] 
  cumul_df <- tibble() 
  i <- 1
  # repeated patent extracts if there is more than one page (500 patents) 
  repeat {
    temp <- httr::GET(url, query = list(searchAny = keyword, 
                                        # multiple pages
                                        currentPage = i, # default == 1
                                        # Set the maximum number of patents per page. 
                                        docsCount = 500, # default == 30 
                                        # I() "as is" is required to retain its original format. 
                                        accessKey = I(mykey)))
    
    # Extract xml information 
    temp_node <- temp %>% 
      read_xml() %>% 
      xml_find_all(xpath = "//items") %>% 
      xml_children() 
    
    # Bind data into one tibble format, only when there are one or more patents. 
    if (length(temp_node) == 0) {
      # Unmark if you want to check the loop status 
      print(paste0("input_keyword: ", keyword))
      print(paste0("page: ", i))
      print(paste0("no_abstracts: ", length(temp_node)))
      break
    } else {
      temp_df <- map_dfr(seq_along(temp_node), function(y) {
        temp_row <- xml_find_all(temp_node[y], './*')
        tibble(
          input_keyword = keyword, 
          page = i, 
          idx = y,
          key = temp_row %>% xml_name(), 
          value = temp_row %>% xml_text()
        )
      }
      ) %>% spread(key, value) 
      
      # Unmark if you want to check the loop status 
      print(paste0("input_keyword: ", keyword))
      print(paste0("page: ", i))
      print(paste0("no_abstracts: ", nrow(temp_df)))
      
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
  if (length(cumul_df) == 0) {
    resultMsg <- temp %>% read_xml() %>% xml_find_all(xpath = "//resultMsg") %>% xml_text() 
    # No message if there is no error 
    print(paste0("API access result: ", resultMsg))
  }
} 

# (2)  Get real patent data from a vector of applicant names, and multiple pages 
df_abstracts <- map_dfr(seq_along(keywords_sample), get_abstracts)

