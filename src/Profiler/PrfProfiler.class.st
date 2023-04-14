Class {
	#name : #PrfProfiler,
	#superclass : #Object,
	#instVars : [
		'counters'
	],
	#category : #Profiler
}

{ #category : #scope }
PrfProfiler >> addClass: aClass [
	|methods|
	methods := aClass methodDictionary.
	methods do: [ :method | self addMethod: method ]
]

{ #category : #scope }
PrfProfiler >> addMethod: aMethod [
	(self canProfile: aMethod) ifTrue: [ 
		counters 
			at: (self methodKey: aMethod) 
			ifAbsentPut: (PrfMethodCounter createForMethod: aMethod) ].
	
]

{ #category : #scope }
PrfProfiler >> addPackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self addClass: class ]
]

{ #category : #private }
PrfProfiler >> canProfile: aMethod [
	^(aMethod realClass ~= PrfProfiler) and: (aMethod realClass ~= PrfMethodCounter)
]

{ #category : #display }
PrfProfiler >> displayResults [

	|keys|
	keys := counters keys asOrderedCollection.
	keys sort: [ :key1 :key2 |  
		((counters at: key1) executionCount) > ((counters at: key2) executionCount)].
	
	Transcript show: '--- Profiling summary ---'; cr.
	keys
		do: [ :methodKey |
			Transcript
				show: (methodKey at: 1);
				show: ' >> #';
				show: (methodKey at: 2);
				show: ' -> ';
				show: (counters at: methodKey) executionCount;
				cr].
	Transcript cr.
]

{ #category : #scope }
PrfProfiler >> excludeClass: aClass [
	|methods|
	methods := aClass methodDictionary.
	methods do: [ :method |
		self excludeMethod: method ]
]

{ #category : #scope }
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

{ #category : #scope }
PrfProfiler >> excludePackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self excludeClass: class ]
]

{ #category : #initialization }
PrfProfiler >> initialize [ 
	counters := Dictionary new.
]

{ #category : #scope }
PrfProfiler >> isNotProfiled: aMethod [
	^(self isProfiled: aMethod) not
]

{ #category : #scope }
PrfProfiler >> isProfiled: aMethod [
	^counters includesKey: (self methodKey: aMethod)
]

{ #category : #scope }
PrfProfiler >> isProfilingEnabled: aMethod [
	^(counters at: (self methodKey: aMethod)) isEnabled
]

{ #category : #scope }
PrfProfiler >> method: aMethod ifNotProfiled: aBlock [
	^(self isProfiled: aMethod)
		ifTrue: [ self ]
		ifFalse: [ aBlock value ]
]

{ #category : #scope }
PrfProfiler >> method: aMethod ifProfiled: aBlock [
	^(self isProfiled: aMethod)
		ifTrue: [ aBlock value ]
		ifFalse: [ self ]
]

{ #category : #scope }
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
PrfProfiler >> reset [
	counters do: [ :counter | counter reset ]
]

{ #category : #lifecycle }
PrfProfiler >> start [
	counters do: [ :counter | counter enable].
]

{ #category : #lifecycle }
PrfProfiler >> stop [ 
	counters do: [ :counter | counter disable].
]
