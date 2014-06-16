

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ValidateResaturantsForRestWeekPromo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ValidateResaturantsForRestWeekPromo]
GO

  
create procedure dbo.Admin_ValidateResaturantsForRestWeekPromo    
(    
  @RIDList varchar(max),    
  @PromoID int    
)    
as    
set nocount on
set transaction isolation level read committed
    
	-- This Procedure accepts List of RID's and Promo Id against which we are uploading the RID list.
	-- It returns 0 when we try to upload blacklisted RID's against Restaurant Week Promo.
	-- Else return 1
         
		 
	-- Checking whether restaurant week promo
    if (exists (select 1 
					from 
						PromoPagesToPromoGroups 
					where 
						PromoID = @PromoID 
						and PromoGroupTypeID = 1
						and Active = 1)
		and exists(select 1
					  from 
						  BlackListPromoWeekRestaurants blackList
					  inner join   
						   fIDStrToTab(@RIDList,',') tabRID
					  on   blackList.RID = tabRID.Id))
		begin
			select 0
			return
		end
    select 1
go

grant execute on [dbo].[Admin_ValidateResaturantsForRestWeekPromo] to ExecuteOnlyRole

go

