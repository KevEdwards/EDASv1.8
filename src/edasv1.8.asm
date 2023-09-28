
; 11.20 AM,  5/8/88 - Last update!

;******************************************************************************
;**                                                                          **
;**    EDITOR ASSEMBLER SOURCE CODE                                          **
;**                                                                          **
;**    REMS BY :- MIKE WEBB (YES EVERY ONE)                                  **
;**                                                                          **
;******************************************************************************



                     ORG $1C00,$9000
CURT                 EQU $78
DIR                  EQU $240
TEXT                 EQU $478


START
                     SEI
                     LDX #$FF:TXS
                     LDA #$:STA $23
                     LDA #$F:STA $D506
                     LDA #$7E
                     STA $FF00
                     LDA #IRQ:STA $FFFE
                     LDA #IR2:STA $314
                     LDA ^IRQ:STA $FFFF
                     LDA ^IR2:STA $315
                     LDA #RESTORE:STA $FFFA
                     LDA ^RESTORE:STA $FFFB
                     LDA #RESTORE2:STA $318
                     LDA ^RESTORE2:STA $319
                     LDA #2
                     STA $FF00
                     STA $D500
                     LDA #$04:STA $D506
                     LDA #IRQ:STA $FFFE
                     LDA ^IRQ:STA $FFFF
                     LDA #RESTORE:STA $FFFA
                     LDA ^RESTORE:STA $FFFB
                     LDA #$FF:STA $D012
                     LDA #$17:STA $D018
                     LDA #$1B
                     STA $D011
                     LDA #$7F:STA $DD0D
                     LDA $DC0D:LDA $DD0D
                     LDA #0:STA $DD03;    PORT=INPUT
                     LDA #$00:STA $DC0E
                     STA $DC0F:STA $D0
                     LDA #$2F:STA $00
                     LDA #$73:STA $01
                     LDA #$F1:STA $D01A
                     LDA #$97:STA $DD00
                     JSR SETKEYS
                     LDY #0
                     STY LINE:STY COLUMN
CLRCOL               LDA #0:STA BUF3,Y
                     INY:BNE CLRCOL
                     STA PRFLAG
                     STY COUNT
SET80COL             LDX XTAB,Y
                     CPX #$FF
                     BEQ FIN
                     LDA ATAB,Y
                     JSR PRTDT
                     INY
                     JMP SET80COL

SETKEYS              LDY #0
SETK1                LDA KEYTAB,Y
                     STA $1000,Y
                     INY:BNE SETK1
                     RTS



KEYTAB               DFB M2-M1,M3-M2,M4-M3,M5-M4
                     DFB M6-M5,M7-M6,M8-M7,M9-M8
                     DFB M10-M9,M11-M10

M1                   DFB 13
                     DFM "              HEX "
M2
M3
M4
M5
M6
M7
M8
M9
M10
M11

TIMoD                DFB $00,$00,$59,$11
FIN                  LDA $D030:ORA #$01
                     STA $D030;\
                     JSR CUROF
                     LDX #3
STIM                 LDA TIMoD,X
;         STA TOD,X
                     DEX:BPL STIM
                     LDA #$4E:STA $0332
                     LDA #$F5:STA $0333
                     LDA #$01:STA $88
                     STA SoRTOP
                     LDA #$04:STA $89
                     STA SoRTOP+1
                     JSR CHOLD2
                     JSR SCRCLR
                     LDA #$01:STA CURT
                     LDA #$04:STA CURT+1
                     LDY #RTN1-GPBYTE+1
TRSTACK              LDA CODE-1,Y
                     STA $0100-1,Y
                     DEY:BNE TRSTACK
                     JSR READY
                     CLI
MAINLOOP             LDA #2:STA $FF00;?
                     JSR $FFE4
                     BEQ MAIN2
                     STA KEYPRESS
                     STA KEYPRESS2
                     JSR READSCR
                     JSR CUROF
                     LDA KEYPRESS
                     JSR NONCMD
                     JSR SCRPRINT
MAIN2                LDX #$3E:STX $FF00
                     JSR STATUSP
                     JSR CURON
                     JSR CURPOS
                     JMP MAINLOOP

RESTORE              PHA:TXA:PHA:TYA:PHA
                     LDA $FF00:PHA
                     LDA #2:STA $FF00

RESTORE2             LDA $DC01:BPL DROPD
ASSR                 PLA:STA $FF00
                     PLA:TYA:PLA:TXA:PLA
                     RTI
DROPD                JMP START

CUROF                LDX #10
                     JSR READT
                     AND #$1F
                     ORA #$20
                     JMP PRTDT

CURON                LDX #10
                     JSR READT
                     AND #$1F
                     ORA CURTYPE
                     JMP PRTDT

NONCMD               LDY #CODE-NOKEY-1
NCMD                 CMP NOKEY,Y:BEQ CONTR
                     DEY:BPL NCMD
                     LDY #1:STY CHANGE
CONTR                RTS

NOKEY                DFB $11,$91,$1D,$9D,$0D,$04,$18,$09,$13,$BA,2,3

;THE FOLLOWING BIT IS COPIED TO $100

CODE
                     ORG $100,CODE+$9000-$1C00
GPBYTE               LDA #$7F
                     STA $FF00
GPLOP
FROM                 LDA $FFFF,Y
TO                   STA $FFFF,Y
                     DEY
                     CPY #$FF:BNE GPLOP
                     DEC TO+2
                     DEC FROM+2
                     DEX
                     CPX #$FF
                     BNE GPLOP
                     LDA #2:STA $FF00
                     RTS

PGBYTE               LDA #$7F:STA $FF00
PGLOP
                     LDA ($88),Y
PUT                  STA ($AE),Y
                     CMP #$FF:BEQ RTNS
                     INY:BNE PGLOP
                     INC $AF:INC $89
                     BNE PGLOP
RTNS                 LDA #2:STA $FF00
                     RTS

GETLINE              LDA #$7F:STA $FF00:LDY #0
LINLOP               LDA ($88),Y
                     STA SRCLIN,Y
                     CMP #$0A
                     BCC GOTAL
                     CMP #$FF:BEQ GOTAL2
                     INY:BNE LINLOP
GOTAL                TYA:SEC:ADC $88
                     STA $88
                     LDA $89:ADC #0
                     STA $89
GOTAL2               LDX #$3F:STX $FF00
                     LDA SRCLIN
                     CMP #$FF
                     RTS
IRQ                  SEI:PHA:TXA:PHA:TYA:PHA
                     LDA $FF00:PHA
                     LDA #2:STA $FF00
IR2                  LDA #$FF:STA $D019
                     INC $D020
                     JSR $C012
                     LDX #10:CPX $A24:BCS PAST1
                     STX $A24
PAST1                LDX #2:CPX $A23:BCS PAST
                     STX $A23
PAST                 DEC $D020
                     PLA:STA $FF00
                     PLA:TAY:PLA:TAX:PLA
RTN1                 RTI
                     ORG CODE+RTN1-GPBYTE+1,CODE+RTN1-GPBYTE+1+$9000-$1C00
XTAB                 DFB 10,11,06,19
                     DFB 18,15,14,01
                     DFB 26,33,32,34
                     DFB 35,21,20,28
                     DFB 32,33,36,24
                     DFB 08,25,12,13
                     DFB 255
ATAB                 DFB $40,$08,$19,$00
                     DFB $00,$00,$00,$50
                     DFB $40,$00,$00,$00
                     DFB $64,$00,$08,$20
                     DFB $00,$00,$0F,$20
                     DFB $00,$47,$00,$00
CONTROL1A            JMP CONTROL
SCRPRINT             PHA:LDX KEYPRESS
                     BEQ SCRPRIFF
SCRPRIN1             CMP #$1F
                     BCC CONTROL1A
                     CMP #$5F
                     BEQ CONTROL1A
                     CMP #$A4

                     BEQ CONTROL1A
                     SEC:SBC #$80
                     CMP #$20
                     BCC CONTROL1A
SCRPRIFF             LDA COLUMN:CMP #79:BCC SCPR2
                     PLA:RTS
SCPR3                PHA
SCPR2                LDA LINE:CMP #23:BCC SCRPRIN2
                     JMP SCRPRIN2
SPSTAT               PHA
SCRPRIN2             PLA:CMP #$80
                     BCS SHIFTED
                     CMP #$60:BCS SHIFTED2
                     CMP #$40:BCC NOSUB
                     SEC:SBC #$40
                     JMP NOSUB
SHIFTED2             SEC:SBC #$60:PHA
                     LDA #$80
                     STA LOWERCASE:PLA
NOSUB                LDX #31
                     JSR PRTDT
                     LDA KEYPRESS:BNE KEYCOL
                     BIT LOWERCASE:BPL NCOL
KEYCOL               JSR COLOUR
NCOL                 LDA RTNFLG:BEQ NoRTN
                     JSR RETURN
NoRTN                LDA #0:STA RTNFLG
                     JMP SKIP
SHIFTED              CMP #$A0:BNE SHIFT2
                     SEC:SBC #$80:JMP NOSUB
SHIFT2               SEC:SBC #$C0
                     CMP #$E0:BEQ NOSUB
                     LDX #31
                     JSR PRTDT
                     LDA #$80:STA LOWERCASE
                     JSR COLOUR
                     LDA RTNFLG:BEQ SKIP
                     JSR RETURN
SKIP                 LDA #0:STA RTNFLG
                     INC COLUMN:LDA COLUMN
                     CMP #$50:BCC EXITSCP
                     DEC COLUMN
EXITSCP              RTS
READSCR              JSR SETREAD
                     JSR READLINE
                     JSR SETCOLA
                     JSR READCOL
OKBG                 JMP RESTPTR
SETREAD              STY YTEMP
                     LDX #19:JSR READT
                     STA UPDATE
                     DEX:JSR READT
                     STA UPDATE+1
                     LDA LINE:ASL 
                     TAY:INY
                     LDX #18:LDA TABLE,Y
                     STA COLBUFH
                     JSR PRTDT
                     INX:DEY:LDA TABLE,Y
                     JSR PRTDT
                     STA COLBUFL
                     LDY #0:LDX #31
                     RTS
READLINE             JSR READT
                     STA BUFFER,Y
                     INY:CPY #$50
                     BCC READLINE
                     RTS
SETCOLA              LDA COLBUFH:CLC
                     ADC #$08
                     LDX #18:JSR PRTDT
                     INX:LDA COLBUFL
                     JSR PRTDT
                     LDY #0:LDX #31
                     RTS
READCOL              JSR READT
                     STA COLBUF,Y
                     INY:CPY #$50
                     BCC READCOL
                     RTS
RESTPTR              LDX #18:LDA UPDATE+1
                     JSR PRTDT
                     INX:LDA UPDATE
                     JSR PRTDT
                     LDY YTEMP
                     RTS
READSCR2             JSR SETREAD
                     JSR READLINE2
                     JSR SETCOLA
                     JSR READCOL2
                     JMP RESTPTR
READLINE2            JSR READT
                     STA TEMPBU,Y
                     INY:CPY #$50
                     BCC READLINE2
                     RTS
READCOL2             JSR READT
                     STA COLBUF2,Y
                     INY:CPY #$50
                     BCC READCOL2
                     RTS
COPYBUF              LDY #$4F
COPYB1               LDA BUFFER,Y
                     STA TEMPBU,Y
                     LDA COLBUF,Y
                     STA COLBUF2,Y
                     DEY:BPL COPYB1
CURL                 RTS

DEL                  JSR READSCR
                     LDA MRK1:CMP #24:LDA COLUMN:ADC #0:TAY
DELLOOP              LDA BUFFER,Y
                     STA BUFFER-1,Y
                     LDA COLBUF,Y
                     STA COLBUF-1,Y
                     INY:CPY #$01
                     BEQ RIGHTSCR
                     CPY #$50
                     BCC DELLOOP
                     LDA #$20:DEY
                     STA BUFFER,Y
                     JSR RIGHTSCR
                     LDX MRK1:CPX #24:BEQ CURL;   SUCK
                     JMP CURLEFT
RIGHTSCR             LDX #19:JSR READT
                     STA UPDATE
                     DEX:JSR READT
                     STA UPDATE+1
                     LDA LINE:ASL 
                     TAY:INY
                     LDX #18:LDA TABLE,Y
                     STA COLBUFH
                     JSR PRTDT
                     INX:DEY:LDA TABLE,Y
                     STA COLBUFL
                     JSR PRTDT
                     LDY #0:LDX #31
RIGHTLINE            LDA BUFFER,Y
                     JSR PRTDT
                     INY:CPY #$50
                     BCC RIGHTLINE
                     LDX #18:LDA COLBUFH
                     CLC:ADC #$08
                     JSR PRTDT
                     INX:LDA COLBUFL
                     JSR PRTDT
                     LDY #0:LDX #31
RIGHTLIN2            LDA COLBUF,Y
                     JSR PRTDT
                     INY:CPY #$50
                     BCC RIGHTLIN2
                     LDX #18:LDA UPDATE+1
                     JSR PRTDT
                     INX:LDA UPDATE
                     JSR PRTDT
                     RTS
INST                 JSR READSCR
                     LDY #$4E
                     LDA BUFFER,Y
                     CMP #$20:BNE EXITINST2
INSTLOOP             LDA BUFFER,Y
                     STA BUFFER+1,Y
                     LDA COLBUF,Y
                     STA COLBUF+1,Y
                     TYA:BEQ EXITINST
                     DEY:CPY COLUMN
                     BCS INSTLOOP
EXITINST             LDY COLUMN:LDA #$20
                     STA BUFFER,Y
                     JSR RIGHTSCR
EXITINST2            RTS
RESTLINE             LDA COLUMN:PHA:LDA #0:STA INTRN:STA XTEMP2A:STA TABFLAG
                     STA COLUMN
                     LDA LINE:JSR CLRLINE:LDA LINE:JSR SETCUR
                     LDA CURT:STA $88:LDA CURT+1:STA $89
                     JSR GETLINE:PHP:LDX #$3E:STX $FF00
                     PLP:BEQ NORSC
                     JSR PRTANY
NORSC                PLA:STA COLUMN:JSR SETCUR2:RTS

CONTROL              PLA:LDX #CTRLTAB-MCMD-1:STA MRK1
CMLOOP               LDA MRK1:CMP MCMD,X:BNE NFONCMD
                     LDA $D3:CMP CTRLTAB,X:BEQ FONCMD
NFONCMD              DEX:BPL CMLOOP
                     RTS
FONCMD               TXA:ASL :TAX
                     LDA CMDTAB+1,X:PHA
                     LDA CMDTAB,X:PHA:RTS
MCMD                 DFB 17,$91,$1D,$9D,13,$93,$13,$14,$94,$1B,$5F,$9,$18,12,10,1,16
                     DFB $A4,14,6,22,2,3,4,26,13,17,23,24,20,5,11,7,15
                     DFB 21,10,18,25,9
CTRLTAB              DFB 00,001,000,001,00,001,000,000,001,000,000,00,001,04,00,4,04
                     DFB 002,04,4,04,4,4,4,04,04,04,04,04,04,4,04,4,4
                     DFB 04,04,04,04,04

CMDTAB               DFW CURDOWN-1,CURUP-1
                     DFW CURRIGHT-1,CURLEFT-1
                     DFW RETURN-1,CONTSC-1
                     DFW CURHOME-1,DEL-1
                     DFW INST-1,RESTLINE-1
                     DFW TABU-1,CURDOWN2-1
                     DFW CURUP2-1,DELLINE-1
                     DFW MSTART-1,ASSEMBLER-1
                     DFW PRINTON-1,SAVRENA-1
                     DFW SCRCLR1-1,CFIND-1
                     DFW CVIEW-1,CBLOKM-1
                     DFW BCOPY-1,BDELETE-1
                     DFW BZREMB-1,CBMOVE-1
                     DFW STARTL-1,ENDLIN2-1
                     DFW DEL2-1,TOP-1
                     DFW BOTFIL-1,EXCASE-1
                     DFW GOENT-1,OLDLINE-1
                     DFW SPLIT-1,UNSPLIT-1
                     DFW NEXTLA-1,DIRCOM-1
                     DFW CLREOL-1

CLREOL               JSR PRESCUR:LDA #1:STA CHANGE
                     LDA COLUMN:PHA:TAY
LOOPCLR              LDA #$20
                     JSR SCRPRINT
                     INY:CPY #79
                     BCC LOOPCLR
                     PLA:STA COLUMN
                     JSR RESCUR
                     RTS

DIRCOM               JSR CHKINSERT
                     LDA LINE:JSR FINDTOP
                     LDA #2:STA $FF00
                     JSR SCRCLR
                     LDY #0:LDA #$20:STA BUFFER,Y
                     STA BUFFER+1,Y
                     JSR LOADDIR2
                     JSR GETKEY
                     SEI
                     JSR LIST2A
                     LDA #$00:STA $D0:CLI
                     RTS


NEXTLA               JSR CHKINSERT:LDA CURT:STA $88:LDA CURT+1:STA $89
                     JSR GETLINE:BEQ DONOT2
DONOT4               JSR GETLINE:BEQ DONOT2
                     LDY #0
                     LDA SRCLIN,Y
                     BMI DONOT4:INY
                     CMP #$0A:BCC DONOT4
                     LDA $88:STA CURT:LDA $89:STA CURT+1
                     JSR BACK1L
                     LDX #$3E:STX $FF00
                     JSR LIST2A
                     LDA #0:STA CHANGE
                     RTS

FDCOL                DFB 0
MONITR               DFB 0

SPLIT                JSR CHKINSERT
                     LDA CURT:STA $88
                     LDA CURT+1:STA $89
                     JSR GETLINE:BEQ DONOT2
                     LDY #$FF
                     LDA #0:STA FDCOL
SETLI                INY:LDA SRCLIN,Y
                     CMP #$0A:BCC DONOT5
                     CMP #&:
                     BNE SETLI
                     LDA SRCLIN+1,Y
                     CMP #&:
                     BNE OKREM2
                     BEQ SETLI
DONOT5               LDA FDCOL:BEQ DONOT2:JSR SETSCR
DONOT2               LDA #$3E:STA $FF00:LDA #0:STA CHANGE
                     RTS

OKREM2               JMP OKREM

UNSPLIT              JSR CHKINSERT
                     LDA CURT:STA $88:LDA CURT+1:STA $89
                     JSR GETLINE:BEQ DONOT2
                     TYA:CLC:ADC CURT:STA $AE
                     LDA CURT+1:ADC #0:STA $AF
                     LDA #&::JSR PTBT
                     JSR SETSCR
                     RTS

OKREM                TYA:PHA:CLC:ADC CURT:STA $AE
                     LDA CURT+1:ADC #0:STA $AF
                     LDA #0:JSR PTBT:LDA #1:STA FDCOL
                     PLA:TAY:JMP SETLI

SETSCR               LDA #0:STA CHANGE:LDA #$3E:STA $FF00
                     LDA CURT:PHA:LDA CURT+1:PHA
                     LDA LINE:PHA:JSR FINDTOP:LDA COLUMN:PHA
                     JSR LIST2A
                     PLA:STA COLUMN:PLA:STA LINE
                     PLA:STA CURT+1:PLA:STA CURT
                     JSR SETCUR2
                     RTS

OLDLINE              LDY #0
NOLIN                LDA OLDBUF,Y
                     STA SRCLIN,Y:INY
                     CMP #$0A:BCC LEAVE1
                     CMP #$FF:BNE NOLIN
LEAVE1               LDA #0:STA TABFLAG:JSR DECODE:LDA #$00
                     STA TEXT,X
                     LDA COLUMN:PHA
                     LDA #0:STA INTRN:STA XTEMP2A:STA COLUMN
                     LDA LINE:JSR CLRLINE
                     JSR SETCUR2
                     JSR PRTTEXT
                     PLA:STA COLUMN:JSR SETCUR2
                     RTS

DEL2                 LDA #1:STA CHANGE:JMP DEL

GOENT
                     LDA #0:STA KEYPRESS
                     RTS

EXCASE               JSR SETCUR2
                     LDX #31
                     JSR READT
                     AND #$3F
                     CMP #27
                     BCS NOVA
                     LDA LINE
                     ASL :TAY
                     LDA TABLE,Y
                     CLC:ADC COLUMN
                     STA WDATAW
                     LDA TABLE+1,Y
                     ADC #$08
                     STA WDATAW+1
                     JSR WWoRD
                     LDX #31:JSR READT
                     EOR #$80:STA MRK2
                     LDA TABLE,Y
                     CLC:ADC COLUMN
                     STA WDATAW
                     LDA TABLE+1,Y
                     ADC #$08
                     STA WDATAW+1
                     JSR WWoRD
                     LDX #31:LDA MRK2
                     JSR PRTDT
