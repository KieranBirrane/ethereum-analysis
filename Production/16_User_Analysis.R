##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### # user Analysis # ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

#####
# Retrieve the user data and prepare for clustering
#####
sql = "
SELECT *
FROM ETH002_BLK_ANALYSIS.analysis.User_Details ud
"

res <- sqlQuery(conn, sql,errors = T,as.is = T)
all_users <- res
nrow(all_users) # 933,183

# Set column data types
all_users$Total_Count <- as.integer(all_users$Total_Count)
all_users$In_Degree <- as.numeric(all_users$In_Degree)
all_users$Out_Degree <- as.numeric(all_users$Out_Degree)
all_users$Mean_In_Value <- as.numeric(all_users$Mean_In_Value)
all_users$Mean_Out_Value <- as.numeric(all_users$Mean_Out_Value)
all_users$Std_Dev_In_Value <- as.numeric(all_users$Std_Dev_In_Value)
all_users$Std_Dev_Out_Value <- as.numeric(all_users$Std_Dev_Out_Value)
all_users$In_Degree_Contract <- as.numeric(all_users$In_Degree_Contract)
all_users$Out_Degree_Contract <- as.numeric(all_users$Out_Degree_Contract)
all_users$Mean_In_Value_Contract <- as.numeric(all_users$Mean_In_Value_Contract)
all_users$Mean_Out_Value_Contract <- as.numeric(all_users$Mean_Out_Value_Contract)
all_users$Std_Dev_In_Value_Contract <- as.numeric(all_users$Std_Dev_In_Value_Contract)
all_users$Std_Dev_Out_Value_Contract <- as.numeric(all_users$Std_Dev_Out_Value_Contract)



#####
# Get summary statistics of the user variables (IsContract)
#####
num_smart <- nrow(all_users[all_users$IsContract=='Y',])  # 179,133
round(100*179133/933183,2)
num_reg <- nrow(all_users[all_users$IsContract=='N',])    # 754,050
round(100*754050/933183,2)

cor(all_users$Total_Count,all_users$In_Degree,method = "spearman")
cor(all_users$Total_Count,all_users$Out_Degree,method = "spearman")
cor(all_users$Total_Count,all_users$In_Degree_Contract,method = "spearman")
cor(all_users$Total_Count,all_users$Out_Degree_Contract,method = "spearman")

cor(all_users$In_Degree,all_users$Out_Degree,method = "spearman")
cor(all_users$In_Degree,all_users$In_Degree_Contract,method = "spearman")
cor(all_users$In_Degree,all_users$Out_Degree_Contract,method = "spearman")

cor(all_users$Out_Degree,all_users$In_Degree_Contract,method = "spearman")
cor(all_users$Out_Degree,all_users$Out_Degree_Contract,method = "spearman")

cor(all_users$In_Degree_Contract,all_users$Out_Degree_Contract,method = "spearman")


#####
# Get a hisogram of number of user transactions
#####
bin = 10
min_tx <- min(all_users$Total_Count)
max_tx <- max(all_users$Total_Count)
limit <- ceiling(max_tx/bin)
for(i in 1:limit){
  dta <- all_users[all_users$Total_Count>=(i-1)*bin,]
  dta <- dta[dta$Total_Count<i*bin,]
  rows <- nrow(dta)

  datafr <- data.frame(Range10=paste((i-1)*bin,"-",i*bin-1,sep="")
                       ,Range100=paste(ceiling((i*bin-1)/100-1)*100,"-",ceiling((i*bin-1)/100)*100-1,sep="")
                       ,Range1000=paste(ceiling((i*bin-1)/1000-1)*1000,"-",ceiling((i*bin-1)/1000)*1000-1,sep="")
                       ,Number_Users=rows)
  
  if(i==1){
    write.table(datafr,"03.01_User_Transactions.txt",sep = ",", col.names = T, append = F, row.names = FALSE)
  }else{
    write.table(datafr,"03.01_User_Transactions.txt",sep = ",", col.names = F, append = T, row.names = FALSE)
  }
}

# Write output to table
write.table(result_df,"03.01_User_Transactions.txt",sep = ",", col.names = T, append = F, row.names = FALSE)

