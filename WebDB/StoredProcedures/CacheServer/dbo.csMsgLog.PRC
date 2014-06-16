--$ create proc csMsgLog
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csMsgLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csMsgLog]
GO

CREATE Procedure dbo.csMsgLog
(
	 @Source	varchar(100)
	,@Details	varchar(255)
)
As

	insert into CacheServerMessageLog
	(
		 CacheLogDate
		,Source
		,Details
	)
	values
	(
		 getdate()
		,@Source
		,@Details
	)
GO

GRANT EXECUTE ON [csMsgLog] TO ExecuteOnlyRole
GO
