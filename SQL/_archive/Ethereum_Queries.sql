
SELECT *
FROM temp_tx

	WHERE [data#type] <> 'tx'
	AND ([data#sender] = '0xBAA54d6E90c3F4d7Ebec11bD180134C7eD8eBb52' OR [data#recipient] = '0xBAA54d6E90c3F4d7Ebec11bD180134C7eD8eBb52')
	order by CAST([data#block_id] as bigint),CASE WHEN [data#txIndex] = 'NA' THEN 0 ELSE CAST([data#txIndex] as bigint) END

	
	
	/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [status]
      ,[data#number]
      ,[data#hash]
      ,[data#parentHash]
      ,[data#uncleHash]
      ,[data#coinbase]
      ,[data#root]
      ,[data#txHash]
      ,[data#difficulty]
      ,[data#gasLimit]
      ,[data#gasUsed]
      ,[data#time]
      ,[data#extra]
      ,[data#mixDigest]
      ,[data#nonce]
      ,[data#tx_count]
      ,[data#uncle_count]
      ,[data#size]
      ,[data#blockTime]
      ,[data#reward]
      ,[Sys#time()]
      ,[file_name]
--,  CONVERT(varbinary(64), right([data#extra],len([data#extra])-2), 1)
,  CONVERT(varchar(64), right([data#extra],len([data#extra])-2), 1)
,  CONVERT(varchar(64), right([data#extra],len([data#extra])-2), 2)
,dbo.GetProductCodeFromVARBINARY([data#extra])
  FROM [ETH001_BLK_DATA].[dbo].[blocks_750k_5]


  SELECT
  
  CONVERT(varchar(64), right([data#extra],len([data#extra])-2), 1)
,  CONVERT(varchar(64), right([data#extra],len([data#extra])-2), 2)
--,  CONVERT(varbinary(64), right([data#extra],len([data#extra])-2), 1)
--,dbo.GetProductCodeFromVARBINARY([data#extra])
  FROM [ETH001_BLK_DATA].[dbo].[blocks_750k_5]



SELECT 
[data#extra]
,CONVERT(VARBINARY(MAX), [data#extra], 1)
,CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), [data#extra], 1))
FROM [ETH001_BLK_DATA].[dbo].[blocks_750k_5]
order by 1

SELECT CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), '0x48656c70', 1)) -- Requires 0x, returns 'Help'
SELECT CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), '48656c70', 2)) -- Assumes 0x string, no 0x wanted, returns 'Help'



SELECT distinct
eb.[data_extra]
,CONVERT(VARBINARY(MAX), [data_extra], 1)
,CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), [data_extra], 1))


SELECT top 10
dbo.ConvertHexadecimal([data_nonce])
,dbo.ConvertHexadecimal([data_extra])
-- SELECT TOP 1 *
FROM [ETH001_BLK_DATA].[input].[Ethereum_Blocks] eb
order by 1
