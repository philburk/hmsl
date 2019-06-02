/*
  ==============================================================================

    TerminalComponent.cpp
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalComponent.h"

TerminalComponent::TerminalComponent(TerminalModel &model, Viewport &viewport)
    : mTerminalModel(model)
    , mScrollingViewport(viewport)
    , mCursorColour(0xffC08020)
{
    // In your constructor, you should add any child components, and
    // initialise any special settings that your component needs.

    setSize (kWidthMin, kHeightMin);

    addKeyListener(this);
    setWantsKeyboardFocus(true);
    setFramesPerSecond(60);
}

TerminalComponent::~TerminalComponent()
{
    removeKeyListener(this);
}

bool TerminalComponent::keyPressed (const KeyPress &key,
                                Component *originatingComponent) {
    return mTerminalModel.onKeyPressed(key);
}

// Update the model and adjust the size if needed.
void TerminalComponent::update() {
    bool changed = mTerminalModel.processOutputQueue();

    std::list<String> *previousLines = &mTerminalModel.mPreviousLines;
    int height = (int)((previousLines->size() + 3) * kLineSpacing);
    int width = std::max(mWidestLine, mScrollingViewport.getMaximumVisibleWidth());
    setSize(width, height);

    if (changed) {
        // Show bottom when characters added to the display.
        int y = height - mScrollingViewport.getHeight();
        mScrollingViewport.setViewPosition(0, y);
    }
}

void TerminalComponent::paint (Graphics& g)
{
    std::list<String>     *previousLines = &mTerminalModel.mPreviousLines;

    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));   // clear the background

    g.setColour (Colours::grey);
    g.drawRect (getLocalBounds(), 1);   // draw an outline around the component

    g.setFont({Font::getDefaultMonospacedFontName(), 14.0f, Font::plain});

    // Draw previous lines.
    g.setColour (Colours::white);
    const int currentLineY =getHeight() - kBottomMargin;
    int y = currentLineY - (kLineSpacing * (int)previousLines->size());
    int maxWidth = kWidthMin;
    auto it = previousLines->begin();
    while(it != previousLines->end())
    {
        g.drawSingleLineText(*it, kLeftMargin, y);
        maxWidth = std::max(maxWidth, (int) g.getCurrentFont().getStringWidth(*it));
        y += kLineSpacing;
        it++;
    }
    mWidestLine = kLineSpacing + maxWidth;

    // Draw cursor under the current line.
    int32_t cursor = mTerminalModel.getLineCursor();
    String &line = mTerminalModel.getCurrentLine();

    const int cursorX = kLeftMargin
            + g.getCurrentFont().getStringWidth(line.substring(0, cursor)) - 1;
    g.setColour(mCursorColour);
    const int cursorHeight = (int) g.getCurrentFont().getHeight();
    const int cursorWidth = (int) g.getCurrentFont().getStringWidth(String(" "));
    g.fillRect(cursorX, currentLineY - cursorHeight + 2, cursorWidth, cursorHeight);

    // Draw current line.
    g.setColour (Colours::white);
    g.drawSingleLineText(line, kLeftMargin, currentLineY);
}

void TerminalComponent::resized()
{
    // This method is where you should set the bounds of any child
    // components that your component contains..
}


