//
//  VerletPoint.h
//  SkyHeist
//
//  Created by Sarah Smith on 15/03/2015.
//  Copyright (c) 2015 Smithsoft. All rights reserved.
//
// Based on: http://www.yoambulante.com/en/labs/verlet.php


/** A class to store pseudo-physics points under Verlet integration.  The points store their previous position
 which effectively gives the point a velocity vector. */
@interface VerletPoint : NSObject<NSCoding>

/** The initialized position of the Verlet point.  Setting this value will not cause physics to be simulated. */
@property (nonatomic, assign) CGPoint position;

/** Create a new Verlet point with the given initial position */
+ (VerletPoint *)pointWithPosition:(CGPoint)position;

/** Initialize a Verlet point with a given position */
- (instancetype)initWithPosition:(CGPoint)position;

/** Adjust a Verlet point by a given delta.  This will cause the point to store its velocity and respond with physics emulation. */
- (void)adjust:(CGPoint)adjustVector;

/** After adjusting the point, iterate toward a stable state by applying velocity. */
- (void)iterate;

@end