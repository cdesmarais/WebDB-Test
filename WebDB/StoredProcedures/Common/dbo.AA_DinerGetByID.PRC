if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DinerGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DinerGetByID]
GO


CREATE Procedure dbo.AA_DinerGetByID
 
@DinerID int
 
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT          cc.Email
               ,cc.FName		as First_Name
               ,cc.LName		as Last_Name
               ,cc.CustID		as Customer_ID
               ,cc.ContactPhone		as Contact_Phone
               ,cc.PhoneExt		as PhoneExtension
               ,cc.CallerID		as Caller_ID
FROM            CallerCustomer	cc
WHERE          (cc.CustID = @DinerID)


GO


GRANT EXECUTE ON [AA_DinerGetByID] TO ExecuteOnlyRole

GO
