if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListFetch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListFetch]
GO
/*	
	Procedure to get the "sticky" TopTenLists 
*/
CREATE PROCEDURE dbo.TopTenListFetch

AS
SET NOCOUNT ON
SET TRANSACTION isolation LEVEL READ uncommitted

------------------------------------------------------------------------------
-- Fetch a unique lookup of Top Ten Lists by 
-- MetroId, FeedListId, MacroId, CuisineId, NeighborhoodId
------------------------------------------------------------------------------
SELECT		 MetroAreaID
			,MediaStore_FeedListID
			,MacroID 
			,CuisineID
			,NeighborhoodID
			,TopTenListID
FROM TopTenList		

GO


GRANT EXECUTE ON [TopTenListFetch] TO ExecuteOnlyRole

GO

