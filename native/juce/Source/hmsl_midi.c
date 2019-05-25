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

#import "hmsl_host.h"
#import "pf_all.h"

#define NANOS_PER_SECOND 1000000000
static int64_t sHmslStartTime;
static int64_t sHmslTickOffset;
static int64_t sHmslTicksPerSecond;

void hostClock_Init() {
    hostClock_SetTime(0);
    sHmslTicksPerSecond = 60;
}

void hostClock_Term() {
}

static int64_t hostClock_GetNanoseconds(void) {
    return 0; // TODO
}

static cell_t hostClock_NanosecondsToTicks( int64_t nanoseconds ) {
    //  Convert from nanos for HMSL clock ticks
    cell_t elapsed = (cell_t) (sHmslTicksPerSecond * (nanoseconds - sHmslStartTime) / NANOS_PER_SECOND);
    return elapsed + sHmslTickOffset;
}


static int64_t hostClock_TicksToNanoseconds( cell_t ticks ) {
    cell_t elapsed = ticks - sHmslTickOffset;
    uint64_t elapsedNanos = (elapsed * (uint64_t) NANOS_PER_SECOND) / sHmslTicksPerSecond;
    return elapsedNanos + sHmslStartTime;
}

cell_t hostClock_QueryTime() {
    int64_t currentTime = hostClock_GetNanoseconds();
    return hostClock_NanosecondsToTicks(currentTime);
}

void hostClock_SetTime( cell_t time ) {
    sHmslStartTime = hostClock_GetNanoseconds();
    sHmslTickOffset = time;
}

void hostClock_AdvanceTime( cell_t delta ) {
    sHmslTickOffset += delta;
}

cell_t hostClock_QueryRate() {
    return sHmslTicksPerSecond;
}

void hostClock_SetRate( cell_t rate ) {
    int currentTicks = hostClock_QueryTime();
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
  usleep(msec * 1000);
}

