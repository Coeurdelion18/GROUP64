#lang racket/base

;; Standalone S2 test harness. Test-only libraries and operations below are
;; intentionally separate from the restricted submission file.
(require rackunit
         rackunit/text-ui
         racket/runtime-path)

(define-runtime-path submission-file "../code/id_q4.rkt")

;; The grader's solution module exports nothing. Evaluate calls in its own
;; module namespace so the test file does not require modifying that module.
(dynamic-require submission-file #f)
(define submission-namespace (module->namespace submission-file))

(define (call-submission expression)
  (parameterize ([current-namespace submission-namespace])
    (eval expression)))

(define (run-stdin text)
  (define input (open-input-string text))
  (define output (open-output-string))
  (parameterize ([current-namespace submission-namespace]
                 [current-input-port input]
                 [current-output-port output])
    (eval '(print-insert-result)))
  (get-output-string output))

(define (run-stdin/remaining text)
  (define input (open-input-string text))
  (define output (open-output-string))
  (parameterize ([current-namespace submission-namespace]
                 [current-input-port input]
                 [current-output-port output])
    (eval '(print-insert-result)))
  (list (get-output-string output) (read input)))

(define large-list (build-list 10000 (lambda (i) i)))
(define large-incremented (build-list 10000 (lambda (i) (+ i 1))))

;; Exactly 100 nested single-element lists surrounding the innermost ().
(define deep-input
  (for/fold ([value '()]) ([i (in-range 100)])
    (list value)))
(define deep-expected
  (for/fold ([value '(deep)]) ([i (in-range 100)])
    (list 'deep value)))

(define tests
  (test-suite
   "S2 - Conditionally Insert into a Nested List"

   (test-case "my-length: empty, flat, nested and 10000 elements"
     (check-equal? (call-submission '(my-length '())) 0)
     (check-equal? (call-submission '(my-length '(1 2 3))) 3)
     (check-equal? (call-submission '(my-length '((1 2) () z))) 3)
     (check-equal? (call-submission `(my-length ',large-list)) 10000))

   (test-case "my-map: order, atoms, sublists, empty and 10000 elements"
     (check-equal? (call-submission '(my-map (lambda (v) (+ v 1)) '())) '())
     (check-equal? (call-submission '(my-map (lambda (v) (* v 2)) '(3 1 2)))
                   '(6 2 4))
     (check-equal?
      (call-submission '(my-map (lambda (v) (list 'seen v)) '(a (b c) ())))
      '((seen a) (seen (b c)) (seen ())))
     (check-equal?
      (call-submission `(my-map (lambda (v) (+ v 1)) ',large-list))
      large-incremented))

   (test-case "make-inserter: predicate, original lengths and empty sublists"
     (check-equal?
      (call-submission
       '((make-inserter 'z (lambda (len) (< len 2))) '(a (b) ())))
      '(a (z b) (z)))
     (check-equal?
      (call-submission
       '((make-inserter 5 (lambda (len) (= len 2))) '((1 2) (3) ())))
      '(5 (5 1 2) (3) ()))
     (check-equal?
      (call-submission
       '((make-inserter 'x (lambda (len) (= len 0))) '(() (a ()))))
      '((x) (a (x)))))

   (test-case "insert-if-short: four exact PDF examples"
     (check-equal?
      (call-submission '(insert-if-short 42 '((1 2) (3 4 5) (6) ()) 3))
      '((42 1 2) (3 4 5) (42 6) (42)))
     (check-equal?
      (call-submission '(insert-if-short 0 '(((1) 2) (3) ((4 5 6) ())) 3))
      '((0 (0 1) 2) (0 3) (0 (4 5 6) (0))))
     (check-equal? (call-submission '(insert-if-short 7 '() 3)) '(7))
     (check-equal? (call-submission '(insert-if-short 7 '() 0)) '()))

   (test-case "insert-if-short: exact threshold and one below"
     (check-equal? (call-submission '(insert-if-short 'x '(a b c) 3)) '(a b c))
     (check-equal? (call-submission '(insert-if-short 'x '(a b) 3)) '(x a b))
     (check-equal? (call-submission '(insert-if-short 'x '((a b) (c)) 2))
                   '((a b) (x c)))
     (check-equal? (call-submission '(insert-if-short 9 '(a b (c)) 0))
                   '(a b (c))))

   (test-case "insert-if-short: mixed atoms, nested empties, symbol/number x"
     (check-equal?
      (call-submission '(insert-if-short 'mark '(a (b ()) c) 4))
      '(mark a (mark b (mark)) c))
     (check-equal?
      (call-submission '(insert-if-short 8 '(q ((r)) ()) 3))
      '(q (8 (8 r)) (8)))
     (check-equal?
      (call-submission '(insert-if-short 'sym '((a) ()) 3))
      '(sym (sym a) (sym))))

   (test-case "insert-if-short: nesting depth 100, exact structure"
     (check-equal? (call-submission `(insert-if-short 'deep ',deep-input 2))
                   deep-expected))

   (test-case "insert-if-short: 10000 elements, exact result"
     (check-equal? (call-submission `(insert-if-short 'front ',large-list 10001))
                   (cons 'front large-list))
     (check-equal? (call-submission `(insert-if-short 'front ',large-list 10000))
                   large-list)
     (check-equal? (call-submission `(insert-if-short 'front ',large-list 0))
                   large-list))

   (test-case "repeated calls: no persistent state between calls"
     (check-equal? (call-submission '(insert-if-short 'a '((1) ()) 2))
                   '((a 1) (a)))
     (check-equal? (call-submission '(insert-if-short 'b '((1) ()) 1))
                   '((1) (b)))
     (check-equal? (call-submission '(insert-if-short 'a '((1) ()) 2))
                   '((a 1) (a)))
     (check-equal?
      (call-submission '((make-inserter 'y (lambda (len) (= len 0))) '()))
      '(y)))

   (test-case "print-insert-result: exact output for all four PDF examples"
     (check-equal? (run-stdin "42 ((1 2) (3 4 5) (6) ()) 3")
                   "((42 1 2) (3 4 5) (42 6) (42))\n")
     (check-equal? (run-stdin "0 (((1) 2) (3) ((4 5 6) ())) 3")
                   "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
     (check-equal? (run-stdin "7 () 3") "(7)\n")
     (check-equal? (run-stdin "7 () 0") "()\n"))

   (test-case "print-insert-result: symbols, multiline input and no prompts"
     (check-equal? (run-stdin "tag\n(a (b ()) c)\n4\n")
                   "(tag a (tag b (tag)) c)\n")
     (check-equal? (run-stdin "0\n()\n1\n") "(0)\n"))

   (test-case "print-insert-result: reads exactly three values"
     (check-equal? (run-stdin/remaining "7 () 3 extra")
                   '("(7)\n" extra)))))

(define failures (run-tests tests))
(unless (zero? failures)
  (exit 1))
