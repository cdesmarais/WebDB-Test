--$ create proc csAuthLogAdd
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csAuthLogAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csAuthLogAdd]
GO

CREATE Procedure dbo.csAuthLogAdd
(
	 @RID							int
	,@LogDate						datetime
	,@SourceMachine					varchar(50)
	,@SourceIP						varchar(50)
	,@AuthorizationSuccessful		bit
	,@ReportedNetworkAddress		varchar(60)
	,@NetworkAddressUpdated			bit
	,@Details						varchar(1000)
)
As

insert into AuthNetworkAddressLog
(
	 RID
	,LogDate
	,SrcMachineName
	,SrcIPAddress
	,AuthSuccess
	,ReportedNetworkAddress
	,NetworkAddressUpdated
	,Details
)
values
(
	 @RID
	,@LogDate
	,@SourceMachine
	,@SourceIP
	,@AuthorizationSuccessful
	,@ReportedNetworkAddress
	,@NetworkAddressUpdated
	,@Details
)

GO

GRANT EXECUTE ON [csAuthLogAdd] TO ExecuteOnlyRole
GO
