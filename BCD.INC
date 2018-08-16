		org			0x500
;***********************************************************
; Binary to BCD - 8 bit                                    *
;	Input:  bin_mum           - Binary number              *
;	Output: bcd_2:bcd_1:bcd_0 - Decimal number             *
;	function name: --> bin_to_bcd                          *
;***********************************************************

bin_mum		EQU H'0060'
bcd_0		EQU	H'0061'
bcd_1		EQU	H'0062'
bcd_2		EQU	H'0063'
counter		EQU	H'006F'

;***********************************************************

bin_to_bcd:
		clrf		bcd_0
		clrf		bcd_1
		clrf		bcd_2
		movlw		0x08
		movwf		counter

		call		regs_left_rot
		decf		counter,f

bcd_lop:movlw		0x05
		subwf		bcd_0,w
		btfss		STATUS,C
		goto		les_5_1
		movlw		0x03
		addwf		bcd_0,f
les_5_1:movlw		0x05
		subwf		bcd_1,w
		btfss		STATUS,C
		goto		les_5_2
		movlw		0x03
		addwf		bcd_1,f
les_5_2:call		regs_left_rot
		decfsz		counter,f
		goto		bcd_lop

		return

regs_left_rot:
		rlf			bin_mum,f
		rlf			bcd_0,f
		btfss		bcd_0,4
		goto		no_C1
		bcf			bcd_0,4
		bsf			STATUS,C
no_C1:	rlf			bcd_1,f
		btfss		bcd_1,4
		goto		no_C2
		bcf			bcd_1,4
		bsf			STATUS,C
no_C2:	rlf			bcd_2,f
		return
