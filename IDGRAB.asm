#include "ti83plus.inc"
#define PACKET_SIZE 4

 ; getting data in/out
 ; _SetXXOP1 A -> OP1
 ; _SetXXXXOP2 HL -> OP2
 ; _ConvOP1 OP1 -> DE

.org userMem-2
.db t2ByteTok, tAsmCmp ; header stuff
 bcall(_RclAns)     ; get Ans in OP1
 bcall(_Trunc)      ; make OP1 an integer
 bcall(_ConvOP1)    ; put OP1 in DE
 ld a,e             ; put LSB of DE in A
 ld hl,linkHeader   ; data will be sent from here
 ld (hl),a          ; set machine ID to a (Ans)

 AppOnErr(BadPacket); Start handling errors
 ld c,0
 ld b,PACKET_SIZE  ; we will be sending this many bytes
 ld hl,linkHeader   ;   from here
SendPacket:         ; 
 ld a,(hl)          ; load the byte we want to send
 push bc
 bcall(_SendAByte)  ; send that byte
 pop bc
 inc hl             ; go to the next byte
 djnz SendPacket    ;   and prepare to send it

 ld c,0
 ld b,PACKET_SIZE   ; we will be receiving this many bytes
 ld hl,response     ;   into here
ReceivePacket:      ; 
 push bc
 bcall(_RecAByteIO) ; receive a byte into a
 pop bc
 ld (hl),a          ; save that byte in our buffer
 inc hl             ; go to the next byte
 djnz ReceivePacket ;   and prepare to receive it
 
 AppOffErr          ; stop handling errors
 ld hl,response     ; start looking at our response
 ld a,(hl)          ;   and load the returned machine ID
 bcall(_SetXXOP1)   ;   and put that into OP1
 ld hl,response+1   ; go to the next byte, to see if we got data
 ld a,(hl)          ;   and load the returned command ID
 cp $5A             ; check if that command ID is ERR
 jr z,NACKPacket    ; if it is, send it to the NACK Packet Handler
 cp $56             ; else, check if that command ID is anything but ACK
 jr nz,BadPacket    ; if it isn't ACK, we got bad data. Set OP1 to -256
Exit:               ; Whatever is in OP1 is going into Ans
 bcall(_StoAns)     ; so we put it there,
 ret                ;   and abandon ship
NACKPacket:         ; We would end up here if we got a ERR response, but a response
 push af            ; preserve a
 ld hl,OP1          ; find the first byte of OP1 (the sign)
 ld a,$80           ; load the value for negative real
 ld (hl),a          ; set the sign byte to negative real
 pop af             ; resurrect af
 jr Exit            ; and abandon ship
BadPacket:          ; Probably corrupt data ends up in this handler
 ld hl,BadResult    ; load the bad result of -256
 bcall(_Mov9ToOP1)  ; shove it in OP1
 jr Exit            ; and abandon ship

; storage for things
linkHeader:
 .db 0,$68,0,0
response:
 .db 0,0,0,0
BadResult:
 .db $80,$82,$25,$60,0,0,0,0,0,0,0

.end
