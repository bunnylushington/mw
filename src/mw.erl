%% -*- mode: erlang -*-

-module(mw).
-export([
          template/1
        , is_development/0
        ]).

-spec template(file:name_all()) -> file:filename_all().
template(File) ->
  filename:join([code:priv_dir(mw), templates, File]).

-spec is_development() -> boolean().
is_development() -> 
  application:get_env(mw, development_mode, false).
