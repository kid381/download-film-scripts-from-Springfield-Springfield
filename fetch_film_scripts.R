########Scraping all scripts from Springfield! Springfield!########
#https://www.springfieldspringfield.co.uk/movie_scripts.php

####0. preparing necessary packages####
rm(list = ls())
setwd("F:/your/happy/directory")
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
#output: all script titles starting with that letter and their links
get_title_link<- function(first_letter, max_page_number){
  info<- lapply(1:max_page_number, function(x){
    print(paste("Working on Page ", x, " of letter ", first_letter, sep = ""))
    url_with_letter_page<- paste(paste(url, "order=", first_letter, sep = ""), 
                                 "&page=", x, sep = "")
    webpage<- read_html(url_with_letter_page)
    Sys.sleep(0.1 + runif(1, min = -0.05, max = 0.05))
    title_html<- html_nodes(webpage, '.script-list-item')
    title<- html_text(title_html)
    title_link<- html_attr(title_html, "href")
    return(data.table(title, title_link))})
  info<- Reduce(rbind, info)}

## part 3: to get script for a certain title_link
#input: the script's link
#output: the script
get_script<- function(title_link){
  print(paste("Scraping the script with the link:", title_link, sep = " "))
  Sys.sleep(0.1 + runif(1, min = -0.05, max = 0.05))
  url_script<- paste("https://www.springfieldspringfield.co.uk", 
                     title_link, sep = "/")
  script<- try(
    read_html(url_script) %>%
    html_nodes(., '.scrolling-script-container') %>%
    html_text(.)
    )
  #lastly I save the script in a local disk
  print("Saving the script in a local disk...")
  file_connection<- file(paste(strsplit(title_link, "=")[[1]][2],
                               "txt", sep = "."))
  writeLines(script, file_connection)
  close(file_connection)
  }




####2. starting fetching####
first_letter<- c(0, LETTERS)
url<- 'https://www.springfieldspringfield.co.uk/movie_scripts.php?'
##fetching page information
#(only needs a few seconds)
page_info<- data.table(letter = first_letter, 
                       max_page = sapply(first_letter, get_page_number))
##fetching title information
#(ten minutes or so)
title_info<- vector(mode = "list", length = length(first_letter))
for (i in 1:length(first_letter)){
  title_info[[i]]<- get_title_link(first_letter = page_info$letter[i], 
                          max_page_number = page_info$max_page[i])}
title_info<- Reduce(rbind, title_info)
##fetching script information
#(this step takes the most of the time)
sapply(title_info$title_link, get_script)

####3. report summary table####
title_info$file_name<- sapply(strsplit(title_info$title_link, "movie="), 
                              function(x){x[2]})
write.csv(title_info, "summary.csv", row.names = FALSE)



