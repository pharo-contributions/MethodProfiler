Class {
	#name : #PrfMethodProfilerResult,
	#superclass : #Object,
	#instVars : [
		'nodes',
		'rootNode'
	],
	#category : #MethodProfiler
}

{ #category : #ui }
PrfMethodProfilerResult >> callGraph [

	| c edges label localNodes lines graphNodes stepping layout minEdgeValue maxEdgeValue allNodes |
	minEdgeValue := nil.
	maxEdgeValue := nil.
	
	allNodes := rootNode allChildren.
	localNodes := (allNodes copyWith: rootNode) select: [ :node |
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
	
	(graphNodes at: rootNode) size: 50; color: (Color green alpha: 0.75).

	RSTreeLayout on: graphNodes values.

	c @ RSCanvasController.
	^ c
]

{ #category : #ui }
PrfMethodProfilerResult >> drawCallGraph [
 	<inspectorPresentationOrder: 10 title: 'Call Graph'>
	^ SpRoassal3InspectorPresenter new canvas: self callGraph yourself
]

{ #category : #ui }
PrfMethodProfilerResult >> drawFlameGraph [
	<inspectorPresentationOrder: 2 title: 'Flame Graph'>
	^ SpRoassal3InspectorPresenter new canvas: self flameGraph yourself
]

{ #category : #ui }
PrfMethodProfilerResult >> flameGraph [

	| builder |
	builder := RSFlameGraph new.
	builder boxShape.
	builder
		leafWeight: [ :f | f totalTime asMicroseconds ];
		explore: rootNode
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
PrfMethodProfilerResult >> initialize [ 
	nodes := Dictionary new.
	rootNode := PrfMethodNode forMethod: nil withProfiler: self withHash: (((SHA1 new hashMessage: '') copyFrom: 1 to: 4) hex ).
]

{ #category : #installation }
PrfMethodProfilerResult >> nodeForMethod: aMethod withPrecedingNode: aNode [

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
PrfMethodProfilerResult >> nodes [

	^ nodes
]

{ #category : #counting }
PrfMethodProfilerResult >> numberOfCallsFrom: aMethod [

	aMethod ifNil: [ ^ rootNode totalNumberOfCalls ].
	^ (nodes keys select: [ :key |
		   key beginsWith: aMethod unproxifiedMethod printString , '#' ])
		  ifNotEmpty: [ :keys |
			  (keys collect: [ :key | (nodes at: key) totalNumberOfCalls ]) sum ]
		  ifEmpty: [ 0 ]
]

{ #category : #counting }
PrfMethodProfilerResult >> numberOfCallsFrom: firstMethod to: secondMethod [

	| fromNodes toNodes result |
	firstMethod ifNil: [ fromNodes := { rootNode } ] ifNotNil: [
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
PrfMethodProfilerResult >> numberOfCallsTo: aMethod [

	^ (nodes keys select: [ :key |
		   key beginsWith: aMethod unproxifiedMethod printString , '#' ])
		  ifNotEmpty: [ :keys |
		  (keys collect: [ :key | (nodes at: key) timesCalled ]) sum ]
		  ifEmpty: [ 0 ]
]

{ #category : #accessing }
PrfMethodProfilerResult >> rootNode [

	^ rootNode
]
