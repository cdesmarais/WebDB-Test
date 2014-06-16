if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessi18nCheckExtractToExcel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessi18nCheckExtractToExcel]
GO

CREATE Procedure dbo.JobProcessi18nCheckExtractToExcel
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
		SFname,
		SLname,
		email, 
		Address1, 
		Address2, 
		City, 
		State, 
		postalCode, 
		Country,
		DateAdd(MINUTE, tz.ServerToLocalOffsetMi, RedemptionDate)as RedemptionDate, 
		GiftAttributes, 
		PointsRedeemed,
		PhoneNumberCountryCode,
		PhoneNumber,
		MobileNumberCountryCode,
		MobileNumber,
		CustomerType,
		CustomerTypeDesc
from CheckRedemption_i18n_VW c
inner join MetroArea m on c.MetroAreaID = m.MetroAreaID
inner join TimeZoneVW tz on m.TZID = tz.TZID
where extracted = 0
and RCode =0

if @@ERROR <> 0 goto error
--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessi18nCheckExtractToExcel', @ErrorMsg, 1	
	raisError ('throw error',15, 1)


GO

GRANT EXECUTE ON [JobProcessi18nCheckExtractToExcel] TO ExecuteOnlyRole

GO
