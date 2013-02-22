coclass 'jflann'

NB. remaining issues:
NB. cant set branch weight except manually
NB. searching on the pointer doesn't work
NB. may be possible to use memr or coinsert

flannparamset_z_ =: setflannparams_jflann_
NB. buildtree_z_=: buildtree_jflann_
NB. searchtree_z_=: searchtree_jflann_ 
NB. treedestroy_z_ =: flanndestroy_jflann_
allsearch_z_ =: allsearch_jflann_
flannparams_z_ =: DEFAULT_jflann_
flannparamnames_z_ =: PARAMNAMES_jflann_
setparams_z_ =: setparams_jflann_
tests_z_ =: buildandsearch_jflann_

3 : 0''
if. UNAME-:'Linux' do.
  LIBFLANN=: jpath'~temp/libflann.so'
  NB. should find it in /usr/local/lib/
elseif. UNAME-:'Darwin' do.
  LIBFLANN=: '"',~'"',jpath '~addons/math/flann/libflann.dylib'
elseif. do.
  LIBFLANN=: '"',~'"',jpath '~addons/math/flann/libflann.so', (IF64#'_64'), '.dll'
end.
)


cd=: 15!:0


NB. The params struct looks like this:
NB.    enum flann_algorithm_t algorithm; /* the algorithm to use 0=linear, 1=kdtree, 2=mixed, 3=*/
NB. enum flann_algorithm_t
NB. {
NB.     FLANN_INDEX_LINEAR   		= 0,
NB.     FLANN_INDEX_KDTREE 			= 1,
NB.     FLANN_INDEX_KMEANS 			= 2,
NB.     FLANN_INDEX_COMPOSITE 		= 3,
NB.     FLANN_INDEX_KDTREE_SINGLE 	= 4,
NB.     FLANN_INDEX_HIERARCHICAL 	= 5,
NB.     FLANN_INDEX_LSH 			= 6, doesn't work right now
NB. #ifdef FLANN_USE_CUDA
NB.     FLANN_INDEX_KDTREE_CUDA 	= 7, obviously won't work
NB. #endif
NB.     FLANN_INDEX_SAVED 			= 254, unsupported
NB.     FLANN_INDEX_AUTOTUNED 		= 255, untested
NB. };
NB.     int checks;                /* how many leafs (features) to check in one search */
NB.     float eps;     /* eps parameter for eps-knn search */
NB.     int sorted;     /* indicates if results returned by radius search should be sorted or not */
NB.     int max_neighbors;  /* limits the maximum number of neighbors should be returned by radius search */
NB.     int cores;      /* number of paralel cores to use for searching */
NB.     int trees;                 /* number of randomized trees to use (for kdtree) */
NB.     int leaf_max_size;
NB.     int branching;             /* branching factor (for kmeans tree) */
NB.     int iterations;            /* max iterations to perform in one kmeans cluetering (kmeans tree) */
NB.     enum flann_centers_init_t centers_init;  /* algorithm used for picking the initial cluster centers for kmeans tree */
NB.     float cb_index;            /* cluster boundary index. Used when searching the kmeans tree */
NB.     float target_precision;    /* precision desired (used for autotuning, -1 otherwise) */
NB.     float build_weight;        /* build tree time weighting factor */
NB.     float memory_weight;       /* index memory weigthing factor */
NB.     float sample_fraction;     /* what fraction of the dataset to use for autotuning */
NB.     unsigned int table_number_; /** The number of hash tables to use */
NB.     unsigned int key_size_;     /** The length of the key in the hash tables */
NB.     unsigned int multi_probe_level_; /** Number of levels to use in multi-probe LSH, 0 for standard LSH */
NB.     enum flann_log_level_t log_level;    /* determines the verbosity of each flann function */
NB.     long random_seed;            /* random seed to use */
NB. };


DEFAULT =: 1;_1;0.01;1;_1;1;1;1;32;11;0;_1;0.9;0.01;0;0.1;12;20;0;5;1	
NB. this needs some kind of associative array, or I'm going to lose
NB. my marbles -look at primitives in the add on to see how it is done

PARAMNAMES=: 'typetree';'checks';'eps';'sorted';'maxnbhs';'cores';'trees';'mxleaf';'branching';'iterations';'centers';'cbdx';'prec';'bwt';'mwt';'sfrac';'loglevel';'seed'

