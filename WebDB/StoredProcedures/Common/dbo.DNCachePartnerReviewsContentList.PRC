if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePartnerReviewsContentList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePartnerReviewsContentList]
go

create procedure dbo.DNCachePartnerReviewsContentList
as
set nocount on
set transaction isolation level read uncommitted

select			c.rid
				,c.contentid
				,c.providerid
				,ltrim(rtrim(p.providername)) as name
				,c.shortvalue as url
from			content as c
inner join		provider as p
on				c.providerid = p.providerid
inner join		restaurantvw as r	-- to filter out restaurants not in current lang
on				r.rid = c.rid
where			c.[enabled] = 1
and				r.RestStateID <> 4	-- filter out inactive restaurants

go

grant execute on [DNCachePartnerReviewsContentList] to ExecuteOnlyRole

go
