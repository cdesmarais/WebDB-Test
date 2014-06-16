
  
if exists (select * FROM dbo.sysobjects where id = object_id(N'[dbo].[Admin_Referrer_Update1]') 
	and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[Admin_Referrer_Update1]
go

/*
	This stored procedure updates an existing Referrer entry in Referrer table with Referrer Id = Referrer_ID
	Input: Referrer_ID, Name, SuppressAlternative, ReportingSourceID, ReportingDisplayName, Notes
*/
  
create procedure dbo.Admin_Referrer_Update1
 (  
  @Referrer_ID int
  , @Name nvarchar(255)
  , @SuppressAlternative int
  , @ReportingSourceTypeID int
  , @ReportingDisplayName nvarchar(256)
  , @Notes nvarchar(500)
 )  
As   
SET NOCOUNT ON
update Referrer  
set 
	ReferrerName = @Name  
	, SuppressAlternative = @SuppressAlternative  
	, ReportingSourceTypeID = @ReportingSourceTypeID
	, ReportingDisplayName = @ReportingDisplayName
	, Notes = @Notes
where 
	ReferrerID =  @Referrer_ID  

go

grant execute on Admin_Referrer_Update1 to ExecuteOnlyRole

go

