/***************************************************************
** HMSL Font functions
**
** Author: Robert Marsanyi
***************************************************************/

#include <windows.h>
#include "pf_all.h"
#include "hmsl_graphics.h"

#define NUM_FACENAMES 10

typedef struct HMFont
{
	void*   hft_NextFont;
	int     hft_Size;
	int     hft_Face;
	HFONT   hft_Font;
} HMFont;

typedef struct HMFace
{
	LPCTSTR hface_Name;
} HMFace;

typedef struct HMFontContext
{
	LOGFONT hg_FontInfo;
	HMFont* hg_FontListStart;
	HMFont* hg_FontListEnd;
	LPCTSTR hg_FaceTable[NUM_FACENAMES];
	HMFont* hg_CurrentFont;
} HMFontContext;

HMFontContext *gHMFont = NULL;
extern HMSLContext *gHMSLContext;

static HMFont *hfAddFont( HFONT font, LOGFONT *fontInfo );
static int hfAddFontName( LPCTSTR faceName );
static int hfFindFontName( LPCTSTR faceName );
static HMFont *hfFindFont( int size, int faceIndex );
static void hfRemoveFont( HMFont *font );

/*
Font Name Table handling
*/
int hfAddFontName( LPCTSTR faceName )
{
	int i, index = -1;
	
	for( i=0; i<NUM_FACENAMES; i++ )
	{
		if( gHMFont->hg_FaceTable[i] == NULL )
		{
			gHMFont->hg_FaceTable[i] = faceName;
			index = i;
			break;
		}
	}

	return( index );
};

int hfFindFontName( LPCTSTR faceName )
{
	int i, index = -1;

	for( i=0; i<NUM_FACENAMES; i++ )
	{
		if( strcmp( gHMFont->hg_FaceTable[i], faceName ) == 0 )
		{
			index = i;
			break;
		}
	}

	return( index );
};

/*
Font List handling
*/

HMFont *hfAddFont( HFONT font, LOGFONT *fontInfo )
{
	HMFont *theFont;

	/* Allocate a HMFont structure */
	theFont = malloc( sizeof( HMFont ) );
	if( theFont == NULL ) return( NULL );

	/* Fill in the required fields */
	theFont->hft_Size = fontInfo->lfHeight;
	theFont->hft_Face = hfFindFontName( fontInfo->lfFaceName );
	theFont->hft_Font = font;
	theFont->hft_NextFont = NULL;

	/* Add the facename to the table, if required */
	if( theFont->hft_Face == -1 )  /* name not found */
	{
		theFont->hft_Face = hfAddFontName( fontInfo->lfFaceName );
	}

	/* Add the new structure to the font list */
	if( gHMFont->hg_FontListStart == NULL )
	{
		gHMFont->hg_FontListStart = theFont;
	}
	else
	{
		gHMFont->hg_FontListEnd->hft_NextFont = theFont;
	}
	gHMFont->hg_FontListEnd = theFont;

	return theFont;
}

HMFont *hfFindFont( int size, int faceIndex )
{
	HMFont *aFont = gHMFont->hg_FontListStart;
	HMFont *selectedFont = NULL;

	/* Check to see if we've got a corresponding font by traversing the list */
	while( (aFont != NULL) )
	{
		if( (aFont->hft_Size == size) && (aFont->hft_Face == faceIndex) )
		{
			selectedFont = aFont;
			break;
		}
		else
		{
			aFont = aFont->hft_NextFont;
		}
	}

	return( selectedFont );
}

void hfRemoveFont( HMFont *font )
{
	/* Remove it from the start of the list, if that's where it is */
	if( gHMFont->hg_FontListStart == font )
	{
		gHMFont->hg_FontListStart = font->hft_NextFont;
	}

	/* Remove it from the end of the list, if that's where it is */
	if( gHMFont->hg_FontListEnd == font )
	{
		gHMFont->hg_FontListEnd = NULL;
	}

	/* Delete the Windows font */
	DeleteObject( font->hft_Font );

	/* Free the structure */
	free( font );

	return;
};

