/*
  ==============================================================================

    This file was originally auto-generated.
    But it has a lot of edits. So I assume it will not get overwritten.

    It contains the basic startup code for a JUCE application.

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "GraphicsWindow.h"
#include "Terminal.h"
#include "ForthThread.h"
#include "HostFileManager.h"
#include "hmsl_version.h"
#include "pf_juce_io.h"

//==============================================================================
class ProtoHMSLApplication  : public JUCEApplication
{
public:
    //==============================================================================
    ProtoHMSLApplication() {}

    const String getApplicationName() override       { return "HMSL"; }
    const String getApplicationVersion() override    { return HMSL_VERSION_STRING; }
    bool moreThanOneInstanceAllowed() override       { return true; }

    //==============================================================================
    void initialise (const String& commandLine) override
    {
        // Launch with "--build-dictionary" to compile pForth and HMSL then quit.
        mBuildDictionary = commandLine.contains("--build-dictionary");

        // For testing, launch with --type 'text' to type text into Forth, eg.
        //     JuceHMSL --type 'y\rinclude hp:bounce.fth\rbounce\r'
        // "\r" is replaced by RETURN. Forth output is also copied to stdout.
        StringArray args = StringArray::fromTokens(commandLine, true);
        int typeIndex = args.indexOf("--type");
        if (typeIndex >= 0 && typeIndex + 1 < args.size()) {
            mTypedText = args[typeIndex + 1].unquoted().replace("\\r", "\r");
            gEchoTerminalToStdout = true;
        }

        HostFileManager *hostFileManager = HostFileManager::getInstance();
        if (!hostFileManager->isInstalled()) {
            startHMSL(); // running in the HMSL repository
            return;
        }

        PropertiesFile::Options options;
        options.applicationName = "HMSL";
        options.folderName = "HMSL";
        options.filenameSuffix = "settings";
        options.osxLibrarySubFolder = "Application Support";
        mSettings.setStorageParameters(options);

        // Hold down the Option key while launching to choose a different work folder.
        File workFolder(mSettings.getUserSettings()->getValue(kWorkFolderKey));
        bool isOptionDown = ModifierKeys::getCurrentModifiersRealtime().isAltDown();
        if (workFolder.isDirectory() && !isOptionDown) {
            useWorkFolder(workFolder);
        } else {
            askForWorkFolder();
        }
    }

    // Create the terminal window and start Forth.
    void startHMSL()
    {
        mTerminalWindow.reset (new TerminalWindow (getApplicationName()));
        if (mTypedText.isNotEmpty()) {
            Terminal::getInstance()->typeText(mTypedText);
        }

        mForthThread.reset(new ForthThread(mBuildDictionary));
        mForthThread->startThread();
    }

    void askForWorkFolder()
    {
        File defaultFolder = File::getSpecialLocation(File::userDocumentsDirectory)
                .getChildFile("HMSL");
        auto options = MessageBoxOptions()
                .withIconType(MessageBoxIconType::QuestionIcon)
                .withTitle("Choose HMSL Work Folder")
                .withMessage("HMSL keeps your pieces, tools and other Forth files in a work folder.\n\n"
                             "Use " + defaultFolder.getFullPathName() + " ?\n\n"
                             "Hold down the Option key when launching HMSL to change the folder.")
                .withButton("Use Documents/HMSL")
                .withButton("Choose Folder...")
                .withButton("Quit");
        NativeMessageBox::showAsync(options, [this, defaultFolder](int buttonIndex) {
            if (buttonIndex == 0) {
                useWorkFolder(defaultFolder);
            } else if (buttonIndex == 1) {
                browseForWorkFolder(defaultFolder);
            } else {
                quit();
            }
        });
    }

    void browseForWorkFolder(const File &defaultFolder)
    {
        mFileChooser.reset(new FileChooser("Choose HMSL Work Folder",
                                           defaultFolder.getParentDirectory()));
        int flags = FileBrowserComponent::openMode
                | FileBrowserComponent::canSelectDirectories;
        mFileChooser->launchAsync(flags, [this](const FileChooser &chooser) {
            File folder = chooser.getResult();
            if (folder == File()) {
                askForWorkFolder(); // cancelled
            } else {
                useWorkFolder(folder);
            }
        });
    }

    void useWorkFolder(const File &folder)
    {
        if (!HostFileManager::getInstance()->setWorkFolder(folder)) {
            auto options = MessageBoxOptions()
                    .withIconType(MessageBoxIconType::WarningIcon)
                    .withTitle("HMSL")
                    .withMessage("Could not use " + folder.getFullPathName())
                    .withButton("OK");
            NativeMessageBox::showAsync(options, [this](int) { askForWorkFolder(); });
            return;
        }
        mSettings.getUserSettings()->setValue(kWorkFolderKey, folder.getFullPathName());
        mSettings.saveIfNeeded();
        startHMSL();
    }

    void shutdown() override
    {
        if (mForthThread == nullptr) return; // quit before HMSL started
        // TODO needed?
        mTerminalWindow->requestClose();
        mForthThread->signalThreadShouldExit();
        mForthThread->stopThread(1000);
    }

    //==============================================================================
    void systemRequestedQuit() override
    {
        if (mForthThread != nullptr) {
            mTerminalWindow->requestClose();
            mForthThread->waitForThreadToExit(500);
        }
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
        TerminalWindow (String name)  : DocumentWindow (name + (" V" HMSL_VERSION_STRING),
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
    static constexpr const char *kWorkFolderKey = "workFolder";

    std::unique_ptr<TerminalWindow> mTerminalWindow;
    std::unique_ptr<ForthThread>    mForthThread;
    std::unique_ptr<FileChooser>    mFileChooser;
    ApplicationProperties           mSettings;
    bool                            mBuildDictionary = false;
    String                          mTypedText; // see --type
};

//==============================================================================
// This macro generates the main() routine that launches the app.
START_JUCE_APPLICATION (ProtoHMSLApplication)
