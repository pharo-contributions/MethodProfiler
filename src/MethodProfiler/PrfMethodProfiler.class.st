Class {
	#name : #PrfMethodProfiler,
	#superclass : #Object,
	#instVars : [
		'callStack',
		'intercepters',
		'nodes',
		'unknownNode',
		'profilingNow'
	],
	#category : #MethodProfiler
}

{ #category : #installation }
PrfMethodProfiler >> addClass: aClass [
	|methods|
	methods := aClass methodDictionary.
	methods do: [ :method | self addMethod: method ].
	^self
]

{ #category : #adding }
PrfMethodProfiler >> addExecutionFromMethod: callingMethod toMethod: calledMethod [
	nodes 
		at: (callingMethod unproxifiedMethod )
		ifPresent: [ :node | node addCall: (calledMethod unproxifiedMethod ) ]
		ifAbsent: [ unknownNode addCall: (calledMethod unproxifiedMethod ) ]
]

{ #category : #installation }
PrfMethodProfiler >> addMethod: aMethod [
	|unproxifiedMethod|
	unproxifiedMethod := aMethod unproxifiedMethod.
	(self shouldWrap: unproxifiedMethod ) ifTrue: [ 
		intercepters 
			at: unproxifiedMethod 
			put: (PrfMethodIntercepter forMethod: unproxifiedMethod withProfiler: self ).
		nodes 
			at: unproxifiedMethod 
			put: (PrfMethodNode forMethod: unproxifiedMethod withProfiler: self  )].
	^self
]

{ #category : #installation }
PrfMethodProfiler >> addPackage: aPackage [
	|classes|
	classes := aPackage definedClasses.
	classes do: [ :class | self addClass: class ].
	^self
]

{ #category : #ui }
PrfMethodProfiler >> callGraph [

	| c edges label localNodes lines graphNodes stepping layout minEdgeValue maxEdgeValue |
	minEdgeValue := nil.
	maxEdgeValue := nil.

	localNodes := (nodes asArray copyWith: unknownNode) select: [ :node |
		              node totalNumberOfCalls + node timesCalled > 0 ].

	edges := Set new.
	localNodes do: [ :node |
		node methodCalls asSet do: [ :method |
			edges add: node -> (nodes at: method) ] ].

	c := RSCanvas new.

	graphNodes := (localNodes collect: [ :model |
						
		               model -> (RSEllipse new
			                labeled;
			                draggable;
			                model: model;
			                yourself) ]) asDictionary.

	lines := edges collect: [ :edge |
		         | edgeValue |
		         edgeValue := edge key numberOfCallsTo: edge value method.
		         label := RSLabeled new.
		         label location
			         inner;
			         middle.
		         label text: edgeValue asString.
		         label lowColor: Color red.
		         RSShapeFactory arrowedLine
			         addInteraction: label;
			         withBorderAttachPoint;
						model: edgeValue;
			         color: Color black;
			         from: (graphNodes at: edge key);
			         to: (graphNodes at: edge value);
			         yourself ].

	c
		addAll: graphNodes values;
		addAll: lines.
		
	RSNormalizer size
		from: 10;
		to: 100; 
		shapes: graphNodes values;
		normalize: #timesCalled.
	RSNormalizer color
		from: (Color blue muchDarker alpha: 0.75);
		to: (Color red alpha: 0.75);
		shapes: graphNodes values;
		normalize: #timesCalled.
	RSNormalizer width
		from: 0.5;
		to: 4;
		shapes: lines;
		normalize: #yourself.
	
	(graphNodes at: unknownNode) size: 50; color: (Color green alpha: 0.75).

	stepping := RSForceLayoutSteppingInteraction new.

	(layout := stepping layout)
		length: 100;
		charge: -1000.
	c @ stepping.
	c @ RSCanvasController.
	^ c
]

{ #category : #accessing }
PrfMethodProfiler >> callStack [

	^ callStack
]

{ #category : #initialization }
PrfMethodProfiler >> destroy [
	intercepters do: [ :intercepter | intercepter uninstall ].
	intercepters removeAll.
	nodes removeAll.
	unknownNode := nil.
]

{ #category : #ui }
PrfMethodProfiler >> drawCallGraph [
	<inspectorPresentationOrder: 1 title: 'Call Graph'>
	^ SpRoassal3InspectorPresenter new canvas: self callGraph yourself
]

{ #category : #installation }
PrfMethodProfiler >> excludeClass: aClass [
	|methods|
	methods := aClass methodDictionary.
	methods do: [ :method |
		self excludeMethod: method ].
	^self
]

{ #category : #installation }
PrfMethodProfiler >> excludeMethod: aMethod [
	|unproxifiedMethod|
	unproxifiedMethod := aMethod unproxifiedMethod.
	intercepters 
		at: unproxifiedMethod 
		ifPresent: [ :intercepter | 
			intercepter uninstall.
			intercepters removeKey: unproxifiedMethod.
			nodes removeKey: unproxifiedMethod  ].
	^self
]

{ #category : #installation }
PrfMethodProfiler >> excludePackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self excludeClass: class ].
	^self
]

{ #category : #initialization }
PrfMethodProfiler >> initialize [
	callStack := PrfProcessCallStack new.
	intercepters := Dictionary new.
	nodes := Dictionary new.
	unknownNode := PrfMethodNode forMethod: nil withProfiler: self.
	profilingNow := false
]

{ #category : #accessing }
PrfMethodProfiler >> intercepters [

	^ intercepters
]

{ #category : #installation }
PrfMethodProfiler >> isProfilingMethod: aMethod [
	^intercepters includesKey: (aMethod unproxifiedMethod)
]

{ #category : #accessing }
PrfMethodProfiler >> isProfilingNow [

	^ profilingNow
]

{ #category : #accessing }
PrfMethodProfiler >> nodeForMethod: aMethod [
	^ nodes at: (aMethod unproxifiedMethod )
]

{ #category : #accessing }
PrfMethodProfiler >> nodes [

	^ nodes
]

{ #category : #counting }
PrfMethodProfiler >> numberOfCallsFrom: aMethod [
	nodes 
	at: (aMethod unproxifiedMethod)
	ifPresent: [ :node | ^node totalNumberOfCalls  ]
	ifAbsent: [ ^0 ]
]

{ #category : #counting }
PrfMethodProfiler >> numberOfCallsTo: aMethod [
	nodes 
	at: (aMethod unproxifiedMethod)
	ifPresent: [ :node | ^node timesCalled  ]
	ifAbsent: [ ^0 ]
]

{ #category : #lifecycle }
PrfMethodProfiler >> profile: aBlock [
	self start.
	aBlock ensure: [ 
		self stop ]
]

{ #category : #initialization }
PrfMethodProfiler >> reset [ 
	unknownNode removeAllCalls.
	nodes do: [ :node | node removeAllCalls ]
]

{ #category : #installation }
PrfMethodProfiler >> shouldWrap: aMethod [
	|unproxifiedMethod clazz|
	unproxifiedMethod := aMethod unproxifiedMethod.
	
	unproxifiedMethod isCompiledMethod ifFalse: [ ^ false ].
	
	clazz := unproxifiedMethod realClass.
	((clazz = PrfMethodIntercepter) 
	or: ((clazz = PrfMethodNode) 
	or: ((clazz = PrfMethodProfiler) 
	or: (clazz = PrfProcessCallStack ))))
	ifTrue: [ ^ false ].
	
	(unproxifiedMethod pragmas noneSatisfy: [ :pragma | pragma selector = #methodProxyCannotWrap ] )ifFalse: [ ^ false ].
	
	^true
]

{ #category : #lifecycle }
PrfMethodProfiler >> start [
	intercepters do: [ :intercepter | intercepter enable ].
	profilingNow := true
]

{ #category : #lifecycle }
PrfMethodProfiler >> stop [
	intercepters do: [ :intercepter | intercepter disable ].
	profilingNow := false
]

{ #category : #accessing }
PrfMethodProfiler >> unknownNode [

	^ unknownNode
]
