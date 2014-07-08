coclass 'jflann'
require'files'

typeof=: 3!:0 
cd=: 15!:0

NB. nearest neighbors using FLANN library
NB. FLANN and documentation can be obtained at the following link:
NB. http://www.cs.ubc.ca/research/flann/
NB. assumes flann-1.8.4, installed in /usr/local/lib/libflann.so

NB. namespace definitions
allsearch_z_ =: allsearch_jflann_
setparams_z_ =: setparams_jflann_
kmeancent_z_ =: kmeans_jflann_
NB. FLANNPARAMS_z_ =: DEFAULT_jflann_
NB. FLANNPARAMNAMES_z_ =: PARAMNAMES_jflann_

NB. path of libflann
3 : 0''
if. (UNAME-:'Linux') *. IF64 do.
  LIBFLANN=: '/usr/local/lib/libflann.so'  
elseif. UNAME-:'Darwin' do.
  LIBFLANN=: '"',~'"',jpath '~addons/math/flann/libflann.dylib'
elseif. UNAME-: 'Win' do.
  'platform not supported' 13!:8[10
elseif. do.
  NB. for eventual package inclusion LIBFLANN=: '"',~'"',jpath '~addons/math/flann/libflann.so', (IF64#'_64'), '.dll'
end.
)

NB.###########################################
NB. Object system for flann
NB. ###########################################

NB. *<(setparams)> create__tree dataset
NB. -creates the tree, after it has been initialized with conew 'jflann'
create=: 3 : 0
 (>setflannparams >DEFAULT) create y
: 
 PARAMS=: x
 speedup =. 1 fc 2.2-2.2
 if. 2=(typeof y) do.
   NB. load some data from a premade tree
   DATASET=: (". freadr y,'data') + 2.2-2.2
   filename=. y,'tree'
   'ROWS COLS'=: $ DATASET
   cmd=. LIBFLANN, ' flann_load_index_double x *c *d i i'
   TREE=: 0 pick cmd cd filename;DATASET;ROWS;COLS
   smoutput 'loaded a tree here'
 else.
   DATASET =: y + 2.2-2.2 
   'ROWS COLS' =: $ DATASET
   cmd=. LIBFLANN, ' flann_build_index_double * *d i i *f x'
   TREE=: 0 pick cmd cd DATASET;ROWS;COLS;speedup;PARAMS
 end.
)

destroy=: 3 : 0
 cmd=. LIBFLANN, ' flann_free_index_double i x x'
 0 pick cmd cd TREE;PARAMS
 TREE=: ''
 PARAMS=: ''
NB.  codestroy
)

NB. * paramsof__tree ''
NB. -dumps the tree parameters
paramsof=: 3 : 0
 PARAMNAMES ,. (getflannparams PARAMS)
)

NB. *search__tree sdata;nn
NB. -searches the tree and returns boxed arrays with index of near neighbors 
NB. -and distances
search=: 3 : 0
 'sdata nn' =. y
 trows =. #,:"1 sdata
 if. nn>0 do. 
  index =. 0*i.trows,nn
  dists =. _<. (trows,nn) $ 0 NB. trick for making doubles 
  cmd =. LIBFLANN, ' flann_find_nearest_neighbors_index_double i x *d i *i *d i x'
  cmd cd TREE;sdata;trows;index;dists;nn;PARAMS
  index;dists
 else.
  smoutput 'error, must be 1 or more nns'
 end. 
)

NB. *radsearch__tree sdata;nn;radius
NB. -searches the tree and returns boxed arrays with index of near neighbors 
NB. -and distances within radius
radsearch =: 3 : 0
 'point mnn rad'=.y
 trows=. #,:"1 point
 index=. 0*i.trows,mnn
 dists=. _<. (trows,mnn) $ 0 NB. trick for making doubles 
 cmd=. LIBFLANN,' flann_radius_search_double i x *d *i *d i f x'
 cmd cd TREE;point;index;dists;mnn;rad;PARAMS
 index;dists
)

NB. *dump__tree 'dirname'
NB. -dumps the tree and dataset in directory 'dirname'
dump =: 3 : 0
 1!:5<y
 filename=. y,'tree'
 cmd=. LIBFLANN, ' flann_save_index_double i x *c'
 0 pick cmd cd TREE;filename
 (": DATASET) fwrites y,'data'    NB. Do this better later
)


NB. The params struct looks like this:
NB.    enum flann_algorithm_t algorithm; /* the algorithm to use 0=linear, 1=kdtree, 2=mixed, 3=*/
NB. enum flann_algorithm_t
NB. {
NB.     FLANN_INDEX_LINEAR 			= 0,
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

PARAMNAMES=: 'typetree';'checks';'eps';'sorted';'maxnbhs';'cores';'trees';'mxleaf';'branching';'iterations';'centers';'cbdx';'prec';'bwt';'mwt';'sfrac';'tnum';'ksz';'mpl';'loglevel';'seed'

NB. * 2;4 setparams 'typetree';'cores'
NB. -returns a pointer to a struct which feeds the flann library with configuration
NB. -parameters. See the above values for a sketch of what they mean, or the
NB. -flann manual; 
NB. -http://www.cs.ubc.ca/research/flann/uploads/FLANN/flann_manual-1.8.4.pdf
setparams=: 4 : 0
 tags=.y
 vals=. x
 ui =. PARAMNAMES i. (I. tags e. PARAMNAMES){tags
 setflannparams (vals ui}DEFAULT)
)

