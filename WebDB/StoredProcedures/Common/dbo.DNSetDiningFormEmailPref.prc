if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSetDiningFormEmailPref]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSetDiningFormEmailPref]
GO


-- Save dining form email opt in settings
CREATE PROCEDURE dbo.DNSetDiningFormEmailPref
(
     @theResID int,
     @theOptOutFlag bit     
)

AS

declare @CallerID int
declare @CustID int

-- Get the CallerID on the reso to determine if this is an Admin or regular account
SELECT	top 1
		 @CallerID =  r.CallerID
		,@CustID = r.CustID
FROM	Reservation r with (nolock)
WHERE	r.ResID = @theResID


IF(@CallerID is not null)

	BEGIN -- This is an Admin account

		UPDATE 		Caller 
		SET 		DiningFormEmailOptIn = @theOptOutFlag
		WHERE 		Callerid = @CallerID
		
	END

ELSE 

	BEGIN -- Regular customer account

		update customer set DiningFormEmailOptIn=@theOptOutFlag
		where 
		custid = (@CustID)

	END


GO

GRANT EXECUTE ON [DNSetDiningFormEmailPref] TO ExecuteOnlyRole

GO
