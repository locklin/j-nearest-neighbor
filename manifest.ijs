CAPTION=: 'KNN hooks and tools' 
VERSION=: '0.2'
FILES=: 0 : 0
flann.ijs
test/test_flann.ijs
)

PLATFORMS=: 0 : 0
'linux'
NB. should work anywhere you can get libFLANN, aka win and darwin
)

DEPENDS=: 0 : 0
dsv/csv
)

DESCRIPTION=: 0 : 0
KNN library hooks. Presently just libflann, which is available here:
http://www.cs.ubc.ca/research/flann/
At some point, I have to decide whether or not to keep this package simple, or
to distribute the vector quantization and kernel regression tools I am using it with.
)
