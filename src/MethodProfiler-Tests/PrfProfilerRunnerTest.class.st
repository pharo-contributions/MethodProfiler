Class {
	#name : #PrfProfilerRunnerTest,
	#superclass : #TestCase,
	#instVars : [
		'runner'
	],
	#category : #'MethodProfiler-Tests'
}

{ #category : #running }
PrfProfilerRunnerTest >> setUp [
	super setUp.
	
	runner := PrfMethodProfilerRunner new
]

{ #category : #running }
PrfProfilerRunnerTest >> tearDown [ 

	runner destroy.
	
	super tearDown.
]

{ #category : #tests }
PrfProfilerRunnerTest >> testBlockMethodExecutionCount [
	|result|
	runner methods: PrfDummyClassA methodDictionary.
	result := runner profile: [
		PrfDummyClassA new foo. ].
	self assert: (result numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerRunnerTest >> testClassMethodExecutionCount [

	runner methods: PrfDummyClassA methodDictionary.

	runner start.
	PrfDummyClassA new foo.
	runner stop.
	runner result buildCallGraph.

	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo)
		equals: 1
]

{ #category : #tests }
PrfProfilerRunnerTest >> testComplexMethodExecutionCount [

	runner methods: {
			(PrfDummyClassA >> #foo).
			(PrfDummyClassA >> #bar:) }.


	runner profile: [
		PrfDummyClassA new foo.
		PrfDummyClassA new bar: true ].

	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo)
		equals: 2.
	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #bar:)
		equals: 1.
	self
		assert: (runner result
				 numberOfCallsFrom: PrfDummyClassA >> #bar:
				 to: PrfDummyClassA >> #foo)
		equals: 1.
	self
		assert:
		(runner result numberOfCallsFrom: nil to: PrfDummyClassA >> #foo)
		equals: 1.
	self
		assert:
		(runner result numberOfCallsFrom: nil to: PrfDummyClassA >> #bar:)
		equals: 1
]

{ #category : #tests }
PrfProfilerRunnerTest >> testExceptionInBlockProfile [
	runner methods: {PrfDummyClassA >> #foo}.
	self should: [ runner profile: [ 1 error: 'test' ] ] raise: Error.
	self deny: (runner isProfilingNow)
]

{ #category : #tests }
PrfProfilerRunnerTest >> testPackageMethodExecutionCount [

	'MethodProfiler-Tests' asPackage definedClasses do: [ :class |
		runner methods: class methodDictionary ].

	runner start.
	PrfDummyClassA new foo.
	runner stop.
	runner result buildCallGraph.

	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo)
		equals: 1
]

{ #category : #tests }
PrfProfilerRunnerTest >> testReset [
	runner methods: {PrfDummyClassA >> #foo}.
	
	runner start.
	PrfDummyClassA new foo.
	runner stop.
	runner reset.
	
	self assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo) equals: 0.
]

{ #category : #tests }
PrfProfilerRunnerTest >> testSimpleMethodExecutionCount [
	runner methods: {PrfDummyClassA >> #foo. PrfDummyClassA >> #bar:}.
	
	runner start.
	PrfDummyClassA new foo.
	runner stop.
	runner result buildCallGraph.
	
	self assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]
