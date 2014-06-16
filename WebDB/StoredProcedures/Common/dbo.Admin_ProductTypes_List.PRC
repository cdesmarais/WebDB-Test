if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ProductTypes_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ProductTypes_List]
GO


CREATE PROCEDURE dbo.Admin_ProductTypes_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ProductID as Product_ID,ProductDesc as Product_Description
FROM RestaurantProduct
where ProductID not in (0,1,2,3,4,5,7)
GO

GRANT EXECUTE ON [Admin_ProductTypes_List] TO ExecuteOnlyRole

GO
