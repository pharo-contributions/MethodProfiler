Class {
	#name : #PrfMethodNode,
	#superclass : #Object,
	#instVars : [
		'method',
		'methodCalls',
		'timesCalled'
	],
	#category : #MethodProfiler
}

{ #category : #creation }
PrfMethodNode class >> forMethod: aMethod [
	|node|
	node := PrfMethodNode new.
	node method: aMethod.
	^node
]

{ #category : #accessing }
PrfMethodNode >> addCall [
	timesCalled := timesCalled + 1.
]

{ #category : #accessing }
PrfMethodNode >> addCallTo: aMethod [
	methodCalls add: aMethod
]

{ #category : #initialization }
PrfMethodNode >> initialize [ 
	methodCalls := Bag new.
	timesCalled := 0
]

{ #category : #accessing }
PrfMethodNode >> method [

	^ method
]

{ #category : #accessing }
PrfMethodNode >> method: anObject [

	method := anObject
]

{ #category : #accessing }
PrfMethodNode >> methodCalls [

	^ methodCalls
]

{ #category : #accessing }
PrfMethodNode >> numberOfCallsTo: aMethod [
	^ methodCalls occurrencesOf: (aMethod unproxifiedMethod ).
]

{ #category : #converting }
PrfMethodNode >> printString [  
	method ifNil: [ ^'Root' ].
	^method printString
]

{ #category : #accessing }
PrfMethodNode >> removeAllCalls [
	methodCalls removeAll.
	timesCalled := 0
]

{ #category : #accessing }
PrfMethodNode >> timesCalled [

	^ timesCalled
]

{ #category : #accessing }
PrfMethodNode >> totalNumberOfCalls [
	^ methodCalls size.
]
