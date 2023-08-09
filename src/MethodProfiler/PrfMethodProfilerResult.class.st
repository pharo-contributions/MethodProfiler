Class {
	#name : #PrfMethodProfilerResult,
	#superclass : #Object,
	#instVars : [
		'methods',
		'nodes',
		'rootNodes',
		'mainProcess',
		'rootGraphNodes',
		'graphNodes'
	],
	#category : #MethodProfiler
}

{ #category : #accessing }
PrfMethodProfilerResult >> buildCallGraph [
	| compactionDictionary |
	
	graphNodes := Dictionary new.
	rootGraphNodes := IdentityDictionary new.
	compactionDictionary := Dictionary new.

	methods do: [ :method |
		|oldNodes replacementNode|
		oldNodes := self nodesForMethod: method.
		replacementNode := PrfCompactMethodNode
				 forMethod: method
				 withResult: self
				 compact: oldNodes.
		graphNodes at: method name put: replacementNode.
		oldNodes do: [ :node | compactionDictionary at: node put: replacementNode ] ].

	rootNodes do: [ :root |
		| newRoot |
		newRoot := root copy.
		graphNodes
			at: 'Root#' , newRoot process identityHash hex
			put: newRoot.
		rootGraphNodes at: newRoot process put: newRoot ].
	
	graphNodes do: [ :node | node curateCallsAfterCompaction: compactionDictionary ]
]

{ #category : #ui }
PrfMethodProfilerResult >> callGraph [

	| c edges label roassalEdges roassalNodes minEdgeValue maxEdgeValue allNodes stepping layout |

	minEdgeValue := nil.
	maxEdgeValue := nil.
	
	allNodes := self graphRootNode allChildrenAndSelf.

	edges := Set new.
	allNodes do: [ :node |
		node methodCalls do: [ :childNode |
			edges add: node -> childNode ] ].

	c := RSCanvas new.

	roassalNodes := (allNodes collect: [ :model |
						
		               model -> (RSEllipse new
			                labeled;
			                draggable;
			                model: model;
			                yourself) ]) asDictionary.

	roassalEdges := edges collect: [ :edge |
		         | edgeValue |
		         edgeValue := edge key numberOfCallsTo: edge value.
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
			         from: (roassalNodes at: edge key);
			         to: (roassalNodes at: edge value);
			         yourself ].

	c
		addAll: roassalNodes values;
		addAll: roassalEdges.
		
	RSNormalizer size
		from: 10;
		to: 100; 
		shapes: roassalNodes values;
		normalize: #timesCalled .
	RSNormalizer color
		from: (Color blue muchDarker alpha: 0.75);
		to: (Color red alpha: 0.75);
		shapes: roassalNodes values;
		normalize: #timesCalled.
	RSNormalizer width
		from: 0.5;
		to: 4;
		shapes: roassalEdges;
		normalize: #yourself.
	
	(roassalNodes at: self graphRootNode) size: 50; color: (Color green alpha: 0.75).

	RSForceBasedLayout new
		length: 100;
		charge: -1000;
		on: roassalNodes values.

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
		weight: [ :f | f model totalTime asMicroseconds ];
		explore: self rootNode
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

{ #category : #accessing }
PrfMethodProfilerResult >> graphRootNode [
	
	^self graphRootNodeForProcess: mainProcess
]

{ #category : #counting }
PrfMethodProfilerResult >> graphRootNodeForProcess: aProcess [

	^ rootGraphNodes at: aProcess ifPresent: [ :node | node ]
]

{ #category : #accessing }
PrfMethodProfilerResult >> graphRootNodes [

	^ rootNodes
]

{ #category : #initialization }
PrfMethodProfilerResult >> initialize [ 
	nodes := Dictionary new.
	rootNodes := IdentityDictionary new.
	graphNodes := Dictionary new.
	rootGraphNodes := IdentityDictionary new.
]

{ #category : #counting }
PrfMethodProfilerResult >> localRootNode [

	^self rootNodeForProcess: Processor activeProcess
]

{ #category : #accessing }
PrfMethodProfilerResult >> mainProcess: anObject [

	mainProcess := anObject
]

{ #category : #accessing }
PrfMethodProfilerResult >> methods: anObject [

	methods := anObject
]

{ #category : #installation }
PrfMethodProfilerResult >> nodeForMethod: aMethod withPrecedingNode: aNode [

	| uniqueNodeName |
	uniqueNodeName := aMethod name , '#' , aNode nodeHash hex.
	^ nodes
		  at: uniqueNodeName
		  ifPresent: [ :node | node ]
		  ifAbsentPut: [
			  PrfTreeMethodNode 
				  forMethod: aMethod
				  withResult: self
				  withHash: (SHA1 hashMessage: uniqueNodeName) ]
]

{ #category : #accessing }
PrfMethodProfilerResult >> nodes [

	^ nodes
]

{ #category : #counting }
PrfMethodProfilerResult >> nodesForMethod: aMethod [

	^ (nodes keys select: [ :key |
		   key beginsWith: aMethod unproxifiedMethod name , '#' ]) collect: [
		  :key | nodes at: key ]
]

{ #category : #counting }
PrfMethodProfilerResult >> numberOfCallsFrom: aMethod [

	aMethod ifNil: [ ^ self graphRootNode totalNumberOfCalls ].

	^ graphNodes
		  at: aMethod name
		  ifPresent: [ :node | node totalNumberOfCalls ]
		  ifAbsent: [ 0 ]
]

{ #category : #counting }
PrfMethodProfilerResult >> numberOfCallsFrom: firstMethod to: secondMethod [

	| fromNode toNode |
	firstMethod
		ifNil: [ fromNode := self graphRootNode. ]
		ifNotNil: [
		fromNode := graphNodes at: firstMethod name ifAbsent: [ ^ 0 ] ].

	toNode := graphNodes at: secondMethod name ifAbsent: [ ^ 0 ].


	^ fromNode numberOfCallsTo: toNode 
]

{ #category : #counting }
PrfMethodProfilerResult >> numberOfCallsTo: aMethod [

	aMethod ifNil: [ ^ self graphRootNode timesCalled ].

	^ graphNodes
		  at: aMethod name
		  ifPresent: [ :node | node timesCalled ]
		  ifAbsent: [ 0 ]
]

{ #category : #accessing }
PrfMethodProfilerResult >> rootNode [
	
	^self rootNodeForProcess: mainProcess
]

{ #category : #counting }
PrfMethodProfilerResult >> rootNodeForProcess: aProcess [

	| newNode uniqueNodeName |
	rootNodes at: aProcess ifPresent: [ :node | ^ node ].

	uniqueNodeName := 'Root#' , aProcess identityHash hex.

	newNode := PrfRootNode
		           forProcess: aProcess
		           withResult: self
		           withHash: (SHA1 hashMessage: uniqueNodeName).
	rootNodes at: aProcess put: newNode.
	nodes at: uniqueNodeName put: newNode.

	^ newNode
]

{ #category : #accessing }
PrfMethodProfilerResult >> rootNodes [

	^ rootNodes
]
