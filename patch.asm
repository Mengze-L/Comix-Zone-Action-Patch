
ORIGIN_ACTION_UP_FORWARD_KICK         set $001D0F82

ORIGIN_ACTION_UP_DOWN_KICK_POINTER    set $0013154C

ORIGIN_SHOULDER_SMASH_HIT_TYPE        set $00131CF4

ORIGIN_SHOULDER_SMASH_ADD_DISTANCE    set $00131D1E
ORIGIN_SHOULDER_SMASH_SUB_DISTANCE    set $00131D14

ORIGIN_SHOULDER_SMASH_TILE_XY         set $001B28EB
ORIGIN_SHOULDER_SMASH_HIT_XY          set $001B28F0

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

ORIGIN_HIT_POINT_LR_CHECK             set $001D0836
ORIGIN_HIT_POINT_RETURN               set $001D083E

ORIGIN_ACTION_HP_DECREASE             set $001D0732

BUTTON_DOWN_DOWN_FLAG                 set $00FF801E
BUTTON_FORWARD_FORWARD_FLAG           set $00FF801F

; Constants: -----------------------------------------------------------
FORWARD_KICK:                         equ $001318C0
FORWARD_KICK_FAST:                    equ $001318DA

SHOULDER_SMASH:                       equ $00131CDC
SHOULDER_SMASH_DISTANCE_ADD:          equ $0026 ; +0x26 (right) position, origin value is 0x1C
SHOULDER_SMASH_DISTANCE_SUB:          equ $FFDA ; -0x26 (left) position, origin value is 0xFFE4
SHOULDER_SMASH_TILE_XY:               equ $21   ; +0x21 (forward) position, origin value is 0x1C
SHOULDER_SMASH_HIT_XY:                equ $26   ; +0x26 (forward) position, origin value is 0x1D

UP_DOWN_KICK_FLAG_OFFSET:             equ $1E

CHARACTOR_HP:                         equ $00FFBF04

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

        ;org     ORIGIN_SHOULDER_SMASH_HIT_TYPE
        ;dc.w    $8

        org     ORIGIN_SHOULDER_SMASH_ADD_DISTANCE
        dc.w    SHOULDER_SMASH_DISTANCE_ADD

        org     ORIGIN_SHOULDER_SMASH_SUB_DISTANCE
        dc.w    SHOULDER_SMASH_DISTANCE_SUB

        org     ORIGIN_SHOULDER_SMASH_TILE_XY
        dc.b    SHOULDER_SMASH_TILE_XY

        org     ORIGIN_SHOULDER_SMASH_HIT_XY
        dc.b    SHOULDER_SMASH_HIT_XY

        org     ORIGIN_DEC_BUTTON_COUNTER
        jmp     DECREASE_FLAG_COUNTERS

        org     ORIGIN_HIT_POINT_LR_CHECK     ; It is bug in original code using D1-D2>0 to check the hit point on left or right. It is always true/right
        jmp     FIX_HIT_POINT_LR_CHECK
        ;cmp.w   D0,D2

        org      ORIGIN_ACTION_HP_DECREASE
        move.w   $12(A3),D1
        andi.w   #$F000,D1
        cmpi.w   #$1000,D1
        beq.s    CHECK_KNOCK_DOWN
        bra.s    SKIP_HP_DECREASE
CHECK_KNOCK_DOWN
        cmpi.w   #$100,D0
        bne.s    DECREASE_HP
        moveq    #$20,D0
DECREASE_HP
        sub.w    D0,(CHARACTOR_HP).w
        cmpi.w   #$20,(CHARACTOR_HP).w
        bge.s    SKIP_HP_DECREASE
        add.w    D0,(CHARACTOR_HP).w
SKIP_HP_DECREASE

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
        move.b  #$20,(BUTTON_FORWARD_FORWARD_FLAG)
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

FIX_HIT_POINT_LR_CHECK
        move.l  D4,-(SP)
        move.w  $C(A3),D4
        cmp.w   $C(A2),D4
        bge.s   FIX_HIT_POINT_RETURN
        move.w  D0,D1
        subi.w  #$2,D1
        move.w  D3,D2
FIX_HIT_POINT_RETURN
        move.l  (SP)+,D4
        jmp     ORIGIN_HIT_POINT_RETURN
      
