%% -*- mode: erlang -*-

-module(index).
-include_lib("nitrogen_core/include/wf.hrl").
-export([main/0, title/0, body/0]).
-export([start_receiver/0, receiver/0]).

main() -> 
  #template { file=mw:template("index.html") }.

title() -> "Welcome to mw".

body() -> 
  wf:wire(#comet{
             scope=global,
             pool=index,
             function=fun() -> start_receiver() end}),
  #panel{ body=[ meter(power), meter(attention), 
                 meter(meditation), meter(blink) ] }.

meter(Which) -> meter(Which, 0).

meter(Which, Pct) -> #panel{ id=Which, body=[Which, ": ", wf:to_list(Pct)] }.

start_receiver() -> 
  process_flag(trap_exit, true),
  gen_event:add_handler(mw_event:manager_pid(), mw_event_callback, []),
  receiver().

receiver() -> 
  receive 
    'INIT' -> 
      ?PRINT("Started receiver");

    {esense, Data, Signal} -> 
      ?PRINT("received esense"),
      wf:replace(attention,
                 meter(attention, maps:get(<<"attention">>, Data, "NA"))),
      wf:replace(meditation, 
                 meter(meditation, maps:get(<<"meditation">>, Data, "NA"))),
      wf:replace(power, meter(power, Signal));

    {blink, Strength} -> 
      ?PRINT("received blink"),
      wf:replace(blink, meter(blink, Strength));

    {'EXIT', _, Message} -> 
      ?PRINT("The user left the page: " ++ Message),
      gen_event:delete_handler(mw_event:manager_pid(), mw_event_callback, []),
      exit(done)
  end,
  wf:flush(),
  ?MODULE:receiver().
      

 
                     
  
