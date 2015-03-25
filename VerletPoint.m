//
//  VerletPoint.m
//  SkyHeist
//
//  Created by Sarah Smith on 18/03/2015.
//  Copyright (c) 2015 Smithsoft. All rights reserved.
//
// Based on: http://www.yoambulante.com/en/labs/verlet.php

#import "VerletPoint.h"


@implementation VerletPoint
{
    CGPoint _prevPosition;
}

+ (VerletPoint *)pointWithPosition:(CGPoint)position
{
    return [[VerletPoint alloc] initWithPosition:position];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@[%0.2f,%0.2f]", CCNSStringFromCGPoint(_position), _prevPosition.x, _prevPosition.y];
}

- (instancetype)initWithPosition:(CGPoint)position
{
    self = [super init];
    if (self)
    {
        [self setPosition:position];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _position.x = [coder decodeFloatForKey:@"position.x"];
        _position.y = [coder decodeFloatForKey:@"position.y"];
        _prevPosition = _position;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:_position.x forKey:@"position.x"];
    [aCoder encodeFloat:_position.y forKey:@"position.y"];
}

- (void)setPosition:(CGPoint)position
{
    _position = _prevPosition = position;
}

- (void)adjust:(CGPoint)adjustVector
{
    _position.x += adjustVector.x;
    _position.y += adjustVector.y;
}

- (void)iterate
{
    CGPoint preIteratePosition = _position;
    _position.x += _position.x - _prevPosition.x;
    _position.y += _position.y - _prevPosition.y;
    _prevPosition = preIteratePosition;
}

@end
