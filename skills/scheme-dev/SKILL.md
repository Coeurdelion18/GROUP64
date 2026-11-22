---
name: scheme-dev
description: Rules, conventions and checks for writing Racket (Scheme) solutions to the CS F301 Assignment 2 problems S1 (binary tree traversals) and S2 (conditional insert into a nested list). Use for every Scheme prompt in this assignment.
---

# scheme-dev

You are helping write Scheme code for a university assignment that is graded
automatically. The code must use only a small, fixed set of built-ins. Correct
code that uses a forbidden built-in loses marks, so the rules below count as
much as correctness.

## 1. Language and version

- Racket 8.x (tested with 8.18). Every solution file starts with the line
  `#lang racket/base` and has nothing above it.
- Files: `code/<GROUPID>_q3.rkt` (S1) and `code/<GROUPID>_q4.rkt` (S2).
- The grader runs `racket <GROUPID>_q3.rkt` after adding its own calls to the
  end of the file. So the file must contain **only definitions**:
  - no calls at the top level, no test code and no example trees left in;
  - nothing printed when the file is loaded;
  - no `require`, no `provide`, no `module+`.

## 2. Allowed built-ins (the complete list)

Only these may appear in a solution file:

```
define  lambda  let  let*  letrec  named let  if  cond (with else)
and  or  not  begin  quote (written ')
cons  car  cdr  list
car/cdr compositions up to four levels: cadr cddr caar cdar caddr cdddr
  cadddr cddddr ... (any c[ad]{2,4}r)
null?  pair?  eq?  assq  assoc
+  -  *  <  >  <=  >=  =  max
display  newline
read            ; S2 only
```

Anything not on this list is forbidden, and so is everything else from
`racket/base`. If a standard function is needed, write a helper with a `my-`
prefix (`my-length`, `my-map`, `my-reverse`, `my-append`) using only the
allowed built-ins.

Literals are fine: numbers, `#t`, `#f`, `'()` and quoted symbols.

## 3. Coding conventions

- Names are kebab-case: `print-inorder`, `tree-height`, `insert-if-short`.
  Predicates end in `?` (`leaf?`). Rewritten standard functions are named
  `my-<name>`.
- The function names asked for in the problem statement are exact. Never
  rename them or change their number of arguments.
- Above **every** function, write a `;;` comment that has:
  1. one line saying what it returns or prints;
  2. its recursive or declarative reading, case by case, for example:
     ```racket
     ;; (tree-height t): height of tree t.
     ;; Reading: the height of () is 0; the height of a node is
     ;; 1 + the larger of the heights of its left and right subtrees.
     ```
- All state is passed through function arguments. Use accumulators instead of
  mutation.
- Prefer tail recursion where it is natural: put the outermost recursive call
  in tail position, and use an accumulator, named `acc`, to carry partial
  results. In tree recursion, one of the two calls cannot be a tail call;
  that is acceptable.
- Build lists with `cons` onto the front. To avoid `append` and `reverse`
  when collecting results, process items right to left into an accumulator.
- Distinguish data like this:
  - empty list: `(null? x)`
  - non-empty list: `(pair? x)`
  - any list (S2): `(or (null? x) (pair? x))`
  - atom: `(not (or (null? x) (pair? x)))`
  - comparing numbers: `=`; comparing symbols: `eq?`
- Tree representation (S1): a tree is `()` or `(value left right)`. Access
  the parts with `car` (value), `cadr` (left) and `caddr` (right), wrapped in
  small named helpers.
- Print functions end with `(newline)` as their last expression, so they
  return void. A top-level call in `#lang racket/base` prints any value it
  returns that is not void, which would add extra output.
- Keep functions small: one job per function, one function per prompt.

## 4. How to run and test

- Check the file loads silently: `racket code/<GROUPID>_q3.rkt` must print
  nothing.
- Quick manual test: open the file in DrRacket, press Run, then type calls in
  the interactions panel, for example
  `(print-inorder '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))`.
- Grader-style test: copy the solution to a temporary file, add the test
  calls to the end, run it with `racket`, and compare the output with the
  expected output exactly, including line breaks.
- S2 reads from standard input. After adding `(print-insert-result)` to a
  temporary copy, test it with
  `echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket tmp.rkt`, which must print
  `((42 1 2) (3 4 5) (42 6) (42))`.
- The test files in `tests/` (one per problem) may use any library, such as
  `racket/system`, `racket/port` and `racket/file`. The built-in restriction
  applies only to the files in `code/`.
- Always test the edge cases: empty tree / empty list, a single node, deep or
  skewed trees, mixed numbers and symbols, `n = 0`. For S2, also test nesting
  depth 100 and a list of 10,000 elements.

## 5. Self-review checklist (apply before every answer)

Before giving code, check each item and fix anything that fails:

1. [ ] Every identifier used is either on the allowed list (section 2) or
       defined in this file.
2. [ ] No `append`, `reverse`, `length`, `map`, `filter`, `member`, `memq`,
       `list-ref` or `list-tail`.
3. [ ] No `set!` or relatives, no vectors, hash tables or strings, no `do` or
       `for` loops.
4. [ ] `else` appears only as the last clause of a `cond`, never with `if`.
5. [ ] No top-level calls or prints; the file only defines.
6. [ ] Print functions use `display` and end with `(newline)`; the output
       format matches the examples exactly (parentheses, spaces, one line per
       list).
7. [ ] Exact required function names and argument order are used.
8. [ ] Each function has its `;;` comment with the recursive reading.
9. [ ] Empty input behaves as specified: `()` prints `()`, height of `()` is
       0, an empty list becomes `(x)` in S2 when `0 < n`.
10. [ ] The outermost recursive call is a tail call where that is natural.
11. [ ] I traced the code by hand on at least one example from the problem
        statement and state the result.
12. [ ] Only the unit asked for in this prompt was written, not the rest of
        the problem.

## 6. Known AI failure modes in Racket (avoid these)

- Using convenient but forbidden built-ins: `add1`, `sub1`, `zero?`,
  `equal?`, `when`, `unless`, `void`, `printf`, `format`, `first`, `rest`,
  `empty`, `empty?`, `list?`, `apply`, `foldl`, `foldr`, `andmap`, `ormap`,
  `cons*`, `last`, `match`, `case`, `string-append`, `number->string`.
- Using `append` or `reverse` to collect traversal results instead of an
  accumulator.
- Writing `(if test a else b)` or putting `else` in the middle of a `cond`.
- Adding `(require racket/list)` or another `require` to get helpers.
- Leaving example trees, `(define t1 ...)` or test calls at the bottom of the
  file. The grader defines its own trees, and a duplicate definition is an
  error.
- Print functions whose last expression returns a list or number, which the
  module then prints as extra output.
- Printing with `write` or `print` instead of `display`, or printing extra
  text, labels or prompts.
- Using `eq?` to compare numbers (use `=`), or `=` on symbols (error).
- Confusing an empty list with an atom in S2: `()` is a list of length 0 and
  must receive the inserted element.
- In S2, measuring a list's length after inserting instead of on the original
  list, or forgetting that the top-level list is also checked.
- In S1, treating `()` as a leaf, or counting a node with one child as a leaf.
- Writing `#lang racket` instead of `#lang racket/base`.
- Producing the whole solution in one answer when only one function was asked
  for.
