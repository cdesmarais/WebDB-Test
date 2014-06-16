if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Hotel_Points]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Hotel_Points]
GO




CREATE PROCEDURE dbo.Concierge_Hotel_Points
(
    @HotelID int
)
AS

Select FName as First_Name,LName as Last_Name,Points,Company.CompanyName as Name from Caller 
inner join Company on Caller.CompanyID = Company.CompanyID
where callerstatusid = 1 and Caller.CompanyID = @HotelID

Order by Points desc,FName
GO

GRANT EXECUTE ON [Concierge_Hotel_Points] TO ExecuteOnlyRole

GO