NOVA                 JSR SETCUR2
                     LDA #0:STA KEYPRESS
                     JMP CURRIGHT

TOP                  JSR CHKINSERT
                     LDA #1:STA CURT:LDA #0:STA CHANGE:STA KEYPRESS:LDA #4:STA CURT+1
                     JMP LIST2A

BOTFIL               JSR CHKINSERT
                     LDA #23:STA MRK1
                     LDA #0:STA KEYPRESS:STA CHANGE
                     LDA SoRTOP:STA CURT:LDA SoRTOP+1:STA CURT+1
BAK                  JSR BACK1L:DEC MRK1
                     BPL BAK
                     LDA CURT+1:CMP #4:BCC SETT
                     JMP LIST2A
SETT                 LDA #1:STA CURT:LDA #4:STA CURT+1:JMP LIST2A

STARTL               LDA #0:STA KEYPRESS:STA COLUMN
                     RTS
ENDLIN2              JSR READSCR
                     LDY #79
ELLP                 LDA BUFFER,Y:CMP #$20:BNE POSHERE
                     DEY:BPL ELLP
POSHERE              INY
                     STY COLUMN
                     RTS
BZREMB
                     LDA COLUMN:PHA
                     LDA CURT:PHA:LDA CURT+1:PHA:LDA LINE:PHA:JSR FINDTOP
BZRE                 LDA #0:STA $88:STA BLOKN:LDA #4
                     STA $89
RMLOP                JSR GETLINE:BEQ ENDSR2
                     LDA SRCLIN,Y:BEQ RMLOP
                     LDA $88:SEC:SBC #1:STA $AE
                     LDA $89:SBC #0:STA $AF
                     LDA #$00:JSR PTBT
                     JMP RMLOP
ENDSR2               LDA #0:STA KEYPRESS
                     LDX #$3E:STX $FF00
                     JSR LIST2A
                     PLA:STA LINE
                     PLA:STA CURT+1:PLA:STA CURT
                     PLA:STA COLUMN:JSR SETCUR2
                     RTS

CBLOKM               LDA CURT:STA $88:LDA CURT+1:STA $89
                     JSR GETLINE
                     LDA SRCLIN,Y
                     CMP #1:BNE NORM
                     DEC BLOKN:DEC BLOKN
NORM                 LDX BLOKN:CPX #2:BEQ TWON:INC BLOKN:PHA
                     JSR GETBYTE2
                     PLA
                     LDX $88:STX $AE:LDX $89:STX $AF
                     EOR #1:JSR PTBT
                     LDA #$3E:STA $FF00
                     LDA #0:STA KEYPRESS:STA CHANGE
                     JSR RESTLINE
TWON                 RTS

CVIEW                JSR CHKINSERT
                     LDY #79:LDA OLDCV:STA $88
                     LDA OLDCV+1:STA $89
PUTIB1               LDA VBUF,Y
                     STA BUF1,Y
                     DEY:BPL PUTIB1
                     JMP COMPLOOP

CFIND                JSR CHKINSERT
                     LDY OLDFSL:LDA OLDCF:STA $88
                     LDA OLDCF+1:STA $89:STY BUFLEN2
PUTIB                LDA FBUF,Y
                     STA BUF1,Y
                     DEY:BPL PUTIB
                     JMP FINSTLOP

FBUF                 DFS 80,00
VBUF                 DFS 80,0
OLDBUF               DFS 80,0
BLOKN                DFB 0

OLDCF                DFW 0
OLDCV                DFW 0

OLDFSL               DFB 0

SCRCLR1              LDA LINE:JSR CLRLINE:JMP SETCUR2
CURUP2               JSR CHKINSERT:LDA LINE:CLC:ADC #23:JSR FINDTOP
                     JMP LIST2A
CURDOWN2             JSR CHKINSERT
                     JSR FINDBOTL
                     BCC OKGOTL:RTS
OKGOTL               LDA $88:STA CURT
                     LDA $89:STA CURT+1
                     JSR BACK1L
                     JMP LIST2A
LAST                 DFB 0
CURDOWN              LDA COLUMN
                     PHA
                     LDA LINE:CMP #23:BEQ DOINS
                     LDA CHANGE:BEQ OINS
DOINS                JSR CHKINSERT
                     JSR CURDO2
                     JSR CURDO2:DEC LINE
NOSE1                JSR BACK1L
NOSE2                PLA:STA COLUMN
                     JMP SETCUR2
OINS                 LDA CURT:STA $88
                     LDA CURT+1:STA $89
                     JSR GETLINE:LDX #$3E:STX $FF00
                     LDA $88:STA CURT
                     LDA $89:STA CURT+1
                     JSR GTBT
                     CMP #$FF:BNE NOSE
                     LDA CUPO:SEC:SBC #$50
                     STA CUPO
                     LDA CUPO+1:SBC #0:STA CUPO+1
                     JMP NOSE1
NOSE                 INC LINE:JMP NOSE2
CURDO2
                     LDA CURT:STA $88
                     LDA CURT+1:STA $89
                     LDA #0:STA XTEMP2A
                     STA INTRN
                     JSR GETLINE:PHP:STA LAST
                     LDX #$3E:STX $FF00
                     PLP:BEQ NODOWN
PRTBOT               LDA LINE
                     CMP #24:BCS NODOWN2
                     CMP #23:BNE DONL
                     LDA SCRLFG:ORA CHTEMP:BEQ LEAVE
                     LDA #0:STA SCRLFG
DONL                 LDA LINE:JSR CLRLINE
                     LDA #0:STA TABFLAG:STA COLUMN
                     JSR SETCUR2
                     LDA LAST
                     JSR PRTANY
LEAVE                INC LINE
                     LDA $88:STA CURT
                     LDA $89:STA CURT+1
                     RTS
NODOWN               LDA CUPO:SEC:SBC #$50
                     STA CUPO
                     LDA CUPO+1:SBC #0
                     STA CUPO+1:RTS
NODOWN2              JSR SCROLL:DEC LINE
                     LDA #1:STA SCRLFG
                     LDA CUPO:SEC:SBC #$50
                     STA CUPO
                     LDA CUPO+1:SBC #0
                     STA CUPO+1
                     JMP PRTBOT
BACK1L               LDA CURT:SEC:SBC #2
                     STA $88:LDA CURT+1
                     SBC #0:STA $89
                     JSR BAKON
                     LDA $88:STA CURT
                     LDA $89:STA CURT+1
                     RTS
CURUP                LDA COLUMN
                     STA OPCH1
                     LDA LINE:BEQ DOINS2
                     LDA CHANGE:BNE DOINS2
                     JSR LASTSRL:DEC LINE
                     LDA OPCH1:STA COLUMN
                     JMP SETCUR2
DOINS2               JSR CHKINSERT
                     JSR LASTSRL
                     BNE NOTLAST
                     RTS
LASTSRL              LDA CURT+1:STA $89
                     CMP #$04:BNE NOBOT
                     LDA CURT
                     CMP #$01:BNE NOBOT
                     RTS
NOBOT                LDA CURT:STA $88
                     JSR BACK1L
                     LDA #1
                     RTS
NOTLAST              LDA LINE:BEQ DOSCD
CONTP                DEC LINE:JSR CURDO2:LDA CHTEMP:BEQ NoPL
                     JSR CURDO2:DEC LINE
                     JSR BACK1L
NoPL                 JSR BACK1L:DEC LINE
                     LDA OPCH1:STA COLUMN
                     JMP SETCUR2
DOSCD                JSR SCROLLD:INC LINE
                     LDA CUPO:CLC:ADC #$50
                     STA CUPO
                     JMP CONTP
RESCUR               LDA CUPO:SEC:SBC #$50
                     STA WDATAW
                     LDA CUPO+1:SBC #0
                     STA WDATAW+1
                     JSR WWoRD
                     RTS
RESCMR               LDA CUPO
                     STA WDATAW
                     LDA CUPO+1
                     STA WDATAW+1
                     JSR WWoRD
                     RTS
RESCMR2              LDA CUPO2
                     STA WDATAW
                     LDA CUPO2+1
                     STA WDATAW+1
                     JSR WWoRD
                     RTS
RESCDR               LDA CUPO:CLC:ADC #$50
                     STA WDATAW
                     LDA CUPO+1:ADC #0
                     STA WDATAW+1
                     JSR WWoRD
                     RTS
PRESCUR              JSR RWoRD
                     LDA WDATAW:STA CUPO
                     LDA WDATAW+1:STA CUPO+1
                     RTS
PRESCUR2             JSR RWoRD
                     LDA WDATAW:STA CUPO2
                     LDA WDATAW+1:STA CUPO2+1
                     RTS
CURRIGHT             LDA COLUMN:CMP #79
                     BCS NOADV
                     INC COLUMN
                     JMP SETCUR2
NOADV                LDA #0
                     STA COLUMN
                     JMP SETCUR2
CURLEFT              LDA COLUMN:BEQ NOCNG
                     JSR PRESCUR
                     LDA CUPO
                     SEC:SBC #1:STA CUPO
                     LDA CUPO+1:SBC #0
                     STA CUPO+1
SETRIT               JSR RESCMR
                     DEC COLUMN:RTS
NOCNG                LDA MTEMP:CMP #$14:BNE OKLE2
                     RTS
OKLE2                JSR PRESCUR
                     LDA CUPO:CLC:ADC #$4F
                     STA CUPO
                     LDA CUPO+1:ADC #0
                     STA CUPO+1
                     LDA #80:STA COLUMN
                     JMP SETRIT
RETURN               JSR READSCR:LDA #0:STA COLUMN
                     LDY LINE:CPY #23
                     BEQ NEXTLI
                     INY:TYA:STA LINE
                     JSR SETCUR2
                     JSR READSCR2
                     JMP CHECKEY
NEXTLI               LDA LINE:JSR SETCUR2:JSR SCROLL
CHECKEY              LDA KEYPRESS:CMP #$0D
                     BEQ INPUT1
                     RTS
INPUT1               LDA #0:STA KEYPRESS
                     STY YTEMP:LDY #0
                     STY COMFLAG
READBUFF             LDA BUFFER,Y
                     CMP #$20:BNE EXITDIR2
                     INY:CPY #$50
                     BCC READBUFF
                     LDY YTEMP
                     LDY #0
                     JMP INSTLINE

NOEXTRAB             JMP NOEXTRA

EXITDIR2             LDA #0:STA COMFLAG
                     JMP STRINGH
DVER                 LDA $90:AND #$90:BNE ISDER
                     RTS
ISDER                TXA:PHA:TYA:PHA:LDY #0
                     LDA COLoR:ORA #$10:STA COL
divLOOP              LDA divMES,Y
                     CMP #$FF:BEQ EXITdiv
                     JSR SCRPRINT
                     INY:JMP divLOOP
EXITdiv              LDA $90:AND #$90:LSR :LSR :LSR :LSR 
                     STA TEMP2
                     LDA #0:STA TEMP3
                     JSR BN2DEC
                     LDA NBUF+1:JSR SCRPRINT
                     LDA NBUF:JSR SCRPRINT
                     LDA COLoR:STA COL
                     JSR RETURN
                     LDA LINE:JSR SETCUR2:JSR CURPOS
                     PLA:TAY:PLA:TAX:PLA:PLA
                     LDA #$F1:STA $D01A
                     JMP EXITFIN

LOADDIR2             LDA #0:STA $9D
                     STA CHANGE
                     STA COUNTROWS
                     LDA #$30:STA DIR+1
                     LDA #$24:STA DIR
DIRCHK               INY:LDA BUFFER,Y
                     CMP #$20:BEQ NOEXTRA
                     CMP #$30:BEQ NOEXTRA
                     LDA #$31:STA DIR+1:JMP NOEXTRA
EXITDIRC             JMP EXITDIR2
E                    LDA #$80:STA EMPTY:JMP GETNEXT;            GETErr
D                    JSR DVER
                     JMP EXITDIR
NOEXTRA              LDA #$01
                     LDX DEVICE
                     LDY #$00
                     JSR $FFBA
STRNUM               LDA #$02
                     LDX #DIR
                     LDY ^DIR
                     JSR $FFBD
                     LDA COMFLAG:BEQ RDIR
                     JSR $FFC0
                     LDA $90:AND #$80
                     BNE D
                     JMP EXITDIR
RDIR                 JSR $FFC0
                     LDA $90:AND #$80
                     BNE D
                     LDX #$01:JSR $FFC6
                     JSR $FFCF:LDA $90
                     AND #$40:BNE E
                     JSR $FFCF:LDA $90
                     AND #$40:BNE E
GETLOOP2             JSR $FFCF:STA ATEMP
                     JSR $FFCF:ORA ATEMP
                     BEQ EXITDIR
                     JSR $FFCF:STA TEMP2
                     JSR $FFCF:STA TEMP3
                     INC COUNTROWS
                     LDA COUNTROWS
                     CMP #22:BCC NOWAIT
                     LDY #0
WAITKEY              LDA $D4
                     CMP #$3F:BEQ EXITDIR
                     CMP #$58:BEQ WAITKEY
                     LDA #0:STA COUNTROWS
NOWAIT               JSR BN2DEC
                     LDY #1
ASCLOOP              LDA ASCIIBR,Y
                     JSR SCRPRINT
                     INY:CPY #8
                     BNE ASCLOOP
GETQUOT              JSR $FFCF
                     CMP #$42:BEQ AB
                     CMP #$22:BNE GETQUOT
AB                   STA BUF2:LDY #1
GETLOOP              JSR $FFCF
                     STA BUF2,Y
                     BEQ NEXTBIT
                     INY
                     BNE GETLOOP
NEXTBIT              LDY #0
NEXTBIT2             LDA BUF2,Y
                     BEQ DORRRR
                     CMP #$0D
                     BNE NoR
                     JMP ERRoRC1
DORRRR               JSR RETURN:JMP GETLOOP2
NoR                  JSR SCRPRINT
                     INY:BNE NEXTBIT2
EXITDIR              JSR RETURN
EXITFIN              LDA #15:JSR $FFC3
                     LDA #1:JSR $FFC3
                     JSR $FFCC
EXITFIN2             LDA #$3E:STA $D500
                     STA $FF00
                     LDA #$00:STA $D501
                     STA $D502:STA $D503
                     STA $D504:STA $FF01
                     STA $FF02:STA $FF03
                     STA $FF04:STA COMFLAG
                     LDA #$37:STA $D505
                     LDA #$04:STA $D506
                     LDA #$00:STA $D507
                     LDA #$F0:STA $D508
                     LDA #$01:STA $D509
                     LDA #$F0:STA $D50A
                     LDA #$20:STA $D50B
                     LDA #2:STA $FF00
                     LDA COLoR:STA COL
                     LDA #$88:STA $2AA
                     LDY YTEMP
                     RTS
GETLLS               LDY #15:LDA #32
GETLLS1              STA DIR,Y:DEY:BPL GETLLS1
                     JSR SKIPSP
                     BIT EMPTY:BMI NOST
                     CMP #$22:BNE NOST
                     LDY #0
GETSTL               JSR RDOC
                     CMP #$22:BEQ ENDST
                     BIT EMPTY:BMI NOST
                     JSR CONVTA
                     STA DIR,Y
                     INY
                     JMP GETSTL
NOST                 SEC:RTS
ENDST                TYA:LDX #DIR:LDY ^DIR
                     JSR SETNAM:CLC:RTS

LVFLG                DFB 0
ERRoRC1              JMP GETErr
LOAD2                LDA #1:STA ADDR+1
                     LDA #0:STA CHANGE
                     STA LPLUSFLAG
                     STA LVFLG
                     STA $9D:STA $C7
                     LDA #4:STA ADDRH+1
                     LDA #1:STA $C6
                     BIT EMPTY:BMI NOST
                     JSR SKIPSP
                     CMP #$22:BEQ NPV
                     JSR CONVTA
                     CMP #'+:BEQ LPLUS
                     CMP #'V:BEQ VERIF
NPV                  DEC YOFF:JMP SETLOG

VERIF                INC LVFLG:JMP SETLOG

LPLUSFLAG            DFB 0

LPLUS                LDA #$FF:STA LPLUSFLAG
                     LDA SoRTOP+1
                     STA ADDRH+1
                     LDA SoRTOP:SEC
                     SBC #1:STA ADDR+1
                     BCS LOADLOOP
                     DEC ADDRH+1:INY
LOADLOOP             JMP SETLOG

COMM2A               LDA #0:JSR SETNAM
                     LDA #15:LDX DEVICE
                     LDY #15
                     JSR SETLFS
                     JSR OPEN
                     JSR GETErr
                     JMP EXITFIN

SETLOG               JSR GETLLS
                     BCC GOTST
                     RTS
GOTST                LDA #1
                     LDX DEVICE
                     LDY #$00:STY $9D
                     JSR $FFBA
                     LDA #$F0:STA $D01A
                     LDA LVFLG
ADDR                 LDX #1
ADDRH                LDY #4
                     JSR $FFD5
CHEDISK              STA ATEMP
                     JSR DVER
                     LDA #$F1:STA $D01A
                     LDA ATEMP:CMP #4
                     BEQ COMM2A
                     CMP #8:BEQ EXITLOAD
                     CMP #3:BEQ COMM2A
                     STX SoRTOP:STY SoRTOP+1
;      LDA SoRTOP:ORA SoRTOP+1
EXITLOAD             LDA #$88:STA $02AA
                     LDA ADDR+1:STA $88
                     LDA ADDRH+1:STA $89
                     LDA #$AE:STA $02B9
                     LDA #$FF:JSR PTBT
                     JSR GTBT:PHA

                     BIT LPLUSFLAG:BMI NPUTNAME

                     LDY #0:LDX #0
                     LDA DIR+1,Y
                     CMP #$3A:BNE SETMES
                     INY:INY
SETMES               LDA DIR,Y
                     STA MES1,Y
                     STA MES2,Y
                     STA MES3,Y
                     STA MES4,Y
                     STA MES5,Y
                     INY:INX:CPX #12:BCC SETMES
STLINL               LDA DIR,Y
                     STA MES5,Y
                     INY:INX:CPX #16:BCC STLINL

NPUTNAME             LDY #11
COPYNBACK            LDA MES1,Y:STA DIR,Y:DEY:BPL COPYNBACK

CONTIN               PLA
NOTCARX              CMP #$AA:BEQ ZEUSFoRM
                     LDA #1:STA CURT
                     LDA #4:STA CURT+1
                     RTS
ZEUSFoRM             LDY #0
PRINTZ               LDA ZEUSMESS,Y
                     CMP #$FF:BEQ EXITZ
                     JSR SCRPRINT
                     INY:JMP PRINTZ
EXITZ                LDY #0
                     JMP COMPRESS
ZEUSMESS             DFM "ZEUS FORMAT, CONVERTING PLEASE WAIT":DFB $FF
READY                JSR RETURN
                     LDA #0:STA COLUMN
                     LDA #24:STA LINE:JSR SETCUR2
                     LDA #$47:STA COL
                     LDY #0
PRINTRE              LDA STLIN,Y
                     CMP #$FF
                     BEQ EXITR
                     JSR SPSTAT
                     JSR COLOUR
                     INY:JMP PRINTRE
EXITR                LDA #0:STA LINE:STA COLUMN:JSR SETCUR2
                     LDA COLoR:STA COL
                     JMP LIST2A
STLIN                DFM "C 00,00 SP 0400 ST 0430       LOG OFF FILE "
MES5                 DFM "EDAS V1.8   .SRC VERSION 1.8 05/08/88":DFB $FF
COMPRESS             LDA #4:STA $AF:LDA #1:STA $AE
                     LDA #0:JSR PTBT
                     LDA $88:STA $AE
                     CLC:ADC #2:STA $88
                     LDA $89:STA $AF
                     ADC #0:STA $89
MOVELOOP             JSR GTBT:BEQ SKIP2
                     CMP #$FF:BEQ EXITMOVE
                     CMP #$0A:BEQ SKIP1
                     JSR PTBT
                     JMP MOVELOOP
SKIP1                JSR GTBT:JMP MOVELOOP
SKIP2                JSR PTBT:LDA $88:CLC:ADC #2
                     STA $88
                     LDA $89:ADC #0:STA $89
                     JMP MOVELOOP
EXITMOVE             JSR PTBT
                     JSR RETURN
                     LDA #$01:STA CURT
                     LDA #$04:STA CURT+1
                     RTS
STRINGH              LDY #$4F
CLRST                LDA #0:STA BUF3,Y
                     DEY:BPL CLRST
                     LDY #$FF
                     LDA #0:STA KEYPRESS
