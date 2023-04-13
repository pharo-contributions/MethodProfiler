Class {
	#name : #PrfDummyClassB,
	#superclass : #Object,
	#category : #'Profiler-Dummy'
}

{ #category : #accessing }
PrfDummyClassB >> bar: isExecutingFoo [
	isExecutingFoo ifTrue: [ self foo ].
	
]

{ #category : #accessing }
PrfDummyClassB >> foo [
]
