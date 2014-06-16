if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNDinerListByCallerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNDinerListByCallerID]
GO

CREATE PROCEDURE dbo.DNDinerListByCallerID 

@CallerID int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Select FName as First_Name,LName as Last_Name,CustID as Customer_ID 
From CallerCustomer
where CallerID = @CallerID and Active = 1
GO

GRANT EXECUTE ON [DNDinerListByCallerID] TO ExecuteOnlyRole

GO
