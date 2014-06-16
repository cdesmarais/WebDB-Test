if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Favorite_UpdateForCaller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Favorite_UpdateForCaller]
GO

CREATE Procedure dbo.Concierge_Favorite_UpdateForCaller
 (
  @UserID int,
  @GeoID int,
  @FolderID int,
  @Restaurants nvarchar(1999) =  ''
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

declare @i int
if right(@Restaurants,1) <> ',' select @Restaurants= @Restaurants + ','

DELETE CallerRestaurants
FROM CallerRestaurants cr
INNER JOIN Caller 
ON cr.CallerID = Caller.CallerID
INNER JOIN Restaurant r
ON cr.RID = r.RID
INNER JOIN Neighborhood n 
ON r.neighborhoodid = n.neighborhoodid
WHERE (Caller.CallerID = @UserID) AND
    (n.metroareaid = @GeoID) AND (cr.FolderID = @FolderID)
if (@Restaurants is not null)
BEGIN
	if right(@Restaurants,1) <> ',' select @Restaurants= @Restaurants + ','
	while 1=1
	begin
	select @i= charindex(',',@Restaurants)
 	if @i = 0 break
  		insert into CallerRestaurants(CallerID,FolderID,RID)
  		select @UserID,@FolderID,convert(int,substring(@Restaurants,1,@i - 1))
  		select @Restaurants= substring(@Restaurants,@i + 1,999)
	end
END
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
	
GO

GRANT EXECUTE ON [Concierge_Favorite_UpdateForCaller] TO ExecuteOnlyRole

GO
