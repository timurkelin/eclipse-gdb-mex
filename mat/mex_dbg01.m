% Tests for BPTC decoder 

clear all;
close all;

global gDebugMexCall01;
global gDebugMexCall02;
global gDebugMexCall03;
global gDebugConfig;

k = 1;
gDebugMexCall01 = k; k = k + 1;
gDebugMexCall02 = k; k = k + 1;
gDebugMexCall03 = k; k = k + 1;
gDebugConfig = zeros( 1, k - 1 );

if strcmp( getenv('MATLAB_DEBUG'), 'gdb' )
	gDebugConfig( gDebugMexCall01 ) = 0;
	gDebugConfig( gDebugMexCall02 ) = 1;
	gDebugConfig( gDebugMexCall03 ) = 0;
end

run_file = mfilename('fullpath');
[run_fpath, run_fname, run_fext] = fileparts( run_file );

fprintf( '***************************************\n' );
fprintf( '%s.%s\n', run_fname, run_fext );
fprintf( 'Start @ %s\n', datestr( now()));
fprintf( '***************************************\n' );

if sum( gDebugConfig )
	fprintf( 2, 'MEX debug configuration.\n' );
	addpath( [run_fpath filesep '../mex/Debug'  ] );
else
	addpath( [run_fpath filesep '../mex/Release'] );
end

% mex debug prologue
if gDebugConfig( gDebugMexCall01 )
	clear( 'myFirstMex' ); dbmex on;
end

a = myFirstMex();

% mex debug epilogue
if gDebugConfig( gDebugMexCall01 )
	clear( 'myFirstMex' ); dbmex off;
end

disp( 'MEX Call 01 result:' );
disp( a );

% mex debug prologue
if gDebugConfig( gDebugMexCall02 )
	clear( 'myFirstMex' ); dbmex on;
end

b = myFirstMex(); % We are going to debug function at this call

% mex debug epilogue
if gDebugConfig( gDebugMexCall02 )
	clear( 'myFirstMex' ); dbmex off;
end

disp( 'MEX Call 02 result:' );
disp( b );

% mex debug prologue
if gDebugConfig( gDebugMexCall03 )
	clear( 'myFirstMex' ); dbmex on;
end

c = myFirstMex();

% mex debug epilogue
if gDebugConfig( gDebugMexCall03 )
	clear( 'myFirstMex' ); dbmex off;
end

disp( 'MEX Call 03 result:' );
disp( c );

disp( [a, b, c] );

fprintf( 'Stop  @ %s\n', datestr( now()));

