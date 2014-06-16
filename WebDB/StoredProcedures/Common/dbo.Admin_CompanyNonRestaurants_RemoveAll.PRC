if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyNonRestaurants_RemoveAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyNonRestaurants_RemoveAll]
GO


CREATE PROCEDURE dbo.Admin_CompanyNonRestaurants_RemoveAll
  @HotelID int,  
  @UserName nvarchar(50),
  @Action nvarchar(20),
  @DateChanged datetime  
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE

if not Exists(Select top 1 RID From CompanyNonRestaurants Where HotelID = @HotelID) Goto notExists	


BEGIN TRANSACTION MyTran
    
    Delete CompanyNonRestaurants
	where HotelID = @HotelID

	Insert Into LogCompanyNonRestaurants(HotelID, RID, UserName,Action,DateChanged)
	Values(@HotelID, 0, @UserName, @Action, @DateChanged)

    IF (@@ERROR <> 0) Goto general_error
    COMMIT TRAN
    RETURN(0)

general_error:
ROLLBACK TRANSACTION MyTran
RAISERROR('general error',17,1)
RETURN(2)

notExists:
RETURN(0)

GO

GRANT EXECUTE ON [Admin_CompanyNonRestaurants_RemoveAll] TO ExecuteOnlyRole

GO


