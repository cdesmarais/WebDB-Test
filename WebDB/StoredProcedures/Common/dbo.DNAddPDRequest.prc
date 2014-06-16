if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAddPDRequest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAddPDRequest]
GO

CREATE PROCEDURE dbo.DNAddPDRequest

@RID int,
@Name nvarchar(100),
@Email nvarchar(100),
@Phone nvarchar(20),
@RequestDate datetime,
@FlexibleDate bit,
@CC bit,
@EventType nvarchar(100),
@PartySize nvarchar(10),
@Details ntext,
@RestSite bit,
@FormDateTS datetime,
@HostName nvarchar(100),
@Instance nvarchar(100),
@FormSource nvarchar(100),
@ClientIP nvarchar(100),
@Robot bit,
@CustID int,
@CallerID int,
@isAnonymous bit

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- insert data into the [PrivateDiningRequests] table..
INSERT [PrivateDiningRequests](
	[RID],
	[Name],
	[Email],
	[Phone],
	[RequestDate],
	[FlexibleDate],
	[CC],
	[EventType],
	[PartySize],
	[Details],
	[RestSite],
	[FormDateTS],
	[HostName],
	[Instance],
	[FormSource],
	[ClientIP],
	[Robot],
	[CustID],
	[CallerID],
	[IsAnonymous]
)
VALUES(
	@RID,
	@Name,
	@Email,
	@Phone,
	@RequestDate,
	@FlexibleDate,
	@CC,
	@EventType,
	@PartySize,
	@Details,
	@RestSite,
	@FormDateTS,
	@HostName,
	@Instance,
	@FormSource,
	@ClientIP,
	@Robot,
	@CustID,
	@CallerID,
	@IsAnonymous)

GO

GRANT EXECUTE ON [DNAddPDRequest] TO ExecuteOnlyRole

GO
