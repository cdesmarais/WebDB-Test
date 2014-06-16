


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCustomerDetail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCustomerDetail]
GO

create procedure dbo.GetCustomerDetail 
(   
  @CustomerID int,  
  @IsCaller int  
)
AS   

/*****************************************************************
Purpose : Get customer details-Name and current balance to display 
		  on CHARM Points Adjustment & History Tracking screen.
*****************************************************************/
if @IsCaller = 0 
begin
	-- Get customer detail from customer table.
	select 
		Coalesce(cust.FName,'') +' '+ Coalesce(cust.LName,'') as CustomerName,
		cust.Points as BalancePoints,
		cust.ConsumerType
	from 
		customer cust
	where
		cust.custid = @CustomerID
end   
if @IsCaller > 0 
begin 
	-- Get caller detail from caller table.
	select 
		Coalesce(caller.FName,'') +' '+ Coalesce(caller.LName,'') as CustomerName,
		caller.Points as BalancePoints,
		caller.ConsumerType 
	from 
		caller 
	where
		caller.callerid = @CustomerID
end  

GO

GRANT EXECUTE ON [GetCustomerDetail] TO ExecuteOnlyRole
GO