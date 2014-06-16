if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessi18nCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessi18nCheckExtract]
GO

CREATE Procedure dbo.JobProcessi18nCheckExtract
as
--******************************************************************************
--Procedure select check from CheckRedemptionDTS table and export to flat files
--******************************************************************************

SET NOCOUNT ON

declare @ErrorMsg as nvarchar(1000)
set @ErrorMsg = 'Unable to select data from CheckRedemptionDTS '

update valuelookup 
	   set valueInt = coalesce(valueInt + 
					(select	count(*)
					from CheckRedemption_i18n_VW
					where extracted = 0
					and RCode = 0), 0)
where LKey='DiningCHKBatchFinalCount'

if @@ERROR <> 0 goto error

declare @MaxGiftRedemptionID as int
select @MaxGiftRedemptionID=ValueInt from  valuelookup where LType = 'DATABASE' and LKey = 'DiningCheckExtract'


select	@MaxGiftRedemptionID MaxGiftRedemptionID,
		GiftRedemptionID,
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
		RedemptionDate, 
		GiftAttributes, 
		PointsRedeemed,
		PhoneNumberCountryCode,
		PhoneNumber,
		MobileNumberCountryCode,
		MobileNumber,
		CustomerType,
		CustomerTypeDesc
from CheckRedemption_i18n_VW
where extracted = 0
and RCode =0

if @@ERROR <> 0 goto error
--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessi18nCheckExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)


GO

GRANT EXECUTE ON [JobProcessi18nCheckExtract] TO ExecuteOnlyRole

GO





