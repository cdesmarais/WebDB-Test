

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_PriceQuartile_GetAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_PriceQuartile_GetAllLanguages]
GO

create procedure dbo.OTR_PriceQuartile_GetAllLanguages
(            
	@RestaurantID   int      
)            
as

set nocount on
set transaction isolation level read uncommitted

/* 
	This SP is used to get price info  for restaurnt 
	Content owned by India team, please notify asaxena@opentable.com if changing.
	
	This SP is same as  Admin_AverageCheck_List. 
	The only modification done is to get price quartile for all languages
*/

Declare @CountryID as varchar(2)


select @CountryID = country from restaurant where rid = @RestaurantID


/* 
	MasterID and MasterValue alias helps becuase we have used same alias for all update profile master data 
	same method has been used to filter master data.
*/
select		
	PriceQuartileID as MasterID 
	,PriceQuartile as MasterValue
	,CountryID
	,LanguageID 
from		
	dbo.PriceQuartileAVW pq
	
where		
	PriceQuartileID != 1 /* existing filter */
	and pq.countryID = @CountryID

go

grant execute on [OTR_PriceQuartile_GetAllLanguages] to ExecuteOnlyRole

go


