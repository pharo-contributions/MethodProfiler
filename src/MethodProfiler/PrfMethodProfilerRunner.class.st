Class {
	#name : #PrfMethodProfilerRunner,
	#superclass : #Object,
	#instVars : [
		'intercepters',
		'profilingNow',
		'callStack',
		'result'
	],
	#category : #MethodProfiler
}

{ #category : #'instance creation' }
PrfMethodProfilerRunner class >> newForMethods: aSetOfMethods [

	^ self new
		  addMethods: aSetOfMethods;
		  yourself
]

{ #category : #adding }
PrfMethodProfilerRunner >> addMethods: aSetOfMethods [
	(aSetOfMethods collect: [ :method | method unproxifiedMethod ]) do: [
		:method | intercepters at: method put: (PrfMethodIntercepter newForMethod: method withRunner: self)]
]

{ #category : #initialization }
PrfMethodProfilerRunner >> destroy [

	intercepters do: [ :intercepter | intercepter uninstall ].
	intercepters removeAll.
	result := nil.
]

{ #category : #'method flow' }
PrfMethodProfilerRunner >> enterMethod: aMethod [

	| node precedingNode |
	callStack ensureStackIsInitialized.
	precedingNode := callStack top.
	node := result
		        nodeForMethod: aMethod
		        withPrecedingNode: precedingNode.
	precedingNode addCallTo: node.
	node addCall.
	callStack push: node.
	node enteringNode
]

{ #category : #'method flow' }
PrfMethodProfilerRunner >> exitMethod: aMethod [

	callStack pop exitingNode
]

{ #category : #initialization }
PrfMethodProfilerRunner >> initialize [
	result := PrfMethodProfilerResult new.
	callStack := PrfProcessCallStack newWithRunner: self.
	intercepters := Dictionary new.
	profilingNow := false
]

{ #category : #accessing }
PrfMethodProfilerRunner >> isProfilingNow [

	^ profilingNow
]

{ #category : #lifecycle }
PrfMethodProfilerRunner >> profile: aBlock [

	self start.
	aBlock ensure: [ self stop ].
	^ result
]

{ #category : #initialization }
PrfMethodProfilerRunner >> reset [ 
	result := PrfMethodProfilerResult new.
]

{ #category : #accessing }
PrfMethodProfilerRunner >> result [

	^ result
]

{ #category : #lifecycle }
PrfMethodProfilerRunner >> start [
	intercepters do: [ :intercepter | intercepter install ].
	result rootNode enteringNode.
	profilingNow := true
]

{ #category : #lifecycle }
PrfMethodProfilerRunner >> stop [

	result rootNode exitingNode.
	intercepters do: [ :intercepter | intercepter uninstall ].
	profilingNow := false
]
