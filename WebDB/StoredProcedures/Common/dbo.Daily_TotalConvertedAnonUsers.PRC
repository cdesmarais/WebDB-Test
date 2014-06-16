if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalConvertedAnonUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalConvertedAnonUsers]
GO





CREATE  PROCEDURE dbo.Daily_TotalConvertedAnonUsers

@strDateOffset 		int = 1

AS


SELECT SUM(Converted_Yesterday) AS Converted_Yesterday,SUM(Converted_Total) AS Converted_Total
FROM 	(
	--Get Yesterdday's Anonymous Conversions
	SELECT COUNT(ConsumerType_Convert_Log_ID) AS Converted_Yesterday,0 AS Converted_Total
	FROM ConsumerType_Convert_Log
	WHERE Original_ConsumerType_ID = 8 AND
		DATEDIFF(d,Convert_Date,getdate()) = @strDateoffset
	
	UNION

	--Get Total Anonymous Conversions
	SELECT 0 AS Converted_Yesterday,
		COUNT(ConsumerType_Convert_Log_ID) AS Converted_Total
	FROM ConsumerType_Convert_Log
	WHERE Original_ConsumerType_ID = 8 AND
		DATEDIFF(d,Convert_Date,getdate()) >= @strDateoffset
	) AS tempdb1

RETURN





GO

GRANT EXECUTE ON [Daily_TotalConvertedAnonUsers] TO ExecuteOnlyRole

GO
