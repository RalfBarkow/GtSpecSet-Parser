Class {
	#name : #GtSpecSetMarkdownParserAdapter,
	#superclass : #Object,
	#category : #'GtSpecSet-Parser'
}

{ #category : #accessing }
GtSpecSetMarkdownParserAdapter class >> exampleMasterText [
	<gtExample>
	^ String
		streamContents: [ :s | 
			s
				nextPutAll: '# SPEC''; cr; nextPutAll: ''Spec body''; cr; cr;
		s nextPutAll: ''# IMPLEMENTATION_PLAN''; cr; nextPutAll: ''Plan body''; cr; cr;
		s nextPutAll: ''# RESEARCH''; cr; nextPutAll: ''Research body''; cr; cr;
		s nextPutAll: ''# WORKLOG''; cr; nextPutAll: ''Worklog body'' ]' ]
]

{ #category : #examples }
GtSpecSetMarkdownParserAdapter class >> exampleParse [
	<gtExample>
	| dir file |
	dir := FileSystem memory root.
	file := (dir / 'MASTER.md') ensureCreateFile.
	file writeStreamDo: [ :ws | ws nextPutAll: self exampleMasterText ].
	^ self parse: file
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> headingNames [
	^ #('SPEC' 'IMPLEMENTATION_PLAN' 'RESEARCH' 'WORKLOG')
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> headingRegex [
	^ '(?m)^#\\s+(SPEC|IMPLEMENTATION_PLAN|RESEARCH|WORKLOG)\\s*$' asRegex
]

{ #category : #registry }
GtSpecSetMarkdownParserAdapter class >> install [
	| registryClass registry |
	registryClass := Smalltalk at: #GtInputParserRegistry ifAbsent: [ ^ self ].
	registry := (registryClass respondsTo: #default)
			ifTrue: [ registryClass default ]
			ifFalse: [ nil ].
	registry ifNil: [ ^ self ].
	(registry respondsTo: #registerParserClass:)
		ifTrue: [ registry registerParserClass: self ]
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> matches: aContextOrRef [
	| ref path text |
	ref := (aContextOrRef respondsTo: #reference)
			ifTrue: [ aContextOrRef reference ]
			ifFalse: [ aContextOrRef ].
	(ref isNil or: [ ref exists not ]) ifTrue: [ ^ false ].
	path := ref fullName asString.
	(#('.md' '.markdown') anySatisfy: [ :ext | path endsWith: ext ])
		ifFalse: [ ^ false ].
	[ text := ref contents ] on: Error do: [ ^ false ].
	^ (self headingRegex matchesIn: text) notEmpty
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> parse: aContextOrRef [
	| ref text parts order currentKey |
	ref := (aContextOrRef respondsTo: #reference)
			ifTrue: [ aContextOrRef reference ]
			ifFalse: [ aContextOrRef ].
	text := ref contents ifNil: [ '' ].
	order := self headingNames collect: [ :s | s asSymbol ].
	parts := Dictionary
			newFrom: {#SPEC -> ''.
					#IMPLEMENTATION_PLAN -> ''.
					#RESEARCH -> ''.
					#WORKLOG -> ''}.

	currentKey := nil.
	text
		linesDo: [ :line | 
			(line beginsWith: '# ')
				ifTrue: [ | sectionTitle |
					sectionTitle := (line allButFirst: 2) trimBoth.
					currentKey := (self headingNames
							detect: [ :h | h = sectionTitle ]
							ifNone: [ nil ]) ifNotNil: [ :h | h asSymbol ] ]
				ifFalse: [ currentKey
						ifNotNil: [ parts at: currentKey put: (parts at: currentKey) , line , String lf ] ] ].

	self headingNames
		do: [ :h | 
			(parts at: h asSymbol)
				ifEmpty: [ parts at: h asSymbol put: (self skeletonFor: h) ] ].

	^ GtSpecSetSplitResult new
		source: ref;
		parts: parts;
		order: order;
		yourself
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> priority [
	^ 2
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> skeletonFor: h [ 
]
