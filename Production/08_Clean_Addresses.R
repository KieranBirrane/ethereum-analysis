##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ### Get the address information ### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getwd()
setwd(global_wd_consol_blocks)



### Get addresses and their associated mined blocks
# resetAddresses(global_wd_consol_blocks)
s = Sys.time()
address <- getAddresses(global_wd_consol_blocks,"Consolidated")
e = Sys.time()
e - s

s = Sys.time()
address <- getAddresses(global_wd_cleaned_blocks,"Cleaned")
e = Sys.time()
e - s



### Get addresses which have participated in transactions
# resetAddresses(global_wd_cleaned_tx)
s = Sys.time()
address <- getTxAddresses(global_wd_cleaned_tx,"Tx_Info")
e = Sys.time()
e - s



######
### Note: Go to 09_SQL_Analysis.R to upload the data and get a distinct list of users
######



### Download address data
# Reset the downloaded addresses file
# resetDownloadedAddresses(global_wd_addresses_sum)

downloadAddress <- downloadAddresses(global_wd_addresses_sum,50,5000)


