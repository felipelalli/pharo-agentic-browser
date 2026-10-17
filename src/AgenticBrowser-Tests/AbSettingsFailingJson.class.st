"
I am an AbSettings whose JSON conversion fails on purpose.
Tests use me to raise an Error from inside #saveFullTo:'s write block.
"
Class {
	#name : 'AbSettingsFailingJson',
	#superclass : 'AbSettings',
	#category : 'AgenticBrowser-Tests',
	#package : 'AgenticBrowser-Tests'
}

{ #category : 'converting' }
AbSettingsFailingJson >> asFullJsonDictionary [

	self error: 'save failed'
]
