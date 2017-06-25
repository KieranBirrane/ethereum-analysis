##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ### Transaction Profiling ### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

#####
### Check the uniqueness of transaction senders and recipients
#####
# Overall total addresses - 933,183 (send/receive only)
# Total number of transactions = 17,345,454
sql = "
SELECT
COUNT(DISTINCT et.[Data_Sender]) AS [Count_Sender]
,COUNT(DISTINCT et.[Data_Recipient]) AS [Count_Recipient]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
addresses <- res



### Get number of senders and number of recipients
count_senders <- addresses$Count_Sender         # 640,405
count_receivers <- addresses$Count_Recipient    # 893,691

### Remove big datasets
rm(addresses)



# Get distribution of amount transactions
sql = "
SELECT
et.[Data_Amount]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
amounts <- data.frame(Data_Amount=as.numeric(res$Data_Amount))
wei <- as.numeric(10^18)

# Get summary of data
# Min.    1st Qu.   Median    Mean    3rd Qu.   Max. 
# 0       0.09      1.0006    57.7859 1.4474    11,901,464.2395
summ <- summary(amounts)
quantile(amounts$Data_Amount,0.99)        # 99th Percentile = 637.4874
quantile(amounts$Data_Amount,0.9999)      # 99.99th Percentile = 49999.9993

### Remove big datasets
rm(amounts)



# Get number of function calls
sql = "
SELECT
et.[Data_TxType]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
tx_type <- res$Data_TxType

count_tx_type <- count(tx_type)
count_tx_type
# x         freq
# call       1,158,829     1158829/17345454 =  6.6809%
# create       183,231      183231/17345454 =  1.0564%
# suicide        1,527        1527/17345454 =  0.0088%
# tx        16,001,867    16001867/17345454 = 92.2540%
sum(count_tx_type$freq)

### Remove big datasets
rm(tx_type)



# Get number of unique addresses for create transactions
sql = "
SELECT
COUNT(DISTINCT et.[Data_Recipient])
FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_TxType] = 'create'
AND et.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
res


# Get number of transactions related to call functions
sql = "
SELECT
COUNT(et.[Data_TxType])
FROM ETH001_BLK_DATA.input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_TxIndex] <> 'NA'
AND et.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
res   # 1,228,426       # 1228426/16001867 = 7.6768%