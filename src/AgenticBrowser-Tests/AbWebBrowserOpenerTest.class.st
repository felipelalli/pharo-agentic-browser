Class {
	#name : 'AbWebBrowserOpenerTest',
	#superclass : 'AbTestCase',
	#category : 'AgenticBrowser-Tests',
	#package : 'AgenticBrowser-Tests'
}

{ #category : 'tests' }
AbWebBrowserOpenerTest >> testLinuxOpenCommandForUnsetsLdLibraryPath [

	self
		assert: (AbWebBrowserOpener linuxOpenCommandFor: 'https://example.com/a?b=1&c=2')
		equals: 'env -u LD_LIBRARY_PATH xdg-open ''https://example.com/a?b=1&c=2'' &'
]

{ #category : 'tests' }
AbWebBrowserOpenerTest >> testLinuxOpenCommandForEscapesSingleQuotes [

	self
		assert: (AbWebBrowserOpener linuxOpenCommandFor: 'https://example.com/it''s')
		equals: 'env -u LD_LIBRARY_PATH xdg-open ''https://example.com/it''\''''s'' &'
]
