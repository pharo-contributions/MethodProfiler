Class {
	#name : #PrfMethodCounterTests,
	#superclass : #TestCase,
	#instVars : [
		'dummyAFooHandler',
		'dummyABarHandler'
	],
	#category : #Profiler
}

{ #category : #running }
PrfMethodCounterTests >> setUp [
	dummyAFooHandler := PrfMethodCounter createForMethod: PrfDummyClassA >> #foo.
	dummyAFooHandler enable.
	
	dummyABarHandler := PrfMethodCounter createForMethod: PrfDummyClassA >> #bar:.
	dummyABarHandler enable.
	
]

{ #category : #running }
PrfMethodCounterTests >> tearDown [
	dummyAFooHandler disable.
	dummyABarHandler disable.
]

{ #category : #tests }
PrfMethodCounterTests >> testDummyABarExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: false.
	self assert: dummyAFooHandler executionCount  equals: 0.
	self assert: dummyABarHandler executionCount equals: 1.
	
]

{ #category : #tests }
PrfMethodCounterTests >> testDummyABarReset [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: false.
	dummyABarHandler reset.
	self assert: dummyABarHandler executionCount equals: 0.
	
]

{ #category : #tests }
PrfMethodCounterTests >> testDummyABarWithSubFooExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: true.
	self assert: dummyAFooHandler executionCount  equals: 1.
	self assert: dummyABarHandler executionCount equals: 1.
	
]

{ #category : #tests }
PrfMethodCounterTests >> testDummyAFooExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA foo.
	self assert: dummyAFooHandler executionCount equals: 1.
	self assert: dummyABarHandler executionCount equals: 0.
	
]

{ #category : #tests }
PrfMethodCounterTests >> testDummyAFooReset [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA foo.
	dummyAFooHandler reset.
	self assert: dummyAFooHandler executionCount equals: 0.
	
]
