%%%-------------------------------------------------------------------
%%% @author rilt
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Oct 2019 9:13 AM
%%%-------------------------------------------------------------------
-module(number_stuff_handler).

-author("rilt").
-include("../include/number_stuff.hrl").
-behaviour(gen_server).

%% API
-export([start_link/0, do/1, normalizing/3]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-record(state, {
  rules_by_op,
  rules_by_num,
  spec_rules,
  common_rules,
  debug}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

do({From, N, Data}) when is_list(N)->
  Normalized = normalizing(N, Data, From),
%%  io:format("I am ~p~n: ", [self()]),
  From ! {self(), Normalized};
%%  gen_server:cast(?SERVER, {respone, From, Normalized});
do(_command) ->
  not_thing_to.


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  RulesOP = utils:readConfig(),
  F = fun(Key, Value, AMap) ->
      NewMap = maps:put(Value, Key, AMap),
      NewMap
      end,
  CommonRules = maps:get(list_to_binary("common"), RulesOP),
  DebugTag = binary_to_list(maps:get(list_to_binary("debug"),CommonRules, <<"false">>)),
  NorRules = maps:get(list_to_binary("normal"),RulesOP), utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [NorRules]]),
  SpecRules = maps:get(list_to_binary("special"),RulesOP), utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [SpecRules]]),
  RulesNum = maps:fold(F, #{}, NorRules),
  {ok,
    #state{
      rules_by_op = NorRules,
      rules_by_num = RulesNum,
      spec_rules = SpecRules,
      debug = DebugTag,
      common_rules = #common_rules{
        local_cc = binary_to_list(maps:get(list_to_binary("local-cc"), CommonRules, <<?DEFAULT_CC>>)),
        ac_fixed = binary_to_integer(maps:get(list_to_binary("ac-fixed"), CommonRules, <<?DEFAULT_AC_FIXED>>)),
        ac_mobile = binary_to_integer(maps:get(list_to_binary("ac-mobile"), CommonRules, <<?DEFAULT_AC_MOBILE>>)),
        num_len =  binary_to_integer(maps:get(list_to_binary("num-len"), CommonRules, <<?DEFAULT_NUM_LEN>>)),
        max_num_len = binary_to_integer(maps:get(list_to_binary("max-num-len"), CommonRules, <<?DEFAULT_MAX_NUM_LEN>>))
      }
    }
  }.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).

handle_call(crash_it, _From, _State) ->
  {reply, ahihi};
handle_call({nmz,N}, _From, State) ->
  {reply, normalizing(N, State),State}.
%%handle_call(_Request, _From, State) ->
%%  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast({nmz, From, N}, State) ->
  spawn(number_stuff_handler, normalizing, [N, State, From]),
  {noreply, State};
handle_cast({respone, From, N}, State) ->
  From ! N,
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------

-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

resultBeatify(#n_context{tel_number = Tel, tag = "tel"}) ->
  "tel:" ++ Tel;
resultBeatify(#n_context{tel_number = Tel, tag = "sip", operator = Op}) ->
  "sip:" ++ Tel ++ "@" ++ Op ++ ";user=phone".

%%%===================================================================
normalizing(URL, Data, From) ->
  From ! normalizing(URL, Data).
normalizing(URL, Data) ->
%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, [Rules]]),
  [Tag|Tail] = string:split(URL, ":"),
  case string:split(string:trim(URL, both), ":") of
      [Tag|[]]   ->
        {invalid, URL};
      [Tag|Tail] ->
        [PhoneNumber|Params] = string:split(Tail, ";", all),
        if
          Params == [] ->
            [Num] = PhoneNumber,
            case inNormalizing({Tag, Num, Params}, Data) of
                #n_context{tel_number = failed} -> {invalid, URL};
                invalid -> {invalid, URL};
                AfterEfect -> {ok, resultBeatify(AfterEfect)}
            end;
          length(Params) > 2 -> {invalid, URL};
          true ->
            case inNormalizing({Tag, PhoneNumber, Params}, Data) of
              #n_context{tel_number = failed} -> {invalid, URL};
              invalid -> {invalid, URL};
              AfterEfect -> {ok, resultBeatify(AfterEfect)}
            end
        end
  end.

inNormalizing({"tel", PhoneNum, Params}, Data = #state{debug = DebugTag}) ->
  case utils:my_is_number(PhoneNum, first) of
    true ->
      NumContext = get_context({"tel", PhoneNum, [], Params}), utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [NumContext]]),
      postNormalizing(NumContext, Data);
    false -> #n_context{tel_number = failed}
  end;
