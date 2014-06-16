if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateReviewSuppression]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateReviewSuppression]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_UpdateReviewSuppression
(
  @RestaurantID int,
  @ReservationID int,
  @bSuppressReview bit
)
AS

--set the suppress date column only when review is suppressed.
--if the review is unsuppressed, then it will be updated with null value.

if(@bSuppressReview = 1)
Begin
	update	StartPageReviews set
			Suppressed = @bSuppressReview,
			SuppressedDate = GETDATE()
	where	ResID = @ReservationID
	and		RID	= @RestaurantID
End
else
Begin
	update	StartPageReviews set
			Suppressed = @bSuppressReview,
			SuppressedDate = NULL
	where	ResID = @ReservationID
	and		RID	= @RestaurantID
	and		SuppressedDate >= dbo.fGetDatePart(GETDATE())
End
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateReviewSuppression] TO ExecuteOnlyRole

GO

