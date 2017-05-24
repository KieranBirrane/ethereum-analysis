/*
Name:			SplitTableName
Description:	Used to split a table name into a schema and name

Date:			08-05-2017
*/
IF OBJECT_ID('SplitTableName', 'FN') IS NOT NULL DROP FUNCTION SplitTableName
GO

CREATE FUNCTION SplitTableName(
	@table		NVARCHAR(MAX) = ''
	,@part		INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @return		VARCHAR(50);

	IF @part = 1
		SELECT @return = SUBSTRING(@table, 0, CHARINDEX('.',@table))
	ELSE
		SELECT @return = SUBSTRING(@table, CHARINDEX('.',@table) + 1, len(@table))

	RETURN(@return)

END
GO 