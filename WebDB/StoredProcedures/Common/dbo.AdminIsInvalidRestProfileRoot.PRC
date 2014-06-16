if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminIsInvalidRestProfileRoot]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminIsInvalidRestProfileRoot]
GO

CREATE PROCEDURE dbo.AdminIsInvalidRestProfileRoot
(
	@RID 				int,
	@RestProfileRoot  	nvarchar(255)
 )
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

set ansi_warnings on
set arithabort on 
set quoted_identifier on

declare @currentNLData1		nvarchar(200)
declare @RestProfileNLData1 nvarchar(200)
declare @MapFilePublishedDt  datetime
declare @myerror int


set @RestProfileNLData1 =  dbo.Rstrip(dbo.Lstrip(dbo.fNLURLEncode(@RestProfileRoot), '-'), '-');

SELECT @currentNLData1 = NLData1, @MapFilePublishedDt = MapFilePublishedDt
FROM dbo.NLURLVw v
WHERE	RID=@RID AND v.NLDataID IN
(
	SELECT MAX(NLDataID) FROM dbo.NLURLVw
	WHERE NLRuleID = 8   -- Rest_Profile.aspx
	GROUP BY RID
) 

IF (@currentNLData1 IS NOT NULL AND @RestProfileNLData1 = @currentNLData1)
BEGIN  --  value is same as current value
	SELECT -1
	RETURN
END

BEGIN TRAN IsValidRoot
BEGIN TRY
	IF (@currentNLData1 IS NOT NULL AND @MapFilePublishedDt is null)
	BEGIN
		UPDATE NLData 
			set NLData1 = @RestProfileNLData1,
				LastModifiedDT = getdate()
		WHERE
				NLRuleID=8      -- NL Rule for rest_profile.aspx
				and RID=@RID
				and MapFilePublishedDt is null
	END ELSE BEGIN
		INSERT INTO NLData (
			NLRuleID
			,RID
			,NLData1
			,LastModifiedDT
			)
		VALUES
		(
			8				--NLRuleID for rest_profile.aspx
			,@RID
			,@RestProfileNLData1
			,getdate()
		)
	END
	SET @myerror = @@ERROR
	ROLLBACK TRAN IsValidRoot
END TRY
BEGIN CATCH
	SET @myerror = @@ERROR
	ROLLBACK TRAN IsValidRoot
END CATCH

SELECT @myError
GO

GRANT EXECUTE ON [AdminIsInvalidRestProfileRoot] TO ExecuteOnlyRole
GO
