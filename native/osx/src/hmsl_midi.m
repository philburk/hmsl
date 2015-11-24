//
//  hmsl_midi.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "hmsl.h"
#import "pf_all.h"

#import <Foundation/Foundation.h>
#import <CoreAudio/HostTime.h>

#define PACKETLIST_SIZE 65536

MIDIEndpointRef hmslMIDISource;
MIDIEndpointRef hmslMIDIDestination;
MIDIPortRef hmslMIDIOutputPort, hmslMIDIInputPort;
MIDIClientRef hmslMIDIClient;
MIDIPacketList *hmslCurrentMIDIData;
MIDIPacket *hmslLastPacket;

// Holds the list of MIDI commands that have yet to be executed
NSMutableArray *hmslMIDIBuffer;

#define NANOS_PER_SECOND 1000000000
static UInt64 sHmslStartTime;
static UInt32 sHmslTickOffset;
static UInt32 sHmslTicksPerSecond;


void hostClock_Init( void ) {
    hostClock_SetTime(0);
    sHmslTicksPerSecond = 60;
}

void hostClock_Term( void ) {
}

static UInt64 hostClock_GetNanoseconds(void) {
    UInt64        absolute = mach_absolute_time();
    // Have to do some pointer fun because AbsoluteToNanoseconds
    // works in terms of UnsignedWide, which is a structure rather
    // than a proper 64-bit integer.
    Nanoseconds     nanoseconds = AbsoluteToNanoseconds( *(AbsoluteTime *) &absolute );
    return * (UInt64 *) &nanoseconds;
}

static int hostClock_NanosecondsToTicks( UInt64 nanoseconds ) {
    //  Convert from nanos for HMSL clock ticks
    UInt32 elapsed = (UInt32) (sHmslTicksPerSecond * (nanoseconds - sHmslStartTime) / NANOS_PER_SECOND);
    //  NSLog(@"Elapsed time: %u ms", elapsed);
    return elapsed + sHmslTickOffset;
}


static UInt64 hostClock_TicksToNanoseconds( int ticks ) {
    UInt32 elapsed = ticks - sHmslTickOffset;
    UInt64 elapsedNanos = (elapsed * (UInt64) NANOS_PER_SECOND) / sHmslTicksPerSecond;
    return elapsedNanos + sHmslStartTime;
}

int hostClock_QueryTime( void ) {
    UInt64 currentTime = hostClock_GetNanoseconds();
    return hostClock_NanosecondsToTicks(currentTime);
}

void hostClock_SetTime( int time ) {
    sHmslStartTime = hostClock_GetNanoseconds();
    sHmslTickOffset = time;
}

void hostClock_AdvanceTime( int delta ) {
    sHmslTickOffset += delta;
}

int hostClock_QueryRate( void ) {
    return sHmslTicksPerSecond;
}

void hostClock_SetRate( int rate ) {
    int currentTicks = hostClock_QueryTime();
    sHmslTicksPerSecond = rate;
    hostClock_SetTime(currentTicks);
}


NSString *getMIDIName(MIDIObjectRef object)
{
  // Returns the name of a given MIDIObjectRef as an NSString
  CFStringRef name = nil;
  if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
    return nil;
  return (NSString *)name;
}


