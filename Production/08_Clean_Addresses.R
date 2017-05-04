##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ### Get the address information ### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getwd()
setwd(global_wd_consol_blocks)



### Get addresses and their associated mined blocks
# resetDownloadedAddresses(global_wd_consol_blocks)
s = Sys.time()
address <- getAddresses(global_wd_consol_blocks,"Consolidated")
e = Sys.time()
e - s

s = Sys.time()
address <- getAddresses(global_wd_cleaned_blocks,"Cleaned")
e = Sys.time()
e - s



### Get addresses which have participated in transactions
# resetDownloadedAddresses(global_wd_cleaned_tx)
s = Sys.time()
address <- getTxAddresses(global_wd_cleaned_tx,"Tx_Info")
e = Sys.time()
e - s



### Clean the consolidated address files into one set of addresses each
output_file <- paste(global_wd_consol_blocks,"\\Address\\Addresses_Summary.csv",
                     sep = "")

read_add <- read.table(output_file, header = TRUE, sep = ",", colClasses = "character")
read_add <- as.data.frame(read_add$source)

summ_add <- table(read_add)
summ_add
