% Stores functions to be used by students
-module(util).

% -export([readFile/1, get_all_lines/1, saveFile/2, strToAtom/1, ualToAddr/1, ualToAtom/1,
%          getUAL/0, print_addrs/1, split_string_chunks/2, get_chunk_name/2, map_list_append/3,
%          resolve_global_name/2]).
-export([readFile/1, get_all_lines/1, saveFile/2, print_addrs/1, split_string_chunks/2, get_chunk_name/2, map_list_append/3, resolve_global_name/2]).

% Function in here can be called in main.erl by doing (for example):
% util:saveFile(path/to/file.txt, "string")


% main, dirService, fileService
% saves a String to a file located at Location
saveFile(Location, String) ->
    file:write_file(Location, String).

% main, fileService
% returns the contents of a file located at FileName
readFile(FileName) ->
    {ok, Device} = file:open(FileName, [read]),         % http://erlang.org/doc/man/file.html#open-2
    try
        get_all_lines(Device)
    after
        file:close(Device)
    end.

% Helper function for readFile
get_all_lines(Device) ->
    case io:get_line(Device, "") of             % http://erlang.org/doc/man/io.html#get_line-2
        eof ->
            [];
        Line ->
            [Line | get_all_lines(Device)]
    end.

% dirService:dir_service_evl
split_string_chunks(L, N) when N > 0, N < length(L) ->
    H = string:slice(L, 0, N),
    T = split_string_chunks(string:slice(L, N), N),
    [H | T];
split_string_chunks(L, _) ->
    [L].

% dirService:send_chunks, fileService:file_service_evl
get_chunk_name(Fname, Index) ->
    [Name, Ext] = string:split(Fname, "."),
    ChunkExt =
        lists:flatten(
            io_lib:fwrite("_~b.~s", [Index, Ext])),
    lists:flatten(
        lists:append(Name, ChunkExt)).

% dirService
map_list_append(Map, Key, Value) ->
    maps:update_with(Key, fun(V) -> lists:append(V, [Value]) end, [Value], Map).


% main, dirService (print helper)       % does not work in Python terminal
print_addrs(helper, []) ->
    "";
print_addrs(helper, [H | T]) ->
    io_lib:fwrite("~w ~s", [H, print_addrs(helper, T)]).
print_addrs(L) ->
    io:fwrite("[ ~s ]~n", [print_addrs(helper, L)]).


    
% main, dirService, fileService
resolve_global_name(UAL, Node) ->
    net_adm:ping(Node),                     % http://erlang.org/doc/man/net_adm.html#ping-1
    PID = global:whereis_name(UAL),         % http://erlang.org/doc/man/global.html#whereis_name-1
    case PID of
        undefined ->
            timer:sleep(100),
            resolve_global_name(UAL, Node);
        _ ->
            PID
    end.



% strToAtom(Str) ->
%     list_to_atom(lists:flatten(Str)).

% ualToAtom(UAL) ->
%     strToAtom(io_lib:fwrite("~w", [UAL])).

% ualToAddr(UAL) ->
%     {ualToAtom(UAL), UAL}.

% getUAL() ->
%     lists:flatten(
%         io_lib:fwrite("~w", [node()])).
