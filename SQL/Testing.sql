SELECT 1 AS [Header]
INTO temp_table

select * from dbo.temp_table


SELECT * FROM OPENROWSET(
   BULK 'C:\Users\temp.user\Desktop\Dissertation\Ethereum_Data\Block_Info\00_Raw_Data\01_0-250,000\Block_Info_0_49_.csv',
   SINGLE_CLOB) AS DATA;

;HDR=NO


EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO

EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1   
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParam', 1


regsvr32 C:\Windows\SysWOW64\msexcl40.dll


SELECT top 10000 *
into blocks_750k_2
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Text;Database=C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\Dissertation_Data\01_Consolidated',
'SELECT * FROM [Consolidated_2750000_2999999.csv]') 

select day(blk.[data#time]) as [day],avg(CAST(blk.[data#blockTime] as float)) as [avg_time]
from dbo.blocks_750k_2 blk
group by day(blk.[data#time])

