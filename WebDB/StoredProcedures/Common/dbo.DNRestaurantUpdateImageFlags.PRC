if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantUpdateImageFlags]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantUpdateImageFlags]
go

create procedure dbo.DNRestaurantUpdateImageFlags
 
  @RIDs varchar(8000) --[EV: List of Int IDs]

as
begin transaction

	--update all rids that do exist
	update	r
	set		r.ImageName		= s.id
			,Thumbnail	= cast(s.id as nvarchar) + '.jpg'
			,ThumbnailName	= cast(s.id as nvarchar) + '.jpg'
	from	RestaurantImage r
	inner join (
		select id 
		from fIDStrToTab(@RIDs, ',')
	) s
	on s.id = r.RID

	--for rids that do not exist, insert them into the table
	insert into RestaurantImage
	(
		RID,
		ShowImage,
		ImageName,
		Thumbnail,
		ThumbnailName
	)
	select		s.id
				, 1
				, s.id
				, cast(s.id as nvarchar) + '.jpg'
				, cast(s.id as nvarchar) + '.jpg'
	from		restaurantimage r
	right join (
		select id 
		from fIDStrToTab(@RIDs, ',')
	) s
	on s.id = r.RID
	
	--ensure the RIDS exist in the restaurant table
	inner join	restaurant 
	on			s.ID = restaurant.RID
	where		r.RID is null

	if (@@error <> 0)
		goto general_error
	
commit transaction
	return(0)

general_error:
	rollback transaction

	exec DNErrorAdd 1029, 'DNRestaurantUpdateImageFlags', N'DNRestaurantUpdateImageFlags Failed', 1
	return(1)
	
go

grant execute on [DNRestaurantUpdateImageFlags] TO ExecuteOnlyRole

go