NB. returns a pointer to the flannparamstruct
setparams=: 4 : 0
tags=.y
vals=. x
tmpdef=. DEFAULT
u =. I. tags e. PARAMNAMES
ui =. PARAMNAMES i. (I. tags e. PARAMNAMES){tags
setflannparams (vals ui}DEFAULT)
)

   
setflannparams=: 3 : 0
'algo checks eps sorted maxnb cores trees mxleaf bra iter clst cbdx tp bwt mwt sf nhsh kl mp verbos seed'=.y
mymem=. mema 88
(2 ic algo) memw mymem,0 4 2 NB. algo
(2 ic checks) memw mymem, 4 4 2 NB. checks
(1 fc eps) memw mymem, 8 4 2 NB. eps
(2 ic sorted) memw mymem, 12 4 2 NB. sorted
(2 ic maxnb) memw mymem, 16 4 2 NB. mxnb for rad search
(2 ic cores) memw mymem, 20 4 2 NB. cores
(2 ic trees) memw mymem, 24 4 2 NB. trees
(2 ic mxleaf) memw mymem, 28 4 2 NB. max leaf
(2 ic bra) memw mymem, 32 4 2 NB. branching for kmeans
(2 ic iter) memw mymem, 36 4 2 NB. iterations
(2 ic clst) memw mymem, 40 4 2 NB. enum clusters init
(1 fc cbdx) memw mymem, 44 4 2 NB. cb index for kmeans
(1 fc tp) memw mymem, 48 4 2 NB. -1, or target precision
(1 fc 0.01) memw mymem, 52 4 2 NB. build tree weight factor why this not set?
(1 fc mwt) memw mymem, 56 4 2 NB. index memory weight factor
(1 fc sf) memw mymem, 60 4 2 NB. sample fraction for autotuning
(2 ic nhsh) memw mymem, 64 4 2 NB. num hash tables
(2 ic kl) memw mymem, 68 4 2 NB. keylength
(2 ic mp) memw mymem, 72 4 2 NB. 0 mprobe level
(2 ic verbos) memw mymem, 76 4 2 NB. long verbosity
(3 ic seed) memw mymem, 80 8 2 NB. long randseed
<mymem
)



getflannparams=: 3 : 0
NB. 'algo checks eps sorted maxnb cores trees mxleaf bra iter clst cbdx tp bwt mwt sf nhsh kl mp verbos seed'=.y
mymem=: >y
algo=: _2 ic memr mymem,0 4 2 NB. algo
checks=: _2 ic memr mymem, 4 4 2 NB. checks
eps=: _1 fc memr mymem, 8 4 2 NB. eps
sorted=:_2 ic memr mymem, 12 4 2 NB. sorted
maxnb =: _2 ic memr mymem, 16 4 2 NB. mxnb for rad search
cores =: _2 ic memr mymem, 20 4 2 NB. cores
trees =: _2 ic memr mymem, 24 4 2 NB. trees
mxleaf =: _2 ic memr mymem, 28 4 2 NB. max leaf
bra =: _2 ic memr mymem, 32 4 2 NB. branching for kmeans
iter =: _2 ic memr mymem, 36 4 2 NB. iterations
clst =: _2 ic memr mymem, 40 4 2 NB. enum clusters init
cbdx =: _1 fc memr mymem, 44 4 2 NB. cb index for kmeans
tp =: _1 fc memr mymem, 48 4 2 NB. -1, or target precision
bwt =: _1 fc memr mymem, 52 4 2 NB. build tree weight factor
mwt =: _1 fc memr mymem, 56 4 2 NB. index memory weight factor
sf =: _1 fc memr mymem, 60 4 2 NB. sample fraction for autotuning
nhsh =: _2 ic memr mymem, 64 4 2 NB. num hash tables
kl =: _2 ic memr mymem, 68 4 2 NB. keylength
mp =: _2 ic memr mymem, 72 4 2 NB. 0 mprobe level
verbos =: _2 ic memr mymem, 76 4 2 NB. long verbosity
seed =: _3 ic memr mymem, 80 8 2 NB. long randseed
algo;checks;eps;sorted;maxnb;cores;trees;mxleaf;bra;iter;clst;cbdx;tp;bwt;mwt;sf;nhsh;kl;mp;verbos;seed
)


buildtree=: 3 : 0
'dataset'=.y
'rows cols' =. $ dataset
params=.>setflannparams >DEFAULT
speedup =. 1 fc 2.2-2.2
cmd=. LIBFLANN, ' flann_build_index * *f i i *f x'
tree=. 0 pick cmd cd dataset;rows;cols;speedup;params
tree
)


NB. tree searchtree data nn
NB. returns boxed set of nns and dists
NB. I have no idea why this is wrong....
searchtree=: 3 : 0
'tree sdata nn'=.y
params=.>setflannparams >DEFAULT
trows=. #sdata
index=. 0*i.trows,nn
dists=. _<. (trows,nn) $ 0 NB. t
cmd=. LIBFLANN, ' flann_find_nearest_neighbors_index i x *f i *i *f i x'
cmd cd tree;sdata;trows;index;dists;nn;params
index;dists
)

NB. why this doesn't work is beyond my powers. It works in C. 
buildandsearch=: 3 : 0
'dataset testset nn'=. y  
tree=. buildtree dataset
searchtree tree;testset;nn
)


destroytree=: 3 : 0
NB. this deallocates memory managed by J I think; anyway, it crashes things
NB. flann_free_index(TREE,params)
)

NB. dyad version takes output of setparams
allsearch=: 3 : 0
params=.>setflannparams >DEFAULT
params allsearch y
:
'dataset testset nn'=. y  
params=.> x
'rows cols'=. $ dataset
trows=. #testset
index=. 0*i.trows,nn
dists=. _<. (trows,nn) $ 0 NB. trick for making doubles 
cmd=. LIBFLANN, ' flann_find_nearest_neighbors x *f i i *f i *i *f i x'
cmd cd dataset;rows;cols;testset;trows;index;dists;nn;params
index;dists
)


NB. remove this from final when everything else works
checkparams=: 3 : 0
pointrd =. LIBFLANN, ' scott_dump_params n x'
pointrd cd y
''
)
