Class {
	#name : #PrfProfilerTests,
	#superclass : #TestCase,
	#instVars : [
		'dummyAFooHandler',
		'dummyAFooProxy',
		'dummyABarHandler',
		'dummyABarProxy'
	],
	#category : #Profiler
}

{ #category : #running }
PrfProfilerTests >> setUp [
	dummyAFooHandler := PrfMethodHandler createForMethod: PrfDummyClassA >> #foo.
	dummyAFooProxy := MpMethodProxy 
		onMethod: PrfDummyClassA >> #foo 
		handler: dummyAFooHandler.
	dummyAFooProxy install.
	
	dummyABarHandler := PrfMethodHandler createForMethod: PrfDummyClassA >> #bar:.
	dummyABarProxy := MpMethodProxy 
		onMethod: PrfDummyClassA >> #bar:
		handler: dummyABarHandler.
	dummyABarProxy install.
	
]

{ #category : #running }
PrfProfilerTests >> tearDown [
	dummyAFooProxy uninstall.
	dummyABarProxy uninstall.
]

{ #category : #tests }
PrfProfilerTests >> testDummyABarExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA bar: 5.
	self assert: dummyAFooHandler executionCount  equals: 0.
	self assert: dummyABarHandler executionCount equals: 1.
	
]

{ #category : #tests }
PrfProfilerTests >> testDummyAFooExecution [
	|dummyA|
	dummyA := PrfDummyClassA new.
	dummyA foo.
	self assert: dummyAFooHandler executionCount equals: 1.
	self assert: dummyABarHandler executionCount equals: 0.
	
]
