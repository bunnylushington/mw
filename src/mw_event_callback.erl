-module(mw_event_callback).
-behaviour(gen_event).

%% API
-export([start_link/0, add_handler/0]).

%% gen_event callbacks
-export([init/1, handle_event/2, handle_call/2, 
         handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
  gen_event:start_link({local, ?SERVER}).

add_handler() ->
  gen_event:add_handler(?SERVER, ?MODULE, []).

%%%===================================================================
%%% gen_event callbacks
%%%===================================================================
init([]) ->
  {ok, #state{}}.


handle_event({blink, Strength}, State) -> 
  comet_send({blink, Strength}),
  {ok, State};

handle_event({esense, Data, SignalLevel}, State) -> 
  comet_send({esense, Data, SignalLevel}),
  {ok, State};

handle_event(_Event, State) ->
  {ok, State}.




handle_call(_Request, State) ->
  Reply = ok,
  {ok, Reply, State}.

handle_info(_Info, State) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

comet_send(Msg) -> 
  nprocreg:get_pid({async_pool, {index, global}}) ! Msg.

  

