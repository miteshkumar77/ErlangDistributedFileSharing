-module(fileService).
-export([file_service_evl/1]).

server_path(FName) ->
    {ok, CWD} = file:get_cwd(),
    %        replace with node in distributed impl               vvvv
    % Path = lists:flatten(io_lib:fwrite("~s/servers/\"~w\"/~s", [CWD, self(), FName])),
    Path = lists:flatten(io_lib:fwrite("~s/servers/~w/~s", [CWD, node(), FName])),
    Path.

file_service_evl(evl, DirUAL) ->
    receive
        quit ->
            ok;
        {saveChunk, ChunkName, ChunkContents} ->
            io:fwrite("Received chunk, name: ~s, contents: ~s~n", [ChunkName, ChunkContents]),
            ok = util:saveFile(server_path(ChunkName), ChunkContents),
            file_service_evl(evl, DirUAL);
        {requestChunk, FName, Index, ClientAddr} ->
            ClientAddr ! {chunkData, Index, util:readFile(server_path(util:get_chunk_name(FName, Index)))},
            file_service_evl(evl, DirUAL);
        _->
            io:fwrite("FS: ~w DS: ~w, Got a message.~n", [self(), DirUAL]),
            file_service_evl(evl, DirUAL)
    end.

file_service_evl(DirUAL) ->
    DirPID = global:whereis_name(DirUAL),
    case DirPID of
        undefined -> 
            timer:sleep(100),
            file_service_evl(DirUAL);
        _ ->
            io:fwrite("Begin file_service_evl~n"),
            ok = filelib:ensure_dir(server_path("drink_ensure.txt")),
            global:send(DirUAL, {fsAddr, self()}),
            file_service_evl(evl, DirUAL)
    end.