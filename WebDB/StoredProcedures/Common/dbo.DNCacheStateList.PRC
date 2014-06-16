if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStateList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheStateList]
GO



CREATE PROCEDURE dbo.DNCacheStateList
 As

SET NOCOUNT ON
set transaction ISOLATION LEVEL read UNCOMMITTED

Select		StateID, 
			StateName.CountryID, 
			StateName, 
			CountryName 
from		StateName
inner join	countryVW c 
on			StateName.CountryID = c.CountryID
where		stateID != '  '
order by 	StateName
GO

GRANT EXECUTE ON [DNCacheStateList] TO ExecuteOnlyRole

GO
