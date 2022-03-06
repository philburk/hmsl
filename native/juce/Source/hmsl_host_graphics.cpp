/*
  ==============================================================================

    hmsl_host_graphics.cpp
    Created: 22 May 2019 8:14:20pm
    Author:  Phil Burk

  ==============================================================================
*/

#include <unordered_map>
#import "pf_all.h"
#import "hmsl_host.h"
#import "GraphicsWindow.h"

static void *deleteWindow(void *windowPtr) {
    GraphicsWindow *window = (GraphicsWindow *) windowPtr;
    delete window;
    return nullptr;
}

struct HmslContext {
    cell_t lastMouseX;
    cell_t lastMouseY;
    enum HMSLColor color;
    cell_t nextWindowHandle = 1;
    std::unordered_map<cell_t, GraphicsWindow*> windowMap;
    GraphicsWindow *currentWindow;

    void setCurrentWindow(hmsl_window_index_t windowIndex) {
        currentWindow = windowMap[windowIndex];
    }

    void closeWindow(hmsl_window_index_t windowIndex) {
        GraphicsWindow *window = windowMap[windowIndex];
        if (window != nullptr) {
            MessageManager *messageManager = MessageManager::getInstance();
            messageManager->callFunctionOnMessageThread(deleteWindow, (void *)window);
            windowMap[windowIndex] = nullptr;
        }
    }
};

HmslContext gHMSLContext = {0};

static MainComponent *cgw() {
    return gHMSLContext.currentWindow->getMainComponent();
}

int32_t hostInit() {
    return -1; // TRUE for OK?
}

void hostTerm() {
}

hmsl_window_index_t hostOpenWindow( hmslWindow *windowInfo ) {
    GraphicsWindow::GraphicsWindowTemplate windowTemplate;

    char title[80];
    if (windowInfo->title == 0) {
        windowTemplate.name = "HMSL?";
    } else {
        ForthStringToC(title, (const char*)windowInfo->title, 80);
        windowTemplate.name = title;
    }
    windowTemplate.x = windowInfo->rect_left;
    windowTemplate.y = windowInfo->rect_top;
    windowTemplate.width = windowInfo->rect_right - windowInfo->rect_left;
    windowTemplate.height = windowInfo->rect_bottom - windowInfo->rect_top;

    GraphicsWindow *window = GraphicsWindow::openNewWindow(&windowTemplate);
    gHMSLContext.currentWindow = window;
    cell_t handle = gHMSLContext.nextWindowHandle++;
    gHMSLContext.windowMap[handle] = window;
    return handle;
}

void hostCloseWindow(hmsl_window_index_t windowIndex) {
    gHMSLContext.closeWindow(windowIndex);
}

void hostSetCurrentWindow( hmsl_window_index_t windowIndex ) {
    gHMSLContext.setCurrentWindow(windowIndex);
}

void hostDrawLineTo( cell_t x, cell_t y ) {
    cgw()->postDrawTo((int32_t)x, (int32_t)y);
}

void hostMoveTo( cell_t x, cell_t y ) {
    cgw()->postMoveTo((int32_t)x, (int32_t)y);
}

/*
 * Draws text in the current context at the current pen point
 *
 * address - address in memory of the string to copy
 * count - number of bytes to read
 */
void hostDrawText( ucell_t address, cell_t count ) {
    cgw()->postDrawText((const char *) address, (int32_t) count);
}

/*
 * Gets the length of the string, using the current font face and size
 *
 * address - address in memory of the string to copy
 * count - number of bytes to read
 *
 * Returns the length of the text
 */
uint32_t hostGetTextLength( ucell_ptr_t address, cell_t count ) {
    return cgw()->getTextLength((const char*)address, (int32_t)count);
}

/*
 * Draws a filled rectangle in the current context
 *
 * x1, y1 - integer coordinates of one corner of rectangle
 * x2, y2 - integer coordinates of opposing corner of rectangle
 */
void hostFillRectangle( cell_t x1, cell_t y1, cell_t x2, cell_t y2 ) {
    cgw()->postMoveTo((int32_t)x1, (int32_t)y1);
    cgw()->postFillRect((int32_t)(x2 - x1), (int32_t)(y2 - y1));
}

/*
 * Sets the stroke/fill drawing color of the current context
 *
 * color - index of color to use, defined as constants in hmsl.h
 */
void hostSetColor( cell_t color ) {
    cgw()->postSetColor((int32_t)color);
}

/*
 * Sets background color of main window
 *
 * color - index of color to use, defined as constants in hmsl.h
 */
void hostSetBackgroundColor( cell_t color ) {
    cgw()->postSetBackgroundColor((int32_t)color);
}

/*
 * Sets drawing mode
 *
 * mode - 0 for normal (overwrite); 1 for XOR.
 */
void hostSetDrawingMode( cell_t mode ) {
    // TODO
}

/*
 * Sets the font from a dictionary of possible fonts
 *
 * font - index of font to set
 */
void hostSetFont( cell_t font ) {
    // TODO
}

/*
 * Sets the font size in some units.
 *
 * size - integer size
 */
void hostSetTextSize( cell_t size ) {
    // TODO
}

/**
 * Called whenever HMSL wants to know where the mouse is (usually open receiving an event)
 *
 * @param xPtr address in memory where the mouse event's x coordinates should be written
 * @param yPtr address in memory where the mouse event's y coordinates should be written
 */
void hostGetMouse( ucell_ptr_t xPtr, ucell_ptr_t yPtr) {
    *(cell_t*)xPtr = gHMSLContext.lastMouseX;
    *(cell_t*)yPtr = gHMSLContext.lastMouseY;
}

/*
 * Polled regularly to receive latest events in the GUI
 *
 * timeout - time until we should stop blocking
 *
 * Returns an int, defined in the enum HMSLEventID
 */
cell_t hostGetEvent( cell_t timeout ) {
    HmslEvent_t event;
    bool gotEvent = cgw()->getNextEvent(&event);
    if (gotEvent) {
        switch (event.id) {
            case EV_MOUSE_DOWN:
            case EV_MOUSE_MOVE:
            case EV_MOUSE_UP:
                gHMSLContext.lastMouseX = event.x;
                gHMSLContext.lastMouseY = event.y;
                break;
            default:
                break;
        }

        return event.id;
    }
    return EV_NULL;
}

