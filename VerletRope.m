//
//  VerletRope.m
//  SkyHeist
//
//  Created by Sarah Smith on 18/03/2015.
//  Copyright (c) 2015 Smithsoft. All rights reserved.
//
// Based on: http://www.yoambulante.com/en/labs/verlet.php

#import "VerletRope.h"
#import "VerletPoint.h"
#import "VerletStick.h"

#define GRAVITY_VALUE 0.1f

//#define ROPE_IMAGE_NAME @"RopeSprites/rope.png"
#define ROPE_IMAGE_NAME @"RopeSprites/debug-rope.png"

#define ROPE_FILE_NAME @"RopeData"

#define DATA_DIR @"data"

NSString *ropeDataDocumentsPath()
{
    NSURL *documentsDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentsPath = [documentsDirURL path];
    documentsPath = [NSString pathWithComponents:@[ documentsPath, DATA_DIR ]];
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath isDirectory:&isDir])
    {
        NSError *err;
        BOOL ok = [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:NO attributes:nil error:&err];
        if (!ok)
        {
            NSLog(@"Could not create data directory: %@ - %@", documentsPath, [err localizedDescription]);
            return nil;
        }
    }
    documentsPath = [NSString pathWithComponents:@[ documentsPath, ROPE_FILE_NAME ]];
    return [documentsPath stringByAppendingPathExtension:@"plist"];
}

NSString *ropeDataBundlePath()
{
    return [[NSBundle mainBundle] pathForResource:ROPE_FILE_NAME ofType:@"plist" inDirectory:DATA_DIR];
}

VerletRope *loadRopeFromPath(NSString *saveDataPath)
{
    VerletRope *result = nil;
    if (saveDataPath != nil)
    {
        NSData *ropeData = [NSData dataWithContentsOfFile:saveDataPath];
        if (ropeData != nil)
        {
            result = [NSKeyedUnarchiver unarchiveObjectWithData:ropeData];
            if (result == nil)
            {
                NSLog(@"Could not decode data from file %@ for rope!", saveDataPath);
            }
        }
        else
        {
            NSLog(@"Could not load data file %@ for rope!", saveDataPath);
        }
    }
    return result;
}

#if COCOS2D_DEBUG
void saveRopeToPath(NSString *saveDataPath, VerletRope *rope)
{
    BOOL success = NO;
    NSData *ropeData = [NSKeyedArchiver archivedDataWithRootObject:rope];
    if (ropeData != nil)
    {
        success = [ropeData writeToFile:saveDataPath atomically:NO];
        if (success)
        {
            NSLog(@"Saved rope data to %@", saveDataPath);
        }
        else
        {
            NSLog(@"Failed to save rope data to %@", saveDataPath);
        }
    }
    else
    {
        NSLog(@"Could not encode rope data!");
    }
}
#endif

@implementation VerletRope
{
    CGFloat _ropeLength;
    
    CCNode *_bodyA, *_bodyB;
    CCPhysicsJoint *_ropeJoint;
    
    CGPoint _bodyALastPosition, _bodyBLastPosition;
    
    NSArray *_points;
    NSArray *_sticks;
    
    NSUInteger _numberOfSegments;
}

+ (VerletRope *)ropeFromSavedDataBodyA:(CCNode *)bodyA bodyB:(CCNode *)bodyB
{
    VerletRope *rope = nil;
    
    // Try to load from bundle first - this is the case where the game is in shipped and running on users device.
    NSString *ropeDataPath = ropeDataBundlePath();
    if (ropeDataPath != nil)
    {
        rope = loadRopeFromPath(ropeDataPath);
        CCLOG(@"Loaded rope data from: %@", ropeDataPath);
    }
    else
    {
#if COCOS2D_DEBUG
        if (ropeDataPath == nil)
        {
            NSLog(@"No rope data found in \"%@/%@.plist\" in %@", DATA_DIR, ROPE_FILE_NAME, [[NSBundle mainBundle] resourcePath]);
        }
        
        // Next try to load from documents directory - development case where we have yet to add a rope to the bundle
        rope = loadRopeFromPath( ropeDataDocumentsPath() );
#endif
    }
    if (rope)
    {
        rope->_bodyA = bodyA;
        rope->_bodyB = bodyB;
    }
    return rope;
}

- (NSString *)description
{
    NSMutableArray *ptDescs = [NSMutableArray array];
    for (VerletPoint *pt in _points)
    {
        [ptDescs addObject:CCNSStringFromCGPoint([pt position])];
    }
    return [ptDescs componentsJoinedByString:@"-"];
}

- (void)dump
{
    for (VerletStick *stk in _sticks)
    {
        NSLog(@"   %@", stk);
    }
}

- (float)ropeLength
{
    return _ropeLength;
}

- (void)saveRopeData
{
    NSString *saveDataFile = ropeDataDocumentsPath();
    saveRopeToPath( saveDataFile, self );
}

