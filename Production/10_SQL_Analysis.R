##### ##### ##### ##### ##### ##### #####
##### ##### ## SQL Analysis # ##### #####
##### ##### ##### ##### ##### ##### #####


###### Set variables ######
i=1
sql = "SELECT COUNT(*) FROM input.Ethereum_Blocks"
res <- sqlQuery(conn, sql)



###### Load Configuration ######
res <- loadText(conn
                ,paste(global_wd_sql_config,"\\Data_Definition.csv",sep="")
                ,","
                ,"control_table.Data_Definition"
                ,action = "INSERT"
                #,action = "PRINT"
                )
convertSQLtoR(res)



###### Load Blocks ######
### Note: First block won't load as Data_BlockTime is NA, instead of a number
# list_files <- list.files(global_wd_block_info, pattern = "*.csv", full.names = TRUE, recursive = TRUE)
list_files <- list.files(global_wd_consol_blocks, pattern = "*.csv", full.names = TRUE)
len_list <- length(list_files)

sql = "TRUNCATE TABLE input.Ethereum_Blocks"
res <- sqlQuery(conn, sql)

s <- array(dim = c(len_list))
e <- array(dim = c(len_list))
timediff <- array(dim = c(len_list))

for(i in 1:len_list){
  s[i] <- Sys.time()
  x <- loadText(conn
                ,list_files[i]
                ,","
                ,table = "input.Ethereum_Blocks"
                ,action = "INSERT"
                #,action = "PRINT"
                )
  e[i] <- Sys.time()
  timediff[i] <- e[i] - s[i]
}
convertSQLtoR(x)



###### Load Transactions ######
# list_files <- list.files(global_wd_raw_tx, pattern = "*.csv", full.names = TRUE, recursive = TRUE)
list_files <- list.files(global_wd_cleaned_tx, pattern = "*.csv", full.names = TRUE)
len_list <- length(list_files)

sql = "TRUNCATE TABLE input.Ethereum_Transactions"
res <- sqlQuery(conn, sql)

s <- array(dim = c(len_list))
e <- array(dim = c(len_list))
timediff <- array(dim = c(len_list))

for(i in 1:len_list){
  s[i] <- Sys.time()
  x <- loadText(conn
                ,list_files[i]
                ,","
                ,table = "input.Ethereum_Blocks"
                ,action = "INSERT"
                #,action = "PRINT"
  )
  e[i] <- Sys.time()
  timediff[i] <- e[i] - s[i]
}
convertSQLtoR(x)



###### Load Addresses ######
list_files <- list.files(global_wd_addresses, pattern = "*.csv", full.names = TRUE)

sql = "TRUNCATE TABLE input.Addresses"
res <- sqlQuery(conn, sql)

for(i in 1:length(list_files)){
  x <- loadText(conn
                ,list_files[i]
                ,","
                ,table = "input.Addresses"
                ,action = "INSERT"
                #,action = "PRINT"
                )
}
convertSQLtoR(x)

# Clean the consolidated address files into one set of addresses each
output_file <- paste(global_wd_addresses,"\\Summary\\Addresses_Summary.csv",
                     sep = "")

sql = "SELECT ad.[Data_Coinbase] FROM input.Addresses ad WHERE ad.[Data_Coinbase] IS NOT NULL GROUP BY ad.[Data_Coinbase] ORDER BY ad.[Data_Coinbase]"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

colnames(res) <- cbind("Address") # res[1:10,]
write.table(res, output_file, sep = ",", col.names = T, append = F, row.names = FALSE)



