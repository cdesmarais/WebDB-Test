
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_GetCharmStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_GetCharmStatus]
GO
  
create procedure [dbo].ROMS_GetCharmStatus  
   
(  
	@WebID int  = null 
)  
as      
      
/**********************************************************************************        

 ROMS uses this proc to get charm statuses from consumer database. 
 Content owned by India team, please notify asaxena@opentable.com if changing.        
************************************************************************************/      
begin      
    if @WebID IS NULL
    BEGIN
		select      
			er.RID as WebId      
			,er.ServerIP as ServerIP        
			,coalesce(LTC.LTC, r.CreateDate) as LastTimeContactedDTPST     
			,getDate() as Server_Time        
			,case 
				when r.RestStateID = 1 AND isReachable = 1 then   
				'Reserve Now'        
				when r.RestStateID = 1 AND isReachable = 0 then   
				'Back Soon'        
				else 
				rs.Rstate			      
			end as CHARMStatus       
			     
		from   
			erbrestaurant er        
			
			inner Join RestaurantVW r on   
			er.rid = r.rid        

			inner Join RestaurantState rs  on       
			r.RestStateID = rs.RestStateID        

			left outer join LastTimeContacted LTC on         
			er.rid = LTC.rid        
	END
	ELSE
	BEGIN
		select      
			er.RID as WebId      
			,er.ServerIP as ServerIP        
			,coalesce(LTC.LTC, r.CreateDate) as LastTimeContactedDTPST     
			,getDate() as Server_Time        
			,case 
				when r.RestStateID = 1 AND isReachable = 1 then   
				'Reserve Now'        
				when r.RestStateID = 1 AND isReachable = 0 then   
				'Back Soon'        
				else 
				rs.Rstate			      
			end as CHARMStatus       
			     
		from   
			erbrestaurant er        
			
			inner Join RestaurantVW r on   
			er.rid = r.rid        

			inner Join RestaurantState rs  on       
			r.RestStateID = rs.RestStateID        

			left outer join LastTimeContacted LTC on         
			er.rid = LTC.rid        

		where   
		r.RID = @WebID
	END
end    

Go

GRANT EXECUTE ON [ROMS_GetCharmStatus] TO ExecuteOnlyRole


GO
