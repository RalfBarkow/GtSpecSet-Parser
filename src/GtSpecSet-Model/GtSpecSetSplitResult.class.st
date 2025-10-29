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
GtSpecSetSplitResult >> gtExampleWriteToTemp [
	<gtExample>
	| tmp |
	tmp := FileSystem memory root / 'out'.
	tmp ensureCreateDirectory.
	self writeFilesIn: tmp.
	^ tmp
]

{ #category : #writing }
GtSpecSetSplitResult >> needsWrite: aFileRef with: newText [
	(aFileRef exists) ifFalse: [ ^ true ].
	^ (aFileRef contents ~= newText)
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
GtSpecSetSplitResult >> writeAll: aString to: aFileRef [
	aFileRef ensureCreateFile.
	aFileRef writeStreamDo: [ :ws | ws nextPutAll: aString ]
]

{ #category : #writing }
GtSpecSetSplitResult >> writeFiles [
	^ self writeFilesIn: source parent
]

{ #category : #writing }
GtSpecSetSplitResult >> writeFilesIn: aDirectoryRef [
	| mapping |
	mapping := { #SPEC -> 'SPEC.md'. #IMPLEMENTATION_PLAN -> 'IMPLEMENTATION_PLAN.md'. #RESEARCH -> 'RESEARCH.md'. #WORKLOG -> 'WORKLOG.md' } asDictionary.
	mapping keysAndValuesDo: [ :key :fileName |
		| targetRef newText |
		targetRef := aDirectoryRef / fileName.
		newText := parts at: key ifAbsent: [ '' ].
		(self needsWrite: targetRef with: newText)
			ifTrue: [ self writeAll: newText to: targetRef ] ].
	^ aDirectoryRef
]
