#' @file confirm-backup-result.R
#' @author Mariko Ohtsuka
#' @date 2021.12.16
rm(list=ls())
# ------ libraries ------
library(tidyverse)
library(data.table)
# ------ functions ------
#' @title CompareAwsNas
#' Compare the contents of the file list.
#' @param kConstName Part of the file name to be compared.
#' @return error list.
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
  aws <- FilterDf(aws)
  nas <- FilterDf(nas)
  print(str_c('#', kConstName, ' check start #'))
  print(str_c('file count nas: ', nrow(nas), ' aws: ', nrow(aws)))
  nas_only <- anti_join(nas, aws, by='V2')
  aws_only <- anti_join(aws, nas, by='V2')
  temp_nas <- anti_join(nas, nas_only, by='V2')
  temp_aws <- anti_join(aws, aws_only, by='V2')
  diff_list <- anti_join(temp_nas, temp_aws, by=c('V2', 'V1'))
  if (nrow(nas_only) > 0 | nrow(aws_only) > 0 | nrow(diff_list) > 0){
    if (nrow(diff_list) > 0){
      print('*** Files of different sizes ***')
      print(diff_list)
    }
    if (nrow(nas_only) > 0){
      print('*** Files that do not exist in aws ***')
      temp <- inner_join(nas, nas_only, by='V2')
      print(temp)
    }
    if (nrow(aws_only) > 0){
      print('*** Files that do not exist in nas ***')
      print(aws_only)
    }
  } else {
    print('No difference.')
  }
  print(str_c('#', kConstName, ' check end #'))
  return(list(kConstName, nas_only, aws_only, diff_list))
}
#' @title FilterDf
#'
#' @param input_df The data frame to be processed.
#' @return a data frame.
FilterDf <- function(input_df){
  output_df <- input_df %>% filter(V1 > 0) %>% filter(!str_detect(V2, '/@Recycle')) %>% filter(!str_detect(V2, '.DS_Store')) %>%
    filter(!str_detect(V2, '/.streams')) %>% filter(!str_detect(V2, '.lnk')) %>% filter(!str_detect(V2, '.fcpcache')) %>%
      filter(!str_detect(V2, '\\/\\..*$')) %>% filter(!str_detect(V2, '@__thumb')) %>% arrange(V1, V2)
  return(output_df)
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
kTargetFolders <- c('Projects', 'References', 'Stat', 'Archives', 'BoxBackups', 'backups')
# ------ main ------
error_list <- str_c(GetTodayYyyymm(), '_', kTargetFolders) %>% map(~CompareAwsNas(.))
save(error_list, file='~/Downloads/nas2awsbackup_errorlist.Rda')
