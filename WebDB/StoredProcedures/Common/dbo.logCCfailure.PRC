if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[logCCfailure]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[logCCfailure]
GO



CREATE PROCEDURE dbo.LogCCfailure
(@ccnumber nvarchar(255),
 @reason nvarchar(255)
)

 AS

insert into FailedCCLog
(number,reason) values (@ccnumber,@reason)
GO

GRANT EXECUTE ON [logCCfailure] TO ExecuteOnlyRole

GO
