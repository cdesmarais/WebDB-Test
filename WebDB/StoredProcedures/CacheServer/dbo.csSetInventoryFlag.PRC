--$ create proc csSetInventoryFlag
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csSetInventoryFlag]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csSetInventoryFlag]
GO

CREATE PROCEDURE dbo.csSetInventoryFlag
(
	 @RID         int
	,@IsInventory bit
)
as

   update ERBRestaurant
   set    IsInventory  = @IsInventory
   where  RID          = @RID
   and    IsInventory != @IsInventory

go
grant execute on [csSetInventoryFlag] to ExecuteOnlyRole
go
