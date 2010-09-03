-module(harmonia).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Env = application:get_all_env(harmonia),
    case hm_sup:start_link(Env) of
        {ok, Pid} ->
            hm_log_h_file:add_handler(
                proplists:get_value(name, Env),
                proplists:get_value(logfile, Env)
            ),
            {ok, Pid};
        Other ->
            {error, Other}
    end.

stop(_State) ->
    ok.