NB. 'algo checks eps sorted maxnb cores trees mxleaf bra iter clst cbdx tp bwt mwt sf nhsh kl mp verbos seed'=.y
getflannparams=: 3 : 0
 mymem=. >y
 algo=. _2 ic memr mymem,0 4 2 NB. algo
 checks=. _2 ic memr mymem, 4 4 2 NB. checks
 eps=. _1 fc memr mymem, 8 4 2 NB. eps
 sorted=._2 ic memr mymem, 12 4 2 NB. sorted
 maxnb =. _2 ic memr mymem, 16 4 2 NB. mxnb for rad search
 cores =. _2 ic memr mymem, 20 4 2 NB. cores
 trees =. _2 ic memr mymem, 24 4 2 NB. trees
 mxleaf =. _2 ic memr mymem, 28 4 2 NB. max leaf
 bra =. _2 ic memr mymem, 32 4 2 NB. branching for kmeans
 iter =. _2 ic memr mymem, 36 4 2 NB. iterations
 clst =. _2 ic memr mymem, 40 4 2 NB. enum clusters init
 cbdx =. _1 fc memr mymem, 44 4 2 NB. cb index for kmeans
 tp =. _1 fc memr mymem, 48 4 2 NB. -1, or target precision
 bwt =. _1 fc memr mymem, 52 4 2 NB. build tree weight factor
 mwt =. _1 fc memr mymem, 56 4 2 NB. index memory weight factor
 sf =. _1 fc memr mymem, 60 4 2 NB. sample fraction for autotuning
 nhsh =. _2 ic memr mymem, 64 4 2 NB. num hash tables
 kl =. _2 ic memr mymem, 68 4 2 NB. keylength
 mp =. _2 ic memr mymem, 72 4 2 NB. 0 mprobe level
 verbos =. _2 ic memr mymem, 76 4 2 NB. long verbosity
 seed =. _3 ic memr mymem, 80 8 2 NB. long randseed
 algo;checks;eps;sorted;maxnb;cores;trees;mxleaf;bra;iter;clst;cbdx;tp;bwt;mwt;sf;nhsh;kl;mp;verbos;seed
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

NB. this should create the right struct for 1.7 version of flann, but on my
NB. machine this library doesn't work at all
setflannparams7=: 3 : 0
 'algo checks eps sorted maxnb cores trees mxleaf bra iter clst cbdx tp bwt mwt sf nhsh kl mp verbos seed'=.y
 mymem=. mema 76
 (2 ic algo) memw mymem,0 4 2 NB. algo
 (2 ic checks) memw mymem, 4 4 2 NB. checks
 (1 fc cbdx) memw mymem, 8 4 2 NB. cb_index 
 (1 fc eps) memw mymem, 12 4 2 NB. eps
 (2 ic trees) memw mymem, 16 4 2 NB. trees
 (2 ic mxleaf) memw mymem, 20 4 2 NB. max_leaf
 (2 ic bra) memw mymem, 24 4 2      NB. branching factor for kmeans tree
 (2 ic iter) memw mymem, 28 4 2       NB. iterations
 (2 ic clst) memw mymem, 32 4 2 NB. enum clusters init
 (1 fc tp) memw mymem, 36 4 2  NB. -1, or target precision
 (1 fc 0.01) memw mymem, 40 4 2 NB. build tree weight factor why this not set?
 (1 fc mwt) memw mymem, 44 4 2 NB. index memory weight factor	 
 (1 fc sf) memw mymem, 48 4 2 NB. sample fraction for autotuning 
 (2 ic nhsh) memw mymem, 52 4 2 NB. num hash tables
 (2 ic kl) memw mymem, 56 4 2 NB. keylength
 (2 ic mp) memw mymem, 60 4 2 NB. 0 mprobe level
 (2 ic verbos) memw mymem, 64 4 2 NB. long verbosity
 (3 ic seed) memw mymem, 68 8 2 NB. long randseed
 <mymem
)


NB. *(flannparams) allsearch data;testset;nn
NB. -dyad version takes output of setparams. This does a near neighbor search
NB. -without building a tree and keeping it around; for batch searches where
NB. -the testset is available all at once.
allsearch=: 3 : 0
 params=.>setflannparams >DEFAULT
 params allsearch y
:
 'dataset testset nn'=. y  
 params=.> x
 'rows cols'=. $ dataset
 trows=. # ,:"1 testset
 index=. 0*i.trows,nn
 dists=. _<. (trows,nn) $ 0 NB. trick for making doubles 
 cmd=. LIBFLANN, ' flann_find_nearest_neighbors x *f i i *f i *i *f i x'
 cmd cd dataset;rows;cols;testset;trows;index;dists;nn;params
 index;dists
)



NB. untested, but appears to do something
kmeans=: 3 : 0
 params=.>setflannparams >DEFAULT
 params kmeans y
:
 'params'=.x
 'data cent'=.y
 'rows cols'=. $ data
 result =. _<. (cent,cols) $ 0
 cmd=. LIBFLANN, ' flann_compute_cluster_centers_double i *d i i i *d x'
 cmd cd data;rows;cols;cent;result;params
 result
)

