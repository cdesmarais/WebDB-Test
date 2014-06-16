if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetReviewResoData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetReviewResoData]
GO

-- Drop type after reference from stored proc is removed
if exists(select * from sys.types where name = 'RestaurantReviewsImportType' and is_table_type = 1)
drop type dbo.RestaurantReviewsImportType
go

CREATE TYPE dbo.RestaurantReviewsImportType AS TABLE
(
	ResID				int not null,
	MetroID				int not null, 
	RestName			nvarchar(500) not null,
	ReservationDate 	datetime not null,
	ResponseDateUTC 	datetime not null,
	CustEmail			nvarchar(200) null,
	RID					int not null,
	Categories			nvarchar(160) null,
	FoodRating			int not null,
	AmbianceRating		int not null,
	ServiceRating		int not null,
	OverallRating		int not null,
	NoiseRating			int not null,
	Comments			nvarchar(800) null,
	DFBUserTypeValue	nvarchar(20) null,
	Error				int not null,
	Title				nvarchar(35) null,
	Name				nvarchar(500) null,
	CommentsToRestaurant nvarchar(800) null
)
GO

grant execute on type::dbo.RestaurantReviewsImportType to ExecuteOnlyRole
go

create procedure dbo.DNGetReviewResoData
(
    @MySqlReviews RestaurantReviewsImportType readonly
)
as
-- This stored procedure takes in a DataTable containing data from reviews
-- kept in the MySql.OTMediaStorage database.  It merges the review data
-- with reservation data in WebDB for a data feed to BazaarVoice.
set nocount on
set transaction isolation level read uncommitted

-- Find the metros that we are excluding from this data fetch
select		res.ResID
		,	r.RID
		,	res.CustID
		,	r.RName as Restname
		,	n.MetroAreaID				
		,	res.ResPoints		
		,	res.ShiftDate + 2 + res.ResTime as ReservationDate
		,   res.RStateID
		,	NULL as AdminCustID --placeholder for compatibility
		,	NULL as OriginalCustID --placeholder
		,	coalesce(ca.CreateDate, c.CreateDate) as UserCreateDate
		,	case
			when coalesce(ca.ConsumerType,c.ConsumerType) in (4,5) then
				1
			else
				0
			end as IsVIP
		--MySql Columns		
		,	m.ResponseDateUTC
		,	m.Categories
		,	m.FoodRating
		,	m.AmbianceRating
		,	m.ServiceRating
		,	m.OverallRating
		,	m.NoiseRating
		,	m.Comments
		,	m.DFBUserTypeValue
		,	m.Error
		,	m.Title	
		,	m.CustEmail
		,	m.Name	
		,	m.CommentsToRestaurant
from		Reservation res
inner join 	@MySqlReviews m
on			res.ResId = m.ResID
inner join	RestaurantAVW r
on			res.RID = r.RID
and			res.LanguageID = r.LanguageID
inner join	Neighborhood n
on			r.NeighborhoodID = n.NeighborhoodID
left join	Customer c
on			res.CustID = c.CustID
left join	[Caller] ca
on			res.CallerID = ca.CallerID
order by	r.RID

GO


GRANT EXECUTE ON [DNGetReviewResoData] TO ExecuteOnlyRole

GO

