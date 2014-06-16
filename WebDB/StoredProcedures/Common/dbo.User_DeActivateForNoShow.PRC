if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_DeActivateForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_DeActivateForNoShow]
GO

CREATE Procedure dbo.User_DeActivateForNoShow
(@CustomerID int
)
/*revised for new schema 8/5/2003 --JD*/
 AS
 SET NOCOUNT ON

--declare @points int
--select @points = points from Customer where CustID = @CustomerID

update Customer set active = 0 where CustID = @CustomerID

Exec dbo.DNLogDeActivatedUsers @CustomerID, 0, 1


GO

GRANT EXECUTE ON [User_DeActivateForNoShow] TO ExecuteOnlyRole

GO
