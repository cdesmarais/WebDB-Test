if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Convert_Consumer_Type]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Convert_Consumer_Type]
GO

CREATE Procedure dbo.User_Convert_Consumer_Type

@Customer_ID			int = NULL,
@Caller_ID			int = NULL,
@Original_Consumer_Type_ID 	int,
@New_Consumer_Type_ID		int

AS
/*revised for new schema 8/5/2003 --JD*/

INSERT INTO ConsumerTypeConvertLog
	(CustID,
	CallerID,
	OriginalConsumerTypeID,
	NewConsumerTypeID,
	ConvertDate)
VALUES
	(@Customer_ID,
	@Caller_ID,
	@Original_Consumer_Type_ID,
	@New_Consumer_Type_ID,
	getdate())
GO

GRANT EXECUTE ON [User_Convert_Consumer_Type] TO ExecuteOnlyRole

GO
