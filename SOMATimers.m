//
//  SOMATimers.m
//
//  Copyright 2011 Franklyn Weber. All rights reserved.
//

#import "SOMATimers.h"


@interface SOMATimers (Private)

-(void)SOMATimerEndsWithID:(NSString *)timerID;
    
@end



@implementation SOMATimers


-(id)init {
    
    self = [super init];
    if (self) {
        
        timers = [[NSMutableDictionary alloc] init];
        groupsByID = [[NSMutableDictionary alloc] init];
        
    }
    
    return self;
    
}


-(void)dealloc {
    
    [timers release];
    
    [super dealloc];
    
}


#pragma mark - Timer Methods

-(NSString *)SOMATimerWithSelector:(SEL)theSelector withObject:(id)theObject afterDelay:(NSTimeInterval)theDelay forDelegate:(id)theDelegate {
    
    return [self SOMATimerForGroup:@"application"
                      withSelector:theSelector
                        withObject:theObject
                        withObject:nil
                        afterDelay:theDelay
                       forDelegate:theDelegate];
    
}


-(NSString *)SOMATimerWithSelector:(SEL)theSelector withObject:(id)theObject1 withObject:(id)theObject2 afterDelay:(NSTimeInterval)theDelay forDelegate:(id)theDelegate {
    
    return [self SOMATimerForGroup:@"application"
                      withSelector:theSelector
                        withObject:theObject1
                        withObject:theObject2
                        afterDelay:theDelay
                       forDelegate:theDelegate];
    
}


-(NSString *)SOMATimerForGroup:(NSString *)theGroup withSelector:(SEL)theSelector withObject:(id)theObject afterDelay:(NSTimeInterval)theDelay forDelegate:(id)theDelegate {

    return [self SOMATimerForGroup:theGroup
                      withSelector:theSelector
                        withObject:theObject
                        withObject:nil
                        afterDelay:theDelay
                       forDelegate:theDelegate];
    
}


-(NSString *)SOMATimerForGroup:(NSString *)theGroup withSelector:(SEL)theSelector withObject:(id)theObject1 withObject:(id)theObject2 afterDelay:(NSTimeInterval)theDelay forDelegate:(id)theDelegate {
    
    static int timerID = 0;
    timerID ++;
    
    NSString *theID = [NSString stringWithFormat:@"%i",timerID];
    
    NSDate *startTime = [NSDate date];
    NSNumber *duration = [NSNumber numberWithFloat:theDelay];
    NSString *selectorAsString = NSStringFromSelector(theSelector);
    
    NSMutableDictionary *thisTimer = [[NSMutableDictionary alloc] init];
    
    if (theGroup == nil) theGroup = @"application";
    if (theObject1 == nil) theObject1 = @"nil";
    if (theObject2 == nil) theObject2 = @"nil";
    
    [thisTimer setObject:theGroup forKey:@"group"];
    [thisTimer setObject:theDelegate forKey:@"delegate"];
    [thisTimer setObject:startTime forKey:@"start"];
    [thisTimer setObject:duration forKey:@"duration"];
    [thisTimer setObject:selectorAsString forKey:@"selector"];
    [thisTimer setObject:theObject1 forKey:@"object1"];
    [thisTimer setObject:theObject2 forKey:@"object2"];
    [thisTimer setObject:@"1" forKey:@"active"];
    
    if ([timers objectForKey:theGroup] == nil) {
        NSMutableDictionary *groupList = [NSMutableDictionary dictionary];
        [timers setObject:groupList forKey:theGroup];
    }
    
    [[timers objectForKey:theGroup] setObject:thisTimer forKey:theID];
    [thisTimer release];
    
    [groupsByID setObject:theGroup forKey:theID];
    
    [self performSelector:@selector(SOMATimerEndsWithID:) withObject:theID afterDelay:theDelay];
    
    return theID;
    
}


