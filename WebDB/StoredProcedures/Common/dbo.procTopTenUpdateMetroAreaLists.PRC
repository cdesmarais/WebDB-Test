if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenUpdateMetroAreaLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenUpdateMetroAreaLists]
GO

create procedure [dbo].[procTopTenUpdateMetroAreaLists] 
(
 @metroareaid	int,
 @dffstartdt	datetime,
 @dbstartdt		datetime --this needs to be the dffstartdt value stored in the db prior to the update in the parent procedure/transaction
)
as

	declare @regionallisttypeid int
	declare @macroid 	int
	declare @dberror 	int
	declare @maxorder	int
	
	set @regionallisttypeid =  22
	
	--Check if MetroAreaID is valid, if not exit
	if(select MetroAreaID from MetroAreaVW where MetroAreaID = @metroareaid) is null
	begin
		raiserror('Invalid MetroAreaID',17,1)
		return(1)
	end
	
	--if dff start has been set (and does not already have a value in the db) check that all appropriate lists have been generated
	if((@dffstartdt is not null and @dffstartdt !='') and (@dbstartdt is null or @dbstartdt =''))
	begin						
		
		declare @lists table (
		TopTenListTypeID int not null,
		FinalDisplayOrder int identity not null,
		ListDisplayOrder int not null,
		ListNameOverride nvarchar(100),
		MetroAreaID int not null,
		MediaStore_FeedListID int null,
		MacroID int null,
		CuisineID int null,
		NeighborhoodID int null		
		)		
				
		--fill the @lists table with lists that have not been created for this metro
		insert into 	@lists (toptenlisttypeid, listdisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, neighborhoodid)
		select 			toptenlisttypeid,defaultdisplayorder,@metroareaid, mediastore_feedlistid, null, cuisineid, null  
		from 			toptenlisttype ttlt
		where 			ttlt.toptenlisttypeid not in(
			select	toptenlisttypeid
			from	toptenlist
			where 	metroareaid = @metroareaid
		) 	and TopTenListTypeID != 22 --no regional lists
		order by		defaultdisplayorder
		
		set @DBError = @@error
		if @DBError <> 0
		goto general_error
			
		--fill the @lists table with any regional lists that have not been created for this metro		
		declare @toprankregion int, @sortord int														
		select 		top 1 @TopRankRegion = mn.MacroID
		from 		metroarea ma
		inner join 	MacroNeighborhoodVW mn on ma.metroareaid = mn.metroareaid
		where 		ma.metroareaid = @MetroAreaID		
		order by 	coalesce(sortorder,2)
		
		if((@TopRankRegion is not null)  AND  (@TopRankRegion > 0)) --if this metro has regions
			begin			

			--Populate the regions
			insert into 	@lists (toptenlisttypeid, listdisplayorder, listnameoverride, metroareaid, mediastore_feedlistid, macroid, cuisineid, neighborhoodid)				
			select 			@regionallisttypeid, 0, macroname, @metroareaid, ttlt.mediastore_feedlistid, macroid, null, null 
			from 			macroneighborhoodvw mn
			inner join 		toptenlisttype ttlt on @regionallisttypeid = ttlt.toptenlisttypeid				
			where 			macroid not in (
							select mnv.MacroID from macroneighborhoodVW mnv
							inner join	toptenlist ttl on mnv.MacroID = ttl.MacroID
							where	ttl.MetroAreaID = @MetroAreaID
					)				
			and 		metroareaid = @metroareaid 
			order by		mn.sortorder
				
			set @DBError = @@error
			if @DBError <> 0
			goto general_error
			
			end			
			
			--re-order the @lists table using the max listdisplayorder from toptenlist as the base value for the new lists
			declare @cnt1 int
			declare @cnt2 int

			select @maxorder = ISNULL(max(listdisplayorder)+1,1) from toptenlist where metroareaid = @metroareaid
			
			set @cnt2 = 1
			select @cnt1 = count(*) from @lists

			while (@cnt2 <= @cnt1) 
			begin
				update	@lists
			    set		ListDisplayOrder = @maxorder
				where	finaldisplayorder = @cnt2
			   
				set @maxorder = @maxorder + 1
				set @cnt2 = @cnt2 + 1

			end

			set @DBError = @@error
			if @DBError <> 0
			goto general_error
					
			--update the top ten list table with changes from @lists				
			--Insert the contents of only the new records in @lists table variable into the TopTenList table
			insert into 	toptenlist ( listnameoverride, toptenlisttypeid, listdisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, lastmodified, lastmodifiedby)
			select  		listnameoverride, toptenlisttypeid, listdisplayorder, metroareaid, mediastore_feedlistid, macroid, cuisineid, getdate(), 'init'
			from 			@lists
			order by 		finaldisplayorder			
			
			set @DBError = @@error
			if @DBError <> 0
			goto general_error
	
	end

	
	
	--write to audit log table if the dff start date has changed
	if ((@dffstartdt is not null and @dffstartdt != '') and (@dbstartdt is null or @dbstartdt = ''))
	--activate metro	
	begin
		insert into 	OTTopTenSchemaAudit (metroareaid, operationtypeid)
		values 			(@metroareaid, 4)  --operationtypeid of '4' is 'activate'
		
		set @DBError = @@error
		if @DBError <> 0
		goto general_error
	end
		
	if ((@dbstartdt is not null and @dbstartdt != '') and (@dffstartdt is null or @dffstartdt=''))
	--deactivate metro		
	begin
		insert into 	OTTopTenSchemaAudit (metroareaid, operationtypeid)
		values 			(@metroareaid, 3)  --operationtypeid of '3' is 'deactivate'
		
		set @DBError = @@error
		if @DBError <> 0
		goto general_error
	end





	return (0) 
			

general_error:	
	return(1)

GO

grant execute on [procTopTenUpdateMetroAreaLists] TO ExecuteOnlyRole

GO

