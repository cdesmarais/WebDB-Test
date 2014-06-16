
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSetupHolidayPromoMsg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSetupHolidayPromoMsg]
GO

create procedure dbo.JobSetupHolidayPromoMsg
AS

/*
This stored procedure read promo message configuration and execute Promo_UpdateCustomDayMessage to update
custom day message for restaurants for specific date.

Content owned by India team. Please notify asaxena@opentable.com, if changing.
*/

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET nocount on 
SET TRANSACTION isolation  LEVEL  READ  uncommitted   

declare @PromoID int
declare @DateSpecificMsgDTPST datetime
declare @ScriptStartDTPST datetime
declare @ScriptEndDTPST datetime
declare @CurrentDTPST datetime
set @CurrentDTPST = convert(varchar(10), getdate(), 101)

declare PromoMsgCfg_Cursor cursor fast_forward for
select 
	PromoID
	,ScriptStartDTPST
	,ScriptEndDTPST
	,DateSpecificMsgDTPST
from
	PromoMsgExTool_DatesConfig

open PromoMsgCfg_Cursor

fetch PromoMsgCfg_Cursor into @PromoID, @ScriptStartDTPST, @ScriptEndDTPST, @DateSpecificMsgDTPST

while @@fetch_status = 0
begin
	
	if(@CurrentDTPST >= @ScriptStartDTPST and @CurrentDTPST <= @ScriptEndDTPST)
	begin

		-- Update customday message for specific date.
		exec Promo_UpdateCustomDayMessage  @DateSpecificMsgDTPST, @PromoID

	end
	
fetch PromoMsgCfg_Cursor into @PromoID, @ScriptStartDTPST, @ScriptEndDTPST, @DateSpecificMsgDTPST
end

close PromoMsgCfg_Cursor
deallocate PromoMsgCfg_Cursor

GO

GRANT EXECUTE ON [JobSetupHolidayPromoMsg] TO ExecuteOnlyRole

GO

