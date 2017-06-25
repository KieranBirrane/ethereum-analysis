##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### #####  Ethereum Miners  ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

##### Questions
# What is the profile of miners? How many exist compared to overall users?
# What addresses look to belong to more than one entity?
# What is the distribution of mining?
# What is the range of blocks that miners have mined?
# How has mining evolved over the months? What about before and after the homestead block?



#####
# Get total count of miners - 3583
#####
sql = "
SELECT COUNT(*)
FROM ETH002_BLK_ANALYSIS.analysis.Block_Miners bm
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
all_miners <- res
all_miners # 3,583

sql = "
SELECT COUNT(*)
FROM ETH002_BLK_ANALYSIS.analysis.User_Details ud
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
all_users <- res
all_users # 933,183





#####
# Get data from miners
#####
sql = "
SELECT *
,100.0*bm.[Number_Blocks]/(1.0*bm.[Last_Block]-1.0*bm.[First_Block]+1.0) AS [Power]
,100.0*bm.[Number_Blocks]/(3100154.0-1.0*bm.[First_Block]+1.0) AS [Activity]
,100.0*bm.[Number_Blocks]/(3100154.0) AS [Presence]
FROM ETH002_BLK_ANALYSIS.analysis.Block_Miners bm
ORDER BY bm.[Number_Blocks] DESC
"
res <- sqlQuery(conn, sql,errors = T,as.is = T)
miners <- res

miners$Number_Blocks <- as.numeric(miners$Number_Blocks)
miners$First_Block <- as.numeric(miners$First_Block)
miners$Last_Block <- as.numeric(miners$Last_Block)
miners$Total_Reward <- as.numeric(miners$Total_Reward)
miners$Power <- as.numeric(miners$Power)
miners$Activity <- as.numeric(miners$Activity)
miners$Presence <- as.numeric(miners$Presence)

# Get summary of data
# Min.    1st Qu.   Median    Mean    3rd Qu.   Max. 
# 1.0     1.0       5.0       865.2   27.0      709000.0
summ <- summary(miners$Number_Blocks)
max = max(miners$Number_Blocks)
bin = 100

#####
### Prepare histogram
#####
g <- ggplot(data=miners[miners$Number_Blocks<4000,], aes(x = Number_Blocks)) +
  xlim(0,3500) +
  ylim(-5,350) +
  geom_histogram(binwidth = bin
                 ,colour = black
                 ,fill = blue) +
  labs(title="Histogram of number of blocks mined"
       ,x="Number of Blocks"
       ,y="Count"
  ) +
  annotate(geom="segment", y=-5, yend=0,
           x=seq(0,3500,100), xend=seq(0,3500,100))
g
# Excluded: 47 items (bigger than 3,500)

# Save to file
saveToPDF(g,"01.01_Miner_Histogram.pdf")



#####
### Prepare LaTeX table for Presence
#####
sum = 0
i = 1
table = ""
presence_data <- miners[order(-miners[,"Presence"]),]
for(i in 1:50){
  sum <- sum + presence_data$Presence[i]
  newline <- paste("\t\t\\textbf{",presence_data$Data_Coinbase[i],"} & "
                   ,presence_data$Data_Name[i]," & "
                   ,formatC(presence_data$Number_Blocks[i], format="d", big.mark=",")," & "
                   ,presence_data$Last_Block[i]-presence_data$First_Block[i]
                   ,round(presence_data$Presence[i],2),"\\% & "
                   ,round(sum,2),"\\% \\\\"
                   ,sep="")
  table <- paste(table,newline,sep="\n")
}

# Save to file
write(table,"01.02_minersPresence_LaTeX.txt")
# Top 50 => 92.6% of all blocks
# Number 50 => 3,157 blocks (0.1% of total)



