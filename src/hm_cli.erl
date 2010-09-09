-module(hm_cli).
-export([
        get/1,
        get/2,
        get/3,
        get_table_info/2,
        log_start/0,
        log_stop/0,
        make_table/3,
        store/2,
        store/3
        ]).

log_start() ->
    {ok, NameList} = gen_server:call({global, hm_name_server}, get_name_list),
    log_start_in(NameList).

log_start_in([]) -> ok;
log_start_in([{_Name, NodeName}|NodeList]) ->
    rpc:call(NodeName, hm_event_mgr, add_file_handler, []),
    log_start_in(NodeList).

log_stop() ->
    {ok, NameList} = gen_server:call({global, hm_name_server}, get_name_list),
    log_stop_in(NameList).

log_stop_in([]) -> ok;
log_stop_in([{_Name, NodeName}|NameList]) ->
    rpc:call(NodeName, hm_event_mgr, delete_file_handler, []),
    log_stop_in(NameList).

make_table(DomainName, TableName, AttList) ->
    {ok, NodeName} = get_node_name(),
    rpc:call(NodeName, hm_table, make_table, [DomainName, TableName, AttList]).

get_table_info(DomainName, TableName) ->
    {ok, NodeName} = get_node_name(),
    rpc:call(NodeName, hm_table, get_table_info, [DomainName, TableName]).

store(Key, Value) ->
    hm_ds:store(Key, Value).

store('$cache_on$', Key, Value) ->
    hm_ds:store('$cache_on$', Key, Value);
store(DomainName, TableName, KVList) ->
    hm_ds:store(DomainName, TableName, KVList).

get(Key) ->
    hm_ds:get(Key).

get('$cache_on$',Key) ->
    hm_ds:get('$cache_on$', Key).

get(DomainName, TableName, Cond) ->
    hm_ds:get(DomainName, TableName, Cond).

get_node_name() ->
    {ok, NameList} = gen_server:call({global, hm_name_server}, get_name_list),
    {_Name, NodeName} = lists:nth(random:uniform(length(NameList)), NameList),
    {ok, NodeName}.

