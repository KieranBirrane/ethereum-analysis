##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### #### Get the block information #### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getwd()
setwd(global_wd)





##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### #### Get the block information #### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####
# Set time tracker CSV
# tt_filename = paste("Time_Tracker_Blocks_",x_startBlock,"_",x_endBlock,".csv",sep = "")
# time_track <- list("file"=as.character()
#                    ,"length.seconds"=as.numeric()
#                    ,"start.block"=as.numeric()
#                    ,"end.block"=as.numeric()
#                    ,"total_tx"=as.numeric())
# time_tracker <- data.frame(time_track)
# Write outputs to file
# write.csv(time_tracker, tt_filename, row.names = FALSE)



# Set starting variables
#repeat{
#  request <- getRequestInfo()
  
#  if(is.data.frame(request)){
    

    
    startBlock = 46140
    loopsize = 20
    endBlock = 47000
#    mess_to = "d14127984@mydit.ie"
#    mess_from = mess_to
    
#    mess_subject <- createSubject(startBlock,endBlock)
#    template <- createTemplate(mess_to, mess_from, mess_subject)
    state <- getBlockLoop(startBlock, endBlock, loopsize)

    if(!is.character(state)){
      if(state==endBlock){
        # Send different mail if code completes
        message <- createMessage(endBlock, startBlock, endBlock, 1)
        mail_to_send <- createEmailFromTemplate(template, message)
        sendMessageWithLabel(mail_to_send)
        # break
      }else{
        # Send mail to indicate where system failed
        message <- createMessage(state - 1, startBlock, endBlock, 2)
        mail_to_send <- createEmailFromTemplate(template, message)
        sendMessageWithLabel(mail_to_send)
        Sys.sleep(10)
        
        # Send new request
        request_subject <- createSubject(state,endBlock,"Request")
        request_message <- createMessage(loopsize,state,endBlock,3)
        request_mail_template <- createTemplate("d14127984@mydit.ie","d14127984@mydit.ie",request_subject)
        request_email <- createEmailFromTemplate(request_mail_template,request_message)
        sendMessageWithLabel(request_email)
        Sys.sleep(10)
      }
    }
  }else if(request == "Cancel"){
    break
  }else if(request == "No request"){
    Sys.sleep(30)
  }
  
}





##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### #### Get transactional information by block ### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

x_startBlock = 48513 + 1
x_loopsize = 1000
x_endBlock = 60000 - 1


# Set time tracker CSV
tt_tx_filename = paste("Time_Tracker_Tx_",x_startBlock,"_",x_endBlock,".csv",sep = "")
time_track_tx <- list("file"=as.character()
                   ,"length.seconds"=as.numeric()
                   ,"start.block"=as.numeric()
                   ,"end.block"=as.numeric()
                   ,"total_tx"=as.numeric())
time_tracker_tx <- data.frame(time_track_tx)

# Set starting variables
startBlock = x_startBlock
loopsize = x_loopsize
endBlock = x_endBlock
loop_num = ceiling((endBlock-startBlock)/loopsize)

for(j in 1:loop_num){
  test_block = min(startBlock + loopsize - 1,endBlock)
  
  # Set filename and remove previously existing files
  filename <- paste("Block_Tx_Info_",startBlock,"_",test_block,".csv" # as.Date(endtime),
                    ,sep = "")
  if(file.exists(filename)){file.remove(filename)}
  
  # Set start time and first block
  # starttime = Sys.time()
  # tx_count = 0
  getInfo <- getBlockTx(startBlock)
  
  # Write outputs to file
  write.csv(getInfo, filename, row.names = FALSE)

  # Loop through remaining blocks in loop
  for(i in (startBlock+1):test_block){
    Sys.sleep(0.3) # The API is currently limited to a maximum of 10 requests per 3 seconds and IP
    new_block <- getBlockTx(i)
    write.table(new_block, filename, sep = ",", col.names = F, append = T, row.names = FALSE)
    # getInfo <- rbind(getInfo,new_block)
  }
  
  # Set end time
  # endtime = Sys.time()
  
  # Add to time tracker
  # time_track_tx_temp <- data.frame(
  #   list("file"=as.character(filename)
  #        ,"length.seconds"=as.numeric(endtime - starttime)
  #        ,"start.block"=as.numeric(startBlock)
  #        ,"end.block"=as.numeric(test_block)
  #        ,"total_tx"=as.numeric(nrow(getInfo))
  #   )
  # )
  # time_tracker_tx <- rbind(time_tracker_tx,time_track_tx_temp)
  
  
  
  # Reset starting block
  startBlock = test_block + 1
}
# if(file.exists(tt_tx_filename)){file.remove(tt_tx_filename)}
# write.csv(time_tracker_tx,tt_tx_filename)

