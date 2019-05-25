/*
  ==============================================================================

    GraphicsWindow.h
    Created: 22 May 2019 7:14:18pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"
#include "MainComponent.h"

//==============================================================================
/*
 This class implements the desktop window that contains an instance of
 our MainComponent class.
 */
class GraphicsWindow    : public DocumentWindow
{
public:
    GraphicsWindow (String name)
    : DocumentWindow (name,
                      Desktop::getInstance().getDefaultLookAndFeel().findColour (ResizableWindow::backgroundColourId),
                      DocumentWindow::allButtons)
    {
        setUsingNativeTitleBar (true);
        mMainComponent.reset(new MainComponent());
        setContentOwned(mMainComponent.get(), true);

#if JUCE_IOS || JUCE_ANDROID
        setFullScreen (true);
#else
        setResizable (true, true);
        centreWithSize (getWidth(), getHeight());
#endif

        setVisible (true);
    }

    void closeButtonPressed() override {
        // For graphics windows, just close the window. Do not exit.
        mMainComponent->onCloseButtonPressed();
    }

    MainComponent *getMainComponent() {
        return mMainComponent.get();
    }

    static GraphicsWindow *openNewWindow(const char *text) {
        MessageManager *messageManager = MessageManager::getInstance();
        void *window = messageManager->callFunctionOnMessageThread(createNewWindow,
                                                                          (void *)"HMSL");
        return static_cast<GraphicsWindow *>(window);
    }

private:
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (GraphicsWindow)

    static void *createNewWindow(void *text) {
        return (void *) new GraphicsWindow(String((char *)text));
    }

    std::unique_ptr<MainComponent> mMainComponent;
};
