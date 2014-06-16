if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_NewList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_NewList]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_NewList
(
  @metroid int,
  @newflg int = 0,
  @RestaurantID int = 0
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @newflgv nvarchar(1)
,@RestID nvarchar(20)
,@SixMonthBackDate datetime

if @newflg = 0 SELECT @newflgv = ''
if @newflg > 0 SELECT @newflgv = @newflg
if @RestaurantID = 0 SELECT @RestID = ''
if @RestaurantID > 0 SELECT @RestID = @RestaurantID

set @SixMonthBackDate = DATEADD(MONTH, -6, GETDATE())

Select		r.RID as Restaurant_ID
			,r.RName as restname
			,r.NewFlag
			,ma.MetroAreaName As metroname
			,coalesce(ERBBuild,'0') As ERBBuild
			,allotment
			,rank = ''
			,coalesce(rja.JustAdded,0) as Just_Added
			,rja.DateAdded
			,rja.DateRemoved
			,rja.OverrideDate
			,DisplayDays
			,MinNumRests
			,r.RSName
From		RestaurantVW r
Inner Join	NeighborhoodAVW n 
On			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
Inner Join	RestaurantJustAdded rja 
On			r.RID = rja.RID
Inner Join	MetroAreaAVW ma 
On			ma.metroareaid = n.metroareaid
and			ma.LanguageID = r.LanguageID
Inner Join	ERBRestaurant erb 
ON			r.RID = erb.RID
Where		ma.metroareaid = @metroid
And			(
			 LEN(@newflgv) = 0 
			 OR 
			 CHARINDEX(',' + CAST(r.NewFlag AS nvarchar(1)) + ',',',' + @newflgv + ',') > 0
			)
And         (
				(
					LEN(@RestID) = 0 
					AND 
					(
						rja.JustAdded = 1 
						OR
						rja.DateAdded > @SixMonthBackDate 
						OR
						rja.OverrideDate > @SixMonthBackDate
					)
				) 
				OR 
				CHARINDEX(',' + CAST(r.RID AS nvarchar(20)) + ',',',' + @RestID + ',') > 0
			)  
And			r.RestStateID in (1,7,13,16)
Order By	r.RSName Asc, r.RName Asc

GO

GRANT EXECUTE ON [Admin_Restaurant_NewList] TO ExecuteOnlyRole

GO
