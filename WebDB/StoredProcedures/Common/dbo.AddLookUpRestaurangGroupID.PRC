


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddLookUpRestaurangGroupID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddLookUpRestaurangGroupID]
GO


create procedure [dbo].[AddLookUpRestaurangGroupID]  
(      
 @LookUpID int    
 ,@ValueID int    
 ,@ReturnValue int output    
)      
as      
      
-- This procedure is used to Insert GroupID..      
  
declare @GroupID_Count int    

select  
	@GroupID_Count=count(*)  
from  
	dbo.ValueLookupIDList  
where   
	LookUpID=@LookUpID  
	and ValueID = @ValueID;  
 
	if (@GroupID_Count > 0)  
		begin
			set @ReturnValue = -999999999
			goto duplicate_error    
		end
	else    
		begin    
			insert into
				dbo.ValueLookupIDList    
				(LookUpID, ValueID)    
				values    
				(@LookUpID, @ValueID)    
				set @ReturnValue =  @ValueID
				return @ReturnValue  
	end
		
  
duplicate_error:  
	return @ReturnValue


GO

GRANT EXECUTE ON [AddLookUpRestaurangGroupID] TO ExecuteOnlyRole

GO