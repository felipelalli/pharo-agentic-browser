"
I am the result of one crit review Finish, written as a JSON file by the finish hooks that AgenticBrowser puts in .crit.config.json.

Responsibility:
- On the class side I own where result files live and how they are named: one file per topic and finish kind (unresolved or approved) under crit-results/ in the AgenticBrowser root directory.
- I recognize finish hook commands that write into my directory, so a hook from an earlier AgenticBrowser root is still treated as ours.
- As an instance I wrap one result file: I read the topicId and kind from its name, parse the hook payload, and build the prompt that hands crit's review loop to the agent.

Collaborators:
- AbSettings: I read #defaultAgenticBrowserRootDirectory.
- AbCritDaemon: It builds the finish hook commands from my file locations and deletes a topic's stale files when a review starts.
- AbCritConfigFile: It asks me whether an existing hook command is ours.
- AbTopicManager: It lists my pending results, sends my prompt to the topic, and deletes me.

Public API and Key Messages:
- AbCritFinishResult class>>directory - The crit-results directory.
- AbCritFinishResult class>>kinds - #unresolved and #approved, matching crit's on_finish_unresolved and on_finish_approved hooks.
- AbCritFinishResult class>>fileForTopicId:kind: - The result file for one topic and kind.
- AbCritFinishResult class>>filesForTopicId: - The result files for one topic, one per kind.
- AbCritFinishResult class>>isHookCommand: - Whether a hook command writes into my directory.
- AbCritFinishResult class>>pendingResults / pendingResultsIn: - One instance per result file in the directory; empty when it does not exist.
- AbCritFinishResult class>>file: - Instance for one result file.
- #topicId / #kind / #isApproved - Read from the file name, without reading the file.
- #payload - The hook's stdin JSON as a Dictionary. Signals an error when the file is not complete JSON (for example while the hook is still writing it).
- #prompt - English prompt in the shape of crit's own: unresolved count, the unresolved comments with their replies, the crit comment --reply-to instruction, and the next round command (crit --session <id>).
- #delete - Delete the result file.

Internal Representation:
- file - FileReference of the result file.
- payload - Parsed JSON, cached after the first successful read.
"
Class {
	#name : 'AbCritFinishResult',
	#superclass : 'Object',
	#instVars : [
		'file',
		'payload'
	],
	#category : 'AgenticBrowser-Core',
	#package : 'AgenticBrowser-Core'
}

{ #category : 'accessing' }
AbCritFinishResult class >> directoryName [

	^ 'crit-results'
]

{ #category : 'accessing' }
AbCritFinishResult class >> directory [

	^ AbSettings defaultAgenticBrowserRootDirectory / self directoryName
]

{ #category : 'accessing' }
AbCritFinishResult class >> kinds [

	^ #( #unresolved #approved )
]

{ #category : 'instance creation' }
AbCritFinishResult class >> file: aFileReference [

	^ self new
		  file: aFileReference;
		  yourself
]

{ #category : 'accessing' }
AbCritFinishResult class >> fileNameSuffixFor: aKindSymbol [

	^ '-' , aKindSymbol , '.json'
]

{ #category : 'accessing' }
AbCritFinishResult class >> fileForTopicId: aTopicIdString kind: aKindSymbol [

	^ self directory / (aTopicIdString , (self fileNameSuffixFor: aKindSymbol))
]

{ #category : 'accessing' }
AbCritFinishResult class >> kindOf: aFileReference [

	^ self kinds
		  detect: [ :kind | aFileReference basename endsWith: (self fileNameSuffixFor: kind) ]
		  ifNone: [ nil ]
]

{ #category : 'testing' }
AbCritFinishResult class >> isResultFile: aFileReference [

	^ (self kindOf: aFileReference) notNil
]

{ #category : 'accessing' }
AbCritFinishResult class >> pendingResults [

	^ self pendingResultsIn: self directory
]

{ #category : 'accessing' }
AbCritFinishResult class >> pendingResultsIn: aDirectoryReference [

	aDirectoryReference exists ifFalse: [ ^ #(  ) ].
	^ (aDirectoryReference files select: [ :each | self isResultFile: each ])
		  collect: [ :each | self file: each ]
]

{ #category : 'accessing' }
AbCritFinishResult class >> filesForTopicId: aTopicIdString [

	^ self kinds collect: [ :kind | self fileForTopicId: aTopicIdString kind: kind ]
]

{ #category : 'testing' }
AbCritFinishResult class >> isHookCommand: aCommandString [

	^ aCommandString isString and: [
		  aCommandString includesSubstring: '/' , self directoryName , '/' ]
]

{ #category : 'accessing' }
AbCritFinishResult >> file [

	^ file
]

{ #category : 'accessing' }
AbCritFinishResult >> file: aFileReference [

	file := aFileReference
]

{ #category : 'accessing' }
AbCritFinishResult >> kind [

	^ self class kindOf: self file
]

{ #category : 'accessing' }
AbCritFinishResult >> topicId [

	^ self file basename allButLast: (self class fileNameSuffixFor: self kind) size
]

{ #category : 'testing' }
AbCritFinishResult >> isApproved [

	^ self kind = #approved
]

{ #category : 'accessing' }
AbCritFinishResult >> payload [

	^ payload ifNil: [ payload := STONJSON fromString: self file contents ]
]

{ #category : 'accessing' }
AbCritFinishResult >> prompt [

	^ String lf join: {
			  self summarySentence.
			  ''.
			  STONJSON toString: (self payload at: 'comments_unresolved_json').
			  ''.
			  self replyInstruction.
			  ''.
			  'When you''re done, run:'.
			  ''.
			  '  ' , (self payload at: 'next_round_cmd') }
]

{ #category : 'private' }
AbCritFinishResult >> summarySentence [

	| count |
	count := self payload at: 'unresolved_count'.
	^ 'The review finished with {1} unresolved {2}.' format: {
			  count.
			  (count = 1
				   ifTrue: [ 'comment' ]
				   ifFalse: [ 'comments' ]) }
]

{ #category : 'private' }
AbCritFinishResult >> replyInstruction [

	^ 'Address each comment. For each one, reply explaining what you did using `crit comment --reply-to <comment-id> --author <your-name> "<explanation>"`.'
]

{ #category : 'operations' }
AbCritFinishResult >> delete [

	self file ensureDelete
]
