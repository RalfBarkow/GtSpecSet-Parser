Class {
	#name : #BaselineOfGtSpecSetParser,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSpecSetParser
}

{ #category : #baseline }
BaselineOfGtSpecSetParser >> baseline: spec [
	<baseline>
	^ spec for: #common do: [ spec package: 'GtSpecSetParser' ]
]
