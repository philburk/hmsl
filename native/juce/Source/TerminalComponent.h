/*
  ==============================================================================

    TerminalComponent.h
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <list>
#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalModel.h"
#include "TerminalComponent.h"

class TerminalComponent; // Forward reference

// Example Menu from https://forum.juce.com/t/getting-a-menu-bar-to-work-in-juce/59923/10

// We do not need to implement the `MenuBarComponent`,
// it is added as a class member.
class MenuComponent :   public juce::Component,
                        public juce::MenuBarModel
{
public:
    //========================================
    MenuComponent(TerminalComponent *terminalComponent);
    ~MenuComponent() override;
    //========================================
    void paint(juce::Graphics& g) override;
    void resized() override;
    //========================================
    juce::StringArray getMenuBarNames() override;
    juce::PopupMenu getMenuForIndex(int topLevelMenuIndex, const juce::String& menuName) override;
    void menuItemSelected(int menuItemID, int topLevelMenuIndex) override;

private:
    std::unique_ptr<juce::MenuBarComponent> menuBarComponent;
    TerminalComponent *mTerminalComponent;

    enum {
        MENU_ID_PASTE = 1,
        MENU_ID_SHAPE_EDITOR
    };

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (MenuComponent)
};

class TerminalComponent    : public Component, KeyListener
{
public:
    explicit TerminalComponent(TerminalModel &model);
    ~TerminalComponent();

    /**
     * Request a single repaint.
     * Uses an atomic bool that is cleared by paint();
     */
    void requestRepaint();
    void paint (Graphics&) override;

    bool keyPressed (const KeyPress &key, Component *originatingComponent) override;

    void onPaste();

    void setTopLine(int32_t topLine) {
        mTopLine = topLine;
    }

    int32_t getTopLine() {
        return mTopLine;
    }

    int32_t getNumLinesVisible() {
        int32_t linesAvailable = (getHeight() - kBottomMargin) / kLineSpacing;
        return std::min(linesAvailable, mTerminalModel.getNumLinesStored() + 1);
    }

private:

    static constexpr  int  kMaxLinesVisible = 200; // allow scrolling
    static constexpr  int  kLeftMargin = 5;
    static constexpr  int  kBottomMargin = 20;
    static constexpr  int  kWidthMin = 200;
    static constexpr  int  kHeightMin = 100;

    float                  kFontSize = 18.0f;
    int                    kLineSpacing = static_cast<int>(kFontSize + 2);

    TerminalModel         &mTerminalModel;
    MenuComponent          menuComponent;

    int32_t                mWidestLine = kWidthMin;
    Colour                 mCursorColour;
    int32_t                mTopLine = 0;

    int32_t                mNumPaints = 0;
    int32_t                mNumRepaintsRequested = 0;

    std::atomic<bool>      mRepaintRequested{false};

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TerminalComponent)
};
