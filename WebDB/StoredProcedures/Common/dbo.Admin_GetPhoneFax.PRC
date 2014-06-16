if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetPhoneFax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetPhoneFax]
GO




CREATE PROCEDURE dbo.Admin_GetPhoneFax

(@restaurant_id int
 )

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select	phone,
		FaxPhone as fax_phone,
		RName as Name 
from	RestaurantVW
where	RID = @restaurant_id
GO

GRANT EXECUTE ON [Admin_GetPhoneFax] TO ExecuteOnlyRole

GO
