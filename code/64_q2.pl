% split_non_empty(+List:list, -Left:list, -Right:list) is nondet.
% True when List is the concatenation of two non-empty lists, Left and Right.
% Base case places the first element in Left with a non-empty Right;
% each recursive step moves one more element into Left from the shorter tail Rest.
split_non_empty([First, Second|Rest], [First], [Second|Rest]).
split_non_empty([First|Rest], [First|LeftRest], Right) :-
    split_non_empty(Rest, LeftRest, Right).

% build_expr(+Numbers:list(integer), -Tree:term, -Value:integer) is nondet.
% True when Tree is a valid arithmetic expression tree over Numbers that evaluates to Value.
% Base case is a single-element list; each recursive step splits Numbers into two strictly shorter non-empty lists.
build_expr([Number], num(Number), Number).
build_expr(Numbers, op(Op, LeftTree, RightTree), Value) :-
    split_non_empty(Numbers, LeftNums, RightNums),
    build_expr(LeftNums, LeftTree, LeftVal),
    build_expr(RightNums, RightTree, RightVal),
    apply_op(Op, LeftVal, RightVal, Value).

% apply_op(?Op:atom, +Left:integer, +Right:integer, -Result:integer) is nondet.
% True when applying arithmetic operator Op to Left and Right yields exact integer Result.
apply_op(+, Left, Right, Result) :-
    Result is Left + Right.
apply_op(-, Left, Right, Result) :-
    Result is Left - Right.
apply_op(*, Left, Right, Result) :-
    Result is Left * Right.
apply_op(/, Left, Right, Result) :-
    Right =\= 0,
    Left mod Right =:= 0,
    Result is Left // Right.

% op_prec(+Op:atom, -Prec:integer) is det.
% Maps each arithmetic operator to its precedence level (higher binds tighter).
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

% expr_to_string(+Tree:term, -Str:string) is det.
% Converts an expression tree into its canonical SWI-Prolog string without spaces.
% Base case is num(N); recursive calls format strictly smaller Left and Right subtrees.
expr_to_string(num(Number), Str) :-
    number_string(Number, Str).
expr_to_string(op(Op, Left, Right), Str) :-
    op_prec(Op, ParentPrec),
    format_left(Left, ParentPrec, LeftStr),
    format_right(Right, ParentPrec, RightStr),
    format(string(Str), "~s~w~s", [LeftStr, Op, RightStr]).