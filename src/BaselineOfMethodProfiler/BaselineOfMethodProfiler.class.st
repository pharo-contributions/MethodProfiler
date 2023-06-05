Class {
	#name : #BaselineOfMethodProfiler,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodProfiler
}

{ #category : #baselines }
BaselineOfMethodProfiler >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: #MethodProxies
			with: [
				spec repository: 'github://pharo-contributions/MethodProxies/src' ];
			package: #MethodProfiler 
			with: [ spec requires: #MethodProxies ];
			package: #'MethodProfiler-Tests'
			with: [ spec requires: #MethodProfiler ].
			
			spec 
				group: #profiler 
				with: #(MethodProfiler);
				group: #tests
				with: #(default MethodProfiler-Tests);
				group: #default
				with: #(tests)
	]
]
