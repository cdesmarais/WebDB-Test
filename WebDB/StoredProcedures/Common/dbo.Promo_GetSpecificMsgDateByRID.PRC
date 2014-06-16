
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetSpecificMsgDateByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetSpecificMsgDateByRID]
GO

create procedure dbo.Promo_GetSpecificMsgDateByRID
(
	 @RID int 
)
as
	/*
	This procedure gets the list of restaurants that have to be excluded from promo messages.
	Content owned by India team. Please notify asaxena@opentable.com, if changing.
	
	============================================================================================	
	This procedure is used to pull the promo date specific message date based on RID.
	=============================================================================================
	*/
select distinct
	pmdc.DateSpecificMsgDTPST

			 		  
from 
	PromoMsgExTool_RIDExclusion pmre
	inner join PromoMsgExTool_DatesConfig pmdc on 
	pmdc.PromoMsgID= pmre.PromoMsgID	
	inner join PromoPages pp on 
	pp.PromoID=pmdc.promoid  
	 

where 
	pmre.rid=@RID and 
	pp.active =1
 

go

GRANT EXECUTE ON [Promo_GetSpecificMsgDateByRID] TO ExecuteOnlyRole

GO

