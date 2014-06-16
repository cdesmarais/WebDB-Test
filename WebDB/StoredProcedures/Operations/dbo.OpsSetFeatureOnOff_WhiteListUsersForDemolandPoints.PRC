if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsSetFeatureOnOff_WhiteListUsersForDemolandPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsSetFeatureOnOff_WhiteListUsersForDemolandPoints]
GO

CREATE PROCEDURE dbo.OpsSetFeatureOnOff_WhiteListUsersForDemolandPoints
(
	@On 	int  -- 1: Turns feature ON and  otherwise Off
)
AS
	set nocount on
	
	UPDATE [dbo].[ValueLookup] 
	SET [ValueInt] = @On
	WHERE [LType] = 'WEBSERVER' AND [LKey] = 'WHITELIST_POINTS_ENABLED'
	
	IF  (@@rowcount = 0)
	BEGIN
		INSERT INTO [dbo].[ValueLookup] ([LType], [LKey], [ValueInt])
		VALUES
		(
			'WEBSERVER',
			'WHITELIST_POINTS_ENABLED',
			@On
		)
	END
GO
	
GRANT EXECUTE ON [OpsSetFeatureOnOff_WhiteListUsersForDemolandPoints] TO ExecuteOnlyRole
GO
	