inNormalizing({"sip", SipContext, Params}, Data = #state{debug = DebugTag}) ->
  [PhoneNum|Op] = string:split(SipContext, "@"),
  case utils:my_is_number(PhoneNum, first) of
    true ->
      NumContext = get_context({"sip", PhoneNum, Op, Params}), utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [NumContext]]),
      postNormalizing(NumContext, Data);
    false ->  #n_context{tel_number = failed}
  end;
inNormalizing(_URL, _Rules) ->
  invalid.

postNormalizing(Context = #n_context{tel_number = TelPhone}, Data = #state{debug = DebugTag}) when (length(TelPhone) < Data#state.common_rules#common_rules.max_num_len) ->
  case preHandleSpecialRules(TelPhone, Data) of
    {ok, Tel_OK, NewOP} -> Context#n_context{tel_number = Tel_OK, operator = NewOP};
    failed ->  Context#n_context{tel_number = failed};
    nomatch ->
      utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [TelPhone]]),
      handleNormalRules(Context#n_context{tel_number = utils:remove_zero(TelPhone)}, Data)
  end;
postNormalizing(Context, _Data) ->
  Context#n_context{tel_number = failed}.

getCC(Tel, PhoneContext, Operator, Data = #state{rules_by_num = RulesByNum, rules_by_op = RulesByOp, debug = DebugTag, common_rules = CommonRules})
  when ((length(PhoneContext) > CommonRules#common_rules.ac_mobile) or (length(PhoneContext) == 0)) ->
  case utils:my_is_number(PhoneContext, first) of
    true ->
      case re:run(PhoneContext, "^\\+" ++ CommonRules#common_rules.local_cc) of
        {match,_} ->
          utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [PhoneContext]]),
          Prefix = length(CommonRules#common_rules.local_cc) + 2,
          RefAC = string:sub_string(PhoneContext, Prefix),
          case maps:find(list_to_binary(RefAC), RulesByNum) of
            {ok, Value} -> %% Ok
              utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [Value]]),
              {PhoneContext ++ Tel, binary_to_list(Value)};
            error ->  %%% Invalid
              {failed, []}
          end;
        nomatch ->
          case preHandleSpecialRules(PhoneContext ++ Tel, Data) of
            {ok, Tel_OK, NewOp} -> {Tel_OK, NewOp};
            Other  -> utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [Other]]), {failed, undefined}
          end
      end;
    false ->
      case maps:find(list_to_binary(Operator), RulesByOp) of
        {ok, Value} -> %% Ok
          utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [Value]]),
          {"+" ++ CommonRules#common_rules.local_cc ++ binary_to_list(Value) ++ Tel, Operator};
        error ->  %%% Invalid
          utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["not_found", Operator]]),
          case maps:find(list_to_binary(PhoneContext), RulesByOp) of
            {ok, Value} -> %% Ok
              utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["found",Value]]),
              {"+" ++ CommonRules#common_rules.local_cc ++ binary_to_list(Value) ++ Tel, PhoneContext};
            error ->  %%% Invalid
              utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["not_found", PhoneContext]]),
              {failed, []}
          end
      end
  end;

getCC(_Tel, _PContext, _OP, _Rules) ->
  {failed, []}.

getOP({ACCodeCD,ACCodeDD, Tel}, #state{rules_by_num = RulesByNum, debug = DebugTag, common_rules = CommonRules})->
  utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["CCCode", ACCodeCD, ACCodeDD, Tel]]),
  case maps:find(list_to_binary(ACCodeDD), RulesByNum) of
    {ok, Value} -> %% Ok
      utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [Value]]),
      RefLen = CommonRules#common_rules.ac_mobile + length(CommonRules#common_rules.local_cc) + CommonRules#common_rules.num_len,
      if
        RefLen == length(Tel) ->
          {"+" ++ Tel, binary_to_list(Value)};
        true -> {failed, undefined}
      end;
    error ->  %%% Invalid
      case maps:find(list_to_binary(ACCodeCD), RulesByNum) of
        {ok, Value} -> %% Ok
          utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [Value]]),
          RefLen = CommonRules#common_rules.ac_fixed + length(CommonRules#common_rules.local_cc) + CommonRules#common_rules.num_len,
          if
            RefLen == length(Tel) ->
              {"+" ++ Tel, binary_to_list(Value)};
            true -> {failed, undefined}
          end;
        error ->  %%% Invalid
          {failed, undefined}
      end
  end;
getOP(_Context, _Data) ->
  {failed, undefined}.

