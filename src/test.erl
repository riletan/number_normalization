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
-export([do/1,stress/1,send/1]).
%%do(N) when is_list(N)->
%%%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [N]]),
%%  number_stuff_handler:do(N);
do(Command) ->
%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [ahihi]]),
  Rs =  timer:tc(number_stuff_handler, do, [Command]),
  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [Rs]]).


send([]) -> ok;
send([Head|Tail]) ->
%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [ahihi]]),
  Rs =  timer:tc(number_stuff_handler, do, [Head]),
  io:format("  -[~p:~p] ~p~n", [?MODULE, ?LINE, [Rs]]),
  send(Tail).

stress(0) -> ok;
stress(N) ->
  Data = utils:readfile(),
  spawn(test, send, [Data]),
  stress(N-1).

