if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobRestaurantPOPRankingsPopulate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobRestaurantPOPRankingsPopulate]
GO

create procedure [dbo].[JobRestaurantPOPRankingsPopulate]
as
-- everything in a transaction  
BEGIN TRANSACTION  

	BEGIN TRY  

		DELETE FROM RestaurantPOPRankings  

		INSERT INTO RestaurantPOPRankings (RID, Rank, UpdateDate)  
		SELECT 	 RID  
				,Rank
				,UpdateDate  
		FROM  RestaurantPOPRankingsStage  
	END TRY  
	BEGIN CATCH  
	  ROLLBACK TRANSACTION  
	  DECLARE @Err NVARCHAR(2000)  
	  SET @Err = 'JobRestaurantPOPRankingsPopulate Error:' + ERROR_MESSAGE()  
	  RAISERROR (@Err, 16, 1)  
	  RETURN  
	END CATCH  

	COMMIT TRANSACTION  
GO

GRANT EXECUTE ON [JobRestaurantPOPRankingsPopulate] TO ExecuteOnlyRole
GO
GRANT EXECUTE ON [JobRestaurantPOPRankingsPopulate] TO DTR_User
GO