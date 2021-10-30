# Acknowledgement to the original authors of the code on which this
# example is based.
import pygame

pygame.init()

SCREEN_HEIGHT = 400
SCREEN_WIDTH = 400

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
done = False
is_blue = True
x = 200
y = 200
speed = 0.3

time = pygame.time

while not done:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            done = True
        if event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
            is_blue = not is_blue
    pressed = pygame.key.get_pressed()
    if pressed[pygame.K_LEFT] and (x >= 0):
        x -= speed
    if pressed[pygame.K_RIGHT] and (x <= SCREEN_WIDTH - rect.width):
        x += speed
    if pressed[pygame.K_UP] and (y >= 0):
        y -= speed

    # Movement Down
    if pressed[pygame.K_DOWN] and (y <= SCREEN_HEIGHT - rect.height):
        y += speed

    print(f"x is {x} y is {y} timer is {time.get_ticks()}")

    screen.fill((0, 0, 0))
    if is_blue:
        color = (0, 128, 255)
    else:
        color = (255, 100, 0)

    rect = pygame.Rect(x, y, 60, 60)
    pygame.draw.rect(screen, color, rect)

    pygame.display.flip()
