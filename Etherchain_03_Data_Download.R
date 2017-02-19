##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### #### Get the block information #### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getwd()
setwd(global_wd)


repeat{
  # Get the latest request
  cancel_request <- getRequestInfo(global_label_cancel)
  
  # Set request depending on if a cancelation was issued
  if(cancel_request=="Cancel"){
    request <- cancel_request
  }else{
    process_request <- getRequestInfo(global_label_read)
    request <- process_request
  }
  
  if(is.data.frame(request)){
    # Initialise variables if data.frame with request information is provided
    startBlock = request$startBlock
    loopsize = request$loopsize
    endBlock = request$endBlock
    mess_to = "d14127984@mydit.ie"
    mess_from = mess_to
    
    mess_subject <- createSubject(startBlock,endBlock)
    template <- createTemplate(mess_to, mess_from, mess_subject)
    state <- getBlockLoop(startBlock, endBlock, loopsize)
    
    if(!is.character(state)){
      # If returned block is same as endBlock, then send completion email
      if(state==endBlock){
        # Send completion mail if code completes
        message <- createMessage(endBlock, startBlock, endBlock, 1)
        mail_to_send <- createEmailFromTemplate(template, message)
        sendMessageWithLabel(mail_to_send)
      }else{
        # Send mail to indicate where system failed
        message <- createMessage(state - 1, startBlock, endBlock, 2)
        mail_to_send <- createEmailFromTemplate(template, message)
        sendMessageWithLabel(mail_to_send)
        Sys.sleep(10)
        
        # Send new request to restart from failure point
        request_subject <- createSubject(state,endBlock,"Request")
        request_message <- createMessage(loopsize,state,endBlock,3)
        request_mail_template <- createTemplate(mess_to,mess_from,request_subject)
        request_email <- createEmailFromTemplate(request_mail_template,request_message)
        sendMessageWithLabel(request_email)
        Sys.sleep(10)
      }
    }
  }else if(request == "Cancel"){
    # Break the loop if the request is to cancel
    break
  }else if(request == "No request"){
    # Make the system sleep if there is no request to cancel or process data
    Sys.sleep(30)
  }
}
