GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Monthly_RestaurantT_Populate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Monthly_RestaurantT_Populate]
GO



CREATE PROCEDURE dbo.Monthly_RestaurantT_Populate

AS
SET NOCOUNT ON
set traNSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION

Delete from ReportRestaurant

Insert Into ReportRestaurant
	(RID, RName, RSName, NeighborhoodID, NbhoodName, MetroAreaID, MetroAreaName, CreateDate, allotment, RestStateID)
(Select
	rts.RID,
	rts.RName,
	rts.RSName,
	n.NeighborhoodID,
	n.NbhoodName,
	ma.MetroAreaID,
	ma.MetroAreaName as MetroName,
	rts.CreateDate,
	rts.allotment,
	rts.RestStateID
From RestaurantVW rts
inner join	NeighborhoodAVW n 
on			rts.NeighborhoodID = n.NeighborhoodID
and			rts.LanguageID = n.LanguageID
inner join	MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			rts.LanguageID = ma.LanguageID
Where ma.MetroAreaID <> 1)

If @@Error <> 0 goto error


COMMIT TRANSACTION
Return(0)

error:
BEGIN
    ROLLBACK TRANSACTION
    RAISERROR ('Error Inserting Monthly Restaurant Information.', 17,1)
    RETURN(1)
END


GO


GRANT EXECUTE ON [Monthly_RestaurantT_Populate] TO ExecuteOnlyRole

GO
