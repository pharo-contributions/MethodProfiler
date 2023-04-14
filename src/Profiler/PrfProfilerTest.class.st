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

	profiler stop.
	
	super tearDown.
]

{ #category : #tests }
PrfProfilerTest >> testBlockMethodExecutionCount [
	profiler addClass: PrfDummyClassA.
	profiler profile: [
		PrfDummyClassA new foo. ].
	self assert: (profiler methodExecutionCount: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testClassExclude [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeClass: PrfDummyClassA.
	self deny: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testClassForbiddenDomainError [
	profiler addClass: PrfProfiler.
	self deny: (profiler isProfiled: PrfProfiler >> #methodExecutionCount:)
]

{ #category : #tests }
PrfProfilerTest >> testClassMethodExecutionCount [
	profiler addClass: PrfDummyClassA.
	profiler start.
	PrfDummyClassA new foo.
	self assert: (profiler methodExecutionCount: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testClassProfiled [
	profiler addClass: PrfDummyClassA.
	self assert: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testExceptionInBlockProfile [
	profiler addMethod: (PrfDummyClassA >> #foo).
	self should: [ profiler profile: [ 1 error: 'test' ] ] raise: Error.
	self deny: (profiler isProfilingEnabled: (PrfDummyClassA >> #foo))
]

{ #category : #tests }
PrfProfilerTest >> testExclude [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeMethod: PrfDummyClassA >> #foo.
	self deny: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testForbiddenDomainError [
	profiler addMethod: PrfProfiler >> #methodExecutionCount:.
	self deny: (profiler isProfiled: PrfProfiler >> #methodExecutionCount:)
]

{ #category : #tests }
PrfProfilerTest >> testNotProfiled [
	profiler addMethod: PrfDummyClassA >> #bar:.
	self deny: (profiler isProfiled: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testPackageExclude [
	profiler addPackage: ('Profiler-Dummy' asPackage).
	profiler excludeClass: PrfDummyClassA.
	self deny: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testPackageForbiddenDomainError [
	profiler addPackage: ('Profiler' asPackage).
	self deny: (profiler isProfiled: PrfProfiler >> #methodExecutionCount:)
]

{ #category : #tests }
PrfProfilerTest >> testPackageMethodExecutionCount [
	profiler addPackage: ('Profiler-Dummy' asPackage).
	profiler start.
	PrfDummyClassA new foo.
	self assert: (profiler methodExecutionCount: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testPackageProfiled [
	profiler addPackage: ('Profiler-Dummy' asPackage).
	self assert: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testProfiled [
	profiler addMethod: PrfDummyClassA >> #foo.
	self assert: (profiler isProfiled: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testReset [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler start.
	PrfDummyClassA new foo.
	profiler reset.
	self assert: (profiler methodExecutionCount: PrfDummyClassA >> #foo) equals: 0.
]

{ #category : #tests }
PrfProfilerTest >> testSimpleMethodExecutionCount [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler addMethod: PrfDummyClassA >> #bar:.
	profiler start.
	PrfDummyClassA new foo.
	self assert: (profiler methodExecutionCount: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testSimpleMethodExecutionCountError [
	self 
		should: [ profiler methodExecutionCount: PrfDummyClassA >> #foo ] 
		raise: PrfNotProfiledError.
]
