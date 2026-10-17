"
I am the singleton that owns the result files of crit review Finishes, written as JSON files by the finish hooks that AgenticBrowser puts in .crit.config.json.

Responsibility:
- I own where result files live and how they are named: one file per topic and finish kind (unresolved or approved) under crit-results/ in the AgenticBrowser root directory.
- I prepare a topic's finish hooks, which save crit's finish payload into my files, merge them into existing hooks unless the user defined a finish hook there, and ensure them in its .crit.config.json.
- I delete a topic's result files.
- I recognize finish hook commands that write into my directory, so a hook from an earlier AgenticBrowser root is still treated as ours.
- I list the result files in my directory as AbCritReviewFinishResult instances, reading the topicId and kind from each file name.

Collaborators:
- AbSettings: I read #defaultAgenticBrowserRootDirectory.
- AbCritReviewFinishResult: I create one per result file.
- AbCritDaemon: It asks me to ensure its topic's finish hooks before spawning, and to delete its topic's stale files when a review starts. I read its #topic and #configFile.
- AbCritConfigFile: I ask it to ensure a topic's finish hooks; it passes me its hooks and writes back the ones I answer.
- AbTopicManager: It asks me for the pending results.

Public API and Key Messages:
- AbCritReviewFinishResultsManager class>>default - The global singleton.
- #directory - The crit-results directory.
- #kinds - #unresolved and #approved, matching crit's on_finish_unresolved and on_finish_approved hooks.
- #fileForTopicId:kind: - The result file for one topic and kind.
- #filesForTopicId: - The result files for one topic, one per kind.
- #prepareFinishHooksFor: - Hook name -> command Dictionary for a topic: each on_finish_<kind> hook saves the payload with cat into the topic's file for that kind.
- #hooksWithFinishHooksFor:from: - A copy of the given hooks with a topic's finish hooks set; nil when one of those hook names already holds a user-defined command.
- #ensureFinishHooksFor: - Create my directory and ensure the topic's finish hooks in the daemon's .crit.config.json; answer false when the file already defines its own on_finish hook.
- #deleteFilesFor: - Delete a topic's result files.
- #isSystemDefinedHookCommand: - Whether a hook command is one AgenticBrowser wrote, recognized by writing into my directory.
- #results - One AbCritReviewFinishResult per result file in the directory; empty when it does not exist.

Internal Representation:
- directory - Overrides the crit-results directory (tests use an in-memory one); nil means under the AgenticBrowser root directory.
- default (class inst var) - The global singleton instance.
"
Class {
	#name : 'AbCritReviewFinishResultsManager',
	#superclass : 'Object',
	#instVars : [
		'directory'
	],
	#classInstVars : [
		'default'
	],
	#category : 'AgenticBrowser-Core',
	#package : 'AgenticBrowser-Core'
}

{ #category : 'class initialization' }
AbCritReviewFinishResultsManager class >> initialize [

	default := nil
]

{ #category : 'instance creation' }
AbCritReviewFinishResultsManager class >> default [

	^ default ifNil: [ default := self new ]
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> directoryName [

	^ 'crit-results'
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> directory [

	^ directory ifNil: [ AbSettings defaultAgenticBrowserRootDirectory / self directoryName ]
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> directory: aDirectoryReference [

	directory := aDirectoryReference
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> kinds [

	^ #( #unresolved #approved )
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> fileNameSuffixFor: aKindSymbol [

	^ '-' , aKindSymbol , '.json'
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> fileForTopicId: aTopicIdString kind: aKindSymbol [

	^ self directory / (aTopicIdString , (self fileNameSuffixFor: aKindSymbol))
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> filesForTopicId: aTopicIdString [

	^ self kinds collect: [ :kind | self fileForTopicId: aTopicIdString kind: kind ]
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> prepareFinishHooksFor: aTopic [

	^ self kinds
		  inject: Dictionary new
		  into: [ :hooks :kind |
			  hooks
				  at: 'on_finish_' , kind
				  put: 'inline:cat > ' , (self fileForTopicId: aTopic topicId kind: kind) fullName shellQuoted;
				  yourself ]
]

{ #category : 'operations' }
AbCritReviewFinishResultsManager >> ensureFinishHooksFor: anAbCritDaemon [

	self directory ensureCreateDirectory.
	^ anAbCritDaemon configFile ensureFinishHooksFor: anAbCritDaemon topic
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> hooksWithFinishHooksFor: aTopic from: aHookDictionary [

	| finishHooks |
	finishHooks := self prepareFinishHooksFor: aTopic.
	(self hasUserDefinedHookNamedAnyOf: finishHooks keys in: aHookDictionary) ifTrue: [ ^ nil ].
	^ aHookDictionary copy
		  addAll: finishHooks;
		  yourself
]

{ #category : 'private' }
AbCritReviewFinishResultsManager >> hasUserDefinedHookNamedAnyOf: aHookNameCollection in: aHookDictionary [

	^ aHookNameCollection anySatisfy: [ :name |
		  (aHookDictionary at: name ifAbsent: [ nil ])
			  ifNil: [ false ]
			  ifNotNil: [ :command | (self isSystemDefinedHookCommand: command) not ] ]
]

{ #category : 'operations' }
AbCritReviewFinishResultsManager >> deleteFilesFor: aTopic [

	(self filesForTopicId: aTopic topicId) do: [ :file | file ensureDelete ]
]

{ #category : 'testing' }
AbCritReviewFinishResultsManager >> isSystemDefinedHookCommand: aCommandString [

	^ aCommandString isString and: [
		  aCommandString includesSubstring: '/' , self directoryName , '/' ]
]

{ #category : 'accessing' }
AbCritReviewFinishResultsManager >> results [

	| suffix |
	self directory exists ifFalse: [ ^ #(  ) ].
	^ self kinds flatCollect: [ :kind |
		  suffix := self fileNameSuffixFor: kind.
		  (self directory files select: [ :file | file basename endsWith: suffix ]) collect: [ :file |
			  AbCritReviewFinishResult
				  file: file
				  topicId: (file basename allButLast: suffix size)
				  kind: kind ] ]
]
