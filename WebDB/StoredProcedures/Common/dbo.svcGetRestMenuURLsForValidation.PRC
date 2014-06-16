if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcGetRestMenuURLsForValidation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcGetRestMenuURLsForValidation]
GO

CREATE PROCEDURE [dbo].[svcGetRestMenuURLsForValidation]

AS

/*
This procedure returns restaurant Menu URLs which will be consumed
by PJR task to validate them and update their accessibility status.
*/

select r.RID,
	   r.MenuURL,
	   coalesce(ra.MenuFormatID, 0) as MenuFormatID,
	   coalesce(ra.IsAccessible, 0) as IsAccessible
from   Restaurant r
left join RestaurantMenuAccess ra
on r.RID = ra.RID
where r.RestStateID <> 4 --exclude inactive rests
and ISNULL(r.MenuURL, '') <> ''
order by IsAccessible desc, RID

GO

GRANT EXECUTE ON [svcGetRestMenuURLsForValidation] TO ExecuteOnlyRole

GO
