if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportReferrerEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportReferrerEmail] 
GO

create  Procedure [dbo].[JobReportReferrerEmail]  	
AS

	set transaction isolation level read UNCOMMITTED	
	
	declare @startDT datetime
	declare @endDT datetime
	
	select @endDT = DATEADD(day, 0, convert(datetime, convert(varchar(8), getdate(), 112)))  
	select @startDT = dateadd(day, -7, @endDT)

	
	SELECT		cu.FName AS FirstName
			,cu.LName AS LastName
			,cu.Email 
			,re.ReferrerID 
			,re.LastUpdated as DateOptIn
	from		ReferrerCustomerEmail re
	inner join	customer cu
	on		re.custID = cu.custID	
	where		re.LastUpdated between @startDT and @endDT
	UNION ALL
	SELECT		ca.FName AS FirstName
			,ca.LName AS LastName
			,ca.Email	
			,re.ReferrerID	
			,re.LastUpdated as DateOptIn
	from		ReferrerCustomerEmail re
	inner join	caller ca
	on		re.callerID = ca.callerID
	where		re.LastUpdated between @startDT and @endDT
	ORDER BY	re.LastUpdated
	

GO


GRANT EXECUTE ON [JobReportReferrerEmail] TO ExecuteOnlyRole

GRANT EXECUTE ON [JobReportReferrerEmail] TO DTR_User


GO
