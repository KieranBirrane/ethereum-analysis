/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [ETH002_BLK_ANALYSIS].[dbo].[user_number_tx] -- 968886
  ORDER BY [SENT]+[RECEIVED] desc

SELECT COUNT(ea.[Data_Address])
FROM [ETH001_BLK_DATA].[input].[Ethereum_Addresses] ea -- 969386

SELECT COUNT(ea.[Data_Code])
FROM [ETH001_BLK_DATA].[input].[Ethereum_Addresses] ea -- 145967
WHERE ea.[Data_Code] <> '0x'

SELECT	COUNT(DISTINCT ea.[Data_Code]) -- SELECT 1
		,[ETH001_BLK_DATA].dbo.ConvertHexadecimal(ea.[Data_Code]) AS [Code]
		-- SELECT LEN(ea.[Data_Code])
FROM [ETH001_BLK_DATA].[input].[Ethereum_Addresses] ea -- 8856
WHERE ea.[Data_Code] <> '0x'
GROUP BY	[ETH001_BLK_DATA].dbo.ConvertHexadecimal(ea.[Data_Code])

