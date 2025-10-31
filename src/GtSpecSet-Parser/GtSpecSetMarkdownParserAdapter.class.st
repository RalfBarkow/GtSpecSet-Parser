Class {
	#name : #GtSpecSetMarkdownParserAdapter,
	#superclass : #Object,
	#category : #'GtSpecSet-Parser'
}

{ #category : #registry }
GtSpecSetMarkdownParserAdapter class >> ensureInstalled [
	"Idempotently register this parser with all known registries/sets."

	| ctx reg parsers |
	(Smalltalk includesKey: #GtInputContext)
		ifTrue: [ ctx := Smalltalk at: #GtInputContext.
			(ctx respondsTo: #current)
				ifTrue: [ (ctx current respondsTo: #registerParser:)
						ifTrue: [ ctx current registerParser: self ] ] ].
	(Smalltalk includesKey: #GtInputParserRegistry)
		ifTrue: [ reg := Smalltalk at: #GtInputParserRegistry.
			(reg respondsTo: #default)
				ifTrue: [ | d |
					d := reg default.
					(d respondsTo: #add:) ifTrue: [ d add: self ] ] ].
	(Smalltalk includesKey: #GtInputParsers)
		ifTrue: [ parsers := Smalltalk at: #GtInputParsers.
			(parsers respondsTo: #parsers)
				ifTrue: [ | coll |
					coll := parsers perform: #parsers.
					(coll respondsTo: #add:) ifTrue: [ coll add: self ] ] ]
]

{ #category : #'examples class' }
GtSpecSetMarkdownParserAdapter class >> exampleMasterText [
	<gtExample>
	^ '# SPEC
Title
'
]

{ #category : #'examples class' }
GtSpecSetMarkdownParserAdapter class >> exampleParse [
	<gtExample>
	| mem master res |
	mem := FileSystem memory.
	master := mem / 'MASTER.md'.
	master ensureCreateFile.
	master writeStreamDo: [ :ws | ws nextPutAll: '# SPEC' , String cr , 'Hello' ].
	self assert: (self matches: master).
	res := self parse: master.
	self assert: (res respondsTo: #writeFilesIn:).
	^ res
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> firstNonEmptyLineFrom: aFileReference ifNone: noneBlock [
	"Read first non-empty, BOM-trimmed line."

	| line |
	aFileReference
		readStreamDo: [ :strm | 
			[ strm atEnd ]
				whileFalse: [ line := strm nextLine ifNil: [ '' ].
					line := line withBlanksCondensed.
					(line notEmpty and: [ line first ~= (Character value: 16rFEFF) ])
						ifTrue: [ ^ line ] ] ].
	^ noneBlock value
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> headingNames [
	^ #('# SPEC' '# IMPLEMENTATION_PLAN' '# RESEARCH' '# WORKLOG')
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> headingRegex [
	^ '(?m)^#\\s+(SPEC|IMPLEMENTATION_PLAN|RESEARCH|WORKLOG)\\s*$' asRegex
]

{ #category : #registry }
GtSpecSetMarkdownParserAdapter class >> install [
	^ self ensureInstalled
]

{ #category : #'accessing class' }
GtSpecSetMarkdownParserAdapter class >> label [
	^ 'SPEC/PLAN/RESEARCH/WORKLOG (Markdown)'
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> matches: aFileReference [
	"True when extension is md/markdown AND first non-empty line is a SPEC-set header."

	| first |
	(aFileReference isFile
		and: [ #('md' 'markdown') includes: aFileReference extension asLowercase ])
		ifFalse: [ ^ false ].
	first := self firstNonEmptyLineFrom: aFileReference ifNone: [ ^ false ].
	^ self headingNames anySatisfy: [ :each | first = each ]
]

{ #category : #'parsing class' }
GtSpecSetMarkdownParserAdapter class >> parse: aFileReference [
	| text parts |
	text := aFileReference readStreamDo: [ :s | s contents ].
	parts := self splitText: text.
	^ (Smalltalk at: #GtSpecSetSplitResult) fromParts: parts
]

{ #category : #parsing }
GtSpecSetMarkdownParserAdapter class >> priority [
	"Lower number = higher precedence."

	^ 1
]

{ #category : #utilities }
GtSpecSetMarkdownParserAdapter class >> splitFromString: aString into: aDirectoryRef [
	| master res |
	aDirectoryRef ensureCreateDirectory.
	master := FileSystem memory root / 'MASTER.md'.
	master ensureCreateFile.
	master writeStreamDo: [ :ws | ws nextPutAll: aString ].
	res := self parse: master.
	^ res writeFilesIn: aDirectoryRef
]

{ #category : #'parsing class' }
GtSpecSetMarkdownParserAdapter class >> splitText: aString [
	"Return a Dictionary #{#spec->String. #plan->String. #research->String. #worklog->String}
     Each string starts with its header line."

	| map currentKey buf out stream line trimmed maybeKey |
	map := Dictionary
			newFromPairs: {'# SPEC'.
					#spec.
					'# IMPLEMENTATION_PLAN'.
					#plan.
					'# RESEARCH'.
					#research.
					'# WORKLOG'.
					#worklog}.
	out := Dictionary new.
	buf := WriteStream on: String new.
	stream := ReadStream on: aString.

	[ stream atEnd ]
		whileFalse: [ line := stream nextLine.
			trimmed := line ifNil: [ '' ] ifNotNil: [ line withBlanksCondensed ].
			maybeKey := map at: trimmed ifAbsent: [ nil ].
			maybeKey
				ifNil: [ currentKey
						ifNotNil: [ buf
								nextPutAll: line;
								cr ] ]
				ifNotNil: [  "flush previous chunk"currentKey
						ifNotNil: [ out at: currentKey put: buf contents ].
					buf := WriteStream on: String new.	"start new chunk with the header itself"
					buf
						nextPutAll: trimmed;
						cr.
					currentKey := maybeKey ] ].
	currentKey ifNotNil: [ out at: currentKey put: buf contents ].
	^ out
]

{ #category : #'parsing class' }
GtSpecSetMarkdownParserAdapter class >> stripBOMFrom: aString [
	^ aString copyWithout: (Character value: 16rFEFF)
]
