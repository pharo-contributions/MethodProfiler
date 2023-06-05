Class {
	#name : #PrfProfilerTest,
	#superclass : #TestCase,
	#instVars : [
		'profiler'
	],
	#category : #'MethodProfiler-Tests'
}

{ #category : #running }
PrfProfilerTest >> setUp [
	super setUp.
	
	profiler := PrfMethodProfiler new
]

{ #category : #running }
PrfProfilerTest >> tearDown [ 

	profiler destroy.
	
	super tearDown.
]

{ #category : #tests }
PrfProfilerTest >> testBlockMethodExecutionCount [
	profiler addClass: PrfDummyClassA.
	profiler profile: [
		PrfDummyClassA new foo. ].
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testClassExclude [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeClass: PrfDummyClassA.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testClassForbiddenDomainError [
	profiler addClass: PrfMethodProfiler.
	self deny: (profiler isProfilingMethod: PrfMethodProfiler >> #numberOfCallsTo:)
]

{ #category : #tests }
PrfProfilerTest >> testClassMethodExecutionCount [
	profiler addClass: PrfDummyClassA.
	profiler start.
	PrfDummyClassA new foo.
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testClassProfiled [
	profiler addClass: PrfDummyClassA.
	self assert: (profiler isProfilingMethod: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testComplexMethodExecutionCount [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler addMethod: PrfDummyClassA >> #bar:.
	profiler start.
	PrfDummyClassA new foo.
	PrfDummyClassA new bar: true.
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #foo) equals: 2.
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #bar:) equals: 1.
	self assert: ((profiler nodeForMethod: (PrfDummyClassA >> #bar:)) numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
	self assert: ((profiler unknownNode) numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
	self assert: ((profiler unknownNode) numberOfCallsTo: PrfDummyClassA >> #bar:) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testExceptionInBlockProfile [
	profiler addMethod: (PrfDummyClassA >> #foo).
	self should: [ profiler profile: [ 1 error: 'test' ] ] raise: Error.
	self deny: (profiler isProfilingNow)
]

{ #category : #tests }
PrfProfilerTest >> testExclude [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeMethod: PrfDummyClassA >> #foo.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testForbiddenDomainError [
	profiler addMethod: PrfMethodProfiler >> #numberOfCallsTo:.
	self deny: (profiler isProfilingMethod: PrfMethodProfiler >> #numberOfCallsTo:)
]

{ #category : #tests }
PrfProfilerTest >> testNotProfiled [
	profiler addMethod: PrfDummyClassA >> #bar:.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testPackageExclude [
	profiler addPackage: ('MethodProfiler-Tests' asPackage).
	profiler excludeClass: PrfDummyClassA.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testPackageForbiddenDomainError [
	profiler addPackage: ('MethodProfiler' asPackage).
	self deny: (profiler isProfilingMethod: PrfMethodProfiler >> #numberOfCallsTo:)
]

{ #category : #tests }
PrfProfilerTest >> testPackageMethodExecutionCount [
	profiler addPackage: ('MethodProfiler-Tests' asPackage).
	profiler start.
	PrfDummyClassA new foo.
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerTest >> testPackageProfiled [
	profiler addPackage: ('MethodProfiler-Tests' asPackage).
	self assert: (profiler isProfilingMethod: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testProfiled [
	profiler addMethod: PrfDummyClassA >> #foo.
	self assert: (profiler isProfilingMethod: PrfDummyClassA >> #foo).
]

{ #category : #tests }
PrfProfilerTest >> testReset [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler start.
	PrfDummyClassA new foo.
	profiler reset.
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #foo) equals: 0.
]

{ #category : #tests }
PrfProfilerTest >> testSimpleMethodExecutionCount [
	profiler addMethod: PrfDummyClassA >> #foo.
	profiler addMethod: PrfDummyClassA >> #bar:.
	profiler start.
	PrfDummyClassA new foo.
	self assert: (profiler numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]
