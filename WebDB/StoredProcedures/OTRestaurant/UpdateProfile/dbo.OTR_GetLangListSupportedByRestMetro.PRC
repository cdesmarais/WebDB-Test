

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_GetLangListSupportedByRestMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_GetLangListSupportedByRestMetro]
GO

create procedure [dbo].[OTR_GetLangListSupportedByRestMetro] 
(
	@RID	int
)
as
set nocount on
set transaction isolation level read uncommitted

	/* 
	This SP is used to get all languages supported by input RID
	Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	
	declare @MetroAreaID int 
	
	-- Get Restaurant MetroArea ID
	select   
		@MetroAreaID = n.MetroAreaID
	from		
		RestaurantAVW r  
		inner join 	NeighborhoodAVW n  
		on 	r.NeighborhoodID = n.NeighborhoodID  
		and	r.LanguageID = n.LanguageID  
	where 
		r.rid = @RID

	
	/* 
	Get all the language supported by metro and check if restaurant profile is available for 
	that localized language 
	Value for LanguageName column will be added in frontend side
	*/
	select
		metro.LanguageID
		,case when isnull(r.LanguageID,0) = 0 then 0 else 1 end as IsRestProfileExists
		,'' as LanguageName
	from
		MetroAreaAVW metro -- Get metro info from all Languages
		inner join [Domain] d
		on metro.SupportedDomainID = d.DomainID

		left join RestaurantAVW r on (rid = @RID and metro.LanguageID = r.LanguageID)
	where
		metro.MetroAreaID = @MetroAreaID
		
GO

grant execute on [OTR_GetLangListSupportedByRestMetro] to ExecuteOnlyRole

GO


