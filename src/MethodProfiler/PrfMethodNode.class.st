Class {
	#name : #PrfMethodNode,
	#superclass : #Object,
	#instVars : [
		'method',
		'methodCalls'
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
PrfMethodNode >> addCallTo: aMethod [
	methodCalls add: aMethod
]

{ #category : #initialization }
PrfMethodNode >> initialize [ 
	methodCalls := Bag new.
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
	methodCalls removeAll
]

{ #category : #accessing }
PrfMethodNode >> totalNumberOfCalls [
	^ methodCalls size.
]
