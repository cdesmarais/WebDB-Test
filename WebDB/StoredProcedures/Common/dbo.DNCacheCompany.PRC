if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheCompany]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheCompany]
GO


CREATE PROCEDURE dbo.DNCacheCompany
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select	CompanyID,
			EMail,
			Country,
			Phone,
			Logo,
			IsNull(AcceptsPoints, 1) AcceptsPoints, 
			DonatePoints, 
			IsCharity
	from company

GO


GRANT EXECUTE ON [DNCacheCompany] TO ExecuteOnlyRole

GO
