if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_UpdateTopTenMetroLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_UpdateTopTenMetroLists]
GO

Create procedure [dbo].[TopTen_UpdateTopTenMetroLists]
(
	@TopTenMetroListData varchar(8000)
)

as

DECLARE @tblTopTenMetroRanks TABLE (
    TopTenListID INT,
    Rank  INT)

SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE

INSERT INTO @tblTopTenMetroRanks
(
TopTenListID, 
Rank
)
Select [Key], [Value] from dbo.fKeyValuePairStrToTab(@TopTenMetroListData, ',', ';')

Update TopTenList Set ListDisplayOrder = Rank
FROM TopTenList ttl INNER JOIN @tblTopTenMetroRanks tmp
ON ttl.TopTenListID = tmp.TopTenListID

if(@@Error <> 0) goto general_Error

Return(0)


general_Error:
RAISERROR('1',16,2) -- Generic error message
RETURN(1)

GO

GRANT EXECUTE ON TopTen_UpdateTopTenMetroLists TO ExecuteOnlyRole

GO




