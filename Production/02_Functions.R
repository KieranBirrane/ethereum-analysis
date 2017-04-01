##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ### Functions ### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####



##### getLabels #####
#
# Returns all labels from Gmail
#
#####################
getLabels <- function(){
  my_labels <- labels()
  base = cbind(my_labels$labels[[1]]$id,my_labels$labels[[1]]$name)
  for(k in 2:length(my_labels$labels)){
    base2 = cbind(my_labels$labels[[k]]$id,my_labels$labels[[k]]$name)
    base = rbind(base,base2)
  }

  return(base[order(base[,1]),])
}



##### setupBlockFile #####
#
# Define the file name of the block outputs
#
##########################
setupBlockFile <- function(startBlock,endBlock, type = c("Regular","Consolidated","Cleaned","Missing","Duplicated","Tx")){
  # Set default to "Regular"
  if(missing(type)){
    type = "Regular"
  }
  
  if(type == "Regular"){
    filename <- paste(getwd(),"\\","Block_Info_",startBlock,"_",endBlock,".csv"
                    ,sep = "")
  } else if(type == "Consolidated" | type == "Cleaned") {
    filename <- paste(getwd(),"\\",type,"\\",type,"_",startBlock,"_",endBlock,".csv"
                      ,sep = "")
  } else if(type == "Missing") {
    filename <- paste(getwd(),"\\Missing_Blocks_",Sys.Date(),".csv"
                      ,sep = "")
  } else if(type == "Duplicates") {
    filename <- paste(getwd(),"\\Duplicate_Blocks_",Sys.Date(),".csv"
                      ,sep = "")
  } else if(type == "Tx") {
    filename <- paste(getwd(),"\\Tx\\Tx_Info_",startBlock,"_",endBlock,".csv"
                      ,sep = "")
  }
  if(file.exists(filename)){file.remove(filename)}
  
  return(filename)
}



##### createSubject #####
#
# Define the email subject
#
#########################
createSubject <- function(startBlock,endBlock,type = "Update"){
  subject = paste(type,": Blocks ",as.character(startBlock)," to ",as.character(endBlock)," : ",Sys.time()
                    ,sep = "")

  return(subject)
}



##### createMessage #####
#
# Define the email message
#
#########################
createMessage <- function(iteration,startBlock,endBlock,type = 0){
  # 0   Update
  # 1   Completed
  # 2   Failed
  # 3   Request
  if(type==0){
    message = paste("Update: Code currently at block ",iteration," in loop ",startBlock," to ",endBlock
                    ,sep = "")
  } else if (type==1){
    message = paste("Completed: Code finished at block ",iteration," in loop ",startBlock," to ",endBlock
                    ,sep = "")
  } else if (type==2){
    message = paste("Failed: Code failed at block ",iteration," in loop ",startBlock," to ",endBlock
                    ,sep = "")
  } else if (type==3){
  message = paste("Request ",iteration,":",startBlock,":",endBlock,":"
                  ,sep = "")
  }
  
  return(message)
}



##### createTemplate #####
#
# Create email template
#
##########################
createTemplate <- function(to,from,subject){
  template <- rbind("to" = to
                    ,"from" = from
                    ,"subject" = subject)
  
  return(template)
}



##### createEmailFromTemplate #####
#
# Create email from template
#
###################################
createEmailFromTemplate <- function(email_template,message){
  email <- mime(
    To = as.character(email_template["to",])
    ,From = as.character(email_template["from",])
    ,Subject = as.character(email_template["subject",])
    ,body = message
  )
  
  return(email)
}



##### sendMessageWithLabel #####
#
# Send a mail and attach a specified label
#
################################
sendMessageWithLabel <- function(email, label_id = "Label_31"){
  ml <- send_message(email)
  mail_id <- ml$id
  modify_message(mail_id, add_labels = label_id)
}



##### setEmailToProcessed #####
#
# Change a mail label to processed
#
################################
setEmailToProcessed <- function(email, remove_label){
  modify_message(email$id, add_labels = "Label_32", remove_labels = remove_label)
}



