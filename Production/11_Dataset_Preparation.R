##### ##### ##### ##### ##### ##### #####
##### ##### ## Dataset Prep # ##### #####
##### ##### ##### ##### ##### ##### #####

# Parameters
# # Dates less than   01-02-2017
# # Blocks up to      3,100,153

###### Get Block_Miners Data ######
# Create template email
temp <- createTemplate("d14127984@mydit.ie","d14127984@mydit.ie","Block_Miners")

sql = "TRUNCATE TABLE ETH002_BLK_ANALYSIS.analysis.Block_Miners"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

sql = "
INSERT ETH002_BLK_ANALYSIS.analysis.Block_Miners(
  [Data_Coinbase]
  ,[Number_Blocks]
  ,[First_Block]
  ,[First_Block_Time]
  ,[Last_Block]
  ,[Last_Block_Time]
  ,[Total_Reward]
  ,[Mined_Blocks]
  ,[Status]
  ,[Data_Address]
  ,[Data_Balance]
  ,[Data_Nonce]
  ,[Data_Code]
  ,[Data_Name]
  ,[Data_Storage]
  ,[Data_FirstSeen]
)
SELECT
  bm.[Data_Coinbase]
  ,bm.[Number_Blocks]
  ,bm.[First_Block]
  ,bm.[First_Block_Time]
  ,bm.[Last_Block]
  ,bm.[Last_Block_Time]
  ,bm.[Total_Reward]
  ,bm.[Mined_Blocks]
  ,ea.[Status]
  ,ea.[Data_Address]
  ,ea.[Data_Balance]
  ,ea.[Data_Nonce]
  ,ea.[Data_Code]
  ,ea.[Data_Name]
  ,ea.[Data_Storage]
  ,ea.[Data_FirstSeen]
FROM (
  SELECT
    eb.[Data_Coinbase]
    ,COUNT(eb.[Data_Number])				AS [Number_Blocks]
    ,MIN(CAST(eb.[Data_Number] AS BIGINT))	AS [First_Block]
    ,MIN(eb.[Data_Time])					AS [First_Block_Time]
    ,MAX(CAST(eb.[Data_Number] AS BIGINT))	AS [Last_Block]
    ,MAX(eb.[Data_Time])					AS [Last_Block_Time]
    ,SUM(eb.[Data_Reward])					AS [Total_Reward]
    ,STUFF(
      (
        SELECT ',' + eb1.[Data_Number]
        FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb1
        WHERE eb1.[Data_Coinbase] = eb.[Data_Coinbase]
        ORDER BY eb1.[Data_Number]
        FOR XML PATH ('')
      ), 1, 1, '') AS [Mined_Blocks]
  FROM ETH001_BLK_DATA.input.Ethereum_Blocks eb
  WHERE eb.[Data_Time] < '2017-02-01'
  GROUP BY eb.[Data_Coinbase]
) bm
LEFT JOIN
  ETH001_BLK_DATA.input.Ethereum_Addresses ea
  ON bm.[Data_Coinbase] = ea.[Data_Address]
"

s <- Sys.time()
res <- sqlQuery(conn, sql,errors = T,as.is = T)
e <- Sys.time()
mess <- paste("ETH002_BLK_ANALYSIS.analysis.Block_Miners populated: ",e-s)
email <- createEmailFromTemplate(temp,mess)
sendMessageWithLabel(email)










###### Get Smart Contract Transactions Data ######
# Create template email
temp <- createTemplate("d14127984@mydit.ie","d14127984@mydit.ie","Smart_Contract_Transactions")

sql = "TRUNCATE TABLE ETH002_BLK_ANALYSIS.analysis.Smart_Contract_Transactions"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

sql = "
WITH create_tx AS (
SELECT DISTINCT [Data_Recipient]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions
WHERE [Data_TxType] = 'create'
)

