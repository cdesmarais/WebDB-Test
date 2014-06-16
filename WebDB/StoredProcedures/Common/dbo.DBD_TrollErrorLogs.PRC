if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_TrollErrorLogs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_TrollErrorLogs]
GO



CREATE PROCEDURE dbo.DBD_TrollErrorLogs
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--**************************************************************************
--**DBD_TrollErrorLogs: Proc identifies top occuring exception per class::function
--**************************************************************************

--**********
--** since ErrorLog isn't indexed; work backward in 100k chunks to find a good starting point
--** Use ErrorLogID (primary key) as the index for all querries
--**********
declare @ErrorLogID int
select @ErrorLogID = max(ErrorLogID) - 100000 from ErrorLog
while exists(select ErrorLogID from ErrorLog where ErrorLogID = @ErrorLogID and errTimeStamp > getdate()-7 )
begin
	set @ErrorLogID = @ErrorLogID - 100000
end


Insert Into ErrorLogSummary (TypeCount,ErrorType,TopErrorCount,TopError, DateLogged)
(
Select TypeCount, 
	ErrorType, 
	(Select top 1 count(*) from errorlog el2 
		where ErrorLogID >= @ErrorLogID
			and el2.ErrMsg like el.ErrorType + '%'
			and errTimeStamp >= getdate()-7
		group by cast(el2.ErrMsg as nvarchar(4000))
		order by count(*) desc) as TopErrorCount,
	(Select top 1  cast(el2.ErrMsg as nvarchar(4000)) from errorlog el2 
		where ErrorLogID >= @ErrorLogID		
			and el2.ErrMsg like el.ErrorType  + '%'
			and errTimeStamp >= getdate()-7
		group by cast(el2.ErrMsg as nvarchar(4000))
		order by count(*) desc) as TopError,  
	getdate() as DateLogged
from (
	--**** Get Set of records by type (first "word of message" most messages are class::function<space>) 
	select count(1) TypeCount, 
		substring(cast(ErrMsg as nvarchar(100)), 0, charindex(' ', cast(ErrMsg as nvarchar(100)))) as ErrorType
	 from errorlog 
	where ErrorLogID >= @ErrorLogID		
		and errTimeStamp >= getdate()-7
	group by substring(cast(ErrMsg as nvarchar(100)), 0, charindex(' ', cast(ErrMsg as nvarchar(100))))
	having count(*) > 100
) el

)
GO

GRANT EXECUTE ON [DBD_TrollErrorLogs] TO ExecuteOnlyRole

GO
