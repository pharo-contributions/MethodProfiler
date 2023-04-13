Class {
	#name : #PrfDummyClassA,
	#superclass : #Object,
	#category : #'Profiler-Dummy'
}

{ #category : #accessing }
PrfDummyClassA >> bar: isExecutingFoo [
	isExecutingFoo ifTrue: [ self foo ].
	
]

{ #category : #accessing }
PrfDummyClassA >> foo [
]
