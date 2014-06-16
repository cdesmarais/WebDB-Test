if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheOfferDayLevelSchedules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheOfferDayLevelSchedules]
GO

CREATE PROCEDURE dbo.DNCacheOfferDayLevelSchedules 
As  
  
SET NOCOUNT ON  
set transaction isolation level read uncommitted  
  select 
    RestaurantOfferID, 
    DOW,   
    MaxInventory, 
    MinPartySize, 
    MaxPartySize,   
    SlotBits1, 
    SlotBits2, 
    SlotBits3   
  from 
    offerdaylevelschedule 

GO
GRANT EXECUTE ON [DNCacheOfferDayLevelSchedules] TO ExecuteOnlyRole