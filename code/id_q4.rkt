#lang racket/base

(define (my-length lst)
  (let loop ((remaining lst) (count 0))
    (if (null? remaining)
        count
        (loop (cdr remaining) (+ count 1)))))

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
