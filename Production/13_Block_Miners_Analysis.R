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
# Get values of numbers of blocks mined
#####
sql = "
SELECT bm.[Number_Blocks]
,100*(bm.[Number_Blocks]/3100154.0) AS [Percentage_Mined]
FROM ETH002_BLK_ANALYSIS.analysis.Block_Miners bm
"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

# Prepare data
number_mined <- data.frame(Number_Blocks=as.numeric(res$Number_Blocks)
                              ,Percentage_Mined=as.numeric(res$Percentage_Mined))
number_mined$Log_Number_Blocks <- log(number_mined$Number_Blocks)

# Get summary of data
# Min.    1st Qu.   Median    Mean    3rd Qu.   Max. 
# 1.0     1.0       5.0       865.2   27.0      709000.0
summ <- summary(number_mined$Number_Blocks)
max = max(number_mined$Number_Blocks)
bin = 100

### Prepare histogram
g <- ggplot(data=number_mined, aes(x = Number_Blocks)) +
  xlim(0,3500) + 
  ylim(0,350) +
  geom_histogram(binwidth = bin
                 ,colour=black
                 ,fill=blue) +
  labs(title="Histogram of number of blocks mined"
       ,x="Number of Blocks"
       ,y="Count"
  ) +
  annotate(geom="segment", y=-10, yend =0,
           x=seq(0,3500,100), xend=seq(0,3500,100))
g
# Excluded: 47 items (bigger than 3,500)

# Save to file
saveToPDF(g,"01.01_Miner_Histogram.pdf")





#####
# Get data from top 100 miners
#####
sql = "
SELECT TOP 100 *
,100*(bm.[Number_Blocks]/3100154.0) AS [Percentage_Mined]
FROM ETH002_BLK_ANALYSIS.analysis.Block_Miners bm
ORDER BY bm.[Number_Blocks] DESC
"
res <- sqlQuery(conn, sql,errors = T,as.is = T)
miners100 <- res

miners100$Number_Blocks <- as.numeric(miners100$Number_Blocks)
miners100$First_Block <- as.numeric(miners100$First_Block)
miners100$Last_Block <- as.numeric(miners100$Last_Block)
miners100$Total_Reward <- as.numeric(miners100$Total_Reward)
miners100$Percentage_Mined <- as.numeric(miners100$Percentage_Mined)

### Prepare LaTeX table
sum = 0
i = 1
table = ""
percent_data <- miners100[order(-miners100[,"Percentage_Mined"]),]
while(sum < 90 && i < 11){
  sum <- sum + miners100$Percentage_Mined[i]
  newline <- paste("\t\t\\textbf{",miners100$Data_Coinbase[i],"} & "
                   ,miners100$Data_Name[i]," & "
                   ,formatC(miners100$Number_Blocks[i], format="d", big.mark=",")," & "
                   ,round(miners100$Percentage_Mined[i],2),"\\% & "
                   ,round(sum,2),"\\% \\\\"
                   ,sep="")
  table <- paste(table,newline,sep="\n")
  i <- i+1
}

# Save to file
write(table,"miners100_LaTeX.txt")





#####
# Check if multiple addresses have the same name
#####
sql = "
SELECT
bm.[Data_Name]
,COUNT(bm.[Data_Name])      AS [Count]
,SUM(bm.[Number_Blocks])    AS [Total_Blocks]
,100*(SUM(bm.[Number_Blocks])/3100154.0)   AS [Percentage_Mined]
FROM ETH002_BLK_ANALYSIS.analysis.Block_Miners bm
WHERE bm.[Data_Name] <> 'NA'
GROUP BY bm.[Data_Name]
ORDER BY COUNT(bm.[Data_Name]) DESC
"
res <- sqlQuery(conn, sql,errors = T,as.is = T)
minersName <- res

minersName$Count <- as.numeric(minersName$Number_Blocks)
minersName$Total_Blocks <- as.numeric(minersName$First_Block)
minersName$Percentage_Mined <- as.numeric(minersName$Percentage_Mined)

### Prepare LaTeX table
sum = 0
i = 1
table = ""
percent_data <- minersName[order(-minersName[,"Percentage_Mined"]),]
while(sum < 90 && i < 11){
  sum <- sum + minersName$Percentage_Mined[i]
  newline <- paste("\t\t\\textbf{",minersName$Data_Name[i],"} & "
                   ,minersName$Count[i]," & "
                   ,formatC(minersName$Total_Blocks[i], format="d", big.mark=",")," & "
                   ,round(minersName$Percentage_Mined[i],2),"\\% & "
                   ,round(sum,2),"\\% \\\\"
                   ,sep="")
  table <- paste(table,newline,sep="\n")
  i <- i+1
}

# Save to file
write(table,"minersName_LaTeX.txt")