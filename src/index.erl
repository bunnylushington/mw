%% -*- mode: erlang -*-

-module(index).
-include_lib("nitrogen_core/include/wf.hrl").
-export([main/0, title/0, body/0]).

main() -> 
  gen_event:add_handler(mw_event:manager_pid(), mw_event_callback, []),
  #template { file=mw:template("index.html") }.

title() -> "Welcome to mw".

body() -> 
  wf:comet(fun() -> update_guage(power) end),
  #panel{ body=[ meter(power), meter(attention), meter(meditation) ] }.

meter(Which) -> meter(Which, 0).

meter(Which, Pct) -> 
  #panel{ class="GaugeMeter",
          id=Which,
          data_fields=data(Which, Pct) }.

data(Which, Pct) -> 
  [{label, Which},
   {text, " "},
   {size, 200},
   {percent, Pct},
   {style, "Semi"}].
  
update_guage(Which) -> 
  timer:sleep(1000),
  NewPct = rand:uniform(100),
  ?PRINT(NewPct),
  wf:update(Which, meter(Which, NewPct)),
  wf:flush().
