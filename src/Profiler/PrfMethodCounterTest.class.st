Class {
	#name : #PrfMethodCounterTest,
	#superclass : #TestCase,
	#instVars : [
		'dummyAFooHandler',
		'dummyABarHandler'
	],
	#category : #Profiler
}

{ #category : #running }
PrfMethodCounterTest >> setUp [
	super setUp.
	
	dummyAFooHandler := PrfMethodCounter createForMethod: PrfDummyClassA >> #foo.
	dummyABarHandler := PrfMethodCounter createForMethod: PrfDummyClassA >> #bar:.
	
]

{ #category : #running }
PrfMethodCounterTest >> tearDown [
	
	dummyAFooHandler disable.
	dummyABarHandler disable.
	
	super tearDown.
]

{ #category : #tests }
PrfMethodCounterTest >> testDummyABarExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: false.
	self assert: dummyAFooHandler executionCount  equals: 0.
	self assert: dummyABarHandler executionCount equals: 1.
	
]

{ #category : #tests }
PrfMethodCounterTest >> testDummyABarReset [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: false.
	dummyABarHandler reset.
	self assert: dummyABarHandler executionCount equals: 0.
	
]

{ #category : #tests }
PrfMethodCounterTest >> testDummyABarWithSubFooExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: true.
	self assert: dummyAFooHandler executionCount  equals: 1.
	self assert: dummyABarHandler executionCount equals: 1.
	
]

{ #category : #tests }
PrfMethodCounterTest >> testDummyAFooExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA foo.
	self assert: dummyAFooHandler executionCount equals: 1.
	self assert: dummyABarHandler executionCount equals: 0.
	
]

{ #category : #tests }
PrfMethodCounterTest >> testDummyAFooReset [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA foo.
	dummyAFooHandler reset.
	self assert: dummyAFooHandler executionCount equals: 0.
	
]