INSERT ETH002_BLK_ANALYSIS.analysis.Smart_Contract_Transactions(
[Status]
,[Data_Hash]
,[Data_Sender]
,[Data_Recipient]
,[Data_AccountNonce]
,[Data_Price]
,[Data_Gaslimit]
,[Data_Amount]
,[Data_BlockID]
,[Data_Time]
,[Data_NewContract]
,[Data_IsContractTx]
,[Data_BlockHash]
,[Data_Parenthash]
,[Data_TxIndex]
,[Data_Gasused]
,[Data_TxType]
,[Contract_Address_Info]
)
SELECT
tx.[Status]
,tx.[Data_Hash]
,tx.[Data_Sender]
,tx.[Data_Recipient]
,tx.[Data_AccountNonce]
,tx.[Data_Price]
,tx.[Data_Gaslimit]
,tx.[Data_Amount]
,tx.[Data_BlockID]
,tx.[Data_Time]
,tx.[Data_NewContract]
,tx.[Data_IsContractTx]
,tx.[Data_BlockHash]
,tx.[Data_Parenthash]
,tx.[Data_TxIndex]
,tx.[Data_Gasused]
,tx.[Data_TxType]
,CASE
  WHEN tx1.[Data_Recipient] IS NULL AND tx2.[Data_Recipient] IS NULL THEN 'NEITHER'
  WHEN tx1.[Data_Recipient] IS NOT NULL AND tx2.[Data_Recipient] IS NULL THEN 'SEND'
  WHEN tx1.[Data_Recipient] IS NULL AND tx2.[Data_Recipient] IS NOT NULL THEN 'RECEIVE'
  WHEN tx1.[Data_Recipient] IS NOT NULL AND tx2.[Data_Recipient] IS NOT NULL THEN 'BOTH'
  END AS [Contract_Address_Info]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions tx
  LEFT JOIN create_tx tx1
  ON tx.[Data_Sender] = tx1.[Data_Recipient]
  LEFT JOIN create_tx tx2
  ON tx.[Data_Recipient] = tx2.[Data_Recipient]
WHERE 1=1
AND COALESCE(tx1.[Data_Recipient],tx2.[Data_Recipient]) IS NOT NULL
AND tx.[Data_Time] < '2017-02-01'
"

s <- Sys.time()
res <- sqlQuery(conn, sql,errors = T,as.is = T)
e <- Sys.time()
mess <- paste("ETH002_BLK_ANALYSIS.analysis.Smart_Contract_Transactions populated: ",e-s)
email <- createEmailFromTemplate(temp,mess)
sendMessageWithLabel(email)
# 40.58 mins









###### Get User Transactions Data ######
# Create template email
temp <- createTemplate("d14127984@mydit.ie","d14127984@mydit.ie","User_Details")

sql = "TRUNCATE TABLE ETH002_BLK_ANALYSIS.analysis.Transaction_Detail"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

sql = "
INSERT INTO ETH002_BLK_ANALYSIS.analysis.Transaction_Detail(
[Data_Sender]
,[Data_Recipient]
,[Data_Amount]
,[Transaction_Type]
)
SELECT
tx.[Data_Sender]
,tx.[Data_Recipient]
,tx.[Data_Amount]
,CASE WHEN sc.[Contract_Address_Info] IN ('SEND','RECEIVE','BOTH') THEN 'SMT' ELSE 'REG' END AS [Transaction_Type]
FROM ETH001_BLK_DATA.input.Ethereum_Transactions tx
  LEFT JOIN ETH002_BLK_ANALYSIS.analysis.Smart_Contract_Transactions sc
  ON tx.[Data_Hash] = sc.[Data_Hash]
WHERE tx.[Data_Time] < '2017-02-01'
"

s <- Sys.time()
res <- sqlQuery(conn, sql,errors = T,as.is = T)
e <- Sys.time()
mess <- paste("ETH002_BLK_ANALYSIS.analysis.Transaction_Detail populated: ",e-s)
email <- createEmailFromTemplate(temp,mess)
sendMessageWithLabel(email)
# 34.76 mins



sql = "TRUNCATE TABLE ETH002_BLK_ANALYSIS.analysis.Sender_Amount_Details"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

sql = "
INSERT INTO ETH002_BLK_ANALYSIS.analysis.Sender_Amount_Details(
[Data_Sender]
,[Count]
,[Sum]
,[Average]
,[Std_Dev_Pop]
,[Count_REG]
,[Sum_REG]
,[Average_REG]
,[Std_Dev_Pop_REG]
,[Count_SMT]
,[Sum_SMT]
,[Average_SMT]
,[Std_Dev_Pop_SMT]
)
SELECT 
  [Data_Sender]
  ,COUNT(*)               AS [Count]
  ,SUM([Data_Amount])     AS [Sum]
  ,AVG([Data_Amount])     AS [Average]
  ,STDEV([Data_Amount])   AS [Std_Dev_Pop]
  ,COUNT([Data_Amount])   AS [Count_REG]
  ,SUM([Data_Amount])     AS [Sum_REG]
  ,AVG([Transaction_Type])                                                      AS [Average_REG]
  ,STDEV([Transaction_Type])                                                    AS [Std_Dev_Pop_REG]
  ,COUNT(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)   AS [Count_SMT]
  ,SUM(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)     AS [Sum_SMT]
  ,AVG(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)     AS [Average_SMT]
  ,STDEV(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)   AS [Std_Dev_Pop_SMT]
