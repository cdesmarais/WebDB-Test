
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateRestaurantType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateRestaurantType]
GO


CREATE PROCEDURE [dbo].[Admin_Restaurant_UpdateRestaurantType]
 (
	@RestaurantID int,	
	@RestaurantType char(1)
)

AS


declare @ProcName as nvarchar(1000)  
declare @Action as nvarchar(3000)  
declare @DBError int 
declare @Allotment bit
declare @IsConnectFieldTest bit

set @ProcName = 'Admin_Restaurant_UpdateRestaurantType'  

if(@RestaurantType = 'E' OR @RestaurantType = 'C')
Begin
	SET @Allotment = 0
	SET @IsConnectFieldTest = 0
End

if(@RestaurantType = 'A')
Begin
	SET  @Allotment = 1
	
	--Ideally this is passed in, otherwise this will need to change whenever we enable field test, but for a temp proc solution
	--this will work
	select @IsConnectFieldTest = case when Country = 'UK' or Country = 'IE' Then 1
		   else 0
		   end 
	from Restaurant
	where RID = @RestaurantID 

	
END

set @Action = 'Updating Restaurant table'  

UPDATE [Restaurant]
	SET	[RestaurantType] = @RestaurantType,
		[Allotment] = @Allotment,
		[IsConnectFieldTest] = @IsConnectFieldTest
	WHERE	[RID] = @RestaurantID
set @DBError = @@error  
if @DBError <> 0  
 goto error  


Return(0)  
  
error:  
 exec procLogProcedureError 1, @ProcName, @Action, @DBError  
 Return(1)  
  
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateRestaurantType] TO ExecuteOnlyRole

GO