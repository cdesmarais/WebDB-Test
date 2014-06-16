--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNOfferCleanup_UpdateWatermark]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNOfferCleanup_UpdateWatermark]
GO

CREATE PROCEDURE [dbo].[DNOfferCleanup_UpdateWatermark]
@NewWatermark INT

AS

declare		@rc int

update		ValueLookup 
set			ValueInt		= @NewWatermark 
where		LKey			= 'OFFER_CLEANUP_WATERMARK' 

select		@rc = @@rowcount

select		@rc

GO


GRANT EXECUTE ON [DNOfferCleanup_UpdateWatermark] TO ExecuteOnlyRole

GO
