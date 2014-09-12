NB. here are some examples, with documentation.
NB. more to be added later
require'math/flann'  NB. assumes you installed it via pacman
loc=. 3 : '> (4!:4 <''y'') { 4!:3 $0'  
PATH=: getpath_j_ loc''
DATA=: PATH,'/data/'
aa=: ".>readcsv DATA,'p53.csv'
$ aa NB. show the shape of aa
test =: 0.01 + (2,3){aa 
tree=. conew 'jflann'       NB. initialize object
create__tree (aa + 2.2-2.2) NB. make sure it's a float by using 2.2-2.2
search__tree test;1         NB. has the correct index
destroy__tree ''            NB. clean up
allsearch aa;test;3         NB. do one search without OO overhead

