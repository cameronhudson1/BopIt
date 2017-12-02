/*********************************************************************/
/* Bop It                                                            */
/* Plays a game of bop it using the FRDM KL46Z development board.    */
/* This project uses mixed assembly language and C. Assembly is      */
/* used for initialization of modules, UART interaction and          */
/* interrupt handling. The game is played by entering information    */
/* and reading instructions from the terminal, then pressing buttons */
/* on the toy before a timer runs out. The button to be pressed next */
/* is denoted by a button lighting up on on the toy.                 */
/* Name:  David Pastuch, Cameron Hudson                              */
/* Date:  November 28, 2017                                          */
/* Class:  CMPE 250                                                  */
/* Section:  L3, Thursday 2:00 P.M.                                  */
/*********************************************************************/
#include "MKL46Z4.h"
#include "Bop_It.h"

#define FALSE      (0)
#define TRUE       (1)

#define MAX_STRING (79)

#define WHITE_LED_MASK (0x10000)
#define RED_LED_MASK (0x2000)
#define YELLOW_LED_MASK (0x800)
#define GREEN_LED_MASK (0x400)
#define BLUE_LED_MASK (0x80)

/*
*	getRandNum
*	Get a random number between 0 and 4
*	inputs: none
*	outputs: ranDUMB number between 0 and 4
*
*/
int getRandNum (void) {
	int rand = (Count & 0x03);
	int addend = (Count & 0x04);
	rand += addend;
	return rand;
}

int main (void) {
	for(;;) {
		char dubmStr[MAX_STRING];
		int rand;
		
		//init UART and PIT
		__ASM("CPSID I");
		Init_UART0_IRQ();
		Init_PIT_IRQ();
		GPIO_BopIt_Init();
		__ASM("CPSIE I");
		
		//get a fellas name but you actually getting a seed for the RNG LOL xDDD
		Count = 0;
		RunStopWatch = 1;
		PutStringSB("Welcome to Bop-It! nigga whatcho name say it back   >", MAX_STRING);
		GetStringSB(dubmStr, MAX_STRING);
		
	}
	/* do forever */
  return (0);
} /* main */
