if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessWFB_PExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessWFB_PExtract]
GO

CREATE Procedure dbo.JobProcessWFB_PExtract
as
--******************************************************************************
--Procedure export US only Payment Records flat file
--******************************************************************************

SET NOCOUNT ON

Declare @FileControlNumber int
		,@FileDate datetime
		,@TransactionID int

declare @ErrorMsg as nvarchar(1000)

set @ErrorMsg = 'Failed to select WFB Payment Records'

if (select count(*) from DCHK_HRecord where export = 0) <>1 --must only have 1 filecontrol number
	goto error

select @FileControlNumber=FileControlNumber 
from DCHK_HRecord where export = 0 


SELECT [RecordID]
      ,[PaymentMethod]
      ,[CreditFlag]
      ,[TransactionID]
      ,CONVERT(CHAR(10), [EffectiveDate], 23) EffectiveDate
      ,[PaymentAmt]
      ,[Currency]
      ,[FXContractNumber]
      ,[OrigPartyName]
      ,[OrigPartyAddName]
      ,[OrigPartyID]
      ,[OrigPartyAddress1]
      ,[OrigPartyAddress2]
      ,[OrigPartyCity]
      ,[OrigPartyState]
      ,[OrigPartyZip]
      ,[OrigPartyCountry]
      ,[OrigPartyCountryName]
      ,[OrigBankName]
      ,[OrigBankAddress]
      ,[OrigBankCity]
      ,[OrigBankState]
      ,[OrigBankZip]
      ,[OrigBankCountryCode]
      ,[OrigAcctType]
      ,[OrigAcct]
      ,[OrigAcctCurrency]
      ,[OrigBankIDType]
      ,[OrigBankID]
      ,[ReceivingPartyName]
      ,[ReceivingPartyAddName]
      ,[ReceivingPartyID]
      ,[ReceivingPartyAddress1]
      ,[ReceivingPartyAddress2]
      ,[RecivingPartyCity]
      ,[ReceivingPartyState]
      ,[ReceivingPartyZip]
      ,[ReceivingPartyCountryCode]
      ,[ReceivingPartyCountryNM]
      ,[ReceivingBankName]
      ,[ReceivingBankAddress]
      ,[ReceivingBankCity]
      ,[ReceivingBankState]
      ,[ReceivingBankZip]
      ,[ReceivingBankCountryCode]
      ,[ReceivingPartyAcctType]
      ,[ReceivingPartyAcct]
      ,[ReceivingAcctCurrency]
	  ,[ReceivingBankPrimaryIDType]
      ,[ReceivingBankPrimaryID]
      ,[ReceivingBankSecID]
      ,[IntermediateBankName]
      ,[IntermediateBankAddress]
      ,[IntermediateBankCity]
      ,[IntermediateBankState]
      ,[IntermediateBankZip]
      ,[IntermediateCountryCode]
      ,[IntermediateBankIDtype]
      ,[IntermediateBankID]
      ,[SecIntermediateBankName]
      ,[secIntermediateBankAddress]
      ,[secIntermediateBankCity]
      ,[secIntermediateBankState]
      ,[secIntermediateBankZip]
      ,[secIntermediateBankCountry]
      ,[secIntermediateBankBankIDType]
      ,[secIntermediateBankID]
      ,[OrderPartyName]
      ,[OrderPartyID]
      ,[OrderPartyAddress1]
      ,[OrderPartyAddress2]
      ,[OrderPartyCity]
      ,[OrderPartyState]
      ,[OrderPartyPostalCode]
      ,[OrderPartyCountryCode]
      ,[OrderPartyCountryName]
      ,[OrigPartyToReceivePartyInfo]
      ,[BankToBankInfo]
      ,[ACHFormatCode]
      ,[ACHIntlTypeCode]
      ,[ACHCompanyID]
      ,[CheckNumber]
      ,[DocumentTemplateNumber]
      ,[EDDBillerID]
      ,[EDDFileFormat]
      ,[EDDDeliveryType]
      ,[EDDDeliveryContactNM]
      ,[EDDDeliveryFaxNumber]
      ,[EDDDeliveryEmailAddress]
      ,[EDDDeliveryUserID]
      ,[EDDDeliveryCompanyID]
      ,[SDDSecureType]
      ,[SDDSecureQuestion1]
      ,[SDDSecurePassword1]
      ,[SDDSecureQuestion2]
      ,[SDDSecurePassword2]
      ,[EDDHandlingCode]
      ,[CEOTemplateID]
      ,[BatachID]
      ,[OperatorID]
      ,[CEOcompanyID]
      ,[EndofRecord]
  FROM [DCHK_PRecord]
where FileControlNumber=@FileControlNumber
		
if @@ERROR <> 0
	goto error

--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessWFBExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)

GO

GRANT EXECUTE ON [JobProcessWFB_PExtract] TO ExecuteOnlyRole

GO





