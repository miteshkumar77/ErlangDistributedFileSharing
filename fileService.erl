-module(fileService).
-export([file_service_evl/1]).

server_path(FName) ->
    {ok, CWD} = file:get_cwd(),
    Path = lists:flatten(io_lib:fwrite("~s/servers/~w/~s", [CWD, node(), FName])),
    Path.

file_service_evl(evl, DirUAL) ->
    receive
        quit ->
            init:stop(0);
        {saveChunk, ChunkName, ChunkContents} ->
            io:fwrite("Received chunk, name: ~s, contents: ~s~n", [ChunkName, ChunkContents]),
            ok = util:saveFile(server_path(ChunkName), ChunkContents),
            file_service_evl(evl, DirUAL);
        {requestChunk, FName, Index, ClientAddr} ->
            ClientAddr ! {chunkData, Index, util:readFile(server_path(util:get_chunk_name(FName, Index)))},
            file_service_evl(evl, DirUAL);
        _->
            % io:fwrite("FS: ~w DS: ~w, Got a message.~n", [self(), DirUAL]),
            file_service_evl(evl, DirUAL)
    end.

file_service_evl(DirUAL) ->
    true = register(node(), self()),
    % io:fwrite("Begin file_service_evl~n"),
    ok = filelib:ensure_dir(server_path("drink_ensure.txt")),
    {DirUAL, DirUAL} ! {fsAddr, node()},
    file_service_evl(evl, DirUAL).