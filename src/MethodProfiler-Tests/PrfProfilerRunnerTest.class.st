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
	runner addMethods: PrfDummyClassA methodDictionary.
	result := runner profile: [
		PrfDummyClassA new foo. ].
	self assert: (result numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]

{ #category : #tests }
PrfProfilerRunnerTest >> testClassMethodExecutionCount [

	runner addMethods: PrfDummyClassA methodDictionary.

	runner start.
	PrfDummyClassA new foo.
	runner stop.

	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo)
		equals: 1
]

{ #category : #tests }
PrfProfilerRunnerTest >> testComplexMethodExecutionCount [

	runner addMethods: {PrfDummyClassA >> #foo. PrfDummyClassA >> #bar:}.
	
	runner start.
	PrfDummyClassA new foo.
	PrfDummyClassA new bar: true.
	runner stop.
	
	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo)
		equals: 2.
	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #bar:)
		equals: 1.
	self
		assert: (runner result numberOfCallsFrom: PrfDummyClassA >> #bar: to: PrfDummyClassA >> #foo)
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
	runner addMethods: {PrfDummyClassA >> #foo}.
	self should: [ runner profile: [ 1 error: 'test' ] ] raise: Error.
	self deny: (runner isProfilingNow)
]

{ #category : #tests }
PrfProfilerRunnerTest >> testPackageMethodExecutionCount [

	'MethodProfiler-Tests' asPackage definedClasses do: [ :class |
		runner addMethods: class methodDictionary ].

	runner start.
	PrfDummyClassA new foo.
	runner stop.

	self
		assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo)
		equals: 1
]

{ #category : #tests }
PrfProfilerRunnerTest >> testReset [
	runner addMethods: {PrfDummyClassA >> #foo}.
	
	runner start.
	PrfDummyClassA new foo.
	runner stop.
	runner reset.
	
	self assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo) equals: 0.
]

{ #category : #tests }
PrfProfilerRunnerTest >> testSimpleMethodExecutionCount [
	runner addMethods: {PrfDummyClassA >> #foo. PrfDummyClassA >> #bar:}.
	
	runner start.
	PrfDummyClassA new foo.
	runner stop.
	
	self assert: (runner result numberOfCallsTo: PrfDummyClassA >> #foo) equals: 1.
]
