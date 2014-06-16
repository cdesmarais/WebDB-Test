if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConValidateShiftSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConValidateShiftSummary]
GO


CREATE PROCEDURE dbo.OTConValidateShiftSummary
(
	@RID						INT,
	@OldStartTime				TIME,
	@OldEndTime					TIME,
	@NewStartTime				TIME,
	@NewEndTime					TIME,
	@DaysOfWeek					VARBINARY(1),  -- Days of the week the shift is OPEN
	@MaxPartySize				INT,
	@MaxCoversAllowed			INT
)

AS
--
--  calls dbo.OTConValidateShift and returns a summary that shows whether any instance
--  of a given error was found.
--

-- create a table var to hold the detail results

DECLARE @ValidationDetails TABLE
(
	ShiftDate					DATE,
	TimeViolationCount			INT,
	PartySizeViolationCount		INT,
	DOWViolationCount			INT,
	OverbookingViolationCount	INT
)

-- populate the table var with the details info
INSERT INTO @ValidationDetails (ShiftDate, TimeViolationCount, PartySizeViolationCount, DOWViolationCount, OverbookingViolationCount)
  EXEC procOTConValidateShift @RID, @OldStartTime, @OldEndTime, @NewStartTime, @NewEndTime, @DaysOfWeek, @MaxPartySize, @MaxCoversAllowed

-- compute and return the summary column
SELECT
	SUM (TimeViolationCount) AS 'TimeViolationsFound',
	SUM (PartySizeViolationCount) AS 'PartySizeViolationsFound',
	SUM (DOWViolationCount) AS 'DOWViolationsFound',
	SUM (OverbookingViolationCount) AS 'OverbookingViolationsFound'

FROM @ValidationDetails

GO

GRANT EXECUTE ON [OTConValidateShiftSummary] TO ConsoleExecuteRole

GO
