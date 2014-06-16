if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_AddConsumerType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_AddConsumerType]
GO



CREATE Procedure dbo.Admin_Promos_AddConsumerType
 (
  @PromoID int,
  @ConsumerTypeID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

Insert into PromoConsumerType 
	(
	PromoID, 
	ConsumerTypeID
	) 
	VALUES 
	(
	@PromoID,
	@ConsumerTypeID
	)


if @@ERROR <> 0
		goto error

COMMIT TRANSACTION

Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN(0)

GO

GRANT EXECUTE ON [Admin_Promos_AddConsumerType] TO ExecuteOnlyRole

GO
