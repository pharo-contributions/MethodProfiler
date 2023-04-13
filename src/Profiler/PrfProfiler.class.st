Class {
	#name : #PrfProfiler,
	#superclass : #Object,
	#instVars : [
		'counters'
	],
	#category : #Profiler
}

{ #category : #control }
PrfProfiler >> addClass: aClass [
	|methods|
	methods := aClass methodDictionary.
	methods do: [ :method | self addMethod: method ]
]

{ #category : #control }
PrfProfiler >> addMethod: aMethod [
	(self canProfile: aMethod) ifTrue: [ 
		counters 
			at: (self methodKey: aMethod) 
			ifAbsentPut: (PrfMethodCounter createForMethod: aMethod) ].
	
]

{ #category : #control }
PrfProfiler >> addPackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self addClass: class ]
]

{ #category : #private }
PrfProfiler >> canProfile: aMethod [
	^(aMethod realClass ~= PrfProfiler) and: (aMethod realClass ~= PrfMethodCounter)
]

{ #category : #control }
PrfProfiler >> excludeClass: aClass [
	|methods|
	methods := aClass methodDictionary.
	methods do: [ :method |
		self excludeMethod: method ]
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

{ #category : #control }
PrfProfiler >> excludePackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self excludeClass: class ]
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

{ #category : #accessing }
PrfProfiler >> profile: aBlock [
	self start.
	aBlock ensure: [ 
		self stop ]
]

{ #category : #lifecycle }
PrfProfiler >> start [
	counters do: [ :counter | counter enable].
]

{ #category : #lifecycle }
PrfProfiler >> stop [ 
	counters do: [ :counter | counter disable].
]
