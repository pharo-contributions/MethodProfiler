Class {
	#name : #PrfRootNode,
	#superclass : #PrfLiveNode,
	#instVars : [
		'process'
	],
	#category : #MethodProfiler
}

{ #category : #creation }
PrfRootNode class >> forProcess: aProcess withResult: aResultObject withHash: aString [

	| node |
	node := self new.
	node result: aResultObject.
	node process: aProcess.
	node nodeHash: aString.
	^ node
]

{ #category : #converting }
PrfRootNode >> printString [
	^'Root#' , process identityHash hex
]

{ #category : #accessing }
PrfRootNode >> process [

	^ process
]

{ #category : #accessing }
PrfRootNode >> process: anObject [

	process := anObject
]
