/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
	  -- SELECT COUNT(*) --6,024,481
  FROM [ETH002_BLK_ANALYSIS].[analysis].[Smart_Contract_Transactions]
  WHERE [Data_Recipient] = '0x109c4f2ccc82c4d77bde15f306707320294aea3f'
  OR [Data_Sender] = '0x109c4f2ccc82c4d77bde15f306707320294aea3f'
  ORDER BY [Data_Time]
			,CASE WHEN [Data_TxIndex] = 'NA' THEN 0 ELSE [Data_TxIndex] END

SELECT [Data_ParentHash]
,SUM([Data_Gasused]) AS [Total_Gas]
,COUNT([Data_TxIndex]) AS [Number_Tx]
	  -- SELECT COUNT(*) --6,024,481
  FROM [ETH002_BLK_ANALYSIS].[analysis].[Smart_Contract_Transactions]
  WHERE [Data_Recipient] = '0x109c4f2ccc82c4d77bde15f306707320294aea3f'
  OR [Data_Sender] = '0x109c4f2ccc82c4d77bde15f306707320294aea3f'
GROUP BY [Data_ParentHash],[Data_Time]
  ORDER BY [Data_Time]
			,CASE WHEN [Data_TxIndex] = 'NA' THEN 0 ELSE [Data_TxIndex] END

SELECT *
FROM [ETH001_BLK_DATA].input.Ethereum_Transactions
WHERE 1=1
AND [Data_Recipient] = '0x9a049f5d18c239efaa258af9f3e7002949a977a0'
AND [Data_TxType] = 'create'


SELECT *
FROM [ETH001_BLK_DATA].input.Ethereum_Addresses
WHERE [Data_Address] = '0x9a049f5d18c239efaa258af9f3e7002949a977a0'
