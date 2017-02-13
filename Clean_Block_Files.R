setwd(global_wd)

global_read_wd <- "C:\\Users\\kieran.birrane\\Desktop\\MSc in Computing\\Dissertation\\Ethereum Data - Testing"

# Set wd
setwd(global_read_wd)

set_start_block = 0
set_end_block = 50000




# Get list of files in directory
list_files <- list.files(global_read_wd, pattern = "*.csv", full.names = TRUE)
# ?list.files
# Create cleaned file name
cleaned_filename <- setupBlockFile(set_start_block,set_end_block,cleaned = TRUE)

  
# Get old file name and create new file name
for(i in 1:length(list_files)){
  
  
  # Create new file name
  old_file <- list_files[i]
  file_path <- strsplit(old_file, "/")[[1]][1]
  file_name <- strsplit(old_file, "/")[[1]][2]
  file_move <- "\\Archived Data"
  new_file <- paste(file_path,file_move,"/",file_name
                    ,sep="")
  #     old_file      new_file
  
  # Open file and create new cleaned file
  read_data <- read.table(old_file, header = TRUE, sep = ",", colClasses = "character") # ?as.data.frame   ?read.csv
  # str(read_data[1,])
  headers_eth <- list("data.number"
                      ,"data.hash"
                      ,"data.tx_count"
                      ,"date.added"
                      ,"file.from")
  new_data <- cbind.data.frame(read_data$data.number
                               ,read_data$data.hash
                               ,read_data$data.tx_count
                               ,Sys.time()
                               ,file_name)
  colnames(new_data) <- headers_eth
  new_data <- new_data[new_data$data.tx_count != 0,] # filter out where txn is not zero

  if(i==1){
    col_names = T
    row_append = F
  } else {
    col_names = F
    row_append = T
  }
  write.table(new_data, cleaned_filename, sep = ",", col.names = col_names, append = row_append, row.names = FALSE)
  
  # Move file from old to new
  moveFile(old_file, new_file)
  # moveFile(new_file, old_file)
}