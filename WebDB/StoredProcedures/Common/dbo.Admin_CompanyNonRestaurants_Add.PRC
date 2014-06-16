if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyNonRestaurants_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyNonRestaurants_Add]
GO


CREATE PROCEDURE dbo.Admin_CompanyNonRestaurants_Add
  @HotelID int,
  @RID int,
  @UserName nvarchar(50),
  @Action nvarchar(50),
  @DateChanged datetime  
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION MyTran
if Exists(Select RID From CompanyNonRestaurants Where HotelID = @HotelID and RID = @RID) Goto dup_rid

    Insert Into CompanyNonRestaurants(HotelID,RID)
    Values(@HotelID,@RID)

	Insert Into LogCompanyNonRestaurants(HotelID,RID,UserName,Action,DateChanged)
	Values(@HotelID,@RID, @UserName, @Action, @DateChanged)

    IF (@@ERROR <> 0) Goto general_error
    COMMIT TRAN
    RETURN(0)

general_error:
ROLLBACK TRANSACTION MyTran
RAISERROR('general error',17,1)
RETURN(2)

dup_rid:
ROLLBACK TRANSACTION MyTran
RAISERROR('The restaurant you entered already exists.',17,1)
RETURN(1)

GO

GRANT EXECUTE ON [Admin_CompanyNonRestaurants_Add] TO ExecuteOnlyRole

GO
