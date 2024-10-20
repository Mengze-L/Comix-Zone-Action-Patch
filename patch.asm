
ORIGIN_ACTION_UP_FORWARD_KICK         set $001D0F82

ORIGIN_ACTION_UP_DOWN_KICK_POINTER    set $0013154C

ORIGIN_SET_BUTTON_LEFT                set $001D02B8
ORIGIN_RETURN_BUTTON_LEFT             set $001D02BE

ORIGIN_SET_BUTTON_RIGHT               set $001D02D0
ORIGIN_RETURN_BUTTON_RIGHT            set $001D02D6

ORIGIN_SET_BUTTON_DOWN                set $001D0278
ORIGIN_RETURN_BUTTON_DOWN             set $001D027E

ORIGIN_SET_BUTTON_UP                  set $001D0244
ORIGIN_RETURN_BUTTON_UP               set $001D024A

ORIGIN_DEC_BUTTON_COUNTER             set $001D01DE
ORIGIN_RETURN_DEC_COUNTER             set $001D01E4

ORIGIN_SET_ACTION                     set $001D0F36
ORIGIN_RETURN_ACTION_SET              set $001D0F3C

BUTTON_DOWN_DOWN_FLAG                 set $00FF801E
BUTTON_FORWARD_FORWARD_FLAG           set $00FF801F

; Constants: -----------------------------------------------------------
FORWARD_KICK:                         equ $001318C0
FORWARD_KICK_FAST:                    equ $001318DA

SHOULDER_SMASH:                       equ $00131CDC

UP_DOWN_KICK_FLAG_OFFSET:             equ $1E

BUTTON_RIGHT_FLAG:                    equ $00FFBF86
BUTTON_LEFT_FLAG:                     equ $00FFBF87
BUTTON_DOWN_FLAG:                     equ $00FFBF88
BUTTON_UP_FLAG:                       equ $00FFBF89

; Overrides: -----------------------------------------------------------
        org     ORIGIN_ACTION_UP_FORWARD_KICK
        dc.l    FORWARD_KICK

        org     ORIGIN_ACTION_UP_DOWN_KICK_POINTER
        dc.w    UP_DOWN_KICK_FLAG_OFFSET

        org     ORIGIN_SET_BUTTON_LEFT
        jmp     CHECK_PREVIOUS_BUTTON_LEFT

        org     ORIGIN_SET_BUTTON_RIGHT
        jmp     CHECK_PREVIOUS_BUTTON_RIGHT

        org     ORIGIN_SET_BUTTON_DOWN
        jmp     CHECK_PREVIOUS_BUTTON_DOWN

        org     ORIGIN_SET_BUTTON_UP
        jmp     CLEAR_PREVIOUS_ACTION_FLAG

        org     ORIGIN_SET_ACTION
        jmp     CHECK_SHOULDER_SMASH

        org     ORIGIN_DEC_BUTTON_COUNTER
        jmp     DECREASE_FLAG_COUNTERS

; Change: ---------------------------------------------------------------
        org     $001FD200
CHECK_PREVIOUS_BUTTON_DOWN
        tst.b   (BUTTON_DOWN_FLAG)
        beq     SKIP_TO_ORIGIN_BUTTON_DOWN_FLAG
        move.b  #$10,(BUTTON_DOWN_DOWN_FLAG)
SKIP_TO_ORIGIN_BUTTON_DOWN_FLAG
        move.b  #$10,(BUTTON_DOWN_FLAG)
        move.b  #$0,(BUTTON_FORWARD_FORWARD_FLAG)
        jmp     ORIGIN_RETURN_BUTTON_DOWN

CHECK_PREVIOUS_BUTTON_LEFT
	tst.b   (BUTTON_LEFT_FLAG)
        beq     SKIP_TO_ORIGIN_BUTTON_LEFT_FLAG
        jsr     SET_DASH_FLAG
SKIP_TO_ORIGIN_BUTTON_LEFT_FLAG
        move.b  #$10,(BUTTON_LEFT_FLAG)
        jmp     ORIGIN_RETURN_BUTTON_LEFT

CHECK_PREVIOUS_BUTTON_RIGHT
	tst.b   (BUTTON_RIGHT_FLAG)
        beq     SKIP_TO_ORIGIN_BUTTON_RIGHT_FLAG
        jsr     SET_DASH_FLAG
SKIP_TO_ORIGIN_BUTTON_RIGHT_FLAG
        move.b  #$10,(BUTTON_RIGHT_FLAG)
        jmp     ORIGIN_RETURN_BUTTON_RIGHT

SET_DASH_FLAG
        move.b  #$10,(BUTTON_FORWARD_FORWARD_FLAG)
        move.b  #$0,(BUTTON_DOWN_DOWN_FLAG)
        rts

CLEAR_PREVIOUS_ACTION_FLAG
        move.b  #$0,(BUTTON_DOWN_DOWN_FLAG)
        move.b  #$0,(BUTTON_FORWARD_FORWARD_FLAG)
        move.b  #$10,(BUTTON_UP_FLAG)
        jmp     ORIGIN_RETURN_BUTTON_UP

CHECK_SHOULDER_SMASH
        tst.b   (BUTTON_FORWARD_FORWARD_FLAG)
        beq     SKIP_SHOULDER_SMASH
        move.l  #SHOULDER_SMASH,$30(A0)
        move.b  #$0,(BUTTON_FORWARD_FORWARD_FLAG)
SKIP_SHOULDER_SMASH
        bclr    #2,$A(A0)
        jmp     ORIGIN_RETURN_ACTION_SET

DECREASE_FLAG_COUNTERS
        and.l   D1,D0
        move.l  D0,(BUTTON_RIGHT_FLAG)
        tst.b   (BUTTON_DOWN_DOWN_FLAG)
        beq     DECREASE_DASH_FLAG
        subi.b  #$1,(BUTTON_DOWN_DOWN_FLAG)
DECREASE_DASH_FLAG
        tst.b   (BUTTON_FORWARD_FORWARD_FLAG)
        beq     RETURN_ORIGIN
        subi.b  #$1,(BUTTON_FORWARD_FORWARD_FLAG)
RETURN_ORIGIN
        jmp     ORIGIN_RETURN_DEC_COUNTER
