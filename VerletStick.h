//
//  VerletStick.m
//  SkyHeist
//
//  Created by Sarah Smith on 18/03/2015.
//  Copyright (c) 2015 Smithsoft. All rights reserved.
//
// Based on: http://www.yoambulante.com/en/labs/verlet.php


#import <Foundation/Foundation.h>

@class VerletPoint;

/** The "stick" class of the Verlet integration encapsulating a constrained line segment.
 The line segment has two VerletPoint end points which are iterated for their velocity
 after which the contract method should be called to apply the constraints.  Generally
 this class is for use by VerletRope and there should be no need to directly create
 instances of VerletStick. */
@interface VerletStick : NSObject<NSCoding>

/** The start-point of the stick. */
@property (nonatomic, strong) VerletPoint *pointA;

/** The end-point of the stick. */
@property (nonatomic, strong) VerletPoint *pointB;

/** The constrained length the stick. */
@property (nonatomic, readonly) float stickLength;

/** The sprite displayed stick. */
@property (nonatomic, weak) CCSprite *sprite;


/** Return a new VerletStick that goes from the given point A to the given point B. */
+ (VerletStick *)stickWithPointA:(VerletPoint *)pointA withPointB:(VerletPoint *)pointB;


/** Initialize a VerletStick so that it goes from the given point A to the given point B. */
- (instancetype)initWithPointA:(VerletPoint *)pointA withPointB:(VerletPoint *)pointB;


/** Apply the length constraint of the stick. */
- (void)contract;

@end
