if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheWelcomeMailMetroConfig]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheWelcomeMailMetroConfig]
GO


CREATE PROCEDURE dbo.DNCacheWelcomeMailMetroConfig
As

SET NOCOUNT ON
/*
	Query the metros that are currently configured to have their Welcome Mail sent by a third party
*/

	select			MetroAreaID, StartDate
	from			EmailProviderWelcomeMailConfig
	
GO

GRANT EXECUTE ON [DNCacheWelcomeMailMetroConfig] TO ExecuteOnlyRole

GO