-(void)SOMATimerEndsWithID:(NSString *)timerID {
    
    NSString *theGroup = [groupsByID objectForKey:timerID];
    NSMutableDictionary *thisTimer = [[timers objectForKey:theGroup] objectForKey:timerID];
    
    NSString *selectorAsString = [thisTimer objectForKey:@"selector"];
    SEL theSelector = NSSelectorFromString(selectorAsString);
    
    id theObject1 = [thisTimer objectForKey:@"object1"];
    id theObject2 = [thisTimer objectForKey:@"object2"];
    
    if ([theObject1 isEqual:@"nil"]) theObject1 = nil;
    if ([theObject2 isEqual:@"nil"]) theObject2 = nil;
    
    
    id theDelegate = [thisTimer objectForKey:@"delegate"];
    
    if ([theDelegate respondsToSelector:theSelector]) {
        if (theObject2 == nil) {
            [theDelegate performSelector:theSelector withObject:theObject1];
        } else {
            [theDelegate performSelector:theSelector withObject:theObject1 withObject:theObject2];
        }
    }
    
    [[timers objectForKey:theGroup] removeObjectForKey:timerID];
    [groupsByID removeObjectForKey:timerID];
    
}


-(void)suspendAllTimers {
    
    for (NSString *timerID in [groupsByID allKeys]) {
        [self suspendTimer:timerID];
    }
    
}


-(void)suspendTimersForGroup:(NSString *)theGroup {
    
    NSMutableDictionary *thisGroup = [timers objectForKey:theGroup];
    for (NSString *timerID in [thisGroup allKeys]) {
        [self suspendTimer:timerID];
    }
}


-(void)suspendTimer:(NSString *)timerID {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(SOMATimerEndsWithID:) object:timerID];
    
    NSString *theGroup = [groupsByID objectForKey:timerID];
    NSMutableDictionary *thisTimer = [[timers objectForKey:theGroup] objectForKey:timerID];
    
    NSDate *startTime = [thisTimer objectForKey:@"start"];
    NSTimeInterval duration = [[thisTimer objectForKey:@"duration"] floatValue];
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startTime];
    NSTimeInterval newDuration = duration - elapsedTime;
    
    NSNumber *durationAsNumber = [NSNumber numberWithFloat:newDuration];
    
    [thisTimer setObject:durationAsNumber forKey:@"duration"];
    [thisTimer setObject:@"0" forKey:@"active"];
    
}


-(void)restartAllTimers {
    
    for (NSString *timerID in [groupsByID allKeys]) {
        [self restartTimer:timerID];
    }
    
}


-(void)restartTimersForGroup:(NSString *)theGroup {
    
    NSMutableDictionary *thisGroup = [timers objectForKey:theGroup];
    for (NSString *timerID in [thisGroup allKeys]) {
        [self restartTimer:timerID];
    }
    
}


-(void)restartTimer:(NSString *)timerID {
    
    NSString *theGroup = [groupsByID objectForKey:timerID];
    NSMutableDictionary *thisTimer = [[timers objectForKey:theGroup] objectForKey:timerID];
    
    if (![[thisTimer objectForKey:@"active"] boolValue]) {
        
        NSDate *startTime = [NSDate date];
        NSTimeInterval duration = [[thisTimer objectForKey:@"duration"] floatValue];
        
        [thisTimer setObject:startTime forKey:@"start"];
        [thisTimer setObject:@"1" forKey:@"active"];
        
        [self performSelector:@selector(SOMATimerEndsWithID:) withObject:timerID afterDelay:duration];
        
    }
    
}


-(void)killTimer:(NSString *)timerID {
    
    [self suspendTimer:timerID];
    
    NSString *theGroup = [groupsByID objectForKey:timerID];
    NSMutableDictionary *thisGroup = [timers objectForKey:theGroup];
    
    [thisGroup removeObjectForKey:timerID];
    [groupsByID removeObjectForKey:timerID];
    
}


-(void)killTimersForGroup:(NSString *)theGroup {
    
    [self suspendTimersForGroup:theGroup];
    
    NSMutableDictionary *thisGroup = [timers objectForKey:theGroup];
    for (NSString *timerID in [thisGroup allKeys]) {
        [groupsByID removeObjectForKey:timerID];
    }
    
    [timers removeObjectForKey:theGroup];
    
}


-(void)killAllTimers {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}


@end
