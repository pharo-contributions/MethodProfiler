Class {
	#name : #PrfMethodNode,
	#superclass : #Object,
	#instVars : [
		'profiler',
		'method',
		'methodCalls',
		'timesCalled',
		'nodeHash'
	],
	#category : #MethodProfiler
}

{ #category : #creation }
PrfMethodNode class >> forMethod: aMethod withProfiler: aProfiler [

	| node |
	node := PrfMethodNode new.
	node method: aMethod.
	node profiler: aProfiler.
	^ node
]

{ #category : #creation }
PrfMethodNode class >> forMethod: aMethod withProfiler: aProfiler withHash: aString [

	| node |
	node := PrfMethodNode new.
	node method: aMethod.
	node profiler: aProfiler.
	node nodeHash: aString.
	^ node
]

{ #category : #accessing }
PrfMethodNode >> accumulatedCalls [

	^ self timesCalled + (self methodCalls sum: [ :e | e accumulatedCalls ])
]

{ #category : #accessing }
PrfMethodNode >> addCall [
	timesCalled := timesCalled + 1.
]

{ #category : #accessing }
PrfMethodNode >> addCallTo: aMethod [
	methodCalls add: aMethod
]

{ #category : #accessing }
PrfMethodNode >> allChildren [
	
	^ methodCalls asSet asOrderedCollection flatCollect: [ :child | {child} , child allChildren ]
]

{ #category : #ui }
PrfMethodNode >> drawNeighborhoodGraph [
	<inspectorPresentationOrder: 1 title: 'Neighborhood Graph'>
	^ SpRoassal3InspectorPresenter new canvas: self neighborhoodGraph yourself
]

{ #category : #testing }
PrfMethodNode >> hasChildren [

	^ methodCalls notEmpty
]

{ #category : #initialization }
PrfMethodNode >> initialize [ 
	methodCalls := Bag new.
	timesCalled := 0
]

{ #category : #accessing }
PrfMethodNode >> method [

	^ method
]

{ #category : #accessing }
PrfMethodNode >> method: anObject [

	method := anObject
]

{ #category : #accessing }
PrfMethodNode >> methodCalls [

	^ methodCalls
]

{ #category : #ui }
PrfMethodNode >> neighborhoodGraph [

	| c edges label localNodes lines graphNodes stepping layout minEdgeValue maxEdgeValue |
	minEdgeValue := nil.
	maxEdgeValue := nil.

	localNodes := (profiler nodes asArray copyWith: (profiler unknownNode)) select: [ :node |
		              (self = node) or: ((node numberOfCallsTo: method) + (self numberOfCallsTo: (node method)) > 0) ].

	edges := Set new.
	
	localNodes do: [ :node |
		((node numberOfCallsTo: method) > 0) ifTrue: [ edges add: (node -> self) ] ].
	
	localNodes do: [ :node |
		((self numberOfCallsTo: (node method)) > 0) ifTrue: [ edges add: (self -> node) ] ].

	c := RSCanvas new.

	graphNodes := (localNodes collect: [ :model |
						|assocication|
		            	assocication := (model -> (RSEllipse new
			                labeled;
			                draggable;
			                model: model;
			                yourself)).
						(model = self) ifTrue: [ assocication value borderColor: (Color green alpha: 0.75) ].
						assocication  ]) asDictionary.

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
	
	graphNodes at: (profiler unknownNode) ifPresent: [ :root | root size: 50; color: (Color green alpha: 0.75). ].

	stepping := RSForceLayoutSteppingInteraction new.

	(layout := stepping layout)
		length: 100;
		charge: -1000.
	c @ stepping.
	c @ RSCanvasController.
	^ c
]

{ #category : #accessing }
PrfMethodNode >> nodeHash [

	^ nodeHash
]

{ #category : #accessing }
PrfMethodNode >> nodeHash: anObject [

	nodeHash := anObject
]

{ #category : #accessing }
PrfMethodNode >> numberOfCallsTo: aMethod [
	aMethod ifNil: [ ^0 ] ifNotNil: [ ^methodCalls occurrencesOf: (aMethod unproxifiedMethod ) ].
]

{ #category : #converting }
PrfMethodNode >> printString [  
	method ifNil: [ ^'Root' ].
	^method printString
]

{ #category : #accessing }
PrfMethodNode >> profiler [

	^ profiler
]

{ #category : #accessing }
PrfMethodNode >> profiler: anObject [

	profiler := anObject
]

{ #category : #accessing }
PrfMethodNode >> removeAllCalls [
	methodCalls removeAll.
	timesCalled := 0
]

{ #category : #accessing }
PrfMethodNode >> timesCalled [

	^ timesCalled
]

{ #category : #accessing }
PrfMethodNode >> totalNumberOfCalls [
	^ methodCalls size.
]
