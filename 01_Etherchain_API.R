##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ### Etherchain ## ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
# Functions come from
# https://etherchain.org/documentation/api/#api-Statistics-GetStatisticsAll





##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ## Blocks # ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

##### getBlockCount #####
#
# Returns the current block count from Ethereum blockchain
#
#########################
getBlockCount <- function(){
  # https://etherchain.org/api/blocks/count
  
  fn <- paste("https://etherchain.org/api/blocks/count",sep = "")
  fn <- requestFromEtherchain(fn)
  fn <- data.frame(fromJSON(fn))
  fn <- fn[1,2]

  return(fn)
}



##### getBlock #####
#
# Returns the block information for a specific block
#
####################
getBlock <- function(blockno){
  # https://etherchain.org/api/block/:id
  # id  String  The number or hash of the block
  fn <- paste("https://etherchain.org/api/block/",as.character(blockno),sep = "")
  fn <- requestFromEtherchain(fn)
  fn <- fromJSON(fn)
  fn <- data.frame(fn)
  
  return(fn)
}



##### getBlockTx #####
#
# Returns the transactions for a specific block
#
######################
getBlockTx <- function(blockno){
  # https://etherchain.org/api/block/:id/tx
  # id  String  The number or hash of the block
  fn <- paste("https://etherchain.org/api/block/",as.character(blockno),"/tx",sep = "")
  fn <- requestFromEtherchain(fn)
  
  if(nchar(fn)==22){
    fn <- setEmptyBlockTx(blockno)
  } else {
    fn <- data.frame(fromJSON(fn))
  }

  return(fn)
}



##### setEmptyBlockTx #####
#
# Returns an empty block transactions result
#
###########################
setEmptyBlockTx <- function(){
  header <- list("status"=as.integer()
                 ,"data.hash"=as.character()
                 ,"data.sender"=as.character()
                 ,"data.recipient"=as.character()
                 ,"data.accountNonce"=as.character()
                 ,"data.price"=as.numeric()
                 ,"data.gasLimit"=as.integer()
                 ,"data.amount"=as.numeric()
                 ,"data.block_id"=as.integer()
                 ,"data.time"=as.character()
                 ,"data.newContract"=as.integer()
                 ,"data.isContractTx"=as.logical()
                 ,"data.blockHash"=as.character()
                 ,"data.parentHash"=as.character()
                 ,"data.txIndex"=as.logical()
                 ,"data.gasUsed"=as.integer()
                 ,"data.type"=as.character()
  )
  df <- data.frame(header)
  
  return(df)
  
}




##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### Others #### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

##### requestFromEtherchain #####
#
# Sends request to Etherchain, including sleep to overcome request limit
#
#################################
requestFromEtherchain <- function(url){
  # Sys.sleep(0.3) # The API is currently limited to a maximum of 10 requests per 3 seconds and IP
  request = getURL(url)
  
  return(request)
}
