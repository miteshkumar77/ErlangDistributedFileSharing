-module(dirService).
-export([dir_service_evl/0]).

send_chunks([ChunkContents|RestChunks], Fname, Index, FileServers, ChunkMap) ->
    NthServer = lists:nth(((Index - 1) rem length(FileServers)) + 1, FileServers),      % http://erlang.org/doc/man/lists.html#nth-2
    ChunkName = util:get_chunk_name(Fname, Index),
    global:send(NthServer, {saveChunk, ChunkName, ChunkContents}),                      % http://erlang.org/doc/man/global.html#send-2
    send_chunks(RestChunks, Fname, Index+1, FileServers, util:map_list_append(ChunkMap, Fname, NthServer));
send_chunks([], _, _, _, ChunkMap) ->
    ChunkMap.
send_chunks(Chunks, Fname, FileServers, ChunkMap) ->
    send_chunks(Chunks, Fname, 1, FileServers, ChunkMap).

send_quit_all_FS([]) ->
    ok;
send_quit_all_FS([FileServer | Rest]) ->
    global:send(FileServer, quit),
    send_quit_all_FS(Rest).


% helper
dir_service_evl(FileServers, ChunkMap) ->
    receive
        quit ->
            send_quit_all_FS(FileServers),
            init:stop(0);
        {fsAddr, FsName} -> 
            util:resolve_global_name(FsName, FsName),
            % util:print_addrs(lists:append(FileServers, [FsName])),
            dir_service_evl(lists:sort(lists:append(FileServers, [FsName])), ChunkMap);
        {saveFile, FName, FContents} ->
            Chunks = util:split_string_chunks(lists:flatten(FContents), 64),        % http://erlang.org/doc/man/lists.html#flatten-1
            dir_service_evl(FileServers, send_chunks(Chunks, FName, FileServers, ChunkMap));
        {requestFileInfo, FName, ClientAddr} ->
            ClientAddr ! {fileInfo, maps:get(FName, ChunkMap)},                 % http://erlang.org/doc/man/maps.html#get-2
            dir_service_evl(FileServers, ChunkMap);
        _ ->
            dir_service_evl(FileServers, ChunkMap)
    end.


% main
dir_service_evl() ->
    % io:fwrite("Begin dir_service_evl~n"),
    global:register_name(node(), self()),                   % http://erlang.org/doc/man/global.html#register_name-2
    dir_service_evl([], #{}).

    