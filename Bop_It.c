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
#define OUT_OF_TIME (2)

#define MAX_STRING (79)

#define WHITE_LED_MASK (0x10000)
#define RED_LED_MASK (0x2000)
#define YELLOW_LED_MASK (0x800)
#define GREEN_LED_MASK (0x400)
#define BLUE_LED_MASK (0x80)
#define ALL_LED_MASK (0x12C80)

#define PERIOD_SCALE (.75)
#define START_PERIOD (3000)
#define BUTTS_PER_STAGE (10)

char dubmStr[MAX_STRING];
char SUCCess;
int rand;
int expectButt;
int SUCCcount;
int highScore;
int currentPeriod;

/*
 *	getRandNum
 *	Get a random number between 0 and 4
 *	inputs: none
 *	outputs: ranDUMB number between 0 and 4
 */
int getRandNum (void) {
	int rand = (GetCount() & 0x03);
	int addend = (GetCount() & 0x04);
	rand += addend;
	return rand;
}

/* 
 * 	nextButton
 * 	reset the buttTouch and light up the next light
 *	inputs: int between 0 and 4
 *	outputs: none
 */
void nextButton (int button) {
	ButtTouch = 5;
	GPIO_Write_LED(ALL_LED_MASK, FALSE);
	switch (button) {
		case 0: {GPIO_Write_LED(WHITE_LED_MASK, TRUE); expectButt = 0;}; break;
		case 1: GPIO_Write_LED(RED_LED_MASK, TRUE); break;
		case 2: GPIO_Write_LED(YELLOW_LED_MASK, TRUE); break;
		case 3: GPIO_Write_LED(GREEN_LED_MASK, TRUE); break;
		case 4: GPIO_Write_LED(BLUE_LED_MASK, TRUE); break;
	}
}

/*
 *	waitForButt
 *	get the next button pressed and compare it against the expected button
 *	inputs: int between 0 and 4
 *	outputs: true if button matches expected, otherwise false
 */
char waitForButt (int expected) {
	while (ButtTouch == 5) {
		if (GetCount() > currentPeriod) {
			return OUT_OF_TIME;
		}
	}
	if (ButtTouch == expected) {
		return TRUE;
	}
	else {
		return FALSE;
	}
}



int main (void) {
	//init some stuff
	highScore = 0;
	ButtTouch = 5;
	
	//init UART and PIT
	__ASM("CPSID I");
	Init_UART0_IRQ();
	Init_PIT_IRQ();
	GPIO_BopIt_Init();
	ResetStopwatch();
	__ASM("CPSIE I");
	
	//restart your clox
	//ResetStopwatch();
	
	for(;;) {
		__asm("CPSIE I");
		//PutStringSB("Welcome to Bop-It! The current high score is ",MAX_STRING);
		//PutNumUB(highScore);
		//PutStringSB("Press any button to start the game", MAX_STRING);
		//YO NEW HIGH SCORE IN TOWN
		if(SUCCcount > highScore) {
			highScore = SUCCcount;
		}
		//init some other stuff
		currentPeriod = START_PERIOD;
		SUCCcount = 0;
		//Turn all LEDs on for AESTHETIC
		GPIO_Write_LED(ALL_LED_MASK, TRUE);
		__asm("CPSIE I");
		PutStringSB("Welcome to Bop-It! The current high score is \r\n",MAX_STRING);
		PutNumUB(highScore);
		PutStringSB("Press any button to start the game\r\n", MAX_STRING);
		__asm("CPSIE	I");
		ButtChange();
		//COUNTDOWN TIIIIIIIIIIIIIIME
		__asm("CPSIE	I");
		WaitForCount(1000);
		PutStringSB("3", MAX_STRING);
		WaitForCount(2000);
		PutStringSB("2", MAX_STRING);
		WaitForCount(3000);
		PutStringSB("1", MAX_STRING);
		for(;;) {
			//check if you should shift into MAXIMUM OVERDRIVE
			if (SUCCcount % BUTTS_PER_STAGE == 0) {
				__asm("CPSIE	I");
				PutStringSB("Speeding up!\r\n",MAX_STRING);
				currentPeriod *= PERIOD_SCALE;
			}
			//grab a butt
			rand = getRandNum();
			nextButton(rand);
			SUCCess = ButtChange();
			//is the butt right?
			if (SUCCess != rand) {
				GPIO_Write_LED(ALL_LED_MASK, TRUE);
				PutStringSB("Wrong Button! Press any button to play again\r\n", MAX_STRING);
				break;
			}
			PutStringSB("yay\r\n",MAX_STRING);
			SUCCcount ++;
		}
	}
	/* do forever */
  return (0);
} /* main */


//int main (void) {
//	__ASM("CPSID I");
//	Init_UART0_IRQ();
//	__ASM("CPSIE I");
//	PutStringSB("Welcome to guessing game (not bop it) press a button to start", MAX_STRING);
//	ButtChange();
//}
