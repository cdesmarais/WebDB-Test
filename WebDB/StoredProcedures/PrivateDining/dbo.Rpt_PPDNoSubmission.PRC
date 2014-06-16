

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Rpt_PPDNoSubmission]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Rpt_PPDNoSubmission]
go

create procedure dbo.Rpt_PPDNoSubmission   
as    
begin    
	/* 
		This SP returns details of restaurants that have private dining premium feature 
		enabled but have not yet submitted premium data. 
		Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	
	Select   
		distinct
		rest.RID  
		,RName 'Restaurant Name'  
		,MetroAreaName as 'Metro'  
		,PrivatePartyPhone as 'Private Dining Phone Number' 
		,PrivatePartyContact as 'Contact Name'  
		,cast(PrivatePartyEmail as nvarchar(510)) as 'Email' 
		,isnull(convert(varchar(20),FreeToPremiumTransitionDTUTC,100),'')  as 'Premium Enabled Date'
	from   
		RestaurantVW rest  
		
		inner join NeighborhoodAVW NBH   
		on rest.NeighborhoodID = NBH.NeighborhoodID
		and NBH.LanguageID = Rest.LanguageID 

		inner join MetroAreaAVW MA
		on NBH.MetroAreaID = MA.MetroAreaID
		and MA.LanguageID = Rest.LanguageID  
		
		inner join PDTracking pd
		on pd.RID = rest.RID
	where				
		IsPremium = 1
		and LastSubmissionDtUtc is null
		
		      
end    
go

grant execute on Rpt_PPDNoSubmission to ExecuteOnlyRole
go


