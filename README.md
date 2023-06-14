# MethodProfiler
![CI](https://github.com/BastouP411/MethodProfiler/actions/workflows/ci.yml/badge.svg)
![Pharo version](https://img.shields.io/badge/Pharo-12-%23aac9ff.svg)](https://pharo.org/download)


## How to install it

```smalltalk
EpMonitor disableDuring: [
	Metacello new
		baseline: 'MethodProfiler';
		repository: 'github://BastouP411/MethodProfiler:main';
		load ].
```
