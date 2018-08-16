

	;--------------------------------------------
	; Date: 26/08/2017
	;  Chen Parnasa ID:316558196
	;  Racheli Verechzon ID:305710071
	;--------------------------------------------	 
	
	;--------------------------------------------
	;    LCD display:
	;This program displays a clock on the LCD screen in the following format:
	;First row HH: MM: SS
	;  00:00:00 Second row) Running time
	;We will use the following functions:
	; An inc function that promotes the time registers in the second, minute and hour.
	; DISPLAY function that updates the current time in the LCD display
	; Timer_1 function that prepares Timer1 to hold 100ms.   
	;--------------------------------------------



	 LIST  P=PIC16F877 
	 include  <P16f877.inc> 
	 include  <BCD.inc> 
	  __CONFIG _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _RC_OSC & _WRT_ENABLE_ON & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 
	 
	org  0x00
	
reset:
	 	nop
	  	goto start
	  	org  0x04 ;Interrupt always starts at 0X04(PC) <------
	 	goto psika
	
	org  0x10

	;--------------------------------------------
	;                 Initialize area:
	;--------------------------------------------
	start:	CALL BANK0   ;Bank0 <------
		 	;Ports connected to lcd;
				CLRF PORTD ;RD0, RD1, RD2,RD3, RD4, RD5, RD6, RD7 <------
			 	CLRF PORTE ;RE0,RE1 <------
			 	MOVLW 0x01
			 	MOVWF T1CON;TIMER1 CONTROL REGISTER(bit 0 TMR1ON: Timer1 On bit1 = Enables Timer1) 
			
			 CALL BANK1   ;Bank1  <------
			 
				CLRF TRISD ;portD output
				CLRF TRISE ;portE output
				CLRF ADCON1
				MOVLW 0X06 ;Analog to digital transmission
				MOVWF ADCON1
				CLRF INTCON   ; disable all interrupts.
				CLRF PIE1   ; disable all peripheral interrupts.
				CLRF PIE2   ;  - it is recommended to block all interrupts before enabling certain interrupts, to ensure that unwanted interrupts are not enabled too.
				BSF  PIE1, TMR1IE ;PIE1 REGISTER: bit TMR1IE: TMR1 Overflow Interrupt Enable bit.
				
			 CALL BANK0   ;Bank0 <------
			  
			 
				 CLRF 0X30; Seconds counter
				 CLRF 0X31; minutes counter 
				 CLRF 0X32; hours  counter
				 
			     CLRW
	 			
				 MOVLW 0X09	;FOR ONE SEC IN PSIKA<------
			     MOVWF 0X71			
				 MOVLW 0X31 ;'0011 0001h' (bit 0 TMR1ON: Timer1 On bit1 = Enables Timer1)
							;bit 5-4 T1CKPS1:T1CKPS0: Timer1 Input Clock Prescale Select bits = 1:8 Prescale value
				 MOVWF T1CON; TIMER1 CONTROL REGISTER (ADDRESS 10h) 1<------
				
				 CALL INIT; initialize the LCD screen
				
				  BSF  INTCON, PEIE ; enable peripheral interrupts.
				  BSF  INTCON, GIE  ; enable Global interrupts. 
			
			 

	
	;--------------------------------------------
	;                 Main program area:
	;--------------------------------------------
	MAIN:
		CALL show_colons
		CALL DISPLAY
		GOTO MAIN 
	
	INC: ;An inc function that promotes the time registers in the second, minute and hour
   	 	 INCF 0X30
		 MOVFW 0x30
		 SUBLW 0x3C
		 BTFSS  STATUS,Z
		 RETURN
		 CLRF 0X30
		 
		 INCF 0X31
		 MOVFW 0x31
		 SUBLW 0x3c
		 BTFSS  STATUS,Z
		 RETURN
		 CLRF 0X31
		
		 INCF 0X32
		 MOVFW 0X32
		 
		 MOVLW 0X24
		 SUBlW 0x24
		 BTFSS  STATUS,Z
		 RETURN
		 CLRF 0X32
		 RETURN 
		
	DISPLAY:
	
	;--------------------------------------------
	;                 SEC SHOW
	;--------------------------------------------
	
		MOVFW 0X30
		MOVWF 0X60 
		CALL bin_to_bcd ;A routine for converting a binary number to a BCD
						;The function accepts a number in the register: 0x60
						;And returns a BCD value in the registers: 0x63: 0x62: 0x61 
						;Unity: Dozens: Hundreds
		
		MOVLW 0x8F ;set cursor to top right
		CALL SEND_C
		
		
		MOVFW 0X61
		ADDLW 0X30
		
		CALL SEND_D
		
		
		MOVLW 0x8E ;set cursor to top right
		CALL SEND_C
		
		MOVFW 0X62
		ADDLW 0X30
		CALL SEND_D
	
	;--------------------------------------------
	;                 MIN SHOW
	;--------------------------------------------
	
		MOVFW 0X31
		MOVWF 0X60 
		CALL bin_to_bcd
		
		MOVLW 0x8C ;set cursor to top right
		CALL SEND_C
		
		
		MOVFW 0X61
		ADDLW 0X30
		
		CALL SEND_D
		
		
		MOVLW 0x8B ;set cursor to top right
		CALL SEND_C
		
		MOVFW 0X62
		ADDLW 0X30
		CALL SEND_D
	
	;--------------------------------------------
	;                 HOUR SHOW
	;--------------------------------------------
	 
	
		MOVFW 0X32
		MOVWF 0X60 
		CALL bin_to_bcd
		
		MOVLW 0x89 ;set cursor to top right
		CALL SEND_C
		
		
		MOVFW 0X61
		ADDLW 0X30
		
		CALL SEND_D
		
		
		MOVLW 0x88 ;set cursor to top right
		CALL SEND_C
		
		MOVFW 0X62
		ADDLW 0X30
		CALL SEND_D
		
		RETURN

	;--------------------------------------------
	;                  FUNCTIONS
	;--------------------------------------------
	 
	show_colons:
		 MOVLW 0x8D
		 CALL SEND_C
		 MOVLW 0x3A
		 CALL SEND_D
		 MOVLW 0x8A 
		 CALL SEND_C
		 MOVLW 0x3A
		 CALL SEND_D 
		
		 MOVLW 0x80
		 CALL SEND_C
		 MOVLW 0x20
		 CALL SEND_D 
		
	     RETURN
	
	 INIT:
		  MOVLW 0X30
		  CALL SEND_C
		  CALL delay_ONE_HALFu
		  CALL delay_ONE_HALFu
		  CALL delay_ONE_HALFu
		  MOVLW 0X30
		  CALL SEND_C
		  MOVLW 0X30
		  CALL SEND_C
		  MOVLW 0X38
		  CALL SEND_C
		  MOVLW 0X0C
		  CALL SEND_C
		  MOVLW 0X06
		  CALL SEND_C
		  MOVLW 0X01
		  CALL SEND_C
		  RETURN
	
	SEND_C: ;Place the cursor on the LCD display
	
		  MOVWF PORTD
		  BCF PORTE,1
		  BSF PORTE,0
		  NOP 
		  BCF PORTE,0
		  CALL delay_ONE_HALFu
		  RETURN
		
	 SEND_D: ;Display the LCD text
	 
		   MOVWF PORTD
		   BSF PORTE,1
		   BSF PORTE,0
		   NOP 
		   BCF PORTE,0
		   CALL delay_ONE_HALFu
	       RETURN 
	 

	;--------------------------------------------
	;        Interrupt program (if required):
	;--------------------------------------------
	psika: 
	  movwf 0x7A   ;store W_reg at 0x7A
	  swapf STATUS, w
	  movwf 0x7B   ;store STATUS at 0x7B
	
	  bcf  STATUS, RP1
	  bcf  STATUS, RP0  ;Bank 0
	
	  btfsc PIR1, TMR1IF ;for the Timer 1 interrupt (if in use)
	  goto Timer_1
	
	ERR: goto ERR
	
	Timer_1:      ;for the Timer 1 interrupt (if in use)
	
	  	movlw 0x16
	  	movwf TMR1H
	  	movlw 0xE8
	  	movwf TMR1L
	 	BCF PIR1,TMR1IF
		movlw 0x01
		SUBWF 0X71,1
		BTFSS STATUS,Z
		GOTO syum_psika
		movlw 0x09
		movwf 0x71
	 	CALL INC
	
	syum_psika:
	  swapf 0x7B, w
	  movwf STATUS   ;res tore STATUS from 0x7B
	  swapf 0x7A, f
	  swapf 0x7A, w   ;restore W_reg from 0x7A
	
	  retfie
	
	
	
	;--------------------------------------------
	;                  DELAYS
	;--------------------------------------------
	
	delay_ONE_HALFu:     ;-----> 1ms delay
	  movlw  0x0B   ;N1 = 11d
	  movwf  0x51
	CONT1: movlw  0x96   ;N2 = 150d
	  movwf  0x52
	CONT2: decfsz  0x52, f
	  goto  CONT2
	  decfsz  0x51, f
	  goto  CONT1
	  return      ; D = (5+4N1+3N1N2)*200nsec = (5+4*11+3*11*150)*200ns = 999.8us=~1ms

	;--------------------------------------------
	;                 BANKS
	;--------------------------------------------

	BANK1:
	 BSF STATUS, RP0
	 BCF STATUS,RP1
	 RETURN 
	BANK0:
	 BCF STATUS, RP0
	 BCF STATUS,RP1
	 RETURN
	
	
	
	 
	 goto$
	
	 end
	
