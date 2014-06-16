

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Referrer_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Referrer_List]
GO

/*
	This stored procedure returns Referrer details for all referrers or 1 referrer based on value of Referrer_ID parameter.
	If Referrer_ID = 0, returns all referrer details
	If Referrer_ID <> 0, returns referrer details of ReferrerID = Referrer_ID
*/

CREATE PROCEDURE dbo.Admin_Referrer_List
(
  @Referrer_ID int = 0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF @Referrer_ID = 0
  BEGIN
  --Return all Referrer details
    SELECT 
		ref.ReferrerID AS ReferrerID
		, ref.ReferrerName as Name
		, ref.SuppressAlternative
		, ref.ReportingSourceTypeID
		, reptype.ReportingSource
		, ref.ReportingDisplayName
		, ref.Notes
	FROM 
		Referrer AS ref
		
	LEFT OUTER JOIN ReportingSourceType As reptype
		ON reptype.ReportingSourceTypeID = ref.ReportingSourceTypeID
		
	Order by 
		ref.ReferrerID  
		
  END
IF @Referrer_ID <> 0
  BEGIN
  --Return Referrer details for ReferrerID = @Referrer_ID
    SELECT 
		ref.ReferrerName as Name
		, ref.SuppressAlternative
		, ref.ReportingSourceTypeID
		, reptype.ReportingSource
		, ref.ReportingDisplayName
		, ref.Notes
	FROM 
		Referrer As ref
	LEFT OUTER JOIN ReportingSourceType As reptype
		ON reptype.ReportingSourceTypeID = ref.ReportingSourceTypeID
	WHERE
		ReferrerID = @Referrer_ID
  END

GO

GRANT EXECUTE ON [Admin_Referrer_List] TO ExecuteOnlyRole

GO


