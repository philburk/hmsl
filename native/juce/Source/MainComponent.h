/*
  ==============================================================================

    This file was auto-generated!

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"

//==============================================================================
/*
    This component lives inside our window, and this is where you should put all
    your controls and content.
*/
class MainComponent   : public AnimatedAppComponent
{
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
     *
     * x1, y1 - integer coordinates of one corner of rectangle
     * x2, y2 - integer coordinates of opposing corner of rectangle
     */
    void fillRectangle(int32_t x1, int32_t y1, int32_t x2, int32_t y2);

    /*
     * Sets the stroke/fill drawing color of the current context
     *
     * color - index of color to use, defined as constants in hmsl.h
     */
    void setColor(int32_t color );

    void drawRandomLine();
    //==============================================================================
    void paint (Graphics&) override;
    void resized() override;
    void update() override;

private:
    //==============================================================================
    // Your private member variables go here...
    std::unique_ptr<Image> mImage;
    Colour                 mCurrentColour = Colours::white;
    int32_t                mCurrentX = 0;
    int32_t                mCurrentY = 0;

    std::vector<Colour>    kPalette{Colours::white, Colours::black,
        Colours::red, Colours::green, Colours::blue, Colours::yellow };

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (MainComponent)
};
