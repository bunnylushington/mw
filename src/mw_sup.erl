%% -*- mode: erlang -*-

-module(mw_sup).

-behaviour(supervisor).

-export([ start_link/0
        , init/1
        , build_dispatch/0 ]).


-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

build_dispatch() ->
  {_Root, Paths} = simple_bridge_util:get_docroot_and_static_paths(cowboy),
  build_dispatch(Paths).

%%====================================================================
%% Supervisor callbacks
%%====================================================================
init([]) ->
  lists:foreach(fun(App) -> ok= application:ensure_started(App) end,
                [ crypto
                , nprocreg
                , simple_bridge
                ]),
  MWEvent = #{ id => mw_event, 
               start => {mw_event, start_link, []} },
  MWConnection = #{ id => mw_connection,
                    start => {mw_connection, start_link, [ok]} },
               
  {ok, { {one_for_one, 5, 10}, [MWEvent, MWConnection]} }.

%%====================================================================
%% Internal functions
%%====================================================================
build_dispatch(StaticPaths) ->
  StaticDispatches = lists:map(fun(Dir) ->
    Opts = [{mimetypes, cow_mimetypes, all}],
    Path = reformat_path(Dir),
    {Type, RelPath} = localized_dir_file(Dir),
    {Path, cowboy_static, {Type, mw, RelPath, Opts}}
  end, StaticPaths),
  HandlerModule = simple_bridge_util:get_anchor_module(cowboy),
  HandlerOpts = [],
  Dispatch = [{'_', StaticDispatches ++ [{'_', HandlerModule , HandlerOpts}]}],
  cowboy_router:compile(Dispatch).

reformat_path(Path) ->
  Path2 = case hd(Path) of
    $/ -> Path;
    $\ -> Path;
    _ -> [$/|Path]
  end,
  Path3 = case lists:last(Path) of 
    $/ -> Path2 ++ "[...]";
    $\ -> Path2 ++ "[...]";
    _ -> Path2
  end,
  Path3.

localized_dir_file(Path) ->
  NewPath = case hd(Path) of
    $/ -> "static" ++ Path;
    _ ->  "static" ++ "/" ++ Path
  end,
  _NewPath2 = case lists:last(Path) of
    $/ -> {priv_dir, NewPath};
    _ ->  {priv_file, NewPath}
  end.