STLOOP               INY:LDA BUFFER,Y
                     CMP #$20:BEQ STLOOP
                     STY BUFSTR:JMP INSTLINE
CHNEW                INY:LDA BUFFER,Y
                     CMP #$20:BNE NETX4
                     LDA #$01:STA SoRTOP
                     LDA #$04:STA SoRTOP+1
                     STA $AF
                     LDA #0:STA $AE
                     LDA #$FF:JSR PTBT
                     RTS
NETX4                DEY:JMP INSTLINE
CHOLD                INY:LDA BUFFER,Y
                     CMP #$20:BNE NETX4
CHOLD2               LDA #$88:STA $02AA
                     LDA #$AE:STA $02B9
                     LDA #$01:STA $88
                     LDA #$04:STA $89
                     STA $AF:LDA #0:STA $AE
                     LDA #0:JSR PTBT
OLDLOOP              JSR GTBT:CMP #$0A:BCC OLDLOOP
                     CMP #$FF:BNE OLDLOOP
                     LDA $88:STA SoRTOP
                     LDA $89:STA SoRTOP+1
                     RTS

INSTLINE             JSR ENCOD
                     STY BUFLEN2
                     JSR PUTSTRING
                     LDA LINE:BEQ NORT
                     JSR CURUP
                     JSR RESTLINE
                     JMP CURDOWN
NORT                 RTS


ZP                   EQU $7A
BUF1                 EQU $568
BUF3                 EQU $4C8

ENCOD                LDA #0:STA BUF3:STA BUF3+1
                     JSR CONVBUF
                     BCS ISALIN
                     LDY #0
                     JMP ENDLIN

ISALIN               LDX #0:LDY #0
ENCOD1               LDA REM:BNE DIRECT
                     JSR QUOTE
                     LDA QFL:BNE DIRECT
                     LDA BUF1,X
                     CMP #32
                     BEQ SKIPEN
                     CMP #&;
                     BEQ REMA
NOTREM               JSR SEARCHOPCODE
                     BCS GOTOP
DIRECT               LDA BUF1,X
GOTOP                STA BUF3,Y
                     INY
                     CMP #$0A:BCC ENDLIN
SKIPEN               INX
                     CPX #80
                     BNE ENCOD1
ENDLIN               LDA #0:STA QFL:STA REM
                     RTS
REMA                 LDA #1:STA REM
                     JMP DIRECT
QUOTE                LDA BUF1,X
                     CMP #34
                     BEQ DOQ:RTS
DOQ                  LDA QFL:EOR #1:STA QFL
                     RTS

REM                  DFB 0
SCRLFG               DFB 0
CHTEMP               DFB 0
QFL                  DFB 0;    QUOTE FLAG

SEARCHOPCODE
;RETURN CARRY CLEAR AND OPCODE IN A IF OPCODE FOUND

                     STY TY
                     STX TX
                     LDA #0
                     STA OPCODP
                     LDA #OPCODS
                     STA ZP
                     LDA ^OPCODS
                     STA ZP+1
                     JSR COMPOPCODES
                     BCC NOTGOT
                     LDY OPCODP
                     LDA TOKEN,Y
                     LDY TY:RTS
NOTGOT               LDY TY:LDX TX
                     RTS

COMPOPCODES          LDY #0
COMPOP1              LDA (ZP),Y
                     CMP #$80:BEQ ITSOP
                     CMP BUF1,X
                     BNE NOTOPT
                     INY
                     INX
                     CPY #4
                     BNE COMPOP1
ITSOP                LDA OPCODP
                     CMP #LASTOP-9
                     BCS ITSOP1
                     LDY TY
                     BEQ ITSOP1
                     LDY TX
                     LDA BUF1-1,Y
                     CMP #32
                     BEQ ITSOP1
                     CMP #58;           58=:
                     BEQ ITSOP1
                     JMP NOTOPT
ITSOP1               DEX
                     SEC:RTS

NOTOPT               LDX TX
                     LDA ZP
                     CLC:ADC #4
                     STA ZP
                     LDA ZP+1
                     ADC #0
                     STA ZP+1
                     INC OPCODP
                     LDA OPCODP
                     CMP #LASTOP
                     BNE COMPOPCODES
                     CLC:RTS

OPCODP               DFB 0

GETLEN               LDX #79
CONVBL1              DEX:BMI NOL
                     LDA BUFFER,X
                     CMP #32
                     BEQ CONVBL1
                     SEC:RTS
NOL                  LDY #0:CLC:RTS
GETLEN2              LDX #$FF
CONVBL1A             INX:BMI NOL2
                     LDA BUF1,X
                     BNE CONVBL1A
NOL2                 RTS

CONVBUF
;CONVERTS BUFFER TO LOWER CASE IF NEADED AND PUTS IN BUF1

                     JSR GETLEN
                     BCS CONON:RTS
CONON                LDA #0
                     STA BUF1+1,X
CONVBL2              LDA COLBUF,X
                     STA ATEMP
                     LDA BUFFER,X
                     CMP #32
                     BCS NOAD
                     BIT ATEMP
                     BPL NOTLC
                     ORA #$20
NOTLC                ORA #$40
NOAD                 STA BUF1,X
                     DEX
                     BPL CONVBL2
                     SEC:RTS

CBMOVE               JSR BMOVE1
                     LDA ERRF
                     BNE ERD
                     LDA CURT+1:CMP MRK1+1:BCC NOSUB2
                     BNE SUBB2
                     LDA CURT:CMP MRK1:BCC NOSUB2
                     BCS SUBB2
NOSUB2               SEC:JMP DEB2
SUBB2                CLC
DEB2                 LDA MRK1:SBC #0:STA $AE:LDA MRK1+1:SBC #0:STA $AF
                     LDA MRK2:STA $88:LDA MRK2+1:STA $89
OKLE                 LDA CURT:STA MRK3:LDA CURT+1:STA MRK3+1
                     JMP DEL4
ERD                  RTS
ERRF                 DFB 0

BMOVE1               LDA #0:STA ERRF:JSR CHKINSERT
                     JSR RECALP
                     LDA ERRF:BEQ OKCON
                     RTS
OKCON                JSR ERRTRA:BCC OKNR:LDA #1:STA ERRF:RTS
OKNR                 JSR SETOPEN;                                      AT CURRENT
                     LDA MRK1+1:CMP CURT+1:BCC OKPTR
                     BNE MOVEDP
                     LDA MRK1:CMP CURT:BCC OKPTR
MOVEDP               LDA MRK1:ADD MRK3:STA MRK1
                     LDA MRK1+1:ADC MRK3+1:STA MRK1+1
                     LDA MRK2:ADD MRK3:STA MRK2
                     LDA MRK2+1:ADC MRK3+1:STA MRK2+1
                     LDA MRK2:ADD #1:STA MRK2
                     LDA MRK2+1:ADC #0:STA MRK2+1
OKPTR
                     JSR MOVEDATA;                                     TO CURRENT
                     LDA #0:STA ERRF
                     RTS

RECALP               LDA #0:STA $88:LDA #4:STA $89
NXLI                 JSR GETLINE:BEQ ENDSR4
                     LDA SRCLIN,Y
                     CMP #0:BEQ NXLI
                     CMP #1:BNE NXLI
                     JSR BACKNS
                     LDA $88:STA MRK1
                     LDA $89:STA MRK1+1
                     JSR GETLINE
NXLI2                JSR GETLINE:BEQ ENDSR4
                     LDA SRCLIN,Y
                     CMP #0:BEQ NXLI2
                     CMP #1:BNE NXLI2
                     JSR BACKNS
                     LDA $88:SEC:SBC #1
                     STA MRK2
                     LDA $89:SBC #0:STA MRK2+1
                     RTS
ENDSR4               LDX #$3E:STX $FF00:LDA #1:STA ERRF:RTS

SETOPEN              LDA SoRTOP:SEC:SBC CURT
                     TAY:STA FROM+1
                     LDA SoRTOP:SEC:SBC FROM+1
                     STA FROM+1
                     LDA SoRTOP+1:SBC #0
                     STA FROM+2
; **********OK  FROM
                     LDA MRK2:SEC:SBC MRK1
                     STA MRK3
                     LDA MRK2+1:SBC MRK1+1
                     STA MRK3+1
                     LDA FROM+1:SEC:ADC MRK3;*******FF
                     STA TO+1
                     LDA FROM+2:ADC MRK3+1
                     STA TO+2
; **********OK   TO
                     LDA FROM+2:SEC:SBC CURT+1
                     TAX
                     JSR GPBYTE
                     LDA SoRTOP:SEC:ADC MRK3
                     STA SoRTOP
                     LDA SoRTOP+1:ADC MRK3+1
                     STA SoRTOP+1
TRANSMM              RTS

ERRTRA               LDA CURT+1
                     CMP MRK1+1
                     BCC OKNE
                     BNE QQQQ
                     LDA CURT
                     CMP MRK1
                     BCC OKNE
QQQQ                 LDA MRK2+1
                     CMP CURT+1
                     BCC OKNE
                     BNE ERRR
                     LDA MRK2
                     CMP CURT
                     BCC OKNE
ERRR                 SEC:RTS
OKNE                 CLC:RTS

MOVEDATA             LDA MRK2
                     SEC:SBC MRK1
                     TAY
                     STA SUBB
                     LDA MRK2
                     SEC
                     SBC SUBB
                     STA FROM+1
                     LDA MRK2+1:SBC #0
                     STA FROM+2
                     LDA CURT:CLC:ADC MRK3
                     STA TO+1
                     LDA CURT+1:ADC MRK3+1
                     STA TO+2
TRMA                 LDA TO+1:SEC:SBC SUBB
                     STA TO+1
                     LDA TO+2:SBC #0:STA TO+2
                     LDX MRK3+1;BUG IN COPY MOVE ON =
                     JSR GPBYTE
                     RTS

SUBB                 DFB 0
MRK1                 DFW $0000
MRK2                 DFW $0000
MRK3                 DFW $0000

BCOPY                JSR BMOVE1
ENDZ                 LDX #$3E:STX $FF00:LDA ERRF:BNE NOTKEY:JSR LIST2A
NOTKEY               LDA #0:STA KEYPRESS:STA CHANGE
                     RTS

BDELETE              LDA BLOKN:BEQ ENDSR
                     LDA #0:STA $88
                     LDA #4:STA $89
NNXLI                JSR GETLINE
                     BEQ ENDSR
                     LDA SRCLIN,Y
                     CMP #$00:BEQ NNXLI
                     CMP #1:BNE NNXLI
                     JSR BACKNS
                     LDA CURT+1:CMP $89
                     BCC REVERS
                     BNE OKD
                     LDA CURT:CMP $88
                     BCC REVERS
OKD                  LDA $88:STA $AE:STA MRK3
                     LDA $89:STA $AF:STA MRK3+1
                     LDA CURT:STA $88
                     LDA CURT+1:STA $89

DEL4                 LDY #0:JSR PGBYTE
                     TYA:SEC:ADC $AE:STA SoRTOP
                     LDA $AF:ADC #0:STA SoRTOP+1
                     LDX #$3E:STX $FF00
                     LDA MRK3:STA CURT
                     LDA MRK3+1:STA CURT+1
                     JSR ENDZ
                     LDA #0:STA CHANGE
                     JMP BZREMB
ENDSR                LDX #$3E:STX $FF00:LDA #0:STA KEYPRESS:STA CHANGE:RTS
REVERS               LDA CURT:STA $AE:STA MRK3
                     LDA CURT+1:STA $AF:STA MRK3+1
                     JMP DEL4

PUTSTRING            LDA KEYPRESS2
                     CMP #13:BNE NOTCR
                     LDY BUFLEN2
                     BNE NOTZL
                     LDA #0
                     STA BUF3+1,Y
                     INC BUFLEN2
NOTZL                INC BUFLEN2

NOTCR                LDA CURT:STA $88
                     LDA CURT+1:STA $89
                     LDA #0:STA BUFLEN

NEWLINE              JSR GTBT:CMP #$0A:BCC EXTES
                     INC BUFLEN:JMP NEWLINE

EXTES                LDA BUFLEN2:BEQ EXTES2
                     DEC BUFLEN2:LDA BUFLEN2
EXTES2               SEC:SBC BUFLEN:STA XTEMP2A
                     STA BUFLEN:BEQ OPENSPA1
                     BCS OPENSPA1
                     LDX BUFLEN2
                     STX BUFLEN
                     JSR DELLINE1
                     JMP SoREU
OPENSPA1             LDA SoRTOP
                     SEC:SBC CURT
                     TAY:STA FROM+1
                     LDA SoRTOP
                     SEC:SBC FROM+1
                     STA FROM+1
                     LDA SoRTOP+1:SBC #0
                     STA FROM+2
                     LDA FROM+1:CLC:ADC BUFLEN
                     STA TO+1
                     LDA FROM+2:ADC #0
                     STA TO+2
                     LDA FROM+2
                     SEC:SBC CURT+1
                     TAX
                     LDA FROM+2:CMP TO+2
                     BNE TRANSMEM
                     LDA FROM+1:CMP TO+1
                     BNE TRANSMEM
                     JMP SoREU
TRANSMEM             JSR GPBYTE
SoREU                LDA CURT:STA $AE
                     LDA CURT+1:STA $AF
                     LDX #0
LOOPSTP              TXA:PHA
                     LDA BUF3,X
                     JSR PTBT
                     PLA:TAX:INX
                     CPX BUFLEN2:BCC LOOPSTP
                     LDA SoRTOP:CLC
                     ADC XTEMP2A
                     STA SoRTOP:STA $AE
                     LDA SoRTOP+1
                     ADC #0
                     STA SoRTOP+1:STA $AF
                     LDA KEYPRESS2
                     CMP #$0D:BNE EXITPUTS2
                     LDA CURT:STA $88
                     LDA CURT+1:STA $89
                     JSR GETLINE
                     LDX #$3E:STX $FF00
                     LDA $88:STA CURT
                     LDA $89:STA CURT+1
                     JSR SCROLLD
EXITPUTS2            LDA #0:STA KEYPRESS:STA KEYPRESS2
                     RTS

DELLINE              LDA COLUMN:STA TEMPC
                     LDA #23:SEC:SBC LINE
                     STA COUNT2
                     JSR PRESCUR2
                     LDX LINE:INX:STX XTEMP
                     TXA:ASL :TAX
                     LDA TABLE,X
                     STA SCROLLPOS+1:INX
                     LDA TABLE,X
                     STA SCROLLPOS
                     LDX #19:JSR READT
                     STA SCRPOS
                     LDA SCROLLPOS+1:SEC
                     SBC #$50:PHP
                     JSR PRTDT
                     LDX #18:JSR READT
                     STA SCRPOS+1
                     LDA SCROLLPOS
                     PLP:SBC #0
                     JSR PRTDT
                     LDA LINE:CMP #23
                     BCS PISSOD
                     JSR SCROLL2
PISSOD               JSR DELLINED
                     LDA LINE:CMP #23:BNE PISSOD1:JSR CLRLINE
PISSOD1              LDA LINE:JSR SETCUR
                     JSR PRTBOTL
                     RTS

DELLINE1             LDA CURT:CLC:STA $88
                     ADC BUFLEN
                     STA $AE
                     LDA CURT+1:STA $89:ADC #0
                     STA $AF
                     JSR GTBT:CMP #$0A:BCC DLINE2
                     CMP #$FF:BNE DLINE
DELD                 JMP EXITDELD
DLINE                JSR GTBT:CMP #$0A:BCC DLINE3
                     CMP #$FF
                     BEQ DELD
                     JMP DLINE
DLINE3
DLINE2               LDA #0:STA OLDMSB:JSR GTBT
                     CMP #$FF:BNE DLINE4
                     STA OLDMSB
DLINE4               JSR GETBYTE2:JSR GETBYTE2
                     LDY #0:JSR PGBYTE
EXITDELL             TYA:CLC:ADC $AE:STA SoRTOP
                     LDA $AF:ADC #0:STA SoRTOP+1
                     LDA OLDMSB:BEQ NOTIF
                     JSR IFFF
NOTIF                LDA #0:STA XTEMP2A
                     RTS
DELLINED             LDA CURT
                     STA $AE:STA $88
                     LDA CURT+1
                     STA $AF:STA $89
                     JSR GETLINE:LDX #$3E:STX $FF00
                     CMP #$0A:BCC EXTOP
                     CMP #$FF:BEQ EXTOP
                     LDY #0:INC $D020
OLLOP                LDA SRCLIN,Y
                     STA OLDBUF,Y:INY
                     CMP #$0A:BCC EXTOP
                     CMP #$FF:BNE OLLOP
EXTOP                LDA CURT:STA $AE:STA $88
                     LDA CURT+1:STA $AF:STA $89

DLINED               JSR GTBT:CMP #$0A:BCC DLINE2A
                     CMP #$FF:BEQ EXITDELD
                     JMP DLINED
DLINE2A              LDA #0:STA OLDMSB:JSR GTBT
                     CMP #$FF:BNE DLINE4A
                     STA OLDMSB
DLINE4A              JSR GETBYTE2
                     LDY #0:JSR PGBYTE
                     JMP EXITDELL
EXITDELD             LDA $88:STA SoRTOP
                     LDA $89:STA SoRTOP+1
                     LDA #0:STA XTEMP2A
                     RTS
IFFF                 JSR LASTSRL
                     BEQ LASTLINE
                     LDA LINE:BEQ LASTLIN2
                     JSR PRESCUR
                     JSR RESCUR
                     DEC LINE
LASTLINE             RTS
LASTLIN2             LDA COLUMN:STA OPCH2
                     JSR PRESCUR
                     JSR CURDO2
                     DEC LINE
                     LDA OPCH2:STA COLUMN
                     JSR RESCMR
                     JSR BACK1L
                     RTS


PRINTMEM             LDA NOMEM,Y:CMP #$FF
                     BEQ EXITMEM
                     JSR SCRPRINT:INY
                     JMP PRINTMEM
EXITMEM              LDA #$FE:STA $AF
                     LDA #$FF:STA $AE
                     JSR RETURN:RTS
SAVE2                LDA #0:STA $9D
                     STA CHANGE:STA $C7
                     LDA #1:STA $C6
SAVELOOP             LDA BUFFER,Y
                     CMP #$22:BEQ FOUNDQB
                     CMP #$20:BNE NOTQA
                     INY
                     CPY #$50:BCC SAVELOOP
NOTQA                RTS
FOUNDQB              INY:LDX #0
BSTRINGA             LDA BUFFER,Y
                     CMP #$22:BEQ FOUNDQ2A
                     CMP #$1B:BCS NOTCHRQA
                     CLC:ADC #$40
NOTCHRQA             STA DIR,X
                     INY:INX
                     CPX #$10:BCC BSTRINGA
                     LDA BUFFER,Y
                     CMP #$22:BNE NOTQA
FOUNDQ2A             STX STRUM4+1
                     INY:LDA BUFFER,Y
                     CMP #$38:BEQ DEV8A
                     CMP #$20:BEQ SETLOG2
                     CMP #$39:BEQ DEV9A
                     JMP NOTQA
DEV9A                LDA #$09:STA DEVICE
                     JMP SETLOG2
NODEVI2              JMP DVER
COMM2C               JMP GETErr
DEV8A                LDA #$08:STA DEVICE
SETLOG2              LDA #$F0:STA $D01A
                     JSR CHOLD2
                     LDA #0:STA $C7
                     LDA #1:STA $C6
                     LDA #1
                     LDX DEVICE
                     LDY #0
                     JSR $FFBA
STRUM4               LDA #0
                     LDX #DIR
                     LDY ^DIR
                     JSR $FFBD
                     LDA #$01:STA $84
                     LDA #$04:STA $85
                     LDX SoRTOP
                     LDY SoRTOP+1
                     LDA #$84
                     JSR $FFD8
                     LDA #$F1:STA $D01A
                     LDA #$3F:STA $FF00
                     JSR CHOLD2
                     LDA ATEMP:AND #$80
                     LDA $90:AND #$80
                     BNE NODEVI2
                     RTS
divMES               DFC "device error ":DFB $FF
NOMEM                DFC "out of memory error":DFB $FF
COMFLAG              DFB 0
BUF2                 EQU $518
ASCIIBR              DFS $8,0
VALUE                DFB 0,0
NBUF                 DFS 6,0
NGFLAG               DFB 0
CHECK1               LDA TEMP2:CMP CHKVAL1
                     BEQ EQual
                     LDA TEMP3:SBC CHKVAL2
                     ORA #$01:BVS OVFLOW:RTS
EQual                LDA TEMP3:SBC CHKVAL2
                     BVS OVFLOW:RTS
