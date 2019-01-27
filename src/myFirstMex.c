#include "mex.h"
#include "proc.h"

/* The mxArray in this example is 2x2 */
#define ROWS    2
#define COLUMNS 2
#define ELEMENTS ( ROWS * COLUMNS )

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double  *pointer;          /* pointer to real data in new array */

    /* Check for proper number of arguments. */
    if ( nrhs != 0 ) {
        mexErrMsgIdAndTxt("MATLAB:arrayFillGetPr:rhs","This function takes no input arguments.");
    }

    /* Create an m-by-n mxArray; you will copy existing data into it */
    plhs[0] = mxCreateNumericMatrix( ROWS, COLUMNS, mxDOUBLE_CLASS, mxREAL);
    pointer = mxGetPr( plhs[0] );

    /* Copy data into the mxArray */
    proc( pointer );

    return;
}
