if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AverageCheck_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AverageCheck_List]
GO

CREATE Procedure dbo.Admin_AverageCheck_List
(            
  @RestaurantID  int = 0        
)            
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @CountryID as varchar(2)
Declare @LanguageID as int
  
	-- Get Language of user and primary country in case no restaurant is provided.  
SELECT  TOP 1
  @LanguageID = [LanguageID],   
  @CountryID = [PrimaryCountryID]   
FROM   dbo.[DBUser] db  
INNER JOIN  dbo.[Domain] d  
ON   db.[DomainID] = d.[DomainID]  
WHERE   dbuser = user 
-- When there is more than 1 domain give the lower DomainID priority (special case for US)
order by db.DomainID ASC

IF @RestaurantID != 0
BEGIN
	SELECT @CountryID = country FROM restaurant WHERE rid = @RestaurantID
END

--*************************
--** Proc: Is called by: Admin_Restaurant_GetProfileByID2
--** Used by Update Restaurant Page
--**
--** Proc only lists Prices associated with the primary county of the Domain
--** Based on the currenty active DBUser 
--*************************
SELECT		PriceQuartileID AS PriceQuartileID
			,PriceQuartile as Value
FROM		dbo.PriceQuartileAVW pq
where		PriceQuartileID != 1 
and 		pq.countryID = @CountryID
and 		pq.LanguageID = @LanguageID

GO

GRANT EXECUTE ON [Admin_AverageCheck_List] TO ExecuteOnlyRole

GO