OVFLOW               EOR #$80:ORA #$01:RTS
SCRCLR               LDY #23:STY LINE
NEXTLIC              LDA LINE:JSR CLRLINE
                     DEC LINE:BPL NEXTLIC
                     INC LINE
                     LDA #0:STA PRFLAG
                     JMP CURHOMM
CURHOME              LDA LINE:JSR FINDTOP
                     LDA #0:STA COLUMN:STA LINE
                     JSR SETCUR2
                     RTS

TABU                 LDA COLUMN:CMP #$0E
                     BCS EXITTAB1
                     LDA #$0E:SEC
                     SBC COLUMN:STA XTEMP
                     LDX #18:JSR READT
                     STA TEMP3:INX
                     JSR READT
                     STA TEMP2
                     LDA TEMP2:CLC
                     ADC XTEMP:STA TEMP2
                     LDA TEMP3:ADC #$00
                     LDX #18:JSR PRTDT
                     INX:LDA TEMP2
                     JSR PRTDT
                     LDA #$0E:STA COLUMN
                     LDA PRFLAG:BEQ EXITTAB
                     LDX XTEMP
PRINTSP              LDA #$20:JSR PRINTER
                     DEX:BNE PRINTSP
EXITTAB              RTS
EXITTAB1             JSR READSCR
                     LDY COLUMN
SRLO                 LDA BUFFER,Y:INY
                     CMP #&:
                     BEQ GOTCOL
                     CPY #79:BCC SRLO
                     RTS
GOTCOL               STY COLUMN:JMP SETCUR2

PRTDT                STX $D600
WAIT                 BIT $D600
                     BPL WAIT
                     STA $D601
                     RTS
PRTD2                BIT $D600
                     BPL PRTD2
                     STA $D601
                     RTS
READT                STX $D600
WAIT2                BIT $D600
                     BPL WAIT2
                     LDA $D601
                     RTS
COLOUR               LDX #19:JSR READT
                     STA SCRPOS:STA COLPOS
                     LDX #18:JSR READT
                     STA SCRPOS+1:CLC
                     ADC #$08:STA COLPOS+1
                     LDX #19:LDA COLPOS
                     SEC:SBC #1:PHP
                     JSR PRTDT
                     DEX:LDA COLPOS+1
                     PLP:SBC #0
                     JSR PRTDT
                     LDX #31:LDA COL
                     ORA LOWERCASE
                     JSR PRTDT
                     LDA #0:STA LOWERCASE
                     LDX #19:LDA SCRPOS
                     JSR PRTDT
                     LDX #18:LDA SCRPOS+1
                     JSR PRTDT
                     RTS
SCROLL               LDX #23:STX COUNT2
SCROLL2B             LDA #$00
                     STA SCROLLPOS
                     LDA #$50
                     STA SCROLLPOS+1
                     JSR PRESCUR2
                     LDA #0:JSR SETCUR
SCROLL2              LDX #24
                     JSR READT
                     ORA #$80
                     JSR PRTDT
                     LDX #32:LDA SCROLLPOS
                     JSR PRTDT
                     INX
                     LDA SCROLLPOS+1
                     JSR PRTDT
                     LDA #$50:LDX #30
                     JSR PRTDT
                     LDX #18:JSR READT
                     STA UPDATE
                     INX:JSR READT
                     STA UPDATE+1
                     LDX #19:LDA SCROLLPOS+1
                     SEC:SBC #$50:PHP
                     JSR PRTDT
                     DEX:LDA SCROLLPOS
                     PLP:BCS NOCAR2
                     SEC:SBC #$01
NOCAR2               CLC:ADC #$08
                     JSR PRTDT
                     LDX #32:LDA SCROLLPOS
                     CLC:ADC #$08
                     JSR PRTDT
                     INX
                     LDA SCROLLPOS+1
                     JSR PRTDT
                     LDA #$50:LDX #30
                     JSR PRTDT
                     LDX #18:LDA UPDATE
                     JSR PRTDT
                     INX:LDA UPDATE+1
                     JSR PRTDT
                     DEC COUNT2:BEQ FIN2
                     LDA SCROLLPOS+1
                     CLC:ADC #$50
                     STA SCROLLPOS+1
                     BCC SCROLL2A
                     INC SCROLLPOS
                     LDA SCROLLPOS
                     CMP #$08:BCC SCROLL2A
FIN2                 LDX #24:LDA #$20
                     JSR PRTDT
                     STY YTEMP:LDA #23
                     JSR CLRLINE
                     JMP DELRES
SCROLL2A             JMP SCROLL2
WDATAW               DFS 2,0
RDATAW               DFS 2,0
CUPO                 DFS 2,0
CUPO2                DFS 2,0
WDATA                DFB 0
WWoRD                LDX #18:LDA WDATAW+1
                     JSR PRTDT
                     INX:LDA WDATAW
                     JMP PRTDT
BWoRD                LDX #33:LDA WDATAW
                     JSR PRTDT
                     DEX:LDA WDATAW+1
                     JMP PRTDT
RWoRD                LDX #19:JSR READT
                     STA WDATAW:DEX
                     JSR READT
                     STA WDATAW+1:RTS
CLRLINE              ASL :TAY
                     LDA TABLE,Y:STA WDATAW
                     LDA TABLE+1,Y
                     STA WDATAW+1
                     LDA #$20:STA WDATA
CLRCoL               JSR WWoRD
                     LDX #31:LDA WDATA
                     JSR PRTDT
                     JSR BWoRD
                     LDA #$4F:LDX #30
                     JSR PRTDT
                     LDX #24:LDA #$20
                     JSR PRTDT
                     LDA WDATAW+1:CMP #8
                     BCS RETNC
                     LDX COLoR:STX WDATA
                     CLC:ADC #8:STA WDATAW+1
                     JMP CLRCoL
RETNC                RTS
DELRES               JSR RESCMR2
                     RTS
SCRUP                LDA #0:STA XTEMP2A
                     LDA LINE:CMP #23
                     BEQ EXSCRUP
                     JSR SCROLL
                     DEC LINE:LDA LINE
                     JSR SETCUR
                     RTS
EXSCRUP              JSR CLRLINE:LDA LINE
                     JSR SETCUR
                     RTS
SCROLLD              LDA #23:SEC:SBC LINE
                     STA COUNT2:BEQ SCRUP
                     BCC SCRUP
                     JSR PRESCUR2
                     LDA #23:JSR SETCUR
                     LDA WDATAW:STA UPDATE+1
                     LDA WDATAW+1:STA UPDATE
                     LDY #44:LDA TABLE,Y
                     STA SCROLLPOS+1
                     LDA TABLE+1,Y
                     STA SCROLLPOS
SCROLL3              LDX #24:JSR READT
                     ORA #$80:JSR PRTDT
                     LDX #32:LDA SCROLLPOS
                     JSR PRTDT
                     INX
                     LDA SCROLLPOS+1
                     JSR PRTDT
                     LDX #18:LDA UPDATE
                     JSR PRTDT
                     INX:LDA UPDATE+1
                     JSR PRTDT
                     LDA #$50:LDX #30
                     JSR PRTDT
                     LDX #19:LDA UPDATE+1
                     JSR PRTDT
                     DEX:LDA UPDATE
                     CLC:ADC #$08
                     JSR PRTDT
                     LDX #32:LDA SCROLLPOS
                     CLC:ADC #$08
                     JSR PRTDT
                     INX
                     LDA SCROLLPOS+1
                     JSR PRTDT
                     LDA #$50:LDX #30
                     JSR PRTDT
                     LDA UPDATE+1
                     SEC:SBC #$50
                     STA UPDATE+1
                     BCS NOCA
                     DEC UPDATE
NOCA                 DEC COUNT2:BEQ FIN3
                     LDA SCROLLPOS+1
                     SEC:SBC #$50
                     STA SCROLLPOS+1
                     BCS SCROLL3A
                     DEC SCROLLPOS
                     JMP SCROLL3A
FIN3                 LDX #24:LDA #$20
                     JSR PRTDT
                     STY YTEMP
                     LDA LINE:JSR CLRLINE
                     JMP DELRES
SCROLL3A             JMP SCROLL3
TEMP                 DFB 0
STFLAG               DFB 0
TEMP2                EQU $80
TEMP3                EQU $81
CHKVAL1              DFB 0
CHKVAL2              DFB 0
COUNT                DFB 0
COUNT2               DFB 0
COUNT3               DFB $07
SCRPOS               DFB 0,0
COLPOS               DFB $00,$08
SCROLLPOS            DFB $00,$08
UPDATE               DFB $00,$00
COL                  DFB %00100111
LINE                 DFB 0
COLUMN               DFB 0
LOWERCASE            DFB 0
KEYPRESS             DFB 0
KEYPRESS2            DFB 0
CARRY                DFB 0
ATEMP                DFB 0
ATEMP2               DFB 0
XTEMP                DFB 0
LENTH                DFB 0

RTNFLG               DFB 0
BUFSTR               DFB 0
BUFEND               DFB 0
BUFLEN               DFB 0
BUFLEN2              DFB 0
OPCH1                DFB 0
OPCH2                DFB 0
OPCH3                DFB 0
OPCH4                DFB 0
SPCH1                DFB 0
XTEMP3               DFB 0
SoRTOP               DFW $0401
SoRMSB               DFW $0401
OLD                  DFW $0401
OLDMSB               DFB 0
COUNTROWS            DFB 0
COLBUFL              DFB 0
COLBUFH              DFB 0
PRFLAG               DFB 0
TEMPC                DFB 0
TABLE                DFW $0000,$0050
                     DFW $00A0,$00F0
                     DFW $0140,$0190
                     DFW $01E0,$0230
                     DFW $0280,$02D0
                     DFW $0320,$0370
                     DFW $03C0,$0410
                     DFW $0460,$04B0
                     DFW $0500,$0550
                     DFW $05A0,$05F0
                     DFW $0640,$0690
                     DFW $06E0,$0730
                     DFW $0780,$07D0
                     DFW $0800
YTEMP                DFB 0
SPTR                 DFB 0
BUFFER               EQU $798
SRCLIN               EQU $240
TEMPBU               EQU $0748
COLBUF               EQU $06D0
COLBUF2              EQU $0680
HEXTAB               DFM "0123456789ABCDEF"
LIST2A               LDA #0:STA XTEMP2A
                     LDA #1:STA INTRN
LIST2C               LDA #$00:STA KEYPRESS
LIST2                LDA CURT
                     STA $88
                     LDA CURT+1
                     STA $89
MLTLI                LDA XTEMP2A
                     LDY INTRN:BEQ OKNOCL
                     JSR CLRLINE
                     LDA XTEMP2A
OKNOCL               ASL :TAY
                     LDA TABLE,Y
                     STA WDATAW
                     LDA TABLE+1,Y
                     STA WDATAW+1
                     JSR WWoRD
                     LDA #0:STA TABFLAG
                     STA COLUMN
LISTMAIN             JSR GETLINE:BEQ SoREND
PRTANY               JSR DECOM2

                     JMP ENDLINE2
SoREND               JSR GETBYTE2
                     LDX #$02:STX $FF00
                     LDA #$0D:JSR PRINTER
                     LDA #$00:STA PRFLAG
                     LDA INTRN:BNE JPN
                     STA XTEMP2A
                     RTS
JPN                  JMP EXITL2L
ENDLINE2             STA TEXT,X
                     LDA #$02:STA $FF00
PRTTEXT              LDY #0
PRTLIN               LDA TEXT,Y
                     CMP #$20:BNE PRTFS
                     JSR TABU:LDY #14
PRTFS                LDA TEXT,Y:INY
                     CMP #$0A:BCC STPPRI;          PRINT REVSPACE
PRTNOM               PHA:JSR SCRPRINT
                     PLA
                     JSR PRINTER
                     JMP PRTFS
STPPRI               CMP #0:BEQ STPPRI1:LDA #79:STA COLUMN
                     LDA #0:STA KEYPRESS
                     LDA INTRN:BNE UEST:LDA LINE:PHA:JMP SER
UEST                 LDA LINE:PHA:LDA XTEMP2A:STA LINE
SER                  JSR SETCUR2:PLA
                     STA LINE
                     LDA #$20:JSR SCPR3:LDA COLoR:AND #15:STA COL
                     LDA #$40:STA LOWERCASE
                     JSR COLOUR

STPPRI1              LDA #$0D:JSR PRINTER
                     LDA XTEMP2A
                     BEQ EXITL2
INTR                 CMP #23:BEQ EXITL2L
                     LDA PRFLAG:BNE PRFILE
                     INC XTEMP2A
PRFILE               JMP MLTLI
EXITL2               LDA INTRN:BNE INTR:RTS
EXITL2L              LDA XTEMP2A:CMP #23:BEQ EXIT2L2
EXIT1L               LDA XTEMP2A:CMP #24:BEQ EXIT2L2:JSR CLRLINE:INC XTEMP2A
                     JMP EXIT1L
EXIT2L2              LDY INTRN:DEY
                     LDA #0:STA INTRN
                     TYA:STA LINE
                     JSR SETCUR
                     LDA #0:STA COLUMN
                     RTS
INTRN                DFB 0
PRINTON
PRINTER              RTS

OPCODEN              BIT TABFLAG:STY YTEMP
                     BMI NOTABN:PHA
                     LDA #$20
TABLO                STA TEXT,X:INX:CPX #14
                     BCC TABLO
                     LDA #$80:STA TABFLAG
                     PLA
NOTABN               LDY #0:STY OPTAB
                     STY OPTAB+1
                     CMP #$E0:BCC NOIND2
                     SUB #NUMFREE;       THIS IS THE BASTARD (THANKS BILL)
NOIND2               SUB #$80:STA TX
ADJ2                 ASL 
                     ASL :ROL OPTAB+1
                     CLC:ADC #OPCODS
                     STA OPTAB
                     LDA ^OPCODS
                     ADC OPTAB+1
                     STA OPTAB+1
                     LDY #0
PRTOP                LDA (OPTAB),Y
                     BMI NULL2
                     STA TEXT,X:INX
NULL2                INY:CPY #4:BNE PRTOP
                     LDY YTEMP
                     LDA SRCLIN,Y:CMP #':
                     BEQ NOSPACE
                     LDA TX:CMP #8:BCC NOSPACE
                     CMP #$C:BCS NOSPACE
                     LDA #$20:STA TEXT,X:INX
NOSPACE              RTS

GTBT                 LDY #0
                     LDX #$7F
                     JSR $02A2
                     STA TEMP2
                     LDA $88:CLC:ADC #1
                     STA $88
                     LDA $89:ADC #0
                     STA $89
                     LDA TEMP2:RTS

PTBT                 LDY #0
                     LDX #$7F
                     JSR $02AF
PUTB                 LDA $AE:CLC:ADC #1
                     STA $AE
                     LDA $AF:ADC #0
                     STA $AF
                     RTS

GETBYTE2             LDY #0
                     LDX #$7F
                     JSR $02A2
                     STA TEMP2
                     LDA $88:SEC:SBC #1
                     STA $88
                     LDA $89:SBC #$00
                     STA $89
                     LDA TEMP2:RTS

FINDLAB1             JSR SKIPSP
                     JMP STRINGH
FINDLAB3             JSR SETTOP
                     JSR GETLEN
                     JSR CONON
                     JSR JUSTIFY
                     BNE COMPLOOP3
DOLIST               JMP LIST2A
COMPLOOP3            LDY #79
COMPLOOP1            LDA BUF1,Y
                     STA VBUF,Y:DEY:BPL COMPLOOP1
COMPLOOP             JSR GETLINE:PHP:LDY #$3E:STY $FF00
                     PLP:BEQ NFIND
                     CMP #$0A:BMI COMPLOOP
                     LDY #0
                     CMP BUF1,Y
                     BEQ COMPLOOP2
                     JMP COMPLOOP
COMPLOOP2            INY:LDA BUF1,Y
                     BEQ FOUNDLAB
                     CMP SRCLIN,Y
                     BNE COMPLOOP
                     JMP COMPLOOP2

NFIND                PHA:LDA #0:STA OLDCV:LDA #4:STA OLDCV+1:PLA:RTS

FOUNDLAB             LDA $88:STA OLDCV:LDA $89:STA OLDCV+1:JSR GETLADD:JMP LIST2A

SETTOP               LDA #1:STA $88:STA CURT
                     LDA #4:STA $89:STA CURT+1:RTS

DECOM                JSR GETLINE:PHP:LDX #$3E:STX $FF00:PLP:BEQ SETEND
DECOM2               LDX #0:CMP #$0A:BCC ENDLI
DECODE               LDY #0:LDX #0
NXBIT                LDA SRCLIN,Y:INY
                     CMP #$0A:BCC ENDLI
                     CMP #&;
                     BEQ NWLOP
                     CMP #0
                     BMI OPCOD2

                     STA TEXT,X:INX:JMP NXBIT

OPCOD2               JSR OPCODEN:JMP NXBIT;   DOES THIS BIT IF OPCODE

ENDLI                CLC
SETEND               RTS

NXBIT2               LDA SRCLIN,Y:INY;       DOES THIS BIT IF REM
                     CMP #$0A:BCC ENDLI
NWLOP                STA TEXT,X:INX:JMP NXBIT2

STRIG                JMP STRINGH
FINDST               JSR SETTOP
                     JSR GETLEN
                     JSR CONON
                     JSR JUSTIFY
                     BEQ DROP
                     JSR GETLEN2
                     STX BUFLEN2:STX OLDFSL
SVBUF                LDA BUF1,X:STA FBUF,X
                     DEX:BPL SVBUF
                     LDX BUFLEN2
FINSTLOP             LDA #0:STA TABFLAG:JSR DECOM
                     BCS DROP
                     INX:STX BUFLEN
                     LDY #0:LDX #0
SERLOP               LDA TEXT,X
                     CMP BUF1,Y
                     BNE CHKLENL
                     INX:INY:CPY BUFLEN2
                     BCC SERLOP
FOUND                LDA $88:STA CURT:STA OLDCF
                     LDA $89:STA CURT+1:STA OLDCF+1
                     JSR BACK1L
                     JSR LIST2A:CLC:RTS

DROP                 LDA #0:STA OLDCF:LDA #4:STA OLDCF+1
                     LDA #0:STA CHANGE:STA $D0:SEC:RTS
CHKLENL              INX:TXA:CLC:ADC BUFLEN2
                     CMP BUFLEN:BCS FINSTLOP
                     LDY #0:JMP SERLOP
JUSTIFY              INY:CPY #$50
                     BCS EXITJ
                     LDA BUF1,Y:CMP #$20
                     BEQ JUSTIFY
                     LDX #0
CoRRSTG              LDA BUF1,Y
                     STA BUF1,X
                     INY:INX:CPX #$50
                     BEQ DOINST
                     CPY #50:BCC CoRRSTG
DOINST               LDA BUF1
                     BEQ EXITJ
                     LDA #1:RTS
EXITJ                RTS

GETLADD              LDA $88:SEC:SBC #2
                     STA $88
                     LDA $89:SBC #0:STA $89
BAKON                JSR GETBYTE2
                     CMP #$0A:BCS BAKON
                     LDA $88:CLC:ADC #2
                     STA CURT:STA $88
                     LDA $89:ADC #0
                     STA CURT+1:STA $89
                     RTS

BACKNS               LDA $88:SEC:SBC #2:STA $88
                     LDA $89:SBC #0:STA $89
BACKNSL              JSR GETBYTE2:CMP #$0A:BCS BACKNSL
                     LDA $88:CLC:ADC #2:STA $88
                     LDA $89:ADC #0:STA $89
                     RTS

SETCUR               ASL :TAY
                     LDA TABLE,Y
                     STA WDATAW
                     LDA TABLE+1,Y
                     STA WDATAW+1
                     JMP WWoRD
SETCUR2              LDA LINE:ASL :TAY
                     LDA TABLE,Y
                     ADC COLUMN
                     STA WDATAW
                     LDA TABLE+1,Y
                     ADC #0
                     STA WDATAW+1
                     JSR WWoRD
CURPOS               LDX #19:JSR READT
                     LDX #15
                     JSR PRTDT
                     LDX #18:JSR READT
                     LDX #14
                     JMP PRTDT
FINDBOTL             LDA LINE:STA OPCH3
                     LDA CURT:STA $88
                     LDA CURT+1:STA $89
BOTL                 JSR GETLINE:BEQ POFF1
                     LDY OPCH3:INY:CPY #24
                     BEQ POFF2
                     STY OPCH3
                     JMP BOTL
POFF1                LDX #$3E:STX $FF00:SEC:RTS
POFF2                STA LAST:LDX #$3E:STX $FF00:CLC:RTS
PRTBOTL              JSR PRESCUR
                     LDA COLUMN:STA OPCH2
                     JSR FINDBOTL
                     BCS ENSOC
                     LDA #23:JSR SETCUR
                     LDA #0:STA COLUMN
                     STA TABFLAG:STA INTRN
                     STA XTEMP2A
                     LDA LAST
                     JSR PRTANY
