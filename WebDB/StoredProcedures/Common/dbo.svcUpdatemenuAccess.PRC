if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcUpdateMenuAccess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcUpdateMenuAccess]
GO

CREATE PROCEDURE [dbo].[svcUpdateMenuAccess]
(
	@RID int,
	@ContentType varchar(50),
	@IsAccessible bit
)
AS

/*
This proc updates the Menu accessibility status along with any newer content types that already not exist in DB.
*/
declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int
declare @MenuFormatID int
set @ProcName = OBJECT_NAME(@@PROCID)  
set @Action = 'Proc Started' 

BEGIN TRANSACTION  


--select menu format from the restaurant menu format table using the content type.
select	@MenuFormatID = menuformatID
from	RestaurantMenuFormat
where	MenuFormat = @ContentType

--if there is an entry, its good, use it. If not, then add an entry into MenuFormat and get the latestID
if(@MenuFormatID IS NULL)
Begin
	set @Action = 'Add New menu format' 
	insert into RestaurantMenuFormat(MenuFormat, MenuDisplayFormatID)
	values							(@ContentType, 1)-- default as Popup menu since we need to determine how to display it.

	SELECT @MenuFormatID = SCOPE_IDENTITY(),@DBError = @@error
End

if @DBError <> 0  
 goto error

--check if there is any record under MenuAccess table, if there is then update Accessible flag and menuformat ID 
if exists(select rid from RestaurantMenuAccess where RID = @RID)
Begin
	set @Action = 'Update MenuAccess and format for restaurant' 	
	update	RestaurantMenuAccess
	set		MenuFormatID = @MenuFormatID,
			IsAccessible = @IsAccessible
	where	RID = @RID				 
End
else
Begin
	set @Action = 'Insert MenuAccess and format for restaurant' 	
	--if not, then insert into restaurant menu access with accessible and menu formatID
	insert into RestaurantMenuAccess (RID, 
									  MenuFormatID,
									  IsAccessible
									  )
	values							 (@RID,
									  @MenuFormatID,
									  @IsAccessible
									  )								
End

set @DBError = @@error  
if @DBError <> 0  
 goto error
 

COMMIT TRANSACTION  
Return(0)  
  
error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1) 

GO

GRANT EXECUTE ON [svcUpdateMenuAccess] TO ExecuteOnlyRole

GO
