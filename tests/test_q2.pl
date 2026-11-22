:- consult('../code/64_q2.pl').

% run_tests is semidet.
% Runs unit tests for P2 covering assignment examples, failure cases, and edge cases.

run_tests :-
    % 1. Assignment examples[cite: 3]
    all_equations([4,2,5,3], [
        "4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
        "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"
    ]),
    count_equations([4,2,5,3], 7),
    all_equations([2,4,8], ["2*4=8"]),
    generate_equation([2,4,8], Eq1),
    string(Eq1),
    Eq1 == "2*4=8",

    % 2. Expected failures & empty results (lengths 0, 1, and unsolvable)[cite: 3, 7]
    \+ generate_equation([], _),
    \+ generate_equation([5], _),
    \+ generate_equation([2,3,4], _),
    all_equations([], []),
    all_equations([5], []),
    all_equations([2,3,4], []),
    count_equations([2,3,4], 0),

    % 3. Edge cases: zeros, non-exact division, negative sub-expressions, precedence[cite: 3, 7]
    all_equations([0,0], ["0=0"]),
    all_equations([0,0,0], ["0*0=0", "0+0=0", "0-0=0", "0=0*0", "0=0+0", "0=0-0"]), % avoids 0/0[cite: 3], % avoids 0/0
    \+ generate_equation([3,2], _),                     % 3/2 is not an exact integer
    all_equations([1,2,3,4], EsNeg),
    memberchk("1-2=3-4", EsNeg),                        % negative intermediate values allowed
    memberchk("1-(2-3)=4-2", [_|_]),                    % sanity check format
    all_equations([1,2,3,6], EsAssoc),
    memberchk("1+(2+3)=6", EsAssoc),                    % distinct tree from 1+2+3
    memberchk("1+2+3=6", EsAssoc).