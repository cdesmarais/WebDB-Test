if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobRestJustAddedExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobRestJustAddedExtract]
GO

CREATE PROCEDURE dbo.JobRestJustAddedExtract
as
------------------------------
--** GC - 110806: Jeana is requesting a monthly automated extract of restaurant added to 
--the Just Added List since the last export.  The extract would run on the first of the 
--month and pull all restaurants added to the list the previous month into a flat file.  
--The flat file will be manually moved to our email vendor's FTP site so they can auto populate our emails with the restaurants.  
--Today Jeana has to figure this out manually for each metro.
------------------------------

declare @runDate datetime
declare @LastCalMonth datetime

set @runDate= getdate()
set @LastCalMonth =  dateadd(m, -1, @runDate)

select		RJA.RID, 
			R.Rname, 
			MA.MetroAreaID, 
			MA.MetroAreaName,
			RJA.DateAdded 
from		dbo.RestaurantJustAdded  RJA
inner join	RestaurantVW R
on			RJA.RID = R.RID
inner join	neighborhood NE
on			R.neighborhoodID = NE.NeighborhoodID
inner join	metroAreaAVW MA
on			MA.metroAreaID = NE.MetroAreaID
and			MA.LanguageID = r.LanguageID
where		Year(RJA.dateAdded) = Year(@LastCalMonth)
and			Month(RJA.dateAdded) = Month(@LastCalMonth)
and			MA.CountryID in('US', 'CA', 'MX')
order by	dateAdded



GO


GRANT EXECUTE ON [JobRestJustAddedExtract] TO ExecuteOnlyRole

GO
