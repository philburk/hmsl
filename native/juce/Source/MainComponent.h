/*
  ==============================================================================

    This file was auto-generated!

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"
#include "AtomicQueue.h"

/*
 * These must match the ID values in HMSL graphics.fth
 */
enum HMSLEventID {
    EV_NULL,
    EV_MOUSE_DOWN,
    EV_MOUSE_UP,
    EV_MOUSE_MOVE,
    EV_MENU_PICK,
    EV_CLOSE_WINDOW,
    EV_REFRESH,
    EV_KEY
};

struct HmslEvent_t {
    enum HMSLEventID id;
    int32_t x;
    int32_t y;
};

//==============================================================================
/*
    This component lives inside our window, and this is where you should put all
    your controls and content.
*/
class MainComponent   : public AnimatedAppComponent
{
private:

    enum opcode_t {
        MOVE_TO,
        DRAW_TO,
        FILL_RECT,
        SET_COLOR,
        SET_BACKGROUND_COLOR,
        DRAW_TEXT,
    };

public:
    //==============================================================================
    MainComponent();
    ~MainComponent();

    void drawLineTo(int x, int y);
    void moveTo(int x, int y) {
        mCurrentX = x;
        mCurrentY = y;
    }
    void drawText(const char *text, int32_t numChars);
    int32_t getTextLength(const char *text, int32_t numChars);

    /*
     * Draws a filled rectangle in the current context
     * Uses current position.
     */
    void fillRect(int32_t width, int32_t height);

    /*
     * Sets the stroke/fill drawing color of the current context
     *
     * color - index of color to use, defined as constants in hmsl.h
     */
    void setColor(int32_t color );

    /*
     * Set background color of window.
     *
     * color - index of color to use, defined as constants in hmsl.h
     */
    void setBackgroundColor(int32_t color );

    void drawRandomLine();

    void postMoveTo(int32_t x, int32_t y) {
        postCommand(MOVE_TO, x, y);
    }
    
    void postDrawTo(int32_t x, int32_t y) {
        postCommand(DRAW_TO, x, y);
    }

    void postFillRect(int32_t width, int32_t height) {
        postCommand(FILL_RECT, width, height);
    }

    void postSetColor(int32_t color) {
        postCommand(SET_COLOR, color, 0);
    }

    void postSetBackgroundColor(int32_t color) {
        postCommand(SET_BACKGROUND_COLOR, color, 0);
    }

    void postDrawText(const char *addr, int32_t count) {
        char *storage = (char *) malloc(count);
        memcpy(storage, addr, count);
        postCommand(DRAW_TEXT, count, 0, storage);
    }

    // ================== Events ===============================
    bool getNextEvent(HmslEvent_t *event);

    void mouseDown(const MouseEvent &event) override {
        postEvent(EV_MOUSE_DOWN, event.getMouseDownX(), event.getMouseDownY());
    }

    void mouseUp(const MouseEvent &event) override {
        postEvent(EV_MOUSE_UP, event.getMouseDownX(), event.getMouseDownY());
    }

    void mouseDrag(const MouseEvent &event) override {
        postEvent(EV_MOUSE_MOVE,
                  event.getMouseDownX() + event.getDistanceFromDragStartX(),
                  event.getMouseDownY() + event.getDistanceFromDragStartY()
                  );
    }

    void onCloseButtonPressed() {
        postEvent(EV_CLOSE_WINDOW);
    }

    // ================== JUCE Window methods ===============================
    void paint (Graphics&) override;
    void resized() override;
    void update() override;

private:

    void postCommand(opcode_t opcode, int32_t x = 0, int32_t y = 0, const char *addr = nullptr) {
        HmslCommand_t cmd = {opcode, x, y, addr};
        int timeout = 50;
        while(mCommandQueue.full() && (timeout-- > 0)) {
            usleep(15 * 1000);
        }
        mCommandQueue.write(cmd);
    }

    void postEvent(HMSLEventID id, int32_t x = 0, int32_t y = 0) {
        HmslEvent_t cmd = {id, x, y};
        mEventQueue.write(cmd); // TODO full?
    }

    struct HmslCommand_t {
        opcode_t    opcode;
        int32_t     x;
        int32_t     y;
        const char *text;
    };

    std::unique_ptr<Image> mImage;
    Colour                 mCurrentColour = Colours::white;
    Colour                 mBackgroundColour = Colours::black;
    int32_t                mCurrentX = 0;
    int32_t                mCurrentY = 0;

    std::vector<Colour>    kPalette {
        Colours::white, Colours::black,
        Colours::red, Colours::green, Colours::blue,
        Colours::cyan, Colours::magenta, Colours::yellow
    };

    AtomicQueue<HmslCommand_t> mCommandQueue;
    AtomicQueue<HmslEvent_t>   mEventQueue;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (MainComponent)
};
