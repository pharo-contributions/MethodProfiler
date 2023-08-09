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
			package: 'MethodProfiler' 
			with: [ spec requires: 'MethodProxies' ];
			package: 'MethodProfiler-Tests'
			with: [ spec requires: 'MethodProfiler' ].

		spec
			baseline: 'MethodProxies'
			with: [
			spec repository: 'github://pharo-contributions/MethodProxies/src' ].

		spec
			group: 'default' with: #( 'core' 'tests' );
			group: 'core' with: #( 'MethodProfiler' );
			group: 'tests' with: #( 'MethodProfiler-Tests' ) ].
		
	spec for: #'pharo11.x' do: [ 
		spec
			baseline: 'MethodProxies'
			with: [ spec repository: 'github://pharo-contributions/MethodProxies:pharo11' ]]
]