BOOLEAN hfInit( void )
{
	HFONT font;
	int i;

	/* Allocate the font context structure */
	gHMFont = malloc( sizeof( HMFontContext ) );
	if( !gHMFont ) return( TRUE );

	/* Initialize the face names array */
	for( i=0; i<NUM_FACENAMES; i++) gHMFont->hg_FaceTable[i] = NULL;

	/* Initialize the font list */
	gHMFont->hg_FontListStart = NULL;
	gHMFont->hg_FontListEnd = NULL;

	/* Get the default font */
	font = GetCurrentObject( gHMSLContext->hg_hDC, OBJ_FONT );

	/* Get the font characteristics */
	GetObject( font, sizeof( LOGFONT ), &(gHMFont->hg_FontInfo) );

	/* Add the font name to the fontname table */
	hfAddFontName( gHMFont->hg_FontInfo.lfFaceName );

	/* Add the font to the list */
	gHMFont->hg_CurrentFont = hfAddFont( font, &(gHMFont->hg_FontInfo) );

	/* Create a font for HMSL font 0 */
	gHMFont->hg_FontInfo.lfHeight = 12;
	gHMFont->hg_FontInfo.lfHeight = 0;  /* match */
	gHMFont->hg_FontInfo.lfEscapement = 0;  /* horizontal */
	gHMFont->hg_FontInfo.lfOrientation = 0;
	gHMFont->hg_FontInfo.lfWeight = FW_DONTCARE;
	gHMFont->hg_FontInfo.lfItalic = FALSE;
	gHMFont->hg_FontInfo.lfUnderline = FALSE;
	gHMFont->hg_FontInfo.lfStrikeOut = FALSE;
	gHMFont->hg_FontInfo.lfCharSet = ANSI_CHARSET;
	gHMFont->hg_FontInfo.lfOutPrecision = OUT_DEFAULT_PRECIS;
	gHMFont->hg_FontInfo.lfClipPrecision = CLIP_DEFAULT_PRECIS;
	gHMFont->hg_FontInfo.lfQuality = DEFAULT_QUALITY;
	gHMFont->hg_FontInfo.lfPitchAndFamily = VARIABLE_PITCH | FF_DONTCARE;
	gHMFont->hg_FontInfo.lfFaceName[0] = '\0';

	font = CreateFontIndirect( &(gHMFont->hg_FontInfo) );
	gHMFont->hg_CurrentFont = hfAddFont( font, &(gHMFont->hg_FontInfo) );

	SelectObject( gHMSLContext->hg_hDC, font );

	return( FALSE );
}

void hfSetFont( int faceIndex, int size )
{
	HMFont *foundFont;
	HFONT selectedFont = NULL;

	/* Find out if we have the requested font */
	foundFont = hfFindFont( size, faceIndex );
	if( foundFont ) selectedFont = foundFont->hft_Font;

	/* If not, set the LOGFONT parameters */
	if( selectedFont == NULL )
	{
		gHMFont->hg_FontInfo.lfHeight = size;
		strcpy( gHMFont->hg_FontInfo.lfFaceName, gHMFont->hg_FaceTable[faceIndex] );

		/* Create a font */
		selectedFont = CreateFontIndirect( &(gHMFont->hg_FontInfo) );

		/* Add it to the list */
		gHMFont->hg_CurrentFont = hfAddFont( selectedFont, &(gHMFont->hg_FontInfo) );
	}

	/* Select the font into the DC */
	SelectObject( gHMSLContext->hg_hDC, selectedFont );

	return;
}

int hfGetFontSize( void )
{
	if( gHMFont->hg_CurrentFont != NULL ) return (gHMFont->hg_CurrentFont->hft_Size );
	else return( -1 );
}

int hfGetFontIndex( void )
{
	if( gHMFont->hg_CurrentFont != NULL ) return (gHMFont->hg_CurrentFont->hft_Face );
	else return( -1 );
}

void hfTerm( void )
{
	HMFont *thisFont, *nextFont;

	if( gHMFont )
	{
		/* For each font in the list except the first, remove it */
		thisFont = gHMFont->hg_FontListStart->hft_NextFont;
		while( thisFont != NULL )
		{
			nextFont = thisFont->hft_NextFont;
			hfRemoveFont( thisFont );
			thisFont = nextFont;
		}

		/* Select the first font (which was the default set up in hfInit) */
		SelectObject( gHMSLContext->hg_hDC, gHMFont->hg_FontListStart->hft_Font );

		/* Remove the first font and deallocate the gHMFont structure */
		hfRemoveFont( gHMFont->hg_FontListStart );

		free( gHMFont );

		gHMFont = NULL;
	}

	return;
}
