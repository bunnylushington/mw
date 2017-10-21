-module(mw_event).

-export([ 
          start_link/0
        , manager_pid/0
        , blink/1
        , esense/2
        ]).

-define(MW_EVENT, mw_event).

start_link() -> 
  {ok, PID} = gen_event:start_link(),
  register(?MW_EVENT, PID).

manager_pid() -> 
  whereis(?MW_EVENT).

blink(Strength) -> 
  gen_event:notify(manager_pid(), {blink, Strength}).

esense(Data, SignalLevel) -> 
  gen_event:notify(manager_pid(), {esense, Data, SignalLevel}).
