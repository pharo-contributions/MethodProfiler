Class {
	#name : #PrfProcessCallStack,
	#superclass : #ProcessLocalVariable,
	#category : #MethodProfiler
}

{ #category : #initialization }
PrfProcessCallStack >> ensureStackIsInitialized [
	self value ifNil: [ self value: Stack new ].
]

{ #category : #testing }
PrfProcessCallStack >> isEmpty [ 
	self ensureStackIsInitialized.
	^self value isEmpty 
]

{ #category : #removing }
PrfProcessCallStack >> pop [
	self ensureStackIsInitialized.
	^self value pop
]

{ #category : #adding }
PrfProcessCallStack >> push: anElement [
	self ensureStackIsInitialized.
	^self value push: anElement
]

{ #category : #accessing }
PrfProcessCallStack >> size [

	self value ifNil: [ ^ 0 ].
	^ self value size
]

{ #category : #accessing }
PrfProcessCallStack >> top [ 
	self ensureStackIsInitialized.
	^self value top
]
