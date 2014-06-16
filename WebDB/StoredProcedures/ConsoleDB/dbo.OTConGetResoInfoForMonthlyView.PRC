if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResoInfoForMonthlyView]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResoInfoForMonthlyView]
GO

CREATE Procedure dbo.OTConGetResoInfoForMonthlyView

@RID	INT,
@ClosedDates  ClosedDaySet READONLY,
@OTAShiftData	  OTAShiftDataSet READONLY,
@OTCShiftData	  OTCShiftDataSet READONLY

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @ResosAndMatchingClosedDays TABLE
(
	ShiftDate			DATETIME,
	TotalResos			INT,
	TotalCovers			INT,
	Shift1StatusID		INT,
	Shift1ResoCount		INT,
	Shift1CoverCount	INT,
	Shift1MaxCovers		INT,
	Shift2StatusID		INT,
	Shift2ResoCount		INT,
	Shift2CoverCount	INT,
	Shift2MaxCovers		INT,
	Shift3StatusID		INT,
	Shift3ResoCount		INT,
	Shift3CoverCount	INT,
	Shift3MaxCovers		INT,
	IsClosed			BIT,
	ClosedDayNote		NVARCHAR(128)
)

INSERT INTO @ResosAndMatchingClosedDays

SELECT		csd.ShiftDate,
			COUNT(r.ResID) AS TotalResos, 
			COALESCE(SUM(r.PartySize), 0) AS TotalCovers,
			MAX(CASE WHEN csd.ShiftTypeID = 1 AND asd.IsClosed = 1 THEN 0
					 WHEN csd.ShiftTypeID = 1 AND asd.IsClosed = 0 THEN  csd.ShiftStatus 
					 ELSE NULL 
				END)
				AS Shift1StatusID, -- 1 is open, 0 is closed
			SUM(CASE WHEN csd.ShiftTypeID = 1 AND r.RID IS NOT NULL THEN 1 ELSE 0 END) AS Shift1ResoCount,
			SUM(CASE WHEN csd.ShiftTypeID = 1 AND r.RID IS NOT NULL THEN PartySize ELSE 0 END) as Shift1CoverCount,
			MAX(CASE WHEN csd.ShiftTypeID = 1 THEN csd.MaxCovers ELSE 0 END) AS Shift1MaxCovers,

			MAX(CASE WHEN csd.ShiftTypeID = 2 AND asd.IsClosed = 1 THEN 0
					 WHEN csd.ShiftTypeID = 2 AND asd.IsClosed = 0 THEN  csd.ShiftStatus  
					 ELSE NULL
				END)
				AS Shift2StatusID, -- 1 is open, 0 is closed
			SUM(CASE WHEN csd.ShiftTypeID = 2 AND r.RID IS NOT NULL THEN 1 ELSE 0 END) AS Shift2ResoCount,
			SUM(CASE WHEN csd.ShiftTypeID = 2 AND r.RID IS NOT NULL THEN PartySize ELSE 0 END) as Shift2CoverCount,
			MAX(CASE WHEN csd.ShiftTypeID = 2 THEN csd.MaxCovers ELSE 0 END) AS Shift2MaxCovers,

			MAX(CASE WHEN csd.ShiftTypeID = 3 AND asd.IsClosed = 1 THEN 0
					WHEN csd.ShiftTypeID = 3 AND asd.IsClosed = 0 THEN  csd.ShiftStatus 
				ELSE NULL END)
				AS Shift3StatusID, -- 1 is open, 0 is closed
			SUM(CASE WHEN csd.ShiftTypeID = 3 AND r.RID IS NOT NULL THEN 1 ELSE 0 END) AS Shift3ResoCount,
			SUM(CASE WHEN csd.ShiftTypeID = 3 AND r.RID IS NOT NULL THEN PartySize ELSE 0 END) as Shift3CoverCount,
			MAX(CASE WHEN csd.ShiftTypeID = 3 THEN csd.MaxCovers ELSE 0 END) AS Shift3MaxCovers,
			MAX(COALESCE(cd.IsClosed, 0)) AS IsClosed,
			'' AS ClosedDayNote
	FROM		@OTCShiftData csd 
	
	INNER JOIN	@OTAShiftData asd
	ON			asd.[Date] = csd.ShiftDate
	AND			asd.AttributeID = csd.ShiftNTopScheduleID
	
	LEFT JOIN Reservation r
	ON		   r.RID = @RID
	AND		   r.ShiftDate = csd.ShiftDate
	AND		   CAST(r.ResTime AS TIME) BETWEEN CAST(csd.StartTime AS TIME) AND CAST(csd.EndTime AS TIME)
	AND			r.RStateID  IN (1,2,5,7) -- include Pending,Seated, Assumed Seated, and Seated Disputed
	
	LEFT JOIN	@ClosedDates cd 
	ON			cd.ScheduleDate = csd.ShiftDate
	GROUP BY csd.[ShiftDate]
	ORDER BY ShiftDate
	-- Force the compiler to optimize based on statistics, not based on first execution
	OPTION ( OPTIMIZE FOR (@RID UNKNOWN) );
	
	-- Select again from the generated table, but infer IsClosed from the other computed shift status values
	-- TODO:  Improve this to make it more efficient (i.e. remove the second SELECT)
	SELECT	ShiftDate,
		TotalResos,
		TotalCovers,
		Shift1StatusID,
		Shift1ResoCount,
		Shift1CoverCount,
		Shift1MaxCovers,
		Shift2StatusID,
		Shift2ResoCount,
		Shift2CoverCount,
		Shift2MaxCovers,
		Shift3StatusID,
		Shift3ResoCount,
		Shift3CoverCount,
		Shift3MaxCovers,
		CASE
			WHEN	(Shift1StatusID IS NULL OR Shift1StatusID = 0)
			  AND	(Shift2StatusID IS NULL OR Shift2StatusID = 0)
			  AND	(Shift3StatusID IS NULL OR Shift3StatusID = 0)
			THEN 1
			ELSE 0
		END AS IsClosed,
		ClosedDayNote
FROM	@ResosAndMatchingClosedDays
GO

GRANT EXECUTE ON [OTConGetResoInfoForMonthlyView] TO ConsoleExecuteRole

GO

