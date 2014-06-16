if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_RemoveConsumerType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_RemoveConsumerType]
GO




CREATE Procedure dbo.Admin_Promos_RemoveConsumerType
 (
  @PromoID int
 )
As

Delete from PromoConsumerType where PromoID = @PromoID

GO

GRANT EXECUTE ON [Admin_Promos_RemoveConsumerType] TO ExecuteOnlyRole

GO
