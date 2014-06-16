if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserUpdatePromoEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserUpdatePromoEmail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.DNUserUpdatePromoEmail
	-- Add the parameters for the stored procedure here
	@Email nvarchar(255), 
	@SendPromoEmail bit 
AS
BEGIN
	SET NOCOUNT ON
	declare @UserID  INT
	DECLARE @MetroAreaID INT
	
	select @UserID = CustID, @MetroAreaID = MetroAreaID
	from Customer with (nolock)
	where Email = @Email 
	
	if (@UserID is not null)
	begin			
		update UserOptIn
			set SpotLight = @SendPromoEmail, UpdatedDtUTC = getutcdate()
		where CustID =@UserID  and SpotLight <> @SendPromoEmail AND MetroAreaID = @MetroAreaID
		
		update Customer
			set SendPromoEmail = @SendPromoEmail
		where CustID =@UserID and SendPromoEmail <> @SendPromoEmail
		
		select 1
	end else
	begin 
		select @UserID = CallerID, @MetroAreaID = MetroAreaID
		from Caller with (nolock)
		where LoginName = @Email

		if (@UserID is not null)
		begin
			update UserOptIn
				set SpotLight = @SendPromoEmail, UpdatedDtUTC = getutcdate()
			where CallerID =@UserID  and SpotLight <> @SendPromoEmail AND MetroAreaID = @MetroAreaID
			
			update Caller
				set SendPromoEmail = @SendPromoEmail
			where CallerID =@UserID  and SendPromoEmail <> @SendPromoEmail
			
			select 1
		end
		else
			select 0

	end		
END
GO

GRANT EXECUTE ON [DNUserUpdatePromoEmail] TO ExecuteOnlyRole
GO
