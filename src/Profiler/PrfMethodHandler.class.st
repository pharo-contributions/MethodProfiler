Class {
	#name : #PrfMethodHandler,
	#superclass : #MpHandler,
	#instVars : [
		'executionCount',
		'method'
	],
	#category : #Profiler
}

{ #category : #creation }
PrfMethodHandler class >> createForMethod: aMethod [
	|handler|
	handler := PrfMethodHandler basicNew.
	handler executionCount: 0.
	handler method: aMethod.
	^handler
]

{ #category : #evaluating }
PrfMethodHandler >> afterMethod [ 
	executionCount := executionCount + 1
]

{ #category : #accessing }
PrfMethodHandler >> executionCount [
	^executionCount 
]

{ #category : #accessing }
PrfMethodHandler >> executionCount: aNumber [
	executionCount := aNumber 
]

{ #category : #initialization }
PrfMethodHandler >> initialize [ 
	executionCount := 0
]

{ #category : #accessing }
PrfMethodHandler >> method [
	^method 
]

{ #category : #accessing }
PrfMethodHandler >> method: aMethod [
	method := aMethod 
]
