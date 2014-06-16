if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantUpdateLogoImages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantUpdateLogoImages]
GO



CREATE PROCEDURE dbo.DNRestaurantUpdateLogoImages
 
  @RIDs varchar(8000)

As
BEGIN TRANSACTION

--update all rids that do exist
update r
set r.logo = 'logo_' + convert(nvarchar,s.id) + '.jpg'
from restaurantimage r
inner join 
(
	select id from fIDStrToTab(@RIDs, ',')
) s
on s.id = r.RID

--for rids that do not exist, insert them into the table
insert into restaurantimage
(
	RID,
	ShowImage,
	ImageName,
	Logo
)
	select  s.id
			, 1
			, '0'
			,'logo_' + convert(nvarchar,s.id) + '.jpg'
	from restaurantimage r
	right join 
	(
		select id from fIDStrToTab(@RIDs, ',')
	) s
	on s.id = r.RID
	--ensure the RIDS exist in the restaurant table
	inner join restaurant on s.id = restaurant.RID
	where r.RID is null
	
if (@@ERROR <> 0)
	goto general_error
	
COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION

	exec DNErrorAdd 1029, 'DNRestaurantUpdateLogoImages', N'DNRestaurantUpdateLogoImages Failed', 1
	Return(1)
	
	
GO

GRANT EXECUTE ON [DNRestaurantUpdateLogoImages] TO ExecuteOnlyRole

GO
