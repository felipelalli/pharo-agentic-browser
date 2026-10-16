Class {
	#name : 'AbCritFinishResultTest',
	#superclass : 'AbTestCase',
	#category : 'AgenticBrowser-Tests',
	#package : 'AgenticBrowser-Tests'
}

{ #category : 'tests' }
AbCritFinishResultTest >> testDirectoryIsUnderAgenticBrowserRoot [

	self
		assert: AbCritFinishResult directory
		equals: AbSettings defaultAgenticBrowserRootDirectory / 'crit-results'
]

{ #category : 'tests' }
AbCritFinishResultTest >> testFileForTopicIdKindNamesTopicAndKind [

	self
		assert: (AbCritFinishResult fileForTopicId: 'abc' kind: #unresolved)
		equals: AbCritFinishResult directory / 'abc-unresolved.json'.
	self
		assert: (AbCritFinishResult fileForTopicId: 'abc' kind: #approved)
		equals: AbCritFinishResult directory / 'abc-approved.json'
]

{ #category : 'tests' }
AbCritFinishResultTest >> testFilesForTopicIdCoverEveryKind [

	self
		assert: (AbCritFinishResult filesForTopicId: 'abc') asArray
		equals: {
				(AbCritFinishResult fileForTopicId: 'abc' kind: #unresolved).
				(AbCritFinishResult fileForTopicId: 'abc' kind: #approved) }
]

{ #category : 'tests' }
AbCritFinishResultTest >> testIsHookCommandRecognizesCommandsWritingIntoResultDirectory [

	self assert: (AbCritFinishResult isHookCommand: 'inline:cat > ''/old/root/agentic-browser/crit-results/abc-unresolved.json''').
	self deny: (AbCritFinishResult isHookCommand: 'inline:echo done >> ~/finishes.log').
	self deny: (AbCritFinishResult isHookCommand: nil)
]

{ #category : 'test data' }
AbCritFinishResultTest >> round1UnresolvedPayload [
	"Recorded from crit v0.21.0 on 2026-10-16."

	^ '{"approved":false,"comments_all_cmd":"crit comments --json --all /home/mumez/.crit/reviews/47d359cc3b15","comments_cmd":"crit comments --json /home/mumez/.crit/reviews/47d359cc3b15","comments_json":[{"scope":"line","path":"a.txt","id":"c_db62fc","start_line":2,"end_line":2,"body":"round1: why changed?","anchor":"line2 changed","author":"Reviewer","created_at":"2026-10-16T08:03:51Z","updated_at":"2026-10-16T08:03:51Z"}],"comments_unresolved_json":[{"scope":"line","path":"a.txt","id":"c_db62fc","start_line":2,"end_line":2,"body":"round1: why changed?","anchor":"line2 changed","author":"Reviewer","created_at":"2026-10-16T08:03:51Z","updated_at":"2026-10-16T08:03:51Z"}],"files_with_comments":["a.txt"],"internal_session_mode":"git","mode":"diff","next_round_cmd":"crit --session 47d359cc3b15","plan_slug":"","review_path":"/home/mumez/.crit/reviews/47d359cc3b15","session_key":"47d359cc3b15","session_stats":{"comments_submitted":0,"duration_seconds":71,"files_reviewed":1},"total_count":1,"unresolved_count":1}'
]

{ #category : 'test data' }
AbCritFinishResultTest >> round2UnresolvedPayload [
	"Recorded from crit v0.21.0 on 2026-10-16."

	^ '{"approved":false,"comments_all_cmd":"crit comments --json --all /home/mumez/.crit/reviews/47d359cc3b15","comments_cmd":"crit comments --json /home/mumez/.crit/reviews/47d359cc3b15","comments_json":[{"scope":"line","path":"a.txt","id":"c_db62fc","start_line":2,"end_line":2,"body":"round1: why changed?","anchor":"line2 changed","author":"Reviewer","created_at":"2026-10-16T08:03:51Z","updated_at":"2026-10-16T08:03:51Z","replies":[{"id":"rp_f87f3a","body":"Changed line2 for the test.","author":"agent","created_at":"2026-10-16T08:05:33Z","review_round":1}]},{"scope":"line","path":"a.txt","id":"c_adc9df","start_line":4,"end_line":4,"body":"round2: why line4?","anchor":"line4","author":"Reviewer","created_at":"2026-10-16T08:05:34Z","updated_at":"2026-10-16T08:05:34Z"}],"comments_unresolved_json":[{"scope":"line","path":"a.txt","id":"c_db62fc","start_line":2,"end_line":2,"body":"round1: why changed?","anchor":"line2 changed","author":"Reviewer","created_at":"2026-10-16T08:03:51Z","updated_at":"2026-10-16T08:03:51Z","replies":[{"id":"rp_f87f3a","body":"Changed line2 for the test.","author":"agent","created_at":"2026-10-16T08:05:33Z","review_round":1}]},{"scope":"line","path":"a.txt","id":"c_adc9df","start_line":4,"end_line":4,"body":"round2: why line4?","anchor":"line4","author":"Reviewer","created_at":"2026-10-16T08:05:34Z","updated_at":"2026-10-16T08:05:34Z"}],"files_with_comments":["a.txt"],"internal_session_mode":"git","mode":"diff","next_round_cmd":"crit --session 47d359cc3b15","plan_slug":"","review_path":"/home/mumez/.crit/reviews/47d359cc3b15","session_key":"47d359cc3b15","session_stats":{"comments_submitted":0,"duration_seconds":117,"files_reviewed":1},"total_count":2,"unresolved_count":2}'
]

{ #category : 'test data' }
AbCritFinishResultTest >> approvedPayload [
	"Recorded from crit v0.21.0 on 2026-10-16."

	^ '{"approved":true,"comments_all_cmd":"crit comments --json --all /home/mumez/.crit/reviews/47d359cc3b15","comments_cmd":"crit comments --json /home/mumez/.crit/reviews/47d359cc3b15","comments_json":[{"scope":"line","path":"a.txt","id":"c_db62fc","start_line":2,"end_line":2,"body":"round1: why changed?","anchor":"line2 changed","author":"Reviewer","created_at":"2026-10-16T08:03:51Z","updated_at":"2026-10-16T08:36:25Z","resolved":true,"resolved_round":3,"carried_forward":true,"replies":[{"id":"rp_f87f3a","body":"Changed line2 for the test.","author":"agent","created_at":"2026-10-16T08:05:33Z","review_round":1}]},{"scope":"line","path":"a.txt","id":"c_e4a4f2","start_line":3,"end_line":3,"body":"test","anchor":"line3","author":"Masashi Umezawa","created_at":"2026-10-16T08:13:36Z","updated_at":"2026-10-16T08:36:27Z","resolved":true,"resolved_round":3,"carried_forward":true,"review_round":2},{"scope":"line","path":"a.txt","id":"c_adc9df","start_line":4,"end_line":4,"body":"round2: why line4?","anchor":"line4","author":"Reviewer","created_at":"2026-10-16T08:05:34Z","updated_at":"2026-10-16T08:36:28Z","resolved":true,"resolved_round":3,"carried_forward":true}],"comments_unresolved_json":[],"files_with_comments":null,"internal_session_mode":"git","mode":"diff","next_round_cmd":"crit --session 47d359cc3b15","plan_slug":"","review_path":"/home/mumez/.crit/reviews/47d359cc3b15","session_key":"47d359cc3b15","session_stats":{"comments_submitted":1,"duration_seconds":1817,"files_reviewed":1},"total_count":3,"unresolved_count":0}'
]

{ #category : 'private' }
AbCritFinishResultTest >> resultFileNamed: aBasename containing: aString [

	| file |
	file := FileSystem memory root / aBasename.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].
	^ AbCritFinishResult file: file
]

{ #category : 'tests' }
AbCritFinishResultTest >> testTopicIdAndKindAreReadFromFileName [

	| result |
	result := self resultFileNamed: 'a1-b2-c3-unresolved.json' containing: self round1UnresolvedPayload.
	self assert: result topicId equals: 'a1-b2-c3'.
	self assert: result kind equals: #unresolved.
	self deny: result isApproved.
	self assert: (self resultFileNamed: 'a1-approved.json' containing: self approvedPayload) isApproved
]

{ #category : 'tests' }
AbCritFinishResultTest >> testFileWithUnknownKindIsNotAResultFile [

	self deny: (AbCritFinishResult isResultFile: FileSystem memory root / 'a1-other.json').
	self deny: (AbCritFinishResult isResultFile: FileSystem memory root / 'a1-unresolved.json.tmp').
	self assert: (AbCritFinishResult isResultFile: FileSystem memory root / 'a1-approved.json')
]

{ #category : 'tests' }
AbCritFinishResultTest >> testPayloadIsParsedJson [

	| payload |
	payload := (self resultFileNamed: 't-unresolved.json' containing: self round1UnresolvedPayload) payload.
	self assert: (payload at: 'unresolved_count') equals: 1.
	self assert: (payload at: 'next_round_cmd') equals: 'crit --session 47d359cc3b15'
]

{ #category : 'tests' }
AbCritFinishResultTest >> testPayloadOfBrokenJsonSignalsError [

	self
		should: [ (self resultFileNamed: 't-unresolved.json' containing: '{"approved": fal') payload ]
		raise: Error
]

{ #category : 'tests' }
AbCritFinishResultTest >> testPromptListsUnresolvedCommentsAndHandsOverTheLoop [

	| prompt |
	prompt := (self resultFileNamed: 't-unresolved.json' containing: self round1UnresolvedPayload) prompt.
	self assert: (prompt beginsWith: 'The review finished with 1 unresolved comment.').
	self assert: (prompt includesSubstring: 'c_db62fc').
	self assert: (prompt includesSubstring: 'round1: why changed?').
	self assert: (prompt includesSubstring: '`crit comment --reply-to <comment-id> --author <your-name> "<explanation>"`').
	self assert: (prompt endsWith: 'When you''re done, run:' , String lf , String lf , '  crit --session 47d359cc3b15')
]

{ #category : 'tests' }
AbCritFinishResultTest >> testPromptKeepsEarlierRepliesAndCountsPlural [

	| prompt |
	prompt := (self resultFileNamed: 't-unresolved.json' containing: self round2UnresolvedPayload) prompt.
	self assert: (prompt beginsWith: 'The review finished with 2 unresolved comments.').
	self assert: (prompt includesSubstring: 'c_adc9df').
	self assert: (prompt includesSubstring: 'Changed line2 for the test.')
]

{ #category : 'tests' }
AbCritFinishResultTest >> testPendingResultsListsOnlyResultFiles [

	| dir results |
	dir := FileSystem memory root / 'crit-results'.
	dir ensureCreateDirectory.
	(dir / 't1-unresolved.json') writeStreamDo: [ :stream | stream nextPutAll: '{}' ].
	(dir / 't2-approved.json') writeStreamDo: [ :stream | stream nextPutAll: '{}' ].
	(dir / 'notes.txt') writeStreamDo: [ :stream | stream nextPutAll: 'x' ].
	results := AbCritFinishResult pendingResultsIn: dir.
	self assert: (results collect: [ :each | each topicId ]) asSet equals: #( 't1' 't2' ) asSet.
	self assert: (AbCritFinishResult pendingResultsIn: FileSystem memory root / 'missing') isEmpty
]
