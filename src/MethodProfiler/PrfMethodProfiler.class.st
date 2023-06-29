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
		"nodes 
			at: unproxifiedMethod 
			put: (PrfMethodNode forMethod: unproxifiedMethod withProfiler: self  )"].
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

	| c edges label localNodes lines graphNodes stepping layout minEdgeValue maxEdgeValue allNodes |
	minEdgeValue := nil.
	maxEdgeValue := nil.
	
	allNodes := self unknownNode allChildren.
	localNodes := (allNodes copyWith: unknownNode) select: [ :node |
		              node totalNumberOfCalls + node timesCalled > 0 ].

	edges := Set new.
	localNodes do: [ :node |
		node methodCalls do: [ :childNode |
			edges add: node -> childNode ] ].

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

	RSTreeLayout on: graphNodes values.

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
 	<inspectorPresentationOrder: 10 title: 'Call Graph'>
	^ SpRoassal3InspectorPresenter new canvas: self callGraph yourself
]

{ #category : #ui }
PrfMethodProfiler >> drawFlameGraph [
	<inspectorPresentationOrder: 2 title: 'Flame Graph'>
	^ SpRoassal3InspectorPresenter new canvas: self flameGraph yourself
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

	| unproxifiedMethod |
	unproxifiedMethod := aMethod unproxifiedMethod.
	intercepters at: unproxifiedMethod ifPresent: [ :intercepter |
		intercepter uninstall.
		intercepters removeKey: unproxifiedMethod.
		(nodes keys select: [ :key |
			 key beginsWith: aMethod unproxifiedMethod printString , '#' ])
			do: [ :key | nodes removeKey: key ] ].
	^ self
]

{ #category : #installation }
PrfMethodProfiler >> excludePackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self excludeClass: class ].
	^self
]

{ #category : #ui }
PrfMethodProfiler >> flameGraph [

	| builder |
	builder := RSFlameGraph new.
	builder boxShape.
	builder
		leafWeight: [ :f | f totalTime asMicroseconds ];
		explore: self unknownNode
		nesting: [ :n | n methodCalls asSet select: [ :c | c hasChildren ] ]
		leaves: [ :n | n methodCalls asSet reject: [ :c | c hasChildren ] ].
	builder build.
	builder shapes
		@ (RSPopup text: [ :f | f asString ]);
		@ (RSHighlightable new highlightBorder:
					 (RSBorder new color: Color black)).
	RSNormalizer color
		from: (Color blue muchDarker alpha: 0.75);
		to: (Color red alpha: 0.75);
		shapes: builder shapes;
		normalize: #timesCalled.

	^ builder canvas
		  addInteraction: RSCanvasController new;
		  yourself
]

{ #category : #initialization }
PrfMethodProfiler >> initialize [
	callStack := PrfProcessCallStack new profiler: self.
	intercepters := Dictionary new.
	nodes := Dictionary new.
	unknownNode := PrfMethodNode forMethod: nil withProfiler: self withHash: (((SHA1 new hashMessage: '') copyFrom: 1 to: 4) hex ).
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

{ #category : #installation }
PrfMethodProfiler >> nodeForMethod: aMethod withPrecedingNode: aNode [

	| uniqueMethodName |
	uniqueMethodName := aMethod name , '#' , aNode nodeHash.
	^ nodes
		  at: uniqueMethodName
		  ifPresent: [ :node | node ]
		  ifAbsentPut: [
			  PrfMethodNode
				  forMethod: aMethod
				  withProfiler: self
				  withHash:
				  ((SHA1 new hashMessage: uniqueMethodName) copyFrom: 1 to: 4) hex ]
]

{ #category : #accessing }
PrfMethodProfiler >> nodes [

	^ nodes
]

{ #category : #counting }
PrfMethodProfiler >> numberOfCallsFrom: aMethod [

	aMethod ifNil: [ ^ unknownNode totalNumberOfCalls ].
	^ (nodes keys select: [ :key |
		   key beginsWith: aMethod unproxifiedMethod printString , '#' ])
		  ifNotEmpty: [ :keys |
			  (keys collect: [ :key | (nodes at: key) totalNumberOfCalls ]) sum ]
		  ifEmpty: [ 0 ]
]

{ #category : #counting }
PrfMethodProfiler >> numberOfCallsFrom: firstMethod to: secondMethod [

	| fromNodes toNodes result |
	firstMethod ifNil: [ fromNodes := { unknownNode } ] ifNotNil: [
		fromNodes := (nodes keys select: [ :key |
			              key beginsWith:
				              firstMethod unproxifiedMethod printString , '#' ])
			             collect: [ :key | nodes at: key ] ].

	toNodes := (nodes keys select: [ :key |
		            key beginsWith:
			            secondMethod unproxifiedMethod printString , '#' ])
		           collect: [ :key | nodes at: key ].

	result := 0.
	fromNodes do: [ :fromNode |  toNodes do: [ :toNode |
			result := result + (fromNode numberOfCallsTo: toNode) ] ].
	^result
]

{ #category : #counting }
PrfMethodProfiler >> numberOfCallsTo: aMethod [

	^ (nodes keys select: [ :key |
		   key beginsWith: aMethod unproxifiedMethod printString , '#' ])
		  ifNotEmpty: [ :keys |
		  (keys collect: [ :key | (nodes at: key) timesCalled ]) sum ]
		  ifEmpty: [ 0 ]
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
