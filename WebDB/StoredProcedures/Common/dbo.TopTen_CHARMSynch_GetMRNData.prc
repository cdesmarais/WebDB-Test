

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_CHARMSynch_GetMRNData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)    
drop procedure [dbo].[TopTen_CHARMSynch_GetMRNData]
GO

/*
	The The TopTen CHARMSYNCH relies on this proc to get MRN values. proc converts -1 (which means ALL) to real ID's. E.g. if you want to generate
	a list for ALL metros OR All Regions of a Metro OR All NBhood of a Metro Or a Region, then you say -1 in the metroid, RegionId,NBHoodId column. This proc is called to replace -1 with the real values. 
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

create procedure [dbo].[TopTen_CHARMSynch_GetMRNData]        
(     
     @parMetroID int   
    ,@parRegionID int       
    ,@parNBHoodID int         
)       
as         
      
select MA.MetroAreaID as MetroID        
    ,MNBH.MacroID as RegionID        
    ,NBH.NeighborhoodID as NBHoodID       

from NeighborhoodVW as NBH        

    inner join MetroAreaVW MA        
    	on NBH.MetroAreaID = MA.MetroAreaID

    inner join MacroNeighborhoodVW  MNBH        
    	on NBH.MacroID = MNBH.MacroID     
  
where         
    MA.MetroAreaID=
    	case 
    		when @parMetroID <=0 
			then MA.MetroAreaID 
		else @parMetroID 
	end 
	
 and NBH.MacroID =  
 	case 
 		when @parRegionID <=0 
 			then NBH.MacroID 
 		else @parRegionID 
 	end  
 
 and NBH.NeighborhoodID =   
 	case
 		when @parNBHoodID <=0 
			then NBH.NeighborhoodID 
		else @parNBHoodID 
	end  
	
order by MetroID asc
        ,RegionID asc
        ,NeighborhoodID asc
  
GO

GRANT EXECUTE ON [TopTen_CHARMSynch_GetMRNData] TO ExecuteOnlyRole
GO       