##### getRequestInfo #####
#
# Get the latest email to read requests
#
##########################
getRequestInfo <- function(label){
  msgs <- messages(label_ids = label) # Get all messages
  msgs_new <- message(msgs[[1]]$messages[[1]]$id, format = "full") # Get latest message
  snip <- msgs_new$snippet # Get message body
  snip_len <- nchar(snip) # Get snip length
  checker <- substr(snip,0,regexpr(" ", snip) - 1) # Get message type
  snip <- substr(snip, 9, snip_len) # Reset message snip

  if(checker == "Request"){
    
    # Get loopsize
    pos_start <- 0
    pos_end <- regexpr(":", snip) - 1
    loop_block = as.numeric(substr(snip,pos_start,pos_end))
    snip <- substr(snip, pos_end + 2, snip_len)

    # Get startBlock    
    pos_start <- 0
    pos_end <- regexpr(":", snip) - 1
    start_block = as.numeric(substr(snip,pos_start,pos_end))
    snip <- substr(snip, pos_end + 2, snip_len)

    # Get endBlock    
    pos_start <- 0
    pos_end <- regexpr(":", snip) - 1
    end_block = as.numeric(substr(snip,pos_start,pos_end))
    snip <- substr(snip, pos_end + 2, snip_len)
    
    # Return information
    info.df <- as.data.frame(list("startBlock" = start_block
                                  ,"endBlock" = end_block
                                  ,"loopsize" = loop_block)
    )
    
    # Change message label
    setEmailToProcessed(msgs_new,label)
    
    return(info.df)
  }else if(checker == "Cancel"){
    setEmailToProcessed(msgs_new,label)
    
    return(checker)
  }else{
    return("No request")
  }
  
}



##### getBlockLoop #####
#
# Start loop for downloading blocks
#
########################
getBlockLoop <- function(startBlock,endBlock,loopsize){
  # Set up loop number
  iteration = startBlock
  loop_num = ceiling((endBlock-startBlock)/loopsize)

  tryCatch(
    {
      for(j in 1:loop_num){
        # Setup loop ending block number
        endblock_loop = min(startBlock + loopsize - 1,endBlock)
        filename <- setupBlockFile(startBlock, endblock_loop)
        
        # Retrieve information for first block in loop
        getInfo <- getBlock(startBlock)
        
        # Write outputs to file
        write.csv(getInfo, filename, row.names = FALSE)
        
        # Loop through remaining blocks in loop and write to csv
        for(i in (startBlock+1):endblock_loop){
          iteration = i

          # Request data from site
          new_block <- getBlock(iteration)
          write.table(new_block, filename, sep = ",", col.names = F, append = T, row.names = FALSE)
        }
        
        # Reset starting block
        startBlock = endblock_loop + 1
      }
      
    }
    , error = function(e){
      # Rename the output file
      file.rename(filename,setupBlockFile(startBlock, iteration - 1))
    }
    , finally = {
      # Return failure block
      return(iteration)
    }
  )
  
  return("Run Completed")
}



##### createDirectory #####
#
# Create directory if it doesn't exist
# http://stackoverflow.com/questions/10266963/moving-files-between-folders
####################
createDirectory <- function(full_path){
  todir <- dirname(full_path)
  if(!isTRUE(file.info(todir)$isdir)){
    dir.create(todir, recursive=TRUE)
  }
}



##### moveFile #####
#
# Move file from one place to another
# http://stackoverflow.com/questions/10266963/moving-files-between-folders
####################
moveFile <- function(from, to){
  # Createa directory if it doesn't exist
  createDirectory(to)
  if(file.exists(to)){file.remove(to)}
  file.rename(from = from, to = to)
}



