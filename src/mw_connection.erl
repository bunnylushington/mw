-module(mw_connection).
-behaviour(gen_server).

-define(SERVER, ?MODULE).
-define(DEF_CONNECTOR_HOSTNAME, "127.0.0.1").
-define(DEF_CONNECTOR_PORT, 13854).
-define(
   CONNECTOR_INIT_MSG,
   "{\"enableRawOutput\": false, \"format\": \"Json\"}\n"
).

-record(state, { socket }).

-export([start_link/1, stop/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


stop() -> 
  gen_server:call(?SERVER, stop).

start_link(Config) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, Config, []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(_) ->
  Hostname = ?DEF_CONNECTOR_HOSTNAME,
  Port = ?DEF_CONNECTOR_PORT,
  {ok, Socket} = gen_tcp:connect(
                   Hostname, Port, [binary, {packet, 0}]
                  ),
  gen_tcp:send(Socket, ?CONNECTOR_INIT_MSG),
  State = #state{ socket = Socket},
  {ok, State}.

handle_call(stop, _From, State) ->
  {stop, normal, State};
handle_call(_Request, _From, State) ->
  {noreply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({tcp, _Port, Data}, State) ->
  lists:map(
    fun(Packet) ->
        Bin = list_to_binary(Packet),
        case jsx:is_json(Bin) of
          true -> decode_json(Bin);
          false -> ok
        end
    end,
    re:split(Data, "\r",[{return,list},trim])),
  {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
  {stop, normal, State};
handle_info({tcp_error, _Socket, Reason}, State) ->
  Reason1 = {tcp_error, Reason},
  {stop, Reason1, State};
handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, State) ->
  gen_tcp:close(State#state.socket),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%% %% ------------------------------------------------------------------
%% %% private Function Definitions
%% %% ------------------------------------------------------------------

decode_json(In) -> 
  Data = jsx:decode(In, [return_maps]),
  publish(Data).

publish(#{ <<"blinkStrength">> := BS }) ->
  mw_event:blink(BS);
publish(#{ <<"eSense">> := ESense, <<"poorSignalLevel">> := Signal }) ->
  mw_event:esense(ESense, Signal);
publish(_) ->
  ok.

