-module(main).

% main functions
-export([start_file_server/1, start_dir_service/0, get/2, create/2, quit/1]).

% can access own ual w/ node()
% can access own PID w/ self()

% you are free (and encouraged) to create helper functions
% but note that the functions that will be called when
% grading will be those below

% when starting the Directory Service and File Servers, you will need
% to register a process name and spawn a process in another node

% starts a directory service
start_dir_service() ->
    PID = spawn(dirService, dir_service_evl, []),
    % register(node(), PID),
	global:register_name(node(), PID),
    io:fwrite("Registered dir service on PID: ~w as ~w~n", [PID, node()]).

% starts a file server with the UAL of the Directory Service
start_file_server(DirUAL) ->
    spawn(fileService, file_service_evl, [DirUAL]).

download_path(FName) ->
    {ok, CWD} = file:get_cwd(),
    lists:flatten(
        io_lib:fwrite("~s/downloads/~s", [CWD, FName])).

request_chunks(_, [], _) ->
    ok;
request_chunks(FName, [ChunkLocation | RestLocations], ChunkIdx) ->
    ChunkLocation ! {requestChunk, FName, ChunkIdx, self()},
    request_chunks(FName, RestLocations, ChunkIdx + 1).

request_chunks(FName, LocationList) ->
    request_chunks(FName, LocationList, 1).

download_chunks(_, NumChunks, ChunkList) when NumChunks == length(ChunkList) ->
    ChunkList;
download_chunks(FName, NumChunks, ChunkList) ->
    receive
        {chunkData, ChunkIndex, ChunkContents} when ChunkIndex == length(ChunkList) + 1 ->
            download_chunks(FName, NumChunks, lists:append(ChunkList, [ChunkContents]))
    end.

download_chunks(FName, NumChunks) ->
    util:saveFile(download_path(FName),
                  string:join(download_chunks(FName, NumChunks, []), "")).

get(DirUAL, FName) ->
    DirUAL ! {requestFileInfo, FName, self()},
    receive
        {fileInfo, LocationList} ->
            util:print_addrs(LocationList),
            request_chunks(FName, LocationList)
    end,
    download_chunks(FName, length(LocationList)).

create(DirUAL, FName) ->
    {ok, CWD} = file:get_cwd(),
    Path =
        lists:flatten(
            io_lib:fwrite("~s/input/~s", [CWD, FName])),
    FContents = util:readFile(Path),
    DirUAL ! {saveFile, FName, FContents}.

% sends shutdown message to the Directory Service (DirUAL)
quit(DirUAL) ->
    DirUAL ! quit.

% test() ->
%     start_dir_service(),
%     start_file_server(node()),
%     start_file_server(node()),
%     start_file_server(node()),
%     start_file_server(node()),
%     start_file_server(node()),
%     timer:sleep(1000),
%     create(node(), "a.txt"),
%     create(node(), "b.txt"),
%     create(node(), "bee_short.txt"),
%     timer:sleep(1000),
%     get(node(), "bee_short.txt"),
%     get(node(), "a.txt"),
%     get(node(), "b.txt"),
%     quit(node()).
