if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Attribution_WriteFirstInLastIn_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Attribution_WriteFirstInLastIn_V2]
GO

CREATE PROCEDURE [dbo].[Attribution_WriteFirstInLastIn_V2]

@ResID					INT,
@PartnerIDFirstIn		INT,
@PartnerIDLastIn		INT,
@ReferrerIDFirstIn		INT,
@ReferrerIDLastIn		INT,
@RestRefIDFirstIn		INT,
@RestRefIDLastIn		INT,
@NewAttributionSwitch	BIT

AS


INSERT INTO			dbo.Attribution_FirstInLastIn
					(
						ResID,
						PartnerIDFirstIn,
						PartnerIDLastIn,
						ReferrerIDFirstIn,
						ReferrerIDLastIn,
						RestRefIDFirstIn,
						RestRefIDLastIn,
						NewAttributionSwitch
					)
VALUES				(
						@ResID,
						@PartnerIDFirstIn,
						@PartnerIDLastIn,
						@ReferrerIDFirstIn,
						@ReferrerIDLastIn,
						@RestRefIDFirstIn,
						@RestRefIDLastIn,
						@NewAttributionSwitch
					)

GO

GRANT EXECUTE ON [Attribution_WriteFirstInLastIn_V2] TO ExecuteOnlyRole

GO
