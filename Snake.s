NewGame:
ldx #0
ldy #0
jsr Sleep
; cheating ;)
ldx #$ff
txs

; store color 1 into address 2
lda #01
sta $02

ldy #8
; load color into a
ClearScreen:

lda $2
; load 32 into x
ldx #32
outputColor:
; store color into video memory
dex
sta $200,x
sta $220,x
sta $240,x
sta $260,x
sta $280,x
sta $2a0,x
sta $2c0,x
sta $2e0,x
sta $300,x
sta $320,x
sta $340,x
sta $360,x
sta $380,x
sta $3a0,x
sta $3c0,x
sta $3e0,x
sta $400,x
sta $420,x
sta $440,x
sta $460,x
sta $480,x
sta $4a0,x
sta $4c0,x
sta $4e0,x
sta $500,x
sta $520,x
sta $540,x
sta $560,x
sta $580,x
sta $5a0,x
sta $5c0,x
sta $5e0,x
bne outputColor

; draw the snake
lda #00
ldx #15
ldy #15
jsr PlotPixel

; put the snake part count in memory $03
lda #01
sta $03

; put snake head link 1 x at memory $20, y at $60
stx $20 ; snake head x
sty $60 ; snake head y

;ldx #14
;stx $21
;ldy #15
;sty $61
;lda #01
;jsr PlotPixel

;ldx #13
;stx $22
;ldy #15
;sty $62
;lda #01
;jsr PlotPixel

jsr AddSection
jsr AddSection
jsr AddSection

jsr SpawnFruit

jmp noreturn

FruitXmatches:
lda $60
cmp $19
bne doneCheckingForFruit
; fruit matches
jsr SpawnFruit
jsr AddSection

jmp doneCheckingForFruit

noreturn:
; check snake head vs fruit location
lda $20
cmp $18
beq FruitXmatches

doneCheckingForFruit:

; redraw fruit, just in case
ldx $18
ldy $19
lda #5
jsr PlotPixel
; wait for player to press right, up, down, or left
; read key press
lda $ff
cmp #97 ; a key
beq leftkeypressed
lda $ff
cmp #100 ; d key
beq rightkeypressed
lda $ff
cmp #119 ; w key
beq upkeypressed
lda $ff
cmp #115 ; s key
beq downkeypressed
jsr Sleep
jmp noreturn

leftkeypressed:
jsr AdvanceSnakeLeft
jsr Sleep
jmp noreturn

rightkeypressed:
jsr AdvanceSnakeRight
jsr Sleep
jmp noreturn

downkeypressed:
jsr AdvanceSnakeDown
jsr Sleep
jmp noreturn

upkeypressed:
jsr AdvanceSnakeUp
jsr Sleep
jmp noreturn



GameOver:
jsr LongSleep
jmp NewGame


; do a whole lotta bupkiss
Sleep:
 ldx #2
outerloop:
; ldy #175
lda #220
sbc $03
clc
sbc $03
clc
sbc $03
clc
sbc $03
clc
sbc $03
clc
sbc $03
clc
sbc $03
innerloop:
sbc #1
 bne innerloop

dex
 bne outerloop
 
rts


; do a whole lotta bupkiss
LongSleep:
 ldx #20
lsouterloop:
 ldy #255
lsinnerloop:
 dey
 bne lsinnerloop

dex
 bne lsouterloop
 
rts


;x and y registers store x and y of new head
FollowSnake:
; save x and y
stx $06
sty $07
; copy section count
lda $03
sta $04

; store memory addr of piece 1 x at $08, piece 1 y at $10
lda #$20
sta $08
lda #$60
sta $10
lda #0
sta $09
sta $11

updateSnake:
jsr updateSection
dec $04
bne updateSnake
rts

; $04 has number of current piece
updateSection:
; is the current piece the last piece?
lda $03
cmp $04
bne doneWithErasing

; get x and y of current piece
lda $04
sta $05
ldy $05 ; put index of current piece in y
dey
lda ($08),y
pha ; get x coord and push it on the stack

lda ($10),y
;lda $60
sta $05
ldy $05
pla
sta $05
ldx $05
lda #1
; erase pixel
jsr PlotPixel

; update x and y to point to new x and y

doneWithErasing:

; get the x,y of the previous section and copy it to this section's x,y
ldy $04
dey
bne notTheFirst

ldx $06
ldy $07
;stx $20
;sty $60
rts

notTheFirst:
ldy $04
dey
dey
; load x,y values of prev section
lda ($08),y
pha
lda ($10),y
;pha
; overwrite x,y values of current section w/ previous x,y
iny
;pla
sta ($10),y
pla
sta ($08),y

rts


AdvanceSnakeRight:
; holy shit assembly is tough

; ld snake x and y
ldx $20
ldy $60

; plot black to the right of head
lda #0
inx ; increase x
cpx #32
bne continueRight
jmp GameOver

continueRight:
jsr PlotPixel


jsr FollowSnake

; increase x of head
inc $20


rts



AdvanceSnakeLeft:

; ld snake x and y
ldx $20
ldy $60

; plot black to the left of head
lda #0
cpx #0
bne continueLeft
jmp GameOver

continueLeft:
dex ; decrease x
jsr PlotPixel

jsr FollowSnake

; erase tail
;ldx $20
;ldy $60
;lda #01
;jsr PlotPixel

; decrease x of head
dec $20

rts



AdvanceSnakeDown:
; holy shit assembly is tough

; ld snake x and y
ldx $20
ldy $60

; plot black underneath head
lda #0
iny ; increase y
cpy #32
bne continueDn
jmp GameOver

continueDn:
jsr PlotPixel

jsr FollowSnake

; erase tail
;ldx $20
;ldy $60
;lda #01
;jsr PlotPixel

; increase y of head
inc $60

rts



AdvanceSnakeUp:

; ld snake x and y
ldx $20
ldy $60

; plot black above head
lda #0
cpy #0
bne continueUp
jmp GameOver

continueUp:
dey ; decrease y
jsr PlotPixel


jsr FollowSnake

; erase tail
;ldx $20
;ldy $60
;lda #01
;jsr PlotPixel

; decrease y of head
dec $60

rts



SpawnFruit:
; read random number for x
lda $fe
and #31
; store fruit x, y at $18, $19
sta $18
lda $fe
and #31
sta $19

ldx $18
ldy $19
; plot this sucker
lda #$05
jsr PlotPixel

rts


AddSection:
; do nothing if there's already 31 sections
lda #31
clc
cmp $03
bcs goOnAdding
rts
goOnAdding:
; write x and y memory locations to $08 and $10
lda #0
sta $09
sta $11
lda #$20
sta $08
lda #60
sta $10

; ld section count
ldy $03
lda ($08),y
pha
lda ($10),y
iny
sta ($10),y
pla
sta ($08),y
inc $03

rts



PlotPixel:
pha ; push the value of a onto the stack

; store $0200 into address 0-1
lda #00
sta $00
lda #02
sta $01

; y coord is in y register, for every y, increase memory location by 32
cpy #0
jmp compareY

subtractY:
lda $00
clc
adc #$20
bcc goOnThen

;carry set, inc $01
inc $01

goOnThen:
sta $00
dey

compareY:
bne subtractY


;restore color 
pla

; move x to memory $02 then to y
stx $02
ldy $02

sta ($00),Y ; plot the pixel

rts
