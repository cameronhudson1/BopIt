/*********************************************************************/
/* Bop It                                               */
/* Plays a game of bop it using the FRDM KL46Z development board.    */
/* This project uses mixed assembly language and C. Assembly is      */
/* used for initialization of modules, UART interaction and          */
/* interrupt handling. The game is played by entering information    */
/* and reading instructions from the terminal, then pressing buttons */
/* on the toy before a timer runs out. The button to be pressed next */
/* is denoted by a button lighting up on on the toy.                 */
/* Name:  R. W. Melton                                               */
/* Date:  November 3, 2017                                           */
/* Class:  CMPE 250                                                  */
/* Section:  All sections                                            */
/*********************************************************************/
typedef int Int32;
typedef short int Int16;
typedef char Int8;
typedef unsigned int UInt32;
typedef unsigned short int UInt16;
typedef unsigned char UInt8;

/* assembly language variables */
extern char ButtTouch;

/* assembly language subroutines */
char GetChar (void);
void GetStringSB (char String[], int StringBufferCapacity);
void Init_UART0_IRQ (void);
void Init_PIT_IRQ (void);
void PutChar (char Character);
void PutNumHex (UInt32);
void PutNumUB (UInt8);
void PutStringSB (char String[], int StringBufferCapacity);
void GPIO_BopIt_Init (void);
void GPIO_Write_LED (int LEDMask, int on);
int GetCount (void);
void ResetStopwatch (void);
int ButtChange (void);
void WaitForCount (int);
