
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_UpdateCustomDayMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_UpdateCustomDayMessage]
GO

create procedure dbo.Promo_UpdateCustomDayMessage
(
	@HolidayDT DateTime,
	@PromoID int
)
AS

/*
This stored procedure copy over the Restaurant's Promo Message from the Promo
to the Restaurant Date Specific Message field in CHARM for the speicifc date (HolidaDT).

"JobSetupHolidayPromoMsg" read the message configuration for script execution and call this
stored procedure for copy over the Restaurant's promo messages.

Note: This stored procedure is updated by India Team for CHARM (Holiday) Promo Messaging Script.
Please notify asaxena@opentable.com, if changing
*/

SET nocount on 
SET TRANSACTION isolation  LEVEL  READ  uncommitted   

declare @RID int 
declare @Message nvarchar(4000)
declare @DayID int
declare @LanguageID int

declare cur cursor fast_forward for
-- Get RID, Promo messages and filter out the restaurants which are 
-- opted out for promo.
select 
	rid,
	REPLACE(CAST(message as nvarchar(500)),'<br>',' ') as message,
	pp.LanguageID
from
	promorests pr
	inner join PromoPages pp
	on pr.PromoID = pp.PromoID
where
	pr.promoid = @PromoID
	and	REPLACE(CAST(message as nvarchar(4000)),'<br>','') != ''
	and pp.active = 1
	and rid not in (select
						rid
					from 
						PromoMsgExTool_RIDExclusion pmridex
						inner join PromoMsgExTool_DatesConfig pmdc
						on pmridex.PromoMsgID = pmdc.PromoMsgID
					where 
						pmdc.PromoID = @PromoID
					)
open cur

fetch cur into @RID, @Message, @LanguageID

while @@fetch_status = 0
begin
	
	if exists (select DayID from CustomedDay where customeddate = @HolidayDT and RID = @RID)
	begin
		select @Dayid = DayID from CustomedDay where customeddate = @HolidayDT and RID = @RID
		if exists (select LanguageID from CustomedDayLocal where LanguageId = @LanguageID and DayID = @Dayid)
		begin
			update CustomedDayLocal set Message = @Message where LanguageId = @LanguageID and DayID = @Dayid
		end
		else
		begin
			insert into customeddayLocal (
				DayID
				,Message
				,LanguageID
				)
			values( 
				@Dayid 
				,@Message
				,@LanguageID) 
		end
	end
	else
	begin
		insert into [customedDay] (
			[RID]
			,[customedDate]
			,[Datecustomed]
			,[customedBy]
		) values ( 
			/* RID - int */ @RID
			/* customedDate - datetime */ ,@HolidayDT
			/* Datecustomed - datetime */ ,getdate()
			/* customedBy - nvarchar(50) */ ,N'Promo Data Pump' ) 

		set @Dayid = @@Identity

		insert into customeddayLocal (
			DayID
			,Message
			,LanguageID
			)
		values( 
			@Dayid 
			,@Message
			,@LanguageID) 
	end
	fetch cur into @RID, @Message, @LanguageID
end

close cur
deallocate cur


GO

GRANT EXECUTE ON [Promo_UpdateCustomDayMessage] TO ExecuteOnlyRole

GO
