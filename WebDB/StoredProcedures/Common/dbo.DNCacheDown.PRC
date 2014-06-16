if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDown]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDown]
GO

--**********************************************
--** This procedure is used to indicate the Cache Server is down
--** Calling this proc will set the date / time that the CacheServer
--** went down.
--**
--**********************************************
CREATE PROCEDURE dbo.DNCacheDown
AS
	-- Update the appropriate key only if more than 10 minutes have passed since last update
	-- This prevents multiple updates coliding with eachother
	update ValueLookup set ValueDT = getdate()
	where Ltype = 'CACHESERVER'
	and Lkey = 'DOWN_DATE'
	and datediff(mi, coalesce(ValueDT, '01/01/1990'), getdate()) > 10

GO




GRANT EXECUTE ON [DNCacheDown] TO ExecuteOnlyRole

GO
