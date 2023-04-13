Class {
	#name : #PrfProfiler,
	#superclass : #Object,
	#instVars : [
		'counters'
	],
	#category : #Profiler
}

{ #category : #control }
PrfProfiler >> addMethod: aMethod [
	(self canProfile: aMethod) ifFalse: [ 
		PrfProfilingDomainError new signal: 'This method is not profilable' ].
	counters 
		at: (self methodKey: aMethod) 
		ifAbsentPut: (PrfMethodCounter createForMethod: aMethod)
]

{ #category : #private }
PrfProfiler >> canProfile: aMethod [
	^(aMethod realClass ~= PrfProfiler) and: (aMethod realClass ~= PrfMethodCounter)
]

{ #category : #control }
PrfProfiler >> close [ 
	counters do: [ :counter | counter disable].
	counters removeAll 
]

{ #category : #control }
PrfProfiler >> excludeMethod: aMethod [
	|key|
	key := self methodKey: aMethod.
	counters 
		at: key 
		ifPresent: [ :counter |
			counter disable.
			counters removeKey: key.
			 ]
]

{ #category : #initialization }
PrfProfiler >> initialize [ 
	counters := Dictionary new.
]

{ #category : #control }
PrfProfiler >> isNotProfiled: aMethod [
	^(self isProfiled: aMethod) not
]

{ #category : #control }
PrfProfiler >> isProfiled: aMethod [
	^counters includesKey: (self methodKey: aMethod)
]

{ #category : #control }
PrfProfiler >> method: aMethod ifNotProfiled: aBlock [
	^(self isProfiled: aMethod)
		ifTrue: [ self ]
		ifFalse: [ aBlock value ]
]

{ #category : #control }
PrfProfiler >> method: aMethod ifProfiled: aBlock [
	^(self isProfiled: aMethod)
		ifTrue: [ aBlock value ]
		ifFalse: [ self ]
]

{ #category : #control }
PrfProfiler >> method: aMethod ifProfiled: profiledBlock ifNotProfiled: notProfiledBlock [
	^(self isProfiled: aMethod)
		ifTrue: [ profiledBlock value ]
		ifFalse: [ notProfiledBlock value ]
]

{ #category : #accessing }
PrfProfiler >> methodExecutionCount: aMethod [
	self 
		method: aMethod 
		ifProfiled: [ ^(counters at: (self methodKey: aMethod)) executionCount ]
		ifNotProfiled: [ PrfNotProfiledError new signal: 'This method is not being profiled.' ]
	
]

{ #category : #private }
PrfProfiler >> methodKey: aMethod [
	^{aMethod realClass . aMethod selector}
]
