##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### Address Profiling ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

#####
### Check the uniqueness of transaction senders and recipients
#####
# Miner addresses - 3,583
sql = "
SELECT DISTINCT et.[Data_Sender],et.[Data_Recipient]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
addresses <- res[,c("Data_Sender","Data_Recipient")]
nrow(addresses) # 1,939,262


sql = "
SELECT DISTINCT eb.[Data_Coinbase]
FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
WHERE 1=1
AND eb.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
miners <- res



### Get number of senders and number of recipients

count_senders <- count(addresses$Data_Sender)       # 640,405
nrow(count_senders)

count_receivers <- count(addresses$Data_Recipient)  # 893,691
nrow(count_receivers)

count_total_add <- rbind(count_senders,count_receivers)
count_total_add <- rbind(count_total_add,data.frame(x=miners$Data_Coinbase,freq=0))
count_total <- count(count_total_add$x)
nrow(count_total)                                   # 933,682

100*nrow(count_senders)/nrow(count_total)           # 68.5892%
100*nrow(count_receivers)/nrow(count_total)         # 95.71685%

### Remove large datasets
rm(addresses)
rm(miners)
rm(count_senders)
rm(count_receivers)
rm(count_total_add)
rm(count_total)
rm(miners)





#####
# Get address data for the addresses appearing in the data
#####
sql = "
SELECT es.[Data_Address],es.[Data_Name],es.[Data_Code],es.[Data_Storage]
FROM ETH001_BLK_DATA.input.Ethereum_Addresses es
LEFT JOIN
(
  SELECT a.[Address] FROM (
    SELECT eb.[Data_Coinbase] AS [Address]
    FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
    WHERE 1=1
    AND eb.[Data_Time] < '2017-02-01'
    
    UNION ALL
    
    SELECT et.[Data_Sender] AS [Address]
    FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
    WHERE 1=1
    AND et.[Data_Time] < '2017-02-01'
    
    UNION ALL
    
    SELECT et.[Data_Recipient] AS [Address]
    FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
    WHERE 1=1
    AND et.[Data_Time] < '2017-02-01'
  ) a
  GROUP BY a.[Address]
) dta
ON es.[Data_Address] = dta.[Address]
WHERE 1=1
AND dta.[Address] IS NOT NULL
"
  
res <- sqlQuery(conn, sql,errors = T,as.is = T)
address_info <- res
nrow(address_info)      # 933,681     # This is one less because the first has a NULL



### Check how many user addresses have code
nrow(address_info[address_info$Data_Code=="0x",])     # 792,185 have no code
nrow(address_info[address_info$Data_Code!="0x",])     # 141,496 have code - smart contracts
# Creates in transaction table = xxx,xxx
# Discrepancy = xxx-yyy = ggg



### Check how many user addresses have names
nrow(address_info[is.na(address_info$Data_Name),])      # 933,474 have no name
nrow(address_info[!is.na(address_info$Data_Name),])     # 207 have a name



### Check how many user addresses have storage
nrow(address_info[is.na(address_info$Data_Storage),])     # 933,681 have no storage
nrow(address_info[!is.na(address_info$Data_Storage),])    # 0 have storage



### Remove large datasets
rm(address_info)