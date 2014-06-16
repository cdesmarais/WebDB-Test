if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetNLMapGenerationDateTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetNLMapGenerationDateTime]
GO

CREATE PROCEDURE dbo.DNGetNLMapGenerationDateTime 
(
	@Date	datetime = NULL OUTPUT
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @GenDate datetime, @GenTime datetime, @CurrentDate datetime

SELECT @GenDate = [ValueDT] 
FROM  [dbo].[ValueLookup]
WHERE LType = 'ISAPIWEB' AND LKey = 'NLMapFileGenerationDate'

SELECT @GenTime = [ValueDT] 
FROM  [dbo].[ValueLookup]
WHERE LType = 'ISAPIWEB' AND LKey = 'NLMapFileGenerationTime'

IF (@GenTime is null)
BEGIN
	SET @Date = @GenDate
END  ELSE
BEGIN
	SET @CurrentDate = getdate();
	SET @GenTime = cast(convert(nvarchar(10), @CurrentDate, 101) as datetime) + cast(convert(nvarchar(10), @GenTime, 108) as datetime)
	IF (@GenDate is  null)
	BEGIN
		SET @Date = @GenTime
	END ELSE
	BEGIN
		declare @span int
		SELECT @span = datediff(hour, @GenDate, @GenTime)
		
		--  If GenDate is set to within 3 hours of  GenTime then
		--  GenDate overrides the GenTime and the Map file generation/publishing is done at datetime specified by GenDate.
		if (@span between -3 and 3)  -- within span of 3 hours
		BEGIN 
			SET @Date =  @GenDate 
		END ELSE if (DateDiff(d, @GenDate, @CurrentDate) <> 0)
		BEGIN
			SET @Date = @GenTime
		END ELSE
		BEGIN
			IF (@GenTime <  @CurrentDate  AND @GenDate < @CurrentDate)
			BEGIN
				IF  (@GenTime > @GenDate)
					SET @Date =  @GenTime
				ELSE
					SET @Date =  @GenDate
			END
			ELSE IF (@GenTime < @CurrentDate)
				SET @Date =  @GenTime
			ELSE IF (@GenDate < @CurrentDate)
				SET @Date =  @GenDate
			ELSE IF (@GenDate < @GenTime)
				SET @Date =  @GenDate
			ELSE
				SET @Date =  @GenTime					
		END
	END
END
GO

GRANT EXECUTE ON [DNGetNLMapGenerationDateTime] TO ExecuteOnlyRole
GO
