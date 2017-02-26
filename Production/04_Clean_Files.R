##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ## Prepare the block information ## ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# Set up variables
# getwd()
wd <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info"
wd_consol <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\Consolidated"
setwd(wd)
start_block = 250000*12
end_block = start_block + 200000

##### Consolidate block information #####
consolidateBlocks <- consolidateBlockFiles(wd, start_block, end_block, clean = FALSE)
consolidateBlocks

# Check for missing blocks
missing_blocks <- checkMissingBlocks(wd_consol)
missing_blocks

# If there are missing blocks, request the additional blocks
download_blocks <- downloadMissingBlocks(wd_consol)
download_blocks



# Check for duplicate blocks
duplicate_blocks <- checkDuplicateBlocks(wd_consol)
duplicate_blocks

# If there are duplicate blocks, remove the duplicates





##### Clean block information #####
cleanBlocks <- consolidateBlockFiles(wd_consol, start_block, end_block, clean = TRUE)
cleanBlocks
