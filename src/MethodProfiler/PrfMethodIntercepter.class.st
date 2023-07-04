Class {
	#name : #PrfMethodIntercepter,
	#superclass : #MpHandler,
	#instVars : [
		'method',
		'proxy',
		'runner'
	],
	#category : #MethodProfiler
}

{ #category : #creation }
PrfMethodIntercepter class >> newForMethod: aMethod withRunner: aRunner [

	^ PrfMethodIntercepter new
		  method: aMethod;
		  runner: aRunner;
		  yourself
]

{ #category : #evaluating }
PrfMethodIntercepter >> afterMethod [

	runner exitMethod: method
]

{ #category : #evaluating }
PrfMethodIntercepter >> beforeMethod [

	runner enterMethod: method
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
PrfMethodIntercepter >> proxy [

	^ proxy
]

{ #category : #accessing }
PrfMethodIntercepter >> runner [

	^ runner
]

{ #category : #accessing }
PrfMethodIntercepter >> runner: anObject [

	runner := anObject
]

{ #category : #installation }
PrfMethodIntercepter >> uninstall [
	proxy ifNotNil: [ 
		proxy uninstall.
		proxy := nil ]
]
