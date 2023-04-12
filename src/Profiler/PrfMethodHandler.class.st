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
	handler := PrfMethodHandler new.
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

{ #category : #accessing }
PrfMethodHandler >> reset [ 
	executionCount := 0
]
