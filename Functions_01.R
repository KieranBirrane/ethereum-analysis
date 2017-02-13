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
setupBlockFile <- function(startBlock,endBlock){
  filename <- paste("Block_Info_",startBlock,"_",endBlock,".csv"
                    ,sep = "")
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
    
    if(start_block==end_block){
      return("Cancel") # Cancel the process if start and end block are the same
    }else{
      return(info.df)
    }
  }else if(checker == "Status"){
    setEmailToProcessed(msgs_new)
    
    return(checker)
  }else if(checker == "Error"){
    setEmailToProcessed(msgs_new)
    
    return(checker)
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
getBlockLoop <- function(startBlock,endBlock,loopsize,email_template){
  # Set up loop number
  iteration = startBlock
  loop_num = ceiling((endBlock-startBlock)/loopsize)

  # Send one mail if code fails to start
  #mail_to_send <- createEmailFromTemplate(email_template, "Code failed to start")
  
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
          
          # Create email message if code fails during loop
          #message <- createMessage(iteration - 1, startBlock, endblock_loop, 2)
          #mail_to_send <- createEmailFromTemplate(email_template, message)
          
          # Create new request email
          #request_subject <- createSubject(iteration,endBlock,"Request")
          #request_message <- createMessage(loopsize,iteration,endBlock,3)
          #request_mail_template <- createTemplate("d14127984@mydit.ie","d14127984@mydit.ie",request_subject)
          #request_email <- createEmailFromTemplate(request_mail_template,request_message)
          
          # Get latest request
          #request <- getRequestInfo()
          #if(request == "Status"){
          #  status_message <- createMessage(iteration - 1,startBlock,endblock_loop)
          #  status_mail_to_send <- createEmailFromTemplate(email_template, status_message)
          #  sendMessageWithLabel(status_mail_to_send)
          #} 
          #else if(request == "Error"){
          #  stop("Test error")
          #}
          #else if(request == "Cancel"){
          #  stop("Cancel the process")
          #}

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
      # error_message <- data.frame(list("Date" = Sys.time()
      #                                  ,"Message"=print(e)))
      # write.table(error_message, "Error_log.csv", sep = ",", col.names = F, append = T, row.names = FALSE)
    }
    , finally = {
      #sendMessageWithLabel(mail_to_send)
      return(iteration)
    }
  )
  
  return("Run Completed")
}
