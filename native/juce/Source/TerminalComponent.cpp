/*
  ==============================================================================

    TerminalComponent.cpp
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalComponent.h"

// TODO Move MenuComponent to its own file.
//#include "MenuComponent.h"

MenuComponent::MenuComponent(TerminalComponent *terminalComponent)
: mTerminalComponent(terminalComponent) {
    // `this` already implements the `MenuBarModel` so this is going to return a
    // `MenuBarComponent` with the Model already setup.
    //menuBarComponent.reset(new juce::MenuBarComponent(this));
    menuBarComponent = std::make_unique<juce::MenuBarComponent>(this);
    // getting the new component to show up.
    addAndMakeVisible(menuBarComponent.get());
    setMacMainMenu(this);
    resized(); // this is NEEDED for the first time rendering.
}

MenuComponent::~MenuComponent() {
    setMacMainMenu(nullptr); // avoid jassert
}

void MenuComponent::paint(juce::Graphics& g) {
    g.fillAll(juce::Colours::beige);

    g.setFont (juce::Font (20.0f));
    g.setColour (juce::Colours::black);
}

void MenuComponent::resized() {
    //setting the size of our normal component.
    setSize(getParentWidth(), 20);
    // setting the size of the menuComponent inside this component.
    menuBarComponent.get()->setSize(getParentWidth(), 20);
}

juce::StringArray MenuComponent::getMenuBarNames() {
    return {"Edit", "Screens"};
}

juce::PopupMenu MenuComponent::getMenuForIndex(int topLevelMenuIndex, const juce::String& menuName) {
    juce::PopupMenu menu;

    if (menuName == "Edit") {
        menu.addItem(MENU_ID_PASTE, "Paste");
    } else if (menuName == "Screens") {
        menu.addItem(MENU_ID_SHAPE_EDITOR, "Shape Editor");
    }

    return menu;
}

void MenuComponent::menuItemSelected(int menuItemID, int topLevelMenuIndex) {
    switch (menuItemID) {
        case MENU_ID_PASTE:
            mTerminalComponent->onPaste();
            break;
        default:
            break;
    }
}


TerminalComponent::TerminalComponent(TerminalModel &model)
    : mTerminalModel(model)
    , menuComponent(this)
    , mCursorColour(0xffC08020) {
    setSize(400, 100);

    addKeyListener(this);
    setWantsKeyboardFocus(true);
}

TerminalComponent::~TerminalComponent() {
    removeKeyListener(this);
}

bool TerminalComponent::keyPressed (const KeyPress &key,
                                Component *originatingComponent) {
    return mTerminalModel.onKeyPressed(key);
}

void TerminalComponent::onPaste() {
    String pasted = SystemClipboard::getTextFromClipboard();
    for (int i = 0; i < pasted.length(); ++i) {
        mTerminalModel.sendCharacter(pasted[i]);
    }
}

void TerminalComponent::paint (Graphics& g)
{
    mRepaintRequested = false;
    mNumPaints++;

    mTerminalModel.processOutputQueue();

    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));   // clear the background
    g.setFont({Font::getDefaultMonospacedFontName(), kFontSize, Font::plain});

    std::list<String> &storedLines = mTerminalModel.getStoredLines();
    const int numLines = (int) storedLines.size();
    int y = getHeight() - (getNumLinesVisible() * kLineSpacing);
    int yLimit = getHeight() + kLineSpacing;
    if ( numLines > 0) {
        // Draw previous lines starting with mTopLine
        g.setColour (Colours::white);
        int maxWidth = kWidthMin;
        int32_t lineCounter = 0;
        auto it = storedLines.begin();
        while(it != storedLines.end() && y < yLimit) {
            if (lineCounter >= mTopLine) {
                g.drawSingleLineText(*it, kLeftMargin, y);
                maxWidth = std::max(maxWidth, (int) g.getCurrentFont().getStringWidth(*it));
                y += kLineSpacing;
            }
            lineCounter++;
            it++;
        }
        mWidestLine = kLeftMargin + maxWidth;
    }

    if (y < yLimit) {
        // Draw cursor under the current line.
        int32_t cursor = mTerminalModel.getLineCursor();
        String &line = mTerminalModel.getCurrentLine();
        const int cursorX = kLeftMargin
                + g.getCurrentFont().getStringWidth(line.substring(0, cursor)) - 1;
        g.setColour(mCursorColour);
        const int cursorHeight = (int) g.getCurrentFont().getHeight();
        const int cursorWidth = (int) g.getCurrentFont().getStringWidth(String(" "));
        g.fillRect(cursorX, y - cursorHeight + 2, cursorWidth, cursorHeight);

        // Draw current line.
        g.setColour (Colours::white);
        g.drawSingleLineText(line, kLeftMargin, y);
    }
/*
    // Display debug info
    String info = "stored = ";
    info += numLines;
    info += ", top = ";
    info += mTopLine;
    info += ", #rq = ";
    info += mNumRepaintsRequested;
    info += ", #pt = ";
    info += mNumPaints;
    g.setColour (Colours::yellow);
    const int leftX = getWidth() - (int)g.getCurrentFont().getStringWidth(info);
    g.drawSingleLineText(info, leftX, kLineSpacing);
 */
}

void TerminalComponent::requestRepaint() {
    if (!mRepaintRequested.exchange(true)) {
        juce::MessageManager::callAsync([this]() {
            mNumRepaintsRequested++;
            this->repaint();
        });
    }
}
