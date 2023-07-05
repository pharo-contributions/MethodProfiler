Class {
	#name : #PrfDummyRunnerForIntercepter,
	#superclass : #Object,
	#instVars : [
		'before',
		'after'
	],
	#category : #'MethodProfiler-Tests'
}

{ #category : #initialization }
PrfDummyRunnerForIntercepter >> enterMethod: aMethod [
	before := before + 1.
]

{ #category : #initialization }
PrfDummyRunnerForIntercepter >> exitMethod: aMethod [
	after := after + 1.
]

{ #category : #initialization }
PrfDummyRunnerForIntercepter >> initialize [ 
	before := 0.
	after := 0
]
