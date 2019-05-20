/*
 Component with an image that accumulates drawing operations.
*/

#include "MainComponent.h"

//==============================================================================
MainComponent::MainComponent()
{
    mImage.reset(new Image(Image::RGB, 200, 200, true));
    Graphics g(*mImage.get());
    g.fillAll (Colours::blue);

    setSize (600, 400);
    setFramesPerSecond(60);
}

MainComponent::~MainComponent() {
}

void MainComponent::update() {
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
    g.setColour (mCurrentColour);
    float descent = g.getCurrentFont().getDescent();
    g.drawSingleLineText(string, mCurrentX, mCurrentY + descent);
    mCurrentX += g.getCurrentFont().getStringWidth(string);
}

int32_t MainComponent::getTextLength(const char *text,
                                     int32_t numChars) {
    String string(text, numChars);
    Graphics g(*mImage.get());
    return (int32_t) g.getCurrentFont().getStringWidth(string);
}

void MainComponent::fillRectangle(int32_t x1, int32_t y1, int32_t x2, int32_t y2) {
    Graphics g(*mImage.get());
    g.setColour (mCurrentColour);
    g.fillRect(x1, y1, x2 - x1, y2 - y1);
    mCurrentX = x1;
    mCurrentY = y1;
}

void MainComponent::setColor(int32_t color ) {
    mCurrentColour = Colour(kPalette[color % kPalette.size()]);
}

//==============================================================================
void MainComponent::paint (Graphics& g) {
    // Our component is opaque, so we must completely fill the background with a solid colour.
    g.fillAll (Colours::green);

    drawRandomLine();
    drawText("hello", 5);
    fillRectangle(10, 20, 130, 140);

    int x = 10 + (getFrameCounter() % 200);
    int y = 10;
    g.drawImageAt(*mImage, x, y);


    // Draw a moving circle.
    g.setColour (Colours::white); // [2]
    int radius = 150;                                                  // [3]
    Point<float> p (getWidth()  / 2.0f + 1.0f * radius * std::sin (getFrameCounter() * 0.04f),
                    getHeight() / 2.0f + 1.0f * radius * std::cos (getFrameCounter() * 0.04f));
    g.fillEllipse (p.x, p.y, 30.0f, 30.0f);                           // [5]
}

void MainComponent::resized() {
}
