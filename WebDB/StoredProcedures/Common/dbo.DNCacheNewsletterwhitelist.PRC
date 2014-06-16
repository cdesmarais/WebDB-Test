if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheNewsletterWhitelist]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheNewsletterWhitelist]
GO

CREATE Procedure dbo.DNCacheNewsletterWhitelist

As

SET NOCOUNT ON

select NewsletterID, MetroAreaID, MacroID, NeighborhoodID, UpdatedDtUTC
from Newsletterwhitelist

GO


GRANT EXECUTE ON [DNCacheNewsletterWhitelist] TO ExecuteOnlyRole
GO