##### consolidateBlockFiles #####
#
# Get the latest email to read requests
#
#################################
consolidateBlockFiles <- function(wd, start_block, end_block, clean = FALSE){
  
  # Setup variables
  setwd(wd)
  if(clean){
    consol_type = "Cleaned"
    check_file_name = "Consolidated"
  } else {
    consol_type = "Consolidated"
    check_file_name = "Block_Info"
  }
  consol_filename <- setupBlockFile(0, global_last_block, type = consol_type)
  createDirectory(consol_filename) # Create directory of output file if it doesn't exist
  row_count = 0
  tx_count = 0
  block_filter <- factor(c(start_block:end_block))
  
  # Get list of files in directory
  list_files <- list.files(wd, pattern = "*.csv", full.names = TRUE)
  
  # Get old file name and create new file name
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr(check_file_name,old_file) == -1){
      next # If filename doesn't contain "Block_Info"/"Consolidated" then go to next file
    }
    
    # Set file path and name
    file_path <- strsplit(old_file, "/")[[1]][1]
    file_name <- strsplit(old_file, "/")[[1]][2]
    file_move <- "\\Archived Data"
    
    # Set new file name
    new_file <- paste(file_path,file_move,"/",file_name
                      ,sep="")
    createDirectory(new_file) # Create directory of file if it doesn't exist
    
    
    
    # Open file and create new consolidated file
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character") # str(read_data[1,])
    new_data_temp <- cbind.data.frame(read_data
                                 ,Sys.time()
                                 ,file_name)
    
    # Count number of rows
    row_count = row_count + nrow(read_data)
    
    # Filter blocks by input block parameters
    new_data_temp <- new_data_temp[as.factor(new_data_temp$data.number) %in% block_filter,]
    new_data <- new_data_temp
    
    # Filter out transactions != 0
    if(clean){
      new_data <- new_data[new_data$data.tx_count != 0,] # filter out where txn is not zero
      if(nrow(new_data) != 0){
        tx_count = tx_count + sum(as.numeric(read_data$data.tx_count))
      }
    }
    
    

    # Set write table information
    if(i==1){
      col_names = T
      row_append = F
    } else {
      col_names = F
      row_append = T
    }
    write.table(new_data, consol_filename, sep = ",", col.names = col_names, append = row_append, row.names = FALSE)
    
    # Move read file to archive folder, if it contained same rows in the selected range
    if(nrow(read_data)==nrow(new_data_temp)){
      moveFile(old_file, new_file)
    }
  }
  
  # Create new file name
  consol_filename_new <- setupBlockFile(start_block, end_block, type = consol_type)
  moveFile(consol_filename,consol_filename_new)
  
  # Open new cleaned file and check the row count
  read_data_consol <- read.table(consol_filename_new, header = TRUE, sep = ",", colClasses = "character")
  
  # Return information
  if(clean){
    count_data <- tx_count
    count_file <- sum(as.numeric(read_data_consol$data.tx_count))
    count_blocks <- nrow(read_data_consol)
    true_false <- count_file == count_data
    info.df <- as.data.frame(list("TRUE_FALSE" = true_false
                                  ,"Actual" = count_file
                                  ,"Expected" = count_data
                                  ,"Input_Tx" = count_data
                                  ,"Output_Tx" = count_file
                                  ,"Output_Blocks" = count_blocks))
  } else {
    count_data <- row_count
    count_file <- nrow(read_data_consol)
    true_false <- count_file == end_block - start_block + 1
    info.df <- as.data.frame(list("TRUE_FALSE" = true_false
                                  ,"Actual" = count_file
                                  ,"Expected" = end_block - start_block + 1
                                  ,"Input_Blocks" = count_data
                                  ,"Output_Blocks" = count_file))
  }
  
  return(info.df)
}



##### checkMissingBlocks #####
#
# Check for missing blocks
#
##############################
checkMissingBlocks <- function(wd){
  
  # Setup variables
  setwd(wd)
  miss_tx = 0
  output_file <- setupBlockFile(start_block, end_block, type = "Missing")

  # Get list of files in directory
  list_files <- list.files(wd, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Consolidated",old_file) == -1){
      next # If filename doesn't contain "Consolidated" then go to next file
    }
    
    # Get block information from file name
    snip <- old_file
    snip_len <- nchar(snip)
    
    # Get file name
    pos_start <- 0
    pos_end <- regexpr("Consolidated_", snip)
    snip <- substr(snip, pos_end, snip_len)
    old_file_name <- snip
    
    # Get startBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr("_", snip) - 1
    start_block = as.numeric(substr(snip, 0, pos_end))
    
    # Get endBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr(".csv", snip) - 1
    end_block = as.numeric(substr(snip, 0, pos_end))
    
    
    
    # Import dataset to get blocks
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
    read_data <- read_data$data.number
    
    
                        
    # Set up dataframe to sanity check against
    checker <- as.data.frame(c(start_block:end_block))
    colnames(checker) <- "checker.number"
    
    # Get missing blocks and create output dataframe
    missing_blocks <- checker[!(checker$checker.number %in% as.factor(read_data)),]
    
    # Create output
    if(length(missing_blocks) == 0){
      none_missing <- as.data.frame(list("Blocks" = "None missing"))
      missing_blocks_df <- cbind(none_missing,old_file_name)
    }else{
      missing_blocks_df <- cbind(missing_blocks,old_file_name)
    }
  
    # Total number of missing blocks
    miss_tx = miss_tx + length(missing_blocks)

    # Write output to file
    if(!file.exists(output_file)){
      write.csv(missing_blocks_df, output_file, row.names = FALSE)
    } else {
      write.table(missing_blocks_df, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
      }
  }
  
  return(miss_tx)
}



