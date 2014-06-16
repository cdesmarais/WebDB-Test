if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_CharityList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_CharityList]
GO






CREATE PROCEDURE dbo.Concierge_CharityList
 (
  @GeoID int
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION

Select CompanyName as Name
,CallerID as Caller_ID
from Company
inner join Caller 
on Company.CompanyID = Caller.CompanyID
where isCharity = 1
and Company.metroareaid = @GeoID
ORDER BY Name

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_CharityList] TO ExecuteOnlyRole

GO
