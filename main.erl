-module(main).

% main functions
-export([start_file_server/1, start_dir_service/0, get/2, create/2, quit/1, request_chunks/3]).

% can access own ual w/ node()
% can access own PID w/ self()

% you are free (and encouraged) to create helper functions
% but note that the functions that will be called when
% grading will be those below

% when starting the Directory Service and File Servers, you will need
% to register a process name and spawn a process in another node

% starts a directory service
start_dir_service() ->
    dirService:dir_service_evl().

% starts a file server with the UAL of the Directory Service
start_file_server(DirUAL) ->
    fileService:file_service_evl(DirUAL).


download_path(FName) ->
    {ok, CWD} = file:get_cwd(),
    lists:flatten(
        io_lib:fwrite("~s/downloads/~s", [CWD, FName])).

request_chunks(_, [], _, _) ->
    ok;
request_chunks(FName, [ChunkLocation | RestLocations], ChunkIdx, ForwardAddr) ->
    {ChunkLocation, ChunkLocation} ! {requestChunk, FName, ChunkIdx, ForwardAddr},
    request_chunks(FName, RestLocations, ChunkIdx + 1, ForwardAddr).

request_chunks(FName, LocationList, ForwardAddr) ->
    request_chunks(FName, LocationList, 1, ForwardAddr).

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

get(DirUAL, FileAtom) ->
    FName = util:convertFileAtom(FileAtom),
    {DirUAL, DirUAL} ! {requestFileInfo, FName, self()},
    receive
        {fileInfo, LocationList} ->
            util:print_addrs(LocationList),
            spawn(main, request_chunks, [FName, LocationList, self()]),
            download_chunks(FName, length(LocationList))
    end.

create(DirUAL, FileAtom) ->
    FName = util:convertFileAtom(FileAtom),
    {ok, CWD} = file:get_cwd(),
    Path =
        lists:flatten(
            io_lib:fwrite("~s/input/~s", [CWD, FName])),
    FContents = util:readFile(Path),
    {DirUAL, DirUAL} ! {saveFile, FName, FContents}.

% sends shutdown message to the Directory Service (DirUAL)
quit(DirUAL) ->
    {DirUAL, DirUAL} ! quit.
