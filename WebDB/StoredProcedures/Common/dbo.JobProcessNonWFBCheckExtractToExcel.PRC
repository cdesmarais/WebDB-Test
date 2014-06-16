if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessNonWFBCheckExtractToExcel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessNonWFBCheckExtractToExcel]
GO

CREATE Procedure dbo.JobProcessNonWFBCheckExtractToExcel
as
--******************************************************************************
--Procedure select non-US check from CheckRedemptionDTS table and export to flat files
--******************************************************************************

SET NOCOUNT ON

declare @ErrorMsg as nvarchar(1000)
set @ErrorMsg = 'Unable to select data from CheckRedemptionDTS '

select	GiftRedemptionID,
		coalesce(CustID,CallerID) UserID, 
		Fname, 
		Lname,
		email, 
		Address1, 
		Address2, 
		City, 
		State, 
		postalCode, 
		Country,
		RedemptionDate, 
		GiftAttributes, 
		PointsRedeemed
from CheckRedemptionVW
where country<>'US' and country<>'CA'  and extracted = 0
and RCode =0

if @@ERROR <> 0 goto error
--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessNonWFBCheckExtractToExcel', @ErrorMsg, 1	
	raisError ('throw error',15, 1)


GO

GRANT EXECUTE ON [JobProcessNonWFBCheckExtractToExcel] TO ExecuteOnlyRole

GO





