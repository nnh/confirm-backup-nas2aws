#!/bin/sh
str_date=`date +'%Y%m%d'`
str_year=`date +'%Y'`
str_month=`date +'%m'`
str_ym=${str_year}${str_month}
#aws s3 ls s3://aronas-backup/${str_ym}_Projects/ --recursive> ${str_ym}_Projects_aws.txt
#aws s3 ls s3://aronas-backup/${str_ym}_References/ --recursive> ${str_ym}_References_aws.txt
#aws s3 ls s3://aronas-backup/${str_ym}_Stat/ --recursive> ${str_ym}_Stat_aws.txt
aws s3 ls s3://aronas-backup/${str_ym}_Archives/ --recursive> ${str_ym}_Archives_aws.txt
