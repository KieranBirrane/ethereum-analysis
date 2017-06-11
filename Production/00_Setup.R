##### ##### ##### ##### ##### ##### #####
#####  Ethereum Block Data - Setup  #####
##### ##### ##### ##### ##### ##### #####
# Block - 3,200,000 with X transactions
# First Transaction - Block 46,147
# Timestamp -  2017-02-17T12:30:51.000Z


# Dataset - Analytised up to 31-01-2017
# Block = 3,100,154

# rm(list=ls(all=TRUE))
# getwd()
# sessionInfo()

# R Version:          R version 3.1.0 (2014-04-10)
# R Studio Version:   Version 1.0.136



##### Activate packages #####
# Install packages
# install.packages("installr")
# install.packages("RJSONIO")
# install.packages("RCurl")
# install.packages("jsonlite")
# install.packages("RODBC")
# install.packages("gmailr")
# install.packages("plyr")
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("tclust")
#library(installr)   # Version:  installr_0.17.5   # lsf.str("package:installr")     # detach("package:installr", unload = TRUE)
#library(RJSONIO)    # Version:  RJSONIO_1.3-0     # lsf.str("package:RJSONIO")      # detach("package:RJSONIO", unload = TRUE)
library(RCurl)      # Version:  RCurl_1.95-4.8    # lsf.str("package:RCurl")        # detach("package:RCurl", unload = TRUE)
library(jsonlite)   # Version:  jsonlite_0.9.19   # lsf.str("package:jsonlite")     # detach("package:jsonlite", unload = TRUE)
library(gmailr)     # Version:  gmailr_0.7.1      # lsf.str("package:gmailr")       # detach("package:gmailr", unload = TRUE)
library(RODBC)      # Version:  RODBC_1.3-14      # lsf.str("package:RODBC")        # detach("package:RODBC", unload = TRUE)
library(plyr)       # Version:  plyr_1.8.4        # lsf.str("package:plyr")         # detach("package:plyr", unload = TRUE)
library(ggplot2)    # Version:  ggplot2_2.2.1     # lsf.str("package:ggplot2")      # detach("package:ggplot2", unload = TRUE)
library(tclust)     # Version:  tclust_1.2-3      # lsf.str("package:tclust")       # detach("package:tclust", unload = TRUE)


##### Global variables ####
global_github = "C:\\Users\\temp.user\\Documents\\GitHub\\ethereum-analysis"
global_wd_r_outputs = paste(global_github,"\\Production\\Outputs",sep="")

global_wd = "C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA\\Dissertation_Data"
global_wd_block_info = paste(global_wd,"\\00_Raw_Data",sep="")
global_wd_consol_blocks = paste(global_wd,"\\01_Consolidated",sep="")
global_wd_cleaned_blocks = paste(global_wd,"\\02_Cleaned",sep="")
global_wd_raw_tx = paste(global_wd,"\\03_Raw_Transactions",sep="")
global_wd_cleaned_tx = paste(global_wd,"\\04_Cleaned_Transactions",sep="")
global_wd_addresses = paste(global_wd,"\\05_User_Addresses",sep="")
global_wd_addresses_sum = paste(global_wd,"\\05_User_Addresses\\Summary",sep="")
global_wd_sql_config = paste(global_wd,"\\SQL_Config",sep="")


global_last_block = 3200000
global_label_read = "Label_31"          # "Year 2/Semester 2/Dissertation/Emails from R"
global_label_processed = "Label_32"     # "Year 2/Semester 2/Dissertation/Emails from R/Request Processed"
global_label_cancel = "Label_34"        # "Year 2/Semester 2/Dissertation/Emails from R/Cancel"
global_secret_file = "C:\\Users\\temp.user\\Desktop\\Dissertation\\Google_API\\d14127984_secret_file.json"



##### Options #####
options(scipen=999) # Remove scientific notation
use_secret_file(global_secret_file) # Use secret file for contacting Gmail
gmail_auth(scope = "full") # Set up authentication with Gmail