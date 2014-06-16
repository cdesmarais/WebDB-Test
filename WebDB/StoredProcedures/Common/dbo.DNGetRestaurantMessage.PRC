if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantMessage]
GO

CREATE PROCEDURE dbo.DNGetRestaurantMessage
(@RID int
,@MessageTypeID int
,@CannedMsg nvarchar(500) OUTPUT
,@ResDate datetime = NULL
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
set @CannedMsg = (select Message from RestaurantCustomMessage where rid = @RID and MessageTypeID = @MessageTypeID and LanguageID = @LanguageID)
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
	,@CutoffTime nvarchar(25)
	,@CancelLimitDate datetime
	,@dt2 nvarchar(25)
	
	Set @CutoffTime = '4pm'

set @CancelLimitDate = dateadd(dd,-2,@Resdate)

set @dt2 = (select datename(m,@CancelLimitDate)+' '+cast(datepart(dd,@CancelLimitDate) as char(2))+' ,'+cast(datepart(yy,@CancelLimitDate) as char(4)))


	-- Used to Process Cutoff Times
	if @MessageTypeID = 5
	BEGIN
		select top 1 @CutoffTime = convert(nvarchar(8),right(ResCutoffTime,7))
		from ShiftTemplate st 
		inner join ScheduleShifts ss  
		ON ss.ShiftTemplateID = st.ShiftTemplateID
		where ss.RID = @RID 
		and ss.shiftID = 2
		and CutoffActive = 1 
		and Active = 1
	END


select @RName = rname
	,@MinPartySize = minon.MinValue
	,@MaxPartySize = maxon.MaxValue
	,@MaxDaysAdvance = maxad.MaxAdvanceOption
	from RestaurantVW rest
	inner join MinOnlineOption minon
	on	rest.MinOnlineOptionID = minon.MinOnlineOptionID
	inner join MaxOnlineOption maxon
	on	rest.MaxOnlineOptionID = maxon.MaxOnlineOptionID
	inner join MaxAdvanceOption maxad
	on	rest.MaxAdvanceOptionID = maxad.MaxAdvanceOptionID
	where rest.RID = @RID
	
set @CannedMsg = (	 	select 	
		Replace(
			Replace(
				Replace(
					Replace(
					Replace(
						Replace(Message,'[RestaurantName]',@RName)
					,'[CancelLimitDate]',@dt2)
					,'[MinOnline]',@MinPartySize) 
				,'[MaxOnline]',@MaxPartySize)
			,'[MaxAdvance]',@MaxDaysAdvance)
		,'[CutoffTime]',@CutoffTime)
	from DefaultMessage 
	where MessageTypeID = @MessageTypeID
	and LanguageID = @LanguageID)

	END
GO

GRANT EXECUTE ON [DNGetRestaurantMessage] TO ExecuteOnlyRole

GO
