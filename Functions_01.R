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
setupBlockFile <- function(startBlock,endBlock, type = c("Regular","Consolidated","Cleaned")){
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
setEmailToProcessed <- function(email){
  modify_message(email$id, add_labels = "Label_32", remove_labels = "Label_31")
}



##### getRequestInfo #####
#
# Get the latest email to read requests
#
##########################
getRequestInfo <- function(){
  msgs <- messages(label_ids = global_label_read) # Get all messages
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
    setEmailToProcessed(msgs_new)
    
    return(info.df)
  }else if(checker == "Cancel"){
    setEmailToProcessed(msgs_new)
    
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
  file.rename(from = from, to = to)
}



##### consolidateBlockFiles #####
#
# Get the latest email to read requests
#
#################################
consolidateBlockFiles <- function(wd, clean = FALSE){
  
  # Setup variables
  if(clean){
    consol_type = "Cleaned"
  } else {
    consol_type = "Consolidated"
  }
  consol_filename <- setupBlockFile(0, global_last_block, type = consol_type)
  createDirectory(consol_filename) # Create directory of output file if it doesn't exist
  row_count = 0
  tx_count = 0
  
  # Get list of files in directory
  list_files <- list.files(global_read_wd, pattern = "*.csv", full.names = TRUE)
  
  # Get old file name and create new file name
  for(i in 1:length(list_files)){
    
    # Check file name and move on if necessary
    old_file <- list_files[i]
    if(regexpr("Block_Info",old_file) == -1){
      next # If filename doesn't contain "Block_Info" then go to next file
    }
    
    # Set file path and name
    file_path <- strsplit(old_file, "/")[[1]][1]
    file_name <- strsplit(old_file, "/")[[1]][2]
    file_move <- ""# "\\Archived Data"
    
    # Set new file name
    new_file <- paste(file_path,file_move,"/",file_name
                      ,sep="")
    
    
    
    # Open file and create new consolidated file
    read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character") # str(read_data[1,])
    headers_eth <- list("data.number"
                        ,"data.hash"
                        ,"data.tx_count"
                        ,"date.added"
                        ,"file.from")
    new_data <- cbind.data.frame(read_data[[headers_eth[[1]][1]]]
                                 ,read_data[[headers_eth[[2]][1]]]
                                 ,read_data[[headers_eth[[3]][1]]]
                                 ,Sys.time()
                                 ,file_name)
    colnames(new_data) <- headers_eth
    
    # Count number of rows
    row_count = row_count + nrow(read_data)
    tx_count = tx_count + sum(as.numeric(read_data$data.tx_count))
    
    # Filter out transactions != 0
    if(clean){
      new_data <- new_data[new_data$data.tx_count != 0,] # filter out where txn is not zero
    }
    
    
    
    # Set output file name
    if(i == 1){
      set_start_block = min(read_data$data.number)
    } else if (i == length(list_files)){
      set_end_block = max(read_data$data.number)
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
    
    # Move read file to archive folder
    moveFile(old_file, new_file)
  }
  
  # Create new file name
  consol_filename_new <- setupBlockFile(set_start_block, set_end_block, type = consol_type)
  moveFile(consol_filename,consol_filename_new)
  
  # Open new cleaned file and check the row count
  read_data_consol <- read.table(consol_filename_new, header = TRUE, sep = ",", colClasses = "character")
  
  # Return information
  if(clean){
    count_data <- tx_count
    count_file <- sum(as.numeric(read_data_consol$data.tx_count))
    count_blocks <- nrow(read_data_consol)
    true_false <- count_data == count_file
    info.df <- as.data.frame(list("TRUE_FALSE" = true_false
                                  ,"Input_Tx" = count_data
                                  ,"Output_Tx" = count_file
                                  ,"Output_Blocks" = count_blocks))
  } else {
    count_data <- row_count
    count_file <- nrow(read_data_consol)
    true_false <- count_data == count_file
    info.df <- as.data.frame(list("TRUE_FALSE" = true_false
                                  ,"Input_Blocks" = count_data
                                  ,"Output_Blocks" = count_file))
  }
  
  return(info.df)
}