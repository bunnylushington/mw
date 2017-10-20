%% -*- mode: erlang -*-

%%%-------------------------------------------------------------------
%% @doc mw public API
%% @end
%%%-------------------------------------------------------------------

-module(mw_app).

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    mw_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================