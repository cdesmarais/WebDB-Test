

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesDeleteInactiveRIDs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesDeleteInactiveRIDs]
go

create procedure dbo.AdminPromosPagesDeleteInactiveRIDs
(
  @RIDList varchar(8000)  
)
as
set nocount on 

	delete 	
	from 
		PromoRests  
	where 
		(@RIDList is null or charindex(',' + cast( RID as nvarchar) + ',', ',' + @RIDList + ',')>0)

go

grant  execute  on [dbo].[AdminPromosPagesDeleteInactiveRIDs]  to [ExecuteOnlyRole]
go