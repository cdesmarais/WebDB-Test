if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procTopTenReorderMetroAreaLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procTopTenReorderMetroAreaLists]
GO

create procedure [dbo].[procTopTenReorderMetroAreaLists] 
(
 @metroareaid	int
)
as
		
	declare @DBError 	int	
	
	--Check if MetroAreaID is valid, if not exit
	if(select MetroAreaID from MetroAreaVW where MetroAreaID = @metroareaid) is null
	begin
		raiserror('Invalid MetroAreaID',16,1)
		return(1)
	end
							
		declare @lists table (
		TopTenListID int not null,
		FinalDisplayOrder int identity not null
		)	
				
		--fill the @lists table with the existing lists 
		insert into 	@lists (toptenlistid)
		select 			toptenlistid
		from 			toptenlist
		where 			metroareaid = @metroareaid
		AND				(MacroID IS NULL OR TopTenListTypeID = 22)	
		order by		listdisplayorder
		
		set @DBError = @@error
		if @DBError <> 0
		goto general_error
					
		--update the top ten list table with changes from @lists				
		update ttl
		set listdisplayorder = l.finaldisplayorder
		from toptenlist ttl
		inner join @lists l on ttl.toptenlistid = l.toptenlistid		
		
		set @DBError = @@error
		if @DBError <> 0
		goto general_error

	return (0) 
			
general_error:	
	return(1)

GO

grant execute on [procTopTenReorderMetroAreaLists] TO ExecuteOnlyRole

GO

