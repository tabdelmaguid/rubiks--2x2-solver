# A Solver for 2x2 Rubik's Cube

## Model

The cubes faces are described with the following labels: up, forward, down, back, right, left.

The directions are coded with their initial letter, and encoded with a number between 0 and 5, in the same order above.

Holding the cube in front of you, the cube to the top, left, closer side to you, is at position (0, 0, 0). The x
axis goes left to right, y at the direction you are facing; from you onward, and z goes from top down.

The blocks are stored in a one-dimensional array, indexed 0 to 7. The index i corresponds to coordinates (x, y, z) when
 i = x + 2 * y + 4 * z.

## Movements:
1. Right side forward (RSF)

    The cube's right side, x = 1, rotates clockwise on the x axis, as if pushing the right side forward from the top.
2. Forward side right (FSR)

    The cube's further side, y = 1, rotates counter-clockwise on the y axis, as if pushing the further side to the right
      from the top.
3. Bottom side counter clockwise (BSCC)

    The cube's bottom side, z = 1, rotates clockwise on the z axis. If you look from the top though, the rotation is
     counter clockwise.

For example, rotating a cube RSF (right side forward) changes the cube's orientations this way:

u -> f, f -> d, d -> b, b -> u, right, and left stay the same.

Individual cubes are described with the current direction of their top, and left side. The top, and left sides are
 defined as the cube's side facing up, and left, respectively, at its initial, solved position.

So, the initial, or null, position, can be described with the following array:
    [(up, left), (up, left), (up, left), (up, left), (up, left), (up, left), (up, left), (up, left)]
