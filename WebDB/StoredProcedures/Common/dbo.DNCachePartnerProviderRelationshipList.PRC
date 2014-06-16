if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePartnerProviderRelationshipList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePartnerProviderRelationshipList]
go

create procedure dbo.DNCachePartnerProviderRelationshipList
as
set nocount on
set transaction isolation level read uncommitted

select		PartnerID
			,ProviderID
from		ContentPartner2ProviderRelationships
where		[enabled] = 1
order by	PartnerID
			,ProviderID

go


grant execute on [DNCachePartnerProviderRelationshipList] to ExecuteOnlyRole

go
