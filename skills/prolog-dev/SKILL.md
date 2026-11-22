---
name: prolog-dev
description: Use when writing, reviewing, debugging, or testing SWI-Prolog 9.x code for a programming languages assignment, especially recursive predicates and grading scripts that invoke main/0 or individual goals.
---

# Prolog development

## Assignment contract

- Target SWI-Prolog 9.x. Read the assignment and existing code before editing. Preserve required filenames, predicate names and arities, input formats, exact output, and any restrictions on built-ins or libraries.
- Keep input and output in `main/0` or dedicated I/O predicates. Keep relations independently queryable. Let `main/0` succeed when the requested work is complete.
- Never call `halt/0` from the source or from a test goal. Use no `initialization` directives. Leave process termination to the command line.

## Predicate style and documentation

- Use descriptive `lower_snake_case` predicate names and meaningful `UpperCamelCase` variable names. Use `_` for an intentionally ignored argument and meaningful names for values used in the logic.
- Place a short comment above every predicate, including helpers. Give its argument modes and expected types, its determinism for the documented modes, and a declarative reading of the relation. Use `+` for input, `-` for output, and `?` for either where supported. Use `det` for exactly one solution without a remaining choice point, `semidet` for zero or one without a remaining choice point, `multi` for one or more, and `nondet` for zero or more.
- For each recursive predicate, identify the base case and explain what gets smaller in each recursive branch for the supported modes. For graph traversal, explain what bounds the search when cycles are possible.
- Keep clauses for the same predicate together. Use head patterns for distinct cases, put base cases first where appropriate, and indent each body goal consistently.

```prolog
% list_total(+Numbers:list(integer), -Total:integer) is det.
% Total is the sum of Numbers. The empty list sums to zero.
% Each recursive call consumes one element and works on the shorter tail.
list_total([], 0).
list_total([Number|Rest], Total) :-
    list_total(Rest, RestTotal),
    Total is Number + RestTotal.
```

## Run and test

Run from the directory containing the source file. Use these commands for `id_q1.pl` and substitute the actual filename for other questions.

```sh
swipl -q -f id_q1.pl -g main -t halt
swipl -q -f id_q1.pl -g "<goal>" -t halt
```

- Replace `<goal>` with a Prolog goal without a trailing period. Use explicit assertions because the command-line invocation does not display variable bindings by default. For the example above, use `-g "list_total([2,3], Total), Total == 5"` in place of the goal argument.
- Run `main/0` with representative assignment input and compare its output exactly, including whitespace. Inspect the exit status and diagnostic output.
- Test each changed predicate in its supported modes. Cover typical success, expected failure, the base case, and applicable edge cases such as duplicates, ties, empty input, or cycles. For predicates that should enumerate answers, use `findall/3` on a bounded case and compare the answers for completeness, duplicates, and required order.
- Investigate load errors and warnings. If SWI-Prolog 9.x is unavailable, state which checks were static and which commands remain unrun.

## Common mistakes to catch

- **Unification and arithmetic.** Use `=` for unification, `==` for term identity, `is` to evaluate a sufficiently instantiated arithmetic expression, and `=:=` for numeric equality. Use integer constraints such as `#=` when relational arithmetic is required and the assignment permits `library(clpfd)`.
- **Negation and disequality.** Use `\+ Goal` when failure of the executed goal is the intended test. Bind relevant inputs first. Use `dif/2` when two terms must stay distinct as variables are bound later.
- **Search order and termination.** Trace goals left to right and clauses in source order. Check that required inputs are bound before arithmetic or other mode-sensitive calls. Guard against unchanged recursive arguments, cycles, and branches that produce the first answer but loop on backtracking.
- **Lost or duplicate answers.** Justify any cut, `once/1`, or if-then-else by the required solution behavior. Check overlapping clauses, repeated derivations, and accidental failure after printing. Preserve duplicates and order whenever the specification calls for them.
- **Syntax and interfaces.** Verify predicate arities, argument order, variable capitalization, singleton warnings, list patterns, and parentheses around mixed conjunctions and disjunctions. Check whether the assignment expects atoms, strings, numbers, or lists. Match the input parser to the supplied format, especially when `read/1` would expect a Prolog term terminated by a period.

## Required self-review before answering

- [ ] Confirm SWI-Prolog 9.x compatibility and match the assignment's filenames, predicate signatures, allowed facilities, and I/O contract.
- [ ] Check every predicate's argument modes, types, determinism, and declarative reading. For recursion, verify the base case and decreasing measure for each supported mode.
- [ ] Trace binding order, arithmetic, negation, and backtracking. Check that all required answers are produced and that search terminates for the intended inputs.
- [ ] Confirm that the source has no calls to `halt/0` or `initialization` directives. Check that loading the source leaves `main/0` available for explicit invocation.
- [ ] Run the main and predicate commands where possible. Check diagnostics, exit status, output, and expected solutions. Fix mismatches and report which checks actually ran.
