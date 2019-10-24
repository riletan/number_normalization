%%%-------------------------------------------------------------------
%%% @author rilt
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Oct 2019 9:10 AM
%%%-------------------------------------------------------------------
-module(utils).
-author("rilt").
-include("../include/number_stuff.hrl").
%% API
-export([readConfig/0,writeConfig/0, buggyOla/2, my_is_number/2, remove_zero/1, readfile/0]).

writeConfig() ->
  WHAT = jsone:encode(#{key => #{key => <<"value">>}, key1 => <<"value2">>, key3 => <<"value3">>}),
  io:format("  -[~p:~p] ~s~n", [?MODULE, ?LINE, [binary_to_list(WHAT)]]),
  file:write_file(?CONF,  io_lib:format("~s~n",[binary_to_list(WHAT)]), [append]), ok.

readConfig() ->
  case file:read_file(?CONF) of
    {ok, <<>>} -> error;
    {ok, Binary} -> jsone:decode(Binary);
    _Other     -> error
  end.
readfile() ->
  case file:open(?INP,[read]) of
    {ok, File} ->
      FirstLine = io:get_line(File, ""),
      Data = readfile(FirstLine,File, []),
      file:close(File),
      Data;
    {error, _Reason} ->
      io:fwrite("Cannot read this file, please check\n"),
      []
  end.
readfile(eof, _File, Data) -> Data;
readfile(Line,File, Data) ->
  NewLine = io:get_line(File, ""),
  readfile(NewLine, File, [string:trim(Line, both)] ++ Data).

buggyOla("true", Msg) ->
  io:format("  -[~p:~p:~p] ~p~n", Msg);
buggyOla(_DonCare, _Msg) -> ok.

%%% Helper Function
my_is_number([Char | T], first) when (((Char >= $0) and (Char =< $9)) or (Char == $+)) ->
  my_is_number(T);
my_is_number(_N, first) ->
  false.
my_is_number([Char | T]) when Char >= $0, Char =< $9 ->
  my_is_number(T);
my_is_number([]) -> true;
my_is_number(_A)  -> false.

remove_zero([H|T]) when H == $0 ->
  remove_zero(T);
remove_zero([H1|T]) when (H1 == $+)->
  remove_zero(T);
remove_zero(T) -> T.