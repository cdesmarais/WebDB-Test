if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantMessageAndType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantMessageAndType]
GO

CREATE PROCEDURE dbo.DNGetRestaurantMessageAndType
(@RID int
,@MessageTypeID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--**********************
--** Get Language
--**********************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

if exists (select 1 from RestaurantCustomMessage where rid = @RID and MessageTypeID = @MessageTypeID and LanguageID = @LanguageID)
	select Message,'1' as Custom from RestaurantCustomMessage where rid = @RID and MessageTypeID = @MessageTypeID and LanguageID = @LanguageID
else
	BEGIN	

	/*Try to only retrieve information that is needed!
	1	IsBlockedDay
	2	UnableToConnect
	3	PartySizeTooSmall
	4	PartySizeTooBig
	5	AfterCutoff
	6	TooFarInAdvance
	7	NotFarEnoughInAdvance
	8	LeadTimeNotOK
	9	NoTimesMessage
	10	Confirmation
	11	CreditCard
	12	LargeParty
	*/
	

	declare 
	@RName nvarchar (255)
	,@MinPartySize nvarchar(25)
	,@MaxPartySize nvarchar(25)
	,@MaxDaysAdvance nvarchar(25)
	,@CutoffTime datetime

	select @RName = rname
			,@MinPartySize = minon.MinOnlineOption
			,@MaxPartySize = maxon.MaxOnlineOption
			,@MaxDaysAdvance = maxad.MaxAdvanceOption
			,@CutoffTime = '4pm'
	from		RestaurantAVW rest
	inner join	MinOnlineOption minon
	on			rest.MinOnlineOptionID = minon.MinOnlineOptionID
	inner join	MaxOnlineOption maxon
	on			rest.MaxOnlineOptionID = maxon.MaxOnlineOptionID
	inner join	MaxAdvanceOption maxad
	on			rest.MaxAdvanceOptionID = maxad.MaxAdvanceOptionID
	where		rest.RID = @RID
	and			rest.LanguageID = @LanguageID
	
 	select 	
			Replace(
				Replace(
					Replace(
						Replace(
							Replace(Message,'[RestaurantName]',@RName)
						,'[MinOnline]',@MinPartySize) 
					,'[MaxOnline]',@MaxPartySize)
				,'[MaxAdvance]',@MaxDaysAdvance)
			,'[CutoffTime]',@CutoffTime) as Message
			,'0' as Custom 
	from	DefaultMessage 
	where	MessageTypeID = @MessageTypeID
	and		LanguageID = @LanguageID

	END
GO

GRANT EXECUTE ON [DNGetRestaurantMessageAndType] TO ExecuteOnlyRole

GO
