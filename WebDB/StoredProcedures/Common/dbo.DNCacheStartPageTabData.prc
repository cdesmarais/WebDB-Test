if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStartPageTabData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheStartPageTabData]
go

create procedure dbo.DNCacheStartPageTabData 
as 
	/*
		This stored procedure is used to create a cache for the start page tab controls.  The data
		returned from this stored procedure is processed by the cache manager to create a metro and
		macro cache object to allow for fast rendering on the start page.
	*/
	set transaction isolation level read uncommitted
	set nocount on
	
	--Active TopTenList job.
	declare @DCListJobID int
	
	select			@DCListJobID = TopTenImportJobID
	from			TopTenImportJob
	where			[Status] = 1
	
	--Look to see that regional list data is supposed to be shown
	declare @RegionalListEnabled int
	
	select			@RegionalListEnabled = coalesce(ValueInt,0)
	from			dbo.ValueLookup 
	where			LKey = 'TTRegionalListsEnabled'
	
	--Get the offers exclusion lookup id
	declare @OffersRIDExclusionListID int
	select @OffersRIDExclusionListID	= LookupID from ValueLookupMaster where [Type] = N'WEBSERVER'	and	[Key] = N'OFFERS_SUPPRESSION_BLACKLIST'

	--Get the offers metro inclusion lookup id
	declare @OffersMetroInclusionListID int
	select @OffersMetroInclusionListID	= LookupID from ValueLookupMaster where [Type] = N'WEBSERVER'	and	[Key] = N'OFFERS_METRO_WHITELIST'
	
	--CC sponsor list lookup ids for included promo(s), metro blacklist, and RID blacklist 
	declare @CCSponsorPromoID INT 
	Select @CCSponsorPromoID = ValueInt FROM dbo.ValueLookup WHERE Lkey = 'CCSponsorPromoID' AND LType = 'WEBSERVER'
	
	declare @CCSponsorMetroBlacklistListID INT = 57 -- CREDIT_CARD_SPONSOR_METRO_BLACKLIST
	declare @CCSponsorRIDBlacklistListID INT = 58   -- CREDIT_CARD_SPONSOR_RID_BLACKLIST
	
	--Create a temp table to house the Diner's Choice list ranks to be used
	--for the cache.  The metro level record will be the lowest ranked list
	--either by override or metro ranking that is an active list.  In the case
	--of smaller metros, this will be the MostBooked list.  These records
	--will be exclusive of MostBookedPOP since that has its own data section.
	--
	--These temp tables apply to the DinersChoice section of this data fetch
	--only.
	
	declare @TmpMetroRank table 
	(
		TopTenListID			int primary key,
		MetroID					int,
		DisplayOrder			int,
		OverrideDisplayOrder	int
	)

	declare @TmpMacroRank table 
	(
		TopTenListID			int primary key,
		MacroID					int,
		DisplayOrder			int,
		OverrideDisplayOrder	int

	)
	
	--Metro DinersChoice List Ranking
	insert into			@TmpMetroRank
	select				 ttl.TopTenListID
						,ttl.MetroAreaID
						,ttl.ListDisplayOrder
						,ttlt.ListDisplayOrderNationalOverride
	from				TopTenList ttl
	left join			TopTenListInstance ttli
	on					ttl.TopTenListID = ttli.TopTenListID
	inner join			TopTenListType ttlt
	on					ttl.TopTenListTypeID = ttlt.TopTenListTypeID
	inner join			MetroAreaVW m
	on					ttl.MetroAreaID = m.MetroAreaID
	inner join
	(	--Aggregate for metroarea id.
		select				min
							(
								case when ttlt.ListDisplayOrderNationalOverride = 0 
								then ttl.ListDisplayOrder
								else ttlt.ListDisplayOrderNationalOverride
								end
							) Ranking
							,ttl.MetroAreaID									
		from				TopTenList ttl
		left join			TopTenListInstance ttli
		on					ttl.TopTenListID = ttli.TopTenListID
		inner join			TopTenListType ttlt
		on					ttl.TopTenListTypeID = ttlt.TopTenListTypeID
		inner join			MetroAreaVW m
		on					ttl.MetroAreaID = m.MetroAreaID
		where				ttl.TopTenListTypeID != 2 --Never consider most booked pop since it has its own tab type
		and					ttl.MacroID is null
		and					(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
		and					ttli.TopTenImportJobID = @DCListJobID
		and					isnull(ttli.IsActive,0) = 1
		group by			ttl.MetroAreaID
	) minmet
	on					ttl.MetroAreaID = minmet.MetroAreaID
	where				(case when ttlt.ListDisplayOrderNationalOverride = 0 
							then ttl.ListDisplayOrder
							else ttlt.ListDisplayOrderNationalOverride
							end
						) = minmet.Ranking
	and					ttl.TopTenListTypeID != 2 --Never consider most booked pop since it has its own tab type
	and					ttl.MacroID is null
	and					(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
	and					ttli.TopTenImportJobID = @DCListJobID
	and					isnull(ttli.IsActive,0) = 1											
	
	--Macro DinersChoice list ranking
	insert into			@TmpMacroRank
	select				ttl.TopTenListID
						,ttl.MacroID
						,ttlx.ListDisplayOrder
						,ttlt.ListDisplayOrderNationalOverride
	from				TopTenList ttl
	left join			TopTenListInstance ttli
	on					ttl.TopTenListID = ttli.TopTenListID
	inner join			MetroAreaVW m
	on					ttl.MetroAreaID = m.MetroAreaID
	inner join			TopTenListType ttlt
	on					ttl.TopTenListTypeID = ttlt.TopTenListTypeID
	inner join			TopTenList ttlx
	on					ttl.TopTenListTypeID = ttlx.TopTenListTypeID
	and					ttl.MetroAreaID = ttlx.MetroAreaID
	and					ttlx.MacroID is null	
	inner join
	(
		select				min
							(
								case when ttlt.ListDisplayOrderNationalOverride = 0 
								then ttlx.ListDisplayOrder
								else ttlt.ListDisplayOrderNationalOverride
								end
							) Ranking
							,ttl.MacroID								
		from				TopTenList ttl
		left join			TopTenListInstance ttli
		on					ttl.TopTenListID = ttli.TopTenListID
		inner join			MetroAreaVW m
		on					ttl.MetroAreaID = m.MetroAreaID
		inner join			TopTenListType ttlt
		on					ttl.TopTenListTypeID = ttlt.TopTenListTypeID
		--Join back to TopTenList to get the metro level record for the list type of the macro.
		--The list display order for macro level lists is always zero since they inherit the
		--list display order of the metro.
		inner join			TopTenList ttlx
		on					ttl.TopTenListTypeID = ttlx.TopTenListTypeID
		and					ttl.MetroAreaID = ttlx.MetroAreaID
		and					ttlx.MacroID is null
		where				ttl.TopTenListTypeID != 2 --Never consider most booked pop since it has its own tab type
		and					ttl.MacroID is not null
		and					(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
		and					ttli.TopTenImportJobID = @DCListJobID
		and					isnull(ttli.IsActive,0) = 1
		and					m.ShowRegionLists = 1
		and					@RegionalListEnabled = 1
		group by			ttl.MacroID
		) minmac
	on					ttl.MacroID = minmac.MacroID
	where				(case when ttlt.ListDisplayOrderNationalOverride = 0 
							then ttlx.ListDisplayOrder
							else ttlt.ListDisplayOrderNationalOverride
							end
						) = minmac.Ranking
	and					ttl.TopTenListTypeID != 2 --Never consider most booked pop since it has its own tab type
	and					ttl.MacroID is not null
	and					(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
	and					ttli.TopTenImportJobID = @DCListJobID
	and					isnull(ttli.IsActive,0) = 1
	and					m.ShowRegionLists = 1
	and					@RegionalListEnabled = 1
	
	--With the national override also matching the min list order sometimes the temp table needs
	--to be de-duped of the regular list order by geographic id.
	--Metro
	delete from @TmpMetroRank
	where TopTenListID in
	(
		select tmr1.TopTenListID 
		from @TmpMetroRank tmr1
		inner join @TmpMetroRank tmr2
		on tmr1.MetroID = tmr2.MetroID
		and tmr1.TopTenListID != tmr2.TopTenListID
		where tmr1.OverrideDisplayOrder = 0
	)
	
	--Macro
	delete from @TmpMacroRank
	where TopTenListID in
	(
		select tmr1.TopTenListID 
		from @TmpMacroRank tmr1
		inner join @TmpMacroRank tmr2
		on tmr1.MacroID = tmr2.MacroID
		and tmr1.TopTenListID != tmr2.TopTenListID
		where tmr1.OverrideDisplayOrder = 0
	)
			
	-----------------
	-- JustAdded data
	-----------------
	select				 ja.MetroAreaID
						,ja.MacroID
						,3 StartPageTabTypeID --StartPageTabType 3=JustAdded
						,case when ja.MetroRank > 5 then null else ja.MetroRank end MetroRank
						,ja.MacroRank
						,ja.RID
						,null MetroTopTenListID
						,null MacroTopTenListID
	from
	(
		select				n.MetroAreaID
							,n.MacroID							
							,row_number()  over(
								partition by n.MetroAreaID 
								order by	dateadd(dd, datediff(dd,0,DateAdded), 0) desc, 
											case when r.rsname is null or len(r.rsname) = 0 then r.rname else r.rsname end
							) MetroRank
							,row_number()  over(
								partition by n.MacroID 
								order by dateadd(dd, datediff(dd,0,DateAdded), 0) desc, 
											case when r.rsname is null or len(r.rsname) = 0 then r.rname else r.rsname end
							) MacroRank
							,r.RID							
		from				RestaurantVW r
		inner join			Neighborhood n 
		on					n.neighborhoodid = r.neighborhoodid
		inner join			MacroNeighborhood mn
		on					mn.MacroID = n.MacroID		
		inner join			RestaurantJustAdded rja
		on					r.RID = rja.RID
		inner join			FoodTypes fts
		ON					r.RID = fts.RID 
		AND					isPrimary = 1
		inner join			FoodType ft
		ON					fts.FoodTypeID = ft.FoodTypeID 
		and					ft.LanguageID = r.LanguageID
		left join			RestaurantImage ri
		on					r.RID = ri.RID				
		where				JustAdded = 1
		and					reststateID in (1,13,5,6,7,16) --These statuses are the same as the just added proc, but different than the ones from the RestList Cache .. need to reconcile
	) ja
	where				(ja.MetroRank <= 5
						 or
						 ja.MacroRank <= 5)
	-- Production data will not see this case, but put into place for dev data
	and					(MetroRank is not null and 
						 MacroRank is not null)						 

	union all
	
	---------------------
	-- MostBookedPOP data
	---------------------
	
	select				MetroAreaID
						,MacroID
						,4 StartPageTabTypeID --StartPageTabType 4=MostBookedPOP
						,case when MetroRank > 5 
							then null 
							else MetroRank 
							end MetroRank
						,case when (MacroID is null or MacroRank > 5)
							then null 
							else MacroRank 
							end MacroRank
						,RID
						,MetroTopTenListID
						,MacroTopTenListID
	from (
		--Create combination of Metro/Macro list and ranking
		select				isnull(metr.MetroAreaID, macr.MetroAreaID) MetroAreaID
							,macr.MacroID
							--The nulls from the metro side of the list are from RIDs that are in a Macro list but not a Metro list.		
							,row_number() over (partition by isnull(metr.MetroAreaID,macr.MetroAreaID) order by isnull(metr.MetroRank,9999)) MetroRank
							,row_number() over (partition by macr.MacroID order by macr.MacroRank) MacroRank
							,isnull(metr.RID, macr.RID) RID
							,metr.TopTenListID MetroTopTenListID
							,macr.TopTenListID MacroTopTenListID
		from (
			--Macro lists for MostBookedPOP (MacroID is not null)
			select				ttl.MetroAreaID
								,ttl.MacroID
								,ttlr.RID
								,ttlr.[Rank] MacroRank
								,ttl.TopTenListID
			from				TopTenList ttl
			left join			TopTenListInstance ttli
			on					ttl.TopTenListID = ttli.TopTenListID
			left join			TopTenListRestaurant ttlr
			on					ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
			inner join			MetroAreaVW m
			on					ttl.MetroAreaID = m.MetroAreaID
			inner join			NeighborhoodVW n
			on					m.MetroAreaID = n.MetroAreaID
			inner join			RestaurantVW r
			on					n.NeighborhoodID = r.NeighborhoodID
			and					ttlr.RID = r.RID
			left join			TopTenListRestaurantSuppression	ttlrs
			on					ttlrs.TopTenListID				= ttl.TopTenListID
			and					ttlrs.RID						= ttlr.RID
			where				ttl.TopTenListTypeID = 2
			and					ttl.MacroID is not null
			and					(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
			and					ttli.TopTenImportJobID = @DCListJobID
			and					isnull(ttli.IsActive,0) = 1
			and					m.ShowRegionLists = 1
			and					@RegionalListEnabled = 1
			and					ttlrs.RID is null
			and					r.RestStateID not in (4,11,15)			
		) macr
	full outer join
	(
		--Metro lists for MostBookedPOP (MacroID is null)
			select				 ttl.MetroAreaID
								,ttlr.RID
								,ttlr.[Rank] MetroRank
								,ttl.TopTenListID
			from				TopTenList ttl
			left join			TopTenListInstance ttli
			on					ttl.TopTenListID = ttli.TopTenListID
			left join			TopTenListRestaurant ttlr
			on					ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
			inner join			MetroAreaVW m
			on					ttl.MetroAreaID = m.MetroAreaID
			inner join			NeighborhoodVW n
			on					m.MetroAreaID = n.MetroAreaID
			inner join			RestaurantVW r
			on					n.NeighborhoodID = r.NeighborhoodID
			and					ttlr.RID = r.RID
			left join			TopTenListRestaurantSuppression	ttlrs
			on					ttlrs.TopTenListID				= ttl.TopTenListID
			and					ttlrs.RID						= ttlr.RID			
			where				ttl.TopTenListTypeID = 2 
			and					(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
			and					ttl.MacroID is null
			and					ttli.TopTenImportJobID = @DCListJobID
			and					isnull(ttli.IsActive,0) = 1
			and					ttlrs.RID is null
			and					r.RestStateID not in (4,11,15)			
		) metr
		on					macr.RID = metr.RID
	) comb	
	where				(MetroRank <= 5 or
						 MacroRank <= 5)
	-- Production data will not see this case, but put into place for dev data
	and					(MetroRank is not null and 
						 MacroRank is not null)						 
	
	union all
	
	-------------------
	--DinersChoice data
	-------------------
	
	select				 MetroAreaID
						,MacroID
						,1 StartPageTabTypeID --StartPageTabType 1=DinersChoice
						,case when MetroRank > 5 
							then null 
							else MetroRank 
							end MetroRank
						,case when (MacroID is null or MacroRank > 5)
							then null 
							else MacroRank 
							end MacroRank
						,RID
						,MetroTopTenListID
						,MacroTopTenListID
	from (
		--Create combination of Metro/Macro list and ranking
		select				isnull(metr.MetroAreaID, macr.MetroAreaID) MetroAreaID
							,macr.MacroID
							--The nulls from the metro side of the list are from RIDs that are in a Macro list but not a Metro list.		
							,row_number() over (partition by isnull(metr.MetroAreaID,macr.MetroAreaID) order by isnull(metr.MetroRank,9999)) MetroRank
							,row_number() over (partition by macr.MacroID order by macr.MacroRank) MacroRank
							,isnull(metr.RID, macr.RID) RID
							,metr.TopTenListID MetroTopTenListID
							,macr.TopTenListID MacroTopTenListID		
		from (
			--ListDisplayOrder for Macro Lists is #1
			select				ttl.MetroAreaID
								,ttl.MacroID
								,ttlr.RID
								,ttlr.[Rank] MacroRank
								,ttl.TopTenListID
			from				TopTenList ttl
			left join			TopTenListInstance ttli
			on					ttl.TopTenListID = ttli.TopTenListID
			left join			TopTenListRestaurant ttlr
			on					ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
			inner join			MetroAreaVW m
			on					ttl.MetroAreaID = m.MetroAreaID
			inner join			NeighborhoodVW n
			on					m.MetroAreaID = n.MetroAreaID
			inner join			RestaurantVW r
			on					n.NeighborhoodID = r.NeighborhoodID
			and					ttlr.RID = r.RID
			left join			TopTenListRestaurantSuppression	ttlrs
			on					ttlrs.TopTenListID				= ttl.TopTenListID
			and					ttlrs.RID						= ttlr.RID
			inner join			@TmpMacroRank tmr
			on					ttl.TopTenListID = tmr.TopTenListID
			where				(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
			and					ttli.TopTenImportJobID = @DCListJobID
			and					isnull(ttli.IsActive,0) = 1
			and					m.ShowRegionLists = 1
			and					ttlrs.RID is null
			and					@RegionalListEnabled = 1
			and					r.RestStateID not in (4,11,15)
		) macr
	full outer join
	(
			--ListDisplayOrder for Metro Lists is #1
			select				 ttl.MetroAreaID
								,ttlr.RID
								,ttlr.[Rank] MetroRank
								,ttl.TopTenListID
			from				TopTenListVW ttl
			left join			TopTenListInstance ttli
			on					ttl.TopTenListID = ttli.TopTenListID
			left join			TopTenListRestaurant ttlr
			on					ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
			inner join			MetroAreaVW m
			on					ttl.MetroAreaID = m.MetroAreaID
			inner join			NeighborhoodVW n
			on					m.MetroAreaID = n.MetroAreaID
			inner join			RestaurantVW r
			on					n.NeighborhoodID = r.NeighborhoodID
			and					ttlr.RID = r.RID
			left join			TopTenListRestaurantSuppression	ttlrs
			on					ttlrs.TopTenListID				= ttl.TopTenListID
			and					ttlrs.RID						= ttlr.RID
			inner join			@TmpMetroRank tmr
			on					ttl.TopTenListID = tmr.TopTenListID
			where				(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
			and					ttli.TopTenImportJobID = @DCListJobID
			and					isnull(ttli.IsActive,0) = 1
			and					ttlrs.RID is null
			and					r.RestStateID not in (4,11,15)			
		) metr
		on					macr.RID = metr.RID
	) comb
	where				(MetroRank <= 5 or
						 MacroRank <= 5)
	-- Production data will not see this case, but put into place for dev data
	and					(MetroRank is not null and 
						 MacroRank is not null)
	
	union all 
	
	-------------------
	-- Village Vines Offers data (only supports metro data)
	-------------------
	select			ro.MetroAreaID
					,null MacroID
					,6 StartPageTabTypeID --StartPageTabType 6=RestaurantOffers
					,ro.MetroRank
					,null MacroRank
					,ro.RID
					,null MetroTopTenListID
					,null MacroTopTenListID
	from
	(
		select			n.MetroAreaID
						,row_number()  over(
							partition by	m.MetroAreaID
							order by		rcc.TotalSeatedStandardCovers desc
											,r.RName asc
						) MetroRank
						,r.RID
		from			ReservationOfferVW ro
		inner join		RestaurantVW r
		on				ro.RID=r.RID
		inner join		Neighborhood n
		on				r.NeighborhoodID = n.NeighborhoodID
		inner join		MetroArea m
		on				m.MetroAreaID = n.MetroAreaID
		inner join		RestaurantCoverCounts rcc
		on				r.RID = rcc.rid
		left join		ValueLookupIDList vlil
		on				ro.RID = vlil.ValueID
		and				vlil.LookupID = @OffersRIDExclusionListID
		inner join		ValueLookupIDList vlil2
		on				m.MetroAreaID = vlil2.ValueID
		and				vlil2.LookupID = @OffersMetroInclusionListID
		where			(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
		and				r.RestStateID in (1,5,6,7,13,16)
		and				ro.OfferStatusID = 1
		and				ro.OfferStartDate < getdate()
		and				ro.OfferEndDate > getdate()
		and				ro.OfferClassID = 3 --Village Vines Offers Class ID
		and				vlil.LookupID is null
	) ro
	where			ro.MetroRank is not null
	and				ro.MetroRank <= 5			 
	
		
	union all 
	-------------------
	-- Promoted Offers data (only supports metro data)
	-------------------	
		
	select			ro.MetroAreaID
				,null MacroID
				,8 StartPageTabTypeID --StartPageTabType 8=PromotedOffers
				,ro.MetroRank
				,null MacroRank
				,ro.RID
				,null MetroTopTenListID
				,null MacroTopTenListID
	from
	(
		select		n.MetroAreaID
					,row_number()  over(
						partition by	m.MetroAreaID
						order by rcc.TotalSeatedStandardCovers desc
								,r.RName asc
					) MetroRank
					,r.RID
		from			
		(
			SELECT DISTINCT rid 
			FROM dbo.ReservationOfferVW 
			WHERE
					OfferStatusID = 1
					and	(OfferStartDate < getdate() OR DisplayOnOTWebSite =1)		 
					and	OfferEndDate > getdate()
					and	OfferClassID = 4 --Promoted Offers Class ID	
		) AS rids
		inner join		RestaurantVW r
		on				rids.RID=r.RID
		inner join		Neighborhood n
		on				r.NeighborhoodID = n.NeighborhoodID
		inner join		MetroArea m
		on				m.MetroAreaID = n.MetroAreaID	
		inner join		RestaurantCoverCounts rcc
		on				r.RID = rcc.rid	
		where			(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
		and				r.RestStateID in (1,5,6,7,13,16)

	) ro
	where			ro.MetroRank is not null
	and			    ro.MetroRank <= 5	
	
	union all 

	-------------------
	-- Chase Curated List data (only supports metro data)
	-------------------
	select			pr.MetroAreaID
					,null MacroID
					,9 StartPageTabTypeID --StartPageTabType 9=CCSponsor
					,pr.MetroRank
					,null MacroRank
					,pr.RID
					,null MetroTopTenListID
					,null MacroTopTenListID
	from
	(
		select			n.MetroAreaID
						,row_number()  over(
							partition by	m.MetroAreaID
							order by		rcc.TotalSeatedStandardCovers desc
											,r.RName asc
						) MetroRank
						,r.RID
		from			RestaurantVW r  
		inner join		Neighborhood n
		on				r.NeighborhoodID = n.NeighborhoodID
		inner join		MetroArea m
		on				m.MetroAreaID = n.MetroAreaID
		inner join		PromoRests pr  
		on				r.RID = pr.RID
		inner join		PromoPages pp  
		on				pr.PromoID = pp.PromoID
		inner join		PromoPagesToMetro pptm
		on				pp.PromoID = pptm.PromoID
		and				m.MetroAreaID = pptm.MetroID
		and				pptm.OnStartPage = 1
		inner join		RestaurantCoverCounts rcc
		on				r.RID = rcc.rid		
		left join		ValueLookupIDList vlil2
		on				vlil2.LookupID = @CCSponsorMetroBlacklistListID
		and				m.MetroAreaID = vlil2.ValueID
		left join		ValueLookupIDList vlil3
		on				vlil3.LookupID = @CCSponsorRIDBlacklistListID
		and				r.RID = vlil3.ValueID
		where			(m.Active = 1 or m.MetroAreaID = 1) -- Metro must be active or demoland
		and				r.RestStateID = 1
		and				r.IsReachable = 1
		and				pp.Active = 1
		and				vlil2.ValueID is null -- Not in CC sponsor Metro blacklist
		and				vlil3.ValueID is null -- Not in CC sponsor RID blacklist
		and				r.Country = 'US'
		AND	            pp.PromoID = @CCSponsorPromoID
	) pr
	where			pr.MetroRank is not null
	and				pr.MetroRank <= 5			 	
	
	-- order all of the data
	order by			StartPageTabTypeID, MetroAreaID, MetroRank

go

GRANT EXECUTE ON [DNCacheStartPageTabData] TO ExecuteOnlyRole
go
