//
//  VerletStick.m
//  SkyHeist
//
//  Created by Sarah Smith on 18/03/2015.
//  Copyright (c) 2015 Smithsoft. All rights reserved.
//
// Based on: http://www.yoambulante.com/en/labs/verlet.php


#import "VerletStick.h"
#import "VerletPoint.h"

@implementation VerletStick

+ (VerletStick *)stickWithPointA:(VerletPoint *)pointA withPointB:(VerletPoint *)pointB
{
    return [[VerletStick alloc] initWithPointA:pointA withPointB:pointB];
}

- (instancetype)initWithPointA:(VerletPoint *)pointA withPointB:(VerletPoint *)pointB
{
    self = [super init];
    if (self)
    {
        _pointA = pointA;
        _pointB = pointB;
        _stickLength = ccpDistance(_pointA.position, _pointB.position);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _stickLength = [coder decodeFloatForKey:@"stickLength"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:_stickLength forKey:@"stickLength"];
}

- (void)setSprite:(CCSprite *)sprite
{
    _sprite = sprite;
    [self updateSprite];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ -(%0.2f)- %@", _pointA, _stickLength, _pointB];
}

- (void)contract
{
    CGPoint stickVec = ccpSub(_pointB.position, _pointA.position);
    float currentStickLength = ccpLength(stickVec);
    float deltaLength = _stickLength - currentStickLength;
    CGPoint deltaVec = ccpMult(stickVec, deltaLength / currentStickLength);
    CGPoint offsetVec = ccpMult(deltaVec, 0.5);
    [_pointA adjust:ccpNeg(offsetVec)];
    [_pointB adjust:offsetVec];
    
    [self updateSprite];
}

- (void)updateSprite
{
    CGPoint stickVec = ccpSub(_pointB.position, _pointA.position);
    CGPoint midPoint = ccpAdd(_pointA.position, ccpMult(stickVec, 0.5f));
    float angle = ccpAngleSigned(ccp(1, 0), stickVec);
    angle = CC_RADIANS_TO_DEGREES(angle);
    [_sprite setRotation:-angle];
    [_sprite setPosition:midPoint];
}

@end
