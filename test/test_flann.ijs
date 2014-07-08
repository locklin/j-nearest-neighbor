load'tables/csv'
load'flann.ijs'
NB. ##############################

Note 'To run flann tests:'
  load 'flann.ijs'
  load 'test/test_flann.ijs'
)

loc=. 3 : '> (4!:4 <''y'') { 4!:3 $0'  
PATH=: getpath_j_ loc''
DATA=: PATH,'../data/'
aa=: ".>readcsv DATA,'p53.csv'
test =: 0.01 + (2,3){aa 
test1 =: 0.01 + 5{aa 

testp53=: 3 : 0
  tree=. conew 'jflann'
  create__tree (aa + 2.2-2.2)
  assert. 5=>{.search__tree test1;1
  assert. (3,9)={:>{.search__tree test;2
  assert. (2,8,0)={.>{.search__tree test;3
  assert. 0.0003={.{.>{:search__tree test;3
  assert. 32=>{:8{paramsof__tree '' 
  destroy__tree ''
)

testparams=: 3 : 0
  tree=. conew 'jflann'
  ((<4) setparams <'typetree') create__tree (aa + 2.2 -2.2)
  assert. 4=>{:{. paramsof__tree''
  destroy__tree ''
)

testrads=: 3 : 0
  tree=. conew 'jflann'
  create__tree aa + 2.2-2.2
  assert. (5,_1)= {. >{.radsearch__tree test1;2;5
  assert. 2={.>{.radsearch__tree test;1;5
  destroy__tree ''
  assert. (5,6,9)={.>{.allsearch aa;test1;3
)


testbig=: 3 : 0
  floatrand=: ?. @$ % ] - 1:
  dataset=: 1E6 10 $ 10e3 floatrand 100 
  test=: 1E3 10 $ 1e4 floatrand 100
  tree=. conew 'jflann'
  create__tree dataset
  assert. 622001=>{.search__tree (1{test);1
  assert. (1000,2) =$>{. search__tree test;2
  assert. 622001=>{.radsearch__tree (1{test);1; 0.1
  destroy__tree''
  assert. 42008={.{.>{.allsearch dataset;((8,4,3){test);10
)

smoutput testp53''
smoutput testrads''
smoutput testbig''
smoutput testparams''


NB. something like this for the other data sets....
NB. NB. row x on y datafile
NB. nntest=: 4 : 0
NB.  a=. ".>readcsv DATA,y
NB.  t=. buildtree a
NB.  test =. x{a
NB.  out =. searchtree t;test;1
NB.  choptree t
NB.  nn=. |: >0{out
NB.  dist=. >1{out
NB.  NB. assert. nn = x
NB. out
NB. )