min_tx <- min(all_users$Total_Count)
max_tx <- max(all_users$Total_Count)
#  Total           933183
#
#  Subtotal        933008
#      0-999       930775
#  1000-1999         1466
#  2000-2999          416
#  3000-3999          146
#  4000-4999           82
#  5000-5999           44
#  6000-6999           28
#  7000-7999           21
#  8000-8999           17
#  9000-9999           13



# Produce histogram of log10(Total_Count)
g <- ggplot(data=all_users, aes(x = log10(Total_Count))) +
  geom_histogram(binwidth = bin/100
                 ,colour = black
                 ,fill = blue) +
  labs(title="Histogram of number of transactions per user (log10 scale)"
       ,x="Number of transactions"
       ,y="Number of users"
  ) + scale_x_continuous(breaks=seq(0, 4, 1)
                         ,labels = cbind("0","10","100","1,000","10,000")
                         ,limits=c(-0.1,4) )
# Excluded: 175 items (bigger than 10,000)

# Save to file
saveToPDF(g,"03.01_User_Transactions.pdf")



# Produce histogram of log10(Total_Count) by type of user
g <- ggplot(data=all_users, aes(x = log10(Total_Count), fill=IsContract)) +
  geom_histogram(binwidth = bin/100) +
  labs(title="Histogram of number of transactions per user (log10 scale)"
       ,x="Number of transactions"
       ,y="Number of users"
  ) + scale_x_continuous(breaks=seq(0, 4, 1)
                         ,labels = cbind("0","10","100","1,000","10,000")
                         ,limits=c(-0.1,4)) +
  scale_fill_manual("SmartContract", values = c(blue, red))
# Excluded: 175 items (bigger than 10,000)

# Save to file
saveToPDF(g,"03.02_User_Transactions_IsContract.pdf")





# Produce summary statistics of each variable
summary_data <- summaryToLatex(all_users$Total_Count,"Total_Count")
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Total_Count[all_users$IsContract=='N']
                                      ,"Total_Count - Users"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Total_Count[all_users$IsContract=='Y']
                                      ,"Total_Count - SmartContract"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$In_Degree
                                      ,"In_Degree"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$In_Degree[all_users$IsContract=='Y']
                                      ,"In_Degree - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$In_Degree[all_users$IsContract=='N']
                                      ,"In_Degree - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Out_Degree
                                      ,"Out_Degree"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Out_Degree[all_users$IsContract=='Y']
                                      ,"Out_Degree - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Out_Degree[all_users$IsContract=='N']
                                      ,"Out_Degree - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_In_Value
                                      ,"Mean_In_Value"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_In_Value[all_users$IsContract=='Y']
                                      ,"Mean_In_Value - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_In_Value[all_users$IsContract=='N']
                                      ,"Mean_In_Value - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_Out_Value
                                      ,"Mean_Out_Value"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_Out_Value[all_users$IsContract=='Y']
                                      ,"Mean_Out_Value - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_Out_Value[all_users$IsContract=='N']
                                      ,"Mean_Out_Value - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_In_Value
                                      ,"Std_Dev_In_Value"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_In_Value[all_users$IsContract=='Y']
                                      ,"Std_Dev_In_Value - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_In_Value[all_users$IsContract=='N']
                                      ,"Std_Dev_In_Value - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_Out_Value
                                      ,"Std_Dev_Out_Value"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_Out_Value[all_users$IsContract=='Y']
                                      ,"Std_Dev_Out_Value - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_Out_Value[all_users$IsContract=='N']
                                      ,"Std_Dev_Out_Value - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$In_Degree_Contract
                                      ,"In_Degree_Contract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$In_Degree_Contract[all_users$IsContract=='Y']
                                      ,"In_Degree_Contract - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$In_Degree_Contract[all_users$IsContract=='N']
                                      ,"In_Degree_Contract - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Out_Degree_Contract
                                      ,"Out_Degree_Contract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Out_Degree_Contract[all_users$IsContract=='Y']
                                      ,"Out_Degree_Contract - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Out_Degree_Contract[all_users$IsContract=='N']
                                      ,"Out_Degree_Contract - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_In_Value_Contract
                                      ,"Mean_In_Value_Contract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_In_Value_Contract[all_users$IsContract=='Y']
                                      ,"Mean_In_Value_Contract - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_In_Value_Contract[all_users$IsContract=='N']
                                      ,"Mean_In_Value_Contract - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_Out_Value_Contract
                                      ,"Mean_Out_Value_Contract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_Out_Value_Contract[all_users$IsContract=='Y']
                                      ,"Mean_Out_Value_Contract - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Mean_Out_Value_Contract[all_users$IsContract=='N']
                                      ,"Mean_Out_Value_Contract - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_In_Value_Contract
                                      ,"Std_Dev_In_Value_Contract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_In_Value_Contract[all_users$IsContract=='Y']
                                      ,"Std_Dev_In_Value_Contract - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_In_Value_Contract[all_users$IsContract=='N']
                                      ,"Std_Dev_In_Value_Contract - Users"))

summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_Out_Value_Contract
                                      ,"Std_Dev_Out_Value_Contract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_Out_Value_Contract[all_users$IsContract=='Y']
                                      ,"Std_Dev_Out_Value_Contract - SmartContract"))
summary_data <- rbind(summary_data
                      ,summaryToLatex(all_users$Std_Dev_Out_Value_Contract[all_users$IsContract=='N']
                                      ,"Std_Dev_Out_Value_Contract - Users"))

# Print LaTeX to screen
cat(as.character(summary_data$LaTeX))



# Get mean and standard deviation of each attribute - so values can be retrieved after clustering
all_users_summ <- data.frame(Summary="Data statistics")
all_users_summ$Total_Count_Mean <- mean(all_users$Total_Count)
all_users_summ$Total_Count_StdDev <- sd(all_users$Total_Count)
all_users_summ$In_Degree_Mean <- mean(all_users$In_Degree)
all_users_summ$In_Degree_StdDev <- sd(all_users$In_Degree)
all_users_summ$Out_Degree_Mean <- mean(all_users$Out_Degree)
all_users_summ$Out_Degree_StdDev <- sd(all_users$Out_Degree)
all_users_summ$Mean_In_Value_Mean <- mean(all_users$Mean_In_Value)
all_users_summ$Mean_In_Value_StdDev <- sd(all_users$Mean_In_Value)
all_users_summ$Mean_Out_Value_Mean <- mean(all_users$Mean_Out_Value)
all_users_summ$Mean_Out_Value_StdDev <- sd(all_users$Mean_Out_Value)
all_users_summ$Std_Dev_In_Value_Mean <- mean(all_users$Std_Dev_In_Value)
all_users_summ$Std_Dev_In_Value_StdDev <- sd(all_users$Std_Dev_In_Value)
all_users_summ$Std_Dev_Out_Value_Mean <- mean(all_users$Std_Dev_Out_Value)
all_users_summ$Std_Dev_Out_Value_StdDev <- sd(all_users$Std_Dev_Out_Value)
all_users_summ$In_Degree_Contract_Mean <- mean(all_users$In_Degree_Contract)
all_users_summ$In_Degree_Contract_StdDev <- sd(all_users$In_Degree_Contract)
all_users_summ$Out_Degree_Contract_Mean <- mean(all_users$Out_Degree_Contract)
all_users_summ$Out_Degree_Contract_StdDev <- sd(all_users$Out_Degree_Contract)
all_users_summ$Mean_In_Value_Contract_Mean <- mean(all_users$Mean_In_Value_Contract)
all_users_summ$Mean_In_Value_Contract_StdDev <- sd(all_users$Mean_In_Value_Contract)
all_users_summ$Mean_Out_Value_Contract_Mean <- mean(all_users$Mean_Out_Value_Contract)
all_users_summ$Mean_Out_Value_Contract_StdDev <- sd(all_users$Mean_Out_Value_Contract)
all_users_summ$Std_Dev_In_Value_Contract_Mean <- mean(all_users$Std_Dev_In_Value_Contract)
all_users_summ$Std_Dev_In_Value_Contract_StdDev <- sd(all_users$Std_Dev_In_Value_Contract)
all_users_summ$Std_Dev_Out_Value_Contract_Mean <- mean(all_users$Std_Dev_Out_Value_Contract)
all_users_summ$Std_Dev_Out_Value_Contract_StdDev <- sd(all_users$Std_Dev_Out_Value_Contract)

