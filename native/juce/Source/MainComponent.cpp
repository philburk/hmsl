/*
 Component with an image that accumulates drawing operations.
*/

#include "MainComponent.h"


//==============================================================================
MainComponent::MainComponent()
: mCommandQueue(1024), mEventQueue(256) {
    mImage.reset(new Image(Image::RGB, 1000, 800, true));
    Graphics g(*mImage.get());
    g.fillAll (Colours::blue);

    setSize (640, 480);
    setFramesPerSecond(60);
}

MainComponent::~MainComponent() {
}

void MainComponent::update() {
    while (!mCommandQueue.empty()) {
        HmslCommand_t cmd = mCommandQueue.read();
        mCommandQueue.advanceRead();
        switch(cmd.opcode) {
            case MOVE_TO:
                mCurrentX = cmd.x;
                mCurrentY = cmd.y;
                break;
            case DRAW_TO:
                drawLineTo(cmd.x, cmd.y);
                break;
            case FILL_RECT:
                fillRect(cmd.x, cmd.y);
                break;
            case SET_COLOR:
                setColor(cmd.x);
                break;
            case SET_BACKGROUND_COLOR:
                setBackgroundColor(cmd.x);
                break;
            case DRAW_TEXT:
                drawText(cmd.text, cmd.x);
                free((void *)cmd.text); // allocated by postDrawTo()
                break;
            default:
                break;
        }
    }
}

void MainComponent::drawLineTo(int x, int y) {
    Graphics g(*mImage.get());
    g.setColour (mCurrentColour);
    g.drawLine(mCurrentX, mCurrentY, x, y);
    mCurrentX = x;
    mCurrentY = y;
}

void MainComponent::drawRandomLine() {
    setColor((int32_t)(drand48() * 1000));
    int x = (int) (drand48() * mImage->getWidth());
    int y = (int) (drand48() * mImage->getWidth());
    drawLineTo(x, y);
}

void MainComponent::drawText(const char *text, int32_t numChars) {
    String string(text, numChars);
    Graphics g(*mImage.get());
    float descent = g.getCurrentFont().getDescent();
    // Old graphics was based on bit-mapped fonts that overwrote the background.
    g.setColour(Colours::white);
    float width = g.getCurrentFont().getStringWidth(string);
    float height = g.getCurrentFont().getHeight();
    g.fillRect((float)mCurrentX, mCurrentY + descent - height,
               width, height);
    // Draw text in current colour.
    g.setColour (mCurrentColour);
    g.drawSingleLineText(string, mCurrentX, mCurrentY + descent);
    mCurrentX += g.getCurrentFont().getStringWidth(string);
}

int32_t MainComponent::getTextLength(const char *text,
                                     int32_t numChars) {
    String string(text, numChars);
    Graphics g(*mImage.get());
     const MessageManagerLock myLock;
    return (int32_t) g.getCurrentFont().getStringWidth(string);
}

void MainComponent::fillRect(int32_t width, int32_t height) {
    Graphics g(*mImage.get());
    g.setColour (mCurrentColour);
    g.fillRect(mCurrentX, mCurrentY, width, height);
}

void MainComponent::setColor(int32_t color ) {
    mCurrentColour = Colour(kPalette[color % kPalette.size()]);
}

void MainComponent::setBackgroundColor(int32_t color ) {
    mBackgroundColour = Colour(kPalette[color % kPalette.size()]);
}

bool MainComponent::getNextEvent(HmslEvent_t *event) {
    if (!mEventQueue.empty()) {
        *event = mEventQueue.read();
        mEventQueue.advanceRead();
        return true;
    }
    return false;
}


//==============================================================================
void MainComponent::paint (Graphics& g) {
    g.fillAll (Colours::black);
    g.drawImageAt(*mImage, 0, 0);
}

void MainComponent::resized() {
    postEvent(EV_REFRESH, 0, 0);
}
