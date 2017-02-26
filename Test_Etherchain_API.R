##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ### Etherchain ## ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####



##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ## Blocks # ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getBlockCount
test_getBlockCount <- getBlockCount()
test_getBlockCount



# getBlock
test_getBlock <- getBlock(417425)
test_getBlock

test_start_time <- Sys.time()
test_getBlock <- getBlock(0)
test_end_time <- Sys.time()
test_delta_time <- as.numeric(test_end_time - test_start_time, units = "secs")
test_delta_time



# getBlockTx
test_getBlockTx <- getBlockTx(3116718)
test_getBlockTx



# setEmptyBlockTx
test_setEmptyBlockTx <- setEmptyBlockTx()
test_setEmptyBlockTx






