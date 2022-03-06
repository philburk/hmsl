/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic startup code for a JUCE application.

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "GraphicsWindow.h"
#include "LocalSynth.h"
#include "Terminal.h"
#include "ForthThread.h"

#define HMSL_VERSION "v0.5.6"

//==============================================================================
class ProtoHMSLApplication  : public JUCEApplication
{
public:
    //==============================================================================
    ProtoHMSLApplication() {}

    const String getApplicationName() override       { return ProjectInfo::projectName; }
    const String getApplicationVersion() override    { return ProjectInfo::versionString; }
    bool moreThanOneInstanceAllowed() override       { return true; }

    //==============================================================================
    void initialise (const String& commandLine) override
    {
        // This method is where you should put your application's initialisation code..
        mTerminalWindow.reset (new TerminalWindow (getApplicationName()));

        mForthThread.reset(new ForthThread());
        mForthThread->startThread();
    }

    void shutdown() override
    {
        // TODO needed?
        mTerminalWindow->requestClose();
        mForthThread->signalThreadShouldExit();
        mForthThread->stopThread(1000);
    }

    //==============================================================================
    void systemRequestedQuit() override
    {
        mTerminalWindow->requestClose();
        mForthThread->waitForThreadToExit(500);
        // This is called when the app is being asked to quit: you can ignore this
        // request and let the app carry on running, or call quit() to allow the app to close.
        quit();
    }

    void anotherInstanceStarted (const String& commandLine) override
    {
        // When another instance of the app is launched while this one is running,
        // this method is invoked, and the commandLine parameter tells you what
        // the other instance's command-line arguments were.
    }

    //==============================================================================
    /*
     This class implements the desktop window that contains an instance of
     our TerminalComponent class.
     */
    class TerminalWindow    : public DocumentWindow
    {
    public:
        TerminalWindow (String name)  : DocumentWindow (name + (" " HMSL_VERSION),
                                                    Desktop::getInstance().getDefaultLookAndFeel()
                                                    .findColour (ResizableWindow::backgroundColourId),
                                                    DocumentWindow::allButtons)
        {
            setUsingNativeTitleBar (true);
            mTerminal.reset(new Terminal());
            setContentOwned(mTerminal.get(), true);

#if JUCE_IOS || JUCE_ANDROID
            setFullScreen (true);
#else
            setResizable (true, true);
            centreWithSize (getWidth(), getHeight());
#endif

            setVisible (true);

        }

        void requestClose() {
            mTerminal->requestClose();
            usleep(50 * 1000); // wait for Forth to get the message
        }

        void closeButtonPressed() override
        {
            requestClose();

            // This is called when the user tries to close this window. Here, we'll just
            // ask the app to quit when this happens, but you can change this to do
            // whatever you need.
            JUCEApplication::getInstance()->systemRequestedQuit();
        }

        /* Note: Be careful if you override any DocumentWindow methods - the base
         class uses a lot of them, so by overriding you might break its functionality.
         It's best to do all your work in your content component instead, but if
         you really have to override any DocumentWindow methods, make sure your
         subclass also calls the superclass's method.
         */

    private:
        JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TerminalWindow)

        std::unique_ptr<Terminal>   mTerminal;
    };

private:
    std::unique_ptr<TerminalWindow> mTerminalWindow;
    std::unique_ptr<ForthThread>    mForthThread;
};

//==============================================================================
// This macro generates the main() routine that launches the app.
START_JUCE_APPLICATION (ProtoHMSLApplication)
