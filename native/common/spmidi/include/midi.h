#ifndef _MIDI_H
#define _MIDI_H

/* $Id: midi.h,v 1.12 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 *
 * @file midi.h
 * @brief Standard MIDI constants
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef MIDI_SUPPORT_NAME_LOOKUP
#define MIDI_SUPPORT_NAME_LOOKUP  (1)
#endif

#define MIDI_MakeFourCC(a,b,c,d)  (((a)<<24) | ((b)<<16) | ((c)<<8) | (d))

    /** Chunk ID for a MIDIFile header. */
#define MIDI_MThd_ID  (('M'<<24) | ('T'<<16) | ('h'<<8) | 'd')
#define MIDI_MTrk_ID  (('M'<<24) | ('T'<<16) | ('r'<<8) | 'k')

    /* Basic Commands */
#define MIDI_NOTE_OFF              (0x80)
#define MIDI_NOTE_ON               (0x90)
#define MIDI_POLYPHONIC_AFTERTOUCH (0xA0)
#define MIDI_CONTROL_CHANGE        (0xB0)
#define MIDI_PROGRAM_CHANGE        (0xC0)
#define MIDI_CHANNEL_AFTERTOUCH    (0xD0)
#define MIDI_PITCH_BEND            (0xE0)

#define MIDI_SOX                   (0xF0)
#define MIDI_EOX                   (0xF7)

#define MIDI_CONTROL_BANK          (0)
#define MIDI_CONTROL_MODULATION    (1)
#define MIDI_CONTROL_DATA_ENTRY    (6)
#define MIDI_CONTROL_VOLUME        (7)
#define MIDI_CONTROL_PAN           (10)
#define MIDI_CONTROL_EXPRESSION    (11)
#define MIDI_CONTROL_LSB_OFFSET    (32)
#define MIDI_CONTROL_SUSTAIN       (64)
#define MIDI_CONTROL_NONRPN_LSB    (98)
#define MIDI_CONTROL_NONRPN_MSB    (99)
#define MIDI_CONTROL_RPN_LSB       (100)
#define MIDI_CONTROL_RPN_MSB       (101)
#define MIDI_CONTROL_ALLSOUNDOFF   (120)
#define MIDI_CONTROL_ALLNOTESOFF   (123)

#define MIDI_RPN_BEND_RANGE        (0x0000)
#define MIDI_RPN_FINE_TUNING       (0x0001)
#define MIDI_RPN_COARSE_TUNING     (0x0002)

#define MIDI_META_EVENT            (0xFF)
#define MIDI_META_SEQUENCE_NUMBER  (0x00)
#define MIDI_META_TEXT_EVENT       (0x01)
#define MIDI_META_COPYRIGHT        (0x02)
#define MIDI_META_SEQUENCE_NAME    (0x03)
#define MIDI_META_INSTRUMENT_NAME  (0x04)
#define MIDI_META_LYRIC            (0x05)
#define MIDI_META_MARKER           (0x06)
#define MIDI_META_CUE_POINT        (0x07)
#define MIDI_META_CHANNEL_PREFIX   (0x20)
#define MIDI_META_END_OF_TRACK     (0x2F)
#define MIDI_META_SET_TEMPO        (0x51)
#define MIDI_META_SMPTE_OFFSET     (0x54)
#define MIDI_META_TIME_SIGNATURE   (0x58)
#define MIDI_META_KEY_SIGNATURE    (0x59)

#define MIDI_OFFSET_NONE           (0x40)

/** Bend value corresponding to no bend. */
#define MIDI_BEND_NONE             (0x2000)
#define MIDI_BEND_MAX              (0x3FFF)

    /** Index of drum channel. Note that this is a zero based index. Humans use 10 */
#define MIDI_RHYTHM_CHANNEL_INDEX  (9)
#define MIDI_NUM_CHANNELS          (16)

    /** Note index of first defined rhythm instrument on channel 10 of General MIDI */
#define GMIDI_FIRST_DRUM          (35)
#define GMIDI_LAST_DRUM           (81)

    /** Number of rhythm instruments defined for channel 10 of General MIDI */
#define GMIDI_NUM_DRUMS            (1 + GMIDI_LAST_DRUM - GMIDI_FIRST_DRUM)
#define GMIDI_NUM_PROGRAMS         (128)

#define GMIDI_RHYTHM_BANK_MSB     (0x78)
#define GMIDI_MELODY_BANK_MSB     (0x79)

    /** Frequency corresponding to pitch of note zero. */
#define MIDI_FREQ_ZERO             (8.1757989156)


#if MIDI_SUPPORT_NAME_LOOKUP
    const char *MIDI_GetProgramName( int programIndex );
    const char *MIDI_GetDrumName( int pitch );
#else
    #define MIDI_GetProgramName(p) ("-")
    #define MIDI_GetDrumName(p) ("-")
#endif

#ifdef __cplusplus
}
#endif

#endif
