Class {
	#name : #PrfCompactMethodNode,
	#superclass : #PrfNode,
	#traits : 'TPrfMethodNode',
	#classTraits : 'TPrfMethodNode classTrait',
	#category : #MethodProfiler
}

{ #category : #creation }
PrfCompactMethodNode class >> forMethod: aMethod withResult: aResultObject compact: aSet [

	| node |
	node := self new.
	node method: aMethod.
	node result: aResultObject.

	aSet do: [ :compactingNode |
		"node addTime: compactingNode totalTime." "Counting time is not as simple as that !"
		node addCalls: compactingNode timesCalled.
		compactingNode methodCalls doWithOccurrences: [
			:destinationNode
			:count |
			(aSet includes: destinationNode)
				ifTrue: [ node addCallTo: node times: count ]
				ifFalse: [ node addCallTo: destinationNode times: count ] ] ].

	^ node
]
