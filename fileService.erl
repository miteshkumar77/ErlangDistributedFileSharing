-module(fileService).
-export([file_service_evl/1]).

file_service_evl(evl, DirUAL) ->
    receive
        _->
            io:fwrite("FS: ~w DS: ~w, Got a message.~n", [node(), DirUAL])
    end.

file_service_evl(DirUAL) ->
    global:send(DirUAL, node()),
    file_service_evl(evl, DirUAL).