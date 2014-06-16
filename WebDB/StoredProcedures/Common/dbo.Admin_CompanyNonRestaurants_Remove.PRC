if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyNonRestaurants_Remove]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyNonRestaurants_Remove]
GO


CREATE PROCEDURE dbo.Admin_CompanyNonRestaurants_Remove
  @HotelID int,
  @RID int,
  @UserName nvarchar(50),
  @Action nvarchar(20),
  @DateChanged datetime  
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION MyTran
if not Exists(Select RID From CompanyNonRestaurants Where HotelID = @HotelID and RID = @RID) 
	Goto not_exists

	Delete CompanyNonRestaurants
	where HotelID = @HotelID and RID = @RID 

	Insert Into LogCompanyNonRestaurants(HotelID,RID,UserName,Action,DateChanged)
	Values(@HotelID,@RID, @UserName, @Action, @DateChanged)

    IF (@@ERROR <> 0) Goto general_error
    COMMIT TRAN
    RETURN(0)

general_error:
ROLLBACK TRANSACTION MyTran
RAISERROR('general error',17,1)
RETURN(2)

not_exists:
ROLLBACK TRANSACTION MyTran
RAISERROR('The restaurant you removed not exists.',17,1)
RETURN(1)

GO

GRANT EXECUTE ON [Admin_CompanyNonRestaurants_Remove] TO ExecuteOnlyRole

GO
