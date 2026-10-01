/*
 * HMSL version number. This is the only place to set it.
 *
 * It is used by the C++ code, by Info-App.plist, which is preprocessed
 * with this header, by the release script, and by Forth, which gets it
 * from HOSTVERSION() as HMSL_VERSION#, eg. 50100 for V5.1.0.
 *
 * Keep MINOR and PATCH below 100 so they fit in HMSL_VERSION#.
 * Only use simple #defines and C comments because this file is also
 * read by the Info.plist preprocessor.
 */
#pragma once

#define HMSL_VERSION_MAJOR 5
#define HMSL_VERSION_MINOR 1
#define HMSL_VERSION_PATCH 0

#define HMSL_VERSION_NUMBER ((HMSL_VERSION_MAJOR * 10000) + (HMSL_VERSION_MINOR * 100) + HMSL_VERSION_PATCH)

#define HMSL_STRINGIFY_(x) #x
#define HMSL_STRINGIFY(x) HMSL_STRINGIFY_(x)
#define HMSL_VERSION_STRING HMSL_STRINGIFY(HMSL_VERSION_MAJOR) "." \
        HMSL_STRINGIFY(HMSL_VERSION_MINOR) "." HMSL_STRINGIFY(HMSL_VERSION_PATCH)

/* For Info-App.plist. Paste the parts into one token, eg. 5.1.0, so the
 * preprocessor does not put spaces around the dots. */
#define HMSL_PASTE_VERSION_(a, b, c) a##.##b##.##c
#define HMSL_PASTE_VERSION(a, b, c) HMSL_PASTE_VERSION_(a, b, c)
#define HMSL_VERSION_PLIST HMSL_PASTE_VERSION(HMSL_VERSION_MAJOR, HMSL_VERSION_MINOR, HMSL_VERSION_PATCH)
