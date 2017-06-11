/*
Name:			SplitString
Description:	Used to split a string up by a delimiter

Date:			31-05-2017

Retrieved from:
https://stackoverflow.com/questions/2647/how-do-i-split-a-string-so-i-can-access-item-x
*/
IF OBJECT_ID('SplitString', 'TF') IS NOT NULL DROP FUNCTION SplitString
GO

CREATE FUNCTION SplitString(
	@string		VARCHAR(MAX)
	,@delim		VARCHAR(5)
)
RETURNS @temptable TABLE
(
	[Items]		VARCHAR(MAX)
)       
AS       
BEGIN

	DECLARE @idx		INT = 1;
	DECLARE @slice		VARCHAR(MAX);

	SET @string = LTRIM(RTRIM(@string))
	IF LEN(@string)<1 OR @string IS NULL	RETURN


	WHILE @idx != 0
    BEGIN       
		SET @idx = CHARINDEX(@delim,@string)
		IF @idx!=0       
			SET @slice = LEFT(@String,@idx - 1)
		ELSE
			SET @slice = @string

		IF(LEN(@slice)>0)
			INSERT INTO @temptable([Items]) VALUES(@slice)

		SET @string = RIGHT(@string,LEN(@string)-@idx)       
		IF LEN(@string) = 0 BREAK       
    END

    RETURN       
END
GO