FROM ETH002_BLK_ANALYSIS.analysis.Transaction_Detail td
GROUP BY [Data_Sender]
"

s <- Sys.time()
res <- sqlQuery(conn, sql,errors = T,as.is = T)
e <- Sys.time()
mess <- paste("ETH002_BLK_ANALYSIS.analysis.Sender_Amount_Details populated: ",e-s)
email <- createEmailFromTemplate(temp,mess)
sendMessageWithLabel(email)
# 12.83 mins




sql = "TRUNCATE TABLE ETH002_BLK_ANALYSIS.analysis.Recipient_Amount_Details"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

sql = "
INSERT INTO ETH002_BLK_ANALYSIS.analysis.Recipient_Amount_Details(
[Data_Recipient]
,[Count]
,[Sum]
,[Average]
,[Std_Dev_Pop]
,[Count_REG]
,[Sum_REG]
,[Average_REG]
,[Std_Dev_Pop_REG]
,[Count_SMT]
,[Sum_SMT]
,[Average_SMT]
,[Std_Dev_Pop_SMT]
)
SELECT 
  [Data_Recipient]
  ,COUNT(*)               AS [Count]
  ,SUM([Data_Amount])     AS [Sum]
  ,AVG([Data_Amount])     AS [Average]
  ,STDEV([Data_Amount])   AS [Std_Dev_Pop]
  ,COUNT([Data_Amount])   AS [Count_REG]
  ,SUM([Data_Amount])     AS [Sum_REG]
  ,AVG([Data_Amount])     AS [Average_REG]
  ,STDEV([Data_Amount])   AS [Std_Dev_Pop_REG]
  ,COUNT(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)   AS [Count_SMT]
  ,SUM(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)     AS [Sum_SMT]
  ,AVG(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)     AS [Average_SMT]
  ,STDEV(CASE [Transaction_Type] WHEN 'SMT' THEN [Data_Amount] ELSE NULL END)   AS [Std_Dev_Pop_SMT]
FROM ETH002_BLK_ANALYSIS.analysis.Transaction_Detail td
GROUP BY [Data_Recipient]
"

s <- Sys.time()
res <- sqlQuery(conn, sql,errors = T,as.is = T)
e <- Sys.time()
mess <- paste("ETH002_BLK_ANALYSIS.analysis.Recipient_Amount_Details populated: ",e-s)
email <- createEmailFromTemplate(temp,mess)
sendMessageWithLabel(email)
# 9.77 mins




sql = "TRUNCATE TABLE ETH002_BLK_ANALYSIS.analysis.User_Details"
res <- sqlQuery(conn, sql,errors = T,as.is = T)