all_users_summ$In_Degree <- (all_users_stand$In_Degree-all_users_summ$In_Degree_Mean)/all_users_summ$In_Degree_StdDev
all_users_summ$Out_Degree <- (all_users_stand$Out_Degree-mean(all_users_stand$Out_Degree))/sd(all_users_stand$Out_Degree)
all_users_summ$Mean_In_Value <- (all_users_stand$Mean_In_Value-mean(all_users_stand$Mean_In_Value))/sd(all_users_stand$Mean_In_Value)
all_users_summ$Mean_Out_Value <- (all_users_stand$Mean_Out_Value-mean(all_users_stand$Mean_Out_Value))/sd(all_users_stand$Mean_Out_Value)
all_users_summ$Std_Dev_In_Value <- (all_users_stand$Std_Dev_In_Value-mean(all_users_stand$Std_Dev_In_Value))/sd(all_users_stand$Std_Dev_In_Value)
all_users_summ$Std_Dev_Out_Value <- (all_users_stand$Std_Dev_Out_Value-mean(all_users_stand$Std_Dev_Out_Value))/sd(all_users_stand$Std_Dev_Out_Value)
all_users_summ$In_Degree_Contract <- (all_users_stand$In_Degree_Contract-mean(all_users_stand$In_Degree_Contract))/sd(all_users_stand$In_Degree_Contract)
all_users_summ$Out_Degree_Contract <- (all_users_stand$Out_Degree_Contract-mean(all_users_stand$Out_Degree_Contract))/sd(all_users_stand$Out_Degree_Contract)
all_users_summ$Mean_In_Value_Contract <- (all_users_stand$Mean_In_Value_Contract-mean(all_users_stand$Mean_In_Value_Contract))/sd(all_users_stand$Mean_In_Value_Contract)
all_users_summ$Mean_Out_Value_Contract <- (all_users_stand$Mean_Out_Value_Contract-mean(all_users_stand$Mean_Out_Value_Contract))/sd(all_users_stand$Mean_Out_Value_Contract)
all_users_summ$Std_Dev_In_Value_Contract <- (all_users_stand$Std_Dev_In_Value_Contract-mean(all_users_stand$Std_Dev_In_Value_Contract))/sd(all_users_stand$Std_Dev_In_Value_Contract)
all_users_summ$Std_Dev_Out_Value_Contract

# Standardise attributes to have mean of 0 and standard deviation of 1
all_users_stand <- all_users

