; ;; Scheme Recursive Art Contest Entry
; ;;
; ;; Please do not include your name or personal info in this file.
; ;;
; ;; Title: <Your title here>
; ;;
; ;; Description:
; ;;   <It's your masterpiece.
; ;;    Use these three lines to describe
; ;;    its inner meaning.>
(define (draw)
  (speed 10)
  (penup)
  (bgcolor "#000000")
  (define (repeat k fn)
    (if (> k 0)
        (begin (fn) (repeat (- k 1) fn))
        nil))
  (define (square size)
    (repeat 4 (lambda () (forward size) (left 90))))
  (color "#FFFFAA")
  (define (art r num t)
    (define angle (- 45 (/ 180 num)))
    (right 90)
    (forward r)
    (left 90)
    (pendown)
    (repeat num
            (lambda ()
              (left angle)
              (square (* (/ r 0.7071067) t))
              (right angle)
              (print (* (+ 45 angle) 0.01745329))
              (forward
               (* (* (cos (* (+ 45 angle) 0.01745329)) r) 2))
              (left (/ 360 num))))
    (penup)
    (left 90)
    (forward r)
    (right 90))
  (define (art-circle t)
    (art (* 90 t) 20 1)
    (forward (* 7 t))
    (art (* 200 t) 80 0.7)
    (forward (* 4 t))
    (art (* 220 t) 200 0.02))
  (define (tri r opt)
    (forward r)
    (left 150)
    (pendown)
    (repeat 3
            (lambda ()
              (forward (* 1.7320508 r))
              ; (art-circle 0.4)
              (penup)
              (if (= opt 1)
                  (art 100 30 0.85)
                  (art 60 20 0.6))
              (pendown)
              (left 120)))
    (penup)
    (right 150)
    (backward r))
  (art-circle 0.8)
  (tri 220 1)
  (left 60)
  (tri 220 0)
  (setposition 8 3)
  (art 260 90 0.09)
  (setposition 5 3)
  (art 280 200 0.01)
  (exitonclick))

; Please leave this last line alone.  You may add additional procedures above
; this line.
(draw)
