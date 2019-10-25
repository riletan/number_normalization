%%%-------------------------------------------------------------------
%%% @author rilt
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Oct 2019 4:42 PM
%%%-------------------------------------------------------------------
-author("rilt").

-define(CONF, "../include/config.json").
-define(INP, "../io/input.txt").
-define(OUTP, "../io/output.txt").
-define(DEFAULT_CC, "84").
-define(DEFAULT_NUM_LEN, "7").
-define(DEFAULT_MAX_NUM_LEN, "15").
-define(DEFAULT_AC_FIXED, "3").
-define(DEFAULT_AC_MOBILE, "2").
-define(SERVER, number_stuff_server).

-record(n_context, {
  tag = "",
  phone_context = "",
  operator = "",
  tel_number = "",
  user="phone"
  }).

-record(common_rules, {
  local_cc,
  num_len,
  max_num_len,
  ac_fixed,
  ac_mobile
}).