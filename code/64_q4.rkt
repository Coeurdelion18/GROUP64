#lang racket/base

;; (my-length lst): returns the number of top-level elements in lst.
;; Reading: an empty list has length 0; otherwise count its first element
;; as one and continue with the rest, carrying the count in tail position.
(define (my-length lst)
  (let loop ((remaining lst) (count 0))
    (if (null? remaining)
        count
        (loop (cdr remaining) (+ count 1)))))

;; (my-map f lst): returns a list with f applied to each top-level element.
;; Reading: an empty list produces an empty list; otherwise collect each
;; transformed element in reverse order, then restore the original order.
(define (my-map f lst)
  (let collect ((remaining lst) (acc '()))
    (if (null? remaining)
        (let restore-order ((reversed acc) (result '()))
          (if (null? reversed)
              result
              (restore-order (cdr reversed)
                             (cons (car reversed) result))))
        (collect (cdr remaining)
                 (cons (f (car remaining)) acc)))))

;; (make-inserter x len-ok?): returns a function that inserts x into
;; each nested list whose original top-level length satisfies len-ok?.
;; Reading: process each sublist recursively and leave atoms unchanged;
;; check the current list's saved original length before prepending x.
(define (make-inserter x len-ok?)
  (letrec ((process-list
            (lambda (lst)
              (let ((original-length (my-length lst)))
                (let ((processed (my-map (lambda (element)
                                           (if (or (pair? element)
                                                   (null? element))
                                               (process-list element)
                                               element))
                                         lst)))
                  (if (len-ok? original-length)
                      (cons x processed)
                      processed))))))
    process-list))

;; (insert-if-short x lst n): returns lst with x inserted at the front
;; of every list whose original top-level length is less than n.
;; Reading: make a recursive inserter using the predicate length < n,
;; then apply that inserter to the whole list.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; (print-insert-result): reads x, lst, n and prints the transformed list.
;; Reading: read the three inputs in order, display insert-if-short's
;; result, and finish with exactly one newline.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
