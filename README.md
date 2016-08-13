SCARABOT
========

Idea
----

I had this idea to build a parallel-arm SCARA style 3d printer similar to the
RepRap Wally that uses DC motors and the AS5048A absolute position rotary
encoder.

The idea was that you could use just about any small DC motors and
pretty much everything would be 3D printed apart from some off the shelf
bearings. You would then get a really cheap, very 3d printable motion platform
with closed loop control where you never even have to home the axes again and
in theory it would be really quiet too.

Problems
--------

The crux of it is that you basically have two identical 3d printed servos.

Turns out that you need really really high gearing and you can either have
little to no backlash OR low friction. So either the gears turned freely, but
you got millimeters of deflection at the end effector OR you had no backlash to
speak of, but the gears would totally bind up and the motors would stall.

I could try larger DC motors, but that would kinda defeat the purpose and mean
a redesign so it doesn't have to move the weight of the motors around.

I also tried just about every possible alternative to just plain old spur gears
that would get me to the required 1000:1 gear ratio, but in the end they all
just weren't suitable for 3D printing, had way too much backlash or would just
end up taking up too much space.

..but I learned a lot
---------------------

I had fun re-learning the required trigonometry to do the forward and inverse
kinematics, learning about PID control, doing way more c coding than at any
time since the 1990s, using OpenSCAD, etc. Oh well! Moving on.
