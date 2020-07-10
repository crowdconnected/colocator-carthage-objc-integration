//
//  ViewController.m
//  ColocatorObjcIntegration
//
//  Created by TCode on 03/12/2019.
//  Copyright © 2019 CrowdConnected. All rights reserved.
//

#import "ViewController.h"

#import <CCLocation/CCLocation-Swift.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CCLocation.sharedInstance.delegate = self;
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *id = [CCLocation.sharedInstance getDeviceId];
        NSLog(@"\n\n\nGot device ID %@", id);
        
        [CCLocation.sharedInstance registerLocationListener];
    });
}

- (void)ccLocationDidConnect {
    NSLog(@"CC Delegate: ccLocationDidConnect");
}

- (void)ccLocationDidFailWithErrorWithError:(NSError * _Nonnull)error {
    NSLog(@"CC Delegate: ccLocationDidFailWithErrorWithError %@", error);
}

- (void)didFailToUpdateCCLocation {
    NSLog(@"CC Delegate: didFailToUpdateCCLocation");
}

- (void)didReceiveCCLocation:(LocationResponse * _Nonnull)location {
    NSString *latitudeString = [[NSNumber numberWithDouble:location.latitude] stringValue];
    NSString *longitudeString = [[NSNumber numberWithDouble:location.longitude] stringValue];
    NSString *headingOffsetString = [[NSNumber numberWithDouble:location.headingOffSet] stringValue];
    NSString *errorString = [[NSNumber numberWithDouble:location.error] stringValue];
    NSString *timestampString = [[NSNumber numberWithDouble:location.timestamp] stringValue];
    NSString *floorString = [[NSNumber numberWithDouble:location.floor] stringValue];
    
    NSDictionary *locationResponseDicstionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 @"latitude", latitudeString,
                                                 @"longitude", longitudeString,
                                                 @"headingOffset",headingOffsetString,
                                                 @"error", errorString,
                                                 @"timestamp", timestampString,
                                                 @"floor", floorString,
                                                 nil];
    
    NSLog(@"CC Delegate: didReceiveCCLocation %@ dictionary %@", location, locationResponseDicstionary);
}

@end
