if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PaymentTypes_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PaymentTypes_Add]
GO



CREATE Procedure dbo.Admin_PaymentTypes_Add
 (
  @RestaurantID int,
  @PaymentTypeID nvarchar(255)
 )
As
SET NOCOUNT ON


BEGIN TRANSACTION
declare @variable nvarchar(255)
declare @tempPaymentTypeID nvarchar(255)
declare @i bit
set @tempPaymentTypeID = @PaymentTypeID + ','


 While len(@tempPaymentTypeID) > 1
	begin
	    Set @variable = convert(int,left(@tempPaymentTypeID,charindex(',',@tempPaymentTypeID) -1)) /*gets everything to the left of a comma*/
		
	    INSERT INTO PaymentTypes (RID,PaymentTypeID) VALUES (@RestaurantID,@variable)

	    If @@Error <> 0 
                      goto error

	   set @tempPaymentTypeID = right(@tempPaymentTypeID,len(@tempPaymentTypeID) - charindex(',',@tempPaymentTypeID)) --trims off the leftmost comma and everything preceeding it

	end

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO

GRANT EXECUTE ON [Admin_PaymentTypes_Add] TO ExecuteOnlyRole

GO
