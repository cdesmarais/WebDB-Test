if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Admin_Restaurant_UpdateMappingAddress') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Admin_Restaurant_UpdateMappingAddress
GO

Create procedure dbo.Admin_Restaurant_UpdateMappingAddress
(
	@RestaurantID int, 
	@MappingAddress nvarchar(128),
	@IsValidMap bit
)
AS

SET NOCOUNT ON

BEGIN TRANSACTION

SET @MappingAddress = ltrim(rtrim(@MappingAddress))

--If MappingAddress is null or empty string set IsValidMap to 0.
If(@MappingAddress is NULL OR @MappingAddress = '')
	 Set @IsValidMap = 0


UPDATE Restaurant  Set
	   MappingAddress = @MappingAddress,
	   MapAddrValid = @IsValidMap	
WHERE RID = @RestaurantID


if @@error <> 0
	goto error

COMMIT TRANSACTION
Return(0)

error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON Admin_Restaurant_UpdateMappingAddress TO ExecuteOnlyRole

GO

