##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### # SQL Functions # ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

userid = "sa"
password = "14Jul92*"
data_import = "C:\\Program Files\\Microsoft SQL Server\\MSSQL12.SQLEXPRESS\\MSSQL\\DATA"
data_blocks = paste(data_import,"\\Dissertation_Data\\01_Consolidated",sep="")
data_tx = paste(data_import,"\\Dissertation_Data\\04_Cleaned_Transactions",sep="")

##### Server Connection #####
conn <- odbcConnect("SQLServer_ETH001", uid=userid, pwd=password)
sql <- "SELECT 'test'"
res <- sqlQuery(conn, sql)
res




##### revString #####
#
# Reverses a string
#
#####################
revString <- function(strValue){
  
  
  strSplit <- strsplit(strValue, NULL)[[1]]
  strSplit <- rev(strSplit)
  strValueRev <- paste(strSplit, collapse = '')
  
  return(strValueRev)
  
}



##### splitFile #####
#
# Splits a filepath into a path and a filename
#
#####################
splitFile <- function(filepath){
  
  # Replace \\ with
  filepath <- gsub("/","\\\\",filepath)
  
  # Prepare filename
  filen <- revString(filepath)
  paste(filen, collapse = '')
  pos <- regexpr("\\\\", filen)
  filen <- substr(filen, 0,pos-1)
  filen <- revString(filen)
  
  # Prepare filepath
  filep = substr(filepath, 0,nchar(filepath)-nchar(filen)-1)
  
  # Index 1 for filepath and Index 2 for filename
  output = cbind(filep,filen)
  
  return(output)
  
}



##### createSchema #####
#
# Creates a schema.ini file
#
########################
createSchema <- function(filepath,delim){
  
  # Get filepath and filename
  snip <- splitFile(filepath)
  filep <- snip[1]
  filen <- snip[2]
  
  # Set up file contents
  schema_text <- paste("[",filen,"]\nFORMAT=DELIMITED(",delim,")\nMAXSCANROWS=0",sep="")
  output_filen <- paste(filep,"/schema.ini",sep="")
  
  # Create file
  write(schema_text,output_filen)

}



##### loadPreparedStatement #####
#
# Loads a prepared statement
#
#################################
loadPreparedStatement <- function(psName){
  
  # Get filepath and filename
  sql = readLines(con = paste(global_sql_ps,"\\",psName,sep=""))
  sql = paste(sql,collapse = "")
  
  return(sql)
}



##### loadText #####
#
# Loads data into the database or into a variable
#
#####################
loadText <- function(conn,filepath=list_files[i],delim,table = "",action = "SELECT"){
  
  # Create schema.ini file
  createSchema(filepath,delim)

  # Add variables to SQL
  fileVar <- splitFile(filepath)
  sql <- paste("EXECUTE LoadText @filepath = '",fileVar[1]
               ,"',@filename = '",fileVar[2]
               ,"',@table = '",table
               ,"',@action = '",action
               ,"'",sep="")
  
  # Execute query and retrieve results
  res <- sqlQuery(conn,sql,errors = T,as.is = T)
  
  # Return result
  return(res)
  
}



##### convertSQLtoR #####
#
# Prints a SQL-returned string to the screen in R
#
#####################
convertSQLtoR <- function(res){
  
  # Return result
  return(cat(as.character(res)))
  
}



##### retrieveAddressBlocks #####
#
# Retrieve mined blocks associated to an address
#
#####################
retrieveAddressBlocks <- function(address){
  sql=paste("
    SELECT eb.[Data_Number]
    FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
    WHERE 1=1
    AND eb.[Data_Coinbase] = '",address,"'
    AND eb.[Data_Number]<3100155
    ORDER BY eb.[Data_Number]"
    ,sep="")
  
  res <- sqlQuery(conn, sql,errors = T,as.is = T)
  blocks <- as.numeric(res$Data_Number)
  blocks <- as.data.frame(blocks)
  
  # Return result
  return(blocks)
  
}



##### retrieveAddressNameBlocks #####
#
# Retrieve mined blocks associated to an address (grouped by name)
#
#####################
retrieveAddressNameBlocks <- function(name){
  sql=paste("
            SELECT eb.[Data_Coinbase],eb.[Data_Number]
            FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
              LEFT JOIN
              ETH001_BLK_DATA.input.Ethereum_Addresses ea
              ON eb.[Data_Coinbase] = ea.[Data_Address]
            WHERE 1=1
            AND eb.[Data_Number]<3100155
            AND ea.[Data_Name] = '",name,"'
            ORDER BY eb.[Data_Number]"
            ,sep="")
  
  res <- sqlQuery(conn, sql,errors = T,as.is = T)
  blocks <- as.data.frame(res)
  blocks$Data_Number <- as.numeric(blocks$Data_Number)
  
  # Return result
  return(blocks)
  
}