if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateUserSuggestionAttribute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateUserSuggestionAttribute]
GO

CREATE PROCEDURE dbo.DNUpdateUserSuggestionAttribute
(
	@SuggAttrID int,
	@Userid int,
	@IsCaller bit,
	@RIDString nvarchar(2000),
	@ListLength int
)

As

/*
Stored procedure to update a comma separated list of RIDs for users that have had 
reservations booked.

The initial purpose for this return set is to determine an exclusion list
for restaurnts to be recommended to diners.
*/
SET NOCOUNT ON

set transaction isolation level read uncommitted

declare @tempAttrVal nvarchar(2000)
declare @NewList nvarchar(2000)
declare @InTable int

-- Determine if the caller or customer is being updated or inserted
if @IsCaller = 0
begin
	select					@tempAttrVal = AttributeValue							
	from					UserSuggestionAttribute
	where					CustID = @Userid
	and						SuggestionAttributeID = @SuggAttrID	

	set @InTable = @@rowcount
	
	--Put together the list of restaurants
	if @tempAttrVal is null or len(@tempAttrVal) = 0
		set @tempAttrVal = @RIDString
	else
		set @tempAttrVal = @RIDString + ',' + @tempAttrVal
		
	--Now just grab the first n values from the string that's concatted, split into rows
	--then coalesce into a CSV string
	select					top (@ListLength) @NewList =  coalesce( @NewList + ',','') + cast(Id as nvarchar)
	from					dbo.fIDStrToTab(@tempAttrVal,',')
	
	--If the row exists just update, otherwise insert
	if @InTable = 1
		begin
			update					UserSuggestionAttribute
			set						AttributeValue = (@NewList)
			where					CustID = @Userid
			and						SuggestionAttributeID = @SuggAttrID			
		end --end update
	else --insert a row
		begin
			insert into				UserSuggestionAttribute
			(SuggestionAttributeID,CustID,AttributeValue,CreateDateUTC)
			values (@SuggAttrID, @Userid, @NewList, getutcdate())
		end --end insertion
end --end IsCaller=0
else --caller
begin
	select					@tempAttrVal = AttributeValue
	from					UserSuggestionAttribute
	where					CallerID = @Userid
	and						SuggestionAttributeID = @SuggAttrID	

	set @InTable = @@rowcount
	
	--Put together the list of restaurants
	if @tempAttrVal is null or len(@tempAttrVal) = 0
	begin		
		set @tempAttrVal = @RIDString
	end
	else
		set @tempAttrVal = @RIDString + ',' + @tempAttrVal
		
	--Now just grab the first n values from the string that's concatted, split into rows
	--then coalesce into a CSV string
	select					top (@ListLength) @NewList =  coalesce( @NewList + ',','') + cast(Id as nvarchar)
	from					dbo.fIDStrToTab(@tempAttrVal,',')
	
	--If the row exists just update, otherwise insert
	if @InTable = 1
		begin
			update					UserSuggestionAttribute
			set						AttributeValue = (@NewList)
			where					CallerID = @Userid
			and						SuggestionAttributeID = @SuggAttrID			
		end --end update
	else --insert a row
		begin
			insert into				UserSuggestionAttribute
			(SuggestionAttributeID,CallerID,AttributeValue,CreateDateUTC)
			values (@SuggAttrID, @Userid, @NewList, getutcdate())
		end --end insertion
end --end IsCaller=1
	
GO

GRANT EXECUTE ON [DNUpdateUserSuggestionAttribute] TO ExecuteOnlyRole

GO
