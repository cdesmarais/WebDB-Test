if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ChangeRealCustomerToAAUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ChangeRealCustomerToAAUser]
GO

CREATE PROCEDURE dbo.ChangeRealCustomerToAAUser
(
@CustomerEmail nvarchar(255),
@Debug int = 0
)
 AS

--***********************
--** ChangeRealCustomerToAAUser this proc has been replaced by DNChangeRealCustomerToAAUser
--** Just incase this proc still gets caleld, call it's replacement
--***********************
exec DNChangeRealCustomerToAAUser @CustomerEmail, @Debug



GO

GRANT EXECUTE ON [ChangeRealCustomerToAAUser] TO ExecuteOnlyRole

GO
