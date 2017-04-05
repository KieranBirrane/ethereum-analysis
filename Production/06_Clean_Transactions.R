##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### Prepare the transaction information ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### #####

# Set up variables
# getwd()
wd_cleaned_blocks <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\02_Cleaned"
wd_downloaded <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\02_Cleaned\\Tx"
wd_renamed_tx <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\02_Cleaned\\Tx\\Tx"
wd_cleaned_tx <- "C:\\Users\\temp.user\\Desktop\\Dissertation\\Ethereum_Data\\Block_Info\\02_Cleaned\\Tx\\Tx\\Tx"
setwd(wd_cleaned_blocks)
start_block = 250000*12
end_block = start_block + 200000 #250000 - 1

##### Consolidate transaction information #####
# Rename Tx_Info files to ensure names are correct
renameTx <- renameTxInfo(wd_downloaded)
renameTx

# Combine Tx_Info files in batches of 250,000
combineTxresult <- combineTx(wd_renamed_tx,start_block,end_block)
combineTxresult

# Check for missing blocks
missing_tx <- checkMissingTx(wd_cleaned_tx, wd_cleaned_blocks)
missing_tx

# If there are missing blocks, request the additional blocks
download_missing_tx <- downloadMissingTx(wd_cleaned_tx)
download_missing_tx

# Check for duplicate transactions
duplicate_tx <- checkDuplicateTx(wd_cleaned_tx, wd_cleaned_blocks)
duplicate_tx

# If there are duplicate blocks, remove the duplicates

# Error in block 2082050
block2082050 <- getBlock(2082050)
blockTx2082050 <- getBlockTx(2082050)
