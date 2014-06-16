if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodTypes_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodTypes_Add]
GO

CREATE Procedure dbo.Admin_FoodTypes_Add
 (
  @RestaurantID int,
  @FoodTypeID nvarchar(255)
 )
As

SET NOCOUNT ON

BEGIN TRANSACTION

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
	Return(0)



GO

GRANT EXECUTE ON [Admin_FoodTypes_Add] TO ExecuteOnlyRole

GO
