if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessWFBExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessWFBExtract]
GO

CREATE Procedure dbo.JobProcessWFBExtract
as
--******************************************************************************
--Procedure insert US only Records Dinning check to DCHK_HRecord, DCHK_Precord, DCHK_Trecord tables
--******************************************************************************

SET NOCOUNT ON
Declare @FileControlNumber int
		,@FileDate datetime
		,@TransactionID int

declare @ErrorMsg as nvarchar(1000)

Begin Transaction

set @ErrorMsg = 'Previous DCHK export batch did not process'

if exists(select * from DCHK_HRecord where export = 0) --Only allow 1 header
	goto error

	set @ErrorMsg = 'Unable insert records to DCHK_HRecord'
	--Create Header record
	insert into DCHK_HRecord(FileDate)
	values (getdate())

if @@ERROR <> 0
	goto error

	--Create Payment record
	select @FileControlNumber=FileControlNumber, @FileDate=fileDate 
	from DCHK_HRecord where export = 0 

if @@ERROR <> 0
	goto error

set @ErrorMsg = 'Unable insert payment records to DCHK_PRecord'

	INSERT INTO DCHK_PRecord
				([FileControlNumber]  --From DCHK_HRecord
			   ,[EffectiveDate]		 -- Same date as DCHK_HRecord
			   ,[PaymentAmt]		 --giftredemption.GiftAttributes
			   ,[GiftRedemptionID]		 --giftRedeemptionID
			   ,[ReceivingPartyAddName]
			   ,[ReceivingPartyID]
			   ,[ReceivingPartyAddress1]
			   ,[ReceivingPartyAddress2]
			   ,[RecivingPartyCity]
			   ,[ReceivingPartyState]
			   ,[ReceivingPartyZip]
			   ,[OTEmailAddress]
			   ,[OTRedemptionDT]
			   ,[OTPoints])
	select 
		@FileControlNumber, 
		@FileDate, 
		cast(replace(G.GiftAttributes,'$','')as decimal),
		G.giftRedemptionID,
		left(G.FName+' '+ G.LName, 60), 
		coalesce(G.CustID,G.CallerID), 
		left(coalesce(G.Address1, ' '),55),
		left(coalesce(G.Address2, ' '),55), 
		left(G.City,30), 
		Left(G.State, 3), 	
		left(replace(G.postalCode,'-',''),9),
		Left(G.Email,150),
		G.RedemptionDate,
		G.PointsRedeemed
		from CheckRedemptionVW G
	where country='US' and extracted = 0
	and RCode =0 

if @@ERROR <> 0
	goto error

set @ErrorMsg = 'Unable insert payment records to DCHK_CAN_PRecord'

	INSERT INTO DCHK_PCADRecord
				([FileControlNumber]  --From DCHK_CAN_PRecord
			   ,[EffectiveDate]		 -- Same date as DCHK_CAN_PRecord
			   ,[PaymentAmt]		 --giftredemption.GiftAttributes
			   ,[GiftRedemptionID]		 --giftRedeemptionID
			   ,[ReceivingPartyAddName]
			   ,[ReceivingPartyID]
			   ,[ReceivingPartyAddress1]
			   ,[ReceivingPartyAddress2]
			   ,[RecivingPartyCity]
			   ,[ReceivingPartyState]
			   ,[ReceivingPartyZip]
			   ,[OTEmailAddress]
			   ,[OTRedemptionDT]
			   ,[OTPoints])
	select 
		@FileControlNumber, 
		@FileDate, 
		cast(replace(G.GiftAttributes,'$','')as decimal),
		G.giftRedemptionID,
		left(G.FName+' '+ G.LName, 60), 
		coalesce(G.CustID,G.CallerID), 
		left(coalesce(G.Address1, ' '),55),
		left(coalesce(G.Address2, ' '),55), 
		left(G.City,30), 
		Left(G.State, 3), 	
		left(replace(G.postalCode,'-',''),9),
		Left(G.Email,150),
		G.RedemptionDate,
		G.PointsRedeemed
		from CheckRedemptionVW G
	where country='CA' and extracted = 0
	and RCode =0

if @@ERROR <> 0
	goto error

set @ErrorMsg = 'Unable insert Trailer records to DCHK_TRecord'

	--Create Trailer record
	insert into DCHK_TRecord
	(FileControlNumber, PaymentCount, PaymentAmount)
	select @fileControlNumber, count(*), sum(PaymentAmt) 
	from ((select * from dbo.DCHK_PRecord) union all 
	(select * from dbo.DCHK_PCADRecord))x
	where FileControlNumber =@fileControlNumber

if @@ERROR <> 0
	goto error


Commit Transaction
--If all is well...
Return(0)

error:
   	ROLLBACK TRAN
	exec DNErrorAdd 888, 'JobProcessWFBExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)

GO

GRANT EXECUTE ON [JobProcessWFBExtract] TO ExecuteOnlyRole

GO





