if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetNewsLettersWhiteList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetNewsLettersWhiteList]
GO


create procedure dbo.GetNewsLettersWhiteList
as
-- retrieve the white list of Metro/Macro/Neighborhood for email preferences
set nocount on
set transaction isolation level read uncommitted

SELECT	NewsLetterID
		,MetroAreaID
		,MacroID
		,NeighborhoodID
FROM	dbo.NewsletterWhiteList 	

GO


GRANT EXECUTE ON [GetNewsLettersWhiteList] TO ExecuteOnlyRole

GO

