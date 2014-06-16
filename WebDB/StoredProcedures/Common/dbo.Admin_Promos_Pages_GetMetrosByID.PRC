

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_GetMetrosByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_GetMetrosByID]
GO

create procedure dbo.Admin_Promos_Pages_GetMetrosByID
(
	@PromoID int
)
as
set NOCOUNT on
set transaction ISOLATION LEVEL read UNCOMMITTED

-- Get Domain ID and promosearchtype separately so as not to break left outer join below.
declare @ChildPromoID int
declare @LanguageID as int
declare @PromoSearchType as nvarchar(255)

select
	@ChildPromoID = COALESCE(pp.ChildPromoID, 0)
	, @LanguageID = pp.LanguageID 
	, @PromoSearchType = ppst.SearchTypeName
from 
	dbo.PromoPages pp 
	inner join dbo.PromoPagesSearchType ppst on 
	pp.PromoSearchTypeID = ppst.SearchTypeID

where 
	pp.PromoID = @PromoID

if @ChildPromoID <> 0
begin

	select 
		ma.metroAreaID
		,ma.MetroAreaName
		,@PromoSearchType AS PromoSearchType
		,Parentpptm.OnStartPage
		,case when (Childpptm.OnStartPage is not null or RestsInChildPromo > 0) then coalesce(Parentpptm.OnContent, 0) else null end as OnContent
		,case when (Childpptm.NoFollow is not null or RestsInChildPromo > 0) then Parentpptm.NoFollow else null end as NoFollow
		,ParticipatingRestaurants
		,ma.SupportedDomainID
	from	
		metroAreaVW ma
		left outer join PromoPagesToMetro  Parentpptm on
		ma.MetroAreaID = Parentpptm.metroID 
		and	Parentpptm.promoid = @PromoID 

		left outer join PromoPagesToMetro  Childpptm on		
		ma.MetroAreaID = Childpptm.metroID 
		and Childpptm.promoid = @ChildPromoID
		
		-- Following inner view is used to find out count of all restaurants with valid rank for given Promos by MetroArea
		left outer join  
		(  
			select 
				count(*) as ParticipatingRestaurants 
				,MetroArea.MetroAreaID as MetroAreaID  
			from   
				PromoRests  
				inner join RestaurantVW rest on
				promorests.RID = rest.RID  

				inner join NeighborhoodAVW NBH  on   
				rest.NeighborhoodID = NBH.NeighborhoodID  
				and NBH.LanguageID = Rest.LanguageID     
	
				inner join MetroAreaAVW MetroArea on  
				NBH.MetroAreaID = MetroArea.MetroAreaID 
				and MetroArea.LanguageID = Rest.LanguageID    
	
			where 
				promorests.Rank is not null    
				and promorests.PromoID = @PromoID 
				and rest.RestStateID <> 2  

			group by 
				MetroArea.MetroAreaID  

		)ParticipatingRestaurantsByMetro on
		ParticipatingRestaurantsByMetro.MetroAreaID = ma.MetroAreaID
		
		-- Following inner view is used to find out count of all restaurants with valid rank for given Promos by MetroArea
		left outer join  
		(  
			select 
				count(*) as RestsInChildPromo
				,MetroArea.MetroAreaID as MetroAreaID  
			from   
				PromoRests  
				inner join RestaurantVW rest on
				promorests.RID = rest.RID  

				inner join NeighborhoodAVW NBH  on   
				rest.NeighborhoodID = NBH.NeighborhoodID  
				and NBH.LanguageID = Rest.LanguageID     
	
				inner join MetroAreaAVW MetroArea on  
				NBH.MetroAreaID = MetroArea.MetroAreaID 
				and MetroArea.LanguageID = Rest.LanguageID    
	
			where 
				promorests.Rank is not null    
				and promorests.PromoID = @ChildPromoID   

			group by 
				MetroArea.MetroAreaID  

		)ParticipatingRestsInChildPromo on
		ParticipatingRestsInChildPromo.MetroAreaID = ma.MetroAreaID

	where	
		(
			ma.active = 1 
			and ma.LanguageID = @LanguageID
		)
		or ma.metroareaID = 1
	order by	
		ma.MetroAreaName
	
end
else
begin
	select 
		ma.metroAreaID
		,ma.MetroAreaName
		,@PromoSearchType AS PromoSearchType
		,Parentpptm.OnStartPage
		,null AS OnContent
		,null AS NoFollow
		,ParticipatingRestaurants
		,ma.SupportedDomainID
	from	
		metroAreaVW ma
		left outer join PromoPagesToMetro  Parentpptm on
		ma.MetroAreaID = Parentpptm.metroID 
		and	Parentpptm.promoid = @PromoID
		
		-- Following inner view is used to find out count of all restaurants with valid rank for given Promos by MetroArea
		left outer join  
		(  
			select 
				count(*) as ParticipatingRestaurants 
				,MetroArea.MetroAreaID as MetroAreaID  
			from   
				PromoRests  
				inner join RestaurantVW rest on
				promorests.RID = rest.RID  

				inner join NeighborhoodAVW NBH  on   
				rest.NeighborhoodID = NBH.NeighborhoodID  
				and NBH.LanguageID = Rest.LanguageID     
	
				inner join MetroAreaAVW MetroArea on  
				NBH.MetroAreaID = MetroArea.MetroAreaID 
				and  MetroArea.LanguageID = Rest.LanguageID    
	
			where 
				promorests.Rank is not null    
				and promorests.PromoID = @PromoID 
				and rest.RestStateID <> 2   

			group by 
				MetroArea.MetroAreaID  

		)ParticipatingRestaurantsByMetro on
		ParticipatingRestaurantsByMetro.MetroAreaID = ma.MetroAreaID

	where	
		(
			ma.active = 1 
			and	ma.LanguageID = @LanguageID
		)
		or	ma.metroareaID = 1
	order by	ma.MetroAreaName
	
end

GO

GRANT EXECUTE ON [Admin_Promos_Pages_GetMetrosByID] TO ExecuteOnlyRole

GO

