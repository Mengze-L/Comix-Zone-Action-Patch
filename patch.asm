
ORIGIN_ACTION_UP_FORWARD_KICK         set $001D0F82

; Constants: -----------------------------------------------------------
FORWARD_KICK:                         equ $001318C0
FORWARD_KICK_FAST:                    equ $001318DA

; Overrides: -----------------------------------------------------------
        org     ORIGIN_ACTION_UP_FORWARD_KICK
        dc.l    FORWARD_KICK

; Change: ---------------------------------------------------------------

