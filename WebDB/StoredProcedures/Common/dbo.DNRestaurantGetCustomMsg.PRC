go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetCustomMsg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetCustomMsg]
go


CREATE PROCEDURE dbo.DNRestaurantGetCustomMsg
AS

set nocount on
set transaction isolation level read uncommitted

	select 		 distinct 
				(cast (cd.rid as varchar(20)) + '|' + cast (cd.LanguageID as varchar(20))) as PrimaryKey
				,cd.rid
				,CustomedDate
				,Message
				,cd.LanguageID
				,DetailsPageOnly
	from		CustomedDayAVW				cd
	inner join	Restaurant				r
	on			r.rid					= cd.rid
	inner join	MaxAdvanceOption mao
	on			mao.MaxAdvanceOptionID	= r.MaxAdvanceOptionID
	inner join	dbo.DBUser db 
	-- For standard user (WebUserUS) returns only one language (en-US) and for regional users (WebUserRegion) returns all the languages
	on		db.dbuser = user
	and		cd.LanguageID = isnull(db.LanguageID , cd.LanguageID) 

	-- add and subtract a day on either end for potential time zone conflicts
	where		CustomedDate			>= getdate() -1		
	and			CustomedDate			<= getdate() + mao.Days + 1
	and			r.RestStateID			!= 4
	order by	cd.CustomedDate

GO

grant execute on [DNRestaurantGetCustomMsg] TO ExecuteOnlyRole

go
