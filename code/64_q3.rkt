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

;; (inorder-acc t acc): the inorder values of tree t, placed in front of acc.
;; Reading: for (), the result is acc; for a node, first collect the right
;; subtree onto acc, cons the node's value in front, then collect the
;; left subtree onto that (right to left, so no append is needed).
(define (inorder-acc t acc)
  (cond ((null? t) acc)
        (else (inorder-acc (tree-left t)
                           (cons (tree-value t)
                                 (inorder-acc (tree-right t) acc))))))

;; (inorder t): the list of values of tree t in inorder (left, node, right).
;; Reading: the inorder values of t placed in front of the empty list.
(define (inorder t)
  (inorder-acc t '()))

;; (print-inorder tree): prints the inorder list of tree on one line (S1.a).
;; Reading: display the inorder list, then end the line with a newline.
(define (print-inorder tree)
  (display (inorder tree))
  (newline))

;; (preorder-acc t acc): the preorder values of tree t, placed in front of acc.
;; Reading: for (), the result is acc; for a node, first collect the right
;; subtree onto acc, then the left subtree onto that, and finally cons the
;; node's value in front (right, left, value, so no append is needed).
(define (preorder-acc t acc)
  (cond ((null? t) acc)
        (else (cons (tree-value t)
                    (preorder-acc (tree-left t)
                                  (preorder-acc (tree-right t) acc))))))

;; (preorder t): the list of values of tree t in preorder (node, left, right).
;; Reading: the preorder values of t placed in front of the empty list.
(define (preorder t)
  (preorder-acc t '()))

;; (postorder-acc t acc): the postorder values of tree t, placed in front of acc.
;; Reading: for (), the result is acc; for a node, first cons the node's
;; value onto acc, then collect the right subtree onto that, and finally
;; the left subtree (value, right, left, so no append is needed).
(define (postorder-acc t acc)
  (cond ((null? t) acc)
        (else (postorder-acc (tree-left t)
                             (postorder-acc (tree-right t)
                                            (cons (tree-value t) acc))))))

;; (postorder t): the list of values of tree t in postorder (left, right, node).
;; Reading: the postorder values of t placed in front of the empty list.
(define (postorder t)
  (postorder-acc t '()))

;; (print-all-traversals tree): prints the inorder, preorder and postorder
;; lists of tree, one per line (S1.b).
;; Reading: display each traversal list followed by a newline, in the
;; order inorder, preorder, postorder.
(define (print-all-traversals tree)
  (display (inorder tree))
  (newline)
  (display (preorder tree))
  (newline)
  (display (postorder tree))
  (newline))
