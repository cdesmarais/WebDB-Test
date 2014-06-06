if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AttributionService_GetPartners]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AttributionService_GetPartners]
GO

create procedure dbo.AttributionService_GetPartners
as
set nocount on
set transaction isolation level read uncommitted


declare @RestaurantPartnerTypeId int = 1
SELECT 
	p.PartnerID, 
	case 
		when p.PartnerTypeID = @RestaurantPartnerTypeId then convert(bit, 1)
		else convert(bit, 0) 
	end				as IsRestaurantPartner
FROM		Partner p
where		p.ActiveFlag = 1
and			p.PartnerTypeID = @RestaurantPartnerTypeId

go

grant execute on [AttributionService_GetPartners] to ExecuteOnlyRole

GO