#lang racket/base

;; (tree-value t): the value stored at the root of non-empty tree t.
;; Reading: t is (value left right), so the value is its first element.
(define (tree-value t)
  (car t))

;; (tree-left t): the left subtree of non-empty tree t.
;; Reading: t is (value left right), so the left subtree is its second element.
(define (tree-left t)
  (cadr t))

;; (tree-right t): the right subtree of non-empty tree t.
;; Reading: t is (value left right), so the right subtree is its third element.
(define (tree-right t)
  (caddr t))

;; (leaf? t): #t if tree t is a leaf, #f otherwise.
;; Reading: the empty tree () is not a leaf; a node is a leaf
;; when its left and right subtrees are both ().
(define (leaf? t)
  (and (pair? t)
       (null? (tree-left t))
       (null? (tree-right t))))
