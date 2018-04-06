########Scraping all scripts from Springfield! Springfield!########
#https://www.springfieldspringfield.co.uk/movie_scripts.php


####0. preparing necessary packages####
rm(list = ls())
setwd("F:/your/working/directory")
library(data.table)
library(stringr)
library(stringi)
library(rvest)
getwd()


####1. three functions to fetch scripts####

##part 1: function to get maximun page number
#input: a letter
#output: the maximum page of the scripts starting with letter
get_page_number<- function(first_letter){
  url_with_letter<- paste(url, "order=", first_letter, sep ="")
  webpage<- read_html(url_with_letter)
  Sys.sleep(0.1 + runif(1, min = -0.05, max = 0.05))
  # get the number of sub-pages for scripts starting with a certain letter
  page_number_html<- html_nodes(webpage, '.pagination')
  # get the number of sub-pages
  page_number<- html_text(page_number_html)
  page_numbers<-  str_extract_all(page_number, "[0-9]+")[[1]]
  max_page_number<- max(as.numeric(page_numbers))
  print(paste("Fetching the maximum page of scripts starting with ", 
              first_letter, "...", sep = ""))
  return(max_page_number)
  }

##part 2: function to get all titles starting with a certain letter
#input: the maximum page of the scripts starting with letter
#output: all script titles starting with that letter
get_title<- function(first_letter, max_page_number){
  titles<- sapply(1:max_page_number, function(x){
    print(paste("Working on Page ", x, " of letter ", first_letter, sep = ""))
    url_with_letter_page<- paste(paste(url, "order=", first_letter, sep = ""), 
                                 "&page=", x, sep = "")
    webpage<- read_html(url_with_letter_page)
    Sys.sleep(0.1 + runif(1, min = -0.05, max = 0.05))
    title_html<- html_nodes(webpage, '.script-list-item')
    title<- html_text(title_html)})
  titles<- as.vector(Reduce(rbind, titles))}
  
## part 3: to get script for a certain title
#input: the script titles
#output: the script
get_script<- function(title){
  print(paste("Scraping the script titled as ", title, sep = ""))
  Sys.sleep(0.1 + runif(1, min = -0.05, max = 0.05))
  title_in_url<- tolower(title) %>%
    gsub("\\(\\d{4}\\)", "", .) %>%
    gsub(" - ", "-", .) %>%
    gsub("'", "", .) %>%
    gsub("(\\d)[/:,](\\d)", "\\1\\2", .) %>%
    gsub("[\\[&<|>$*+():.#,!°?@%/]", " ", .) %>%
    gsub("\\]", " ", .) %>%
    str_trim(.) %>%
    gsub("\\s+", " ", .) %>%
    gsub(" ", "-", .)
  url_script<- paste(url2, 'movie=', title_in_url, sep = '')
  script<- try(
    read_html(url_script) %>%
    html_nodes(., '.scrolling-script-container') %>%
    html_text(.)
    )
  print("Saving the script in a local disk...")
  file_connection<- file(paste(
    paste(title_in_url, substr(title, start = nchar(title) - 5, 
                 stop = nchar(title)), sep = " "), "txt", sep = "."))
  writeLines(script, file_connection)
  close(file_connection)
  }


####2. starting fetching####
first_letter<- c(0, LETTERS)
url<- 'https://www.springfieldspringfield.co.uk/movie_scripts.php?'
url2<- 'https://www.springfieldspringfield.co.uk/movie_script.php?'
##fetching page information
#(only needs a few seconds)
page_info<- data.table(letter = first_letter, 
                       max_page = sapply(first_letter, get_page_number))
##fetching title information
#(ten minutes or so)
title_info<- vector(mode = "list", length = length(first_letter))
for (i in 1:length(first_letter)){
  title_info[[i]]<- get_title(first_letter = page_info$letter[i], 
            max_page_number = page_info$max_page[i])}
title_info<- unlist(title_info)
##fetching script information
#(this step takes the most of the time)
sapply(title_info, get_script)


####3. report summary table####
write.csv(data.table(title = title_info, 
           year = substr(title_info, start = nchar(title_info) - 4, 
                         stop = nchar(title_info) - 1),
           file.name = paste(paste(tolower(title_info) %>%
                                     gsub("\\(\\d{4}\\)", "", .) %>%
                                     gsub(" - ", "-", .) %>%
                                     gsub("'", "", .) %>%
                                     gsub("(\\d)[/:,](\\d)", "\\1\\2", .) %>%
                                     gsub("[\\[&<|>$*+():.#,!°?@%/]", " ", .) %>%
                                     gsub("\\]", " ", .) %>%
                                     str_trim(.) %>%
                                     gsub("\\s+", " ", .) %>%
                                     gsub(" ", "-", .), 
                                   substr(title_info, 
                                          start = nchar(title_info) - 5, 
                                          stop = nchar(title_info)), sep = " "), 
                             "txt", sep = ".")), "summary.csv", 
          col.names = FALSE)
