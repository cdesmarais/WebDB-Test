if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procCalculateGeographicCenterPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procCalculateGeographicCenterPoints]
go

create procedure dbo.procCalculateGeographicCenterPoints 
	 @SendEmailReport	bit = 0		-- this now indicates we'll log updates to errrolog (no longer send email)
as 
begin
	---------------------------------------------------------------------------------------------------------
	--Find the median lat and lon for each geographic area.  Addtionally, we now also calculate the lat/lon 
	-- span used for generating static maps
	--1) create temp table with geographic id, avg_lat, avg_lon, latspan and lonspan
	--2) create cursor for all area
	--3) for each area, put the id, median latitude and median mlongitude into variables (2 queries)
	--4) insert into temp table
	--5) Calculate the lat and lon span for all geographic areas and update the temp table
	--6) Update the real table from the temp table
	---------------------------------------------------------------------------------------------------------

	set nocount on
	set transaction isolation level read uncommitted 

	declare @tmpMetroLatLon table
	(
		 MetroAreaID		int
		,AverageLatitude	decimal(10,7)
		,AverageLongitude	decimal(10,7)
		,MetroLatSpan		decimal(10,7)
		,MetroLonSpan		decimal(10,7)
	)

	declare @tmpMacroNeighborhoodLatLon table
	(
		 MacroID			int
		,AverageLatitude	decimal(10,7)
		,AverageLongitude	decimal(10,7)
		,MacroLatSpan		decimal(10,7)
		,MacroLonSpan		decimal(10,7)
	)

	declare @tmpNeighborhoodLatLon table
	(
		 NeighborhoodID		int
		,AverageLatitude	decimal(10,7)
		,AverageLongitude	decimal(10,7)
		,NbHoodLatSpan		decimal(10,7)
		,NbHoodLonSpan		decimal(10,7)
	)

	declare  @MetroAreaID			int
			,@MacroID				int
			,@NeighborhoodID		int
			,@AverageLatitude		decimal(10,7)
			,@AverageLongitude		decimal(10,7)
			,@LogMsg				nvarchar(4000)
			,@ReturnCode			int 

	declare	 @rowcount	int
			,@error		int

	declare @tblWorkingSet table 
	(
		 latitude	decimal(10,7)
		,longitude	decimal(10,7)
	)
	
	declare @CountRequiredForMedian int
	declare @procname varchar(500)

	declare  @DefaultMetroLatSpan	decimal(10,7)
			,@DefaultMacroLatSpan	decimal(10,7)
			,@DefaultNbHoodLatSpan	decimal(10,7)
			,@DefaultMetroLonSpan	decimal(10,7)
			,@DefaultMacroLonSpan	decimal(10,7)
			,@DefaultNbHoodLonSpan	decimal(10,7)
			,@MetroBlackListID		int
			,@MacroBlackListID		int
			,@NBHoodBlackListID		int
	
	set @MetroBlackListID = 26
	set @MacroBlackListID = 27
	set @NbHoodBlackListID = 28
	
	-- If there are 3 or more restaurants, use the median value for center point, otherwise
	-- take the average.
	set @CountRequiredForMedian = 3
	
	-- get name of proc for logging
	set @procname = object_name(@@procid)
	
	-- Error codes are translated to strings in [JobCalculateGeographicCenterPoints]
	-- If error codes are modified, please update [JobCalculateGeographicCenterPoints] as well.
	set @ReturnCode = 0

	-----------------------------------------------------------------------------------------------------
	-- Metros
	-----------------------------------------------------------------------------------------------------

	-- Calculate for all metros, regardless of whether they are active or display on the site.
	-- This allows us to calculate center points for metros that will be turned on in advance of turning 
	-- them on, i.e. metro splits or new metros
	declare curMetro cursor for
		select	metroAreaid 
		from	MetroArea m
		left join	valuelookupidlist vlil
		on			vlil.ValueID = m.MetroAreaID
		and			vlil.LookupID = @MetroBlackListID
		where		vlil.ValueID is null

	open curMetro

	fetch next from curMetro
	into @MetroAreaID

	while @@fetch_status = 0
	begin

		-- Get median latitude
		insert		@tblWorkingSet (			
					latitude, 
					longitude )
		select		latitude, 
					longitude 
		from		Restaurant r
		inner join	Neighborhood n
		on			n.NeighborhoodID = r.NeighborhoodID
		inner join	MacroNeighborhood mn
		on			mn.MacroID = n.MacroID
		inner join	MetroArea m
		on			m.MetroAreaID = mn.MetroAreaID
		where		m.metroareaid = @MetroAreaID 
					and r.RestStateID in (1, 5, 6, 7, 13, 16)
					and r.latitude is not null 
					and r.longitude is not null

		select @rowcount = count(*) from @tblWorkingSet
		if @rowcount > 0 
		begin
		
			-- Use median values if there are 1 or more than 3 restaurants.  If there are 2 or 3 restaurants, 
			-- use the average as it looks better on the map
			if @rowcount >= @CountRequiredForMedian or @rowcount = 1
			begin
				select @AverageLongitude = min(longitude) 
				from 
				(
					select top 50 percent longitude 
					from		@tblWorkingSet
					order by longitude desc
				) a

				select @AverageLatitude = min(latitude) 
				from 
				(
					select top 50 percent latitude 
					from		@tblWorkingSet
					order by	latitude desc
				) a

			end
			else 
			begin
				select 	@AverageLongitude = avg(longitude), @AverageLatitude = avg(latitude) 
				from	@tblWorkingSet
			end	
				
			insert @tmpMetroLatLon	( 
				 MetroAreaID	
				,AverageLatitude
				,AverageLongitude
			) values (
				 @MetroAreaID	
				,@AverageLatitude
				,@AverageLongitude
			)	

			delete @tblWorkingSet
		end 
				
		fetch next from curMetro
		into @MetroAreaID
		
	end

	close curMetro
	deallocate curMetro

	-----------------------------------------------------------------------------------------------------
	-- Macros
	-----------------------------------------------------------------------------------------------------

	-- note, calculate for all macros, regardless of whether they are active
	declare curMacro cursor for
		select		MacroID 
		from		MacroNeighborhood mn
		left join	valuelookupidlist vlil
		on			vlil.ValueID = mn.MacroID
		and			vlil.LookupID = @MacroBlackListID
		where		vlil.ValueID is null

	open curMacro

	fetch next from curMacro
	into @MacroID

	while @@fetch_status = 0
	begin

		-- Get median latitude
		insert		@tblWorkingSet (			
					latitude, 
					longitude )
		select		latitude, 
					longitude 
		from		Restaurant r
		inner join	Neighborhood n
		on			n.NeighborhoodID = r.NeighborhoodID
		inner join	MacroNeighborhood mn
		on			mn.MacroID = n.MacroID
		where		mn.macroid = @MacroID 
					and r.RestStateID in (1, 5, 6, 7, 13, 16)
					and r.latitude is not null 
					and r.longitude is not null


		select @rowcount = count(*) from @tblWorkingSet
		if @rowcount > 0 
		begin
		
			-- Use median values if there are 1 or more than 3 restaurants.  If there are 2 or 3 restaurants, 
			-- use the average as it looks better on the map
			if @rowcount >= @CountRequiredForMedian or @rowcount = 1
			begin
				select @AverageLongitude = min(longitude) 
				from 
				(
					select top 50 percent longitude 
					from		@tblWorkingSet
					order by longitude desc
				) a

				select @AverageLatitude = min(latitude) 
				from 
				(
					select top 50 percent latitude 
					from		@tblWorkingSet
					order by	latitude desc
				) a

			end
			else 
			begin
				select 	@AverageLongitude = avg(longitude), @AverageLatitude = avg(latitude) 
				from	@tblWorkingSet
			end	
				
			insert @tmpMacroNeighborhoodLatLon	( 
				 MacroID	
				,AverageLatitude
				,AverageLongitude
			) values (
				 @MacroID	
				,@AverageLatitude
				,@AverageLongitude
			)	

			delete @tblWorkingSet
		end 
				

		fetch next from curMacro
		into @MacroID
	end

	close curMacro
	deallocate curMacro

	-----------------------------------------------------------------------------------------------------
	-- Neighborhoods
	-----------------------------------------------------------------------------------------------------
	-- note, calculate for all nbhoods, regardless of whether they are active
	declare curNeighborhood cursor for
		select		NeighborhoodID
		from		Neighborhood n
		left join	valuelookupidlist vlil
		on			vlil.ValueID = n.NeighborhoodID
		and			vlil.LookupID = @NbHoodBlackListID
		where		vlil.ValueID is null

	open curNeighborhood

	fetch next from curNeighborhood
	into @NeighborhoodID

	while @@fetch_status = 0
	begin

		-- Get median latitude
		insert		@tblWorkingSet (			
					latitude, 
					longitude )
		select		latitude, 
					longitude 
		from	Restaurant r
		where	r.NeighborhoodID = @NeighborhoodID 
				and r.RestStateID in (1, 5, 6, 7, 13, 16)
				and r.latitude is not null 
				and r.longitude is not null


		select @rowcount = count(*) from @tblWorkingSet
		if @rowcount > 0 
		begin
		
			-- Use median values if there are 1 or more than 3 restaurants.  If there are 2 or 3 restaurants, 
			-- use the average as it looks better on the map
			if @rowcount >= @CountRequiredForMedian or @rowcount = 1
			begin
				select @AverageLongitude = min(longitude) 
				from 
				(
					select top 50 percent longitude 
					from		@tblWorkingSet
					order by longitude desc
				) a

				select @AverageLatitude = min(latitude) 
				from 
				(
					select top 50 percent latitude 
					from		@tblWorkingSet
					order by	latitude desc
				) a

			end
			else 
			begin
				select 	@AverageLongitude = avg(longitude), @AverageLatitude = avg(latitude) 
				from	@tblWorkingSet
			end	
				
			insert @tmpNeighborhoodLatLon	( 
				 NeighborhoodID	
				,AverageLatitude
				,AverageLongitude
			) values (
				 @NeighborhoodID	
				,@AverageLatitude
				,@AverageLongitude
			)	

			delete @tblWorkingSet
		end 

		fetch next from curNeighborhood
		into @NeighborhoodID
	end

	close curNeighborhood
	deallocate curNeighborhood


	----------------------------------------------------------------------------------------
	-- Now calculate the lat and lon spans used for static map generation
	-- Look at the 80 percent of restaurants closest to the center of the gegraphic area.
	-- Then for an area centered on the area's center point, find the latitude and longitude 
	-- spans that cover those restaurants, when centered on the area's center point
	-- TODO: UPDATE BELOW SO IT USES A BLACKLIST TO OVERRIDE CALCULATED VALUES
	----------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------------
	-- update metro lat/lon spans into temp table
	----------------------------------------------------------------------------------------
	update	@tmpMetroLatLon
	set		 MetroLatSpan = b.MetroLatSpan
			,MetroLonSpan = b.MetroLonSpan
	from	@tmpMetroLatLon t
	inner join (
		select   case when abs(clt-mnlt) >= abs(clt-mxlt) then abs(clt-mnlt) * 2 else abs(clt-mxlt) * 2 end MetroLatSpan
				,case when abs(cln-mnln) >= abs(cln-mxln) then abs(cln-mnln) * 2 else abs(cln-mxln) * 2 end MetroLonSpan
				,a.MetroAreaID
		from (
			select	 m.MetroAreaID
					,m.MetroCenterLat clt
					,m.MetroCenterLon cln
					,(	
						select min(latitude) minlat
						from (	select top 80 percent latitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.metroareaid = m.MetroAreaID
								order by r.latitude desc
							) x 
						) mnlt
					,(	
						select min(longitude) minlon
						from (	select top 80 percent longitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.metroareaid = m.MetroAreaID
								order by r.longitude desc
							) x 
						) mnln
					,(	
						select max(latitude) maxlat
						from (	select top 80 percent latitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.metroareaid = m.MetroAreaID
								order by r.latitude
							) x 
						) mxlt
					,(	
						select max(longitude) maxlon
						from (	select top 80 percent longitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.metroareaid = m.MetroAreaID
								order by r.longitude 
							) x 
						) mxln
			from metroarea m
			left join valuelookupidlist vlil
			on vlil.ValueID = m.MetroAreaID
			and vlil.LookupID = @MetroBlackListID
			where vlil.ValueID is null
		) a
	) b
	on b.metroareaid = t.metroareaid


	----------------------------------------------------------------------------------------
	-- Update macro lat/lon spans, same as above
	----------------------------------------------------------------------------------------
	update	@tmpMacroNeighborhoodLatLon
	set		 MacroLatSpan = b.MacroLatSpan
			,MacroLonSpan = b.MacroLonSpan
	from	@tmpMacroNeighborhoodLatLon t
	inner join (
		select   case when abs(clt-mnlt) >= abs(clt-mxlt) then abs(clt-mnlt) * 2 else abs(clt-mxlt) * 2 end MacroLatSpan
				,case when abs(cln-mnln) >= abs(cln-mxln) then abs(cln-mnln) * 2 else abs(cln-mxln) * 2 end MacroLonSpan
				,a.macroid
		from (
			select	 m.MacroID
					,m.MacroCenterLat clt
					,m.MacroCenterLon cln
					,(	
						select min(latitude) minlat
						from (	select top 80 percent latitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.macroid = m.macroid
								order by r.latitude desc
							) x 
						) mnlt
					,(	
						select min(longitude) minlon
						from (	select top 80 percent longitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.macroid = m.macroid
								order by r.longitude desc
							) x 
						) mnln
					,(	
						select max(latitude) maxlat
						from (	select top 80 percent latitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.macroid = m.macroid
								order by r.latitude
							) x 
						) mxlt
					,(	
						select max(longitude) maxlon
						from (	select top 80 percent longitude
								from Restaurant r
								inner join Neighborhood n
								on n.NeighborhoodID = r.NeighborhoodID
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and n.macroid = m.macroid
								order by r.longitude 
							) x 
						) mxln
			from MacroNeighborhood m
			left join valuelookupidlist vlil
			on vlil.ValueID = m.MacroID
			and vlil.LookupID = @MacroBlackListID
			where vlil.ValueID is null
		) a
	) b
	on b.macroid = t.macroid
	

	----------------------------------------------------------------------------------------
	-- Update nbhood lat/lon spans, same as above 
	----------------------------------------------------------------------------------------
	update	@tmpNeighborhoodLatLon
	set		 NBHoodLatSpan = b.NBHoodLatSpan
			,NBHoodLonSpan = b.NBHoodLonSpan
	from	@tmpNeighborhoodLatLon t
	inner join (
		select   case when abs(clt-mnlt) >= abs(clt-mxlt) then abs(clt-mnlt) * 2 else abs(clt-mxlt) * 2 end NBHoodLatSpan
				,case when abs(cln-mnln) >= abs(cln-mxln) then abs(cln-mnln) * 2 else abs(cln-mxln) * 2 end NBHoodLonSpan
				,a.NeighborhoodID
		from (
			select	 n.NeighborhoodID
					,n.NBHoodCenterLat clt
					,n.NBHoodCenterLon cln
					,(	
						select min(latitude) minlat
						from (	select top 80 percent latitude
								from Restaurant r
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and r.NeighborhoodID = n.NeighborhoodID
								order by r.latitude desc
							) x 
						) mnlt
					,(	
						select min(longitude) minlon
						from (	select top 80 percent longitude
								from Restaurant r
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and r.NeighborhoodID = n.NeighborhoodID
								order by r.longitude desc
							) x 
						) mnln
					,(	
						select max(latitude) maxlat
						from (	select top 80 percent latitude
								from Restaurant r
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and r.NeighborhoodID = n.NeighborhoodID
								order by r.latitude
							) x 
						) mxlt
					,(	
						select max(longitude) maxlon
						from (	select top 80 percent longitude
								from Restaurant r
								where r.RestStateID in (1, 5, 6, 7, 13, 16) and r.latitude is not null and r.longitude is not null and r.NeighborhoodID = n.NeighborhoodID
								order by r.longitude 
							) x 
						) mxln
			from Neighborhood n
			left join valuelookupidlist vlil
			on vlil.ValueID = n.NeighborhoodID
			and vlil.LookupID = @NbHoodBlackListID
			where vlil.ValueID is null
		) a
	) b
	on b.neighborhoodid = t.neighborhoodid

	--select * from @tmpNeighborhoodLatLon

	-------------------------------------------------------------------------------
	-- Get update stats for email
	-------------------------------------------------------------------------------
	
	-- @SendEmailReport: indicates we will log report to the errorlog
	if @SendEmailReport = 1 
	begin
		
		-- Note if everything gets updated this buffer for the email body will not be large enough and will truncate.
		set @LogMsg = 'Metroid, old lat, new lat, old lon, new lon'
		
		-- add metros being updated
		select			@LogMsg = coalesce(@LogMsg + char(13) + char(10), '') 
						+ cast(m.MetroAreaID as varchar) + ','
						+ cast(isnull(cast(m.MetroCenterLat as decimal(10,4)),0) as varchar) +','+cast(cast(t.AverageLatitude as decimal(10,4)) as varchar)+','
						+ cast(isnull(cast(m.MetroCenterLon as decimal(10,4)),0) as varchar) +','+cast(cast(t.AverageLongitude as decimal(10,4)) as varchar)
		from		MetroArea m
		inner join	@tmpMetroLatLon t
		on			t.MetroAreaID = m.MetroAreaID
		where		t.AverageLatitude is not null
					and t.AverageLongitude is not null
					and (t.AverageLatitude != isnull(m.MetroCenterLat,0)
					or t.AverageLongitude != isnull(m.MetroCenterLon,0) )

		set @LogMsg = @LogMsg + char(13) + char(10) + 'Macroid, old lat, new lat, old lon, new lon'
		set @LogMsg = @LogMsg + char(13) + char(10)
		
		-- add macros being updated
		select			@LogMsg = coalesce(@LogMsg + char(13) + char(10), '') 
						+ cast(m.MacroID as varchar) + ','
						+ cast(isnull(cast(m.MacroCenterLat as decimal(10,4)),0) as varchar) +','+cast(cast(t.AverageLatitude as decimal(10,4)) as varchar)+','
						+ cast(isnull(cast(m.MacroCenterLon as decimal(10,4)),0) as varchar) +','+cast(cast(t.AverageLongitude as decimal(10,4)) as varchar)
		from		MacroNeighborhood m
		inner join	@tmpMacroNeighborhoodLatLon t
		on			t.MacroID = m.MacroID
		where		t.AverageLatitude is not null
					and t.AverageLongitude is not null
					and (t.AverageLatitude != isnull(m.MacroCenterLat,0)
					or t.AverageLongitude != isnull(m.MacroCenterLon,0) )

		set @LogMsg = @LogMsg + char(13) + char(10) + 'Neighborhoodid, old lat, new lat, old lon, new lon'
		set @LogMsg = @LogMsg + char(13) + char(10)
			
		-- add macros being updated
		select			@LogMsg = coalesce(@LogMsg + char(13) + char(10), '') 
						+ cast(n.NeighborhoodID as varchar) + ','
						+ cast(isnull(cast(n.NbHoodCenterLat as decimal(10,4)),0) as varchar) +','+cast(cast(t.AverageLatitude as decimal(10,4)) as varchar)+','
						+ cast(isnull(cast(n.NbHoodCenterLon as decimal(10,4)),0) as varchar) +','+cast(cast(t.AverageLongitude as decimal(10,4)) as varchar)
		from		Neighborhood n
		inner join	@tmpNeighborhoodLatLon t
		on			t.NeighborhoodID = n.NeighborhoodID
		where		t.AverageLatitude is not null
					and t.AverageLongitude is not null
					and (t.AverageLatitude != isnull(n.NbHoodCenterLat,0)
					or t.AverageLongitude != isnull(n.NbHoodCenterLon,0) )
		
	end

	-------------------------------------------------------------------------------
	-- Update the real tables
	-------------------------------------------------------------------------------

	begin transaction

	update		MetroArea
	set			 MetroCenterLat = t.AverageLatitude
				,MetroCenterLon = t.AverageLongitude
				,MetroLatSpan = t.MetroLatSpan
				,MetroLonSpan = t.MetroLonSpan
	from		MetroArea m
	inner join	@tmpMetroLatLon t
	on			t.MetroAreaID = m.MetroAreaID
	where		t.AverageLatitude is not null
				and t.AverageLongitude is not null
				and (t.AverageLatitude != isnull(m.MetroCenterLat,0)
				or t.AverageLongitude != isnull(m.MetroCenterLon,0) 				
				or t.MetroLatSpan != isnull(m.MetroLatSpan,0)
				or t.MetroLonSpan != isnull(m.MetroLonSpan,0) )


	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -1
		goto Script_Error
	end
		   
	update		MacroNeighborhood
	set			 MacroCenterLat = t.AverageLatitude
				,MacroCenterLon = t.AverageLongitude
				,MacroLatSpan = t.MacroLatSpan
				,macroLonSpan = t.MacroLonSpan
	from		MacroNeighborhood m
	inner join	@tmpMacroNeighborhoodLatLon t
	on			t.MacroID = m.MacroID
	where		t.AverageLatitude is not null
				and t.AverageLongitude is not null
				and (t.AverageLatitude != isnull(m.MacroCenterLat,0)
				or t.AverageLongitude != isnull(m.MacroCenterLon,0)
				or t.MacroLatSpan != isnull(m.MacroLatSpan,0)
				or t.MacroLonSpan != isnull(m.MacroLonSpan,0) )

	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -2
		goto Script_Error
	end

	update		Neighborhood
	set			NbHoodCenterLat = t.AverageLatitude
				,NbHoodCenterLon = t.AverageLongitude
				,NbHoodLatSpan = t.NbHoodLatSpan
				,NbHoodLonSpan = t.NbHoodLonSpan
	from		Neighborhood n
	inner join	@tmpNeighborhoodLatLon t
	on			t.NeighborhoodID = n.NeighborhoodID
	where		t.AverageLatitude is not null
				and t.AverageLongitude is not null
				and (t.AverageLatitude != isnull(n.NbHoodCenterLat,0)
				or t.AverageLongitude != isnull(n.NbHoodCenterLon,0)
				or t.NBHoodLatSpan != isnull(n.NBHoodLatSpan,0)
				or t.NBHoodLonSpan != isnull(n.NBHoodLonSpan,0) )
		
	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -3
		goto Script_Error
	end


	----------------------------------------------------------------------------------------
	-- If any neighborhoods or macros have null center points, update their center 
	-- point to the center point of their closest parent 
	----------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------
	-- for neighborhoods, if center point is not valid, use macro center point if it's
	-- valid, otherwise use the metor.  The case statement ensures that we get an actual full 
	-- center point from a single geographic area, i.e. we don't get a lat from macro and a 
	-- lon from metro, or some such combo.
	----------------------------------------------------------------------------------------
	update		Neighborhood
	set			 NbHoodCenterLat =	case 
										when	mn.MacroCenterLat is not null 
												and mn.MacroCenterLon is not null 
										then	mn.MacroCenterLat
										else	m.MetroCenterLat
									end
				,NbHoodCenterLon =	case 
										when	mn.MacroCenterLat is not null 
												and mn.MacroCenterLon is not null 
										then	mn.MacroCenterLon
										else	m.MetroCenterLon
									end
	from		Neighborhood n
	inner join	MacroNeighborhood mn
	on			mn.MacroID = n.MacroID
	inner join	MetroArea m
	on			m.MetroAreaID = mn.MetroAreaID
	where		n.NbHoodCenterLat is null or 
				n.NbHoodCenterLon is null

	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -4
		goto Script_Error
	end

	----------------------------------------------------------------------------------------
	-- use metro center point for macros that have invalid center points
	----------------------------------------------------------------------------------------
	update		MacroNeighborhood
	set			 MacroCenterLat = m.MetroCenterLat
				,MacroCenterLon = m.MetroCenterLon
	from		MacroNeighborhood mn
	inner join	MetroArea m
	on			m.MetroAreaID = mn.MetroAreaID
	where		mn.MacroCenterLat is null or 
				mn.MacroCenterLon is null

	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -5
		goto Script_Error
	end


	----------------------------------------------------------------------------------------
	-- update lat and lon spans when null
	----------------------------------------------------------------------------------------
	
	-- set all spans that are null or 0 to an approximately 1 square mile area
	-- (1 degree of latitude is 69.2 miles...)
	set @DefaultMetroLatSpan	= .0144
	set @DefaultMetroLonSpan	= .0144
	set @DefaultMacroLatSpan	= .0144
	set @DefaultMacroLonSpan	= .0144
	set @DefaultNbHoodLatSpan	= .0144
	set @DefaultNbHoodLonSpan	= .0144

	update	metroarea 
	set		 MetroLatSpan = @DefaultMetroLatSpan
			,MetroLonSpan = @DefaultMetroLonSpan
	where	MetroLatSpan is null 
	or		MetroLatSpan = 0
	or		MetroLonSpan is null
	or		MetroLonSpan = 0

	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -6
		goto Script_Error
	end


	update	macroneighborhood 
	set		 MacroLatSpan = @DefaultMacroLatSpan
			,MacroLonSpan = @DefaultMacroLonSpan
	where	MacroLatSpan is null 
	or		MacroLatSpan = 0
	or		MacroLonSpan is null
	or		MacroLonSpan = 0

	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -7
		goto Script_Error
	end

	update	Neighborhood 
	set		 NbHoodLatSpan = @DefaultNbHoodLatSpan
			,NbHoodLonSpan = @DefaultNbHoodLonSpan
	where	NbHoodLatSpan is null 
	or		NbHoodLatSpan = 0
	or		NbHoodLonSpan is null
	or		NbHoodLonSpan = 0

	select @error = @@error
	if @error != 0
	begin
		set @ReturnCode = -8
		goto Script_Error
	end

	commit


	
	-- Note, email is not sent in the event of an error, a nagios alert is raised.
	if @SendEmailReport = 1 
	begin
		exec DNErrorAdd
			@Errorid = 9020, 
			@ErrMsg = @LogMsg, 
			@ErrStackTrace = @procname, 
			@ErrSeverity = 2
	end		

	goto Script_Exit

	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------
	Script_Error:
	rollback

	exec DNErrorAdd
		@Errorid = 9020, 
		@ErrMsg = @ReturnCode, 
		@ErrStackTrace = @procname, 
		@ErrSeverity = 2

	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------
	Script_Exit:

	-----------------------------------------------------------------------------------------------------
	-- Clean up
	-----------------------------------------------------------------------------------------------------

	-- nothing to do

	return @ReturnCode
end
go

GRANT EXECUTE ON [procCalculateGeographicCenterPoints] TO ExecuteOnlyRole

GO
