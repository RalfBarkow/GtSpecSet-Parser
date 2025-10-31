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

{ #category : #'as yet unclassified' }
GtSpecSetMarkdownParserAdapter class >> exampleDiagnoseDiskSPEC [
	"Point this to a real SPEC-like file in your workspace to inspect selection."

	<gtExample>
	| fr input |
	self installEverywhere.
	fr := FileLocator home / 'workspace' / 'space-runner' / 'space-runner-SPEC.md'.
	(fr exists and: [ fr isFile ])
		ifFalse: [ ^ 'File not found: ' , fr pathString ].
	input := fr asGtInputFile.
	^ input selectionExplanation
]

{ #category : #'as yet unclassified' }
GtSpecSetMarkdownParserAdapter class >> exampleFirstNonEmptyLine [
	"Sanity-check our first-line detector with BOM/blank handling."

	<gtExample>
	| fr first |
	fr := FileSystem memory root / 'X.md'.
	fr ensureCreateFile.
	fr
		writeStreamDo: [ :s | 
			s nextPutAll: (String with: (Character value: 16rFEFF)).	"BOM"
			s
				cr;
				cr;
				nextPutAll: '# SPEC';
				cr;
				nextPutAll: '…' ].
	first := self firstNonEmptyLineFrom: fr ifNone: [ '<<none>>' ].
	self assert: first = '# SPEC'.
	^ first
]

{ #category : #'as yet unclassified' }
GtSpecSetMarkdownParserAdapter class >> exampleInstallEverywhere [
	"Run this once to ensure the adapter is visible to GT."

	<gtExample>
	self installEverywhere.
	^ 'installed'
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

{ #category : #'as yet unclassified' }
GtSpecSetMarkdownParserAdapter class >> exampleParseAndWriteToTemp [
	"Parse a minimal SPEC-set text and write the four files to a temp dir."

	<gtExample>
	| tmp res |
	self installEverywhere.
	res := self exampleParse.	"assumes you already have exampleParse answering a split result"
	tmp := FileSystem memory root / 'out'.
	tmp ensureCreateDirectory.
	res writeFilesIn: tmp.
	^ tmp
]

{ #category : #'examples class' }
GtSpecSetMarkdownParserAdapter class >> exampleRegistryHealth [
	<gtExample>
	| ctxClass ctx regClass reg parsersClass ctxParsers regParsers globalParsers |
	ctxParsers := #().
	regParsers := #().
	globalParsers := #().

	ctxClass := Smalltalk at: #GtInputContext ifAbsent: [ nil ].
	ctxClass ifNotNil: [
		(ctxClass respondsTo: #current) ifTrue: [
			ctx := ctxClass current.
			(ctx respondsTo: #parsers)
				ifTrue: [ ctxParsers := ctx parsers collect: #name ] ] ].

	regClass := Smalltalk at: #GtInputParserRegistry ifAbsent: [ nil ].
	regClass ifNotNil: [
		(regClass respondsTo: #default) ifTrue: [
			reg := regClass default.
			(reg respondsTo: #parsers)
				ifTrue: [ regParsers := reg parsers collect: #name ] ] ].

	parsersClass := Smalltalk at: #GtInputParsers ifAbsent: [ nil ].
	parsersClass ifNotNil: [
		(parsersClass respondsTo: #parsers)
			ifTrue: [ globalParsers := (parsersClass parsers collect: #name) ] ].

	^ { #ctxHas -> ctxParsers asArray.
	     #registryHas -> regParsers asArray.
	     #globalHas -> globalParsers asArray }
]

{ #category : #'examples class' }
GtSpecSetMarkdownParserAdapter class >> exampleWhyMemorySPEC [
	"Creates a SPEC.md in a memory FS and shows who wins + candidates."
	<gtExample>
	| fr input why winner candidates |
	self installEverywhere.

	fr := FileSystem memory root / 'SPEC.md'.
	fr ensureCreateFile.
	fr writeStreamDo: [ :s |
		s nextPutAll: '# SPEC'; cr; nextPutAll: 'Title'; cr ].

	input := fr asGtInputFile.
	why := input selectionExplanation.  "Often an OrderedDictionary"

	winner := self
		valueFor: #winner
		in: why
		ifAbsent: [ '<<unknown>>' ].
	candidates := self
		valueFor: #candidates
		in: why
		ifAbsent: [ (input respondsTo: #candidateParsers)
			ifTrue: [ input candidateParsers collect: #name ]
			ifFalse: [ #() ] ].

	^ { #winner -> winner.
	     #candidates -> candidates.
	     #path -> fr pathString }
]

{ #category : #'examples class' }
GtSpecSetMarkdownParserAdapter class >> exampleWhyMemorySPEC_fixed [
	<gtExample>
	| fr input why winner candidates ctxClass ctx |
	fr := FileSystem memory root / 'SPEC.md'.
	fr ensureCreateFile.
	fr writeStreamDo: [ :s |
		s nextPutAll: '# SPEC'; cr; nextPutAll: 'Title'; cr ].

	input := fr asGtInputFile.

	"Register on the specific input context (prevents Null winner)"
	ctxClass := Smalltalk at: #GtInputContext ifAbsent: [ nil ].
	ctx := (input respondsTo: #context) ifTrue: [ input context ] ifFalse: [ nil ].
	ctx isNil ifTrue: [ ctx := (ctxClass notNil and: [ ctxClass respondsTo: #current ])
		ifTrue: [ ctxClass current ] ifFalse: [ nil ] ].
	ctx ifNotNil: [ (ctx respondsTo: #registerParser:) ifTrue: [ ctx registerParser: self ] ].

	why := input selectionExplanation.

	winner := self valueFor: #winner in: why ifAbsent: [ '<<unknown>>' ].
	candidates := self valueFor: #candidates in: why
		ifAbsent: [ (input respondsTo: #candidateParsers)
			ifTrue: [ input candidateParsers collect: #name ]
			ifFalse: [ #() ] ].

	^ { #winner -> winner.
	     #candidates -> candidates.
	     #path -> fr pathString }
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

{ #category : #'registry class' }
GtSpecSetMarkdownParserAdapter class >> installEverywhere [
	| ctxClass regClass parsersClass ctx reg |
	ctxClass := Smalltalk at: #GtInputContext ifAbsent: [ nil ].
	regClass := Smalltalk at: #GtInputParserRegistry ifAbsent: [ nil ].
	parsersClass := Smalltalk at: #GtInputParsers ifAbsent: [ nil ].

	ctxClass ifNotNil: [
		(ctxClass respondsTo: #current) ifTrue: [
			ctx := ctxClass current.
			(ctx respondsTo: #registerParser:) ifTrue: [ ctx registerParser: self ] ] ].

	regClass ifNotNil: [
		(regClass respondsTo: #default) ifTrue: [
			reg := regClass default.
			(reg respondsTo: #add:) ifTrue: [ reg add: self ] ] ].

	parsersClass ifNotNil: [
		(parsersClass respondsTo: #parsers)
			ifTrue: [ (parsersClass parsers) addIfNotPresent: self ] ].
	^ self
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
	"Return a Dictionary #{#spec->String. #plan->String. #research->String. #worklog->String}."

	| map currentKey buf out stream line trimmed maybeKey |
	map := Dictionary
			newFromPairs: #('# SPEC' #spec '# IMPLEMENTATION_PLAN' #plan '# RESEARCH' #research '# WORKLOG' #worklog).
	out := Dictionary new.
	buf := WriteStream on: String new.
	stream := ReadStream on: aString.

	[ stream atEnd ]
		whileFalse: [ line := stream nextLine.
			trimmed := line ifNotNil: [ line trimBoth ].	"FIX: #withBlanksTrimmed → #trimBoth"
			maybeKey := map at: trimmed ifAbsent: [ nil ].
			maybeKey
				ifNotNil: [ currentKey ifNotNil: [ out at: currentKey put: buf contents ].
					buf := WriteStream on: String new.
					currentKey := maybeKey ]
				ifNil: [ buf
						nextPutAll: trimmed;
						cr ] ].

	currentKey ifNotNil: [ out at: currentKey put: buf contents ].
	^ out
]

{ #category : #'parsing class' }
GtSpecSetMarkdownParserAdapter class >> stripBOMFrom: aString [
	^ aString copyWithout: (Character value: 16rFEFF)
]

{ #category : #'utilities class' }
GtSpecSetMarkdownParserAdapter class >> valueFor: aKey in: aMap ifAbsent: aBlock [
	(aMap respondsTo: #at:) ifTrue: [ ^ aMap at: aKey ifAbsent: aBlock ].
	(aMap respondsTo: #associations) ifTrue: [
		| assoc |
		assoc := aMap associations
			detect: [ :ea | ea key = aKey ]
			ifNone: [ ^ aBlock value ].
		^ assoc value ].
	^ aBlock value
]
