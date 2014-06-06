

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesDeleteInactiveRIDs_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesDeleteInactiveRIDs_v2]
go

create procedure dbo.AdminPromosPagesDeleteInactiveRIDs_v2
(
  @RIDList varchar(8000),
  @PromoID int  
)
as
set nocount on 

	delete 	
	from 
		PromoRests  
	where 
		(@RIDList is null or charindex(',' + cast( RID as nvarchar) + ',', ',' + @RIDList + ',')>0)
		and PromoID = @PromoID

go

grant  execute  on [dbo].[AdminPromosPagesDeleteInactiveRIDs_v2]  to [ExecuteOnlyRole]
go