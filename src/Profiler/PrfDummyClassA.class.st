Class {
	#name : #PrfDummyClassA,
	#superclass : #Object,
	#category : #Profiler
}

{ #category : #accessing }
PrfDummyClassA >> bar: isExecutingFoo [
	isExecutingFoo ifTrue: [ self foo ].
	
]

{ #category : #accessing }
PrfDummyClassA >> foo [
]