ENSOC                JSR RESCMR
                     LDA OPCH2:STA COLUMN
                     RTS
CHKINSERT            LDA CHANGE:STA CHTEMP
                     BEQ NOCHANGE
                     LDA #0:STA CHANGE
                     JSR READSCR
                     JSR STRINGH
NOCHANGE             RTS
CHANGE               DFB 0
FINDTOP              STA OPCH3
                     LDA CURT
                     STA $88
                     LDA CURT+1
                     STA $89
FTLOP                LDA $89
                     CMP #4
                     BNE NOTBOT
                     LDA $88:CMP #1
                     BNE NOTBOT
FTOP                 RTS
NOTBOT               LDY OPCH3:BEQ FTOP:JSR BACK1L
                     LDY OPCH3:DEY
                     BEQ FTOP
                     STY OPCH3:JMP FTLOP
STATUSP              JSR COLROW
                     JSR SOrCAL
                     JSR DEVICES
                     JSR TIME
ST5                  JMP PRTSTR
COLROW               LDA COLUMN:STA TEMP2
                     JSR BN2D2
                     LDA NBUF
                     STA STLIN+3
                     LDA NBUF+1
                     STA STLIN+2
                     LDA LINE:STA TEMP2
                     JSR BN2D2
                     LDA NBUF
                     STA STLIN+6
                     LDA NBUF+1
                     STA STLIN+5
                     RTS
SOrCAL               LDA SoRTOP
                     JSR DETOA
                     LDA NBUF:STA STLIN+22
                     LDA NBUF+1:STA STLIN+21
                     LDA SoRTOP+1
                     JSR DETOA
                     LDA NBUF:STA STLIN+20
                     LDA NBUF+1:STA STLIN+19
                     LDA CURT
                     JSR DETOA
                     LDA NBUF:STA STLIN+14
                     LDA NBUF+1:STA STLIN+13
                     LDA CURT+1
                     JSR DETOA
                     LDA NBUF:STA STLIN+12
                     LDA NBUF+1:STA STLIN+11
                     RTS
DEVICES              LDA DEVICE:JSR DETOA
                     LDA NBUF:STA STLIN+28
                     LDA NBUF+1:CMP #$30
                     BNE USEN
                     LDA #$20
USEN                 STA STLIN+27
                     LDA PRFLAG:ASL :ADC PRFLAG:CLC:ADC #2:TAY:LDX #2
SHOW                 LDA ONROF,Y
                     STA STLIN+34,X
                     DEY:DEX:BPL SHOW
                     RTS
ONROF                DFM "OFF ON"
DETOA                PHA:AND #$0F:TAY
                     LDA HEXTAB,Y
                     STA NBUF
                     PLA:LSR :LSR :LSR :LSR 
                     TAY:LDA HEXTAB,Y
                     STA NBUF+1
                     RTS
TIME                 LDX #3
GETTOD               LDA #0;                 TOD,X
                     STA ASCIIBR,X
                     DEX:BPL GETTOD
                     CMP TENTHS
                     BNE DOCAL
                     RTS
DOCAL                STA TENTHS
                     LDX #3
PRTIM                LDA ASCIIBR,X
                     JSR DETOA
                     LDY TABS,X
                     LDA NBUF+1
                     AND #$37
                     STA STLIN,Y
                     LDA NBUF:STA STLIN+1,Y
                     DEX:BNE PRTIM
                     LDA ASCIIBR+3
                     AND #$80:CLC:ROL :ROL 
                     TAX:LDA AMPM,X
                     STA STLIN+3,Y:RTS
AMPM                 DFM "AP"
TABS                 DFB 69,66,63,60
PRTSTR               LDA #24:JSR SETCUR
                     LDY #0:LDX #31
                     LDA STLIN,Y
                     AND #$3F:JSR PRTDT
                     INY
FPRINT               LDA STLIN,Y
                     AND #$3F
                     JSR PRTD2
                     INY:CPY #80
                     BCC FPRINT
                     JMP SETCUR2
TEMPZPL              EQU $7C
TEMPZPH              EQU $7D
XTEMP2               DFB 0
XTEMP2A              DFB 0
YTEMP2               DFB 0
YTEMP1               DFB 0
TABFLAG              DFB 0
TENTHS               DFB 0
OPTAB                EQU $86
OPCODS               DFM "ORA "
                     DFM "AND "
                     DFM "EOR "
                     DFM "ADC "
                     DFM "STA "
                     DFM "LDA "
                     DFM "CMP "
                     DFM "SBC "
                     DFM "ASL":DFB $80
                     DFM "ROL":DFB $80
                     DFM "LSR":DFB $80
                     DFM "ROR":DFB $80
                     DFM "STX "
                     DFM "LDX "
                     DFM "DEC "
                     DFM "INC "
                     DFM "BIT "
                     DFM "STY "
                     DFM "LDY "
                     DFM "CPY "
                     DFM "CPX "
                     DFM "JMP "
                     DFM "JSR "
                     DFM "BRK":DFB $80
                     DFM "PHP":DFB $80
                     DFM "CLC":DFB $80
                     DFM "PLP":DFB $80
                     DFM "SEC":DFB $80
                     DFM "RTI":DFB $80
                     DFM "PHA":DFB $80
                     DFM "CLI":DFB $80
                     DFM "RTS":DFB $80
                     DFM "PLA":DFB $80
                     DFM "SEI":DFB $80
                     DFM "DEY":DFB $80
                     DFM "TXA":DFB $80
                     DFM "TYA":DFB $80
                     DFM "TXS":DFB $80
                     DFM "TAY":DFB $80
                     DFM "TAX":DFB $80
                     DFM "CLV":DFB $80
                     DFM "TSX":DFB $80
                     DFM "INY":DFB $80
                     DFM "DEX":DFB $80
                     DFM "CLD":DFB $80
                     DFM "INX":DFB $80
                     DFM "NOP":DFB $80
                     DFM "SED":DFB $80
                     DFM "BPL "
                     DFM "BMI "
                     DFM "BVC "
                     DFM "BVS "
                     DFM "BCC "
                     DFM "BCS "
                     DFM "BNE "
                     DFM "BEQ "
                     DFM "ORG "
                     DFM "DFS "
                     DFM "DFB "
                     DFM "DFW "
                     DFM "DFM "
                     DFM "DFH "
                     DFM "DSP "
                     DFM "ENT":DFB $80
                     DFM "EQU "
                     DFM "DFC "
                     DFM "DFL "
                     DFM "ADD "
                     DFM "SUB "
                     DFM "HEX "
                     DFM "DFN "
                     DFM "OUT "
                     DFM "REG "
                     DFM "END":DFB $80; \1

NUMFREE              EQU ($E0-(.-OPCODS)DIV 4)-$80

                     DFM ",X)":DFB $80
                     DFM "),Y":DFB $80
                     DFM ",X":DFS 2,$80
                     DFM ",Y":DFS 2,$80
                     DFM "MOD "
                     DFM "OR ":DFB $80
                     DFM "XOR "
                     DFM "DIV "
                     DFM "AND "

TOKEN                DFB $80,$81,$82,$83
                     DFB $84,$85,$86,$87
                     DFB $88,$89,$8A,$8B
                     DFB $8C,$8D,$8E,$8F
                     DFB $90,$91,$92,$93
                     DFB $94,$95,$96,$97
                     DFB $98,$99,$9A,$9B
                     DFB $9C,$9D,$9E,$9F
                     DFB $A0,$A1,$A2,$A3
                     DFB $A4,$A5,$A6,$A7
                     DFB $A8,$A9,$AA,$AB
                     DFB $AC,$AD,$AE,$AF
                     DFB $B0,$B1,$B2,$B3
                     DFB $B4,$B5,$B6,$B7
                     DFB $B8,$B9,$BA,$BB
                     DFB $BC,$BD,$BE,$BF
                     DFB $C0,$C1,$C2,$C3
                     DFB $C4,$C5,$C6
                     DFB $C7
                     DFB $C8,$C9; \1
                     DFB $E0;             9 MATHS TOKENS
                     DFB $E1,$E2,$E3,$E4
                     DFB $E5,$E6,$E7,$E8

LASTOP               EQU .-TOKEN

BN2DEC               LDY #4
BOOOP                LDX #0
BOOP                 LDA TEMP2
                     SEC:SBC TAB3,Y
                     STA TEMP2
                     LDA TEMP3
                     SBC TAB2,Y
                     BCC ADD01
                     STA TEMP3
                     INX:BNE BOOP
ADD01                LDA TEMP2
                     CLC:ADC TAB3,Y
                     STA TEMP2
                     TXA:CLC:ADC #$30:STA NBUF,Y
                     DEY:BNE BOOOP
                     LDA TEMP2:CLC:ADC #$30:STA NBUF,Y
                     LDA #$20:LDX #6
CLAS                 STA ASCIIBR+1,X:DEX:BPL CLAS
                     LDY #4:LDX #0:STX TEMP2
ALOOP                LDA NBUF,Y
                     BIT TEMP2:BMI PRTIT
                     CPY #0:BEQ PRTIT
                     CMP #$30:BEQ NPRTIT
                     DEC TEMP2
PRTIT                STA ASCIIBR+1,X
NPRTIT               INX:DEY:BPL ALOOP
                     RTS
BN2D2                LDX #0
BOP2                 LDA TEMP2
                     SEC:SBC #10
                     STA TEMP2
                     BCC ADD2
                     INX:JMP BOP2
ADD2                 ADC #$30+10
                     STA NBUF
                     TXA:CLC:ADC #$30
                     STA NBUF+1
                     RTS

TAB3                 DFB $00,$0A,$64,$E8,$10
TAB2                 DFB $00,$00,$00,$03,$27

MON
INPUT                EQU $FFCF
CR                   EQU 13
SAVX                 EQU $200
WRAP                 EQU $201
BAD                  EQU $202
YOFF                 EQU $203
MFROM                EQU $FB
KEYBUF               EQU $277
NUMKB                EQU $C6
TX                   EQU 5
TY                   EQU 6
MTEMP                EQU 7
SREG2                EQU $DC0C
TIMALO2              EQU $DC04
TIMAHI2              EQU $DC05
NMIFLG2              EQU $DC0D
CTRLREG2             EQU $DC0E
CONTSC               JSR CHKINSERT
                     JSR CURHOME
                     SEI:LDX #$FF:TXS
                     JSR MINIT
                     LDA #0:STA MRK1
                     JSR CONONL
                     JSR CURON
                     CLI
WCONT                LDA #2:STA $FF00:LDA #0:STA EMPTY
                     STA WRAP:STA YOFF:STA $D0
                     STA MONITR
                     JSR RDOC
                     LDX LASTBD:BMI WCONT
                     JSR CUROF
                     JSR SKIPSP
                     JSR CONVTA
                     JSR DOCSC
                     JSR CURON
                     JMP WCONT

CONVTA               CMP #32:BCS NOCONVTA
                     ORA #$40
NOCONVTA             RTS

DOCSC                LDX #NUMCOMMANDS
NCSC                 CMP COMMANDTABLE,X
                     BEQ GOTCSC
                     DEX:BPL NCSC
                     RTS

GOTCSC               TXA:ASL :TAX
                     LDA COMMANDADR+1,X
                     PHA
                     LDA COMMANDADR,X
                     PHA
                     RTS

COMMANDTABLE         DFM "VFLS@$NXTEDHJR:"
NUMCOMMANDS          EQU .-COMMANDTABLE

COMMANDADR           DFW MYVIEW-1
                     DFW MYFIND-1
                     DFW LOAD2-1
                     DFW MSAVE2-1
                     DFW DOS-1
                     DFW LOADDIR2-1
                     DFW CHNAME-1
                     DFW XCOM-1
                     DFW TABLE2-1
                     DFW EVALX-1
                     DFW DISSAS-1
                     DFW HEXLINE-1
                     DFW JUMPNINT-1
                     DFW READ16K-1
                     DFW WRITE16-1

WRITE16
;NOW IN BUF1
                     SEI
                     JSR CONVBUF
                     LDY #1
                     JSR GETHEX1:BCS FINISHED
                     STA ACC1+1
                     JSR GETHEX1:BCS FINISHED
                     STA ACC1
                     LDX #15
GET1BYTE             LDA ACC1+1:JSR WRITEADHI
                     LDA ACC1+1:JSR WRITEADHI
                     LDA ACC1:JSR WRITEADLO
                     LDA ACC1:JSR WRITEADLO
                     INY:JSR GETHEX1
                     BCS FINISHED
                     JSR WRITEBYTE
                     INC ACC1:BNE .+4:INC ACC1+1
                     DEX:BPL GET1BYTE
FINISHED
                     CLI
                     RTS


GETHEX1              JSR GETNIB
                     BCS GHEXOUT
                     ASL :ASL :ASL :ASL 
                     STA ACC
                     JSR GETNIB
                     ORA ACC
GHEXOUT              RTS

GETNIB               LDA BUF1,Y
                     INY
                     CMP #$47:BCS GOUT
                     SUB #$30:BMI GOUT
                     CMP #$0A:BCC GDIG
                     SUB #7
                     CMP #$0A:BCC GOUT
GDIG                 CLC:RTS
GOUT                 SEC:RTS

READ16K              JSR SETADDRESS
                     SEI
                     JSR DELAY
                     LDA #$8000:STA ACC1
                     LDA ^$8000:STA ACC1+1
                     LDY #0
READ1BYTE            LDA ACC:JSR WRITEADLO
                     LDA ACC:JSR WRITEADLO
                     LDA ACC+1:JSR WRITEADHI
                     LDA ACC+1:JSR WRITEADHI
                     JSR READNINC
                     INC ACC:BNE .+4:INC ACC+1
                     STA (ACC1),Y:INY:BNE READ1BYTE
                     INC ACC1+1
                     LDA ACC1+1:CMP ^$C000:BNE READ1BYTE
                     CLI
                     RTS

JUMPNINT             LDA #$7F:STA $DD0D
                     LDA $DD0D
                     LDA #0:JSR OUTPUTBYTE
                     JSR GETPARAMS
                     LDA ACC:JSR WRITEJPLO
                     LDA ACC+1:JMP WRITEJPHI

HEXLINE              JSR SETADDRESS
NEXTHEX              SEI
                     JSR PRINTHEXLINE
                     CLI
                     JSR PRINTBUFFER
                     JSR TESTESCAPE
                     BNE NEXTHEX
                     LDA #0:JMP OUTPUTBYTE

DISSAS               JSR SETADDRESS
NEXTDISAS            SEI
                     JSR dDUMP
                     CLI
                     JSR PRINTBUFFER
                     JSR TESTESCAPE
                     BNE NEXTDISAS
                     LDA #0:JMP OUTPUTBYTE

TESTESCAPE           JSR $FFE4;                READ KEY
                     BEQ TESTESCAPE
                     CMP #27
                     RTS

SETADDRESS           JSR GETPARAMS
                     SEI
                     LDA ACC:STA AD0:JSR WRITEADLO
                     LDA ACC+1:STA AD0+1:JSR WRITEADHI
                     CLI
                     RTS

PRINTBUFFER          JSR CONVBUF
                     LDY #79
TRANSFER             LDA BUF1,Y:STA TEXT-1,Y
                     DEY:BNE TRANSFER
                     LDA #0:STA TEXT+79
                     JSR PRTTEXT
                     LDA #0:STA COLUMN
                     JSR CURDOWM
                     LDA #0:STA COLUMN
                     JSR SETCUR2
                     LDA #0:JSR OUTPUTBYTE
                     RTS

MYTEMPY              DFB 0

GETPARAMS
                     LDY #78:LDA #0
CLRTEXT              STA TEXT,Y
                     LDA #$20
                     DEY:BPL CLRTEXT
                     JSR ENCOD
                     LDA #1:STA PASS
                     TSX:DEX:DEX:STX ERRSP
EV1                  LDA BUF3,Y
                     STA SRCLIN-1,Y
                     DEY
                     BNE EV1
                     STY ERRFLAG
                     SEI
                     LDA $FF00:STA TEMPFF00
                     LDA 0:STA TEMP0
                     LDA #$3E:STA $FF00
                     LDA #$2F:STA $0
                     JSR STARTCALC
                     LDA TEMP0:STA 0
                     LDA TEMPFF00:STA $FF00
                     STY MYTEMPY
                     CLI
                     RTS

TEMP0                DFB 0
TEMPFF00             DFB 0

EVALX
                     JSR GETPARAMS

DISPACC              LDX #1
                     JSR PUTVAL
                     LDA #0:STA TEXT,X
                     JSR PRTTEXT
                     LDA #0:STA COLUMN
                     JMP CURDOWM

PUTVAL               LDA #&$
                     STA TEXT-1,X
                     LDA ACC+1
                     STA TEMP3
                     JSR PRTHEX
                     LDA ACC
                     STA TEMP2
                     JSR PRTHEX
                     LDY #3
                     LDA #$20
PSP1                 STA TEXT,X
                     INX
                     DEY
                     BNE PSP1
                     TXA:PHA
                     JSR BN2DEC
                     STX TEMP3
                     PLA:TAX
                     LDY #0
MV1                  LDA ASCIIBR+1,Y
                     STA TEXT,X
                     INY
                     INX
;    DEC TEMP3
                     CPY #5:BNE MV1
                     BNE MV1
                     RTS

PRTHEX               PHA
                     ROR :ROR 
                     ROR :ROR 
                     JSR PR1H
                     PLA
PR1H                 AND #$0F
                     TAY
                     LDA HEXTAB,Y
                     STA TEXT,X
                     INX
                     RTS

TABLE2               RTS:JSR INITABSER
RESTARTL             LDA #20:STA COUNT
                     JSR SCRCLR
NELAB                JSR MIKE
                     BEQ NOLAB2
                     JSR PRTLAB
                     DEC COUNT
                     BNE NELAB
NOLAB2               JSR GETKEY
                     CMP #3
                     BNE RESTARTL
                     RTS
INITABSER            RTS
PRTLAB               RTS;                          PRTLAB PLUS HEX
MIKE                 LDA #0:RTS

USE8                 LDA #$08:STA DEVICE:RTS

MSAVE2               JSR SKIPSP:LDX #0:LDY YOFF:DEY
                     JMP SAVE2

CHNAME               JSR SKIPSP:LDX #0:LDY YOFF:DEY
STLINS2              LDA BUFFER,Y
                     JSR CONVTA
                     STA MES1,X
                     STA MES2,X
                     STA MES3,X
                     STA MES4,X
                     STA MES5,X
                     INX:INY:CPX #12:BCC STLINS2
                     RTS

DOS                  LDA #0:STA $C6:STA $C7
                     STA $9D
                     JMP GETNEXT

MYVIEW               LDY YOFF:DEY:JSR FINDLAB3
                     CMP #$FF:BNE EXITCS
                     RTS
EXITCS               JSR CLEAN
                     LDX #$FF:TXS
                     JMP MAINLOOP

MYFIND               LDY YOFF:DEY:JSR FINDST
                     BCC EXITCS
                     RTS

MSTART               RTS:JSR CHKINSERT
                     SEI:LDX #$FF:TXS:STX MONITR
                     JSR MINIT
                     JSR CONONL
                     JSR CURON
WMSTART              LDA #2:STA $FF00
                     LDA #0
                     STA WRAP
                     STA YOFF
                     STA $D0
                     JSR RDOC
                     JSR SKIPSP
S0                   LDX #NCMDS-1
                     CMP #$20:BCS CHECKCOM
                     ORA #$40
CHECKCOM             CMP CMDS,X
                     BEQ MVALID:DEX
                     BPL CHECKCOM
ERR1                 LDX #&?
                     LDA #CR
                     JSR PRINTXA
                     JMP WMSTART
SKIPSP               JSR RDOC:CMP #32:BEQ SKIPSP:RTS
MVALID               LDY #$3E:STY $FF00
                     JSR DRUT:CLI
                     JMP WMSTART
DRUT                 CMP #&Z:BEQ NOSEND2:CMP #&X:BEQ NOSEND2;  :JSR OBIB
NOSEND2              TXA:ASL :TAX
                     LDA MADDR+1,X
                     PHA
                     LDA MADDR,X
                     PHA:RTS
cr                   LDA #CR:STA MTEMP
WRITE                CMP #$0D:BEQ DoRETT
                     CMP #$20:BEQ DOPRINT
                     CMP #$2D:BEQ DOPRINT
