if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroUpdate1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroUpdate1]
GO

CREATE PROCEDURE dbo.Admin_MacroUpdate1
(
  @macroid int,
  @macroName nvarchar(100),
  @sortorder INT,
  @active int,
  @MetroAreaId int
)
AS

	declare @LanguageID int
	declare @CurrentMetroID int
	
	exec @LanguageID = procGetDBUserLanguageID
	
	--Getting Metro ID of metro to which Region is currently assigned.
	select
		@CurrentMetroID = mn.MetroAreaID
	from 
		MacroNeighborhood mn
	where
		mn.macroid = @macroid

	if @sortorder = 99
	BEGIN
		Set @sortorder = NULL
	END

	Update	MacroNeighborhood 
	set		SortOrder = @sortorder,
			Active = @active,
			MetroAreaID = @MetroAreaId
	where	MacroID = @macroid

	Update	MacroNeighborhoodlocal
	set		MacroName = @macroName 
	where	MacroID = @macroid
	and	LanguageID = @LanguageID
	
	
		
	--Checking whether Metro of the region has changed or not?
	if( @CurrentMetroID != @MetroAreaId )
	begin	
		-- Changing the Metro of all Neighborhood under the region.
		update 
			Neighborhood
		set
			MetroAreaID = @MetroAreaId
		where
			MacroID = @macroid
	end
GO

GRANT EXECUTE ON [Admin_MacroUpdate1] TO ExecuteOnlyRole

GO
