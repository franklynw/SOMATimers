//
//  SOMATimers.h
//
//  Copyright 2011 Franklyn Weber. All rights reserved.
//
//  Version 1.0
//  May 2011
//
//
//  For management of "performSelector:withObject:afterDelay:" calls
//
//  call in exactly the same way using "SOMATimerWithSelector:withObject:afterDelay:forDelegate:"
//  or "SOMATimerWithSelector:withObject:withObject:afterDelay:forDelegate:" (added extra!)
//  each timer called returns a unique ID as NSString
//
//  also available are grouped timers, which can be stopped & started by group name
//  the methods are the same as above, but you specify the group name by calling -
//  "SOMATimerForGroup:etc etc"
//  timers made without a group are kept in the @"application" group
//  
//  then suspend all the timers using "suspendAllTimers" (all timers in all groups)
//  or individual timers by passing the id which is returned when you call a timer,
//  using "suspendTimer:myTimerID"
//  suspend all timers in a group using "suspendTimersForGroup:myGroupName"
//
//  all timers can be resumed using "restartAllTimers" (all timers in all groups)
//  or again, individual timers by passing their id
//  using "restartTimer:myTimerID"
//  restart all timers in a group using "restartTimersForGroup:myGroupName"
//
//  calling a new timer doesn't affect the status (suspended or not)
//  of existing timers
//
//  make sure you kill any timers which belong to a delegate which is released,
//  as it will attempt to call the released delegate and crash -
//  use "killTimersForGroup:myGroupName"
//
//  "killAllTimers" should be called before releasing the SOMATimers object
//  or the timers may continue & call the released object (crash...)


#import <Foundation/Foundation.h>


@interface SOMATimers : NSObject {
    
    NSMutableDictionary *timers;
    NSMutableDictionary *groupsByID;
    
}


-(id)init;

-(NSString *)SOMATimerWithSelector:(SEL)theSelector
                        withObject:(id)theObject
                        afterDelay:(NSTimeInterval)theDelay
                       forDelegate:(id)theDelegate;

-(NSString *)SOMATimerWithSelector:(SEL)theSelector
                        withObject:(id)theObject1
                        withObject:(id)theObject2
                        afterDelay:(NSTimeInterval)theDelay
                       forDelegate:(id)theDelegate;

-(NSString *)SOMATimerForGroup:(NSString *)theGroup
                  withSelector:(SEL)theSelector
                    withObject:(id)theObject
                    afterDelay:(NSTimeInterval)theDelay
                   forDelegate:(id)theDelegate;

-(NSString *)SOMATimerForGroup:(NSString *)theGroup
                  withSelector:(SEL)theSelector
                    withObject:(id)theObject1
                    withObject:(id)theObject2
                    afterDelay:(NSTimeInterval)theDelay
                   forDelegate:(id)theDelegate;


-(void)suspendTimer:(NSString *)timerID;
-(void)suspendTimersForGroup:(NSString *)theGroup;
-(void)suspendAllTimers;

-(void)restartTimer:(NSString *)timerID;
-(void)restartTimersForGroup:(NSString *)theGroup;
-(void)restartAllTimers;

-(void)killTimer:(NSString *)timerID;
-(void)killTimersForGroup:(NSString *)theGroup;
-(void)killAllTimers;


@end