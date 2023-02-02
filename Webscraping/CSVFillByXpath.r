library(rvest)
library(tidyverse)


# Only using XML Library
# html_doc <- htmlTreeParse("Dataspec.html", useInternal = TRUE)
# heading <- xpathSApply(html_doc, "//h1", xmlValue)

# Variables
html_doc <- read_html("Dataspec.html")
df <-tibble()
FormArr <- array()




SecArr <- NA
qlist <- data.frame("Form" = NA, "Section" = NA, "Field" = NA, "Field_Info" = NA)

# Outer loop, forms.
i = 1
for (i in 1:1200) {
  xpathform = paste('/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[', i, ']/h1', sep = "")
  form <- html_doc %>%
    html_element(xpath = xpathform) %>%
    html_text()
  
  if(is.na(form)) {
    break
  }
  

  # Mid loop, sections.
  d = 1
  for (d in 1:1200) {
    xpathsec = paste('/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[', i, ']/div[', d+1, ']/h2', sep = "")
    section <- html_doc %>%
      html_element(xpath = xpathsec) %>%
      html_text()
   # qlist[nrow(qlist)+1,] <- c(form, section)
    
    if(is.na(section)) {
      break
  
  
  
    }
    
    # Field Loop
    k = 1
    for (k in 1:1200) {
      xpathfield = paste('/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[', i, ']/div[', d+1, ']/div[', k+1, ']/h3', sep = "")
      xpathqopts = paste('/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[', i, ']/div[', d+1, ']/div[', k+1, ']/div[2]', sep = "")
      field <- html_doc %>%
        html_element(xpath = xpathfield) %>%
        html_text()
      
      
      qopts <- html_doc %>%
        html_elements(xpath = xpathqopts) %>%
        html_elements("li") %>%
        html_text()
      
     finfo <- paste(qopts, sep = "", collapse = ", ")
      
      
      
      
      qlist[nrow(qlist)+1,] <- c(form, section, field, finfo)
      
      if(is.na(field)) {
        break
        
        
        
      }
    }
  }
  print(i)
}

# TESTING BELOW ----
                  '/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[12]/div[5]/div[2]/ul/li[1]'
xpathtest = paste('/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[12]/div[5]/div[2]', sep = "")
qopts <- html_doc %>%
  html_elements(xpath = xpathtest) %>%
  html_elements("li") %>%
  html_text()

testqopts <- paste(shQuote(qopts), collapse=", ")

test2qopts <-paste(qopts, sep = "", collapse = ", ")

qlistclean <- qlist %>% drop_na(Field)

write.csv(qlistclean, "dataspec.csv")

#FormArr <- append(FormArr, print(form))


# Sample 1st Form: /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/h1
#                  /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[13]/ul/li[1]
#   1st Section:   /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[2]/h2
#     1st Question:/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[2]/div[2]/h3
#     2nd Question:/html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[2]/div[3]/h3
#.  Question Info: /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[3]/div[2]/p
#.                 /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[6]/div[9]/div[2]/ul/li[1]

#   2nd Section: /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[1]/div[3]/h2

# Sample 2nd Form: /html/body/div[3]/div[2]/div/div[2]/div[4]/div/div[2]/div[2]/div[2]/div[2]/h1

# write.table(sections, "firstgo.html")