all_users_stand$Total_Count <- (all_users_stand$Total_Count-all_users_summ$Total_Count_Mean)/all_users_summ$Total_Count_StdDev
all_users_stand$In_Degree <- (all_users_stand$In_Degree-all_users_summ$In_Degree_Mean)/all_users_summ$In_Degree_StdDev
all_users_stand$Out_Degree <- (all_users_stand$Out_Degree-all_users_summ$Out_Degree_Mean)/all_users_summ$Out_Degree_StdDev
all_users_stand$Mean_In_Value <- (all_users_stand$Mean_In_Value-all_users_summ$Mean_In_Value_Mean)/all_users_summ$Mean_In_Value_StdDev
all_users_stand$Mean_Out_Value <- (all_users_stand$Mean_Out_Value-all_users_summ$Mean_Out_Value_Mean)/all_users_summ$Mean_Out_Value_StdDev
all_users_stand$Std_Dev_In_Value <- (all_users_stand$Std_Dev_In_Value-all_users_summ$Std_Dev_In_Value_Mean)/all_users_summ$Std_Dev_In_Value_StdDev
all_users_stand$Std_Dev_Out_Value <- (all_users_stand$Std_Dev_Out_Value-all_users_summ$Std_Dev_Out_Value_Mean)/all_users_summ$Std_Dev_Out_Value_StdDev
all_users_stand$In_Degree_Contract <- (all_users_stand$In_Degree_Contract-all_users_summ$In_Degree_Contract_Mean)/all_users_summ$In_Degree_Contract_StdDev
all_users_stand$Out_Degree_Contract <- (all_users_stand$Out_Degree_Contract-all_users_summ$Out_Degree_Contract_Mean)/all_users_summ$Out_Degree_Contract_StdDev
all_users_stand$Mean_In_Value_Contract <- (all_users_stand$Mean_In_Value_Contract-all_users_summ$Mean_In_Value_Contract_Mean)/all_users_summ$Mean_In_Value_Contract_StdDev
all_users_stand$Mean_Out_Value_Contract <- (all_users_stand$Mean_Out_Value_Contract-all_users_summ$Mean_Out_Value_Contract_Mean)/all_users_summ$Mean_Out_Value_Contract_StdDev
all_users_stand$Std_Dev_In_Value_Contract <- (all_users_stand$Std_Dev_In_Value_Contract-all_users_summ$Std_Dev_In_Value_Contract_Mean)/all_users_summ$Std_Dev_In_Value_Contract_StdDev
all_users_stand$Std_Dev_Out_Value_Contract <- (all_users_stand$Std_Dev_Out_Value_Contract-all_users_summ$Std_Dev_Out_Value_Contract_Mean)/all_users_summ$Std_Dev_Out_Value_Contract_StdDev



#####
# Prepare dataset for analysis
#####
na_address <- all_users_stand[is.na(all_users_stand$Address)==TRUE,] # Keep NA address

data_analysis <- all_users_stand[is.na(all_users_stand$Address)!=TRUE,] # Remove NA address
row.names(data_analysis) <- data_analysis$Address
data_analysis <- subset(data_analysis, select = -c(Address,IsContract
                                               ,Status,Data_Balance
                                               ,Data_Nonce,Data_Code
                                               ,Data_Name,Data_Storage
                                               ,Data_FirstSeen))
# 933,182 records over 13 variables

test_means <- data_analysis[1:3000,]
test_means[1,]


# Loop through number of clusters in order to determine optimal number of clusters
for(i in 1:15){
  km <- kmeans(data_analysis,i)
  with_ss <- km$tot.withinss
  
  df_kmeans <- data.frame(clusters=i
                          ,within_ss=with_ss)
  
  if(i==1){
    write.table(df_kmeans,"03.03_k_Means_WithinSS.txt",sep = ",", col.names = T, append = F, row.names = FALSE)
  }else{
    write.table(df_kmeans,"03.03_k_Means_WithinSS.txt",sep = ",", col.names = F, append = T, row.names = FALSE)
  }
}

withinss <- read.table("03.03_k_Means_WithinSS.txt", header = TRUE, sep = ",")
scale <- 2500000
max_y <- round(max(withinss$within_ss)/scale)*scale
s <- seq(length(withinss$clusters))  # one shorter than data
s1 <-seq(length(withinss$clusters))
s2 <- seq(length(withinss$clusters))+1

g <- ggplot(data=withinss, aes(x = clusters, y=within_ss)) +
  geom_segment(aes(x=withinss$clusters[s1]
                   ,y=withinss$within_ss[s1]
                   ,xend=withinss$clusters[s2]
                   ,yend=withinss$within_ss[s2])) +
  geom_segment(x=6,xend=6
               ,y=withinss$within_ss[6],yend=scale
               ,aes(col=red),show.legend = FALSE,size=1) +
  geom_text(x=6,y=scale*1.1,aes(label="Optimal Clusters = 6",col=red),show.legend = FALSE) +
  geom_point(size=3, color=blue) +
  labs(title="Within Sum of Squares per Cluster"
       ,x="Number of Clusters"
       ,y="Within Sum of Squares"
  ) +
  scale_y_continuous(breaks=seq(0, max_y, scale)
                     ,labels = formatC(seq(0, max_y, scale), format="d", big.mark=","))
g

# Save to file
saveToPDF(g,"03.04_WithinSS_Graph.pdf")



