Class {
	#name : #PrfMethodProfiler,
	#superclass : #Object,
	#instVars : [
		'methods',
		'runners',
		'lastRunner'
	],
	#classVars : [
		'FinalizationReg'
	],
	#category : #MethodProfiler
}

{ #category : #'class initialization' }
PrfMethodProfiler class >> initialize [ 
	FinalizationReg := FinalizationRegistry new. 
]

{ #category : #installation }
PrfMethodProfiler class >> shouldWrap: aMethod [

	| unproxifiedMethod |
	unproxifiedMethod := aMethod unproxifiedMethod.

	unproxifiedMethod isCompiledMethod ifFalse: [ ^ false ].

	unproxifiedMethod realClass package = self package ifTrue: [ ^ false ].

	(unproxifiedMethod pragmas noneSatisfy: [ :pragma |
		 pragma selector = #methodProxyCannotWrap ]) ifFalse: [ ^ false ].

	^ true
]

{ #category : #installation }
PrfMethodProfiler >> addClass: aClass [
	aClass methodDictionary do: [ :method | self addMethod: method unproxifiedMethod ].
	^self
]

{ #category : #installation }
PrfMethodProfiler >> addMethod: aMethod [

	| unproxifiedMethod |
	unproxifiedMethod := aMethod unproxifiedMethod.
	(self class shouldWrap: unproxifiedMethod) ifTrue: [
		methods add: unproxifiedMethod ].
	^ self
]

{ #category : #installation }
PrfMethodProfiler >> addPackage: aPackage [
	|classes|
	classes := aPackage definedClasses.
	classes do: [ :class | self addClass: class ].
	^self
]

{ #category : #'as yet unclassified' }
PrfMethodProfiler >> createRunner [

	lastRunner ifNotNil: [
		lastRunner isProfilingNow ifTrue: [
			^ Error signal: 'The last profiling is still running' ].
		lastRunner destroy ].

	lastRunner := PrfMethodProfilerRunner newForMethods: methods.
	runners add: lastRunner.
	^ lastRunner
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
	(methods includes: unproxifiedMethod)
		ifTrue: [ methods remove: unproxifiedMethod ].
	^ self
]

{ #category : #installation }
PrfMethodProfiler >> excludePackage: aPackage [
	|classes|
	classes := aPackage classes.
	classes do: [ :class | self excludeClass: class ].
	^self
]

{ #category : #'as yet unclassified' }
PrfMethodProfiler >> finalize [

	runners do: [ :runner | runner destroy ]
]

{ #category : #initialization }
PrfMethodProfiler >> initialize [

	FinalizationReg add: self.
	methods := Set new.
	runners := Set new
]

{ #category : #installation }
PrfMethodProfiler >> isProfilingMethod: aMethod [

	^ methods includes: aMethod unproxifiedMethod
]

{ #category : #accessing }
PrfMethodProfiler >> profile: aBlock [
	^self createRunner profile: aBlock
]
