//
//  hmsl_midi.m
//  HMSL-OSX
//
//  Contributors:
//     1997 Robert Marsanyi
//     2015 Andrew C Smith
//     2019 Phil Burk
//

#include <unistd.h>

#include "../JuceLibraryCode/JuceHeader.h"

#import "hmsl_host.h"
#import "pf_all.h"

static int64_t sHmslStartTime;
static int64_t sHmslTickOffset;
static int64_t sHmslTicksPerSecond;

void hostClock_Init() {
    sHmslTicksPerSecond = 60;
    hostClock_SetTime(0);
}

void hostClock_Term() {
}

static int64_t hostClock_GetHighResTicks(void) {
    return Time::getHighResolutionTicks();
}

static cell_t hostClock_HighResToLowResTicks( int64_t highResTicks ) {
    //  Convert from nanos for HMSL clock ticks
    cell_t elapsed = (cell_t) (sHmslTicksPerSecond * (highResTicks - sHmslStartTime)
                               / Time::getHighResolutionTicksPerSecond());
    return elapsed + sHmslTickOffset;
}

//static int64_t hostClock_LowResTicksToHighResTicks( cell_t ticks ) {
//    cell_t elapsed = ticks - sHmslTickOffset;
//    int64_t elapsedHighResTicks = (elapsed * (int64_t) Time::getHighResolutionTicksPerSecond()) / sHmslTicksPerSecond;
//    return elapsedHighResTicks + sHmslStartTime;
//}

cell_t hostClock_QueryTime() {
    int64_t currentTime = hostClock_GetHighResTicks();
    return hostClock_HighResToLowResTicks(currentTime);
}

void hostClock_SetTime( cell_t time ) {
    sHmslStartTime = hostClock_GetHighResTicks();
    sHmslTickOffset = time;
}

void hostClock_AdvanceTime( cell_t delta ) {
    sHmslTickOffset += delta;
}

cell_t hostClock_QueryRate() {
    return sHmslTicksPerSecond;
}

void hostClock_SetRate( cell_t rate ) {
    cell_t currentTicks = hostClock_QueryTime();
    sHmslTicksPerSecond = rate;
    hostClock_SetTime(currentTicks);
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t hostMIDI_Init() {
    hostClock_Init();
    return 0;
}

// Called by HMSL to terminate the MIDI connection
void hostMIDI_Term() {
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - int, the number of bytes in the above addr array
// vtime - time in ms from the start of the scheduler to create event
//
// Returns error code (0 for no error)
cell_t hostMIDI_Write(ucell_ptr_t buffer, cell_t count, cell_t vtime) {
    // TODO unsigned char *addr = (unsigned char *)buffer;
    return 0;
}

cell_t hostMIDI_Recv( void ) {
    return 0;
}

void hostSleep( cell_t msec ) {
    usleep((useconds_t)(msec * 1000));
}

