if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ReActivate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ReActivate]
GO



CREATE PROCEDURE dbo.Admin_ReActivate
(@CallerID int
)
 AS
 SET NOCOUNT ON
/*this stored proc takes away the pre-pended 'DeActivatedForNoShow' on the email that is placed there to effectively disable the Caller account*/
declare @points int
select @points = points from Caller where CallerID = @CallerID

update Caller set callerstatusid = 1 --active
 where CallerID = @CallerID

--update Caller set email = Replace (email,'DeActivatedForNoShow','') where CallerID = @CallerID
GO

GRANT EXECUTE ON [Admin_ReActivate] TO ExecuteOnlyRole

GO
