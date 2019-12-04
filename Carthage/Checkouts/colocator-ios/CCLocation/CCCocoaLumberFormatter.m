//
//  CCCocoaLumberFormatter.m
//  CCLocation
//
//  Created by Ralf Kernchen on 05/12/2016.
//  Copyright © 2016 Crowd Connected. All rights reserved.
//

//#import <Foundation/Foundation.h>
//#import "CCCocoaLumberFormatter.h"
//#import <libkern/OSAtomic.h>
//
//@implementation CCCocoaLumberFormatter
//
//- (NSString *)stringFromDate:(NSDate *)date {
//    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);
//    
//    if (loggerCount <= 1) {
//        // Single-threaded mode.
//        
//        if (threadUnsafeDateFormatter == nil) {
//            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
//            [threadUnsafeDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
//        }
//        
//        return [threadUnsafeDateFormatter stringFromDate:date];
//    } else {
//        // Multi-threaded mode.
//        // NSDateFormatter is NOT thread-safe.
//        
//        NSString *key = @"MyCustomFormatter_NSDateFormatter";
//        
//        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
//        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
//        
//        if (dateFormatter == nil) {
//            dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
//            
//            [threadDictionary setObject:dateFormatter forKey:key];
//        }
//        
//        return [dateFormatter stringFromDate:date];
//    }
//}
//
//- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
//    NSString *logLevel;
//    switch (logMessage->_flag) {
//        case DDLogFlagError    : logLevel = @"E"; break;
//        case DDLogFlagWarning  : logLevel = @"W"; break;
//        case DDLogFlagInfo     : logLevel = @"I"; break;
//        case DDLogFlagDebug    : logLevel = @"D"; break;
//        default                : logLevel = @"V"; break;
//    }
//    
//    NSString *dateAndTime = [self stringFromDate:(logMessage.timestamp)];
//    NSString *logMsg = logMessage->_message;
//    NSString *fileName = [logMessage->_file lastPathComponent];
//    NSString *funcName = logMessage->_function;
//    long line = logMessage->_line;
//    
//    return [NSString stringWithFormat:@"[CC] %@ (%@:%ld) %@ %@ | %@", dateAndTime, fileName, line, funcName, logLevel, logMsg];
//}
//
//- (void)didAddToLogger:(id <DDLogger>)logger {
//    OSAtomicIncrement32(&atomicLoggerCount);
//}
//
//- (void)willRemoveFromLogger:(id <DDLogger>)logger {
//    OSAtomicDecrement32(&atomicLoggerCount);
//}
//
//@end

