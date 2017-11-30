            TTL Program Title for Listing Header Goes Here
;****************************************************************
;Descriptive comment header goes here.
;(What does the program do?)
;Name:  <Your name here>
;Date:  <Date completed here>
;Class:  CMPE-250
;Section:  <Your lab section, day, and time here>
;---------------------------------------------------------------
;Keil Template for KL46 Assembly with Keil C startup
;R. W. Melton
;November 13, 2017
;****************************************************************
;Assembler directives
            THUMB
            GBLL  MIXED_ASM_C
MIXED_ASM_C SETL  {TRUE}
            OPT   64  ;Turn on listing macro expansions
;****************************************************************
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates
;---------------------------------------------------------------
;NVIC_ICER
;31-00:CLRENA=masks for HW IRQ sources;
;             read:   0 = unmasked;   1 = masked
;             write:  0 = no effect;  1 = mask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ICER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_ICPR
;31-00:CLRPEND=pending status for HW IRQ sources;
;             read:   0 = not pending;  1 = pending
;             write:  0 = no effect;
;                     1 = change status to not pending
;22:PIT IRQ pending status
;12:UART0 IRQ pending status
NVIC_ICPR_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ICPR_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_IPR0-NVIC_IPR7
;2-bit priority:  00 = highest; 11 = lowest
;--PIT
PIT_IRQ_PRIORITY    EQU  0
NVIC_IPR_PIT_MASK   EQU  (3 << PIT_PRI_POS)
NVIC_IPR_PIT_PRI_0  EQU  (PIT_IRQ_PRIORITY << UART0_PRI_POS)
;--UART0
UART0_IRQ_PRIORITY    EQU  3
NVIC_IPR_UART0_MASK   EQU  (3 << UART0_PRI_POS)
NVIC_IPR_UART0_PRI_3  EQU  (UART0_IRQ_PRIORITY << UART0_PRI_POS)
;---------------------------------------------------------------
;NVIC_ISER
;31-00:SETENA=masks for HW IRQ sources;
;             read:   0 = masked;     1 = unmasked
;             write:  0 = no effect;  1 = unmask
;22:PIT IRQ mask
;12:UART0 IRQ mask
NVIC_ISER_PIT_MASK    EQU  PIT_IRQ_MASK
NVIC_ISER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;PIT_LDVALn:  PIT load value register n
;31-00:TSV=timer start value (period in clock cycles - 1)
;Clock ticks for 0.01 s at 24 MHz count rate
;0.01 s * 24,000,000 Hz = 240,000
;TSV = 240,000 - 1
PIT_LDVAL_10ms  EQU  239999
;---------------------------------------------------------------
;PIT_MCR:  PIT module control register
;1-->    0:FRZ=freeze (continue'/stop in debug mode)
;0-->    1:MDIS=module disable (PIT section)
;               RTI timer not affected
;               must be enabled before any other PIT setup
PIT_MCR_EN_FRZ  EQU  PIT_MCR_FRZ_MASK
;---------------------------------------------------------------
;PIT_TCTRLn:  PIT timer control register n
;0-->   2:CHN=chain mode (enable)
;1-->   1:TIE=timer interrupt enable
;1-->   0:TEN=timer enable
PIT_TCTRL_CH_IE  EQU  (PIT_TCTRL_TEN_MASK :OR: PIT_TCTRL_TIE_MASK)
;---------------------------------------------------------------
;UART0_S2
;1-->7:LBKDIF=LIN break detect interrupt flag (clear)
;             write 1 to clear
;1-->6:RXEDGIF=RxD pin active edge interrupt flag (clear)
;              write 1 to clear
;0-->5:(reserved); read-only; always 0
;0-->4:RXINV=receive data inversion (disabled)
;0-->3:RWUID=receive wake-up idle detect
;0-->2:BR213=break character generation length (10)
;0-->1:LBKDE=LIN break detect enable (disabled)
;0-->0:RAF=receiver active flag; read-only
UART0_S2_NO_RXINV_BR210_NO_LBKDETECT_CLEAR_FLAGS  EQU  0xC0
;---------------------------------------------------------------
;PORTx_PCRn (Port x pin control register n [for pin n])
;___->10-08:Pin mux control (select 0 to 8)
;Use provided PORT_PCR_MUX_SELECT_2_MASK
;---------------------------------------------------------------
;Port A
PORT_PCR_SET_PTA1_UART0_RX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
PORT_PCR_SET_PTA2_UART0_TX  EQU  (PORT_PCR_ISF_MASK :OR: \
                                  PORT_PCR_MUX_SELECT_2_MASK)
;---------------------------------------------------------------
;SIM_SCGC4
;1->10:UART0 clock gate control (enabled)
;Use provided SIM_SCGC4_UART0_MASK
;---------------------------------------------------------------
;SIM_SCGC5
;1->09:Port A clock gate control (enabled)
;Use provided SIM_SCGC5_PORTA_MASK
;---------------------------------------------------------------
;SIM_SOPT2
;01=27-26:UART0SRC=UART0 clock source select
;         (PLLFLLSEL determines MCGFLLCLK' or MCGPLLCLK/2)
; 1=   16:PLLFLLSEL=PLL/FLL clock select (MCGPLLCLK/2)
SIM_SOPT2_UART0SRC_MCGPLLCLK  EQU  \
                                 (1 << SIM_SOPT2_UART0SRC_SHIFT)
SIM_SOPT2_UART0_MCGPLLCLK_DIV2 EQU \
    (SIM_SOPT2_UART0SRC_MCGPLLCLK :OR: SIM_SOPT2_PLLFLLSEL_MASK)
;---------------------------------------------------------------
;SIM_SOPT5
; 0->   16:UART0 open drain enable (disabled)
; 0->   02:UART0 receive data select (UART0_RX)
;00->01-00:UART0 transmit data select source (UART0_TX)
SIM_SOPT5_UART0_EXTERN_MASK_CLEAR  EQU  \
                               (SIM_SOPT5_UART0ODE_MASK :OR: \
                                SIM_SOPT5_UART0RXSRC_MASK :OR: \
                                SIM_SOPT5_UART0TXSRC_MASK)
;---------------------------------------------------------------
;UART0_BDH
;    0->  7:LIN break detect IE (disabled)
;    0->  6:RxD input active edge IE (disabled)
;    0->  5:Stop bit number select (1)
;00001->4-0:SBR[12:0] (UART0CLK / [9600 * (OSR + 1)]) 
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDH_9600  EQU  0x01
;---------------------------------------------------------------
;UART0_BDL
;26->7-0:SBR[7:0] (UART0CLK / [9600 * (OSR + 1)])
;UART0CLK is MCGPLLCLK/2
;MCGPLLCLK is 96 MHz
;MCGPLLCLK/2 is 48 MHz
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDL_9600  EQU  0x38
;---------------------------------------------------------------
;UART0_C1
;0-->7:LOOPS=loops select (normal)
;0-->6:DOZEEN=doze enable (disabled)
;0-->5:RSRC=receiver source select (internal--no effect LOOPS=0)
;0-->4:M=9- or 8-bit mode select 
;        (1 start, 8 data [lsb first], 1 stop)
;0-->3:WAKE=receiver wakeup method select (idle)
;0-->2:IDLE=idle line type select (idle begins after start bit)
;0-->1:PE=parity enable (disabled)
;0-->0:PT=parity type (even parity--no effect PE=0)
UART0_C1_8N1  EQU  0x00
;---------------------------------------------------------------
;UART0_C2
;0-->7:TIE=transmit IE for TDRE (disabled)
;0-->6:TCIE=transmission complete IE for TC (disabled)
;0-->5:RIE=receiver IE for RDRF (disabled)
;0-->4:ILIE=idle line IE for IDLE (disabled)
;1-->3:TE=transmitter enable (enabled)
;1-->2:RE=receiver enable (enabled)
;0-->1:RWU=receiver wakeup control (normal)
;0-->0:SBK=send break (disabled, normal)
UART0_C2_T_R    EQU  (UART0_C2_TE_MASK :OR: UART0_C2_RE_MASK)
UART0_C2_T_RI   EQU  (UART0_C2_RIE_MASK :OR: UART0_C2_T_R)
UART0_C2_TI_RI  EQU  (UART0_C2_TIE_MASK :OR: UART0_C2_T_RI)
;---------------------------------------------------------------
;UART0_C3
;0-->7:R8T9=9th data bit for receiver (not used M=0)
;           10th data bit for transmitter (not used M10=0)
;0-->6:R9T8=9th data bit for transmitter (not used M=0)
;           10th data bit for receiver (not used M10=0)
;0-->5:TXDIR=UART_TX pin direction in single-wire mode
;            (no effect LOOPS=0)
;0-->4:TXINV=transmit data inversion (not inverted)
;0-->3:ORIE=overrun IE for OR (disabled)
;0-->2:NEIE=noise error IE for NF (disabled)
;0-->1:FEIE=framing error IE for FE (disabled)
;0-->0:PEIE=parity error IE for PF (disabled)
UART0_C3_NO_TXINV  EQU  0x00
;---------------------------------------------------------------
;UART0_C4
;    0-->  7:MAEN1=match address mode enable 1 (disabled)
;    0-->  6:MAEN2=match address mode enable 2 (disabled)
;    0-->  5:M10=10-bit mode select (not selected)
;01111-->4-0:OSR=over sampling ratio (16)
;               = 1 + OSR for 3 <= OSR <= 31
;               = 16 for 0 <= OSR <= 2 (invalid values)
UART0_C4_OSR_16           EQU  0x0F
UART0_C4_NO_MATCH_OSR_16  EQU  UART0_C4_OSR_16
;---------------------------------------------------------------
;UART0_C5
;  0-->  7:TDMAE=transmitter DMA enable (disabled)
;  0-->  6:Reserved; read-only; always 0
;  0-->  5:RDMAE=receiver full DMA enable (disabled)
;000-->4-2:Reserved; read-only; always 0
;  0-->  1:BOTHEDGE=both edge sampling (rising edge only)
;  0-->  0:RESYNCDIS=resynchronization disable (enabled)
UART0_C5_NO_DMA_SSR_SYNC  EQU  0x00
;---------------------------------------------------------------
;UART0_S1
;0-->7:TDRE=transmit data register empty flag; read-only
;0-->6:TC=transmission complete flag; read-only
;0-->5:RDRF=receive data register full flag; read-only
;1-->4:IDLE=idle line flag; write 1 to clear (clear)
;1-->3:OR=receiver overrun flag; write 1 to clear (clear)
;1-->2:NF=noise flag; write 1 to clear (clear)
;1-->1:FE=framing error flag; write 1 to clear (clear)
;1-->0:PF=parity error flag; write 1 to clear (clear)
UART0_S1_CLEAR_FLAGS  EQU  0x1F
;---------------------------------------------------------------
;UART0_S2
;1-->7:LBKDIF=LIN break detect interrupt flag (clear)
;             write 1 to clear
;1-->6:RXEDGIF=RxD pin active edge interrupt flag (clear)
;              write 1 to clear
;0-->5:(reserved); read-only; always 0
;0-->4:RXINV=receive data inversion (disabled)
;0-->3:RWUID=receive wake-up idle detect
;0-->2:BRK13=break character generation length (10)
;0-->1:LBKDE=LIN break detect enable (disabled)
;0-->0:RAF=receiver active flag; read-only
UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS  EQU  0xC0
;--------------------------------------------------------------

MAX_STRING	EQU		79			;max size of string + null termination
IN_PTR		EQU 	0			;pointer to where to enqueue
OUT_PTR		EQU 	4			;pointer to where to dequeue
BUF_STRT	EQU 	8			;start of buffer
BUF_PAST	EQU 	12			;first byte past buffer
BUF_SIZE	EQU 	16			;size of buffer
NUM_ENQD	EQU 	17			;number of elements enqueued
NIB_SHFT	EQU		4			;bits to shift to get next nibble
TXRX_BUF_SIZE	EQU		80
BUFFER_SIZE	EQU		4
GPIOA_BUTT	EQU		2_00000000000000011100000011000000	;pins 6, 7, 14, 15, 16  \\TODO add colors
GPIOC_LED	EQU		2_00000000000000010010110010000000	;pins 7, 10, 11, 13, 16  \\TODO add colors
;****************************************************************
;MACROs
;****************************************************************
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY
			EXPORT	GetChar
			EXPORT	GetStringSB
			EXPORT	Init_UART0_IRQ
			EXPORT	PutChar
			EXPORT	PutNumHex
			EXPORT	PutNumUB
			EXPORT	PutStringSB
			EXPORT 	UART0_IRQHandler
			EXPORT 	Init_PIT_IRQ
			EXPORT	PIT_IRQHandler
			EXPORT	GPIO_BopIt_Init
;>>>>> begin subroutine code <<<<<

;------------------------------------------------------------------------------  
;Init_UART0_IRQ
;FUNCTION: initializes UART0 through port A pins 1 and 2 with 8 bits data, no 
;parity, one stop bit at 9600 baud, and enables hardware interrupts
;INPUTS: none
;OUTPUT: none
;CHANGED: none
;SUBROUTINES USED: InitQueue
;------------------------------------------------------------------------------
Init_UART0_IRQ	PROC	{R0-R14}
			PUSH	{R0-R2,LR}
			
			;initialize Rx and Tx queues
			LDR		R0,=RxQBuffer		;init Rx queue
			LDR		R1,=RxQRef
			MOVS	R2,#TXRX_BUF_SIZE
			BL		InitQueue
			LDR		R0,=TxQBuffer		;init Tx queue
			LDR		R1,=TxQRef
			BL		InitQueue
			
			LDR   R0,=SIM_SOPT2     
			LDR   R1,=SIM_SOPT2_UART0SRC_MASK     
			LDR   R2,[R0,#0]     
			BICS  R2,R2,R1    
			LDR   R1,=SIM_SOPT2_UART0_MCGPLLCLK_DIV2    
			ORRS  R2,R2,R1    
			STR   R2,[R0,#0] 
			
			;Enable external connection for UART0     
			LDR   R0,=SIM_SOPT5     
			LDR   R1,=SIM_SOPT5_UART0_EXTERN_MASK_CLEAR     
			LDR   R2,[R0,#0]     
			BICS  R2,R2,R1    
			STR   R2,[R0,#0] 
			
			;Enable clock for UART0 module     
			LDR   R0,=SIM_SCGC4     
			LDR   R1,=SIM_SCGC4_UART0_MASK     
			LDR   R2,[R0,#0]     
			ORRS  R2,R2,R1    
			STR   R2,[R0,#0] 
			
			;Enable clock for Port A module     
			LDR   R0,=SIM_SCGC5     
			LDR   R1,=SIM_SCGC5_PORTA_MASK     
			LDR   R2,[R0,#0]     
			ORRS  R2,R2,R1    
			STR   R2,[R0,#0] 
			
			;Connect PORT A Pin 1 (PTA1) to UART0 Rx (J1 Pin 02)     
			LDR     R0,=PORTA_PCR1     
			LDR     R1,=PORT_PCR_SET_PTA1_UART0_RX     
			STR     R1,[R0,#0] 
			
			;Connect PORT A Pin 2 (PTA2) to UART0 Tx (J1 Pin 04)     
			LDR     R0,=PORTA_PCR2     
			LDR     R1,=PORT_PCR_SET_PTA2_UART0_TX     
			STR     R1,[R0,#0]
			
			;Disable UART0 receiver and transmitter     
			LDR   R0,=UART0_BASE     
			MOVS  R1,#UART0_C2_T_R     
			LDRB  R2,[R0,#UART0_C2_OFFSET]     
			BICS  R2,R2,R1    
			STRB  R2,[R0,#UART0_C2_OFFSET] 
			
			;initialize NVIC
			LDR		R0,=UART0_IPR
			LDR		R2,=NVIC_IPR_UART0_PRI_3
			LDR		R3,[R0,#0]
			ORRS	R3,R3,R2
			STR		R3,[R0,#0]
			
			;clear any pending uart interrupts
			LDR		R0,=NVIC_ICPR
			LDR		R1,=NVIC_ICPR_UART0_MASK
			STR		R1,[R0,#0]
			
			;unmask uart interrupts
			LDR		R0,=NVIC_ISER
			LDR		R1,=NVIC_ISER_UART0_MASK
			STR		R1,[R0,#0]
			
			;Set UART0 for 9600 baud, 8N1 protocol 
			LDR   R0,=UART0_BASE 			
			MOVS  R1,#UART0_BDH_9600     
			STRB  R1,[R0,#UART0_BDH_OFFSET]     
			MOVS  R1,#UART0_BDL_9600     
			STRB  R1,[R0,#UART0_BDL_OFFSET]     
			MOVS  R1,#UART0_C1_8N1     
			STRB  R1,[R0,#UART0_C1_OFFSET]     
			MOVS  R1,#UART0_C3_NO_TXINV     
			STRB  R1,[R0,#UART0_C3_OFFSET]     
			MOVS  R1,#UART0_C4_NO_MATCH_OSR_16     
			STRB  R1,[R0,#UART0_C4_OFFSET]     
			MOVS  R1,#UART0_C5_NO_DMA_SSR_SYNC    
			STRB  R1,[R0,#UART0_C5_OFFSET]     
			MOVS  R1,#UART0_S1_CLEAR_FLAGS     
			STRB  R1,[R0,#UART0_S1_OFFSET]     
			MOVS  R1,#UART0_S2_NO_RXINV_BR210_NO_LBKDETECT_CLEAR_FLAGS     
			STRB  R1,[R0,#UART0_S2_OFFSET] 
			
			;Enable UART0 receiver and transmitter     
			MOVS  R1,#UART0_C2_T_RI     
			STRB  R1,[R0,#UART0_C2_OFFSET] 
			
			POP		{R0-R2,PC}
			BX		LR
			ENDP				
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------  
;GetChar
;FUNCTION: Reads a single character from the terminal to R0
;INPUTS: none
;OUTPUTS: R0 - character
;CHANGED: R0
;SUBROUTINES USED: Dequeue
;------------------------------------------------------------------------------

			;Poll RDRF until UART0 ready to receive  
GetChar		PROC 	{R1-R14}
			PUSH 	{R1,LR}
			
			LDR		R1,=RxQRef		;try to enqueue character
			
getLoop		CPSID	I				;mask interrupts
			BL		Dequeue
			CPSIE	I				;unmask interrupts
			BCS		getLoop			;loop if unsuccesful
			
			POP 	{R1,PC}
			BX 		LR
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;GetStringSB
;FUNCTION: reads a string from the terminal keyboard, displays it to the 
;		   terminal screen, and stores the string in memory at an address
;		   specified in R0.
;INPUTS: R0 - address to store string at; R1 - buffer capacity
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
;R0: current character
;R1: buffer capacity
;R2: string base address
;R3: counter/offset

GetStringSB	PROC 	{R0-R14}
			PUSH 	{R0-R3,LR}
			SUBS 	R1,R1,#1		;Subtract 1 from buffer capacity to account
									;for null termination
			MOVS 	R2,R0			;Move address to R2
			MOVS 	R3,#0			;Initialize counter to 0
			
GSLoop		BL 		GetChar			;Get character from keyboard
			CMP 	R0,#0x0D		;if(char == CR)
			BEQ 	return
			CMP 	R0,#0x1F		;if(char == special char)
			BLO 	GSLoop
			CMP 	R0,#0x7F
			BEQ 	GSLoop
			CMP 	R3,R1			;if(counter >= buffer capacity)
			BHS 	GSLoop
			BL 		PutChar			;Print character to terminal screen
			STRB 	R0,[R2,R3]		;Store character in memory at appropriate offset
			ADDS 	R3,R3,#1		;Increment counter
			B 		GSLoop
			
return		MOVS 	R0,#0			;Move 0 (null) into R0
			STRB 	R0,[R2,R3]		;Store null at end of string
			MOVS 	R0,#0x0D		;Move CR into R0
			BL 		PutChar			;Print to terminal screen
			MOVS 	R0,#0x0A		;Move LF into R0
			BL 		PutChar			;Print to terminal screen
			
			POP 	{R0-R3,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;UART0_ISR
;FUNCTION: handles uart input and output triggered by hardware interrupts
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: Enqueue, Dequeue
;------------------------------------------------------------------------------
UART0_IRQHandler
UART0_ISR	PROC	{R0-R14}
			CPSID	I
			PUSH	{LR}
			
			LDR		R0,=UART0_BASE		
			LDRB	R1,[R0,#UART0_C2_OFFSET]
			MOVS	R2,#UART0_C2_TIE_MASK
			TST		R1,R2			;check if TxInterruptEnabled
			BEQ		Rx
			LDRB	R1,[R0,#UART0_S1_OFFSET]
			MOVS	R2,#UART0_S1_TDRE_MASK
			TST		R1,R2			;check if TDRE is set
			BEQ		Rx
			LDR		R1,=TxQRef
			BL		Dequeue			;dequeue from transmit queue
			BCC		dqSucc			;branch if queue was successful
			LDR		R0,=UART0_BASE
			MOVS	R1,#UART0_C2_T_RI	;diasble TxInterrupt
			STRB	R1,[R0,#UART0_C2_OFFSET]
			B		Rx
			
dqSucc		LDR		R1,=UART0_BASE	;write to uart data register
			STRB	R0,[R1,#UART0_D_OFFSET]			
			
Rx			LDR		R0,=UART0_BASE	;check if RDRF is set
			LDRB	R1,[R0,#UART0_S1_OFFSET]
			MOVS	R2,#UART0_S1_RDRF_MASK
			TST		R1,R2
			BEQ		rxTxDone
			LDRB	R0,[R0,#UART0_D_OFFSET]	;read char from data register
			LDR		R1,=RxQRef
			BL		Enqueue			;enqueue character to receive queue
			
rxTxDone	POP		{PC}
			CPSIE	I			;unmask interrupts
			ENDP
;-----------------------------end ISR------------------------------------------

;------------------------------------------------------------------------------  
;InitQueue
;FUNCTION: initializes the queue
;INPUTS: R0 - address of beginning of queue buffer; R1 - address of beginning 
;of queue record; R2 - size of queue buffer
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
InitQueue	PROC 	{R0-R14}
			PUSH 	{R0}
			
			STR		R0,[R1,#IN_PTR]		;define the head of the queue
			STR		R0,[R1,#OUT_PTR]	;define the tail of the queue
			STR		R0,[R1,#BUF_STRT]	;define the start of the buffer
			ADDS	R0,R0,R2			;R0 = buffer start + buffer size
			STR		R0,[R1,#BUF_PAST]	;define the first byte past the buffer
			STRB 	R2,[R1,#BUF_SIZE]	;set the buffer size
			MOVS	R0,#0				;R0 = 0
			STRB	R0,[R1,#NUM_ENQD]	;initialize the number enqueued to 0
			
			POP 	{R0}
			BX 		LR
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;Dequeue
;FUNCTION: dequeues and returns the next element stored in the queue. C flag 
;if cannot dequeue
;INPUTS: R1 - address of beginning of queue record
;OUTPUTS: R0 - dequeued element; PSR C flag, success (0) or failure (1)
;CHANGED: R0, APSR
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
Dequeue		PROC 	{R1-R14}
			PUSH 	{R2-R3}
			
			LDRB	R2,[R1,#NUM_ENQD]	;load R2 with number enqueued
			CMP		R2, #0				;check if current number enqueued is 0
			BEQ		emptyDQ
			LDR		R0,[R1,#OUT_PTR]	
			LDRB	R0,[R0,#0]			;get next element to be dequeued
			SUBS	R2,R2,#1			;decrement number enqueued
			STRB	R2,[R1,#NUM_ENQD]	;store new number enqueued
			LDR		R2,[R1,#OUT_PTR]	;load R2 with out pointer
			ADDS	R2,R2,#1			;increment out pointer by one byte
			LDR		R3,[R1,#BUF_PAST]	;load R3 with past buffer pointer
			CMP 	R2,R3				;check if out pointer is past buffer
			BLO		clearCDQ
			LDR		R2,[R1,#BUF_STRT]	;load new out pointer as start of buffer
			
clearCDQ	STR		R2,[R1,#OUT_PTR]	;store new out pointer
			MOVS	R2,#0x20			;load R2 with mask to clear C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			BICS	R3,R3,R2			;clear using mask
			MSR		APSR,R3				;store R3 in APSR
			B		endDQ
			
emptyDQ		MOVS	R2,#0x20			;load R2 with mask to set C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			ORRS	R3,R3,R2			;set using mask
			MSR		APSR,R3				;store R3 in APSR
			
endDQ		POP 	{R2-R3}
			BX		LR
			ENDP
;-----------------------------end subroutine-----------------------------------
;------------------------------------------------------------------------------  
;Enqueue
;FUNCTION: prompts the user for a character and enqueues it. C flag set if 
;cannot enqueue
;INPUTS: R0 - element to enqueue; R1 - address of beginning of queue record
;OUTPUTS: PSR C flag, success (0) or failure (1)
;CHANGED: APSR
;------------------------------------------------------------------------------
Enqueue		PROC 	{R0-R14}
			PUSH	{R2-R3,LR}
	
			LDRB	R2,[R1,#NUM_ENQD]	;load R2 with number enqueued
			LDRB	R3,[R1,#BUF_SIZE]	;load R3 with buffer size
			CMP 	R2,R3				;check if R2 is greater than R3
			BHS		fullNQ
			
			LDR		R3,[R1,#IN_PTR]		
			STRB	R0,[R3,#0]			;enqueue element at in pointer
			ADDS	R2,R2,#1			;increment number enqueued
			STRB	R2,[R1,#NUM_ENQD]	;store new number enqueued
			LDR		R0,[R1,#IN_PTR]		;load R0 with in pointer
			ADDS	R0,R0,#1			;increment in pointer
			LDR		R2,[R1,#BUF_PAST]	;load R2 with first byte past buffer
			CMP		R0,R2				;check if R0 is less than past buffer
			BLO		clearCNQ
			LDR		R0,[R1,#BUF_STRT]	;load R0 with buffer start pointer
			
clearCNQ	STR		R0,[R1,#IN_PTR]		;store new in pointer
			MOVS	R2,#0x20			;load R2 with mask to clear C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			BICS	R3,R3,R2			;clear using mask
			MSR		APSR,R3				;store R3 in APSR
			B		endNQ
			
fullNQ		MOVS	R2,#0x20			;load R2 with mask to set C flag
			LSLS	R2,R2,#24			;shift mask 24 bits left
			MRS		R3,APSR				;load APSR into R3
			ORRS	R3,R3,R2			;set using mask
			MSR		APSR,R3				;store R3 in APSR
	
endNQ		POP		{R2-R3,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;PutChar
;FUNCTION: displays a single character to the terminal from R0
;INPUTS: R0 - character
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: Enqueue
;------------------------------------------------------------------------------
				
PutChar		PROC 	{R0-R14}
			PUSH 	{R0-R2,LR}
			
			LDR		R1,=TxQRef		;try to enqueue character
putLoop		CPSID	I				;mask interrupts
			BL		Enqueue
			CPSIE	I				;unmask interrupts
			BCS		putLoop			;loop if unsuccesful
			LDR		R0,=UART0_BASE	;enable TxInterrupt
			MOVS	R1,#UART0_C2_TI_RI
			STRB	R1,[R0,#UART_C2_OFFSET]
			
			POP 	{R0-R2,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;PutNumHex
;FUNCTION: prints the hex representation of the unsigned word value in R0
;INPUTS: R0 - unsigned word value
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
PutNumHex	PROC 	{R0-R14}
			PUSH 	{R1-R2,LR}
	
			MOVS 	R1,#8			;initialize downcounter to 8
			LDR		R2,=0xF0000000	;initialize mask
			
hexLoop		CMP		R1,#0			;check if downcounter is 0
			BEQ		putHEnd
			PUSH	{R0}
			ANDS	R0,R0,R2		;AND hex value with mask to get LSB
			LSRS	R0,#28			;shift value to LSB
			CMP		R0,#10			;check if number is numeric or alphabetic
			BHS		hexLetter
			ADDS	R0,#48			;add 48 to convert to appropriate number
			B 		printHex
			
hexLetter	ADDS	R0,#55			;add 55 to convert to appropriate letter

printHex	BL 		PutChar			;print hex character
			SUBS	R1,R1,#1		;decrement downcounter
			POP		{R0}
			LSLS	R0,#NIB_SHFT	;shift to next nibble
			B 		hexLoop
			
putHEnd		POP		{R1-R2,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;PutNumUB
;FUNCTION: prints the decimal representation of the unsigned byte value in R0
;INPUTS: R0 - unsinged byte value
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
PutNumUB	PROC	{R0-R14}
			PUSH	{R0-R1,LR}
	
			MOVS	R1,#0x0F		;load R1 with mask
			ANDS	R0,R0,R1		;AND R0 with mask to get LSB
			BL		PutNumU			;print the decimal value in R0
			
			POP		{R0-R1,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;PutNumU
;FUNCTION: displays an unsigned decimal number to the terminal from R0
;INPUTS: R0 - value to print
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
;R0: value to print
;R1: radix
;R2: temporary storage
;R3: counter/offset

PutNumU		PROC	{R0-R14}
			PUSH	{R0-R3,LR}		;Push registers 0-2
			MOVS 	R3,#0
			
divLoop		MOVS 	R1,R0			;Move quotient into R1
			MOVS 	R0,#10			;Move radix (10) into R1
			BL 		divu			;Call divu
			
			PUSH 	{R1}
			
			ADDS 	R3,R3,#1
			CMP 	R0,#0			;if(quotient == 0)
			BNE 	divLoop			;Branch back
			
printVal	CMP 	R3,#0
			BEQ 	endPutNum
			POP 	{R0}
			ADDS 	R0,R0,#0x30		;Add 30 to remainder to match ascii value 
									;for that number
			BL 		PutChar
			SUBS 	R3,R3,#1
			B 		printVal
			
endPutNum	POP 	{R0-R3,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;---------------------------------------------------------------
;divu
;FUNCTION: Divides two numbers and returns the quotient and remainder
;INPUTS: R0 - divisor; R1 - dividend
;OUTPUTS: R0 - quotient; R1 - remainder
;MODIFIED: R0, R1
;---------------------------------------------------------------
divu 		PROC 	{R0-R14}			
			PUSH 	{R2-R4}
			MOVS 	R2,#0				;Reset R2 to 0
			MRS 	R3,APSR				;set C flag {
			MOVS 	R4,#0x20
			LSLS 	R4,R1,#24
			ORRS 	R3,R3,R4
			MSR 	APSR,R3				;}
			CMP 	R0,#0				;if(divisor == 0)
			BEQ 	div_by_0
			
while		CMP 	R1,R0				;while(dividend >= divisor) {
			BLO 	good_div
			SUBS 	R1,R1,R0			;dividend -= divisor
			ADDS 	R2,#1				;quotient ++
			B 		while
					
good_div	MOVS 	R0,R2
			BICS 	R3,R3,R4			;Clears C flag
			MSR 	APSR,R3				;}

div_by_0	POP		{R2-R4}
			BX 		LR
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;PutStringSB
;FUNCTION: displays a string stored in memory to the terminal screen
;INPUTS: R0 - string address to read from; R1 - buffer capacity
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
;R0: current character
;R1: buffer capacity
;R2: string base address
;R3: counter/offset

PutStringSB	PROC 	{R0-R14}
			PUSH 	{R0-R3,LR}
			MOVS 	R2,R0			;Moves address into R2
			MOVS 	R3,#0			;Initializes counter to 0
			
PSLoop		CMP 	R3,R1			;if(counter >= buffer capacity)
			BHS 	PSEnd
			
			LDRB 	R0,[R2,R3]		;Get character at string R2, offset R3
			CMP 	R0,#0
			BEQ 	PSEnd
				
			BL 		PutChar			;Display character to terminal screen
			ADDS 	R3,R3,#1		;Inrement counter by 1
			B 		PSLoop
			
PSEnd		POP 	{R0-R3,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------  
;Init_PIT_IRQ
;FUNCTION: initializes the NVIC for PIT use
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;------------------------------------------------------------------------------
Init_PIT_IRQ	PROC	{R0-R14}
			PUSH	{R0-R2,LR}
			
			LDR		R0,=SIM_SCGC6	;set SIM_SCGC6 for PIT clock enabled
			LDR		R1,=SIM_SCGC6_PIT_MASK
			LDR		R2,[R0,#0]
			ORRS	R2,R2,R1
			STR		R2,[R0,#0]
			
			LDR		R0,=PIT_CH0_BASE	;disable PIT0 timer
			LDR		R1,=PIT_TCTRL_TEN_MASK
			LDRB	R2,[R0,#PIT_TCTRL_OFFSET]
			BICS	R1,R1,R2
			STR		R1,[R0,#PIT_TCTRL_OFFSET]
			
			LDR		R0,=PIT_IPR		;set PIT interrupt priority
			LDR		R1,=NVIC_IPR_PIT_MASK
			LDR		R2,[R0,#0]
			BICS	R2,R2,R1
			STR		R2,[R0,#0]
			
			LDR		R0,=NVIC_ICPR	;clear any pending PIT interrupts
			LDR		R1,=NVIC_ICPR_PIT_MASK
			STR		R1,[R0,#0]

			LDR		R0,=NVIC_ISER	;unmask PIT interrutps
			LDR		R1,=NVIC_ISER_PIT_MASK
			STR		R1,[R0,#0]
			
			LDR		R0,=PIT_BASE	;enable PIT interrupts
			LDR		R1,=PIT_MCR_EN_FRZ
			STRB	R1,[R0,#PIT_MCR_OFFSET]
			
			LDR		R0,=PIT_CH0_BASE	;set interrupt period
			LDR		R1,=PIT_LDVAL_10ms
			STR		R1,[R0,#PIT_LDVAL_OFFSET]
			
			LDR		R0,=PIT_CH0_BASE	;enable timer channel 0 for interrupts
			MOVS	R1,#PIT_TCTRL_CH_IE
			STRB	R1,[R0,#PIT_TCTRL_OFFSET]
			
			POP		{R0-R2,PC}
			ENDP
;-----------------------------end subroutine-----------------------------------

;------------------------------------------------------------------------------
;PIT_ISR
;FUNCTION: handles pit triggers by incrementing a counter
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
PIT_IRQHandler
PIT_ISR		PROC 	{R0-R14}
			CPSID	I
			PUSH	{LR}
			
			LDR		R0,=RunStopWatch	;get RunStopWatch variable
			LDRB	R0,[R0,#0]
			CMP		R0,#0			;exit if equals 0
			BEQ		pit_isr_end
			LDR		R0,=Count		;get count variable
			LDR		R1,[R0,#0]
			ADDS	R1,R1,#1		;increment count
			STR		R1,[R0,#0]		;store new count
			
pit_isr_end	LDR		R0,=PIT_CH0_BASE	;get pit flag register
			MOVS	R1,#PIT_TFLG_TIF_MASK	;get pit flag mask
			STRB	R1,[R0,#PIT_TFLG_OFFSET]	;store new tflg register
			
			POP		{PC}
			CPSIE	I
			ENDP
;-----------------------------end ISR------------------------------------------

;------------------------------------------------------------------------------
;GPIO_BopIt_Init
;FUNCTION: initializes gpio pins for led output and buttons input
;INPUTS: none
;OUTPUTS: none
;CHANGED: none
;SUBROUTINES USED: none
;------------------------------------------------------------------------------
GPIO_BopIt_Init	PROC 	{R0-R14}
			PUSH	{R0-R2}
			
			LDR		R0,=PORTA_BASE		;initialize GPIOA pins for buttons
			LDR		R1,[R0,#0]
			MOVS	R2,#GPIOA_BUTT
			BICS	R1,R1,R2
			STR		R1,[R0,#GPIO_PDDR_OFFSET]
			
			LDR		R0,=PORTC_BASE		;initialize GPIOC pins for LEDs
			LDR		R1,[R0,#0]
			MOVS	R2,#GPIOA_LED
			ORRS	R1,R1,R2
			STR		R1,[R0,#GPIO_PDDR_OFFSET]
			
			POP		{R0-R2}
			ENDP
;-----------------------------end subroutine-----------------------------------

;>>>>>   end subroutine code <<<<<
            ALIGN
;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
;>>>>>   end constants here <<<<<
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
			EXPORT	Count
			EXPORT 	RunStopWatch
;>>>>> begin variables here <<<<<
Count		SPACE	4
RunStopWatch	SPACE	1
			ALIGN
RxQRef		SPACE 	18
			ALIGN
TxQRef		SPACE	18
			ALIGN
RxQBuffer	SPACE	TXRX_BUF_SIZE
			ALIGN
TxQBuffer	SPACE	TXRX_BUF_SIZE
;>>>>>   end variables here <<<<<
            END
