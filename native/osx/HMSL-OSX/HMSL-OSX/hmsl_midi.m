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
MIDIPortRef hmslMIDIInputPort;
MIDIPortRef hmslMIDIOutputPort;
MIDIClientRef hmslMIDIClient;
UInt64 hmslStartTime;
UInt64 hmslCurrentTime;
MIDIPacketList *hmslCurrentMIDIData;
MIDIPacket *hmslLastPacket;

// Holds the list of MIDI commands that have yet to be executed
NSMutableArray *hmslMIDIBuffer;

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
  hmslMIDIBuffer = [NSMutableArray arrayWithCapacity:PACKETLIST_SIZE];
  
  hmslStartTime = mach_absolute_time();
  hmslCurrentMIDIData = (MIDIPacketList*)calloc(PACKETLIST_SIZE, sizeof(Byte));
  hmslLastPacket = MIDIPacketListInit(hmslCurrentMIDIData);
  
  //  NSLog(@"HMSL MIDI Init at %llu", hmslStartTime);
  
  MIDIClientCreate(CFSTR("HMSL MIDI"), NULL, NULL, &hmslMIDIClient);
  
  MIDISourceCreate(hmslMIDIClient, CFSTR("HMSL MIDI Source"), &hmslMIDISource);
  MIDIOutputPortCreate(hmslMIDIClient, CFSTR("HMSL MIDI Port Output"), &hmslMIDIOutputPort);
  MIDIInputPortCreate(hmslMIDIClient, CFSTR("HMSL MIDI Port Input"), (MIDIReadProc)&midiSourceProc, NULL, &hmslMIDIInputPort);
  
  //  listen on every port
  ItemCount numSources = MIDIGetNumberOfSources();
  for (ItemCount source = 0; source < numSources; source++) {
    MIDIPortConnectSource(hmslMIDIInputPort, MIDIGetSource(source), NULL);
  }
  
  return 0;
}

// Called by HMSL to terminate the MIDI connection
void hostMIDI_Term( void ) {
  free(hmslCurrentMIDIData);
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
  
  timestamp = hmslStartTime + AudioConvertNanosToHostTime((UInt64)((UInt64)(vtime) * 1000000));
  
  MIDIPacketList *packetList = (MIDIPacketList*)calloc(PACKETLIST_SIZE, 1);
  MIDIPacket *first_packet = MIDIPacketListInit(packetList);
  MIDIPacket *curPacket;
  
  curPacket = MIDIPacketListAdd(packetList, PACKETLIST_SIZE, first_packet, timestamp, message_count, data);
  
  if (curPacket == NULL) {
    NSLog(@"Not enough room in the packet.");
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
  if ([hmslMIDIBuffer count] > 0) {
    NSData *data = [hmslMIDIBuffer objectAtIndex: 0];
    Byte output;
    [data getBytes: &output length: 1];
    
    if ([data length] > 1) {
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

int hostClock_QueryTime( void ) {
  int elapsed;
  hmslCurrentTime = mach_absolute_time();
  //  Convert from nanos to millis for HMSL
  elapsed = (int)(AudioConvertHostTimeToNanos(hmslCurrentTime - hmslStartTime) / 1000000);
  //  NSLog(@"Elapsed time: %u ms", elapsed);
  return elapsed;
}

int hostClock_QueryRate( void ) {
  return 1000;
}

void hostSleep( int msec ) {
  usleep(msec * 1000);
}

