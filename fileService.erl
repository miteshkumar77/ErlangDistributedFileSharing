-module(fileService).
-export([file_service_evl/1]).

server_path(FName) ->
    {ok, CWD} = file:get_cwd(),
    %        replace with node in distributed impl               vvvv
    Path = lists:flatten(io_lib:fwrite("~s/servers/\"~w\"/~s", [CWD, self(), FName])),
    ok = filelib:ensure_dir(Path),
    Path.

file_service_evl(evl, DirUAL) ->
    receive
        {chunk, ChunkName, ChunkContents} ->
            io:fwrite("Received chunk, name: ~s, contents: ~s~n", [ChunkName, ChunkContents]),
            ok = util:saveFile(server_path(ChunkName), ChunkContents);
        _->
            io:fwrite("FS: ~w DS: ~w, Got a message.~n", [self(), DirUAL]),
            file_service_evl(evl, DirUAL)
    end.

file_service_evl(DirUAL) ->
    io:fwrite("Begin file_service_evl~n"),
    DirUAL ! {fsAddr, self()},

    file_service_evl(evl, DirUAL).