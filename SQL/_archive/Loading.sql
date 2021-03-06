SELECT COUNT(*)
FROM input.Ethereum_Blocks eb


EXECUTE LoadText
@filepath = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\01_Consolidated'
, @filename = 'Consolidated_250000_499999.csv'
, @table = 'input.Ethereum_Blocks'

-- Load address data
INSERT INTO input.Addresses
SELECT [data#coinbase],[frequency],[source]
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Text;Database=C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\05_User_Addresses',
		'SELECT * FROM [All_Miners_Addresses_Summary.csv]')

INSERT INTO input.Addresses
SELECT [data#coinbase],[frequency],[source]
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Text;Database=C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\05_User_Addresses',
		'SELECT * FROM [Tx_Blocks_Miners_Addresses_Summary.csv]')

INSERT INTO input.Addresses
SELECT [data#coinbase],[frequency],[source]
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
		'Text;Database=C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\05_User_Addresses',
		'SELECT * FROM [Tx_Participants_Addresses_Summary.csv]')

SELECT	ad.[data#coinbase]
FROM input.Addresses ad
WHERE ad.[data#coinbase] IS NOT NULL
GROUP BY ad.[data#coinbase]
ORDER BY ad.[data#coinbase]

