% split_non_empty(+List:list, -Left:list, -Right:list) is nondet.
% True when List is the concatenation of two non-empty lists, Left and Right.
% Base case places the first element in Left with a non-empty Right;
% each recursive step moves one more element into Left from the shorter tail Rest.
split_non_empty([First, Second|Rest], [First], [Second|Rest]).
split_non_empty([First|Rest], [First|LeftRest], Right) :-
    split_non_empty(Rest, LeftRest, Right).