- (instancetype)initWithLength:(CGFloat)length bodyA:(CCNode *)bodyA bodyB:(CCNode *)bodyB
{
    self = [super init];
    if (self)
    {
        _ropeLength = length;
        _bodyA = bodyA;
        _bodyB = bodyB;
        _bodyALastPosition = [_bodyA position];
        _bodyBLastPosition = [_bodyB position];
        [self setUpRopeSegments];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _bodyA = _bodyB = nil;
        _bodyALastPosition = _bodyBLastPosition = CGPointZero;
        _points = [coder decodeObjectForKey:@"points"];
        _sticks = [coder decodeObjectForKey:@"sticks"];
        _ropeLength = [coder decodeFloatForKey:@"ropeLength"];
        _numberOfSegments = [_sticks count];
        [self restoreRopeSegments];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSAssert(_points != nil, @"trying to encode when points not set up!");
    NSAssert(_sticks != nil, @"trying to encode when sticks not set up!");
    [coder encodeObject:_points forKey:@"points"];
    [coder encodeObject:_sticks forKey:@"sticks"];
    [coder encodeFloat:_ropeLength forKey:@"ropeLength"];
    
    for (VerletPoint *p in _points)
    {
        NSLog(@">> %@", CCNSStringFromCGPoint([p position]));
    }
}

- (void)setUpRopeJointWithAnchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
{
    _ropeJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA:[_bodyA physicsBody]
                                                           bodyB:[_bodyB physicsBody]
                                                         anchorA:anchorA
                                                         anchorB:anchorB
                                                     minDistance:0.0f
                                                     maxDistance:_ropeLength];
    [_ropeJoint setCollideBodies:YES];
}

- (void)setUpRopeSegments
{
    CCSpriteFrame *ropeFrame = [CCSpriteFrame frameWithImageNamed:ROPE_IMAGE_NAME];
    CGRect frameRect = [ropeFrame rect];
    CGFloat segmentImageLength = frameRect.size.width;
    _numberOfSegments = ceilf(_ropeLength / segmentImageLength);
    _ropeLength = (float)_numberOfSegments * segmentImageLength;
    
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:(_numberOfSegments + 1)];
    CGPoint pos = CGPointZero;
    CGPoint delta = ccpSub([_bodyB position], [_bodyA position]);
    delta.x = delta.x / _numberOfSegments;
    delta.y = (delta.y - _ropeLength) / (4.0f * _numberOfSegments);
    float negDeltaY = -delta.y;
    for (int i = 0; i < _numberOfSegments + 1; ++i)
    {
        [points addObject:[VerletPoint pointWithPosition:pos]];
        pos = ccpAdd(pos, delta);
        if (i > (_numberOfSegments * 0.5f))
        {
            delta.y = negDeltaY;
        }
    }
    NSMutableArray *sticks = [NSMutableArray arrayWithCapacity:_numberOfSegments];
    for (int i = 0; i < _numberOfSegments; ++i)
    {
        VerletStick *stick = [VerletStick stickWithPointA:points[i] withPointB:points[i+1]];
        CCSprite *ropeSegment = [CCSprite spriteWithSpriteFrame:ropeFrame];
        [self addChild:ropeSegment];
        [stick setSprite:ropeSegment];
        [sticks addObject:stick];
    }
    _points = [points copy];
    _sticks = [sticks copy];
}

// Just for NSCoder case
- (void)restoreRopeSegments
{
    for (int i = 0; i < _numberOfSegments; ++i)
    {
        [[_sticks objectAtIndex:i] setPointA:[_points objectAtIndex:i]];
        [[_sticks objectAtIndex:i] setPointB:[_points objectAtIndex:i+1]];
    }
    CCSpriteFrame *ropeFrame = [CCSpriteFrame frameWithImageNamed:ROPE_IMAGE_NAME];
    for (int i = 0; i < _numberOfSegments; ++i)
    {
        VerletStick *stick = [_sticks objectAtIndex:i];
        CCSprite *ropeSegment = [CCSprite spriteWithSpriteFrame:ropeFrame];
        [self addChild:ropeSegment];
        [stick setSprite:ropeSegment];
    }
}

- (void)updateRopeElements
{
    NSAssert(_bodyA != nil, @"bodyA must not be nil!");
    NSAssert(_bodyB != nil, @"bodyB must not be nil!");
    
    VerletPoint *firstPoint = [_points firstObject];
    VerletPoint *lastPoint = [_points lastObject];
    
    [firstPoint setPosition:[_bodyA position]];
    [lastPoint setPosition:[_bodyB position]];
    
    for (VerletPoint *verletPoint in _points)
    {
        [verletPoint adjust:ccp(0.0f, -GRAVITY_VALUE)];
        [verletPoint iterate];
    }
    for (VerletStick *verletStick in _sticks)
    {
        [verletStick contract];
    }
}

- (void)onEnter
{
    [super onEnter];
    [self updateRopeElements];
}

- (void)onExit
{
    [_ropeJoint invalidate];
    [super onExit];
}

- (void)update:(CCTime)delta
{
    [self updateRopeElements];
}


@end
