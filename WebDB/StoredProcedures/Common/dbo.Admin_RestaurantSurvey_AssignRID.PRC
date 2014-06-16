if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RestaurantSurvey_AssignRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RestaurantSurvey_AssignRID]
GO

CREATE PROCEDURE [dbo].[Admin_RestaurantSurvey_AssignRID]
(
    @RID						INT,	
    @RestaurantSurveyID			INT,
    @AssociateRIDToSurvey		BIT
)
As

BEGIN TRANSACTION
declare @Action as nvarchar(3000)
declare @ProcName as nvarchar(1000)
declare @DBError int

set @ProcName = 'Admin_RestaurantSurvey_AssignRID'

set @Action = 'Associate Restaurant Survey with a RID'


delete from RestaurantSurveyRestaurants 
	where RID = @RID and RestaurantSurveyID = @RestaurantSurveyID

if @AssociateRIDToSurvey = 1
begin
Insert Into RestaurantSurveyRestaurants (RestaurantSurveyID, RID)
	values (@RestaurantSurveyID, @RID)
end


set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return (1)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)  
GO	

-- Set Permission 
GRANT EXECUTE ON [Admin_RestaurantSurvey_AssignRID] TO ExecuteOnlyRole 
GO 


