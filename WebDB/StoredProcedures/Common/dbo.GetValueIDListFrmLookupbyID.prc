

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetValueIDListFrmLookupbyID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetValueIDListFrmLookupbyID] 
GO

create procedure [dbo].[GetValueIDListFrmLookupbyID]    
(    
	@LookUpID int     
)
as
	--- Get the comma seperated list of ValueIDs by providing lookup ID
	declare @retVal varchar(8000)
	set @retVal =''
	
	select 
		@retVal = case 
					when len(@retVal)>0 Then  
					@retVal + ',' + cast(ValueID as varchar)
					else
						cast(ValueID as varchar)
				   end

	from 
		ValueLookupIDList

	where 
		[LookUpID] = @LookUpID
	
	select 
		@retVal
	
GO

GRANT EXECUTE ON [GetValueIDListFrmLookupbyID] TO ExecuteOnlyRole

GO
