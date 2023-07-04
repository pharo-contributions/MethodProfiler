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

{ #category : #tests }
PrfProfilerTest >> testClassExclude [

	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeClass: PrfDummyClassA.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testClassForbiddenDomainError [

	profiler addClass: PrfMethodProfilerRunner.
	self deny:
		(profiler isProfilingMethod: PrfMethodProfilerRunner >> #profile:)
]

{ #category : #tests }
PrfProfilerTest >> testClassProfiled [

	profiler addClass: PrfDummyClassA.
	self assert: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testExclude [

	profiler addMethod: PrfDummyClassA >> #foo.
	profiler excludeMethod: PrfDummyClassA >> #foo.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testForbiddenDomainError [

	profiler addMethod: PrfMethodProfilerRunner >> #profile:.
	self deny:
		(profiler isProfilingMethod: PrfMethodProfilerRunner >> #profile:)
]

{ #category : #tests }
PrfProfilerTest >> testNotProfiled [

	profiler addMethod: PrfDummyClassA >> #bar:.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testPackageExclude [

	profiler addPackage: 'MethodProfiler-Tests' asPackage.
	profiler excludeClass: PrfDummyClassA.
	self deny: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testPackageForbiddenDomainError [

	profiler addPackage: 'MethodProfiler' asPackage.
	self deny:
		(profiler isProfilingMethod: PrfMethodProfilerRunner >> #profile:)
]

{ #category : #tests }
PrfProfilerTest >> testPackageProfiled [

	profiler addPackage: 'MethodProfiler-Tests' asPackage.
	self assert: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]

{ #category : #tests }
PrfProfilerTest >> testProfiled [

	profiler addMethod: PrfDummyClassA >> #foo.
	self assert: (profiler isProfilingMethod: PrfDummyClassA >> #foo)
]
