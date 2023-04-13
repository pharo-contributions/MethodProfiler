Class {
	#name : #PrfProfilerTest,
	#superclass : #TestCase,
	#instVars : [
		'profiler'
	],
	#category : #Profiler
}

{ #category : #running }
PrfProfilerTest >> setUp [
	super setUp.
	
	profiler := PrfProfiler new
]

{ #category : #running }
PrfProfilerTest >> tearDown [ 

	profiler close.
	
	super tearDown.
]

{ #category : #tests }
PrfProfilerTest >> testExclude [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeMethod: PrfDummyClassA >> #foo.
	self deny: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testForbiddenDomainError [
	self 
		should: [ profiler addMethod: PrfProfiler >> #methodExecutionCount: ] 
		raise: PrfProfilingDomainError .
]

{ #category : #tests }
PrfProfilerTest >> testNotProfiled [
	profiler addMethod: PrfDummyClassA >> #bar:.
	self deny: (profiler isProfiled: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testProfiled [
	profiler addMethod: PrfDummyClassA >> #foo.
	self assert: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testSimpleMethodExecutionCount [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler addMethod: PrfDummyClassA >> #bar:.
	PrfDummyClassA new foo.
	self assert: (profiler methodExecutionCount: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testSimpleMethodExecutionCountError [
	self 
		should: [ profiler methodExecutionCount: PrfDummyClassA >> #foo ] 
		raise: PrfNotProfiledError.
]
