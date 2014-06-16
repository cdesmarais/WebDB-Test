if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_MetroList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_MetroList]
GO

CREATE PROCEDURE dbo.Concierge_Caller_MetroList
As
SET NOCOUNT ON

SELECT 	m.metroareaid as Metro_Area_ID,
	m.MetroAreaName as Name,
	m.Active,
	d.DomainID,
	d.Domain,
	m.LanguageID,
	d.PrimaryLanguageID

FROM 	MetroAreaAVW m -- Get metro info from all Languages
inner join [Domain] d
on	    m.SupportedDomainID =  d.DomainID
where	m.languageID = d.PrimaryLanguageID
AND     m.Active = 1
order	by Domain, Name

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Caller_MetroList] TO ExecuteOnlyRole

GO