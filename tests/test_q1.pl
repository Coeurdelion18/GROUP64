:- consult('../code/64_q1.pl').

% run_p1_tests is semidet.
% Succeeds when the counts, clue 9 filtering, and main output match P1.
run_p1_tests :-
    count_solutions([], 13824),
    BaseClues = [1, 2, 3, 4, 5, 6, 7, 8],
    count_solutions(BaseClues, 3),
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8, 9], 1),

    % Any of the four people can be in testing, with Python fixed for them.
    count_solutions([3], 3456),
    once((solution([3], PartialSolution), \+ clue(2, PartialSolution))),

    findall(Solution, solution(BaseClues, Solution), Solutions),
    length(Solutions, 3),
    sort(Solutions, [_, _, _]),
    forall(member(Solution, Solutions),
           (ground(Solution), forall(member(Clue, BaseClues), clue(Clue, Solution)))),

    findall(Solution, (member(Solution, Solutions), clue(9, Solution)), [_]),
    findall(Solution, (member(Solution, Solutions), \+ clue(9, Solution)), [_, _]),

    with_output_to(string(Output), main),
    once((member(Solution, Solutions), p1_output_matches(Solution, Output))).

% p1_output_matches(+Solution:list(p/4), +Output:string) is semidet.
% Output is exactly the four assignment rows in the required order.
p1_output_matches(Solution, Output) :-
    Solution = [p('Alex', _, _, _), p('Ben', _, _, _),
                p('Carla', _, _, _), p('Dana', _, _, _)],
    with_output_to(string(Expected),
                   forall(member(p(Name, Department, Language, Project), Solution),
                          format('~a = [~a, ~a, ~a]~n', [Name, Department, Language, Project]))),
    Output == Expected.
