/*
Name:			ConvertHexadecimal
Description:	Used to convert a hexadecimal to a string

Date:			08-05-2017
*/
IF OBJECT_ID('ConvertHexadecimal', 'FN') IS NOT NULL DROP FUNCTION ConvertHexadecimal
GO

CREATE FUNCTION ConvertHexadecimal(
	@string		VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @output		VARCHAR(MAX);

	SET @output =	CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX),@string, 1))
					
	RETURN @output

END
GO