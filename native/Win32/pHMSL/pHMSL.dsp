# Microsoft Developer Studio Project File - Name="pHMSL" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=pHMSL - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "pHMSL.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "pHMSL.mak" CFG="pHMSL - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "pHMSL - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "pHMSL - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "pHMSL - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /I "E:\nomad\pForth\csrc" /I "\nomad\MIDISynth\code\spmidi\include" /I "D:\mobileer_work\exports\bose_piano" /I "\nomad\MIDISynth\code\spmidi\engine" /I "\nomad\MIDISynth\code\util" /I "\nomad\PortAudio\pav18\portaudio\pablio" /I "\nomad\PortAudio\pav18\portaudio\pa_common" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D JUKEBOX_FIFO_SIZE=8192 /D JUKEBOX_EVBUF_SIZE=16000 /D "PF_SUPPORT_FP" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386 /out:"E:\nomad\PHMSL\pHMSL.exe"

!ELSEIF  "$(CFG)" == "pHMSL - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /Od /I "E:\nomad\PHMSL\portmidi\porttime" /I "E:\nomad\PHMSL\portmidi\pm_common" /I "E:\nomad\pForth\csrc" /I "\nomad\MIDISynth\code\spmidi\include" /I "D:\mobileer_work\exports\bose_piano" /I "\nomad\MIDISynth\code\spmidi\engine" /I "\nomad\MIDISynth\code\util" /I "\nomad\PortAudio\pav18\portaudio\pablio" /I "\nomad\PortAudio\pav18\portaudio\pa_common" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D JUKEBOX_FIFO_SIZE=8192 /D JUKEBOX_EVBUF_SIZE=16000 /D "PF_SUPPORT_FP" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386 /out:"E:\nomad\PHMSL\pHMSL.exe" /pdbtype:sept
# SUBTRACT LINK32 /nodefaultlib

!ENDIF 

# Begin Target

# Name "pHMSL - Win32 Release"
# Name "pHMSL - Win32 Debug"
# Begin Group "pforth"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_all.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_cglue.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_cglue.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_clib.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_clib.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_core.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_core.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_float.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_guts.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_host.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_inc1.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_inner.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_io.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_io.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_io_win32_console.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_mem.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_mem.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_save.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_save.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_text.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_text.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_types.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_win32.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_words.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_words.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pfcompfp.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pfcompil.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pfcompil.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pfdicdat.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pfdicdat_arm.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pfinnrfp.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pforth.h
# End Source File
# End Group
# Begin Group "ME2000"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\adsr_envelope.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\adsr_envelope.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\jukebox\atomic_fifo.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\jukebox\atomic_fifo.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\compressor.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\compressor.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\dbl_list.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\dbl_list.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\dls_articulations.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\dls_parser.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\dls_parser_internal.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\jukebox\event_buffer.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\jukebox\event_buffer.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\fxpmath.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\instrument_mgr.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\instrument_mgr.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\memheap.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\memheap.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\memtools.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\memtools.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\midi_names.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\midifile_parser.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\midifile_player.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\oscillator.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\oscillator.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\parse_riff.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\parse_riff.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\resource_mgr.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\resource_mgr.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\reverb.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\reverb.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\song_player.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\util\spmidi_audio_pa.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_dls.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_dls.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_fast.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_host.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_host.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_hybrid.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_hybrid.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_hybrid_presets.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_hybrid_presets_me1000.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\jukebox\spmidi_jukebox.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_orchestra.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_orchestra.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_preset.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_presets_custom_1.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_presets_custom_2.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_synth.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_synth_util.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_synth_util.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_util.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\spmidi_voice.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\stack.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\stack.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\streamio.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\streamio_ram.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\svfilter.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\svfilter.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\wave_manager.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\wave_manager.h
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\wavetable.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\xmf_parser.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\engine\xmf_parser_internal.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\src\hmsl_event.c
# End Source File
# Begin Source File

SOURCE=.\src\hmsl_event.h
# End Source File
# Begin Source File

SOURCE=.\src\hmsl_font.c
# End Source File
# Begin Source File

SOURCE=.\src\hmsl_graphics.c
# End Source File
# Begin Source File

SOURCE=.\src\hmsl_graphics.h
# End Source File
# Begin Source File

SOURCE=.\src\hmsl_midi.h
# End Source File
# Begin Source File

SOURCE=.\src\hmsl_midi_me2000.c
# End Source File
# Begin Source File

SOURCE=..\..\..\pForth\csrc\pf_main.c
# End Source File
# Begin Source File

SOURCE=.\src\pfcustom_hmsl.c
# End Source File
# Begin Source File

SOURCE=..\..\..\MIDISynth\code\spmidi\lib\PortAudioWMME.lib
# End Source File
# End Target
# End Project
