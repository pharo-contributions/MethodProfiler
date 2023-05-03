Class {
	#name : #PrfMethodIntercepter,
	#superclass : #MpHandler,
	#instVars : [
		'method',
		'proxy',
		'profiler'
	],
	#category : #MethodProfiler
}

{ #category : #creation }
PrfMethodIntercepter class >> forMethod: aMethod withProfiler: aProfiler [
	|intercepter|
	intercepter := PrfMethodIntercepter new.
	intercepter method: aMethod.
	intercepter profiler: aProfiler.
	intercepter install.
	^intercepter
]

{ #category : #accessing }
PrfMethodIntercepter >> afterMethod [
	(profiler callStack isEmpty) ifFalse: [ profiler callStack pop ] 
]

{ #category : #accessing }
PrfMethodIntercepter >> beforeMethod [
	(profiler callStack isEmpty)
	ifFalse: [ 
		(profiler nodes at: (profiler callStack top)) addCallTo: method ] 
	ifTrue: [ 
		profiler unknownNode addCallTo: method ].
	(profiler nodes at: (method)) addCall.
	profiler callStack push: method 
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
		proxy install.
		proxy disable. ]
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
