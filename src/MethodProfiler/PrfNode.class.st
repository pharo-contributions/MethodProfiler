Class {
	#name : #PrfNode,
	#superclass : #Object,
	#instVars : [
		'methodCalls',
		'timesCalled',
		'result'
	],
	#category : #MethodProfiler
}

{ #category : #accessing }
PrfNode >> accumulatedCalls [

	^ self timesCalled + (self methodCalls sum: [ :e | e accumulatedCalls ])
]

{ #category : #accessing }
PrfNode >> addCall [
	timesCalled := timesCalled + 1.
]

{ #category : #accessing }
PrfNode >> addCallTo: aNode [
	methodCalls add: aNode
]

{ #category : #accessing }
PrfNode >> addCallTo: aNode times: aNumber [
	methodCalls add: aNode withOccurrences: aNumber 
]

{ #category : #accessing }
PrfNode >> addCalls: aNumber [
	timesCalled := timesCalled + aNumber.
]

{ #category : #accessing }
PrfNode >> allChildren [

	| stack set |
	stack := Stack new.
	set := Set new.

	stack push: self.

	[ stack isEmpty ] whileFalse: [
		| node |
		node := stack pop.
		node methodCalls doWithOccurrences: [ :destinationNode :_ |
			(set includes: destinationNode) ifFalse: [
				stack push: destinationNode.
				set add: destinationNode ] ] ].
	
	^set
]

{ #category : #accessing }
PrfNode >> allChildrenAndSelf [

	^ self allChildren
		  add: self;
		  yourself
]

{ #category : #accessing }
PrfNode >> curateCallsAfterCompaction: aCompactionDictionnary [

	| oldMethodCalls |
	oldMethodCalls := methodCalls.
	methodCalls := Bag new.

	oldMethodCalls doWithOccurrences: [ :node :occurences |
		methodCalls
			add: (aCompactionDictionnary
					 at: node
					 ifPresent: [ :newNode | newNode ]
					 ifAbsent: [ node ])
			withOccurrences: occurences ]
]

{ #category : #testing }
PrfNode >> hasChildren [

	^ methodCalls notEmpty
]

{ #category : #initialization }
PrfNode >> initialize [ 
	super initialize.
	methodCalls := Bag new.
	timesCalled := 0.
]

{ #category : #accessing }
PrfNode >> methodCalls [

	^ methodCalls
]

{ #category : #accessing }
PrfNode >> numberOfCallsTo: aNode [
	aNode ifNil: [ ^0 ] ifNotNil: [ ^methodCalls occurrencesOf: aNode ].
]

{ #category : #copying }
PrfNode >> postCopy [ 
	methodCalls := methodCalls copy.
	^ self
]

{ #category : #accessing }
PrfNode >> removeAllCalls [
	methodCalls removeAll.
	timesCalled := 0
]

{ #category : #accessing }
PrfNode >> result: anObject [

	result := anObject
]

{ #category : #accessing }
PrfNode >> timesCalled [

	^ timesCalled
]

{ #category : #accessing }
PrfNode >> totalNumberOfCalls [
	^ methodCalls size.
]
