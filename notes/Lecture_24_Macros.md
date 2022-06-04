## Programs as Data

**A Scheme Expression is a Scheme List**

![image-20220604103706817](Lecture_24_Macros.assets/image-20220604103706817.png)

```scheme
(define (fact-exp n)
  (if (= n 1) 1 (list '* n (*fact-exp (- n 1)))))
```



## Macros

![image-20220604140123858](Lecture_24_Macros.assets/image-20220604140123858.png)

![image-20220604142056436](Lecture_24_Macros.assets/image-20220604142056436.png)

