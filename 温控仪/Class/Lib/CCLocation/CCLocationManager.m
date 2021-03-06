//
//  CCLocationManager.m
//  MMLocationManager
//
//  Created by WangZeKeJi on 14-12-10.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import "CCLocationManager.h"
#import "CLLocation+YCLocation.h"
@interface CCLocationManager (){
    CLLocationManager *_manager;

}
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;
@property(nonatomic,strong)NSString *lastCity;
@property (nonatomic,strong) NSString *lastProvience;

@property(nonatomic,assign)float latitude;
@property(nonatomic,assign)float longitude;
@end

@implementation CCLocationManager


+ (CCLocationManager *)shareLocation{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)initWithDelegate:(id<CCLocationManagerZHCDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (CCLocationManager *)getNowCityNameAndProvienceName:(id<CCLocationManagerZHCDelegate>)delegate {
    CCLocationManager *manager =  [self initWithDelegate:delegate];
    [self startLocation];
    return manager;

}

-(void)startLocation
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        _manager=[[CLLocationManager alloc]init];
        _manager.delegate=self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        [_manager requestAlwaysAuthorization];
        _manager.distanceFilter=100;
        [_manager startUpdatingLocation];
    } else {
        
    }
    
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation * location = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    CLLocation * marsLoction =   [location locationMarsFromEarth];
    _lastCoordinate = CLLocationCoordinate2DMake(marsLoction.coordinate.latitude ,marsLoction.coordinate.longitude);
    
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks,NSError *error)
     {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             _lastCity = placemark.locality;

             _lastProvience = placemark.addressDictionary[@"State"];
             [kStanderDefault setObject:placemark.addressDictionary[@"State"] forKey:@"provience"];
             
             NSLog(@"%@ , %@" , _lastCity , _lastProvience);
            
             if (_lastCity && _lastProvience) {
                 
                 NSArray *address = @[_lastCity , _lastProvience];
                 
                 if (_delegate && [_delegate respondsToSelector:@selector(getCityNameAndProvience:)]) {
                     [_delegate getCityNameAndProvience:address];
                 }
             }
         }
         
     }];
    
    [manager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self stopLocation];

}
-(void)stopLocation
{
    _manager = nil;
}


@end
