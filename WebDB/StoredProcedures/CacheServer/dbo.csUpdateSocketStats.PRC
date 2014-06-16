--$ create proc csUpdateSocketStats
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csUpdateSocketStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csUpdateSocketStats]
GO

CREATE Procedure dbo.csUpdateSocketStats
(
	 @Source						varchar(64)

	-- Connection Counts
	,@CountConnsInProgress			int
	,@CountConnsPending				int
	,@CountConnsTotalAccepted		int
	,@CountConnsTotalProcessed		int

	-- Buffer Get/Release Counts
	,@CountBufGet					int
	,@CountBufRelease				int
	,@CountBufRelease_RHSockData	int

	-- Enqueue/Dequeue Counts and Errors
	,@EnqueueSW						int
	,@EnqueueRH						int
	,@DequeueSW						int
	,@DequeueRH						int
	,@DequeueFailTotal				int
	,@DequeueFail_NonNull			int
	,@DequeueFail_NetNameDeleted	int
	,@DequeueFail_OpAborted			int
	,@DequeueFail_ConnAborted		int

	-- Socket Manager Thread Event Details
	,@SMEventSignalSocket			int
	,@SMEventSignalAccept			int
	,@SMEventTimeout				int
	,@SMEventFailed					int
	,@SMSocketEnumTotal				int
	,@SMSocketEnum_FDAccept			int
	,@SMSocketEnum_SocketError		int

	-- AllocateBuffer Details
	,@AllocBuffersFail_WSASocket	int
	,@AllocBuffersFail_AcceptEx		int
	,@AllocBuffersFail_CreateIOCP	int
)
As

	insert into CacheServerSocketStats
	(
		 CacheLogDate
		,Source
		,CountConnsInProgress
		,CountConnsPending
		,CountConnsTotalAccepted
		,CountConnsTotalProcessed
		,CountBufGet
		,CountBufRelease
		,CountBufRelease_RHSockData
		,EnqueueSW
		,EnqueueRH
		,DequeueSW
		,DequeueRH
		,DequeueFailTotal
		,DequeueFail_NonNull
		,DequeueFail_NetNameDeleted
		,DequeueFail_OpAborted
		,DequeueFail_ConnAborted
		,SMEventSignalSocket
		,SMEventSignalAccept
		,SMEventTimeout
		,SMEventFailed
		,SMSocketEnumTotal
		,SMSocketEnum_FDAccept
		,SMSocketEnum_SocketError
		,AllocBuffersFail_WSASocket
		,AllocBuffersFail_AcceptEx
		,AllocBuffersFail_CreateIOCP
	)
	values
	(
		 getdate()
		,@Source
		,@CountConnsInProgress
		,@CountConnsPending
		,@CountConnsTotalAccepted
		,@CountConnsTotalProcessed
		,@CountBufGet
		,@CountBufRelease
		,@CountBufRelease_RHSockData
		,@EnqueueSW
		,@EnqueueRH
		,@DequeueSW
		,@DequeueRH
		,@DequeueFailTotal
		,@DequeueFail_NonNull
		,@DequeueFail_NetNameDeleted
		,@DequeueFail_OpAborted
		,@DequeueFail_ConnAborted
		,@SMEventSignalSocket
		,@SMEventSignalAccept
		,@SMEventTimeout
		,@SMEventFailed
		,@SMSocketEnumTotal
		,@SMSocketEnum_FDAccept
		,@SMSocketEnum_SocketError
		,@AllocBuffersFail_WSASocket
		,@AllocBuffersFail_AcceptEx
		,@AllocBuffersFail_CreateIOCP
	)
GO

GRANT EXECUTE ON [csUpdateSocketStats] TO ExecuteOnlyRole
GO
