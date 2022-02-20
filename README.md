# Draw-Delete-Move-Cirlces

- This assignment is to develop a simple drawing app. The user can draw colored circles. The
app will have three modes of operation: drawing, deleting and moving. The three modes are
described below. The app can only be in one mode at a time. So in the drawing mode circles
are not moving.

## Drawing Mode

The drawing area for the circles will be the entire screen except for the title bar. When the user
places one finger on the screen a circle is drawn on the screen. The center of the circle is
placed where the user touched the screen. The user moves their finger to increase the radius
of the circle. While the user is moving their finger the circle is drawn, with the edge of the circle
under the users finger. So as the user moves their finger farther from the center of the circle
the circle gets larger in real time. When the user lifts their finger the size of the circle is fixed.
The user can put multiple circles on the screen by touching it multiple times. You should be
able to support unlimited number of circles (or as many as memory will allow).
While in drawing mode the user can select via a menu which color the circle should be when
drawn. The user can select the colors blue, red, green and black. The default color it is black.
This is the color of the circles drawn while the color selected. So the user could draw several
black circles, then change the color to blue and then draw some blue circles. The first black
circles remain black.

## Delete Mode

While in delete mode the user can delete circles. When the user touches inside a circle the circle is removed and not drawn again. If the spot where the user touches the screen is inside
multiple circles at the same time they are all deleted. Circles do not move when the app is in
delete mode.

## Moving Mode

In this mode the user can put the circles in motion. The user sets a circle in motion by placing
a finger in a circle and swiping in any direction. The circles will start moving in direction and
velocity indicated by the swipe. Different circles can be moving in different directions with different speeds. When a circle reaches the edge of the screen it will bounce off the edge properly. That is it will lose some velocity and take into account the angle it strikes the edge. For example if the circle hits the edge at 90 degree angle it will bounce straight back. If it strikes the edge at a 45 degree angle it will bounce off at a 135 degree angle.

