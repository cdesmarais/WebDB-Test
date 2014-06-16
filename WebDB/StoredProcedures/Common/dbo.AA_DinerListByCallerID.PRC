if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DinerListByCallerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DinerListByCallerID]
GO

CREATE PROCEDURE dbo.AA_DinerListByCallerID 

@CallerID int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select 
		FName as First_Name
		,LName as Last_Name
		,CustID as Customer_ID
		,coalesce(ContactPhone,'') As Phone 
From	CallerCustomer
where	CallerID = @CallerID 
and		Active = 1

GO

GRANT EXECUTE ON [AA_DinerListByCallerID] TO ExecuteOnlyRole

GO
