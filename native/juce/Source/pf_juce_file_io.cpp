/***************************************************************
 ** I/O subsystem for PForth based on 'C'
 **
 ** Author: Phil Burk
 ** Copyright 1994 3DO, Phil Burk, Larry Polansky, David Rosenboom
 **
 ** The pForth software code is dedicated to the public domain,
 ** and any third party may reproduce, distribute and modify
 ** the pForth software code or any derivative works thereof
 ** without any compensation or license.  The pForth software
 ** code is provided on an "as is" basis without any warranty
 ** of any kind, including, without limitation, the implied
 ** warranties of merchantability and fitness for a particular
 ** purpose and their equivalents under the laws of any jurisdiction.
 **
 ***************************************************************/

#include "pf_all.h"

#include "../JuceLibraryCode/JuceHeader.h"
#include "HostFileManager.h"

FileStream *sdOpenFile( const char *fileName, const char *mode ) {
    return HostFileManager::getInstance()->openFile(fileName, mode);
}
