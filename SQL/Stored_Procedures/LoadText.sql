/*
Name:			LoadText
Description:	Used to load an input text file

Date:			03-05-2017
*/
IF OBJECT_ID('LoadText', 'P') IS NOT NULL DROP PROCEDURE LoadText
GO

CREATE PROCEDURE LoadText
	@filepath	NVARCHAR(MAX)
	,@filename	NVARCHAR(MAX)
	,@table		NVARCHAR(MAX) = ''
AS

DECLARE @sql_buffer		NVARCHAR(MAX) = '';
DECLARE @updated_path	NVARCHAR(MAX) = dbo.ReplaceSlash(@filepath);

-- If @table is not blank, add an INSERT INTO
IF @table <> ''
	BEGIN
		SET @sql_buffer = 'INSERT INTO ' + @table
	END

-- Write @sql_buffer
SET @sql_buffer =
	@sql_buffer + '
	SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
		''Text;Database=' + @updated_path + ''',
		''SELECT * FROM [' + @filename + ']'')
	'

-- Execute buffer
--PRINT(@sql_buffer)
EXEC(@sql_buffer)

GO 