% clue(+ClueNumber:integer, +Solution:list(p/4)) is semidet.
% Holds when the numbered clue is satisfied by the fully filled Solution.

% Clue 1 holds when the friend who prefers AI is someone other than Dana
% and works outside research.
clue(1, Solution) :-
    memberchk(p(Name, Department, _, 'AI'), Solution),
    Name \== 'Dana',
    Department \== research.

% Alex works outside development and prefers a language other than C++.
clue(2, Solution) :-
    memberchk(p('Alex', Department, Language, _), Solution),
    Department \== development,
    Language \== 'c++'.

% The friend in testing prefers Python.
clue(3, Solution) :-
    memberchk(p(_, testing, python, _), Solution).

% Ben prefers web projects and works outside testing.
clue(4, Solution) :-
    memberchk(p('Ben', Department, _, web), Solution),
    Department \== testing.

% The friend who prefers Java works in design.
clue(5, Solution) :-
    memberchk(p(_, design, java, _), Solution).

% Carla works outside development and prefers a project other than embedded.
clue(6, Solution) :-
    memberchk(p('Carla', Department, _, Project), Solution),
    Department \== development,
    Project \== embedded.

% Dana works in research or testing and prefers a language other than Java.
clue(7, Solution) :-
    memberchk(p('Dana', Department, Language, _), Solution),
    Language \== java,
    memberchk(Department, [research, testing]).

% The friend who prefers data projects works in research and uses a language
% other than JavaScript.
clue(8, Solution) :-
    memberchk(p(_, research, Language, data), Solution),
    Language \== javascript.

% solution(+Active:list(integer), -Solution:list(p/4)) is nondet.
% Solution assigns each department, language and project once, in friend
% order, and satisfies every clue numbered in Active.
solution(Active, Solution) :-
    Solution = [
        p('Alex', AlexDepartment, AlexLanguage, AlexProject),
        p('Ben', BenDepartment, BenLanguage, BenProject),
        p('Carla', CarlaDepartment, CarlaLanguage, CarlaProject),
        p('Dana', DanaDepartment, DanaLanguage, DanaProject)
    ],
    permutation([research, development, design, testing],
                [AlexDepartment, BenDepartment, CarlaDepartment, DanaDepartment]),
    permutation([python, java, 'c++', javascript],
                [AlexLanguage, BenLanguage, CarlaLanguage, DanaLanguage]),
    permutation(['AI', web, embedded, data],
                [AlexProject, BenProject, CarlaProject, DanaProject]),
    forall(member(ClueNumber, Active), clue(ClueNumber, Solution)).

% main is semidet.
% Prints the first assignment satisfying clues 1 through 8, in friend order.
main :-
    once(solution([1, 2, 3, 4, 5, 6, 7, 8], [Alex, Ben, Carla, Dana])),
    print_person(Alex),
    print_person(Ben),
    print_person(Carla),
    print_person(Dana).

% print_person(+Person:p(atom, atom, atom, atom)) is det.
% Writes one assignment row with unquoted atoms and a trailing newline.
print_person(p(Name, Department, Language, Project)) :-
    format('~a = [~a, ~a, ~a]~n', [Name, Department, Language, Project]).
