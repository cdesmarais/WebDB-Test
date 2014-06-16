if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetCustomerDataForSFB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetCustomerDataForSFB]
GO

CREATE PROCEDURE dbo.DNGetCustomerDataForSFB
(
     @ResID 	int
	,@RID	int
	,@CustomerID	int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @RestaurantName		nvarchar(255)
declare @MetroAreaID		int
declare @SentEmailCount		int
declare @CustomerEmail		nvarchar(75)
declare @CustomerFirstName	nvarchar(40)
declare @CustomerLastName	nvarchar(40)
declare @ConsumerType		int
declare @CallerID			int
declare @IsAdmin			bit

select		@RestaurantName = r.RName
			,@MetroAreaID = n.MetroAreaID
from		RestaurantAVW r
inner join	NeighborhoodAVW n on r.NeighborhoodID = n.NeighborhoodID
and			r.LanguageID = n.LanguageID
where		r.RID = @RID

select 		@SentEmailCount = sfb.SendEmailCount
from		SFBEmailCountByReso sfb
where		sfb.ResID = @ResID

IF EXISTS(Select CustID From CallerCustomer Where CustID = @CustomerID) 
	
	BEGIN -- This is an Admin account
	
		select		 @CustomerEmail = c.Email
					,@CustomerFirstName = c.FName
					,@CustomerLastName = c.LName
					,@ConsumerType = NULL
					,@CallerID = c.CallerID
					
		from		Caller c
		inner join	CallerCustomer cc on c.CallerID = cc.CallerID
		where		cc.CustID = @CustomerID		
	
	END

ELSE
	
	BEGIN --This is a regular customer account

		select		 @CustomerEmail = cust.Email
					,@CustomerFirstName = cust.FName
					,@CustomerLastName = cust.LName
					,@ConsumerType = cust.ConsumerType
					,@CallerID = cust.CallerID

		from		Customer cust
		where		cust.CustID = @CustomerID
		
	END



select		@RestaurantName as RestaurantName
			,@MetroAreaID as MetroAreaID
			,@SentEmailCount as SentEmailCount
			,@CustomerEmail as CustomerEmail
			,@CustomerFirstName as CustomerFirstName
			,@CustomerLastName as CustomerLastName
			,@ConsumerType as ConsumerType
			,@CallerID as CallerID

GO


GRANT EXECUTE ON [DNGetCustomerDataForSFB] TO ExecuteOnlyRole

GO

