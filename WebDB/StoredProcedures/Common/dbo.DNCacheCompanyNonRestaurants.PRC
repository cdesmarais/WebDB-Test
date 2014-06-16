if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheCompanyNonRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheCompanyNonRestaurants]
GO


CREATE PROCEDURE dbo.DNCacheCompanyNonRestaurants
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select distinct HotelID CompanyID,
		RID
	from CompanyNonRestaurants

GO


GRANT EXECUTE ON [DNCacheCompanyNonRestaurants] TO ExecuteOnlyRole

GO