#####
### Prepare histogram
#####
g <- ggplot(data=presence_data[1:50,], aes(x = reorder(Data_Name,-Presence), y = Presence)) +
  geom_col(colour=black
                 ,fill=blue) +
  labs(title="Percentage of blocks mined by user"
       ,x="User name"
       ,y="Percentage"
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1,vjust = 0.5))
g
# Display bar char of top 50 miners
# Total percentage covered = 92.6%

# Save to file
saveToPDF(g,"01.03_Top_50_Miner_Histogram.pdf")



#####
# Aggregate miners by address, ignoring NAs and repeat graphs
#####
sql = "
SELECT bm.[Data_Name]
,COUNT(bm.[Data_Name])      AS [Count]
,SUM(bm.[Number_Blocks])    AS [Total_Blocks]
,100.0*SUM(bm.[Number_Blocks])/3100154.0 AS [Presence]
FROM ETH002_BLK_ANALYSIS.analysis.Block_Miners bm
WHERE bm.[Data_Name] <> 'NA'
GROUP BY bm.[Data_Name]
ORDER BY SUM(bm.[Number_Blocks]) DESC
"
res <- sqlQuery(conn, sql,errors = T,as.is = T)
minersName <- res

minersName$Count <- as.numeric(minersName$Count)
minersName$Total_Blocks <- as.numeric(minersName$Total_Blocks)
minersName$Presence <- as.numeric(minersName$Presence)

#####
### Prepare LaTeX table for Presence
#####
num_i <- nrow(minersName)
sum = 0
i = 1
table = ""
presenceAgg_data <- minersName[order(-minersName[,"Presence"]),]
for(i in 1:num_i){
  sum <- sum + presenceAgg_data$Presence[i]
  newline <- paste("\t\t\\textbf{",presenceAgg_data$Data_Name[i],"} & "
                   ,formatC(presenceAgg_data$Total_Blocks[i], format="d", big.mark=",")," & "
                   ,round(presenceAgg_data$Presence[i],2),"\\% & "
                   ,round(sum,2),"\\% \\\\"
                   ,sep="")
  table <- paste(table,newline,sep="\n")
}

# Save to file
write(table,"01.04_minersAggPresence_LaTeX.txt")



#####
### Prepare bar chart
#####
g <- ggplot(data=presenceAgg_data[1:25,], aes(x = reorder(Data_Name,-Presence), y = Presence)) +
  geom_col(colour=black
           ,fill=blue) +
  labs(title="Percentage of blocks mined by user (aggregated)"
       ,x="User name"
       ,y="Percentage"
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1,vjust = 0.5)) +
  ylim(0,max(presenceAgg_data$Presence)+2.5) +
  geom_text(aes(label = paste(round(Total_Blocks/1000,0),"k",sep=""))
            , hjust = 0
            , angle = 90
            , colour = orange
            , nudge_y = 0.5)
g
# Display bar char of top 25 miners
# Total percentage covered = 83.17%

# Save to file
saveToPDF(g,"01.05_Top_25_Agg_Miner_Histogram.pdf")



#####
### Prepare histogram for each of the top miners
#####
bin = 100000
for(i in 1:25){

  miner_name <- presenceAgg_data$Data_Name[i]
  mined_blks_miner <- retrieveAddressNameBlocks(miner_name)
  mined_blks_miner$Data_Name <- miner_name
  num_name <- paste("0",i,sep="")
  mined_blks_miner$Order <- substr(num_name, nchar(num_name)-1, nchar(num_name))
  mean_blk <- formatC(round(mean(mined_blks_miner$Data_Number),0), format="d", big.mark=",")
  median_blk <- formatC(round(median(mined_blks_miner$Data_Number),0), format="d", big.mark=",")
  
  if(i==1){
    full_data = mined_blks_miner
  }else{
    full_data = rbind(full_data,mined_blks_miner)
  }

  g <- ggplot(data=mined_blks_miner, aes(x = Data_Number)) +
    geom_histogram(binwidth = bin
                   ,colour = black
                   ,fill = blue) +
    labs(title=paste(miner_name,": Histogram of mined blocks",sep="")
         ,x="Block number"
         ,y="Number of blocks mined"
    ) +
    annotate("text", x = 2250000, y = 40000,
             label = paste("mean"," = ",mean_blk), parse = FALSE
             ,hjust = 0
             ,color=red
             ,size=5) +
    annotate("text", x= 2250000, y = 37500,
             label = paste("median"," = ",median_blk), parse = FALSE
             ,hjust = 0
             ,color=orange
             ,size=5)

  # Save to file
  if(i<5){
    num = paste("0",5+i,sep="")
  }else{
    num = paste("",5+i,sep="")
  }
  saveToPDF(g,paste("01.",num,"_",presenceAgg_data$Data_Name[i],"_Miner_Histogram.pdf",sep=""))
}