// Callback function for the HMSL input port. +midiSourceProc+ is called
// whenever HMSL receives MIDI data from an outside source.
//
// pktlist - list of current MIDI packets in the schedule
// readProcRefCon - function to read from
// srcConnRefCon - source of the connection
//
void midiSourceProc(MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
  MIDIPacket *curPacket = pktlist->packet;
  for (int i = 0; i < pktlist->numPackets; i++) {
    // Add the new data to the buffer
    [hmslMIDIBuffer addObject: [NSData dataWithBytes:curPacket->data length:curPacket->length]];
    // Increment to next packet
    curPacket = MIDIPacketNext(curPacket);
  }
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
int hostMIDI_Init() {
  hostClock_Init();

  hmslMIDIBuffer = [NSMutableArray arrayWithCapacity:PACKETLIST_SIZE];
  
  hmslCurrentMIDIData = (MIDIPacketList*)malloc(PACKETLIST_SIZE);
  hmslLastPacket = MIDIPacketListInit(hmslCurrentMIDIData);
  
  //  NSLog(@"HMSL MIDI Init at %llu", hmslStartTime);
  
  MIDIClientCreate(CFSTR("HMSL MIDI"), NULL, NULL, &hmslMIDIClient);
  
  MIDISourceCreate(hmslMIDIClient, CFSTR("HMSL MIDI Source"), &hmslMIDISource);
  MIDIDestinationCreate(hmslMIDIClient, CFSTR("HMSL MIDI Destination"),
                        (MIDIReadProc)&midiSourceProc, NULL, &hmslMIDIDestination);
  
  MIDIInputPortCreate(hmslMIDIClient, CFSTR("HMSL MIDI Port Input"),
                      (MIDIReadProc)&midiSourceProc, NULL, &hmslMIDIInputPort);
  
  ItemCount numSources = MIDIGetNumberOfSources();
  for (ItemCount i = 0; i < numSources; i++) {
    MIDIEndpointRef systemSource = MIDIGetSource(i);
    // NSLog(@" Source: %@", getMIDIName((MIDIObjectRef)systemSource));
    MIDIPortConnectSource(hmslMIDIInputPort, systemSource, NULL);
  }
  /*
  MIDIOutputPortCreate(hmslMIDIClient, CFSTR("HMSL MIDI Port Output"), &hmslMIDIOutputPort);

  ItemCount numSources = MIDIGetNumberOfSources();
  NSLog(@"Found %lu sources", numSources);
  NSLog(@"Found %lu destinations", MIDIGetNumberOfDestinations());
  for (ItemCount i = 0; i < numSources; i++) {
    MIDIEndpointRef systemSource = MIDIGetSource(i);
    MIDIPortConnectSource(hmslMIDIInputPort, systemSource, NULL);
  } 
  */
  
  return 0;
}

// Called by HMSL to terminate the MIDI connection
void hostMIDI_Term( void ) {
  free(hmslCurrentMIDIData);
  // This automatically disposes of the ports as well
  MIDIClientDispose(hmslMIDIClient);
  return;
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - int, the number of bytes in the above addr array
// vtime - time in ms from the start of the scheduler to create event
//
// Returns error code (0 for no error)
int hostMIDI_Write( unsigned char *addr, int count, int vtime ) {
  
  //  NSLog(@"Scheduled time: %i", vtime);
  //  NSLog(@"NOW: %llu", mach_absolute_time());
  
  MIDITimeStamp timestamp;
  ByteCount message_count = (ByteCount)count;
  Byte *data = (Byte*)addr;
  
    // MIDITimeStamps are based on from mach_absolute_time()
    UInt64 nanoseconds64 = hostClock_TicksToNanoseconds(vtime);
    Nanoseconds nanoseconds = * (Nanoseconds *) &nanoseconds64;
    AbsoluteTime absolute = NanosecondsToAbsolute( nanoseconds );
    timestamp = * (MIDITimeStamp *) &absolute;
  
  MIDIPacketList *packetList = (MIDIPacketList*)calloc(PACKETLIST_SIZE, 1);
  MIDIPacket *first_packet = MIDIPacketListInit(packetList);
  MIDIPacket *curPacket;
  
  curPacket = MIDIPacketListAdd(packetList, PACKETLIST_SIZE, first_packet, timestamp, message_count, data);
  
  if (curPacket == NULL) {
    NSLog(@"Not enough room in the packet.");
    free(packetList);
    return 1;
  } else {
    // NSLog(@"Packet size: %lu", packetList->numPackets);
  }
  
  //  NSLog(@"%i, %i, %i, %i, %llu", addr[0], addr[1], addr[2], count, timestamp);
  
  OSStatus err = 0;
  
  err = MIDIReceived(hmslMIDISource, packetList);
  
  if (err != noErr) {
    NSLog(@"Error with most recent midi string");
  }
  free(packetList);
  return 0;
}

int hostMIDI_Recv( void ) {
  if (hmslMIDIBuffer.count > 0) {
    NSData *data = [hmslMIDIBuffer objectAtIndex: 0];
    Byte output;
    [data getBytes: &output length: 1];
    
    if (data.length > 1) {
      NSUInteger newLength = [data length] - 1;
      Byte *buffer = malloc(newLength);
      
      [data getBytes: buffer range: NSMakeRange(1, newLength)];
      [hmslMIDIBuffer replaceObjectAtIndex: 0 withObject: [NSData dataWithBytes:buffer length: newLength]];
      free(buffer);
    } else {
      [hmslMIDIBuffer removeObjectAtIndex: 0];
    }
    
    return output;
  } else {
    return -1;
  }
}

void hostSleep( int msec ) {
  usleep(msec * 1000);
}

