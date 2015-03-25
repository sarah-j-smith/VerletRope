//
//  VerletRope.h
//  SkyHeist
//
//  Created by Sarah Smith on 18/03/2015.
//  Copyright (c) 2015 Smithsoft. All rights reserved.
//
// Based on: http://www.yoambulante.com/en/labs/verlet.php

#import "CCNode.h"

/** Implements a rope using Verlet integration.  By default the gravity has a value of 0.1
 and points downwards (negative y).  Provide a sprite sheet called "RopeSprites" which contains
 an image called "rope.png" to give the visual appearance to the rope.
 
 Set the rope bodyA and bodyB nodes to suitable non-nil end-points, and add the rope to the
 scene (via the scene's addChild: method) to have the rope move with the end point nodes.
 
 The size of the rope elements is determined by the "rope.png" sprite, and the number of
 rope elements is a function of the length of the rope and the size of the sprites.  Use a
 larger sprite for a more coarse grained, less-CPU intensive rope.
 
 When the rope is first displayed it will take some time to reach a stable state.  To avoid
 this, during development save out the state of a stable rope to a data file, and then copy
 that data file into the application bundle.  During production when the app is in use, it
 will load a pre-determined stable rope.
 
 Use this code in didLoadFromCCB or onEnter:

    // PRODUCTION CASE
    _ropeNode = [VerletRope ropeFromSavedDataBodyA:nodeA bodyB:nodeB];
    if (_ropeNode == nil)
    {
        // DEVELOPMENT CASE - ROPE_SAG_FACTOR should be around 1.2
        float len = ccpDistance([nodeA position], [nodeB position]) * ROPE_SAG_FACTOR;
        _ropeNode = [[VerletRope alloc] initWithLength:len bodyA:nodeA bodyB:nodeB];
    }
    [self addChild:_ropeNode];
 
 Call the saveRopeData method once the rope is stable to get the rope data.  For example
 place a call in the touchBegan:withEvent: method, and trigger it by tapping the screen when
 you see that your rope is stable.  Once a stable rope has successfully been saved, copy the
 data file into your app bundle for shipping with the app/game.
 
 The amount of gravity, the names of the sprite image and data paths can be changed by
 modifying the values at the top of VerletRope.m.
 */
@interface VerletRope : CCNode<NSCoding>

/** Initialise a Verlet rope from a saved data file.  First try to load the rope data
 from the application bundle, then if that fails try to load from the documents directory.
 The file checked for is `data/RopeData.plist` in those two locations. */
+ (VerletRope *)ropeFromSavedDataBodyA:(CCNode *)bodyA bodyB:(CCNode *)bodyB;;

/** Initialise a new rope of at least the given ropeLength that stretches from bodyA to bodyB. */
- (instancetype)initWithLength:(CGFloat)ropeLength bodyA:(CCNode *)bodyA bodyB:(CCNode *)bodyB;

/** Save the rope data into the documents directory. */
- (void)saveRopeData;

/** Final length of rope, after adjustments for sprite size.  May be slightly longer than supplied length. */
- (float)ropeLength;

/** Set up a rope joint, that is a CCPhysicsSlideJoint that allows a min and max distance
 between the ropes two nodes, with the given anchorA and anchorB values for the respective nodes. */
- (void)setUpRopeJointWithAnchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB;

// debug method - deliberately not documented
- (void)dump;

@end