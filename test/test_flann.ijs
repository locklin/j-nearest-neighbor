load'tables/csv'
load'flann.ijs'
loc=. 3 : '> (4!:4 <''y'') { 4!:3 $0'  
PATH=. getpath_j_ loc''
DATA=. PATH,'data/'
aa=. ".>readcsv DATA,'p53.csv'
test =. 0.01 + (2,3){aa 
test1 =. 0.01 + 5{aa 
tree=. conew 'jflann'
create__tree (aa + 2.2-2.2)
search__tree test1;1
search__tree test;2
search__tree test;3
paramsof__tree ''
destroy__tree ''
tree=. conew 'jflann'
create__tree aa
radsearch__tree test1;2;5
destroy__tree ''

allsearch aa;test1

".>readcsv DATA,'p79.csv'
".>readcsv DATA,'p53.csv'


floatrand=: ?. @$ % ] - 1:
dataset=: 1E6 10 $ 10e3 floatrand 100 
test=: 1E3 10 $ 1e4 floatrand 100
tree=. conew 'jflann'
create__tree dataset
search__tree (1{test);1
search__tree test;2
search__tree test;3
radsearch__tree (1{test);1; 0.1
allsearch dataset;((8,4,3){test);10
destroy__tree''

NB. all kinds of problems apparent here.... maybe it is time to go back to libANN

NB. ##############################

Note 'To run flann tests:'
  load 'flann'
  load 'flann/test/test_flann'
)

NB. row x on y datafile
nntest=: 4 : 0
 a=. ".>readcsv DATA,y
 t=. buildtree a
 test =. x{a
 out =. searchtree t;test;1
 choptree t
 nn=. |: >0{out
 dist=. >1{out
 NB. assert. nn = x
out
)
