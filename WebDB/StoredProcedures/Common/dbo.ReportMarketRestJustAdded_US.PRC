if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReportMarketRestJustAdded_US]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReportMarketRestJustAdded_US]
GO

CREATE PROCEDURE dbo.ReportMarketRestJustAdded_US
as
------------------------------
--** PROC START
------------------------------

declare @runDate datetime
declare @LastCalMonth datetime

set @runDate= getdate()
set @LastCalMonth =  dateadd(m, -1, @runDate)

select RJA.RID, R.Rname, MA.MetroAreaID, MA.MetroAreaName,
			RJA.DateAdded from dbo.RestaurantJustAdded  RJA
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
order by dateAdded


GO


GRANT EXECUTE ON [ReportMarketRestJustAdded_US] TO ExecuteOnlyRole

GO
