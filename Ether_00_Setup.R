##### ##### ##### ##### ##### ##### #####
#####  Ethereum Block Data - Setup  #####
##### ##### ##### ##### ##### ##### #####
# Block - 3,127,805 with 16,332,490 transactions
# First Transaction - Block 46,147

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
#library(installr)   # Version:  installr_0.17.5   # lsf.str("package:installr")     # detach("package:installr", unload = TRUE)
#library(RJSONIO)    # Version:  RJSONIO_1.3-0     # lsf.str("package:RJSONIO")      # detach("package:RJSONIO", unload = TRUE)
library(RCurl)      # Version:  RCurl_1.95-4.8    # lsf.str("package:RCurl")        # detach("package:RCurl", unload = TRUE)
library(jsonlite)   # Version:  jsonlite_0.9.19   # lsf.str("package:jsonlite")     # detach("package:jsonlite", unload = TRUE)
library(gmailr)     # Version:  gmailr_0.7.1      # lsf.str("package:gmailr")       # detach("package:gmailr", unload = TRUE)
#library(RODBC)      # Version:  RODBC_1.3-14      # lsf.str("package:RODBC")        # detach("package:RODBC", unload = TRUE)




##### Global variables ####
global_wd = "C:\\Users\\kieran.birrane\\Desktop\\MSc in Computing\\Dissertation\\Ethereum Data - Testing"
global_last_block = 3127805
global_label_read = "Label_31"          # "Year 2/Semester 2/Dissertation/Emails from R"
global_label_processed = "Label_32"     # "Year 2/Semester 2/Dissertation/Request Processed"
global_secret_file = "C:\\Users\\temp.user\\Desktop\\Dissertation\\Google_API\\d14127984_secret_file.json"



##### Options #####
options(scipen=999) # Remove scientific notation
use_secret_file(global_secret_file) # Use secret file for contacting Gmail
gmail_auth(scope = "full") # Set up authentication with Gmail
