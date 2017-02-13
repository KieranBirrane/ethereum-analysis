##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### #####  Consolidate the block information  ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# getwd()
setwd(global_wd)



check_result <- consolidateBlockFiles(global_wd, clean = FALSE)
check_result

check_result2 <- consolidateBlockFiles(global_wd, clean = TRUE)
check_result2