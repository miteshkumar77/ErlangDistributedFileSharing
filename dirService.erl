-module(dirService).
-export([dir_service_evl/0]).

print_addrs([]) ->
    "~n";
print_addrs([H|T]) ->
    io_lib:fwrite("~s ~s", [atom_to_list(H), print_addrs(T)]).

dir_service_evl() ->
    dir_service_evl([]).
dir_service_evl(file_servers) ->
    receive
        {fsAddr, FsPID, FsAddr} -> 
            register(util:ualToAtom(FsAddr), FsPID),
            print_addrs(lists:append(file_servers, [FsAddr])),
            dir_service_evl(lists:append(file_servers, [FsAddr]));
        _ ->
            dir_service_evl(file_servers)
    end.

    