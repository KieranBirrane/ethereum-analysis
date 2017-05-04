/*
Name:			ReplaceSlash
Description:	Used to change R filepath to SQL filepath

Date:			03-05-2017
*/
IF OBJECT_ID('ReplaceSlash', 'FN') IS NOT NULL DROP FUNCTION ReplaceSlash
GO

CREATE FUNCTION ReplaceSlash(
	@path		NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @sql_path		NVARCHAR(MAX);

	SET @sql_path =	REPLACE(@path, '\\', '\')
					
	RETURN @sql_path

END
GO