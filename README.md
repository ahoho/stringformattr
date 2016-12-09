# stringformattr
Dynamic String Formatting

This is a simple set of functions that attempt to emulate python-like string formatting. For example, in python, one can do the following:

```python
'the quick brown fox jump' + 'ed over the lazy dog'
# > 'the quick brown fox jumped over the lazy dog'

'SELECT {column} FROM {table}'.format(column = 'STUDENT_ID', table = 'STUDENTS')
# > 'SELECT STUDENT_ID FROM STUDENTS'
```
    
With this package, the same operations are available in R:
    
```R
'the quick brown fox jump' %p% 'ed over the lazy dog'

'SELECT {column} FROM {table}' %f% c('column' = 'STUDENT_ID', 'table' = 'STUDENTS')
```

Available on CRAN [here](https://cran.r-project.org/web/packages/stringformattr/index.html).
