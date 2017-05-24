/*
Name:			LoadText
Description:	Used to load an input text file

Date:			03-05-2017
*/
IF OBJECT_ID('LoadText', 'P') IS NOT NULL DROP PROCEDURE LoadText
GO

CREATE PROCEDURE LoadText
	@filepath	VARCHAR(MAX)
	,@filename	VARCHAR(MAX)
	,@table		VARCHAR(MAX) = ''
	,@action	VARCHAR(20) = 'SELECT'
AS

DECLARE @sql_buffer		VARCHAR(MAX) = '';
DECLARE @updated_path	VARCHAR(MAX) = dbo.ReplaceSlash(@filepath);
DECLARE @schema			VARCHAR(50) = dbo.SplitTableName(@table,1);
DECLARE @table_name		VARCHAR(50) = dbo.SplitTableName(@table,2);
DECLARE @insert_list	VARCHAR(MAX) = dbo.BuildLoadInsert(@schema,@table_name)

-- If @schema is 'control_table', truncate the table before insert
IF @schema = 'control_table' AND @action = 'INSERT'
	BEGIN
		SET @sql_buffer = 'TRUNCATE TABLE ' + @table
		EXEC(@sql_buffer)
	END

-- If @action is to Insert, add an INSERT INTO
IF @action = 'INSERT' OR @action = 'PRINT'
	BEGIN
		IF @insert_list <> 'Nothing'
			SET @sql_buffer = 'INSERT INTO ' + @table + '(' + @insert_list + ')'
		ELSE
			SET @sql_buffer = 'INSERT INTO ' + @table
	END

-- Write @sql_buffer
SET @sql_buffer =
	@sql_buffer + '
	SELECT
	' + dbo.BuildLoadSelect(@schema,@table_name) + '
	-- SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
		''Text;Database=' + @updated_path + ''',
		''SELECT * FROM [' + @filename + ']'') a
	'

-- Execute buffer
IF @action = 'PRINT'
	SELECT @sql_buffer
ELSE
	EXEC(@sql_buffer)

GO 