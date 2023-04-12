Class {
	#name : #PrfMethodCounter,
	#superclass : #MpHandler,
	#instVars : [
		'executionCount',
		'method'
	],
	#category : #Profiler
}

{ #category : #creation }
PrfMethodCounter class >> createForMethod: aMethod [
	|handler|
	handler := PrfMethodCounter new.
	handler method: aMethod.
	^handler
]

{ #category : #evaluating }
PrfMethodCounter >> afterMethod [ 
	executionCount := executionCount + 1
]

{ #category : #lifecycle }
PrfMethodCounter >> createProxy [
	proxy := MpMethodProxy 
		onMethod: method 
		handler: self.
]

{ #category : #lifecycle }
PrfMethodCounter >> disable [
	proxy ifNil: [ self createProxy ].
	proxy uninstall.
]

{ #category : #lifecycle }
PrfMethodCounter >> enable [
	proxy ifNil: [ self createProxy ].
	proxy install.
]

{ #category : #accessing }
PrfMethodCounter >> executionCount [
	^executionCount 
]

{ #category : #initialization }
PrfMethodCounter >> initialize [ 
	executionCount := 0
]

{ #category : #accessing }
PrfMethodCounter >> method [
	^method 
]

{ #category : #accessing }
PrfMethodCounter >> method: aMethod [
	method := aMethod 
]

{ #category : #accessing }
PrfMethodCounter >> reset [ 
	executionCount := 0
]
