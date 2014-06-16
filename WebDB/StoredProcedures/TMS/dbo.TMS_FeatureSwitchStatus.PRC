IF EXISTS ( SELECT * 
        FROM DBO.SYSOBJECTS 
        WHERE ID = OBJECT_ID(N'[dbo].[TMS_FeatureSwitchStatus]') 
        AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
    DROP PROCEDURE [dbo].[TMS_FeatureSwitchStatus]
GO


CREATE PROCEDURE [dbo].[TMS_FeatureSwitchStatus]
AS

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	declare @ValueLookupID int = 92

	select v1.valueid as EmailSwitchId, 'shadow' as FeatureSwitchMode
	from 
		ValueLookupIDList v1 
			inner join ValueLookupIDList v2
					on  v1.LookupID = @ValueLookupID 
					and v2.LookupID = @ValueLookupID
					and v2.valueid = v1.valueid + 1000
	union
	select valueid as FeatureSwitchMode, 'full'
	from ValueLookupIDList v3
	where 
		lookupid = @ValueLookupId 
		and v3.valueid < 1000
		and not exists(select * from valuelookupidlist where lookupid = @ValueLookupId and valueid = v3.valueid+1000)
  
GO

GRANT EXECUTE ON [TMS_FeatureSwitchStatus] TO ExecuteOnlyRole

GO
