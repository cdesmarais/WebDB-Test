


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetGroupIDListFrmLookupbyID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetGroupIDListFrmLookupbyID]
GO


create procedure [dbo].[GetGroupIDListFrmLookupbyID]   
(    
	@LookUpID int     
)
as

declare @Test varchar(8000)

set @Test =''

select 
	@Test = case 

when 
	len(@Test)>0 

then @Test + ',' + cast(ValueID as varchar(5))

else

	cast(ValueID as varchar(5))

end

from 
	ValueLookupIDList

where 
	[LookUpID] = @LookUpID

select 
	@Test
	
	
GO

GRANT EXECUTE ON [GetGroupIDListFrmLookupbyID] TO ExecuteOnlyRole

GO
	
	

