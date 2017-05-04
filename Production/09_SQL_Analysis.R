##### ##### ##### ##### ##### ##### #####
##### ##### ## SQL Analysis # ##### #####
##### ##### ##### ##### ##### ##### #####

userid = "sa"
password = "14Jul92*"
data_import = "C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA"
data_blocks = paste(data_import,"\\Dissertation_Data\\01_Consolidated",sep="")
data_tx = paste(data_import,"\\Dissertation_Data\\04_Cleaned_Transactions",sep="")



##### Server Connection #####
conn <- odbcConnect("SQLServer_ETH001", uid=userid, pwd=password)


###### Blocks ######
i=1
list_files <- list.files(data_blocks, pattern = "*.csv", full.names = TRUE)

for(i in 1:10){
  x <- loadText(conn,list_files[i],",", table = "input.Ethereum_Blocks")
}

###### Blocks ######
i=1
list_files <- list.files(data_tx, pattern = "*.csv", full.names = TRUE)

for(i in 1:10){
  x <- loadText(conn,list_files[i],",")
}

  

  
#############################

filennn = "C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\00_Raw_Data\01_0-250,000\Block_Info_100_149_.csv"

filennn = "C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA\\Dissertation_Data\\00_Raw_Data\\01_0-250,000"


filepath = "C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA\\Dissertation_Data\\00_Raw_Data\\01_0-250,000\\Block_Info_100_149_.csv"
delim = ","

list_files <- list.files(filennn, pattern = "*.csv", full.names = TRUE)


res <- sqlQuery(con, "select * from dbo.temp_table")

resss <- sqlQuery(con,"select day(blk.[data#time]) as [day],avg(CAST(blk.[data#blockTime] as float)) as [avg_time]
from dbo.blocks_750k_2 blk
                  group by day(blk.[data#time])")

summary(resss)
resss$day

DSN:  SQLServer_ETH001

IEEYDATAMINING\SQLEXPRESS

ETH001_BLK_DATA
