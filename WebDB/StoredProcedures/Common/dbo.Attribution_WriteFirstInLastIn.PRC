if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Attribution_WriteFirstInLastIn]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Attribution_WriteFirstInLastIn]
GO

CREATE PROCEDURE [dbo].[Attribution_WriteFirstInLastIn]

@ResID				INT,
@PartnerIDFirstIn	INT,
@PartnerIDLastIn	INT,
@ReferrerIDFirstIn	INT,
@ReferrerIDLastIn	INT,
@RestRefIDFirstIn	INT,
@RestRefIDLastIn	INT

AS


INSERT INTO			dbo.Attribution_FirstInLastIn
					(
						ResID,
						PartnerIDFirstIn,
						PartnerIDLastIn,
						ReferrerIDFirstIn,
						ReferrerIDLastIn,
						RestRefIDFirstIn,
						RestRefIDLastIn
					)
VALUES				(
						@ResID,
						@PartnerIDFirstIn,
						@PartnerIDLastIn,
						@ReferrerIDFirstIn,
						@ReferrerIDLastIn,
						@RestRefIDFirstIn,
						@RestRefIDLastIn
					)

GO

GRANT EXECUTE ON [Attribution_WriteFirstInLastIn] TO ExecuteOnlyRole

GO
