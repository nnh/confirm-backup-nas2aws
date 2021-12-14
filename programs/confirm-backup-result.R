#' @file confirm-backup-result.R
#' @author Mariko Ohtsuka
#' @date 2021.12.13
rm(list=ls())
# ------ libraries ------
library(tidyverse)
library(data.table)
# ------ functions ------
#' @title CompareAwsNas
#' Compare the contents of the file list.
#' @param kConstName Part of the file name to be compared.
#' @return none.
CompareAwsNas <- function(kConstName){
  raw_aws <- read_lines(str_c('~/Downloads/', kConstName, '_aws.txt'))
  raw_nas <- read_lines(str_c('~/Downloads/', kConstName, '_nas.txt'))
  aws <- raw_aws %>% map(~{
    temp <- .
    temp <- temp %>% str_replace('^[0-9]{4}-[0-9]{2}-[0-9]{2}\\s[0-9]{2}:[0-9]{2}:[0-9]{2}\\s+', '') %>%
      str_replace(kConstName, '') %>%
      str_split('\\s', n=2)
    return(temp[[1]])
  }) %>% as.data.frame() %>% transpose()
  targetFolderName <- kConstName %>% str_replace('^[0-9]{6}_', '')
  nas <- raw_nas %>% map(~{
    temp <- .
    temp <- temp %>% str_replace(str_c('^/share/', targetFolderName), '') %>% str_split('\t')
    return(c(temp[[1]][2], temp[[1]][1]))
  }) %>% as.data.frame() %>% transpose()
  aws <- aws %>% filter(V1 > 0) %>% arrange(V1, V2)
  nas <- nas %>% filter(V1 > 0) %>% filter(!str_detect(V2, '/@Recycle')) %>% filter(!str_detect(V2, '.DS_Store')) %>%
    filter(!str_detect(V2, '/.streams')) %>% filter(!str_detect(V2, '.lnk')) %>% filter(!str_detect(V2, '.fcpcache')) %>%
      filter(!str_detect(V2, '\\/\\..*$')) %>% filter(!str_detect(V2, '@__thumb')) %>% arrange(V1, V2)
  diff_list <- NULL
  none_list <- NULL
  print(str_c('#', kConstName, ' check start #'))
  print(str_c('file count nas: ', nrow(nas), ' aws: ', nrow(aws)))
  for(i in 1:nrow(nas)){
    temp <- aws %>% filter(V2 == nas[i, 'V2'])
    if (nrow(temp) > 0){
      if (nas[i, 'V1'] != temp[1, 'V1']){
        diff_list <- c(diff_list, nas[i, 'V2'])
      }
    } else {
      none_list <- c(none_list, nas[i, 'V2'])
    }
  }
  print('*** Files of different sizes ***')
  print(diff_list)
  print('*** Files that do not exist in aws ***')
  print(none_list)
  print(str_c('#', kConstName, ' check end #'))
  return(list(diff_list, none_list))
}
#' @title GetTodayYyyymm
#' Returns today's year and month in YYYYMM.
#' @param none.
#' @return A string such as '202105'.
GetTodayYyyymm <- function(){
  date_array <- Sys.Date() %>% str_split('-') %>% .[[1]]
  mm <- ifelse(as.numeric(date_array[2]) < 10, str_c('0', date_array[2]), date_array[2])
  yyyymm <- str_c(date_array[1], mm)
  return(yyyymm)
}
# ------ constants ------
kTargetFolders <- c('Projects', 'References', 'Stat')
# ------ main ------
error_list <- str_c(GetTodayYyyymm(), '_', kTargetFolders) %>% map(~CompareAwsNas(.))
