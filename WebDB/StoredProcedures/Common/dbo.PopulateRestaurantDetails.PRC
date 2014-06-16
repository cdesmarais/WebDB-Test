
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PopulateRestaurantDetails]') and
OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PopulateRestaurantDetails]
GO

create procedure dbo.PopulateRestaurantDetails

as
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @bLoadTable as bit = 0 
declare @LastUpdatedTimeStampDtUtc as datetime = getutcdate()

if object_id('tempdb..##tempRestaurantDetails') is null
begin
	create table ##tempRestaurantDetails(
		RID int,
		Rname nvarchar(255),
		LanguageID int,
		MetroAreaName nvarchar(255),
		City nvarchar(40),
		State nvarchar(40),
		Zip nvarchar(20),
		ExternalURL nvarchar(128),
		ReservationPhone varchar(20),
		TimeStampDtUtc datetime default getutcdate(),
		primary key clustered(RID, LanguageID)
		)
	 	set @bLoadtable = 1
end
else
begin
	select @LastUpdatedTimeStampDtUtc = MIN(TimeStampDtUtc) from ##tempRestaurantDetails
end

if DATEDIFF(MINUTE,@LastUpdatedTimeStampDtUtc,GETUTCDATE()) > 10
begin
	truncate table ##tempRestaurantDetails
	set @bLoadtable = 1
end

if @bLoadTable = 1
begin
insert 
	into ##tempRestaurantDetails
	(
		RName
		,RID
		,LanguageID
		,MetroAreaName
		,City
		,State
		,Zip
		,ExternalURL
		,ReservationPhone
		,TimeStampDtUtc
	)

	select
		Rest.RName
		,Rest.RID
		,Rest.LanguageID
		,MA.MetroAreaName
		,rest.City
		,rest.State
		,rest.ZIP
		,rest.ExternalURL
		,rest.ReservationPhone
		,GETUTCDATE()
	from 
		RestaurantAVW rest 

        inner join NeighborhoodAVW NBH  on 
        rest.NeighborhoodID = NBH.NeighborhoodID  and 
        NBH.LanguageID = Rest.LanguageID   

		inner join MetroAreaAVW MA on
        NBH.MetroAreaID = MA.MetroAreaID and 
        MA.LanguageID = Rest.LanguageID    

	where 
		rest.NeighborhoodID = NBH.NeighborhoodID and 
        MA.MetroAreaID = NBH.MetroAreaID and 
		rest.RestStateID <> 4 -- RStateID for Inactive state
end

GO

grant execute on [PopulateRestaurantDetails] to ExecuteOnlyRole

GO


