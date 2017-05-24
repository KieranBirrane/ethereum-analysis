USE ETH001_BLK_DATA

SELECT COUNT(*)
-- SELECT TOP 1 eb.[Data_Time]
-- SELECT MIN(eb.[Data_Time])
-- SELECT MIN(CAST(eb.[Data_Number] as bigint))
FROM input.Ethereum_Blocks eb
WHERE 1=1
AND eb.[Data_Time] < '2015-08-30'

SELECT SUM(eb.[Data_Difficulty])/POWER(10.0,18)
FROM input.Ethereum_Blocks eb

EXECUTE LoadText
@filepath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\01_Consolidated'
,@filename = 'Consolidated_0_249999.csv'
,@table = 'input.Ethereum_Blocks'
,@action = 'PRINT'

-- Load DD
TRUNCATE TABLE control_table.Data_Definition
EXECUTE LoadText
@filepath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\SQL_Config'
,@filename = 'Data_Definition.csv'
,@table = 'control_table.Data_Definition'
,@action = 'INSERT'


-- Load transactions
EXECUTE LoadText
@filepath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\04_Cleaned_Transactions'
--,@filename = 'Tx_Info_0_249999_(46147_249987).csv'
--,@filename = 'Tx_Info_250000_499999_(250005_499998).csv'
--,@filename = 'Tx_Info_500000_749999_(500002_749995).csv'
--,@filename = 'Tx_Info_750000_999999_(750000_999999).csv'
--,@filename = 'Tx_Info_1000000_1249999_(1000000_1249999).csv'
--,@filename = 'Tx_Info_1250000_1499999_(1250000_1499998).csv' -- 5:47	1,492,147
--,@filename = 'Tx_Info_1500000_1749999_(1500000_1749999).csv' -- 7:54	2,010,399
--,@filename = 'Tx_Info_1750000_1999999_(1750001_1999999).csv' -- 6:14	2,019,440
--,@filename = 'Tx_Info_2000000_2249999_(2000000_2249999).csv' -- 16:45	2,310,081
--,@filename = 'Tx_Info_2250000_2499999_(2250001_2499998).csv' -- 11:04	1,990,698
--,@filename = 'Tx_Info_2500000_2749999_(2500001_2749998).csv' -- 12:01	1,783,250
--,@filename = 'Tx_Info_2750000_2999999_(2750000_2999998).csv' -- 5:54	1,803,924
--,@filename = 'Tx_Info_3000000_3200000_(3000000_3200000).csv' -- 14:48	2,059,279
,@table = 'input.Ethereum_Transactions'
,@action = 'INSERT'

-- Load Addresses
EXECUTE LoadText
@filepath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\06_Downloaded_Addresses'
,@filename = 'Address_Info.csv'
,@table = 'input.Ethereum_Addresses'
,@action = 'PRINT'