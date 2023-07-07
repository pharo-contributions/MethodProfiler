Class {
	#name : #PrfLiveNode,
	#superclass : #PrfNode,
	#instVars : [
		'nodeHash',
		'lastTimeEntered',
		'totalTime'
	],
	#category : #MethodProfiler
}

{ #category : #'method flow' }
PrfLiveNode >> enteringNode [
	lastTimeEntered := DateAndTime now
]

{ #category : #'method flow' }
PrfLiveNode >> exitingNode [
	"Manage the case of the root unknown node"
	lastTimeEntered ifNil: [ ^ self ].

	totalTime := totalTime + (DateAndTime now - lastTimeEntered).
	lastTimeEntered := nil 
]

{ #category : #initialization }
PrfLiveNode >> initialize [

	super initialize.
	totalTime := 0 seconds
]

{ #category : #accessing }
PrfLiveNode >> nodeHash [

	^ nodeHash
]

{ #category : #accessing }
PrfLiveNode >> nodeHash: anObject [

	nodeHash := anObject
]

{ #category : #accessing }
PrfLiveNode >> totalTime [

	^ totalTime
]
