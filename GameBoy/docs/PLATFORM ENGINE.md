# Engine básica de plataforma 2D

> As informações desta página, por hora, foram tiradas do cu do chatGPT, e nada disso foi confirmado ainda.

## Colisão com o chão

Segundo o GPT, não se verifica se o sprite abaixo do player no BG é chão para detectar a colisão.
Em vez disso, um "collision map" ou "metatile map" deve existir, com os valores de cada tile para comparação:

```
0 = ar
1 = chão
2 = parede
```

E a forma típica de se verificar isso, em um pseudo-código, seria:

```
player_y_pixel + 16 → posição dos pés
player_x_pixel → centro do jogador

tile_x = player_x_pixel / 8
tile_y = (player_y_pixel + 16) / 8

ld a, [CollisionMap + tile_y * MAP_WIDTH + tile_x]
cp TILE_GROUND
jp z, OnGround

; Caso não esteja no chão, aplicar gravidade:
ld a, [player_y]
inc a
ld [player_y], a
```

## Pulo considional ao botão pressionado

Para o pulo, usa-se o conceito de "vertical speed (vy)".

```
wPlayerY:          db
wPlayerVy:         db
wIsOnGround:       db
wJumpHeld:         db
```

Um pseudo-código do pulo

```
ld a, [wIsOnGround]
or a
jr z, .notOnGround

ld a, [wCurKeys]
and PADF_A
jr z, .notOnGround

; inicia pulo
ld a, -6               ; velocidade inicial pra cima (números negativos sobem)
ld [wPlayerVy], a
ld a, 0
ld [wIsOnGround], a

; ----------------------------------------------------------------------------
.notOnGround:

;- Aplicar gravidade (incrementar `vy` até o máximo)
ld a, [wPlayerVy]
inc a
cp 4                 ; velocidade máxima pra baixo
jr c, .skipClamp
ld a, 4

.skipClamp:
ld [wPlayerVy], a

;- Atualizar posição vertical:
ld a, [wPlayerY]
add a, [wPlayerVy]
ld [wPlayerY], a

;- Verificar colisão com o chão (como descrito antes).  
;Se colidir, zera `vy` e marca `wIsOnGround = 1`.

;3. **Pulo alto/baixo (controlado pelo tempo do botão)**
;Quando o player solta o botão **antes de chegar no pico**:
ld a, [wCurKeys]
and PADF_A
jr nz, .stillHeld

ld a, [wPlayerVy]
cp -2
jr nc, .stillHeld
ld a, -2               ; corta a subida
ld [wPlayerVy], a
.stillHeld:
```
