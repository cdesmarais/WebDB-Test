if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_AnonUser_Conversions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_AnonUser_Conversions]
GO





CREATE PROCEDURE dbo.Daily_AnonUser_Conversions
(
@rptID int,
@strDateOffset 		int = 1
)
AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @Converted_Yesterday int
declare @Converted_Total int

	--Get Yesterdday's Anonymous Conversions
	SELECT @Converted_Yesterday = COUNT(ConsumerTypeConvertLogID)
	FROM ConsumerTypeConvertLog
	WHERE OriginalConsumerTypeID = 8 AND
		DATEDIFF(d,ConvertDate,getdate()) = @strDateoffset
	
	--Get Total Anonymous Conversions
	SELECT @Converted_Total = COUNT(ConsumerTypeConvertLogID)
	FROM ConsumerTypeConvertLog
	WHERE OriginalConsumerTypeID = 8 AND
		DATEDIFF(d,ConvertDate,getdate()) >= @strDateoffset


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Anonymous User conversions (yesterday/total) : ' + cast(@Converted_Yesterday as nvarchar(20)) 
				+ '/' + cast(@Converted_Total as nvarchar(20)) 
				+ @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)


GO

GRANT EXECUTE ON [Daily_AnonUser_Conversions] TO ExecuteOnlyRole

GO
