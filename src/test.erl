%%%-------------------------------------------------------------------
%%% @author rilt
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Oct 2019 2:23 PM
%%%-------------------------------------------------------------------
-module(test).
-author("rilt").
-include("../include/number_stuff.hrl").
%% API
-export([do/2,stress/2,send/3,stress/3]).
%%do(N) when is_list(N)->
%%%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [N]]),
%%  number_stuff_handler:do(N);
do(Command, call) ->
%%  gen_server:call(?SERVER, {nmz,Command}).
  timer:tc(gen_server, call, [{?SERVER,'rilt@127.0.0.1'}, {nmz,Command}]);
%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [Rs]]).
do(Command,cast) ->
  gen_server:cast({?SERVER,'rilt@127.0.0.1'}, {nmz,self(), Command}),
  receive
    Rs -> Rs
  end.

send([],Count,_Tag) -> Count;
send([Head|Tail],Count, Tag) ->
  {_Time, _Rs} =  timer:tc(test, do, [Head,Tag]),
  %%io:format("  -[~p:~p] Input: ~p ~n                Output: ~p ~n                Execution time: ~p~n", [?MODULE, Count, Head, Rs, Time]),
  send(Tail, Count + 1, Tag).

stress(N, Tag) ->
  {Time, Count}  = timer:tc(test, stress, [N,1, Tag]),
  io:format("  -[~p]:Execution time of ~p test cases: ~p Microseconds~n", [?MODULE, Count, Time]),
  io:format("  -[~p]:Request/Second                : ~p~n", [?MODULE, (Count/Time)*1000000]).

stress(0, Count, _Tag) -> Count - 1;
stress(N, Count, Tag) ->
  Data = utils:readfile(),
  {_Time, NewCount} = timer:tc(test, send, [Data, Count, Tag]),
%%  io:format("  -[~p]:Execution time of this test case set: ~p~n", [?MODULE, Time]),
  stress(N-1, NewCount, Tag).


