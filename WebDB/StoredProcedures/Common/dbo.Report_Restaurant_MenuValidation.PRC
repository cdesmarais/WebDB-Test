if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_MenuValidation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_MenuValidation]
GO

CREATE PROCEDURE [dbo].[Report_Restaurant_MenuValidation]
As

select	r.RID as RestaurantID,
		r.RName as RestaurantName,
		m.MetroAreaID,
		m.MetroAreaName,
		n.NbhoodName as NeighborhoodName,
		r.MenuURL,
		l.LanguageRegionDesc as RestaurantLanguage
from RestaurantVW r
inner join NeighborhoodVW n
on r.NeighborhoodID = n.NeighborhoodID
inner join MetroAreaVW m
on n.MetroAreaID = m.MetroAreaID
inner join Language l
on r.LanguageID = l.LanguageID
left join RestaurantMenuAccess rma
on r.RID = rma.RID
where r.RestStateID <> 4
and  ISNULL(rma.IsAccessible, 0) = 0
order by MetroAreaName, RestaurantID

GO

GRANT EXECUTE ON [Report_Restaurant_MenuValidation] TO ExecuteOnlyRole

GO

