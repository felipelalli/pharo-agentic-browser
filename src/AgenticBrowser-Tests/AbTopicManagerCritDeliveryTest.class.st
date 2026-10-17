Class {
	#name : 'AbTopicManagerCritDeliveryTest',
	#superclass : 'AbTestCase',
	#instVars : [
		'manager',
		'sentPrompts',
		'resultTopicIds'
	],
	#category : 'AgenticBrowser-Tests',
	#package : 'AgenticBrowser-Tests'
}

{ #category : 'running' }
AbTopicManagerCritDeliveryTest >> setUp [

	super setUp.
	AbSettings initialize.
	AbSettings default useCrit: true.
	manager := AbTopicManager forTest.
	sentPrompts := OrderedCollection new.
	resultTopicIds := OrderedCollection new
]

{ #category : 'running' }
AbTopicManagerCritDeliveryTest >> tearDown [

	resultTopicIds do: [ :topicId |
		(AbCritReviewFinishResultsManager default filesForTopicId: topicId) do: [ :file | file ensureDelete ] ].
	AbSettings initialize.
	super tearDown
]

{ #category : 'private' }
AbTopicManagerCritDeliveryTest >> unresolvedPayload [

	^ '{"unresolved_count":1,"comments_unresolved_json":[{"id":"c_1","body":"please fix"}],"next_round_cmd":"crit --session s1"}'
]

{ #category : 'private' }
AbTopicManagerCritDeliveryTest >> writeResult: aKindSymbol containing: aString forTopicId: aTopicId [

	| file |
	resultTopicIds add: aTopicId.
	file := AbCritReviewFinishResultsManager default fileForTopicId: aTopicId kind: aKindSymbol.
	file parent ensureCreateDirectory.
	file writeStreamDo: [ :stream | stream nextPutAll: aString ].
	^ file
]

{ #category : 'private' }
AbTopicManagerCritDeliveryTest >> writeUnresolvedFor: aTopic [

	^ self writeResult: #unresolved containing: self unresolvedPayload forTopicId: aTopic topicId
]

{ #category : 'private' }
AbTopicManagerCritDeliveryTest >> topicAwaitingFirstFinish: aBoolean events: anEventCollection [

	| topic |
	topic := AbMockTopicNoPromptSend new.
	topic onSendBlock: [ :text :resources | sentPrompts add: text ].
	anEventCollection do: [ :event | topic stateMachine handleEvent: event ].
	topic critDaemon awaitingFirstFinish: aBoolean.
	manager addTopic: topic.
	^ topic
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testDoesNothingWhenUseCritIsFalse [

	| topic file |
	topic := self topicAwaitingFirstFinish: true events: #( #promptSent #turnEnded ).
	file := self writeUnresolvedFor: topic.
	AbSettings default useCrit: false.
	manager deliverCritFinishResults.
	self assert: sentPrompts isEmpty.
	self assert: file exists.
	self assert: topic critDaemon isAwaitingFirstFinish
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testSendsPromptToIdleAwaitingTopics [

	| endTurnTopic initialTopic files |
	endTurnTopic := self topicAwaitingFirstFinish: true events: #( #promptSent #turnEnded ).
	initialTopic := self topicAwaitingFirstFinish: true events: #(  ).
	files := { endTurnTopic. initialTopic } collect: [ :each | self writeUnresolvedFor: each ].
	manager deliverCritFinishResults.
	self assert: sentPrompts size equals: 2.
	self assert: (sentPrompts allSatisfy: [ :each | each beginsWith: 'The review finished with 1 unresolved comment.' ]).
	self assert: (files noneSatisfy: [ :each | each exists ]).
	self deny: endTurnTopic critDaemon isAwaitingFirstFinish.
	self deny: initialTopic critDaemon isAwaitingFirstFinish
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testKeepsResultWhileTopicIsBusy [

	| workingTopic waitingTopic files |
	workingTopic := self topicAwaitingFirstFinish: true events: #( #promptSent ).
	waitingTopic := self topicAwaitingFirstFinish: true events: #( #permissionRequested ).
	files := { workingTopic. waitingTopic } collect: [ :each | self writeUnresolvedFor: each ].
	manager deliverCritFinishResults.
	self assert: sentPrompts isEmpty.
	self assert: (files allSatisfy: [ :each | each exists ]).
	self assert: workingTopic critDaemon isAwaitingFirstFinish.
	self assert: waitingTopic critDaemon isAwaitingFirstFinish
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testReportsFirstApprovalInAnyStatusWithoutPrompt [

	| topic file |
	topic := self topicAwaitingFirstFinish: true events: #( #promptSent ).
	file := self writeResult: #approved containing: '{"approved":true}' forTopicId: topic topicId.
	manager deliverCritFinishResults.
	self assert: sentPrompts isEmpty.
	self assert: topic messages last text equals: 'Crit review approved.'.
	self deny: file exists.
	self deny: topic critDaemon isAwaitingFirstFinish
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testDiscardsResultOfTopicNotAwaitingFirstFinish [

	| topic file |
	topic := self topicAwaitingFirstFinish: false events: #( #promptSent #turnEnded ).
	file := self writeUnresolvedFor: topic.
	manager deliverCritFinishResults.
	self assert: sentPrompts isEmpty.
	self deny: file exists
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testDiscardsResultOfUnknownTopic [

	| file |
	file := self
		        writeResult: #unresolved
		        containing: self unresolvedPayload
		        forTopicId: 'ab-test-unknown-' , UUID new asString36.
	manager deliverCritFinishResults.
	self deny: file exists
]

{ #category : 'tests' }
AbTopicManagerCritDeliveryTest >> testKeepsUnreadableResultForRetryWithoutStoppingOthers [

	| brokenTopic goodTopic brokenFile |
	brokenTopic := self topicAwaitingFirstFinish: true events: #( #promptSent #turnEnded ).
	goodTopic := self topicAwaitingFirstFinish: true events: #( #promptSent #turnEnded ).
	brokenFile := self writeResult: #unresolved containing: '{"unresolved_count":' forTopicId: brokenTopic topicId.
	self writeUnresolvedFor: goodTopic.
	manager deliverCritFinishResults.
	self assert: brokenFile exists.
	self assert: brokenTopic critDaemon isAwaitingFirstFinish.
	self assert: sentPrompts size equals: 1.
	self deny: goodTopic critDaemon isAwaitingFirstFinish
]