DOPRINT              PHA:JMP SCRPRIFF
NoPRINT              RTS
DoRETT               JSR ALTB:LDA #0:STA COLUMN:JMP RETURN
ALTB                 LDA #$A0:PHA:JMP SCRPRIFF

RDOC                 TYA:PHA:TXA:PHA
                     LDA WRAP
                     BNE NOOD
RDOC2                JSR SETCUR2
RDOC2L               JSR STATUSP:JSR $FFE4:BEQ RDOC2L
                     CMP #3:BEQ RDOC2L
                     STA MTEMP:AND #$7F
                     CMP #$0D:BEQ GOCR
                     CMP #$1F:BCC CONKEY
GOCR                 PHA:JSR READSCR:PLA:PHA
                     CMP #CR:BNE DoRT:JSR RETURN
                     JMP PASTX
DoRT                 LDA MTEMP:JSR WRITE
PASTX                PLA
                     CMP #CR
                     BNE RDOC2
                     LDA #1:STA WRAP
                     LDA #0:STA YOFF
                     LDX #79
PUTAO                LDA BUFFER,X:AND #$7F:CMP #$20:BNE PUTTI:DEX:BPL PUTAO
PUTTI                STX LASTBD
RET2                 PLA:TAX:PLA:TAY
                     LDA MTEMP:RTS
NOOD                 LDY YOFF:CPY LASTBD:BEQ PTUO
                     LDA #0:DFB $2C
PTUO                 LDA #$80:STA EMPTY
                     LDA BUFFER,Y
                     CMP #$A0:BNE ADBUF
                     STA MTEMP
                     LDA #0:STA WRAP
                     JMP RET2
ADBUF                STA MTEMP:INC YOFF
                     JMP RET2
PISH                 LDX #$FF:TXS
                     JSR cr
                     JMP WMSTART
CONKEY               JSR CONKEY2:JMP RDOC2
CONKEY2              LDX #CONWRD-CONTAB
                     LDA MTEMP
KEYLOP               CMP CONTAB,X
                     BEQ GOTCON
                     DEX:BPL KEYLOP
                     LDA #0:STA WRAP:STA YOFF:LDA #0:STA EMPTY
                     RTS
GOTCON               TXA:ASL :TAX
                     LDA CONWRD+1,X
                     PHA
                     LDA CONWRD,X
                     PHA
                     RTS
CONTAB               DFB $11,$91,$1D,$9D,$14
                     DFB $94,$93,$13
CONWRD               DFW CURDOWM-1,CURUPM-1
                     DFW CURRIGHT-1,CURLEFT-1
                     DFW DEL-1,INST-1,SCRCLR-1
                     DFW CURHOMM-1
LASTBD               DFB 0
EMPTY                DFB 0
CURDOWM              LDY LINE
                     CPY #23
                     BCS ONBOT
                     INY:STY LINE
                     JSR READSCR
                     JMP SETCUR2
CURUPM               LDY LINE
                     CPY #0
                     BEQ ATTOP
                     DEY:STY LINE
                     JSR READSCR
                     JMP SETCUR2
ONBOT                JSR SCROLL
                     LDA #0:STA COLUMN
ATTOP                RTS

CURHOMM              LDA #0:STA COLUMN:STA LINE:JMP SETCUR2
CMDS                 DFM "TX"
NCMDS                EQU .-CMDS
MADDR
                     DFW TEST
;     DFW LOAD-1
;    DFW SAVE-1
;   DFW MCOPY-1
;       DFW DISPREG-1
;      DFW DISPREG-1
                     DFW ZEUS-1


GETKEY               LDX $D4
                     CPX #$58:BEQ GETKEY
                     CPX #$3F:BNE RET
                     LDA #$03
RET                  RTS

TEST

ZEUS                 JSR CLEAN

                     LDX #$FF:TXS
                     LDA #0:STA $D0
                     STA KEYPRESS
                     STA CHANGE
                     JSR LIST2A
                     JMP MAINLOOP

XCOM                 JSR CLEAN
                     LDX #$FF:TXS
                     LDA #0:STA $D0
                     STA KEYPRESS
                     STA CHANGE
                     JSR LIST2A
                     JMP MAINLOOP

PRINTXA              PHA
                     TXA:JSR WRITE
                     PLA
                     JMP WRITE
MINIT                SEI
MINIT2               LDA #$7F
                     STA $DC0D
                     LDA $DC0D
                     LDA #$08
                     STA $DC0E
                     STA $DC0F
                     LDX #0
                     STX $DC03
                     DEX
                     STX $DC02
                     LDX #$3F
                     LDA #7
                     LDA #2
                     LDA #0
                     LDA #$31
                     STA CTRLREG2
                     RTS
CONONL               JSR SCRCLR
                     LDA #0:STA LINE
                     STA COLUMN
                     RTS

TEMPIR               DFB 0
TEMPIR1              DFB 0

CLEAN                LDX #$81:STX CTRLREG2
                     CLI:RTS


STRI                 JMP STRINGH
ASSEMBLER            LDA KEYPRESS
                     CMP #1
                     BNE STRI
                     JSR CHKINSERT
                     LDA LINE:JSR FINDTOP
                     JSR SCRCLR
                     LDA #$3F:STA $FF00
                     LDA #0:STA CHANGE
                     STA KEYPRESS
                     JSR ASSEMB
                     TAX:LDY MESS,X:TYA
                     PHA
                     LDA #0:JSR SETCUR
                     PLA:TAY:PHA
PRMES                LDA ASSMES,Y
                     CMP #$FF:BEQ FIND
                     JSR SCRPRINT
                     INY
                     JMP PRMES
FIND                 LDA #2:STA $FF00
                     JSR WAITFK
                     JSR CURHOMM
                     PLA:BEQ NER
                     JSR GETLADD
NER                  LDA #$16:STA XTEMP2A
                     JSR RETURN
                     JMP LIST2A
WAITFK               JSR RETURN:JSR CURON
WAITFK1              JSR $FFE4:BEQ WAITFK1
                     JMP CUROF
MESS                 DFB assmes1-ASSMES,assmes2-ASSMES,assmes3-ASSMES,assmes4-ASSMES
                     DFB assmes5-ASSMES,assmes6-ASSMES,assmes7-ASSMES,assmes8-ASSMES
ASSMES
assmes1              DFM "ASSEMBLY COMPLETE.":DFB $FF
assmes2              DFM "GARBAGE IN EXPRESSION":DFB $FF
assmes3              DFM "DEFINE THE LABEL BEFORE YOU USE IT WALLY":DFB $FF
assmes4              DFM "I'VE FOUND A NUMBER THATS TOO BIG":DFB $FF
assmes5              DFM "YOU'VE USED THIS LABEL BEFORE YOU WALLY":DFB $FF
assmes6              DFM "ABSOLUTE GARBAGE":DFB $FF
assmes7              DFM "CRAP LABEL":DFB $FF
assmes8              DFM "CAN'T JUMP THIS FAR":DFB $FF

CHKIN                EQU $FFC6
CHKOUT               EQU $FFC9
CHRIN                EQU $FFCF
OPEN                 EQU $FFC0
CLOSE                EQU $FFC3
SETNAM               EQU $FFBD
SETLFS               EQU $FFBA
SAVE3                EQU $FFD8
INFO                 EQU DIR
TXTTAB               EQU $84
DEVICE               DFB 8
COLoR                DFB 15
CURTYPE              DFB $40
DOSCOM

GETNEXT              LDA #0:STA CMDLEN
                     BIT EMPTY:BMI SENDBUF
                     JSR SKIPSP
                     JSR CONVTA:STA NAME3
                     LDY #1:STY CMDLEN
READBUF              BIT EMPTY:BMI SENDBUF:JSR RDOC
                     JSR CONVTA
                     STA NAME3,Y:INY
                     STY CMDLEN
                     JMP READBUF
SENDBUF              LDX #3:JSR SETUPN
READE                LDA #15
                     LDX DEVICE
                     LDY #15
                     JSR SETLFS
                     JSR OPEN
                     JSR GETErr
                     JMP EXITFIN

STRI2                JMP STRINGH

SAVRENA              LDA KEYPRESS:CMP #$A4
                     BNE STRI2
                     JSR SCRCLR
                     LDA #0:STA CHANGE
                     STA KEYPRESS:STA $D0
                     LDA #1:STA $C6
                     LDX #0:STX $C7
                     JSR SETUPN
                     LDA #4
                     LDX DEVICE
                     LDY #4
                     JSR SETLFS
                     JSR OPEN
                     LDA #4
                     JSR CLOSE
                     LDA #0
                     JSR SETNAM
                     LDA #15
                     LDX DEVICE
                     LDY #15
                     JSR SETLFS
                     JSR OPEN
                     JSR GETErr
                     JSR FINER
                     JSR WAITFK
                     JMP LIST2A
GETErr
                     LDX #15:JSR CHKIN
                     LDY #40:LDX #0
GETTER               STX TX:JSR CHRIN:BEQ FINE2:LDX TX
                     STA INFO,X:INX
                     PHA:CMP #$0D:BNE SCPTON:JSR RETURN:JMP DONTPR
SCPTON               STX TX:JSR SCRPRINT:LDX TX
DONTPR               PLA:CMP #13:BEQ FINE2
                     DEY:BPL GETTER
FINE2                LDA #15:JMP CLOSE

FINER                LDA INFO
                     CMP #$30:BNE NRENE
                     LDA #15:JSR CLOSE
                     LDX #2
                     JSR SETUPN
                     JSR OPEN
                     LDA #15:JSR CLOSE
                     LDX #1
                     JSR SETUPN
                     JSR OPEN
                     JSR GETErr
                     LDA INFO
                     CMP #$30
                     BNE AbO
NRENE                LDA #15:JSR CLOSE
                     LDX #0:JSR SETUPN
                     LDA #1
                     STA TXTTAB
                     LDA #4
                     STA TXTTAB+1
                     LDY SoRTOP+1
                     LDX SoRTOP
                     LDA #TXTTAB
                     SEI:JSR SAVE3:CLI
                     LDY #15
SETSTL               LDA MES1,Y
                     STA MES5,Y
                     DEY:BPL SETSTL
AbO                  JMP EXITFIN
SETUPN               LDA MESLEN,X
                     PHA:TXA:ASL :TAX
                     LDY ADRE+1,X
                     LDA ADRE,X
                     TAX:PLA
                     JMP SETNAM
ADRE                 DFW NAME,NAME1,NAME2,NAME3
NAME                 DFM "0:"
MES1                 DFM "EDAS V1.8   .SRC"
NAME1                DFM "R0:"
MES2                 DFM "EDAS V1.8   .BAK="
MES3                 DFM "EDAS V1.8   .SRC"
NAME2                DFM "S0:"
MES4                 DFM "EDAS V1.8   .BAK
NAME3                DFS 80,$20
MESLEN               DFB NAME1-NAME,NAME2-NAME1,NAME3-NAME2
CMDLEN               DFB 0
;******************************************************************************
;*************************   ASSEMBLER START **********************************

SRCEND
CHARA1               EQU SRCLIN

;ZERO-PAGE-VARS
BDR                  EQU $D020

V                    EQU 200
ACC                  EQU V+0
NEXTFREE             EQU V+2
STACKP               EQU V+4
ERRSP                EQU V+5
ACC1                 EQU V+6
PROD                 EQU V+8
TEMP1A               EQU V+10
TEMP2A               EQU V+11
TEMP3A               EQU V+12
TEMP4A               EQU V+13
SEARCHAD             EQU V+14
PASS                 EQU V+16
CURRENT              EQU $88
RUN                  EQU V+17
SEARCHY              EQU V+19
LD                   EQU V+20
OPCOD                EQU V+22
PC                   EQU V+23
TEMPY                EQU V+25
TEMPD                EQU V+26
COMD                 EQU V+27
ERRFLAG              EQU ZP+28

SOURCE               EQU $0401


ASSEMB               SEI
                     LDA #$3E:STA $FF00
                     LDA #$2F:STA $0
                     LDA #$73
                     STA $1
                     LDA #$7F:STA $DD0D
                     LDA $DD0D
                     LDA #$00:STA $DD03
                     TSX
                     STX ERRSP
                     LDA #$3F
                     STA $FF00
                     JSR INITLABLE
                     LDA #0
                     STA RUN
                     STA RUN+1
                     LDA #1
                     STA COMD
                     LDA #%00100000
                     STA PASS
PASSLOOP             LDA #SOURCE
                     STA CURRENT
                     LDA ^SOURCE
                     STA CURRENT+1
                     LDA #0:STA OUTPUT
                     STA FINFLAG
LINELOOP             JSR GETLINE;   DOES CMP #$FF
                     BEQ ISEND
NOTEND               LDY #0
MULTILINE            LDA #0
                     STA SEARCHY
                     LDA SRCLIN,Y
                     BMI OPCODLP
                     BEQ LINELOOP
                     CMP #$3B
                     BEQ LINELOOP
                     JSR GETLABLEN
                     JSR PUTLABLE
NOLAB                LDA SRCLIN,Y
                     BMI OPCODLP
                     BEQ LINELOOP
                     CMP #$3B
                     BEQ LINELOOP
                     INY
                     CMP #$3A
                     BEQ MULTILINE
                     CMP #$20
                     BEQ NOLAB
SYNTAX2              JMP SYNTAX
OPCODLP              JSR DOOPCODE
                     LDA FINFLAG:BNE ISEND
                     LDA SRCLIN-1,Y
                     CMP #$3B:BEQ LINELOOP
                     LDA SRCLIN,Y
                     BEQ LINELOOP
                     CMP #$3B
                     BEQ LINELOOP
                     CMP #$3A:BNE SYNTAX2
MULTLINE1            INY
                     JMP MULTILINE

ISEND                ASL PASS
                     BPL PASSPAP
PASSPAP              BCC PASSLOOP

                     LDA #0
                     JMP ETRAP

ISINDIRT             INY
                     JSR STARTCALC
                     BEQ INDOK
                     CMP #9
                     BEQ ISINDIR
                     CMP #$4
                     BCC ADDERR
INDOK                CLC
                     RTS
ISINDIR              LDA #9
                     CLC
                     RTS

GETADM0              INY
GETADMD              LDA SRCLIN,Y
                     BEQ ISACC2
                     CMP #$20
                     BEQ GETADM0
                     CMP #'#
                     BEQ ISIMED
                     CMP #$5E; '^
                     BEQ ISHIIM
                     CMP #'(
                     BEQ ISINDIRT
;IS-DIRECT OR ACCUM

                     CMP #$3B;;
                     BEQ ISACC2
                     CMP #$3A;:
                     BEQ ISACC2
                     CMP #$41;'A
                     BNE ISDIRECT
                     LDA SRCLIN+1,Y
                     BEQ ISACC1
                     CLC
                     CMP #$3B;;
                     BEQ ISACC1
                     CMP #$3A;:
                     BNE ISDIRECT
ISACC1               INY
ISACC2               LDA #8
                     RTS

ISDIRECT
                     JSR STARTCALC
                     BMI ADDERR
                     BEQ ADDERR
                     CMP #%100
                     BEQ ADDERR
                     RTS

ISIMED               INY
                     JSR STARTCALC
                     BMI ADDERR
                     CMP #%011;DIRECT
                     BNE ADDERR
                     LDA #%010;IMEDIATE
                     RTS

ISHIIM               INY
                     JSR STARTCALC
                     BMI ADDERR
                     CMP #%011
                     BNE ADDERR
                     LDA ACC+1
                     STA ACC
                     LDA #%010
                     RTS

ADDERR               JMP SYNTAX


;LABLE-TABLE-BITS

;LABLE-STORED AS
;FIRST-BYTE IS LENGTH+2
;NEXT-ARE-NAME LESS FIRST CHAR
;NEXT-2-ARE-VALUE
;NEXT-2-ARE-POINTER

INITLABLE            LDA #AEND
                     STA NEXTFREE
                     LDA ^AEND
                     STA NEXTFREE+1
                     LDA #0
                     LDX #26*9+1
CLLABADS             STA LABADS-1,X
                     STA LABADS+26*9-1,X
                     STA LABADS2-1,X
                     STA LABADS2+26*9-1,X
                     DEX
                     BNE CLLABADS
                     RTS

PUTLABLE             JSR LSEARCH
                     BCS PUTLAB1
                     LDA PASS
                     CMP #%00100000
                     BNE .+5:JMP REDERR
                     LDY SEARCHY
                     LDA PC
                     STA (SEARCHAD),Y
                     INY
                     LDA PC+1
                     STA (SEARCHAD),Y
                     JMP DUNPUTPC
PUTLAB1              DFB $AF
                     DFW NEXTFREE;        LAX LAB
                     STA (SEARCHAD),Y
                     LDA NEXTFREE+1
                     INY
                     STA (SEARCHAD),Y
                     STA SEARCHAD+1
                     STX SEARCHAD
                     LDY #0
                     LDA TEMP3A;     LABLEN
                     STA (SEARCHAD),Y
                     INY
                     SEC:SBC #3
                     STA TEMP2A
                     BEQ DUNPUT
                     LDX TEMPY
PUTL1                LDA SRCLIN+1,X
                     STA (SEARCHAD),Y
                     INY
                     INX
                     DEC TEMP2A
                     BNE PUTL1
DUNPUT               LDA PC
                     STA (SEARCHAD),Y
                     STY SEARCHY
                     INY
                     LDA PC+1
                     STA (SEARCHAD),Y
                     INY
                     LDA #0
                     STA (SEARCHAD),Y
                     INY
                     STA (SEARCHAD),Y
                     INY
                     TYA
                     CLC
                     ADC SEARCHAD
                     STA NEXTFREE
                     LDA #0
                     ADC SEARCHAD+1
                     STA NEXTFREE+1
DUNPUTPC             LDA TEMPY
                     CLC:ADC TEMP3A
                     SEC:SBC #2
                     TAY
                     RTS

LSEARCH
                     LDA #LABADS
                     STA SEARCHAD
                     LDA ^LABADS
                     STA SEARCHAD+1
                     LDA SRCLIN,Y
                     SEC:SBC #$41
                     CMP #26
                     BCC ISUC
                     SBC #$20
                     BPL .+5:JMP BADLABERR
                     CMP #26
                     BCC .+5:JMP BADLABERR
                     LDX #LABADS2
                     STX SEARCHAD
                     LDX ^LABADS2
                     STX SEARCHAD+1
ISUC                 LDX TEMP3A
                     CPX #12
                     BCC .+4:LDX #11
                     CLC
                     ADC LX26-3,X
                     ASL 
                     PHP
                     CLC
                     ADC SEARCHAD
                     STA SEARCHAD
                     LDA #0
                     TAY
                     ROL 
                     PLP
                     ADC SEARCHAD+1
                     STA SEARCHAD+1
                     JMP NEXTLAB

NOTFOUND             LDY #0
                     LDA (SEARCHAD),Y
                     TAY
NEXTLAB;      DFB $B3,SEARCHAD;     LAX (),Y
                     LDA (SEARCHAD),Y:TAX
                     INY
                     ORA (SEARCHAD),Y
                     BEQ NOTDEF
                     LDA (SEARCHAD),Y
                     STA SEARCHAD+1
                     STX SEARCHAD
                     LDY #0
                     LDA (SEARCHAD),Y
                     CMP TEMP3A
                     BNE NOTFOUND
                     INY
                     SBC #3; CARRY ALWAYS SET
                     STA TEMP2A
                     BEQ GOTLAB
                     LDX TEMPY
CHECKLAB             LDA SRCLIN+1,X
                     CMP (SEARCHAD),Y
                     BNE NOTFOUND
                     INX
                     INY
                     DEC TEMP2A
                     BNE CHECKLAB
GOTLAB               LDA (SEARCHAD),Y
                     STA ACC
                     STY SEARCHY
                     INY
                     LDA (SEARCHAD),Y
                     STA ACC+1
TIDYY                LDA TEMPY
                     CLC
                     ADC TEMP3A;LAB LEN
                     SBC #1
                     TAY
                     CLC
                     RTS

LX26                 DFB 0,26
                     DFB 2*26
                     DFB 3*26
                     DFB 4*26
                     DFB 5*26
                     DFB 6*26
                     DFB 7*26
                     DFB 8*26
                     DFB 9*26

NOTDEF               DEY
                     LDA #0
                     STA ACC
                     STA ACC+1
                     SEC
                     RTS

GETLABLEN            LDA #$01
                     STY TEMPY
                     STA TEMP3A
GETL1
                     INC TEMP3A
                     LDX SRCLIN,Y
                     BMI GOTLEN
                     INY
                     CPX #$3C
                     BCS GETL1
                     LDA GLTAB,X
                     BPL GETL1
GOTLEN               LDY TEMPY
                     LDA TEMP3A
                     RTS

