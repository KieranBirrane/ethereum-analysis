--INSERT INTO 
	SELECT
	a.*
	-- SELECT *
	into temp_tx
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Text;Database=C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\04_Cleaned_Transactions',
		'SELECT * FROM [Tx_Info_0_249999_(46147_249987).csv]') a



SELECT COUNT(*)
-- SELECT TOP 1 eb.[Data_Time]
-- SELECT MIN(eb.[Data_Time])
-- SELECT MIN(CAST(eb.[Data_Number] as bigint))
-- SELECT MAX(CAST(eb.[Data_Number] as bigint))
-- SELECT TOP 1 eb.[Data_Number],eb.[Data_TX_Count]
FROM input.Ethereum_Blocks eb
WHERE 1=1
--AND eb.[Data_Time] > '2017-02-01'
ORDER BY CAST(eb.[Data_TX_Count] as bigint) DESC


CREATE UNIQUE CLUSTERED INDEX block_number
ON input.Ethereum_Blocks([Data_Number],[Data_Time]);


SELECT *
-- SELECT TOP 1 eb.[Data_Time]
-- SELECT MIN(eb.[Data_Time])
-- SELECT MIN(CAST(eb.[Data_Number] as bigint))
-- SELECT MAX(CAST(eb.[Data_Number] as bigint))
INTO temp_1719596
FROM input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_BlockID] = '1719596'
--AND eb.[Data_Time] > '2017-02-01'

SELECT *
FROM temp_1719596


SELECT et.[Data_TxType],COUNT(et.[Data_TxType]) -- tx, create, call, suicide
FROM input.Ethereum_Transactions et
WHERE 1=1
GROUP BY et.[Data_TxType]

tx	16808444
suicide	1564
call	1409841
create	191479

SELECT et.[Data_Recipient] --,COUNT(et.[Data_TxType]) -- tx, create, call, suicide
INTO temp_contracts
FROM input.Ethereum_Transactions et
WHERE 1=1
AND et.[Data_TxType] = 'call'
GROUP BY et.[Data_Recipient]