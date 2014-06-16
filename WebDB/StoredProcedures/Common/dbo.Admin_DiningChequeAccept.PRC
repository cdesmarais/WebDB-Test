if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DiningChequeAccept]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DiningChequeAccept]
GO




CREATE PROCEDURE dbo.Admin_DiningChequeAccept

(@AcceptCheque bit,
 @restaurant_id int
 )

AS
SET NOCOUNT ON

update Restaurant set AcceptCheque = @AcceptCheque where RID = @restaurant_id

GO

GRANT EXECUTE ON [Admin_DiningChequeAccept] TO ExecuteOnlyRole

GO
