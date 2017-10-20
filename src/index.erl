%% -*- mode: erlang -*-

-module(index).
-include_lib("nitrogen_core/include/wf.hrl").
-export([main/0, title/0, body/0]).

main() -> #template { file=mw:template("index.html") }.

title() -> "Welcome to mw".

body() -> "Just a sample page.".
