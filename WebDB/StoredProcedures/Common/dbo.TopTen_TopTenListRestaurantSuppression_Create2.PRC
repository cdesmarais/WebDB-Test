if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListRestaurantSuppression_Create2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListRestaurantSuppression_Create2]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListRestaurantSuppression_Create2]
(
    @TopTenListID int,    
    @RID int,  -- Restaurant ID
	@MacroNeighborhoodID int = null,
    @ModifiedBy nchar(255)  -- username of modifying user
)
As

SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE

--If this PK aready exists in the table, exit with a -1 status code
IF EXISTS
(
    SELECT 1
        FROM TopTenListRestaurantSuppression
        WHERE TopTenListID = @TopTenListID
        AND RID = @RID
)
BEGIN
    RETURN -1;
END
ELSE
BEGIN
   
	BEGIN TRANSACTION TRANSTTLRSC

	--check if this metro is enabled for regional lists
	Declare @IsRegionalListEnabled bit
	Declare @SecondaryTopTenListID int --The TTLID of the parent or child list
	Declare @PrimaryTopTenListTypeid int
	
	Select		 @IsRegionalListEnabled = m.ShowRegionLists								
	From		MetroAreaVW m
	Inner Join	TopTenList ttl On m.MetroAreaID = ttl.MetroAreaID
	Where		TopTenListID = @TopTenListID		
	
	if(@IsRegionalListEnabled = 1) --If metro has regional lists enabled
		BEGIN		
		
			Set		@SecondaryTopTenListID = 0
			
			-- Get the toptenlisttypeid of the primary list, so we can prevent a PK constraint violat
			Select		@PrimaryTopTenListTypeid = t.TopTenListTypeID							
			From		TopTenList t		
			Where		t.TopTenListID = @TopTenListID
			
		
			if(@MacroNeighborhoodID is not null AND @PrimaryTopTenListTypeID != 22) --If this is a regional list, get the parent TopTenListID
				BEGIN
										
					Select		@SecondaryTopTenListID = ttl2.TopTenListID
					From		TopTenList ttl1
					Inner Join	TopTenList ttl2 on ttl1.TopTenListTypeID = ttl2.TopTenListTypeID
					And			ttl2.MacroID is null	
					And			ttl2.MetroAreaID = ttl1.MetroAreaID
					Where		ttl1.TopTenListID = @TopTenListID
				
				END

			if(@MacroNeighborhoodID is null AND @PrimaryTopTenListTypeID != 22) --If this is not a regional list, get the child TopTenListID
				BEGIN
				
					--Get the Macroneighborhoodid of the restaurant
					Select		@MacroNeighborhoodID = mn.MacroID
					from		MacroNeighborhoodVW mn
					inner join	NeighborhoodVW n on mn.MacroID = n.MacroID
					inner join	RestaurantVW r on n.NeighborhoodID = r.NeighborhoodID
					Where		r.RID = @RID
					
					Select		@SecondaryTopTenListID = ttl2.TopTenListID
					From		TopTenList ttl1
					Inner Join	TopTenList ttl2 on ttl1.TopTenListTypeID = ttl2.TopTenListTypeID -- join to the child record					
					And 		ttl2.MacroID = @MacroNeighborhoodID
					And			ttl2.MetroAreaID = ttl1.MetroAreaID					
					Where		ttl1.TopTenListID = @TopTenListID
																		
				END
				
			if exists --if the secondary list id is already suppressed, exit with an error code of -1
			(
				SELECT 1
		        FROM TopTenListRestaurantSuppression
		        WHERE TopTenListID = @SecondaryTopTenListID
		        AND RID = @RID
			)
			begin
				rollback transaction TRANSTTLRSC
				RETURN -1;
			end
			
			
		END
		
	insert into [dbo].[TopTenListRestaurantSuppression]
	values  (@TopTenListID, @RID)

	if (@@ERROR <> 0) 
			GOTO general_error
	
	if(@IsRegionalListEnabled = 1 AND @SecondaryTopTenListID > 0)
	BEGIN	
	
		-- If Regional lists enabled, insert the child or parent list record into TopTenList
		insert into [dbo].[TopTenListRestaurantSuppression]
		values  (@SecondaryTopTenListID, @RID)
		
	if (@@ERROR <> 0) 
		GOTO general_error

	END
			
	--log a timestamp on the TopTenList record        
	update  TTL
	set     LastModified = GETDATE(),
			LastModifiedBy = @ModifiedBy 
	from	[dbo].[TopTenList] TTL
	where   TTL.TopTenListID = @TopTenListID


	IF (@@ERROR <> 0) 
			GOTO general_error
	        
	--If regional lists enabled, log timestamp on the parent/child list record as well
	if(@IsRegionalListEnabled = 1 AND @SecondaryTopTenListID > 0)
	BEGIN
	
		update  TTL
		set     LastModified = GETDATE(),
				LastModifiedBy = @ModifiedBy 
		from	[dbo].[TopTenList] TTL
		where   TTL.TopTenListID = @SecondaryTopTenListID
		
		IF (@@ERROR <> 0) 
				GOTO general_error		
		
	END
			
	COMMIT TRANSACTION TRANSTTLRSC
	RETURN(0)

END

-- Handle Error cases.
general_error:
	ROLLBACK TRANSACTION TRANSTTLRSC
	RAISERROR('1',16,2) -- Generic error message
	RETURN(1)


GO

GRANT EXECUTE ON [dbo].[TopTen_TopTenListRestaurantSuppression_Create2] TO ExecuteOnlyRole

GO

