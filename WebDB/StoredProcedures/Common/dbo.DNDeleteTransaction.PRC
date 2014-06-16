
 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNDeleteTransaction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNDeleteTransaction]

GO
CREATE PROCEDURE dbo.DNDeleteTransaction

(
            @transactionID int
)

As

delete uploadtransactionlog where transactionid = @transactionid

GO

 GRANT EXECUTE ON [DNDeleteTransaction] TO ExecuteOnlyRole

 

GO
