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