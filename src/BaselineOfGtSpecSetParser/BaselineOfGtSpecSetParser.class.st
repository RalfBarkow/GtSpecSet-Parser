Class {
	#name : #BaselineOfGtSpecSetParser,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSpecSetParser
}

{ #category : #baseline }
BaselineOfGtSpecSetParser >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec package: 'GtSpecSet-Model'.
			spec
				package: 'GtSpecSet-Parser'
				with: [ spec requires: #('GtSpecSet-Model') ].
			spec group: 'core' with: #('GtSpecSet-Model' 'GtSpecSet-Parser').
			spec group: 'default' with: #('core') ]
]

{ #category : #'as yet unclassified' }
BaselineOfGtSpecSetParser >> postLoad [
	(Smalltalk at: #GtSpecSetMarkdownParserAdapter ifAbsent: [ ^ self ])
		perform: #install
]
