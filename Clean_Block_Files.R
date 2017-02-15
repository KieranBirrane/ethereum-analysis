##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### #####  Consolidate the block information  ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getwd()
setwd(wd)
wd <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info"
wd_clean <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\Consolidated"
start_block = 0
end_block = start_block + 1000 - 1

check_result <- consolidateBlockFiles(wd, start_block, end_block, clean = FALSE)
check_result

check_result2 <- consolidateBlockFiles(wd_clean, start_block, end_block, clean = TRUE)
check_result2



#########################################################################

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
#########################################################################

?as.factor
lists <- c(20:30)
list_filter <- factor(lists)
str(list_filter)
str(xxx$data.number)

xxx[as.factor(xxx$data.number) %in% list_filter,]

xxx <- new_data

str(xxx$data.number)
row.names(xxx) <- xxx$data.number
xxx[as.numeric(xxx$data.number) >= as.numeric(start_block),]
cbind(new_data)[order(as.numeric(levels(new_data$data.number))),]
?order
# Filter blocks to be within the specified input blocks
mode(new_data$data.number)
xxx$data.number <- as.numeric(new_data$data.number)
new_data <- new_data[order(as.numeric(levels(new_data$data.number))),]
20 >= 20
new_data[which(as.numeric(levels(new_data$data.number)) >= as.numeric(start_block)),]
subset(new_data, as.numeric(new_data$data.number) >= as.numeric(start_block))

mode(new_data$data.number)
cbind(as.numeric(levels(new_data$data.number)) >= as.numeric(start_block)
      ,new_data)


x <- getBlock(104278)
write.csv(x, file = "104278.csv")

wdmmm <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\Consolidated\\Consolidated_0_249999.csv"

xxxtest <- read.table(wdmmm, header = TRUE, sep = ",", colClasses = "character")
nrow(xxxtest)
checker <- c(start_block:end_block)
checker <- as.data.frame(checker)
checker[!(checker$checker %in% xxxtest$data.number),]
xxxtest[]
cbind()





#############################################################################

count_data <- 123
count_file <- 234
true_false <- TRUE


checker <- as.data.frame(c(start_block:end_block))
missing_blocks <- checker[!(checker$checker %in% read_data_consol$data.number),]
colnames(missing_blocks) <- "Missing_Blocks"



missing_blocks <- as.data.frame(c(0:4))
colnames(missing_blocks) <- "missing"
info.df <- as.data.frame(list("TRUE_FALSE" = true_false
                              ,"Actual" = count_file
                              ,"Expected" = 000
                              ,"Input_Blocks" = count_data
                              ,"Output_Blocks" = count_file
                              ,"Missing_Blocks" = missing_blocks))



