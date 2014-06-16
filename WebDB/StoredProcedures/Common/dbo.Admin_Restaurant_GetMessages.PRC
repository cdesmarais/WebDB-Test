

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetMessages]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetMessages
(@RID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare	@LanguageID int,
	@RName nvarchar (255),
	@MinPartySize nvarchar(25),
	@MaxPartySize nvarchar(25),
	@MaxDaysAdvance nvarchar(25),
	@CutoffTime nvarchar(25)

select @RName = rname
	,@MinPartySize = minon.MinOnlineOption
	,@MaxPartySize = maxon.MaxOnlineOption
	,@MaxDaysAdvance = maxad.MaxAdvanceOption
	,@CutoffTime = '4pm'
from		RestaurantAVW rest
inner join	MinOnlineOption minon
on		rest.MinOnlineOptionID = minon.MinOnlineOptionID
inner join	MaxOnlineOption maxon
on		rest.MaxOnlineOptionID = maxon.MaxOnlineOptionID
inner join	MaxAdvanceOption maxad
on		rest.MaxAdvanceOptionID = maxad.MaxAdvanceOptionID
inner join	dbo.DBUserDistinctLanguageVW db 
on			db.languageid = rest.LanguageID
where		rest.RID = @RID

select dm.MessageTypeID,
	Replace(
		Replace(
			Replace(
				Replace(
					Replace(dm.Message,'[RestaurantName]',@RName)
					,'[MinOnline]',@MinPartySize) 
				,'[MaxOnline]',@MaxPartySize)
			,'[MaxAdvance]',@MaxDaysAdvance)
		,'[CutoffTime]',@CutoffTime) as DefaultMessage,
	coalesce((select Message
		from RestaurantCustomMessage rcm
		where dm.languageID = rcm.languageID
		and dm.MessageTypeId = rcm.MessageTypeID
		and rcm.RID = @RID), '') as CustomMessage,
	dm.LanguageID as LanguageID
from DefaultMessage dm
where dm.MessageTypeID in (1,2,3,4,5,6,7,8,9,10,11,12,14,15,16)
order by dm.MessageTypeID
GO

GRANT EXECUTE ON [Admin_Restaurant_GetMessages] TO ExecuteOnlyRole

GO
