if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessExceptionCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessExceptionCheckExtract]
GO

CREATE Procedure dbo.JobProcessExceptionCheckExtract
as
--******************************************************************************
--Procedure select non-US check from CheckRedemptionDTS table and export to flat files
--******************************************************************************

SET NOCOUNT ON

declare @ErrorMsg as nvarchar(1000)
declare @FileControlNumber as int
set @ErrorMsg = 'Unable to select data from ExceptionCheckExtract '

update valuelookup 
	   set valueInt = valueInt + 
					(select	count(*)
					from CheckRedemptionVW
					where extracted = 0
					and CheckRedemptionVW.RCode <>0)
where LKey='DiningCHKBatchFinalCount'

if @@ERROR <> 0 goto error

declare @MaxGiftRedemptionID as int
select @MaxGiftRedemptionID=ValueInt from  valuelookup where LType = 'DATABASE' and LKey = 'DiningCheckExtract'


select	@MaxGiftRedemptionID MaxGiftRedemptionID,
		GiftRedemptionID,
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
		PointsRedeemed,
		RC.Reason
from CheckRedemptionVW
inner join DCHK_RCode RC
on CheckRedemptionVW.RCode= RC.Rcode
where extracted = 0
and CheckRedemptionVW.RCode <>0

if @@ERROR <> 0 goto error
--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessExceptionCheckExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)


GO

GRANT EXECUTE ON [JobProcessExceptionCheckExtract] TO ExecuteOnlyRole

GO