#####
# Produce histograms for clustered variables
#####
km6 <- kmeans(data_analysis,6)
dtffff <- cbind(data_analysis,clus=km6$cluster)

nrow(dtffff[dtffff$clus==1,])
nrow(dtffff[dtffff$clus==2,])
nrow(dtffff[dtffff$clus==3,])
nrow(dtffff[dtffff$clus==4,])
nrow(dtffff[dtffff$clus==5,])
nrow(dtffff[dtffff$clus==6,])

data_check <- dtffff[dtffff$clus!=1,]

binwidth = bin/100
                 ,colour = black
                 ,fill = blue

km6$centers

mean(dtffff$Total_Count)
sd(dtffff$Total_Count)
min(dtffff$Total_Count)
max(dtffff$Total_Count)

max(log10(dtffff$Total_Count+2))

g <- ggplot(data=dtffff, aes(x = log10(Total_Count+2),fill=as.character(clus))) +
  geom_histogram(binwidth = 0.01) +
  labs(title="Histogram of number of transactions per user (log10 scale)"
       ,x="Number of transactions"
       ,y="Number of users"
  )+
  scale_fill_manual("SmartContract", values = c(red,orange,yellow,green,blue,indigo))+
  xlim(c(0.25,3))+ylim(c(0,25))
g



g <- ggplot(data=data_check, aes(x = log10(Total_Count+2),y = log10(In_Degree+2),color=as.character(clus))) +
  geom_point() +
  labs(title="Histogram of number of transactions per user (log10 scale)"
       ,x="Number of transactions"
       ,y="Number of users"
  )+
  scale_color_manual("Cluster", values = c(red,orange,yellow,green,blue,indigo))

+
  xlim(c(0.25,3))+ylim(c(0,25))
g




max(data_analysis$Total_Count)
+ scale_x_continuous(breaks=seq(0, 4, 1)
                         ,labels = cbind("0","10","100","1,000","10,000")
                         ,limits=c(-0.1,4) )
















###########################################################
bin=1
i=2
dta <- all_users[all_users$Total_Count>=(i-1)*bin,]
dta <- dta[dta$Total_Count<i*bin,]
rows <- nrow(dta)


# Ticks from 0-10, every .25
  scale_x_continuous(formatter='log10')
  annotate(geom="segment", y=-5, yend=0,
           x=seq(0,3500,100), xend=seq(0,3500,100))
g
exp(15)
nrow(all_users[all_users$Total_Count>10000,])

+
  labs(title="Histogram of number of blocks mined"
       ,x="Number of Blocks"
       ,y="Count"
  ) 
plot(all_users$Total_Count)
+
  annotate(geom="segment", y=-5, yend=0,
           x=seq(0,3500,100), xend=seq(0,3500,100))
g
# Excluded: 47 items (bigger than 3,500)


install.packages("tclust")

library ("tclust")
data ("geyser2")
clus <- tkmeans (geyser2, k =3, alpha = 0.03)
xx<-plot (clus)

271*0.03
9/271

clus$par # The analysis parameters
clus$centers # The centres of each cluster
clus$weights
mean(clus$obj)

m1<-kmeans(geyser2,9)




#################################
data("iris")
irisf<-iris
irisf$Species<-NULL
m1<-kmeans(irisf,9)
m1$withinss
m1$tot.withinss
m1$betweenss/m1$totss

plot(irisf)
plot(m1)

Within cluster sum of squares by cluster:
  [1] 15.15100 39.82097 23.87947
(between_SS / total_SS = 88.4 %)


###################################
test_users <- data.frame(Address=all_users$Address
                            ,In_Degree=all_users$In_Degree
                            ,Out_Degree=all_users$Out_Degree)
test_usersx <- test_users[1:3000,]
test_names <- as.data.frame(test_usersx$Address)
test_data <- data.frame(In_Degree=log10(test_usersx$In_Degree+1)
                        ,Out_Degree=log10(test_usersx$Out_Degree+1))


check <- kmeans(test_data,10)
plot(check)

clus <- tkmeans (test_data, k =8, alpha = 0.03)
plot (clus)
