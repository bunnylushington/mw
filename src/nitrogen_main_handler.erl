%% -*- mode: erlang -*-
-module(nitrogen_main_handler).
-export([
         run/0,
         ws_init/0
        ]).

handlers() ->
  nitrogen:handler(mw_config_handler, []),

  case mw:is_development() of
    true -> nitrogen:handler(debug_crash_handler, []);
    false -> ok
  end,
  ok.

ws_init() ->
  handlers().

run() ->
  handlers(),
  wf_core:run().
