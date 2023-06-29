Class {
	#name : #PrfProcessCallStack,
	#superclass : #ProcessLocalVariable,
	#instVars : [
		'profiler',
		'stacks'
	],
	#category : #MethodProfiler
}

{ #category : #initialization }
PrfProcessCallStack >> ensureStackIsInitialized [
	
	"A new thread requires a stack.
	Initialize it and store it.
	Otherwise, the process specific variable is stored in a weak array"
	| theStack |
	self value ifNotNil: [ ^ self ].
	
	theStack := Stack new.
	theStack push: profiler unknownNode.
	stacks add: theStack.
	
	self value: theStack.
]

{ #category : #initialization }
PrfProcessCallStack >> initialize [

	super initialize.
	stacks := IdentitySet new
]

{ #category : #removing }
PrfProcessCallStack >> pop [
	"Precondition, the process variable is already initialized"
	^ self value pop
]

{ #category : #accessing }
PrfProcessCallStack >> profiler [

	^ profiler
]

{ #category : #accessing }
PrfProcessCallStack >> profiler: anObject [

	profiler := anObject
]

{ #category : #adding }
PrfProcessCallStack >> push: anElement [
	self ensureStackIsInitialized.
	^self value push: anElement
]

{ #category : #accessing }
PrfProcessCallStack >> size [

	^ self value size
]

{ #category : #accessing }
PrfProcessCallStack >> top [ 
	^self value top
]
