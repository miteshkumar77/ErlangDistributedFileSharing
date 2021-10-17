-module(main).
% main functions
-export([start_file_server/1, start_dir_service/0, get/2, create/2, quit/1,test/0]).

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
	register(node(), PID),
	io:fwrite("Registered dir service on PID: ~w as ~w~n", [PID, node()]).
% starts a file server with the UAL of the Directory Service
start_file_server(DirUAL) ->
	spawn(fileService, file_service_evl, [DirUAL]).





% requests file information from the Directory Service (DirUAL) on File
% then requests file parts from the locations retrieved from Dir Service
% then combines the file and saves to downloads folder

% 3. 	The client requests a particular file from the directory service.
% 		The directory service replies with the block names and their locations.
% 4. 	The client requests a particular block from each file server concurrently.
% 5. 	The file servers respond with the requested blocks.
% 6. 	The client reassembles them into the original file.
% 		The file must be written to a folder named downloads.
get(DirUAL, File) ->
	pass.
	% CODE THIS
	

	% file:list_dir(".")  % current working directory,
	% {ok,["helloworld.erl",".cg_conf","Newfile.txt","helloworld.beam"]}
	


	






% gives Directory Service (DirUAL) the name/contents of File to create

% 1. 	File name and contents are sent to the directory service.
% 		The file must be located in a folder named input.
% 2. 	Directory server splits file into 64 character blocks and distributes it to the file servers.
% 		The servers save their blocks to directories named after themselves.
create(DirUAL, File) ->
	pass.
	% CODE THIS

	% https://riptutorial.com/erlang/example/18563/reading-from-a-file
	% file:read_file("_ .txt").
	% {ok,<<"summer has come and passed\r\nthe innocent can never last\r\nWake me up when september ends\r\n">>}
	
	% http://erlang.org/doc/man/string.html#substr-3
	% string:substr(String, Start, Length)
	% string:len(S)


% sends shutdown message to the Directory Service (DirUAL)
quit(DirUAL) ->
	pass.
	% CODE THIS




test() ->
	start_dir_service(),
	start_file_server(node()),
	start_file_server(node()),
	start_file_server(node()),
	start_file_server(node()),
	start_file_server(node()),
	timer:sleep(1000),
	node() ! {saveFile, "main.txt", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}.
