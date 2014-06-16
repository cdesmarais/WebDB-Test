if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GroupReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GroupReport]
GO


create  Procedure [dbo].[GroupReport]
(
  @GroupID varchar(8000), --[EV: List of Int IDs]
  @Offset int
)
AS


set transaction isolation level read uncommitted

/*GroupReport returns group restaurants' monthly billable reservation results.
Pass in @GroupID as a comma delimited string - IE '2,15,294' and @Offset parameter
determines number of months previous to current month - IE @Offset=-2 describes 2 months 
prior to current month, @Offset=-10 describes 10 months prior to current monht*/

Declare @PreMonth datetime
Declare @CurReportYear nvarchar(4)
Declare @CurReportDate nvarchar(7)
Declare @month int

select @PreMonth = DATEADD(month, @Offset, getdate())
select @CurReportDate =cast(month(@PreMonth ) as nvarchar(2))+ '/' + cast(Year(@PreMonth) as nvarchar(4)) 
select @CurReportYear= cast(year(@PreMonth) as nvarchar(4))
select @month = month(@PreMonth)


select 
	COALESCE(YTD.RID,0) as RID, 
	@CurReportDate as reportdate, 
	COALESCE(YTD.GID,0) as GID, 
	COALESCE(YTD.GroupName,'') as GroupName, 
	COALESCE(R.RName,'') as RName, 
	COALESCE(R.City,'') as City, 
	COALESCE(R.State,'') as State, 
	COALESCE(TotalReservations, 0) as TotalReservations,  COALESCE(YTD_TotalReservations,0) as YTD_TotalReservations,
	COALESCE(TotalGuests, 0) as TotalGuests,  COALESCE(YTD_TotalGuests,0) as YTD_TotalGuests,
	COALESCE(TotalFirstTimeBookers, 0) as TotalFirstTimeBookers,      COALESCE(YTD_TotalFirstTimeBookers,0) as YTD_TotalFirstTimeBookers,
	COALESCE(CoverFromFirstTimeBookers, 0)as CoverFromFirstTimeBookers,      COALESCE(YTD_CoverFromFirstTimeBookers,0) as YTD_CoverFromFirstTimeBookers,
	COALESCE(TotalOTReservation, 0)as TotalOTReservation, COALESCE(YTD_TotalOTReservation,0) as YTD_TotalOTReservation,
	COALESCE(TotalOTGuest, 0) as TotalOTGuest,      COALESCE(YTD_TotalOTGuest,0) as YTD_TotalOTGuest,
	COALESCE(TotalRestaurantReservation, 0)as TotalRestaurantReservation,      COALESCE(YTD_TotalRestaurantReservation,0) as YTD_TotalRestaurantReservation,
	COALESCE(TotalRestaurantGuest, 0)as TotalRestaurantGuest,      COALESCE(YTD_TotalRestaurantGuest,0) as YTD_TotalRestaurantGuest,
	COALESCE(TotalPromoReservation, 0) as TotalPromoReservation,      COALESCE(YTD_TotalPromoReservation,0) as YTD_TotalPromoReservation,
	COALESCE(TotalPromoGuest, 0)as TotalPromoGuest,COALESCE(YTD_TotalPromoGuest,0) as YTD_TotalPromoGuest,
	COALESCE(FirstTimeOTBooker, 0)as FirstTimeOTBooker, COALESCE(YTD_FirstTimeOTBooker,0)as YTD_FirstTimeOTBooker,
	COALESCE(FirstTimeRestaurantBooker, 0)as FirstTimeRestaurantBooker, COALESCE(YTD_FirstTimeRestaurantBooker,0) as YTD_FirstTimeRestaurantBooker,
	COALESCE(FirstTimePromoBooker, 0)as FirstTimePromoBooker ,      COALESCE(YTD_FirstTimePromoBooker,0) as YTD_FirstTimePromoBooker,
	COALESCE(DisputedCovers, 0)as DisputedCovers,   COALESCE(YTD_DisputedCovers,0)as YTD_DisputedCovers, 
	COALESCE(NoShow,0) as NoShow, COALESCE(YTD_NoShow,0) as YTD_NoShow, COALESCE(Cancel,0) as Cancel, COALESCE(YTD_Cancel,0) as YTD_Cancel
