/*
Name:			BuildLoadInsert
Description:	Used to build up the INSERT statement for a load

Date:			08-05-2017
*/
IF OBJECT_ID('BuildLoadInsert', 'FN') IS NOT NULL DROP FUNCTION BuildLoadInsert
GO

CREATE FUNCTION BuildLoadInsert(
	@schema		VARCHAR(20)
	,@table		VARCHAR(50)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @sql_path		VARCHAR(MAX);

	IF EXISTS(SELECT * FROM control_table.Data_Definition dd WHERE dd.[INCLUDE_COLUMN] = 'Y' AND dd.[TABLE_SCHEMA] = @schema AND dd.[TABLE_NAME] = @table)
		BEGIN
			SELECT @sql_path =	COALESCE(@sql_path + CHAR(13) + CHAR(10) + CHAR(9) + ',','') + '[' + dd.[OUTPUT_COLUMN_NAME] + ']'
								-- SELECT *
								FROM control_table.Data_Definition dd
								WHERE 1=1
								AND dd.[INCLUDE_COLUMN] = 'Y'
								AND dd.[TABLE_SCHEMA] = @schema
								AND dd.[TABLE_NAME] = @table
								ORDER BY dd.[ORDINAL_POSITION]
			SELECT @sql_path = SUBSTRING(@sql_path, 1, LEN(@sql_path))
		END
	ELSE
		BEGIN
			SELECT @sql_path = 'Nothing'
		END

	RETURN @sql_path

END
GO