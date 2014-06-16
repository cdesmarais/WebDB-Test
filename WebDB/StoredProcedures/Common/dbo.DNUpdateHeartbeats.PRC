if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateHeartbeats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateHeartbeats]
GO

CREATE PROCEDURE dbo.DNUpdateHeartbeats
(
	@Restaurants nvarchar(4000)
	,@sCommType nvarchar(50)
)
 AS

-- OBSOLETE!

GO



GRANT EXECUTE ON [DNUpdateHeartbeats] TO ExecuteOnlyRole

GO
