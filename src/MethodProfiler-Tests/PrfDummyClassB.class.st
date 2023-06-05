Class {
	#name : #PrfDummyClassB,
	#superclass : #Object,
	#category : #'MethodProfiler-Tests'
}

{ #category : #accessing }
PrfDummyClassB >> bar: isExecutingFoo [
	isExecutingFoo ifTrue: [ self foo ].
	
]

{ #category : #accessing }
PrfDummyClassB >> foo [
]
