if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsSetServerActiveStatus]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsSetServerActiveStatus]
GO

CREATE PROCEDURE dbo.OpsSetServerActiveStatus
(
	@DestServerName nvarchar(100),
	@Active	bit
)
As

--************************************************************************************
--** Proc is used to add/remove servers from the data-center
--************************************************************************************

declare @AcceptsTraffic int
declare @LBStatusCode int

if (@Active = 0)
begin
	set @AcceptsTraffic = 0						-- inactive servers can not accept traffic 
	set @LBStatusCode = 0						-- LBStatusCode = 0 = OTWEB_OFF
	update	[Server]
	set		Active = @Active,
			AcceptsTraffic = @AcceptsTraffic,
			LBStatusCode = @LBStatusCode
	where	ServerName = @DestServerName
end
else
begin
	update	[Server]
	set		Active = @Active
	where	ServerName = @DestServerName
end

GO


GRANT EXECUTE ON [dbo].[OpsSetServerActiveStatus] TO ExecuteOnlyRole
GO