from 
(
	select G.GID as GID,FE.RID, G.GroupName, 
	sum(TotalReservations) as TotalReservations,
	sum(TotalGuests)as TotalGuests,
	sum(TotalFirstTimeBookers)as TotalFirstTimeBookers,
	sum(CoverFromFirstTimeBookers)as CoverFromFirstTimeBookers,
	sum(TotalOTReservation)as TotalOTReservation,
	sum(TotalOTGuest)as TotalOTGuest,
	sum(TotalRestaurantReservation)as TotalRestaurantReservation,
	sum(TotalRestaurantGuest)as TotalRestaurantGuest,
	sum(TotalPromoReservation)as TotalPromoReservation,
	sum(TotalPromoGuest)as TotalPromoGuest,
	sum(FirstTimeOTBooker)as FirstTimeOTBooker,
	sum(FirstTimeRestaurantBooker)as FirstTimeRestaurantBooker,
	sum(FirstTimePromoBooker)as FirstTimePromoBooker,
	sum(DisputedCovers)as DisputedCovers,
	sum(Noshow) as NoShow,
	sum(Cancel) as Cancel
	from		GroupReportInterimHistorical FE
	inner join	restaurantToGroup RG 
	on			FE.RID = RG.RID
	inner join	restaurantGroup G
	on			RG.GID = G.GID
	where		CHARINDEX(',' + CAST(G.GID AS nvarchar) + ',', ',' + @GroupID + ',') > 0
	and			ReportDate = @CurReportDate
	GROUP BY G.GID, FE.RID, G.GroupName
)LM
Right join (
	select G.GID as GID,FE.RID, G.GroupName,
	sum(TotalReservations) as YTD_TotalReservations,
	sum(TotalGuests)as YTD_TotalGuests,
	sum(TotalFirstTimeBookers)as YTD_TotalFirstTimeBookers,
	sum(CoverFromFirstTimeBookers)as YTD_CoverFromFirstTimeBookers,
	sum(TotalOTReservation)as YTD_TotalOTReservation,
	sum(TotalOTGuest)as YTD_TotalOTGuest,
	sum(TotalRestaurantReservation)as YTD_TotalRestaurantReservation,
	sum(TotalRestaurantGuest)as YTD_TotalRestaurantGuest,
	sum(TotalPromoReservation)as YTD_TotalPromoReservation,
	sum(TotalPromoGuest)as YTD_TotalPromoGuest,
	sum(FirstTimeOTBooker)as YTD_FirstTimeOTBooker,
	sum(FirstTimeRestaurantBooker)as YTD_FirstTimeRestaurantBooker,
	sum(FirstTimePromoBooker)as YTD_FirstTimePromoBooker,
	sum(DisputedCovers)as YTD_DisputedCovers,
	sum(Noshow) as YTD_NoShow,
	sum(Cancel) as YTD_Cancel
	from		GroupReportInterimHistorical FE
	inner join	restaurantToGroup RG 
	on			FE.RID = RG.RID
	inner join	restaurantGroup G
	on			RG.GID = G.GID 
	where		CHARINDEX(',' + CAST(G.GID AS varchar) + ',', ',' + @GroupID + ',') > 0
	and			RIGHT(ReportDate, 4) =@CurReportYear and cast(left(FE.reportdate,len(FE.reportDate)-5) as int)  <= @month
	GROUP BY	G.GID, FE.RID, G.GroupName
) YTD
on			YTD.RID = LM.RID and YTD.GID = LM.GID
inner join	restaurantVW R
on			R.RID = YTD.RID

GO

GRANT EXECUTE ON [GroupReport] TO ExecuteOnlyRole

GO
