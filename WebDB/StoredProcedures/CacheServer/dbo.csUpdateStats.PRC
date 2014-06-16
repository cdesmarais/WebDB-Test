--$ create proc csUpdateStats
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csUpdateStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csUpdateStats]
GO


CREATE Procedure dbo.csUpdateStats
(
	 @Source								varchar(64)

	-- Sample size
	,@SamplePeriodMilliSec					int

	-- Cache slot usage
	,@RestsAllocated						int
	,@RestsTotalUsed						int

	-- Restaurant states
	,@RestsStatusNotCached					int
	,@RestsStatusValid						int
	,@RestsStatusInvalid					int
	,@RestsTotalActive						int
	,@RestsActiveCacheValid					int
	,@RestsActiveCacheInvalid				int

	-- Web Server Messages
	,@MsgCountReachRequest					int
	,@MsgCountAvailRequestSingle			int
	,@MsgCountAvailRequestMulti				int
	,@MsgCountWebPing						int
	,@MsgCountWebPingIP						int
	,@MsgCountWebBatchPing					int
	,@MsgCountInvalidateCache				int
	,@MsgCountUpdateERBData					int

	-- ERB Messages
	,@MsgCountCacheInit						int
	,@MsgCountCacheRefresh					int
	,@MsgCountCacheUpdate					int
	,@MsgCountCacheAddDay					int
	,@MsgCountTimeUpdate					int
	,@MsgCountIPAddrUpdate					int
	,@MsgCountERBPing						int
	,@MsgCountErbAuthRequest				int

	-- Cache Server Messages
	,@MsgCountCacheRequest					int

	-- Heartbeats
	,@HeartbeatsReceived					int

	-- Total/Hit/Miss counts
	,@CacheCountAllTotal					int
	,@CacheCountAllHit						int
	,@CacheCountAllMiss						int
	,@CacheCountCacheCapableTotal			int
	,@CacheCountCacheCapableHit				int
	,@CacheCountCacheCapableMiss			int
	,@CacheCountCachedTotal					int
	,@CacheCountCachedHit					int
	,@CacheCountCachedMiss					int

	-- Search Hit/Miss Details
	,@SearchCountMiss_NotInCache			int
	,@SearchCountMiss_StatusNotCached		int
	,@SearchCountMiss_LTCTooOld				int
	,@SearchCountMiss_UnpingSet				int
	,@SearchCountMiss_StatusInvalid			int
	,@SearchCountMiss_PartySizeNotCached	int
	,@SearchCountMiss_DateNotSearchable		int
	,@SearchCountHit_DateInPast				int
	,@SearchCountHit_Normal					int

	-- Search Results
	,@SearchAvailBefore						int
	,@SearchAvailExact						int
	,@SearchAvailAfter						int

	-- Response Times
	,@SearchResponseTimeProcessedSumSingle	int
	,@SearchResponseTimeProcessedSumMulti	int
	,@SearchResponseTimeProcessedMaxSingle	int
	,@SearchResponseTimeProcessedMaxMulti	int
	,@SearchResponseTimeSentSumSingle		int
	,@SearchResponseTimeSentSumMulti		int
	,@SearchResponseTimeSentMaxSingle		int
	,@SearchResponseTimeSentMaxMulti		int

	,@ErbMsgResponseTimeProcessedSum		int
	,@ErbMsgResponseTimeProcessedMax		int
	,@ErbMsgResponseTimeSentSum				int
	,@ErbMsgResponseTimeSentMax				int
	,@WebMsgResponseTimeProcessedSum		int
	,@WebMsgResponseTimeProcessedMax		int
	,@WebMsgResponseTimeSentSum				int
	,@WebMsgResponseTimeSentMax				int

	-- Error Conditions
	,@ErrorSeqNumMismatch_CacheUpdate		int
	,@ErrorSeqNumMismatch_CacheAddDay		int
	
	-- Lock Contention
	,@ContentionCount_Cache 				int = 0
	,@ContentionCount_AuthLog 				int = 0
	,@ContentionCount_NetAddr 				int = 0
	,@ContentionCount_Stats 				int = 0
	,@ContentionCount_InternalIP 			int = 0
	,@ContentionCount_ToBeAddedRID 			int = 0
	,@ContentionCount_WLogMap 				int = 0
	,@ContentionCount_CacheTuning 			int = 0
	,@ContentionCount_AuditFailure 			int = 0
	,@ContentionCount_SettingsManager 		int = 0
	,@ContentionCount_ReqBuf                int = 0
	,@ContentionCount_SockList              int = 0

	-- thread usage
	,@ThreadCountRH							int = 0
	,@MaxRHThreadsInUse						int = 0
	,@ThreadCountSW							int = 0
	,@MaxSWThreadsInUse						int = 0

	,@MsgCountDebugRequest					int = 0
	,@MsgCountEventAudit					int = 0

	,@OutboundResponseTimeSentSum			int = 0
	,@OutboundResponseTimeSentMax			int = 0

	,@ThreadCountOutbound					int = 0
	,@MaxOutboundThreadsInUse				int = 0

	-- Email counts
	,@EmailCount_RogueERB					int = 0
	,@EmailCount_DBError					int = 0
	,@EmailCount_CacheFull					int = 0
	,@EmailCount_InternalError				int = 0
	,@EmailCount_Startup					int = 0
	,@EmailCount_ProtocolError				int = 0

	-- New error counts
	,@ErrorEmptyCacheRefresh				int = 0

	-- New Multi-Day Search stats
	,@MsgCountAvailRequestSingleMD				int = 0
	,@MsgCountAvailRequestMultiMD				int = 0	
	,@SearchResponseTimeProcessedSumSingleMD	int = 0
	,@SearchResponseTimeProcessedSumMultiMD		int = 0
	,@SearchResponseTimeProcessedMaxSingleMD	int = 0
	,@SearchResponseTimeProcessedMaxMultiMD		int = 0
	,@SearchResponseTimeSentSumSingleMD			int = 0
	,@SearchResponseTimeSentSumMultiMD			int = 0
	,@SearchResponseTimeSentMaxSingleMD			int = 0
	,@SearchResponseTimeSentMaxMultiMD			int = 0

	-- New for Cache Server 1.4
	,@MaxOutboundQueueLength    				int = 0
	,@MaxRHQueueLength     						int = 0
	,@ThreadCountWebRH							int = 0
	,@MaxWebRHThreadsInUse						int = 0
	,@MaxWebRHQueueLength     					int = 0
	,@SearchCountMiss_NotOwned					int = 0
	,@RestsOwned								int = 0
	,@MsgCountNotOwned							int = 0
	,@RestContactUpdateCount					int = 0
	,@OutboundFailTotal							int = 0
	,@OutboundFailConnRefused					int = 0
	,@OutboundFailConnReset						int = 0
	,@OutboundFailConnAborted					int = 0
	,@MsgCountSetval							int = 0
	,@MsgCountReloadconfig						int = 0
	,@QueueCountAdd								int = 0
	,@QueueCountDelete							int = 0
	,@QueueCountInfo							int = 0
	,@RestsReachable							int = 0
)
As

	insert into CacheServerStats
	(
		 Source
		,CacheLogDate
		,SamplePeriodMilliSec
		,RestsAllocated
		,RestsTotalUsed
		,RestsStatusNotCached
		,RestsStatusValid
		,RestsStatusInvalid
		,RestsTotalActive
		,RestsActiveCacheValid
		,RestsActiveCacheInvalid
		,MsgCountReachRequest
		,MsgCountAvailRequestSingle
		,MsgCountAvailRequestSingleMD
		,MsgCountAvailRequestMulti
		,MsgCountAvailRequestMultiMD
		,MsgCountWebPing
		,MsgCountWebPingIP
		,MsgCountWebBatchPing
		,MsgCountInvalidateCache
		,MsgCountUpdateERBData
		,MsgCountCacheInit
		,MsgCountCacheRefresh
		,MsgCountCacheUpdate
		,MsgCountCacheAddDay
		,MsgCountTimeUpdate
		,MsgCountIPAddrUpdate
		,MsgCountERBPing
		,MsgCountErbAuthRequest
		,MsgCountCacheRequest
		,HeartbeatsReceived
		,CacheCountAllTotal
		,CacheCountAllHit
		,CacheCountAllMiss
		,CacheCountCacheCapableTotal
		,CacheCountCacheCapableHit
		,CacheCountCacheCapableMiss
		,CacheCountCachedTotal
		,CacheCountCachedHit
		,CacheCountCachedMiss
		,SearchCountMiss_NotInCache
		,SearchCountMiss_StatusNotCached
		,SearchCountMiss_LTCTooOld
		,SearchCountMiss_UnpingSet
		,SearchCountMiss_StatusInvalid
		,SearchCountMiss_PartySizeNotCached
		,SearchCountMiss_DateNotSearchable
		,SearchCountHit_DateInPast
		,SearchCountHit_Normal
		,SearchAvailBefore
		,SearchAvailExact
		,SearchAvailAfter
		,SearchResponseTimeProcessedSumSingle
		,SearchResponseTimeProcessedSumSingleMD
		,SearchResponseTimeProcessedSumMulti
		,SearchResponseTimeProcessedSumMultiMD
		,SearchResponseTimeProcessedMaxSingle
		,SearchResponseTimeProcessedMaxSingleMD
		,SearchResponseTimeProcessedMaxMulti
		,SearchResponseTimeProcessedMaxMultiMD
		,SearchResponseTimeSentSumSingle
		,SearchResponseTimeSentSumSingleMD
		,SearchResponseTimeSentSumMulti
		,SearchResponseTimeSentSumMultiMD
		,SearchResponseTimeSentMaxSingle
		,SearchResponseTimeSentMaxSingleMD
		,SearchResponseTimeSentMaxMulti
		,SearchResponseTimeSentMaxMultiMD
		,ErbMsgResponseTimeProcessedSum
		,ErbMsgResponseTimeProcessedMax
		,ErbMsgResponseTimeSentSum
		,ErbMsgResponseTimeSentMax
		,WebMsgResponseTimeProcessedSum
		,WebMsgResponseTimeProcessedMax
		,WebMsgResponseTimeSentSum
		,WebMsgResponseTimeSentMax
		,ErrorSeqNumMismatch_CacheUpdate
		,ErrorSeqNumMismatch_CacheAddDay
		,ContentionCount_Cache
		,ContentionCount_AuthLog
		,ContentionCount_NetAddr
		,ContentionCount_Stats
		,ContentionCount_InternalIP
		,ContentionCount_ToBeAddedRID
		,ContentionCount_WLogMap
		,ContentionCount_CacheTuning
		,ContentionCount_AuditFailure
		,ContentionCount_SettingsManager
		,ContentionCount_ReqBuf
		,ContentionCount_SockList
		,ThreadCountRH
		,MaxRHThreadsInUse
		,ThreadCountSW
		,MaxSWThreadsInUse
		,ThreadCountOutbound
		,MaxOutboundThreadsInUse
		,MsgCountDebugRequest
		,MsgCountEventAudit
		,OutboundResponseTimeSentSum
		,OutboundResponseTimeSentMax
		,EmailCount_RogueERB		
		,EmailCount_DBError		
		,EmailCount_CacheFull	
		,EmailCount_InternalError
		,EmailCount_Startup
		,EmailCount_ProtocolError
		,ErrorEmptyCacheRefresh
		,MaxOutboundQueueLength
		,MaxRHQueueLength
		,ThreadCountWebRH
		,MaxWebRHThreadsInUse
		,MaxWebRHQueueLength
		,SearchCountMiss_NotOwned
		,RestsOwned
		,MsgCountNotOwned
		,RestContactUpdateCount
		,OutboundFailTotal							
		,OutboundFailConnRefused					
		,OutboundFailConnReset						
		,OutboundFailConnAborted		
		,MsgCountSetval							
		,MsgCountReloadconfig			
		,QueueCountAdd			
		,QueueCountDelete			
		,QueueCountInfo			
		,RestsReachable
	)
	values
	(
		 @Source
		,getdate()
		,@SamplePeriodMilliSec
		,@RestsAllocated
		,@RestsTotalUsed
		,@RestsStatusNotCached
		,@RestsStatusValid
		,@RestsStatusInvalid
		,@RestsTotalActive
		,@RestsActiveCacheValid
		,@RestsActiveCacheInvalid
		,@MsgCountReachRequest
		,@MsgCountAvailRequestSingle
		,@MsgCountAvailRequestSingleMD
		,@MsgCountAvailRequestMulti
		,@MsgCountAvailRequestMultiMD
		,@MsgCountWebPing
		,@MsgCountWebPingIP
		,@MsgCountWebBatchPing
		,@MsgCountInvalidateCache
		,@MsgCountUpdateERBData
		,@MsgCountCacheInit
		,@MsgCountCacheRefresh
		,@MsgCountCacheUpdate
		,@MsgCountCacheAddDay
		,@MsgCountTimeUpdate
		,@MsgCountIPAddrUpdate
		,@MsgCountERBPing
		,@MsgCountErbAuthRequest
		,@MsgCountCacheRequest
		,@HeartbeatsReceived
		,@CacheCountAllTotal
		,@CacheCountAllHit
		,@CacheCountAllMiss
		,@CacheCountCacheCapableTotal
		,@CacheCountCacheCapableHit
		,@CacheCountCacheCapableMiss
		,@CacheCountCachedTotal
		,@CacheCountCachedHit
		,@CacheCountCachedMiss
		,@SearchCountMiss_NotInCache
		,@SearchCountMiss_StatusNotCached
		,@SearchCountMiss_LTCTooOld
		,@SearchCountMiss_UnpingSet
		,@SearchCountMiss_StatusInvalid
		,@SearchCountMiss_PartySizeNotCached
		,@SearchCountMiss_DateNotSearchable
		,@SearchCountHit_DateInPast
		,@SearchCountHit_Normal
		,@SearchAvailBefore
		,@SearchAvailExact
		,@SearchAvailAfter
		,@SearchResponseTimeProcessedSumSingle
		,@SearchResponseTimeProcessedSumSingleMD
		,@SearchResponseTimeProcessedSumMulti
		,@SearchResponseTimeProcessedSumMultiMD
		,@SearchResponseTimeProcessedMaxSingle
		,@SearchResponseTimeProcessedMaxSingleMD
		,@SearchResponseTimeProcessedMaxMulti
		,@SearchResponseTimeProcessedMaxMultiMD
		,@SearchResponseTimeSentSumSingle
		,@SearchResponseTimeSentSumSingleMD
		,@SearchResponseTimeSentSumMulti
		,@SearchResponseTimeSentSumMultiMD
		,@SearchResponseTimeSentMaxSingle
		,@SearchResponseTimeSentMaxSingleMD
		,@SearchResponseTimeSentMaxMulti
		,@SearchResponseTimeSentMaxMultiMD
		,@ErbMsgResponseTimeProcessedSum
		,@ErbMsgResponseTimeProcessedMax
		,@ErbMsgResponseTimeSentSum
		,@ErbMsgResponseTimeSentMax
		,@WebMsgResponseTimeProcessedSum
		,@WebMsgResponseTimeProcessedMax
		,@WebMsgResponseTimeSentSum
		,@WebMsgResponseTimeSentMax
		,@ErrorSeqNumMismatch_CacheUpdate
		,@ErrorSeqNumMismatch_CacheAddDay
		,@ContentionCount_Cache
		,@ContentionCount_AuthLog
		,@ContentionCount_NetAddr
		,@ContentionCount_Stats
		,@ContentionCount_InternalIP
		,@ContentionCount_ToBeAddedRID
		,@ContentionCount_WLogMap
		,@ContentionCount_CacheTuning
		,@ContentionCount_AuditFailure
		,@ContentionCount_SettingsManager
		,@ContentionCount_ReqBuf
		,@ContentionCount_SockList
		,@ThreadCountRH
		,@MaxRHThreadsInUse
		,@ThreadCountSW
		,@MaxSWThreadsInUse
		,@ThreadCountOutbound
		,@MaxOutboundThreadsInUse
		,@MsgCountDebugRequest
		,@MsgCountEventAudit
		,@OutboundResponseTimeSentSum
		,@OutboundResponseTimeSentMax
		,@EmailCount_RogueERB		
		,@EmailCount_DBError		
		,@EmailCount_CacheFull	
		,@EmailCount_InternalError
		,@EmailCount_Startup
		,@EmailCount_ProtocolError
		,@ErrorEmptyCacheRefresh
		,@MaxOutboundQueueLength
		,@MaxRHQueueLength
		,@ThreadCountWebRH
		,@MaxWebRHThreadsInUse
		,@MaxWebRHQueueLength
		,@SearchCountMiss_NotOwned
		,@RestsOwned
		,@MsgCountNotOwned
		,@RestContactUpdateCount
		,@OutboundFailTotal							
		,@OutboundFailConnRefused					
		,@OutboundFailConnReset						
		,@OutboundFailConnAborted	
		,@MsgCountSetval							
		,@MsgCountReloadconfig										
		,@QueueCountAdd			
		,@QueueCountDelete			
		,@QueueCountInfo			
		,@RestsReachable
	)
GO

GRANT EXECUTE ON [csUpdateStats] TO ExecuteOnlyRole
GO
