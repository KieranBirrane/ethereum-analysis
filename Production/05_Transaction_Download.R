##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### # Get the transaction information # ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# resetDownloadedBlocks(global_wd_cleaned_blocks)

# getwd()
setwd(global_wd_cleaned_blocks)
state = 250000*11
start_point = state
loop_size = 50000



repeat{
  # Start download of Tx
  if(!is.character(state)){
    state <- getTxLoop(global_wd_cleaned_blocks, start_point, loop_size)
    if(state=="Run Completed"){start_point=start_point+loop_size}
    start_point <- state # Set the next iteration point
  }

  # Get the latest request
  cancel_request <- getRequestInfo(global_label_cancel)
  
  # Break the loop if the request is to cancel or if run completes
  if(cancel_request=="Cancel" || state == "Run Completed"){
    break
  }

}