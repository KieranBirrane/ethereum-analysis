/*
Name:			BuildLoadSelect
Description:	Used to build up the SELECT statement for a load

Date:			08-05-2017
*/
IF OBJECT_ID('BuildLoadSelect', 'FN') IS NOT NULL DROP FUNCTION BuildLoadSelect
GO

CREATE FUNCTION BuildLoadSelect(
	@schema		VARCHAR(20)
	,@table		VARCHAR(50)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql_path		VARCHAR(MAX);

	IF EXISTS(SELECT * FROM control_table.Data_Definition dd WHERE dd.[INCLUDE_COLUMN] = 'Y' AND dd.[TABLE_SCHEMA] = @schema AND dd.[TABLE_NAME] = @table)
		BEGIN
			SELECT @sql_path =	COALESCE(@sql_path + CHAR(13) + CHAR(10) + CHAR(9) + ',','') + 
								CASE
								WHEN dd.[DATA_TYPE] = 'nvarchar' AND [OUTPUT_DATA_TYPE] = 'varchar' THEN
									'CAST(a.[' + dd.[COLUMN_NAME] + '] AS ' + dd.[OUTPUT_DATA_TYPE] + '(' + dd.[OUTPUT_DATA_TYPE_PRECISION] + ')) AS [' + dd.[OUTPUT_COLUMN_NAME] + ']'

								WHEN [DATA_TYPE] = 'float' AND [OUTPUT_DATA_TYPE] IN ('int','bigint') THEN
									'CAST(a.[' + dd.[COLUMN_NAME] + '] AS ' + dd.[OUTPUT_DATA_TYPE] + ') AS [' + dd.[OUTPUT_COLUMN_NAME] + ']'

								WHEN [DATA_TYPE] = 'float' AND [OUTPUT_DATA_TYPE] = 'superint' THEN
									'CAST(CAST(a.[' + dd.[COLUMN_NAME] + '] AS FLOAT) AS DECIMAL(24,0)) AS [' + dd.[OUTPUT_COLUMN_NAME] + ']'

								WHEN [DATA_TYPE] = 'float' AND [OUTPUT_DATA_TYPE] = 'superbigint' THEN
									'CAST(CAST(a.[' + dd.[COLUMN_NAME] + '] AS FLOAT) AS DECIMAL(38,0)) AS [' + dd.[OUTPUT_COLUMN_NAME] + ']'

								WHEN [DATA_TYPE] = 'float' AND [OUTPUT_DATA_TYPE] = 'varchar' THEN
									'CAST(CAST(a.[' + dd.[COLUMN_NAME] + '] AS BIGINT) AS ' + dd.[OUTPUT_DATA_TYPE] + '(' + dd.[OUTPUT_DATA_TYPE_PRECISION] + ')) AS [' + dd.[OUTPUT_COLUMN_NAME] + ']'

								WHEN [DATA_TYPE] = [OUTPUT_DATA_TYPE] THEN
									'a.[' + [COLUMN_NAME] + '] AS [' + dd.[OUTPUT_COLUMN_NAME] + ']'

								ELSE
									'a.[' + [COLUMN_NAME] + ']'
								END
								-- SELECT *
								FROM control_table.Data_Definition dd
								WHERE 1=1
								AND dd.[INCLUDE_COLUMN] = 'Y'
								AND dd.[TABLE_SCHEMA] = @schema
								AND dd.[TABLE_NAME] = @table
								ORDER BY dd.[ORDINAL_POSITION]
		END
	ELSE
		BEGIN
			SELECT @sql_path = 'a.*'
		END

	RETURN @sql_path

END
GO