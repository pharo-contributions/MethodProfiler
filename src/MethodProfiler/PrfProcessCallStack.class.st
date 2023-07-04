Class {
	#name : #PrfProcessCallStack,
	#superclass : #ProcessLocalVariable,
	#instVars : [
		'stacks',
		'runner'
	],
	#category : #MethodProfiler
}

{ #category : #'instance creation' }
PrfProcessCallStack class >> newWithRunner: aRunner [

	^ self new
		  runner: aRunner;
		  yourself
]

{ #category : #initialization }
PrfProcessCallStack >> ensureStackIsInitialized [
	
	"A new thread requires a stack.
	Initialize it and store it.
	Otherwise, the process specific variable is stored in a weak array"
	| theStack |
	self value ifNotNil: [ ^ self ].
	theStack := Stack new.
	theStack push: runner result rootNode.
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

{ #category : #adding }
PrfProcessCallStack >> push: anElement [
	self ensureStackIsInitialized.
	^self value push: anElement
]

{ #category : #accessing }
PrfProcessCallStack >> runner [

	^ runner
]

{ #category : #accessing }
PrfProcessCallStack >> runner: aRunner [

	runner := aRunner
]

{ #category : #accessing }
PrfProcessCallStack >> size [

	^ self value size
]

{ #category : #accessing }
PrfProcessCallStack >> top [ 
	^self value top
]
