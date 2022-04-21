## Key Value Store

![image-20220421093848662](Lecture_8_Diagnostic_Quiz.assets/image-20220421093848662.png)

```python
def lens(prev=lambda x: 0):
    def put(k, v):
        def get(k2):
            if k == k2:
                return v
            else:
                return prev(k2)
        return get, lens(get)
    return put
```

## Storeroom

![image-20220421094231872](Lecture_8_Diagnostic_Quiz.assets/image-20220421094231872.png)

```python
def storeroom(helium, fn_even, fn_odd):
    evens_defined, odds_defined = False, False
    evens, odds = None, None
    while helium:
        helium, last = helium // 10, helium % 10
        if last % 2:
            if odds_defined == False:
                odds_defined = True
                odds = last
            else:
                odds = fn_odd(odds, last)
        else:
            if evens_defined == False:
                evens_defined = True
                evens = last
            else:
                evens = fn_odd(evens, last)
    return evens > odds
```

## Maximum subnumber

![image-20220421095042626](Lecture_8_Diagnostic_Quiz.assets/image-20220421095042626.png)

```python
def sculptural(ruler, k):
    if ruler == 0 or k == 0:
        return 0
    a = sculptural(ruler//10, k-1) * 10 + ruler%10
    b = sculptural(ruler//10, k)
    return max(a, b)
```

