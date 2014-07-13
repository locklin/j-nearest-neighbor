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
  dataset=: ". IF64{::'1e3 10 $?.1e4$0';'1e6 10 $ ?.10e7$0'
  testdx=: ".IF64{:: '1e2?.1e3';'1e3 ?. 1e6'
  test=: testdx{dataset
  tree=. conew 'jflann'
  create__tree dataset
  assert. testdx = ,>{.search__tree test;1
  destroy__tree''
  assert. testdx = ,>{.allsearch dataset;test;1  
)

smoutput testp53''
smoutput testrads''
smoutput testbig''
smoutput testparams''

NB. manually tested savetree; it seems to work.


NB. something like this for the other data sets....
NB. NB. row x on y datafile
nntest=: 4 : 0
 a=. ".>readcsv DATA,y
 t=. conew 'jflann'
 create__t a
 test =. x{a
 out =. searchtree t;test;1
 choptree t
 nn=. |: >0{out
 dist=. >1{out
 assert. nn = x
 assert. dist = 
out
)
