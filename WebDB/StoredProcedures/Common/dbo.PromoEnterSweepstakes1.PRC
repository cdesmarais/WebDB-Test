if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoEnterSweepstakes1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromoEnterSweepstakes1]
GO


CREATE PROCEDURE dbo.PromoEnterSweepstakes1
 (
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @Email nvarchar(255),
  @Phone nvarchar(255),
  @Age nvarchar(255),
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @State nvarchar(255),
  @Zip nvarchar(255),
  @SendEmail bit,
  @EnteredCity nvarchar(255)
 )
As
SET NOCOUNT ON
INSERT INTO PromoSweepstakes1
    (FName,LName,Email,Phone,Age,Address1,Address2,City,State,ZipCode,SendEmail,CitEntered)
VALUES (@FirstName,@LastName,@Email,@Phone,@Age,@Address1,@Address2,@City,@State,@Zip,@SendEmail,@EnteredCity)


GO



GRANT EXECUTE ON [PromoEnterSweepstakes1] TO ExecuteOnlyRole

GO