get_context({Tag, PhoneNumber, Op, Params}) ->
%%  io:format("  -[~p:~p] ~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, [Op]]),
  if
    Op == [] ->
      get_context(Params, #n_context{tel_number = string:trim(PhoneNumber, both), tag = Tag});
    ((Params == []) or (Params == [[]])) ->
      #n_context{tel_number = string:trim(PhoneNumber, both), operator = string:trim(Op, both), phone_context = string:trim(Op, both), tag = Tag};
    true ->
%%      io:format("  -[~p:~p] ~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, [Params]]),
      get_context(Params, #n_context{tel_number = string:trim(PhoneNumber, both), operator = string:trim(Op, both), tag = Tag})
  end.
get_context([], NumContext) -> NumContext;
get_context([Head|Tail], NumContext = #n_context{operator = Op}) ->
  [RawKey|RawValue] = string:split(Head, "="),
  Key = string:trim(RawKey, both),
  Value = string:trim(RawValue, both),
  if
    Key == "phone-context" ->
      [Context|Operator] = string:split(Value, "@"),
%%      io:format("  -[~p:~p] ~p~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, Context, Operator]),
      if
        Operator == [] ->
          get_context(Tail, NumContext#n_context{phone_context = Context});
        true ->
          [Opp] = Operator,
%%          io:format("  -[~p:~p] ~p~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, [Op], [Opp]]),
          if
            ((Op == []) or (Op == undefined)) ->
              get_context(Tail, NumContext#n_context{phone_context = Context, operator = Opp});
            Op =/= Opp ->
              get_context(Tail, NumContext#n_context{phone_context = Context, operator = []});
            true ->
              get_context(Tail, NumContext#n_context{phone_context = Context})
          end
      end;
    Key == "user" ->
      get_context(Tail, NumContext#n_context{user = Value});
    true -> get_context(Tail, NumContext)
  end.
preHandleSpecialRules(TelPhone, Data) ->
  SpecRules = maps:to_list(Data#state.spec_rules),
  LocalCC = Data#state.common_rules#common_rules.local_cc,
  handleSpecialRules(LocalCC, TelPhone, SpecRules).

handleSpecialRules(_LocalCC,_TelPhone, []) ->
  nomatch;
handleSpecialRules(LocalCC, TelPhone, [{Key, Value}|Tail]) ->
  case re:run(TelPhone, binary_to_list(Key)) of
    {match,_} ->
%%      io:format("  -[~p:~p] ~p~n", [?MODULE, ?FUNCTION_NAME, ?LINE, [binary_to_list(Key)]]),
      if
        Value == <<"international">> ->
          case re:run(TelPhone, binary_to_list(Key) ++ LocalCC) of
            {match, _} -> nomatch;
            _Other     ->
              Normalized = re:replace(TelPhone, binary_to_list(Key), "+", [{return,list}]),
              {ok, Normalized, binary_to_list(Value)}
          end;
        true ->
          {ok, "+" ++ LocalCC ++ TelPhone, binary_to_list(Value)}
      end;
    nomatch    -> handleSpecialRules(LocalCC, TelPhone, Tail)
  end.

handleNormalRules(Context = #n_context{tel_number = TelPhone, phone_context = PhoneContext, operator = Operator}, Rules = #state{debug = DebugTag, common_rules = CommonRules}) ->
  NumSize = length(TelPhone), utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["NumSize", NumSize]]),
  if
    NumSize == CommonRules#common_rules.num_len ->
      utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["DK6", PhoneContext, Operator]]),
      {Tel_OK, NewOP} = getCC(TelPhone, PhoneContext, Operator, Rules);
    NumSize > CommonRules#common_rules.num_len  ->
      utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, ["^" ++ CommonRules#common_rules.local_cc, TelPhone]]),
      Tel = case re:run(TelPhone, "^" ++ CommonRules#common_rules.local_cc) of
                              {match,_} ->
                                TelPhone;
                              _Other ->
                                re:replace(TelPhone, "^", CommonRules#common_rules.local_cc,[{return,list}])
                            end,
      Prefix = length(CommonRules#common_rules.local_cc) + 1,
      RefACFixed = string:sub_string(Tel, Prefix, Prefix + CommonRules#common_rules.ac_fixed - 1),
      RefACMobile = string:sub_string(Tel, Prefix, Prefix + CommonRules#common_rules.ac_mobile -1),
      utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [{RefACFixed, RefACMobile, Tel}]]),
      {Tel_OK, NewOP} = getOP({RefACFixed, RefACMobile, Tel}, Rules);
    true ->
      {Tel_OK, NewOP} = {failed, undefined}
  end,
  utils:buggyOla(DebugTag, [?MODULE, ?FUNCTION_NAME, ?LINE, [NewOP]]),
  Context#n_context{operator = NewOP, tel_number = Tel_OK}.