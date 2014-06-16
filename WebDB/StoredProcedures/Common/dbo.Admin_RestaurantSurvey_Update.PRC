
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RestaurantSurvey_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RestaurantSurvey_Update]
GO
/****** Object:  StoredProcedure [dbo].[Admin_RestaurantSurvey_Update]    Script Date: 03/07/2013 08:16:40 ******/

CREATE PROCEDURE [dbo].[Admin_RestaurantSurvey_Update]
(
    @Name						VARCHAR(50),	
    @RestaurantSurveyTypeID		INT,				
    @Code						NVARCHAR(50),  
    @Active						BIT,				
    @Question					NVARCHAR(250),   
    @FeedbackYes				NVARCHAR(250),   
    @FeedbackInput				NVARCHAR(250),	
    @FeedbackNo					NVARCHAR(250),  
    @UpdatedDate				datetime,		
    @UpdatedBy					NVARCHAR(100),
    @RestaurantSurveyID			INT,
    @LanguageID					INT = 1	
)
As

BEGIN TRANSACTION
	declare @SurveyID int
	declare @Action as nvarchar(3000)
	declare @DBError int
	declare @ProcName as nvarchar(1000)
	set @ProcName = 'Admin_RestaurantSurvey_Update'
	
	set @Action = 'Update RestaurantSurveys table'


Update RestaurantSurveys Set 
	Name = @Name,
	RestaurantSurveyTypeID = @RestaurantSurveyTypeID,
	UpdatedBy = @UpdatedBy,
	UpdatedDate = getdate(),
	Code = @Code
	
where 	RestaurantSurveyID = @RestaurantSurveyID 

set @DBError = @@error
if @DBError <> 0
	goto general_error


set @Action = 'Update RestaurantSurveysLocal table'

Update RestaurantSurveysLocal Set 
	Question = @Question,
	FeedbackYes = @FeedbackYes,
	FeedbackNo	= @FeedbackNo,
	FeedbackInput = @FeedbackInput

where 	RestaurantSurveyID = @RestaurantSurveyID 
and 	LanguageID = @LanguageID	

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

GRANT EXECUTE ON [Admin_RestaurantSurvey_Update] TO ExecuteOnlyRole

GO