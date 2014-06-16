if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_Company]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_Company]
GO



CREATE PROCEDURE dbo.Concierge_Caller_Company
 (
  @CompanyID int
 )
As
SET NOCOUNT ON
SELECT CompanyID AS HotelID,CompanyName as HotelName
FROM Company
WHERE CompanyID = @CompanyID
GO

GRANT EXECUTE ON [Concierge_Caller_Company] TO ExecuteOnlyRole

GO

