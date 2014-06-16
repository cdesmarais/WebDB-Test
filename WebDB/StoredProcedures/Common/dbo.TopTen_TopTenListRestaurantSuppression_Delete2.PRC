if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListRestaurantSuppression_Delete2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListRestaurantSuppression_Delete2]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListRestaurantSuppression_Delete2]
(
    @TopTenListID int,    
    @RID int,  -- Restaurant ID  
	@MacroNeighborhoodID int = null,
    @ModifiedBy nchar(255)  -- username of modifying user
)
As

SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION TRANS1


	Declare @IsRegionalListEnabled bit
	Declare @SecondaryTopTenListID int --The TTLID of the parent or child list
	
	Select		 @IsRegionalListEnabled = m.ShowRegionLists								
	From		MetroAreaVW m
	Inner Join	TopTenList ttl On m.MetroAreaID = ttl.MetroAreaID
	Where		TopTenListID = @TopTenListID
	
	--delete the primary list entry in ttlrs
	delete 
	from [dbo].[TopTenListRestaurantSuppression]
	where   TopTenListID = @TopTenListID
	        and RID = @RID

	IF (@@ERROR <> 0) 
		GOTO general_error
			
	--if Regional lists enabled	delete the secondary list suppression too
	If(@IsRegionalListEnabled = 1)
	Begin
	
		--Get secondary list id
		if(@MacroNeighborhoodID is not null) --If this is a regional list, get the parent TopTenListID
				begin
										
					Select		@SecondaryTopTenListID = ttl2.TopTenListID
					From		TopTenList ttl1
					Inner Join	TopTenList ttl2 on ttl1.TopTenListTypeID = ttl2.TopTenListTypeID
					And			ttl2.MacroID is null	
					And			ttl2.MetroAreaID = ttl1.MetroAreaID
					Where		ttl1.TopTenListID = @TopTenListID
				
				end

		if(@MacroNeighborhoodID is null) --If this is not a regional list, get the child TopTenListID
				begin
				
					--Get the Macroneighborhoodid of the restaurant
					Select		@MacroNeighborhoodID = mn.MacroID
					from		MacroNeighborhoodVW mn
					inner join	NeighborhoodVW n on mn.MacroID = n.MacroID
					inner join	RestaurantVW r on n.NeighborhoodID = r.NeighborhoodID
					Where		r.RID = @RID
				
					Select		@SecondaryTopTenListID = ttl2.TopTenListID
					From		TopTenList ttl1
					Inner Join	TopTenList ttl2 on ttl1.TopTenListTypeID = ttl2.TopTenListTypeID -- join to the child record
					And			ttl2.MetroAreaID = ttl1.MetroAreaID
					And			ttl2.MacroID = @MacroNeighborhoodID
					Where		ttl1.TopTenListID = @TopTenListID
				
				end
	
		if(@SecondaryTopTenListID > 0)
		begin
			--delete the secondary list entry in ttlrs
			delete 
			from [dbo].[TopTenListRestaurantSuppression]
			where   TopTenListID = @SecondaryTopTenListID
					and RID = @RID
		end
					
		IF (@@ERROR <> 0) 
			GOTO general_error
				
		
		if(@SecondaryTopTenListID > 0)
		begin
			update	TTL --log a timestamp on the Secondary TopTenList record       
			set     LastModified = GETDATE(),
			        LastModifiedBy = @ModifiedBy  
			from	[dbo].[TopTenList] TTL		    
			where   TTL.TopTenListID = @SecondaryTopTenListID
		end

		IF (@@ERROR <> 0) 
				GOTO general_error
		
	End
	
  
  
update	TTL --log a timestamp on the TopTenList record       

set     LastModified = GETDATE(),
        LastModifiedBy = @ModifiedBy  

from	[dbo].[TopTenList] TTL
    
where   TTL.TopTenListID = @TopTenListID
        

IF (@@ERROR <> 0) 
		GOTO general_error
        





        
COMMIT TRANSACTION TRANS1

RETURN(0)

-- Handle Error cases.

general_error:
	ROLLBACK TRANSACTION TRANS1
	RAISERROR('1',16,2) -- Generic error message
	RETURN(1)

GO



GRANT EXECUTE ON [dbo].[TopTen_TopTenListRestaurantSuppression_Delete2] TO ExecuteOnlyRole

GO

