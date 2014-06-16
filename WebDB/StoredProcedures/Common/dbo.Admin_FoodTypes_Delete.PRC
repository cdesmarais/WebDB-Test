if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodTypes_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodTypes_Delete]
GO

CREATE Procedure dbo.Admin_FoodTypes_Delete
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON

declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000) 
declare @DBError int 
declare @LanguageID int 

set @ProcName = 'FoodTypes_Delete'  
set @Action = 'Proc Started'  

BEGIN TRANSACTION

--***************************  
--** Retrieve LanguageID  
--***************************  
set @Action = 'Retrieve LanguageID'  
exec @LanguageID = procGetDBUserLanguageID  
set @DBError = @@error  
if @DBError <> 0  
 goto error 

DELETE FROM FoodTypes
WHERE ([RID] = @RestaurantID and FoodTypes.[FoodTypeID] IN (
	SELECT FoodTypeID from FoodType where [LanguageID] = @LanguageID))


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

GRANT EXECUTE ON [Admin_FoodTypes_Delete] TO ExecuteOnlyRole

GO
