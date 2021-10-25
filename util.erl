% Stores functions to be used by students
-module(util).

-export([convertFileAtom/1, readFile/1, get_all_lines/1, saveFile/2, strToAtom/1, ualToAddr/1, ualToAtom/1,
         getUAL/0, print_addrs/1, split_string_chunks/2, get_chunk_name/2, map_list_append/3,
         resolve_global_name/2]).

% Function in here can be called in main.erl by doing (for example):
% util:saveFile(path/to/file.txt, "string")

trimBegin(FileAtom) ->
    Fst = string:substr(FileAtom, 1, 1),
    io:fwrite("~s~n", [Fst]),
    if
    Fst == "'" ->
        string:substr(FileAtom, 2);
    true ->
        FileAtom
    end.
trimEnd(FileAtom) ->
    Lst = string:substr(FileAtom, length(FileAtom)),
    io:fwrite("~s~n", [Lst]),
    if 
    Lst == "'" ->
        string:substr(FileAtom, 1, length(FileAtom) - 1);
    true ->
        FileAtom
    end.
convertFileAtom(FileAtom)->
    TMP = lists:flatten(io_lib:fwrite("~w", [FileAtom])),
    io:fwrite("FTOATOM: ~s~n", [TMP]),
    lists:flatten(io_lib:fwrite("~s", [trimBegin(trimEnd(TMP))])).


% saves a String to a file located at Location
saveFile(Location, String) ->
    file:write_file(Location, String).

% returns the contents of a file located at FileName
readFile(FileName) ->
    io:fwrite("Reading File: ~s~n", [FileName]),
    {ok, Device} = file:open(FileName, [read]),
    try
        get_all_lines(Device)
    after
        file:close(Device)
    end.

% Helper function for readFile
get_all_lines(Device) ->
    case io:get_line(Device, "") of
        eof ->
            [];
        Line ->
            Line ++ get_all_lines(Device)
    end.

split_string_chunks(L, N) when N > 0, N < length(L) ->
    {P, S} = {string:slice(L, 0, N), string:slice(L, N)},
    [P | split_string_chunks(S, N)];
split_string_chunks(L, _) ->
    [L].

get_chunk_name(Fname, Index) ->
    [Name, Ext] = string:split(Fname, "."),
    ChunkExt =
        lists:flatten(
            io_lib:fwrite("_~b.~s", [Index, Ext])),
    lists:flatten(
        lists:append(Name, ChunkExt)).

map_list_append(Map, Key, Value) ->
    maps:update_with(Key, fun(V) -> lists:append(V, [Value]) end, [Value], Map).

strToAtom(Str) ->
    list_to_atom(lists:flatten(Str)).

ualToAtom(UAL) ->
    strToAtom(io_lib:fwrite("~w", [UAL])).

ualToAddr(UAL) ->
    {ualToAtom(UAL), UAL}.

getUAL() ->
    lists:flatten(
        io_lib:fwrite("~w", [node()])).

print_addrs(helper, []) ->
    "";
print_addrs(helper, [H | T]) ->
    io_lib:fwrite("~w ~s", [H, print_addrs(helper, T)]).

print_addrs(L) ->
    io:fwrite("[ ~s ]~n", [print_addrs(helper, L)]).

resolve_global_name(UAL, Node) ->
    net_adm:ping(Node),
    PID = global:whereis_name(UAL),
    case PID of
        undefined ->
            timer:sleep(100),
            resolve_global_name(UAL, Node);
        _ ->
            PID
    end.
