if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Add_SurveyInformation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Add_SurveyInformation]
GO

/******* Object:  StoredProcedure [dbo].[Admin_Restaurant_Add_SurveyInformation]    Script Date: 03/11/2013 08:26:31 ******/

CREATE PROCEDURE [dbo].[Admin_Restaurant_Add_SurveyInformation]
    @Name						VARCHAR(50)	= NULL,
    @RestaurantSurveyTypeID		INT				= NULL,
    @Code						NVARCHAR(50)   = '',
    @Active						BIT				= 0,
    @Question					NVARCHAR(250)   = '',
    @FeedbackYes				NVARCHAR(250)   = '',
    @FeedbackInput				NVARCHAR(250)	= '',
    @FeedbackNo					NVARCHAR(250)   = '',
    @UpdatedDate				datetime		= NULL,
    @UpdatedBy					NVARCHAR(100)	= '',
    @SurveyIDRET					INT				= NULL OUTPUT
    
AS

	declare @SurveyID int
	declare @Action as nvarchar(3000)
	declare @DBError int
	declare @PageID int	
	declare @ProcName as nvarchar(1000)	
BEGIN TRANSACTION

	set @ProcName = 'Admin_Restaurant_Add_SurveyInformation'
	
	set @Action = 'Insert row into RestaurantSurveys'

    INSERT INTO dbo.RestaurantSurveys
       (
			RestaurantSurveyTypeID,
    		Name,
    		Code,
    		Active,
    		UpdatedDate,
    		UpdatedBy
    	)
    VALUES
       (
			@RestaurantSurveyTypeID,
			@Name,
    		@Code,
    		@Active,
    		@UpdatedDate,
    		@UpdatedBy
    	)

	set @DBError = @@error
	if @DBError <> 0
		goto general_error
		
    set @SurveyID = SCOPE_IDENTITY();
    
    set @Action = 'Insert row into RestaurantSurveysLocal'
    
    INSERT INTO dbo.RestaurantSurveysLocal
       (
			RestaurantSurveyID,
    		LanguageID,
    		Question,
    		FeedbackYes,
    		FeedbackInput,
    		FeedbackNo
    	)
    	 Select @SurveyID as RestaurantSurveyID,
			LanguageID,
			@Question as Question, 
			@FeedbackYes as FeedbackYes,
			@FeedbackInput as FeedbackInput,
			@FeedbackNo as FeedbackNo
			from 	[Language] 
			WHERE 	active = 1

	set @DBError = @@error
	if @DBError <> 0
		goto general_error
   
COMMIT TRANSACTION
set @SurveyIDRET =  @SurveyID
Return(1)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)  

GO	
	
GRANT EXECUTE ON [Admin_Restaurant_Add_SurveyInformation] TO ExecuteOnlyRole

GO 
    