GLTAB                DFB $80
                     DFS $1F,0
                     DFB $80,0,$80
                     DFS 5,0
                     DFB $80,$80,$80,$80,$80
                     DFB $80,$00,$80
                     DFS $0A,0
                     DFB $80,$80

STARTCALC            LDX #0
                     STX STACKP

;
GETEXPR              JSR DOPR2
                     JSR STACKNUM
REENT                LDA SRCLIN,Y
                     LDX #NPR2-1
GETE1                CMP PR2TAB,X
                     BEQ GOTETYPE
                     DEX
                     BPL GETE1
                     JMP ERR
GOTETYPE             INY
                     TXA:ASL :TAX
                     LDA PR2ADD+1,X
                     PHA
                     LDA PR2ADD,X
                     PHA
                     TXA:LSR :TAX
                     RTS

DOPR2                JSR GETNUM
REENT2               LDA SRCLIN,Y
                     BNE .+3:RTS
                     CMP #$20
                     BNE .+6:INY:JMP REENT2
                     CMP #'*
                     BEQ ISPR2
                     CMP #$E7
                     BNE NOTPR2
                     INY
                     JSR dIVNUM
                     JMP REENT2
NOTPR2               RTS
ISPR2                INY
                     JSR MULTI
                     JMP REENT2

ERR
GOTEND               JMP ERRINEXP

;
MULTI                JSR STACKNUM
                     JSR GETNUM
                     JSR UNSTACK1
                     JSR MULTIPLY
                     RTS

MULTIPLY
;MULTIPLY ACC BY ACC1

                     LDA #0
                     STA PROD
                     STA PROD+1
                     LDX #17
                     CLC
MULLP                ROR  PROD+1
                     ROR  PROD
                     ROR  ACC+1
                     ROR  ACC
                     BCC DECNT
                     CLC
                     LDA ACC1
                     ADC PROD
                     STA PROD
                     LDA ACC1+1
                     ADC PROD+1
                     STA PROD+1
DECNT                DEX
                     BNE MULLP
                     RTS



dIVNUM               JSR STACKNUM
                     JSR GETNUM
                     JSR UNSTACK1;GET DIVID

;DIVIDEND-IN ACC1 (4 BYTES)
;DIVISOR-IN ACC

                     LDA ACC
                     ORA ACC+1
                     BNE NOTDBZ
                     JMP ERR
NOTDBZ               LDA #0
                     STA ACC1+2
                     STA ACC1+3
                     TYA
                     PHA
                     LDX #16
div1                 ROL ACC1
                     ROL  ACC1+1
                     ROL  ACC1+2
                     ROL  ACC1+3
                     SEC
                     LDA ACC1+2
                     SBC ACC
                     TAY
                     LDA ACC1+3
                     SBC ACC+1
                     BCC DECCNT
                     STY ACC1+2
                     STA ACC1+3
DECCNT               DEX
                     BNE div1
                     ROL  ACC1
                     ROL  ACC1+1
                     PLA
                     TAY

                     LDA ACC1
                     STA ACC
                     LDA ACC1+1
                     STA ACC+1
                     RTS

ADDQ                 JSR DOPR2
DOADD                LDX STACKP
                     LDA ACC
                     CLC
                     ADC CALCSTACK-2,X
                     STA CALCSTACK-2,X
                     STA ACC
                     LDA ACC+1
                     ADC CALCSTACK-1,X
                     STA CALCSTACK-1,X
                     STA ACC+1
                     JMP REENT

SUBQ                 JSR DOPR2
DOSUB                LDX STACKP
                     LDA CALCSTACK-2,X
                     SEC
                     SBC ACC
                     STA CALCSTACK-2,X
                     STA ACC
                     LDA CALCSTACK-1,X
                     SBC ACC+1
                     STA CALCSTACK-1,X
                     STA ACC+1
                     JMP REENT

aNDNUM               JSR DOPR2
                     LDX STACKP
                     LDA CALCSTACK-2,X
                     AND ACC
                     STA CALCSTACK-2,X
                     STA ACC
                     LDA CALCSTACK-1,X
                     AND ACC+1
                     STA CALCSTACK-1,X
                     STA ACC+1
                     JMP REENT

oRNUM                JSR DOPR2
                     LDX STACKP
                     LDA CALCSTACK-2,X
                     ORA ACC
                     STA CALCSTACK-2,X
                     STA ACC
                     LDA CALCSTACK-1,X
                     ORA ACC+1
                     STA CALCSTACK-1,X
                     STA ACC+1
                     JMP REENT


GOTNUM1              DEY
GOTNUM               LDA RETVAL,X
                     CLC
                     RTS



STACKNUM             LDX STACKP
                     LDA ACC
                     STA CALCSTACK,X
                     LDA ACC+1
                     STA CALCSTACK+1,X
                     INC STACKP
                     INC STACKP
                     RTS

STACKNUM1            LDX STACKP
                     LDA ACC1
                     STA CALCSTACK,X
                     LDA ACC1+1
                     STA CALCSTACK+1,X
                     INC STACKP
                     INC STACKP
                     RTS

UNSTACK              DEC STACKP
                     DEC STACKP
                     LDX STACKP
                     LDA CALCSTACK,X
                     STA ACC
                     LDA CALCSTACK+1,X
                     STA ACC+1
                     RTS

UNSTACK1             DEC STACKP
                     DEC STACKP
                     LDX STACKP
                     LDA CALCSTACK,X
                     STA ACC1
                     LDA CALCSTACK+1,X
                     STA ACC1+1
                     RTS



GETNUM               LDA SRCLIN,Y
                     LDX #NPR1-1
GETN1                CMP PR1TAB,X
                     BEQ GOTTYPE
                     DEX
                     BPL GETN1

SKSP                 LDA SRCLIN,Y
                     CMP #$20
                     BNE .+6:INY:JMP SKSP
                     JSR GETDIG
                     BCS NOTDEC1
                     CMP #$0A
                     BCS NOTDEC
                     STA ACC
                     LDA #0
                     STA ACC+1
GETDEC               JSR GETDIG
                     BCS GOTDEC1
                     CMP #$0A
                     BCS GOTDEC
                     PHA
                     ASL  ACC
                     ROL  ACC+1
                     LDA ACC
                     LDX ACC+1
                     ASL  ACC
                     ROL  ACC+1
                     ASL  ACC
                     ROL  ACC+1
                     CLC
                     ADC ACC
                     STA ACC
                     TXA
                     ADC ACC+1
                     STA ACC+1
                     PLA
                     CLC
                     ADC ACC
                     STA ACC
                     BCC .+4:INC ACC+1
                     JMP GETDEC
GOTDEC               DEY
GOTDEC1              RTS
NOTDEC               DEY
NOTDEC1

;MUST-BE-LABLE IF GOT TO HERE

                     JSR GETLABLEN
                     JSR LSEARCH
                     BCC ISDEF
                     LDA TEMPY
                     CLC:ADC TEMP3A;LAB LEN
                     SEC:SBC #2
                     TAY
                     LDA PASS
                     CMP #%00100000
                     BEQ ISDEF
                     JMP LABNOTDEF
ISDEF                RTS

GOTTYPE              INY
                     TXA:ASL :TAX
                     LDA PR1ADD+1,X
                     PHA
                     LDA PR1ADD,X
                     PHA
                     RTS


UNMIN                JSR GETNUM
                     LDA ACC
                     EOR #$FF
                     CLC
                     ADC #1
                     STA ACC
                     LDA ACC+1
                     EOR #$FF
                     ADC #0
                     STA ACC+1
                     RTS

TICK                 LDA SRCLIN,Y
                     INY
                     STA ACC
                     LDA #0
                     STA ACC+1
                     RTS

AMPER                LDA SRCLIN,Y
                     INY
                     STA ACC
                     LDA #0
                     STA ACC+1
                     RTS

GETHEX               JSR CLRACC
GETH1                JSR GETDIG
                     BCS GOTHEX
                     ASL  ACC
                     ROL  ACC+1
                     ASL  ACC
                     ROL  ACC+1
                     ASL  ACC
                     ROL ACC+1
                     ASL  ACC
                     ROL  ACC+1
                     ORA ACC
                     STA ACC
                     JMP GETH1
GOTHEX               RTS

CLRACC               LDA #0
                     STA ACC
                     STA ACC+1
                     RTS

GETDIG               LDX SRCLIN,Y
                     BMI NOTHDIG
                     CPX #$30
                     BCC NOTHDIG
                     CPX #71
                     BCS NOTHDIG
                     LDA HEXT-$30,X
                     BMI NOTHDIG
GOTHDIG              INY
                     CLC
                     RTS
NOTHDIG              SEC
                     RTS

HEXT                 DFB 0,1,2,3,4,5,6,7,8
                     DFB 9
                     DFS 7,$80
                     DFB 10,11,12,13,14,15

GETBIN               JSR CLRACC
GETBIN1              LDA SRCLIN,Y
                     SEC
                     SBC #$30
                     BCC GOTBIN
                     LSR A
                     BNE GOTBIN
                     ROL  ACC
                     ROL  ACC+1
                     INY
                     JMP GETBIN1
GOTBIN               RTS

OPENBRAK             JSR GETEXPR
                     DEY
                     LDA SRCLIN,Y
                     INY
                     CMP #$29
                     BEQ EXPOK
                     JMP ERR
EXPOK                JSR UNSTACK
                     RTS

GETPC                LDA PC
                     STA ACC
                     LDA PC+1
                     STA ACC+1
                     RTS

PR1TAB               DFB $28;(
                     DFB $26;&
                     DFB $2B;+
                     DFB $2D;-
                     DFB $25;%
                     DFB ''
                     DFB $2E;.
                     DFB $24;$
NPR1                 EQU .-PR1TAB

PR1ADD               DFW OPENBRAK-1
                     DFW AMPER-1
                     DFW GETNUM-1
                     DFW UNMIN-1
                     DFW GETBIN-1
                     DFW TICK-1
                     DFW GETPC-1
                     DFW GETHEX-1


PR2TAB               DFB $29;)
                     DFB $81;       $E8 ;AND
                     DFB $E8;AND
                     DFB $E5;OR
                     DFB $20;SPACE
                     DFB $3B;;
                     DFB $3A;COLON
                     DFB $E0;X,)
                     DFB $E1;),Y
                     DFB $E2;,X
                     DFB $E3;,Y
                     DFB $2D;-
                     DFB $2B;+
                     DFB $2C;,
                     DFB $00;EOL
NPR2                 EQU .-PR2TAB

RETVAL               DFB 9;)
                     DFB $80;AND
                     DFB $80;AND
                     DFB $80;OR
                     DFB %011;SPACE
                     DFB %011;;
                     DFB %011;COLON
                     DFB %000;,X)
                     DFB %100;),Y
                     DFB %111;,X
                     DFB %110;,Y
                     DFB $80;-
                     DFB $80;+
                     DFB %011;,
                     DFB %011;EOL

PR2ADD               DFW GOTNUM-1;)
                     DFW aNDNUM-1;AND
                     DFW aNDNUM-1;AND
                     DFW oRNUM-1;OR
                     DFW GOTNUM-1;SP
                     DFW GOTNUM-1;;
                     DFW GOTNUM1-1;COLON
                     DFW GOTNUM-1;,X)
                     DFW GOTNUM-1;),Y
                     DFW GOTNUM-1;,X
                     DFW GOTNUM-1;,Y
                     DFW SUBQ-1;-
                     DFW ADDQ-1;+
                     DFW GOTNUM-1;,
                     DFW GOTNUM1-1;EOL


DOOPCODE
                     STY TEMPY
                     AND #$7F
                     CMP #$E0-$80
                     BCC .+5:JMP SYNTAX
                     TAX
ROUTOK1              LDA ROUTS,X
                     BPL RUTOK
                     LDA OPNUM,X
                     LDY TEMPY
                     INY
                     JMP STO1B
RUTOK                TAY
                     LDA OPADS+1,Y
                     PHA
                     LDA OPADS,Y
                     PHA
                     LDA OPNUM,X
                     STA OPCOD
                     LDY TEMPY
                     INY
                     RTS

OPNUM                DFB $01,$21,$41,$61
                     DFB $81,$A1,$C1,$E1

                     DFB $02,$22,$42,$62

                     DFB $86,$A2,$C6,$E6
                     DFB $24,$84,$A0,$C0
                     DFB $E0

                     DFB $4C,$20

                     DFB $00,$08,$18,$28
                     DFB $38,$40,$48,$58
                     DFB $60,$68,$78,$88
                     DFB $8A,$98,$9A,$A8
                     DFB $AA,$B8,$BA,$C8
                     DFB $CA,$D8,$E8,$EA
                     DFB $F8

                     DFB $10,$30,$50,$70
                     DFB $90,$B0,$D0,$F0
                     DFS 11,0
                     DFB $61,$E1

ROUTS                DFS 8,0
                     DFS 4,2
                     DFB 6,8,4,4
                     DFB 12,4,8,10
                     DFB 10,14,14
                     DFS 25,$80
                     DFS 8,16
                     DFB 18,20,22,24
                     DFB 26,28,30,32,34
                     DFB 36,38
                     DFB 40;ADD
                     DFB 42;SUB
                     DFB 44; HEX
                     DFB 46; DFN
                     DFB 48; OUT
                     DFB 50; REG
                     DFB 52; END \1

OPADS                DFW ora-1
                     DFW asl-1
                     DFW dec-1
                     DFW stx-1
                     DFW ldx-1
                     DFW cpx-1
                     DFW bit-1
                     DFW jmp-1
                     DFW bpl-1
                     DFW org-1
                     DFW dfs-1
                     DFW dfb-1
                     DFW dfw-1
                     DFW dfm-1
                     DFW dfh-1
                     DFW dsp-1
                     DFW ent-1
                     DFW equ-1
                     DFW dfc-1
                     DFW dfl-1
                     DFW add-1
                     DFW sub-1
                     DFW hex-1
                     DFW dfn-1
                     DFW out-1
                     DFW reg-1
                     DFW end-1;\1

;OPCODE-ROUTINES

;\1

end                  INC FINFLAG
                     RTS

reg                  JSR STARTCALC
                     CMP #3
                     BNE SYNTAX1
                     LDA ACC+1:BNE SYNTAX1
                     LDA ACC:CMP #4:BCS SYNTAX1
                     ROR :ROR :ROR :ROR ; *32
                     PHA
                     JSR STARTCALC
                     CMP #3:BNE SYNTAX1
                     LDA ACC+1:BNE SYNTAX1
                     LDA ACC:AND #$1F
                     CMP ACC:BNE SYNTAX1
                     LDA #$3E:STA $FF00
                     LDA $DD0D
                     PLA:ORA ACC
                     BIT PASS:BPL .+5
                     JSR WRITEREG
                     JSR DELAY
                     LDA #$3F:STA $FF00
                     RTS

SYNTAX1              JMP SYNTAX

out
                     JSR STARTCALC
                     CMP #3
                     BNE SYNTAX1
                     LDA ACC:ORA ACC+1
                     STA OUTPUT
                     BIT PASS
                     BPL NOCMD3
                     LDA #1:STA COMD
NOCMD3               RTS

hex                  LDA SRCLIN,Y
                     BNE .+3:RTS
                     JSR GETDIG
                     BCC .+3:RTS
                     ASL :ASL :ASL :ASL 
                     STA TEMP1A
                     JSR GETDIG
                     BCC .+5:JMP SYNTAX
                     ORA TEMP1A
                     JSR STO1B
                     JMP hex

dfc                  LDA #$80
                     LDX #$DF
                     JMP dfa
dfm                  LDA #$00
                     LDX #$FF
dfa                  STA TEMP1A
                     STX TEMP3A
                     LDA SRCLIN,Y
                     BNE .+5:JMP SYNTAX
                     INY
                     STA TEMP2A
GET2                 LDA SRCLIN,Y
                     BEQ GOT
                     INY
                     CMP TEMP2A
                     BEQ GOT
                     CMP #$41
                     BCC NOSET
                     ORA TEMP1A
                     AND TEMP3A
NOSET                JSR STO1B
                     JMP GET2
GOT                  RTS

dfn                  LDA SRCLIN,Y:BNE .+5:JMP SYNTAX
                     INY:STA TEMP2A
GET3                 LDA SRCLIN,Y
                     BEQ GOT
                     INY
                     CMP TEMP2A:BEQ GOT
                     CMP #32:BEQ ISSPACE
                     SUB #$3A
                     BMI .+5:SUB #$41-$3A
                     ADD #10
GOTDFN               JSR STO1B
                     JMP GET3

ISSPACE              LDA #40:JMP GOTDFN

dfl                  JSR STARTCALC;GETADMD
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA PR2TAB,X
                     STA TEMP1A
                     LDA ACC
                     JSR STO1B
                     LDA TEMP1A
                     CMP #$2C
                     BEQ dfl
                     RTS

equ                  LDA SEARCHAD:PHA
                     LDA SEARCHAD+1:PHA
                     LDA SEARCHY:PHA
                     JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     STY TEMP1A
                     PLA:TAY
                     PLA:STA SEARCHAD+1
                     PLA:STA SEARCHAD
                     CPY #0
                     BNE .+5:JMP SYNTAX
                     LDA ACC
                     STA (SEARCHAD),Y
                     INY
                     LDA ACC+1
                     STA (SEARCHAD),Y
                     LDY TEMP1A
                     RTS
ent
                     LDA PC
                     STA RUN
                     LDA PC+1
                     STA RUN+1
                     RTS
dfh                  JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA PR2TAB,X
                     STA TEMP1A
                     LDA ACC+1
                     JSR STO1B
                     LDA TEMP1A
                     CMP #$2C
                     BEQ dfh
                     RTS
dfw                  JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA PR2TAB,X
                     STA TEMP1A
                     LDA ACC
                     JSR STO1B
                     LDA ACC+1
                     JSR STO1B
                     LDA TEMP1A
                     CMP #$2C
                     BEQ dfw
                     RTS

dfb                  JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA ACC+1
                     BEQ .+5:JMP ZPEXP
                     LDA PR2TAB,X
                     STA TEMP1A
                     LDA ACC
                     JSR STO1B
                     LDA TEMP1A
                     CMP #$2C
                     BEQ dfb
                     RTS

dfs                  JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA PR2TAB,X
                     CMP #$2C
                     BEQ INMEM
                     LDA ACC
                     CLC:ADC PC
                     STA PC
                     LDA ACC+1
                     ADC PC+1
                     STA PC+1
                     LDA LD
                     CLC:ADC ACC
                     STA LD
                     LDA LD+1
                     ADC ACC+1
                     STA LD+1
                     BIT PASS
                     BPL NOCM
                     LDA #1:STA COMD
NOCM                 RTS
INMEM                LDA ACC
                     STA TEMP1A
                     LDA ACC+1
                     STA TEMP2A
                     JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     BIT PASS
                     BPL NOTP3
                     LDA TEMP1A
                     ORA TEMP2A
                     BEQ FINDFS
                     LDA ACC+1
                     BEQ DECDFS:JMP ZPEXP
LOOP
                     LDA ACC
                     JSR STO1B
DECDFS               DEC TEMP1A
                     LDA TEMP1A:CMP #$FF
                     BNE LOOP
                     DEC TEMP2A
                     LDA TEMP2A:CMP #$FF
                     BNE LOOP
FINDFS               RTS
NOTP3                LDA TEMP1A
                     CLC:ADC PC
                     STA PC
                     LDA TEMP2A
                     ADC PC+1
                     STA PC+1
                     RTS

org                  JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA PR2TAB,X
                     STA TEMP1A
                     LDA ACC
                     STA PC
                     STA LD
                     LDA ACC+1
                     STA PC+1
                     STA LD+1
                     BIT PASS
                     BPL NOCMD2
                     LDA #1:STA COMD
NOCMD2               LDA TEMP1A
                     CMP #$2C
                     BNE GOTRG
dsp                  JSR STARTCALC
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA ACC
                     STA LD
                     LDA ACC+1
                     STA LD+1
GOTRG                RTS

sub                  LDA #$38
                     DFB $2C
add                  LDA #$18
                     JSR STO1B
ora                  JSR GETADMD
                     CMP #8
                     BCC .+5:JMP SYNTAX
                     LDX #1:STX TEMP3A
                     CMP #2
                     BEQ DUNZP1
                     CMP #%110
                     BEQ NOTZP1
                     LDX ACC+1
                     BNE NOTZP1
                     AND #$FD
                     JMP DUNZP1
NOTZP1               CMP #4
                     BNE .+5:JMP SYNTAX
                     CMP #0
                     BNE .+5:JMP SYNTAX
                     INC TEMP3A
