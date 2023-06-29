Class {
	#name : #PrfMethodIntercepter,
	#superclass : #MpHandler,
	#instVars : [
		'method',
		'profiler',
		'proxy'
	],
	#category : #MethodProfiler
}

{ #category : #creation }
PrfMethodIntercepter class >> forMethod: aMethod withProfiler: aProfiler [
	|intercepter|
	intercepter := PrfMethodIntercepter new.
	intercepter method: aMethod.
	intercepter profiler: aProfiler.
	^intercepter
]

{ #category : #evaluating }
PrfMethodIntercepter >> afterMethod [

	profiler callStack pop exitingNode
]

{ #category : #evaluating }
PrfMethodIntercepter >> beforeMethod [

	| node precedingNode |
	profiler callStack ensureStackIsInitialized.
	precedingNode := profiler callStack top.
	node := profiler
		        nodeForMethod: method
		        withPrecedingNode: precedingNode.
	precedingNode addCallTo: node.
	node addCall.
	profiler callStack push: node.
	node enteringNode.
]

{ #category : #accessing }
PrfMethodIntercepter >> disable [
	proxy isEnabled: false.
]

{ #category : #accessing }
PrfMethodIntercepter >> enable [
	proxy isEnabled: true.
]

{ #category : #installation }
PrfMethodIntercepter >> install [

	proxy ifNil: [
		proxy := MpMethodProxy onMethod: method handler: self.
		proxy install ]
]

{ #category : #accessing }
PrfMethodIntercepter >> method [

	^ method
]

{ #category : #accessing }
PrfMethodIntercepter >> method: anObject [

	method := anObject
]

{ #category : #accessing }
PrfMethodIntercepter >> profiler [

	^ profiler
]

{ #category : #accessing }
PrfMethodIntercepter >> profiler: anObject [

	profiler := anObject
]

{ #category : #accessing }
PrfMethodIntercepter >> proxy [

	^ proxy
]

{ #category : #installation }
PrfMethodIntercepter >> uninstall [
	proxy ifNotNil: [ 
		proxy uninstall.
		proxy := nil ]
]
