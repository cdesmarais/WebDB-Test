if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodTypes_Change]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodTypes_Change]
GO

CREATE Procedure dbo.Admin_FoodTypes_Change
 (
	@RestaurantID INT
	,@FoodTypeID nvarchar(255)
 )
As
SET NOCOUNT ON

declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000) 
declare @DBError int 
declare @LanguageID int 

set @ProcName = 'Admin_FoodTypes_Change'  

BEGIN TRANSACTION

--***************************  
--** Retrieve LanguageID  
--***************************  
set @Action = 'Retrieve LanguageID'  
exec @LanguageID = procGetDBUserLanguageID  
set @DBError = @@error  
if @DBError <> 0  
 goto error 

set @Action = 'Delete existing FoodTypes'  
DELETE FROM FoodTypes
WHERE ([RID] = @RestaurantID and FoodTypes.[FoodTypeID] IN (
	SELECT FoodTypeID from FoodType where [LanguageID] = @LanguageID))

set @DBError = @@error
if @DBError <> 0  
  goto error   


set @Action = 'Add new FoodTypes'  
--*****************************
--** Create an ordered table of Foodtypes
--*****************************	
declare @FoodTab table
	(
	     Pos int identity(1,1),
	     FoodTypeID int
	)

insert into @FoodTab (FoodTypeID)
	select ID from dbo.fIDStrToTab(@FoodTypeID, ',')
If @@Error <> 0 
   goto error

INSERT INTO FoodTypes (RID, FoodTypeID, IsPrimary, FTRank) 
	select @RestaurantID, 
		FoodTypeID,
		(Case when Pos=1 then 1 else 0 end),
		Pos
	from @FoodTab
If @@Error <> 0 
   goto error
  
COMMIT TRANSACTION  
Return(0) 


error:  
 ROLLBACK TRANSACTION  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1) 
GO

GRANT EXECUTE ON [Admin_FoodTypes_Change] TO ExecuteOnlyRole

GO