DUNZP1               ASL :ASL 
                     ORA OPCOD
                     CMP #$89
                     BNE .+5:JMP SYNTAX
                     JMP STOBYT
asl                  JSR GETADMD
                     LDX #0:STX TEMP3A
                     CMP #8
                     BEQ ISASLA
                     LDX #2:STX TEMP3A
                     TAX
                     LDA LEGASL,X
                     BPL .+5:JMP SYNTAX
                     LDX ACC+1
                     BNE NOTZP2
                     DEC TEMP3A
                     AND #%10100
NOTZP2
                     ORA OPCOD
                     JMP STOBYT
ISASLA               LDA #$08
                     JMP NOTZP2
LEGASL               DFB $FF,$FF,$FF
                     DFB $0C,$FF,$FF
                     DFB $FF,$1C,$08
                     DFB $FF
dec                  JSR GETADMD
                     LDX #2:STX TEMP3A
                     CMP #8
                     BCC .+5:JMP SYNTAX
                     TAX
                     LDA OPCOD
                     LDA LEGDEC,X
                     BPL .+5:JMP SYNTAX
                     LDX ACC+1
                     BNE NOTZP
                     AND #$F7
                     DEC TEMP3A
NOTZP
                     ORA OPCOD
                     CMP #$9C
                     BNE .+5:JMP SYNTAX
                     JMP STOBYT
LEGDEC               DFB $FF,$FF,$FF,$08
                     DFB $FF,$FF,$FF,$18
stx                  JSR GETADMD
                     LDX #2:STX TEMP3A
                     CMP #7
                     BCC .+5:JMP SYNTAX
                     TAX
                     LDA LEGSTX,X
                     BPL .+5:JMP SYNTAX
                     LDX ACC+1
                     BNE NOTZP4
                     AND #%10000
                     DEC TEMP3A
NOTZP4
                     ORA OPCOD
                     CMP #$9E
                     BNE .+5:JMP SYNTAX
                     JMP STOBYT
LEGSTX               DFB $FF,$FF,$FF,$08
                     DFB $FF,$FF,$18
ldx                  JSR GETADMD
                     CMP #8
                     BCC .+5:JMP SYNTAX
                     LDX #2:STX TEMP3A
                     TAX
                     LDA OPCOD
                     CMP #$A0;OPCD FOR LDY
                     BNE NOTX1
                     TXA:CLC:ADC #8
                     TAX
NOTX1                LDA LEGLDX,X
                     BEQ ISIM2
                     BPL .+5:JMP SYNTAX
                     LDX ACC+1
                     BNE NOTZP3
                     AND #%10100
ISIM2                DEC TEMP3A
NOTZP3
                     ORA OPCOD
                     JMP STOBYT
LEGLDX               DFB $FF,$FF,$00,$0C
                     DFB $FF,$FF,$1C,$FF
                     DFB $FF,$FF,$00,$0C
                     DFB $FF,$FF,$FF,$1C
cpx                  JSR GETADMD
                     CMP #4
                     BCC .+5:JMP SYNTAX
                     LDX #2:STX TEMP3A
                     TAX
                     LDA LEGCPX,X
                     BEQ ISIM5
                     BPL .+5:JMP SYNTAX
                     CMP #%1100
                     BNE NOTZP5
                     LDX ACC+1
                     BNE NOTZP5
                     LDA #%100
ISIM5                DEC TEMP3A
NOTZP5
                     ORA OPCOD
                     JMP STOBYT
LEGCPX               DFB $FF,$04,$00,$0C
bit                  JSR GETADMD
                     LDX #2:STX TEMP3A
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     LDA #$08
                     LDX ACC+1
                     BNE NOTZP6
                     LDA #0
                     DEC TEMP3A
NOTZP6
                     ORA OPCOD
                     JMP STOBYT
jmp                  JSR GETADMD
                     TAX
                     LDA #0
                     CPX #3
                     BEQ GOTJUMP
                     LDA #$20
                     CPX #9
                     BEQ .+5:JMP SYNTAX
                     LDX OPCOD
                     CPX #$20
                     BNE .+5:JMP SYNTAX
GOTJUMP              ORA OPCOD
                     LDX #2:STX TEMP3A
                     JMP STOBYT
bpl                  JSR GETADMD
                     CMP #3
                     BEQ .+5:JMP SYNTAX
                     BIT PASS
                     BPL INRANG
                     LDA PC
                     CLC:ADC #2
                     STA TEMP1A
                     LDA PC+1
                     ADC #0
                     STA TEMP2A
                     LDA ACC
                     SEC:SBC TEMP1A
                     STA TEMP1A
                     LDA ACC+1
                     SBC TEMP2A
                     STA TEMP2A
                     BEQ FRWRD
                     INC TEMP2A
                     BNE OUTRANG
                     LDA TEMP1A
                     BPL OUTRANG
                     STA ACC
                     JMP INRANG
FRWRD                LDA TEMP1A
                     BMI OUTRANG
                     STA ACC
INRANG               LDX #1
                     STX TEMP3A
                     LDA OPCOD
                     JMP STOBYT

ERRINEXP             LDA #1:DFB $2C
LABNOTDEF            LDA #2:DFB $2C
ZPEXP                LDA #3:DFB $2C
REDERR               LDA #4:DFB $2C
SYNTAX               LDA #5:DFB $2C
BADLABERR            LDA #6:DFB $2C
OUTRANG              LDA #7
                     LDX #0:STX RUN
                     STX RUN+1
                     DEC ERRFLAG
ETRAP
                     STY TEMPY
                     LDX ERRSP
                     TXS
                     PHA
                     LDA #$3E:STA $FF00
                     LDX #$FF:LDY #$FF
SENDEND              LDA OUTPUT:BEQ NOSEND
                     LDA RUN+1:ORA RUN
                     BEQ NOSEND
                     LDA RUN:JSR WRITEJPLO
                     LDA RUN+1:JSR WRITEJPHI
NOSEND               PLA
                     LDY TEMPY
                     CLI
                     RTS

STOBYT               STY TEMP4A
                     LDY #0
                     JSR STB1
                     LDX TEMP3A
                     DEX
                     BMI DONST
STOL                 LDA ACC
                     JSR STB1
                     DEX
                     BMI DONST
                     LDA ACC+1
                     JSR STB1
DONST                LDY TEMP4A
                     RTS
STO1B                STY TEMP4A
                     LDY #0
                     JSR STB1
                     LDY TEMP4A
                     RTS
STB1                 BIT PASS
                     BPL NOSTO
                     STX TEMPD
                     LDX OUTPUT:BNE TONINTENDO
                     STA (LD),Y
                     JMP DONESTORE
TONINTENDO           LDX #$3E:STX $FF00
                     LDX COMD
                     BEQ NOTNEWADD
                     PHA
                     LDA #0:JSR OUTPUTBYTE
                     LDA #$0:JSR OUTPUTBYTE
                     LDA LD:JSR WRITEADLO
                     LDA LD+1:JSR WRITEADHI
                     PLA
NOTNEWADD            JSR WRITENINC
                     LDA #$3F:STA $FF00
DONESTORE            LDA #0:STA COMD
                     INC LD
                     BNE .+4:INC LD+1
                     LDX TEMPD
NOSTO                INC PC
                     BNE .+4:INC PC+1
                     RTS

WRITEREG             JSR OUTNIBLE
                     ORA #$B0:BNE OUTPUTBYTE
WRITEADLO            JSR OUTNIBLE
                     ORA #$10:BNE OUTPUTBYTE
WRITEADHI            JSR OUTNIBLE
                     ORA #$20:BNE OUTPUTBYTE
WRITENINC            JSR OUTNIBLE
                     ORA #$30:BNE WRITEONE
WRITEBYTE            JSR OUTNIBLE
                     ORA #$40
WRITEONE             JSR OUTPUTBYTE
                     LDA #10
WRITEDEL             SUB #1:BNE WRITEDEL
                     RTS
READNINC             JSR OUTNIBLE
                     ORA #$50:JSR OUTPUTBYTE
                     JMP INPUTBYTE
READBYTE             JSR OUTNIBLE
                     ORA #$60:JSR OUTPUTBYTE
                     JMP INPUTBYTE
WRITEJPLO            JSR OUTNIBLE
                     ORA #$70:BNE OUTPUTBYTE
WRITEJPHI            JSR OUTNIBLE
                     ORA #$80:BNE OUTPUTBYTE
OUTNIBLE             PHA
                     AND #$0F:JSR OUTPUTBYTE
                     PLA
                     LSR :LSR :LSR :LSR 
                     RTS

OUTPUTBYTE           PHA
                     LDA #$FF:STA $DD03;     PORT=OUTPUT
                     PLA:STA $DD01
WAITPUT              LDA $DD0D:AND #$10:BEQ WAITPUT
                     LDA #0:STA $DD03;       INPUT AGAIN
                     RTS

INPUTBYTE            JSR DELAY
INPWAIT              LDA $DD0D
                     AND #$10
                     BEQ INPWAIT
                     LDA $DD01

DELAY                PHA:LDA #5
DEL1                 SUB #1:BNE DEL1
                     PLA
                     RTS

FINDLEN              EQU $28; COMMON VAR


AD0                  EQU $AC;2
XC                   EQU $14
W1                   EQU $15
W2                   EQU $16
YINDX                EQU $17

WSP                  EQU 12
NL                   EQU 13
NH                   EQU 14
PFL                  EQU 15
dad                  EQU $18;3

PDECTAB              DFW 10000,1000,100,10

MNEM0                DFM "AAABBBBBBBBBBCCC"
                     DFM "CCCCDDDEIIIJJLLL"
                     DFM "LNOPPPPRRRRSSSSS"
                     DFM "SSTTTTTT "

MNEM1                DFM "DNSCCEIMNPRVVLLL"
                     DFM "LMPPEEEONNNMSDDD"
                     DFM "SORHHLLOOTTBEEET"
                     DFM "TTAASXXY "

MNEM2                DFM "CDLCSQTIELKCSCDI"
                     DFM "VPXYCXYRCXYPRAXY"
                     DFM "RPAAPAPLRISCCDIA"
                     DFM "XYXYXASA "
;table0.00-3F
DT0                  DFB 41,138,225,225,225
                     DFB 138,10,225,145,138
                     DFB 9,225,225,139,11
                     DFB 225,38,138,225,225
                     DFB 225,138,10,225,53
                     DFB 139,225,225,225,139
                     DFB 11,225,115,6,225
                     DFB 225,26,6,158,225
                     DFB 153,6,157,225,27
                     DFB 7,159,225,30,6
                     DFB 225,225,225,6,158
                     DFB 225,177,7,225,225
                     DFB 225,7,159,225
;table0.40-7F
                     DFB 165,94,225,225,225
                     DFB 94,130,225,141,94
                     DFB 129,225,111,95,131
                     DFB 225,46,94,225,225
                     DFB 225,94,130,225,61
                     DFB 95,225,225,225,95
                     DFB 131,225,169,2,225
                     DFB 225,225,2,162,225
                     DFB 149,2,161,225,111
                     DFB 3,163,225,50,2
                     DFB 225,225,225,2,162
                     DFB 225,185,3,225,225
                     DFB 225,3,163,225
;table0.80-BF
                     DFB 225,190,225,225,198
                     DFB 190,194,225,89,225
                     DFB 213,225,199,191,195
                     DFB 225,14,190,225,225
                     DFB 198,190,194,225,221
                     DFB 191,217,225,225,191
                     DFB 225,225,126,118,122
                     DFB 225,126,118,122,225
                     DFB 205,118,201,225,127
                     DFB 119,123,225,18,118
                     DFB 225,225,126,118,122
                     DFB 225,65,119,209,225
                     DFB 127,119,123,225
;table0.C0-FF
                     DFB 78,70,225,225,78
                     DFB 70,82,225,105,70
                     DFB 85,225,79,71,83
                     DFB 225,34,70,225,255
                     DFB 225,70,82,225,57
                     DFB 71,225,225,225,71
                     DFB 83,225,74,174,225
                     DFB 225,74,174,98,225
                     DFB 101,174,133,225,75
                     DFB 175,99,225,22,174
                     DFB 225,225,225,174,98
                     DFB 225,181,175,225,225
                     DFB 225,175,99,225
;table1.00-3F
DT1                  DFB 7,134,0,0,0,66
                     DFB 66,0,3,34,18,0
                     DFB 0,51,51,0,$CA,179
                     DFB 0,0,0,115,115,0
                     DFB 2,147,0,0,0,99
                     DFB 103,0,54,134,0,0
                     DFB 67,67,66,0,4,34
                     DFB 18,0,52,52,54,0
                     DFB 194,189,0,0,0,116
                     DFB 118,0,2,156,0,0
                     DFB 0,108,103,0
;table1.40-7F
                     DFB 6,134,0,0,0,67
                     DFB 69,0,3,34,18,0
                     DFB 51,52,54,0,194,189
                     DFB 0,0,0,116,118,0
                     DFB 2,156,0,0,0,108
                     DFB 111,0,6,134,0,0
                     DFB 0,67,69,0,4,34
                     DFB 18,0,85,52,54,0
                     DFB 194,189,0,0,0,116
                     DFB 118,0,2,156,0,0
                     DFB 0,108,103,0
;table1.80-BF
                     DFB 0,134,0,0,67,67
                     DFB 67,0,2,0,2,0
                     DFB 52,52,52,0,194,182
                     DFB 0,0,116,116,164,0
                     DFB 2,149,2,0,0,101
                     DFB 0,0,34,134,34,0
                     DFB 67,67,67,0,2,34
                     DFB 2,0,52,52,52,0
                     DFB 194,189,0,0,116,116
                     DFB 164,0,2,156,2,0
                     DFB 108,108,156,0
;table1.C0-FF
                     DFB 34,134,0,0,67,67
                     DFB 69,0,2,34,2,0
                     DFB 52,52,54,0,194,189
                     DFB 0,0,0,116,118,0
                     DFB 2,156,0,0,0,108
                     DFB 103,0,34,134,0,0
                     DFB 67,67,69,0,2,34
                     DFB 2,0,52,52,54,0
                     DFB 194,189,0,0,0,116
                     DFB 118,0,2,156,0,0
                     DFB 0,108,103,0
;
;
pmnem                TAX
                     LDA MNEM0,X
                     JSR WRITEBUFF
                     LDA MNEM1,X
                     JSR WRITEBUFF
                     LDA MNEM2,X
                     JSR WRITEBUFF+2
                     JMP sp
;
CLRBUFFER            LDA #32:LDX #78
cB                   STA BUFFER,X:DEX:BPL cB
                     LDA #0:STA BUFFER+79
                     LDX #1:STX XC
                     RTS

dol                  LDA #&$:DFB $2C
ob                   LDA #&(:DFB $2C
cb                   LDA #&):DFB $2C
one                  LDA #&1:DFB $2C
com                  LDA #&,:DFB $2C
plus                 LDA #&+:DFB $2C
sp                   LDA #32:JMP WRITEBUFF
;
pxw                  TYA:JSR pxa:TXA:JMP pxa
spxa                 PHA:JSR sp:PLA

pxa                  STX WSP:TAY:LSR :LSR :LSR 
                     LSR :JSR pxd
                     TYA:AND #15
                     JSR pxd
                     LDX WSP:RTS

pbina                STA WSP:LDY #7
pbl                  LDA #&0:ASL  WSP:ADC #0
                     JSR WRITEBUFF
                     DEY:BPL pbl
                     RTS

pxd                  TAX
                     LDA HEXTAB,X:JMP WRITEBUFF

PRINTHEXLINE         JSR CLRBUFFER
                     LDA #$3A:STA BUFFER+1;      COLON
                     INC XC;                     OFFSET INTO BUFFER
                     JSR STOREAD0
                     JSR STORESPACE
                     LDY #0
PR1HEXBYTE           JSR GETBYTE
                     JSR STORE2HEX
                     JSR STORESPACE
                     INY:CPY #16:BNE PR1HEXBYTE
                     LDA AD0:ADD #16:STA AD0
                     BCC .+4:INC AD0+1
                     RTS

STORESPACE           LDA #$20:BNE WRITEBUFF

STOREAD0             LDA AD0+1:JSR STORE2HEX
                     LDA AD0
STORE2HEX            PHA
                     LSR :LSR :LSR :LSR 
                     JSR STOREHEX
                     PLA
STOREHEX             AND #$0F
                     STX W2:TAX
                     LDA HEXTAB,X:LDX W2
WRITEBUFF            STX W2
                     LDX XC;             THIS ALSO CALLED
                     STA BUFFER,X
                     INC XC:LDX W2
                     RTS

hxline               STA AD0:STY AD0+1;       STA AD1:STY AD1+1
                     STX W1:TAX:JSR pxw
                     LDY #0:STY YINDX
hxloop               LDY YINDX:JSR GETBYTE
                     INC XC
                     JSR pxa:INC YINDX
                     DEC W1:BNE hxloop
                     RTS

dDUMP
dDL                  JSR CLRBUFFER
                     LDY #0:JSR GETBYTE:TAX
                     LDA DT1,X:STA dad+1
                     LDA DT0,X:STA dad
                     AND #3:STA dad+2;length
                     LDX #1:STX XC
                     LDX AD0:LDY AD0+1
                     JSR pxw
                     LDX #17:STX XC
                     LDX dad+2:LDY #0:STY W1
dl                   LDY W1
                     JSR GETBYTE
                     INC XC
                     JSR pxa
                     INC W1:DEX:BNE dl
                     LDX #30:STX XC
                     LDA AD0:LDY AD0+1
;      LDX dad+2:JSR vstrxy
                     LDA dad+1:BEQ fin
                     LDX #36:STX XC:TAY
                     AND #7:JSR pxd:TYA
                     AND #8:BEQ d3
                     JSR plus
                     JSR one
d3                   LDX #6:STX XC
                     LDA dad:LSR :LSR 
                     JSR pmnem
                     LDA dad+1:AND #240
                     BEQ fin
                     LSR :LSR :LSR :LSR 
                     JSR operand
fin
dW
                     LDA dad+2:CLC:ADC AD0
                     STA AD0:BCC d5
                     INC AD0+1
d5;    JMP dDL
dx                   RTS
;
operand              TAY:DEY:BNE ad2
                     LDA #&A:JMP WRITEBUFF
ad2                  DEY:BNE ad3
                     LDA #&#:JSR WRITEBUFF
                     JMP zpage
ad3                  DEY:BNE ad4
getabsol             INY:JSR GETBYTE
                     TAX:INY:JSR GETBYTE:TAY
absol                JSR dol:JMP pxw
ad4                  DEY:BNE ad5
zpage                INY:JSR dol:JSR GETBYTE
                     JMP pxa
ad5                  DEY:BNE ad6
                     JSR ob:JSR getabsol
                     JMP cb
ad6                  DEY:BNE ad7
                     JSR getabsol
comx                 JSR com
                     LDA #&X:JMP WRITEBUFF
ad7                  DEY:BNE ad8
zpcomx               JSR zpage:JMP comx
ad8                  DEY:BNE ad9
                     JSR indcom:JSR comx
                     JMP cb
indcom               JSR ob:JMP zpage
ad9                  DEY:BNE ad10
                     JSR getabsol
comy                 JSR com
                     LDA #&Y:JMP WRITEBUFF
ad10                 DEY:BNE ad11
                     JSR zpage:JMP comy
ad11                 DEY:BNE ad12
                     JSR indcom:JSR cb
                     JMP comy
ad12                 JSR GETBYTE:LDY AD0+1
                     TAX:BPL forward:DEY
forward              CLC:ADC #2:BCC nonewpag
                     INY:CLC
nonewpag             ADC AD0:TAX:BCC absol
                     INY:JMP absol

GETBYTE;   LDA (AD0),Y:RTS

                     TYA:ADD AD0:PHA
                     LDA AD0+1:ADC #0
;       PHA
                     JSR WRITEADHI
;      PLA:JSR WRITEADHI
;      JSR DELAY
                     PLA
                     PHA:JSR WRITEADLO
                     PLA:JSR WRITEADLO
;     JSR DELAY
                     JMP READBYTE

;
;0.doesn't exist
;1.ACCUMULATOR
;3.ABSOLUTE
;3.ABSOLUTE
;4.ZEROPAGE
;5.(INDIRECT)
;6.ABSOLUTE,X
;7.ZEROPAGE,X
;8.(INDIRECT,X)
;9.ABSOLUTE,Y
;10.ZEROPAGE,Y
;11.(INDIRECT),Y
;12.RELATIVE
;


FINFLAG              DFB 0
OUTPUT               DFB 0

CALCSTACK            DFS 16
LABADS
LABADS2              EQU LABADS+52*9
AEND                 EQU LABADS2+52*9
                     DFS 52*9*2,0


