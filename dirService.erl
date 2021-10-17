-module(dirService).
-export([dir_service_evl/0]).

send_chunks([ChunkContents|RestChunks], Fname, Index, FileServers, ChunkMap) ->
    NthServer = lists:nth(((Index - 1) rem length(FileServers)) + 1, FileServers),
    ChunkName = util:get_chunk_name(Fname, Index),
    NthServer ! {saveChunk, ChunkName, ChunkContents},
    send_chunks(RestChunks, Fname, Index+1, FileServers, util:map_list_append(ChunkMap, Fname, NthServer));


send_chunks([], _, _, _, ChunkMap) ->
    ChunkMap.
    
send_chunks(Chunks, Fname, FileServers, ChunkMap) ->
    send_chunks(Chunks, Fname, 1, FileServers, ChunkMap).

send_quit_all_FS([]) ->
    ok;
send_quit_all_FS([FileServer | Rest]) ->
    FileServer ! quit,
    send_quit_all_FS(Rest).

dir_service_evl(FileServers, ChunkMap) ->
    receive
        quit ->
            send_quit_all_FS(FileServers),
            ok;
        {fsAddr, FsName} -> 
            util:print_addrs(lists:append(FileServers, [FsName])),
            dir_service_evl(lists:sort(lists:append(FileServers, [FsName])), ChunkMap);
        {saveFile, FName, FContents} ->
            Chunks = util:split_string_chunks(lists:flatten(FContents), 64),
            dir_service_evl(FileServers, send_chunks(Chunks, FName, FileServers, ChunkMap));
        {requestFileInfo, FName, ClientAddr} ->
            ClientAddr ! {fileInfo, maps:get(FName, ChunkMap)},
            dir_service_evl(FileServers, ChunkMap);
        _ ->
            dir_service_evl(FileServers, ChunkMap)
    end.

dir_service_evl() ->
    io:fwrite("Begin dir_service_evl~n"),
    dir_service_evl([], #{}).

    