#####
### Check the distribution of number of transactions
#####
sql = "
SELECT eb.[Data_Number],eb.[Data_Tx_Count]
FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
WHERE 1=1
AND eb.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
tx_counts <- res
tx_counts # 3,100,154

tx_counts$Data_Tx_Count <- as.numeric(tx_counts$Data_Tx_Count)

# Get summary of data
# Min.    1st Qu.   Median    Mean    3rd Qu.   Max. 
# 0.000   0.000     1.000     5.199   5.000     228.000 
summ <- summary(tx_counts$Data_Tx_Count)
max = max(tx_counts$Data_Tx_Count)
bin = 10

count_tx <- nrow(tx_counts[tx_counts$Data_Tx_Count==0,"Data_Tx_Count"]) # 1,176,748         100*1176748/3100154
count_tx <- nrow(tx_counts[tx_counts$Data_Tx_Count<10,"Data_Tx_Count"]) # 2,686,222         100*2686222/3100154
sum(count_tx$freq)                                                        # 2686222-1176748   100*1509474/3100154

max_block <- tx_counts[tx_counts$Data_Tx_Count==max,"Data_Number"]

### Prepare histogram
g <- ggplot(data=tx_counts, aes(x = Data_Tx_Count)) +
  geom_histogram(binwidth = bin
                 ,colour = black
                 ,fill = blue) +
  labs(title="Histogram of number of transactions per block"
       ,x="Number of Transactions"
       ,y="Count"
  ) +
  scale_y_continuous(breaks=seq(0, 2500000, 500000)
                     ,labels = cbind("0","0.5 mil","1.0 mil","1.5 mil","2.0 mil","2.5 mil"))
g

# Save to file
saveToPDF(g,"01.31_Transaction_Count.pdf")



#####
### Check the distribution of block rewards
#####
sql = "
SELECT eb.[Data_Number],eb.[Data_Reward]
FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
WHERE 1=1
AND eb.[Data_Time] < '2017-02-01'
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
block_rewards <- res
block_rewards # 3,100,154

block_rewards$Data_Reward <- as.numeric(block_rewards$Data_Reward)
wei <- (10^18)

# Get summary of data
# Min.    1st Qu.   Median    Mean    3rd Qu.   Max. 
# 5.000   5.000     5.001     5.019   5.007     766.600 
summ <- summary(block_rewards$Data_Reward/wei)
min = min(block_rewards$Data_Reward)/wei
max = max(block_rewards$Data_Reward)/wei
bin = .1

count_re <- nrow(block_rewards[block_rewards$Data_Reward/wei==5,])  # 1,089,321         100*1089321/3100154
count_re <- nrow(block_rewards[block_rewards$Data_Reward/wei<6,])   # 3,100,045         100*3100045/3100154
sum(count_tx$freq)                                                  # 3100045-1089321   100*2010724/3100154

rem_blocks <- block_rewards[block_rewards$Data_Reward/wei>=6,]      # 109
nrow(rem_blocks)
summ_rem <- summary(rem_blocks$Data_Reward/wei)                     # IQR = 7.374-6.259
max_block <- block_rewards[block_rewards$Data_Reward/wei==max,"Data_Number"]