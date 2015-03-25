Verlet Rope
===========

Simple Objective-C / Cocos2D implementation.  This was based on the tutorial
at http://www.yoambulante.com/en/labs/verlet.php.  This implementation is a 
clean re-boot of Objective-C from the YoAmbulante tutorial and does not use
any code from the other previous implementations.

As such it uses modern Objective-C, and the Obj-C interface to Chipmunk.
Additionally the `VerletRope` class has a very simple interface, allowing
a rope to be set up between two nodes.  My motivation for creating this was that
the VRope implementation was full of ifdef and patch coding that made it hard
to get working in a 2015 Cocos2D V3 app.


Initial Config Feature
======================

When a rope is initialised in the scene it will handle updates to the two
end control points and produce fairly realistic rope movements.  If the rope
should initially be stable then the initial config feature can be used.

For this a rope's state can be serialized out to a plist file and then on a
subsequent run of the app, the rope can be initialised from the plist instead
of just initializing by itself.  This is important for ropes that are lying
slack with some sag between two points, as opposed to ropes that are already
stretched taut at initialization.

By default the `+ (VerletRope *)ropeFromSavedDataBodyA:(CCNode *)bodyA bodyB:(CCNode *)bodyB`
method checks `rope/RopeData.plist` in the App's Bundle and then in the documents
directory.  This allows you to ship a pre-configured rope setup with your app,
but during development try out the config that has been saved in to the documents
directory via the `- (void)saveRopeData` method.  When you're happy with the
rope's setup you can add it to your Xcode project for inclusion in the bundle.


Other Objective-C Verlet Ropes
==============================

Note that there is a [Verlet rope implementation on GitHub](https://github.com/pkclsoft/VRope/tree/chipmunk) which is a fork by
Pcklsoft of an original one done back in 2012 by Greg Harding.  Pcklsoft's implementation
adds Chipmunk support but does not solve some of the problems of the 2012 version which is
no ARC, no modern Objective-C, terse documentation and difficult to use with a number of special
case methods set up for the developer's own usage.

The Pcklsoft implementation is used in a [2012 article on Ray Wenderlich's site](http://www.raywenderlich.com/14793/how-to-make-a-game-like-cut-the-rope-part-1)
but as shown there a number of edits are required to get the VRope class working.
Under the hood it uses Box2D and the later port to Chipmunk still does not use
the Objective-C interface, and has a number of ifdef's to handle Box2D vs Chipmunk.

So in summary, those implementations are a bit of patchwork of updates, mods and
ifdef's that I found too messy to use.


