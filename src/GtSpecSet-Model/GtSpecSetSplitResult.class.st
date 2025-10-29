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
	^ parts
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
	| mapping localParts |
	localParts := self validatedParts.

	mapping := {#SPEC -> 'SPEC.md'.
			#IMPLEMENTATION_PLAN -> 'IMPLEMENTATION_PLAN.md'.
			#RESEARCH -> 'RESEARCH.md'.
			#WORKLOG -> 'WORKLOG.md'} asDictionary.

	aDirectoryRef ensureCreateDirectory.

	mapping
		keysAndValuesDo: [ :key :fileName | 
			| targetRef newText |
			newText := localParts at: key ifAbsent: [ '' ].	"Coerce anything non-textual to a String (defensive), but warn in Transcript."
			(newText isString or: [ newText isKindOf: Text ])
				ifFalse: [ Transcript
						cr;
						show: '[GtSpecSetSplitResult] WARNING: ' , key printString , ' value was '
								, newText class name , '. Coercing via #asString.';
						cr.
					newText := newText asString ].
			targetRef := aDirectoryRef / fileName.
			(self needsWrite: targetRef with: newText)
				ifTrue: [ self writeAll: newText to: targetRef ] ].
	^ aDirectoryRef
]
