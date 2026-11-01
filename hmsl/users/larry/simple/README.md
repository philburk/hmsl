# Simple Actions by Larry Polansky.

This is the first version, which used Amiga local sound.

## To Run

Launch HMSL then enter:

1. Setup the file assignments. Enter:  include users/assigns.fth
(You can copy and paste into HMSL using the Edit menu.)
2. Compile the code. Enter:  include husa:load_simple.fth
3. Run the piece. Enter:  SACT

## To Play

1. Click the “Perform” button.
2. Click on sact-1 through sact-4 to turn on or off the sound.
3. Click on other "sact-*" buttons.
4. Explore. Don't worry if it is confusing. The complexity is part of the piece.

You should hear a very noisy modulated sound that is created using the Amiga Local Sound emulator in HMSL.

Close the window when done.

## Optional - Use the original Amiga Dictionary RAM

The original piece ran on the Amiga. It used the Amiga
JForth dictionary as a waveform and modulation source.
So the audience was listening to the code directly.

The current implementation on pForth uses the pForth dictionary.
It sounds different because it has more zeros than JForth and is not native code.

If you want Simple Action to sounds closer to what it sounded like on the Amiga,
then you can download an archive that contains an HMSL JForth executable.
You can place the archive at the top of your filesystem at "~" or at "~/work/".
We will look in both places.
Then we will load the executable into memory and use it as the waveform.

```
cd ~
git clone https://github.com/philburk/hmsl-archive.git
```

Then rerun the piece. You can switch between the two RAMs and hear the difference.
It will print out which RAM is being used.

```
sar-ram-enabled OFF
sact
sar-ram-enabled ON
sact
```

<img width="601" height="433" alt="action_table_sact" src="https://github.com/user-attachments/assets/bafd1157-9f7a-4330-b068-4fd40588380a" />