##### checkDuplicateBlocks #####
#
# Check for duplicated blocks
#
################################
checkDuplicateBlocks <- function(wd){
  
  # Setup variables
  setwd(wd)
  dupe_tx = 0
  output_file <- setupBlockFile(0, 0, type = "Duplicates")
  
  # Get list of files in directory
  list_files <- list.files(wd, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    old_file_name <- substr(old_file, nchar(wd)+2, nchar(old_file))
    if(regexpr("Consolidated",old_file_name) == -1){
      next # If filename doesn't contain "Consolidated" then go to next file
    }
    
    
    
    # Import dataset to get blocks
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
    read_data <- read_data$data.number
    
    
    
    # Get duplicate blocks and create output dataframe
    duplicate_blocks <- read_data[duplicated(read_data)]
    
    # Create output
    if(length(duplicate_blocks) == 0){
      none_duplicated <- as.data.frame(list("Blocks" = "None duplicated"))
      duplicated_blocks_df <- cbind(none_duplicated,old_file_name)
    }else{
      duplicated_blocks_df <- cbind(duplicate_blocks,old_file_name)
    }
    
    # Total number of missing blocks
    dupe_tx = dupe_tx + length(duplicate_blocks)
    
    # Write output to file
    if(!file.exists(output_file)){
      write.csv(duplicated_blocks_df, output_file, row.names = FALSE)
    } else {
      write.table(duplicated_blocks_df, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
    }
  }
  
  return(dupe_tx)
}



##### downloadMissingBlocks #####
#
# Download the blocks retrieved from the checkMissingBlocks function
#
#################################
downloadMissingBlocks <- function(wd){

  # Setup variables
  setwd(wd)

  # Get list of files in directory
  list_files <- list.files(wd, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Missing_Blocks",old_file) == -1){
      next # If filename doesn't contain "Missing_Blocks" then go to next file
    }
    
    # Get blocks from missing_blocks file
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
    missing_blocks <- read_data$missing_blocks
    missing_blocks <- missing_blocks[missing_blocks!="None missing"]
    start_block <- paste("Missing_",min(missing_blocks)
                         ,sep = "") # Set up name so that it contains the word "Missing"
    end_block <- max(missing_blocks)
    output_file <- setupBlockFile(start_block, end_block)

    # Get block information
    len_missing <- length(missing_blocks)
    
    # Get new block information
    getInfo <- getBlock(missing_blocks[1])
    write.csv(getInfo, output_file, row.names = FALSE)
    
    if(len_missing<2){next}
    
    for(i in 2:len_missing){
      # Get new block information
      getInfo <- getBlock(missing_blocks[i])
      
      # Write outputs to file
      write.table(getInfo, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
      }
  }
  
  return("Missing blocks retrieved")
}



##### getTxLoop #####
#
# Start loop for downloading transactions
#
#####################
getTxLoop <- function(cleaned_wd, startpoint, loop_size){
  # Setup variables
  setwd(cleaned_wd)
  dwnl_block_filename = paste(cleaned_wd,"\\Downloaded_Blocks.csv",
                              sep = "")
  iteration = startpoint + loop_size
  
  # Read which blocks have been already downloaded
  checker <- read.table(dwnl_block_filename, header = TRUE, sep = ",", colClasses = "character")
  
  # Get list of files in directory
  list_files <- list.files(cleaned_wd, pattern = "*.csv", full.names = TRUE)
  
  tryCatch(
    {
      # Get file name to check
      for(i in 1:length(list_files)){
        # Check file name and move on if necessary
        old_file <- list_files[i]
        if(regexpr("Cleaned",old_file) == -1){
          next # If filename doesn't contain "Cleaned" then go to next file
        }

        # Get blocks from missing_blocks file
        read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
        blocks <- read_data$data.number
        
        # Ignore blocks already downloaded
        blocks <- blocks[!(as.factor(blocks) %in% checker$Block_Number)]
        blocks <- blocks[order(as.numeric(blocks))]

        # Constrain loop to loopsize
        loop_constraint <- factor(c(startpoint:(startpoint+loop_size)))
        blocks <- blocks[(as.factor(blocks) %in% as.factor(loop_constraint))]
        
        # Get block information
        len_missing <- length(blocks)
        if(len_missing==0){next} # If there are no more block Tx to download, go to next file 

        # Get ending point
        start_block <- min(as.numeric(blocks))
        end_block <- max(as.numeric(blocks))
        output_file <- setupBlockFile(start_block, end_block, "Tx")
        
        # Get new block information
        getInfo <- getBlockTx(blocks[1])
        write.csv(getInfo, output_file, row.names = FALSE)
        
        # Add block to downloaded file
        downloaded_block = data.frame(
          list("Block_Number"=as.integer(blocks[1])
               ,"Time"=Sys.time()
          )
        )
        write.table(downloaded_block, dwnl_block_filename, sep = ",", col.names = F, append = T, row.names = FALSE)

        # Loop through remaining blocks
        for(i in 2:len_missing){
          # Get new block information
          iteration = as.numeric(blocks[i-1])
          getInfo <- getBlockTx(blocks[i])
          
          # If all transactions are retrieved then add them to the file, else repeat
          if(sum(getInfo$status)==length(getInfo$status)){
            # Write outputs to file
            write.table(getInfo, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
            
            # Add block to downloaded file
            downloaded_block = data.frame(
              list("Block_Number"=as.integer(blocks[i])
                   ,"Time"=Sys.time()
              )
            )
            write.table(downloaded_block, dwnl_block_filename, sep = ",", col.names = F, append = T, row.names = FALSE)
          }else{
              i=i-1 # Repeat previous attempt
          }
        }
      }
    }
    , error = function(e){
      # Rename the output file
      file.rename(output_file,setupBlockFile(start_block, iteration, "Tx"))
      }
    , finally = {
      # Return failure block
      return(iteration)
    }
  )
  
  return("Run Completed")
}



##### resetDownloadedBlocks #####
#
# REset the file for tracking downloaded blocks
#
#################################
resetDownloadedBlocks <- function(cleaned_wd){
  
  # Setup variables
  setwd(cleaned_wd)
  dwnl_block_filename = paste(cleaned_wd,"\\Downloaded_Blocks.csv",
                              sep = "")
  if(file.exists(dwnl_block_filename)){file.remove(dwnl_block_filename)} # Delete old file
  
  downloaded_block = data.frame(
    list("Block_Number"
         ,"Time"
    )
  )
  write.table(downloaded_block[1,], dwnl_block_filename, sep = ",", col.names = F, append = F, row.names = F)
  
}



##### renameTxInfo #####
#
# Rename the Tx_Info files
#
#####################
# wdir = "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\02_Cleaned\\Tx"
renameTxInfo <- function(wdir){
  # Setup variables
  setwd(wdir)
  
  # Get list of files in directory
  list_files <- list.files(wdir, pattern = "*.csv", full.names = TRUE)
  
    # Get file name to check
    for(i in 1:length(list_files)){
      # Check file name and move on if necessary
      old_file <- list_files[i]
      if(regexpr("Tx_Info",old_file) == -1){
        next # If filename doesn't contain "Cleaned" then go to next file
      }
      
      # Get blocks from missing_blocks file
      read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
      blocks <- read_data$data.block_id

      # Get ending point
      start_block <- min(as.numeric(blocks))
      end_block <- max(as.numeric(blocks))
      output_file <- setupBlockFile(start_block, end_block, "Tx")
      
      # Get block information
      len_missing <- length(blocks)
      if(len_missing==0){next} # If there are no more block Tx to download, go to next file 
      
      # Get new block information
      file.rename(old_file,output_file)

    }
  
  return("Run Completed")
}



##### combineTx #####
#
# Combine Tx files
#
#####################
combineTx <- function(wdir, startpoint, endpoint){
  # Setup variables
  setwd(wdir)
  count_files = 0
  
  # Get list of files in directory
  list_files <- list.files(wdir, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){

    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Tx_Info",old_file) == -1){
      next # If filename doesn't contain "Cleaned" then go to next file
    }
    
    # Get block information from file name
    snip <- old_file
    snip_len <- nchar(snip)
    
    # Get file name
    pos_start <- 0
    pos_end <- regexpr("Info_", snip)
    snip <- substr(snip, pos_end, snip_len)
    old_file_name <- snip
    new_file <- paste(wdir,"\\Consolidated\\Tx_",old_file_name,
                     sep="")
    
    # Get startBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr("_", snip) - 1
    start_block = as.numeric(substr(snip, 0, pos_end))
    
    # Get endBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr(".csv", snip) - 1
    end_block = as.numeric(substr(snip, 0, pos_end))
    
    # If file is outside consolidation points, ignore it
    if(end_block<startpoint || start_block>endpoint){
      next
    }

    # Get blocks from missing_blocks file
    count_files = count_files + 1
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
    if(count_files==1){
      consol_blocks <- read_data
    }else{
      consol_blocks <- rbind(consol_blocks,read_data)
    }
    
    # Move file
    moveFile(old_file,new_file)
  }
  
  
  # Setup output file
  consol_blocks <- consol_blocks[order(as.numeric(consol_blocks$data.block_id)),]
  start_block <- min(as.numeric(consol_blocks$data.block_id))
  end_block <- max(as.numeric(consol_blocks$data.block_id))
  
  ideal = paste(startpoint,"_",endpoint,sep="")
  actual = paste("(",start_block,"_",end_block,")",sep="")
  output_file <- setupBlockFile(ideal, actual, "Tx")
  
  # Write output file
  write.csv(consol_blocks, output_file, row.names = FALSE)
  
  return("Run Completed")
}



##### checkMissingTx #####
#
# Check for missing transactions
#
##########################
checkMissingTx <- function(tx_wd, block_wd){
  
  # Setup variables
  setwd(tx_wd)
  miss_tx = 0
  output_file <- setupBlockFile(start_block, end_block, type = "Missing")
  
  # Get list of files in directory
  list_files <- list.files(tx_wd, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Tx_Info_",old_file) == -1){
      next # If filename doesn't contain "Consolidated" then go to next file
    }
    
    # Get block information from file name
    snip <- old_file
    snip_len <- nchar(snip)
    
    # Get file name
    pos_start <- 0
    pos_end <- regexpr("Info_", snip)
    snip <- substr(snip, pos_end, snip_len)
    old_file_name <- snip
    
    # Get startBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr("_", snip) - 1
    start_block = as.numeric(substr(snip, 0, pos_end))
    
    # Get endBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr("_", snip) - 1
    end_block = as.numeric(substr(snip, 0, pos_end))
    
    

    # Import dataset to get blocks
    cleaned_block_file = paste(block_wd,"\\Cleaned_",start_block,"_",end_block,".csv",
                               sep="")
    read_data_block <- read.table(cleaned_block_file, header = TRUE, sep = ",", colClasses = "character")
    read_data_block <- read_data_block$data.number
    
    # Import dataset to get Tx
    read_data_tx <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
    read_data_tx <- read_data_tx$data.block_id
    
    # Get missing blocks and create output dataframe
    missing_blocks <- read_data_block[!(as.factor(read_data_block) %in% as.factor(read_data_tx))]
    
    # Create output
    if(length(missing_blocks) == 0){
      none_missing <- as.data.frame(list("missing_blocks" = "None missing"))
      missing_blocks_df <- cbind(none_missing,old_file_name)
    }else{
      missing_blocks_df <- cbind(missing_blocks,old_file_name)
    }
    
    # Total number of missing blocks
    miss_tx = miss_tx + length(missing_blocks)
    
    # Write output to file
    if(!file.exists(output_file)){
      write.csv(missing_blocks_df, output_file, row.names = FALSE)
    } else {
      write.table(missing_blocks_df, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
    }
  }
  
  return(miss_tx)
}



##### downloadMissingTx #####
#
# Download the tx of the blocks retrieved from the checkMissingTx function
#
#############################
downloadMissingTx <- function(wd){
  
  # Setup variables
  setwd(wd)
  
  # Get list of files in directory
  list_files <- list.files(wd, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Missing_Blocks",old_file) == -1){
      next # If filename doesn't contain "Missing_Blocks" then go to next file
    }
    
    # Get blocks from missing_blocks file
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character")
    missing_blocks <- read_data$missing_blocks
    missing_blocks <- missing_blocks[missing_blocks!="None missing"]
    start_block <- paste("Missing_",min(missing_blocks)
                         ,sep = "") # Set up name so that it contains the word "Missing"
    end_block <- max(missing_blocks)
    output_file <- setupBlockFile(start_block, end_block)
    
    # Get block information
    len_missing <- length(missing_blocks)
    
    # Get new block information
    getInfo <- getBlockTx(missing_blocks[1])
    write.csv(getInfo, output_file, row.names = FALSE)
    
    if(len_missing<2){next}
    
    for(i in 2:len_missing){
      # Get new block information
      getInfo <- getBlockTx(missing_blocks[i])
      
      # Write outputs to file
      write.table(getInfo, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
    }
  }
  
  return("Missing blocks retrieved")
}



##### checkDuplicateTx #####
#
# Check for duplicate transactions
#
##########################
checkDuplicateTx <- function(tx_wd, block_wd){
  
  # Setup variables
  setwd(tx_wd)
  dupe_tx = 0
  output_file <- setupBlockFile(0, 0, type = "Duplicates")
  
  # Get list of files in directory
  list_files <- list.files(tx_wd, pattern = "*.csv", full.names = TRUE)
  
  # Get file name to check
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Tx_Info_",old_file) == -1){
      next # If filename doesn't contain "Consolidated" then go to next file
    }
    
    # Get block information from file name
    snip <- old_file
    snip_len <- nchar(snip)
    
    # Get file name
    pos_start <- 0
    pos_end <- regexpr("Info_", snip)
    snip <- substr(snip, pos_end, snip_len)
    old_file_name <- snip
    
    # Get startBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr("_", snip) - 1
    start_block = as.numeric(substr(snip, 0, pos_end))
    
    # Get endBlock    
    pos_start <- regexpr("_", snip) + 1
    snip <- substr(snip, pos_start, snip_len)
    pos_end <- regexpr("_", snip) - 1
    end_block = as.numeric(substr(snip, 0, pos_end))
    
    
    # Headers
    header <- c("Block_Number","Block_Tx","Tx_Count")
    
    # Import dataset to get blocks
    cleaned_block_file = paste(block_wd,"\\Cleaned_",start_block,"_",end_block,".csv",
                               sep="")
    read_data_block <- read.table(cleaned_block_file, header = TRUE, sep = ",", colClasses = "character")
    read_data_block <- read_data_block[,c("data.number","data.tx_count")]
    read_data_block$data.tx_count <- as.numeric(read_data_block$data.tx_count)
    read_data_block$col_3 = 0 # Add new column
    colnames(read_data_block) <- header

    # Import dataset to get Tx
    read_data_tx <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character",
                               na.strings = "NA")
    read_data_tx <- read_data_tx[(is.na(read_data_tx$data.txIndex)==TRUE),] # Keep only Tx
    read_data_tx <- count(read_data_tx,"data.block_id")
    read_data_tx$col_3 = 0 # Add new column
    read_data_tx <- read_data_tx[,c(1,3,2)] # Reorder in preparation of join
    colnames(read_data_tx) <- header

    # Join datasets and calculate differences
    joined_data = rbind(read_data_block,read_data_tx)
    agg_data <- aggregate(cbind(joined_data$Block_Tx,joined_data$Tx_Count) ~ joined_data$Block_Number
                                  ,data = joined_data
                                  ,FUN = sum)
    colnames(agg_data) <- header
    agg_data$Difference <- agg_data$Block_Tx-agg_data$Tx_Count
    
    # Filter to check for duplicates
    duplicate_blocks <- agg_data[agg_data$Difference<0,"Block_Number"]

    # Create output
    if(length(duplicate_blocks) == 0){
      none_duplicated <- as.data.frame(list("duplicate_blocks" = "None missing"))
      duplicate_blocks_df <- cbind(none_duplicated,old_file_name)
    }else{
      duplicate_blocks_df <- cbind(duplicate_blocks,old_file_name)
    }
    
    # Total number of duplicate blocks
    dupe_tx = dupe_tx + length(duplicate_blocks)
    
    # Write output to file
    if(!file.exists(output_file)){
      write.csv(duplicate_blocks_df, output_file, row.names = FALSE)
    } else {
      write.table(duplicate_blocks_df, output_file, sep = ",", col.names = F, append = T, row.names = FALSE)
    }
  }
  
  return(dupe_tx)
}