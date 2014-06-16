if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetDiningForm]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetDiningForm]
GO


-- Return Dining Form Elements. If dining formID is set to -1, return the active form
CREATE PROCEDURE dbo.DNGetDiningForm
(
	@theDiningFormID int	
)

AS

declare @localDinFormID int

set @localDinFormID=@theDiningFormID


-- return multiple recordsets

-- recordset1 (DiningForm Table)
if @theDiningFormID = -1 
   BEGIN
   	-- pick most recent active dining form. ALWAYS only one dining form thats active
	select @localDinFormID=diningformid  from diningform where active=1
	select * from diningform where diningformid=@localDinFormID
   END
else 
   BEGIN
   	select * from diningform where diningformid=@localDinFormID
   END

-- recordset2 (Ratings Section)
select si.NonHTMLFieldName,
	 si.ratingsectionitemid, 
	 rt.ratingstypeid,
	 rtd.ratingstypedetailid,
	 si.ratingstitle,
	 rtd.dispcolumntext 
from FBFormRatingsSectionItems si
inner join FBFormRatingsType rt on rt.ratingstypeid=si.ratingstypeid
inner join FBFormRatingsTypeDetail rtd on rtd.ratingstypeid=rt.ratingstypeid
where si.diningformid=@localDinFormID 
	and si.active=1 
	and rt.active=1 
	and rtd.active=1
order by si.rank asc,rtd.columnrank asc

-- recordset3 (Categories Section)
select ci.categorysectionitemid,
	c.categoryid,
	c.displaytext 
from FBFormCategoriesSectionItems ci 
inner join FBFormCategories c on c.categoryid=ci.categoryid
where ci.diningformid=@localDinFormID  
	and ci.active=1 and c.active=1
order by rank asc


GO

GRANT EXECUTE ON [DNGetDiningForm] TO ExecuteOnlyRole

GO
