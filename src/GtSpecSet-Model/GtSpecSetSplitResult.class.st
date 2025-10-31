Class {
	#name : #GtSpecSetSplitResult,
	#superclass : #Object,
	#instVars : [
		'source',
		'parts',
		'order'
	],
	#category : #'GtSpecSet-Model'
}

{ #category : #'instance creation' }
GtSpecSetSplitResult class >> fromParts: aDict [
	^ self new
		parts: aDict;
		yourself
]

{ #category : #examples }
GtSpecSetSplitResult class >> gtExampleWriteToTemp [
	<gtExample>
	| res tmp |
	res := GtSpecSetMarkdownParserAdapter exampleParse.	"returns a GtSpecSetSplitResult with #parts set"
	tmp := FileSystem memory root / 'out'.
	tmp ensureCreateDirectory.
	res writeFilesIn: tmp.
	^ tmp
]

{ #category : #writing }
GtSpecSetSplitResult >> needsWrite: aFileRef with: newText [
	^ aFileRef exists not or: [ aFileRef contents ~= newText ]
]

{ #category : #accessing }
GtSpecSetSplitResult >> order: aCollection [
	order := aCollection
]

{ #category : #accessing }
GtSpecSetSplitResult >> parts [
	^ parts ifNil: [ Dictionary new ]
]

{ #category : #accessing }
GtSpecSetSplitResult >> parts: aDict [
	parts := aDict
]

{ #category : #accessing }
GtSpecSetSplitResult >> source: aRef [
	source := aRef
]

{ #category : #writing }
GtSpecSetSplitResult >> validatedParts [
	parts
		ifNil: [ self
				error: 'No parts set. Create via the adapter''s #parse: (e.g., exampleParse).' ].
	(parts isKindOf: Dictionary)
		ifFalse: [ self error: 'Invalid parts (expected Dictionary); got: ' , parts class name ].
	^ parts
]

{ #category : #writing }
GtSpecSetSplitResult >> writeAll: newText to: aFileRef [
	aFileRef ensureCreateFile.
	aFileRef writeStreamDo: [ :ws | ws nextPutAll: newText ]
]

{ #category : #writing }
GtSpecSetSplitResult >> writeFiles [
	^ self writeFilesIn: source parent
]

{ #category : #writing }
GtSpecSetSplitResult >> writeFilesIn: aDirectoryRef [
	| mapping |
	aDirectoryRef ensureCreateDirectory.
	mapping := {#spec -> 'SPEC.md'.
			#plan -> 'IMPLEMENTATION_PLAN.md'.
			#research -> 'RESEARCH.md'.
			#worklog -> 'WORKLOG.md'} asDictionary.
	mapping
		keysAndValuesDo: [ :key :name | 
			(self parts at: key ifAbsent: [ nil ])
				ifNotNil: [ :txt | 
					| f |
					f := aDirectoryRef / name.
					f ensureCreateFile.
					f writeStreamDo: [ :ws | ws nextPutAll: txt ] ] ].
	^ aDirectoryRef
]
