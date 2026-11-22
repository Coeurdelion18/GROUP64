#lang racket/base
;; Tests for S1: Binary Tree Traversals (code/64_q3.rkt).
;; Run from anywhere:  racket tests/test_q3.rkt
;;
;; The solution file only defines functions (no provide), so we load it and
;; call its functions inside the module's own namespace. Each print function
;; is called on a tree, its printed output is captured and compared with the
;; exact expected text (newlines included).
;;
;; Sections:
;;   1. File checks: loads silently, uses only allowed built-ins.
;;   2. Examples from the assignment PDF (t1, t2, t3, empty tree).
;;   3. Edge cases (single node, one-child nodes, skewed, mixed values, ...).
;;   4. Large trees (deep chains, full tree).
;;   5. Return values: every print function returns void.
;;   6. Grader-style run: calls appended to a copy of the file, run as a
;;      separate racket process, full stdout compared.

(require racket/port
         racket/runtime-path
         racket/system
         racket/file
         racket/string
         racket/list)

(define-runtime-path code-file "../code/64_q3.rkt")

;; ---------------------------------------------------------------------------
;; Loading the solution
;; ---------------------------------------------------------------------------

;; Namespace of the solution module, so its (unexported) functions can be
;; called with eval.
(define ns
  (parameterize ([current-namespace (make-base-namespace)])
    (dynamic-require code-file #f)
    (module->namespace code-file)))

;; (call fn tree): calls (fn 'tree) in the solution's namespace.
;; Returns two values: the printed output (a string) and the return value.
(define (call fn tree)
  (define result #f)
  (define out
    (with-output-to-string
      (lambda () (set! result (eval `(,fn ',tree) ns)))))
  (values out result))

;; (output-of fn tree): only the printed output of (fn tree).
(define (output-of fn tree)
  (define-values (out _) (call fn tree))
  out)

;; ---------------------------------------------------------------------------
;; Tiny test framework: each check prints FAIL on mismatch and returns #t/#f.
;; ---------------------------------------------------------------------------

(define (check name actual expected)
  (cond [(equal? actual expected) #t]
        [else (printf "FAIL ~a\n  expected: ~s\n  actual:   ~s\n"
                      name expected actual)
              #f]))

;; (lines . strs): joins strings into lines, each ending in a newline.
(define (lines . strs)
  (apply string-append (map (lambda (s) (string-append s "\n")) strs)))

;; (expect-tree name tree in pre post hl): checks all three functions on tree.
;; in/pre/post/hl are the expected printed lists, e.g. "(1 2 3)" and "(2 1)".
(define (expect-tree name tree in pre post hl)
  (list (check (format "~a: print-inorder" name)
               (output-of 'print-inorder tree) (lines in))
        (check (format "~a: print-all-traversals" name)
               (output-of 'print-all-traversals tree) (lines in pre post))
        (check (format "~a: print-height-and-leaves" name)
               (output-of 'print-height-and-leaves tree) (lines hl))))

;; ---------------------------------------------------------------------------
;; 1. File checks
;; ---------------------------------------------------------------------------

;; Path of the racket executable running these tests.
(define racket-exe
  (let ([p (find-system-path 'exec-file)])
    (if (absolute-path? p) p (find-executable-path p))))

;; (run-racket file): runs `racket file` and returns its stdout+stderr.
(define (run-racket file)
  (with-output-to-string
    (lambda ()
      (parameterize ([current-error-port (current-output-port)])
        (system* racket-exe file)))))

;; Allowed built-ins for S1 (from the assignment's Scheme rules).
(define allowed
  '(define lambda let let* letrec if cond else and or not begin quote
     cons car cdr list
     caar cadr cdar cddr
     caaar caadr cadar caddr cdaar cdadr cddar cdddr
     caaaar caaadr caadar caaddr cadaar cadadr caddar cadddr
     cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr
     null? pair? eq? assq assoc
     + - * < > <= >= = max display newline))

;; (file-forms file): all forms in file after the #lang line.
(define (file-forms file)
  (call-with-input-file file
    (lambda (in)
      (read-line in)                          ; skip "#lang racket/base"
      (let loop ([acc '()])
        (define form (read in))
        (if (eof-object? form) (reverse acc) (loop (cons form acc)))))))

;; (symbols-in x): every symbol in datum x, skipping quoted data.
(define (symbols-in x)
  (cond [(symbol? x) (list x)]
        [(and (pair? x) (eq? (car x) 'quote)) '(quote)]
        [(pair? x) (append (symbols-in (car x)) (symbols-in (cdr x)))]
        [else '()]))

;; (defined-names forms): names and parameters bound by (define (f args...) ...).
(define (defined-names forms)
  (append* (for/list ([f forms]
                      #:when (and (pair? f) (eq? (car f) 'define)))
             (define head (cadr f))
             (if (pair? head) head (list head)))))

(define file-check-results
  (let* ([forms (file-forms code-file)]
         [ok (append allowed (defined-names forms))]
         [bad (remove-duplicates
               (filter (lambda (s) (not (memq s ok)))
                       (append* (map symbols-in forms))))])
    (list
     (check "file starts with #lang racket/base"
            (call-with-input-file code-file read-line)
            "#lang racket/base")
     (check "loading the file prints nothing"
            (run-racket code-file) "")
     (check "only allowed built-ins are used (list of others)"
            bad '())
     (check "every top-level form is a define"
            (for/and ([f forms]) (and (pair? f) (eq? (car f) 'define)))
            #t))))

;; ---------------------------------------------------------------------------
;; 2. Examples from the assignment PDF
;; ---------------------------------------------------------------------------

(define t1 '(4 (2 (1 () ()) (3 () ()))
               (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))

(define pdf-results
  (append
   (expect-tree "PDF t1" t1
                "(1 2 3 4 5 6 7)" "(4 2 1 3 6 5 7)" "(1 3 2 5 7 6 4)" "(3 4)")
   (expect-tree "PDF t2" t2
                "(1 2 3)" "(1 2 3)" "(3 2 1)" "(3 1)")
   (expect-tree "PDF t3" t3
                "(b a c)" "(a b c)" "(b c a)" "(2 2)")
   (expect-tree "PDF empty tree" '()
                "()" "()" "()" "(0 0)")))

;; ---------------------------------------------------------------------------
;; 3. Edge cases
;; ---------------------------------------------------------------------------

(define edge-results
  (append
   ;; A single node is a leaf of height 1.
   (expect-tree "single number node" '(5 () ())
                "(5)" "(5)" "(5)" "(1 1)")
   (expect-tree "single symbol node" '(z () ())
                "(z)" "(z)" "(z)" "(1 1)")
   ;; Value 0 and negative numbers are ordinary values.
   (expect-tree "zero and negative values" '(0 (-1 () ()) (-2 () ()))
                "(-1 0 -2)" "(0 -1 -2)" "(-1 -2 0)" "(2 2)")
   ;; One child only: the parent is not a leaf.
   (expect-tree "root with only a left child" '(2 (1 () ()) ())
                "(1 2)" "(2 1)" "(1 2)" "(2 1)")
   (expect-tree "root with only a right child" '(1 () (2 () ()))
                "(1 2)" "(1 2)" "(2 1)" "(2 1)")
   ;; Left-skewed chain (mirror of t2).
   (expect-tree "left-skewed chain" '(3 (2 (1 () ()) ()) ())
                "(1 2 3)" "(3 2 1)" "(1 2 3)" "(3 1)")
   ;; Zig-zag: left, then right, then left.
   (expect-tree "zig-zag" '(1 (2 () (3 (4 () ()) ())) ())
                "(2 4 3 1)" "(1 2 3 4)" "(4 3 2 1)" "(4 1)")
   ;; Unbalanced: height comes from the deeper side.
   (expect-tree "unbalanced, deep right side"
                '(1 (2 () ()) (3 () (4 () (5 () ()))))
                "(2 1 3 4 5)" "(1 2 3 4 5)" "(2 5 4 3 1)" "(4 2)")
   ;; Mixed numbers and symbols, with one-child nodes on both sides.
   (expect-tree "mixed numbers and symbols"
                '(x (3 (y () ()) ()) (z () (8 () ())))
                "(y 3 x z 8)" "(x 3 y z 8)" "(y 3 8 z x)" "(3 2)")
   ;; Repeated values are printed every time they occur.
   (expect-tree "repeated values" '(1 (1 () ()) (1 () ()))
                "(1 1 1)" "(1 1 1)" "(1 1 1)" "(2 2)")
   ;; Leaves at different depths.
   (expect-tree "leaves at different depths"
                '(a (b (d () ()) (e () ())) (c () ()))
                "(d b e a c)" "(a b d e c)" "(d e b c a)" "(3 3)")))

;; ---------------------------------------------------------------------------
;; 4. Large trees
;; ---------------------------------------------------------------------------

;; (list->string-list nums): "(n1 n2 ...)" for a list of numbers.
(define (list->string-list nums)
  (string-append "(" (string-join (map number->string nums) " ") ")"))

;; (left-chain n): (n (n-1 ( ... (1 () ()) ...) ()) ()), a left-skewed chain.
(define (left-chain n)
  (for/fold ([t '()]) ([i (in-range 1 (+ n 1))])
    (list i t '())))

;; (right-chain n): (1 () (2 () ( ... (n () ())))), a right-skewed chain.
(define (right-chain n)
  (for/fold ([t '()]) ([i (in-range n 0 -1)])
    (list i '() t)))

;; (full-tree lo hi): a perfect tree holding lo..hi in inorder.
(define (full-tree lo hi)
  (if (> lo hi)
      '()
      (let ([mid (quotient (+ lo hi) 2)])
        (list mid (full-tree lo (- mid 1)) (full-tree (+ mid 1) hi)))))

(define big-n 10000)
(define up (range 1 (+ big-n 1)))      ; 1 .. n
(define down (reverse up))             ; n .. 1

(define large-results
  (append
   (expect-tree (format "left chain of ~a nodes" big-n) (left-chain big-n)
                (list->string-list up) (list->string-list down)
                (list->string-list up)
                (format "(~a 1)" big-n))
   (expect-tree (format "right chain of ~a nodes" big-n) (right-chain big-n)
                (list->string-list up) (list->string-list up)
                (list->string-list down)
                (format "(~a 1)" big-n))
   ;; Perfect tree of height 10: 1023 nodes, 512 leaves, inorder is 1..1023.
   (list (check "perfect tree (1023 nodes): print-inorder"
                (output-of 'print-inorder (full-tree 1 1023))
                (lines (list->string-list (range 1 1024))))
         (check "perfect tree (1023 nodes): print-height-and-leaves"
                (output-of 'print-height-and-leaves (full-tree 1 1023))
                (lines "(10 512)")))))

;; ---------------------------------------------------------------------------
;; 5. Return values: a print function must return void, otherwise a top-level
;;    call in the grader would print its result as extra output.
;; ---------------------------------------------------------------------------

(define void-results
  (for*/list ([fn '(print-inorder print-all-traversals print-height-and-leaves)]
              [tree (list t1 '())])
    (define-values (_ result) (call fn tree))
    (check (format "~a returns void on ~s" fn tree) (void? result) #t)))

;; ---------------------------------------------------------------------------
;; 6. Grader-style run: append calls to a copy of the file, run it with
;;    racket, compare the whole stdout.
;; ---------------------------------------------------------------------------

(define grader-calls
  "(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(print-inorder t1)
(print-all-traversals t1)
(print-height-and-leaves t1)
(print-all-traversals t2)
(print-height-and-leaves t2)
(print-all-traversals t3)
(print-height-and-leaves t3)
(print-inorder '())
(print-all-traversals '())
(print-height-and-leaves '())
")

(define grader-expected
  (lines "(1 2 3 4 5 6 7)"
         "(1 2 3 4 5 6 7)" "(4 2 1 3 6 5 7)" "(1 3 2 5 7 6 4)"
         "(3 4)"
         "(1 2 3)" "(1 2 3)" "(3 2 1)"
         "(3 1)"
         "(b a c)" "(a b c)" "(b c a)"
         "(2 2)"
         "()"
         "()" "()" "()"
         "(0 0)"))

(define grader-results
  (let* ([dir (make-temporary-file "s1-grader-~a" 'directory)]
         [copy (build-path dir "64_q3.rkt")])
    (dynamic-wind
     void
     (lambda ()
       (call-with-output-file copy
         (lambda (out)
           (write-string (file->string code-file) out)
           (write-string "\n" out)
           (write-string grader-calls out)))
       (list (check "grader-style run of the PDF examples"
                    (run-racket copy) grader-expected)))
     (lambda () (delete-directory/files dir)))))

;; ---------------------------------------------------------------------------
;; Summary
;; ---------------------------------------------------------------------------

(define (report section results)
  (printf "~a: ~a/~a passed\n"
          section (count values results) (length results)))

(define all-sections
  (list (cons "1. File checks" file-check-results)
        (cons "2. PDF examples" pdf-results)
        (cons "3. Edge cases" edge-results)
        (cons "4. Large trees" large-results)
        (cons "5. Return values" void-results)
        (cons "6. Grader-style run" grader-results)))

(for ([s all-sections]) (report (car s) (cdr s)))

(define all-results (append* (map cdr all-sections)))
(define failed (- (length all-results) (count values all-results)))
(printf "TOTAL: ~a/~a passed\n" (- (length all-results) failed) (length all-results))
(unless (zero? failed) (exit 1))