sql = "
INSERT INTO ETH002_BLK_ANALYSIS.analysis.User_Details(
[Address]
,[IsContract]
,[Status]
,[Data_Balance]
,[Data_Nonce]
,[Data_Code]
,[Data_Name]
,[Data_Storage]
,[Data_FirstSeen]
,[Total_Count]
,[In_Degree]
,[Out_Degree]
,[Mean_In_Value]
,[Mean_Out_Value]
,[Std_Dev_In_Value]
,[Std_Dev_Out_Value]
,[In_Degree_Contract]
,[Out_Degree_Contract]
,[Mean_In_Value_Contract]
,[Mean_Out_Value_Contract]
,[Std_Dev_In_Value_Contract]
,[Std_Dev_Out_Value_Contract]
)
SELECT
usr.[Address]
,CASE WHEN con.[Data_Recipient] IS NULL THEN 'N' ELSE 'Y' END AS [IsContract]
,adr.[Status]
,adr.[Data_Balance]
,adr.[Data_Nonce]
,adr.[Data_Code]
,adr.[Data_Name]
,adr.[Data_Storage]
,adr.[Data_FirstSeen]
,SUM(COALESCE(usr.[Total_Count],0))                 AS [Total_Count]
,SUM(COALESCE(usr.[In_Degree],0))                   AS [In_Degree]
,SUM(COALESCE(usr.[Out_Degree],0))                  AS [Out_Degree]
,SUM(COALESCE(usr.[Mean_In_Value],0))               AS [Mean_In_Value]
,SUM(COALESCE(usr.[Mean_Out_Value],0))              AS [Mean_Out_Value]
,SUM(COALESCE(usr.[Std_Dev_In_Value],0))            AS [Std_Dev_In_Value]
,SUM(COALESCE(usr.[Std_Dev_Out_Value],0))           AS [Std_Dev_Out_Value]
,SUM(COALESCE(usr.[In_Degree_Contract],0))          AS [In_Degree_Contract]
,SUM(COALESCE(usr.[Out_Degree_Contract],0))         AS [Out_Degree_Contract]
,SUM(COALESCE(usr.[Mean_In_Value_Contract],0))      AS [Mean_In_Value_Contract]
,SUM(COALESCE(usr.[Mean_Out_Value_Contract],0))     AS [Mean_Out_Value_Contract]
,SUM(COALESCE(usr.[Std_Dev_In_Value_Contract],0))   AS [Std_Dev_In_Value_Contract]
,SUM(COALESCE(usr.[Std_Dev_Out_Value_Contract],0))  AS [Std_Dev_Out_Value_Contract]
FROM
(
  SELECT
  snd.[Data_Sender]	    	AS [Address]
  ,snd.[Count]		      	AS [Total_Count]
  ,0					          	AS [In_Degree]
  ,snd.[Count_REG]	    	AS [Out_Degree]
  ,0					          	AS [Mean_In_Value]
  ,snd.[Average_REG]	  	AS [Mean_Out_Value]
  ,0						          AS [Std_Dev_In_Value]
  ,snd.[Std_Dev_Pop_REG]	AS [Std_Dev_Out_Value]
  ,0						          AS [In_Degree_Contract]
  ,snd.[Count_SMT]		    AS [Out_Degree_Contract]
  ,0						          AS [Mean_In_Value_Contract]
  ,snd.[Average_SMT]		  AS [Mean_Out_Value_Contract]
  ,0						          AS [Std_Dev_In_Value_Contract]
  ,snd.[Std_Dev_Pop_SMT]	AS [Std_Dev_Out_Value_Contract]
  FROM ETH002_BLK_ANALYSIS.analysis.Sender_Amount_Details snd
  
  UNION ALL
  
  SELECT
  rec.[Data_Recipient]  	AS [Address]
  ,rec.[Count]		      	AS [Total_Count]
  ,rec.[Count_REG]	    	AS [In_Degree]
  ,0				          		AS [Out_Degree]
  ,rec.[Average_REG]	  	AS [Mean_In_Value]
  ,0					           	AS [Mean_Out_Value]
  ,rec.[Std_Dev_Pop_REG]	AS [Std_Dev_In_Value]
  ,0					          	AS [Std_Dev_Out_Value]
  ,rec.[Count_SMT]	    	AS [In_Degree_Contract]
  ,0					          	AS [Out_Degree_Contract]
  ,rec.[Average_SMT]	  	AS [Mean_In_Value_Contract]
  ,0					          	AS [Mean_Out_Value_Contract]
  ,rec.[Std_Dev_Pop_SMT]	AS [Std_Dev_In_Value_Contract]
  ,0					          	AS [Std_Dev_Out_Value_Contract]
  FROM ETH002_BLK_ANALYSIS.analysis.Recipient_Amount_Details rec
) usr
LEFT JOIN
  ETH001_BLK_DATA.input.Ethereum_Addresses adr
  ON usr.[Address] = adr.[Data_Address]
LEFT JOIN
  (
  SELECT DISTINCT [Data_Recipient]
  FROM ETH001_BLK_DATA.input.Ethereum_Transactions
  WHERE [Data_TxType] = 'create'
  ) con
  ON usr.[Address] = con.[Data_Recipient]
GROUP BY  usr.[Address]
          ,CASE WHEN con.[Data_Recipient] IS NULL THEN 'N' ELSE 'Y' END
          ,adr.[Status]
          ,adr.[Data_Balance]
          ,adr.[Data_Nonce]
          ,adr.[Data_Code]
          ,adr.[Data_Name]
          ,adr.[Data_Storage]
          ,adr.[Data_FirstSeen]
"

s <- Sys.time()
res <- sqlQuery(conn, sql,errors = T,as.is = T)
e <- Sys.time()
mess <- paste("ETH002_BLK_ANALYSIS.analysis.User_Details populated: ",e-s)
email <- createEmailFromTemplate(temp,mess)
sendMessageWithLabel(email)
# 11.08 mins