//
//  FWAuthorize.m
//  FWApplication
//
//  Created by wuyong on 17/3/15.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWAuthorize.h"
#import <UIKit/UIKit.h>

#pragma mark - FWAuthorizeContacts

#if FWCOMPONENT_CONTACTS_ENABLED

#import <Contacts/Contacts.h>

// iOS9+使用Contacts
@interface FWAuthorizeContacts : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizeContacts

- (FWAuthorizeStatus)authorizeStatus
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusRestricted:
            return FWAuthorizeStatusRestricted;
        case CNAuthorizationStatusDenied:
            return FWAuthorizeStatusDenied;
        case CNAuthorizationStatusAuthorized:
            return FWAuthorizeStatusAuthorized;
        case CNAuthorizationStatusNotDetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
    [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        FWAuthorizeStatus status = granted ? FWAuthorizeStatusAuthorized : FWAuthorizeStatusDenied;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(status);
            });
        }
    }];
}

@end

#endif

#pragma mark - FWAuthorizeEventKit

#if FWCOMPONENT_CALENDAR_ENABLED

#import <EventKit/EventKit.h>

@interface FWAuthorizeEventKit : NSObject <FWAuthorizeProtocol>

@property (nonatomic, readonly) EKEntityType type;

- (instancetype)initWithType:(EKEntityType)type;

@end

@implementation FWAuthorizeEventKit

- (instancetype)initWithType:(EKEntityType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (FWAuthorizeStatus)authorizeStatus
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:self.type];
    switch (status) {
        case EKAuthorizationStatusRestricted:
            return FWAuthorizeStatusRestricted;
        case EKAuthorizationStatusDenied:
            return FWAuthorizeStatusDenied;
        case EKAuthorizationStatusAuthorized:
            return FWAuthorizeStatusAuthorized;
        case EKAuthorizationStatusNotDetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus))completion
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:self.type completion:^(BOOL granted, NSError * _Nullable error) {
        FWAuthorizeStatus status = granted ? FWAuthorizeStatusAuthorized : FWAuthorizeStatusDenied;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(status);
            });
        }
    }];
}

@end

#endif

#pragma mark - FWAuthorizeLocation

#import <CoreLocation/CoreLocation.h>

@interface FWAuthorizeLocation : NSObject <FWAuthorizeProtocol, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) void (^completionBlock)(FWAuthorizeStatus status);

@property (nonatomic, assign) BOOL changeIgnored;

@property (nonatomic, readonly) BOOL isAlways;

- (instancetype)initWithIsAlways:(BOOL)isAlways;

@end

@implementation FWAuthorizeLocation

- (instancetype)initWithIsAlways:(BOOL)isAlways
{
    self = [super init];
    if (self) {
        _isAlways = isAlways;
    }
    return self;
}

- (CLLocationManager *)locationManager
{
    // 需要强引用CLLocationManager，否则授权弹出框会自动消失
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (FWAuthorizeStatus)authorizeStatus
{
    // 定位功能未打开时返回Denied，可自行调用[CLLocationManager locationServicesEnabled]判断
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusRestricted:
            return FWAuthorizeStatusRestricted;
        case kCLAuthorizationStatusDenied:
            return FWAuthorizeStatusDenied;
        case kCLAuthorizationStatusAuthorizedAlways:
            return FWAuthorizeStatusAuthorized;
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            if (self.isAlways) {
                NSNumber *isAuthorized = [[NSUserDefaults standardUserDefaults] objectForKey:@"FWAuthorizeLocation"];
                return isAuthorized != nil ? FWAuthorizeStatusDenied : FWAuthorizeStatusNotDetermined;
            } else {
                return FWAuthorizeStatusAuthorized;
            }
        }
        case kCLAuthorizationStatusNotDetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus))completion
{
    self.completionBlock = completion;
    
    if (self.isAlways) {
        [self.locationManager requestAlwaysAuthorization];
        
        // 标记已请求授权
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"FWAuthorizeLocation"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // 如果请求always权限且当前已经是WhenInUse权限，系统会先回调此方法一次，忽略之
    if (self.isAlways && !self.changeIgnored) {
        if (status == kCLAuthorizationStatusNotDetermined ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            self.changeIgnored = YES;
            return;
        }
    }
    
    // 主线程回调，仅一次
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(self.authorizeStatus);
            self.completionBlock = nil;
        });
    }
}

@end

#pragma mark - FWAuthorizeMicrophone

#if FWCOMPONENT_MICROPHONE_ENABLED

#import <AVFoundation/AVFoundation.h>

@interface FWAuthorizeMicrophone : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizeMicrophone

- (FWAuthorizeStatus)authorizeStatus
{
    AVAudioSessionRecordPermission status = [[AVAudioSession sharedInstance] recordPermission];
    switch (status) {
        case AVAudioSessionRecordPermissionDenied:
            return FWAuthorizeStatusDenied;
        case AVAudioSessionRecordPermissionGranted:
            return FWAuthorizeStatusAuthorized;
        case AVAudioSessionRecordPermissionUndetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL granted) {
        FWAuthorizeStatus status = granted ? FWAuthorizeStatusAuthorized : FWAuthorizeStatusDenied;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(status);
            });
        }
    }];
}

@end

#endif

#pragma mark - FWAuthorizePhotoLibrary

#import <Photos/Photos.h>

@interface FWAuthorizePhotoLibrary : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizePhotoLibrary

- (FWAuthorizeStatus)authorizeStatus
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusRestricted:
            return FWAuthorizeStatusRestricted;
        case PHAuthorizationStatusDenied:
            return FWAuthorizeStatusDenied;
        case PHAuthorizationStatusAuthorized:
            return FWAuthorizeStatusAuthorized;
        case PHAuthorizationStatusNotDetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.authorizeStatus);
            });
        }
    }];
}

@end

#pragma mark - FWAuthorizeCamera

#import <AVFoundation/AVFoundation.h>

@interface FWAuthorizeCamera : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizeCamera

- (FWAuthorizeStatus)authorizeStatus
{
    // 模拟器不支持照相机，返回受限制
    NSString *mediaType = AVMediaTypeVideo;
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
    if (![inputDevice hasMediaType:mediaType]) {
        return FWAuthorizeStatusRestricted;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusRestricted:
            return FWAuthorizeStatusRestricted;
        case AVAuthorizationStatusDenied:
            return FWAuthorizeStatusDenied;
        case AVAuthorizationStatusAuthorized:
            return FWAuthorizeStatusAuthorized;
        case AVAuthorizationStatusNotDetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus))completion
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.authorizeStatus);
            });
        }
    }];
}

@end

#pragma mark - FWAuthorizeAppleMusic

#if FWCOMPONENT_APPLEMUSIC_ENABLED

#import <MediaPlayer/MediaPlayer.h>

// iOS9.3+需要授权，9.3以前不需要授权
@interface FWAuthorizeAppleMusic : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizeAppleMusic

- (FWAuthorizeStatus)authorizeStatus
{
    MPMediaLibraryAuthorizationStatus status = [MPMediaLibrary authorizationStatus];
    switch (status) {
        case MPMediaLibraryAuthorizationStatusRestricted:
            return FWAuthorizeStatusRestricted;
        case MPMediaLibraryAuthorizationStatusDenied:
            return FWAuthorizeStatusDenied;
        case MPMediaLibraryAuthorizationStatusAuthorized:
            return FWAuthorizeStatusAuthorized;
        case MPMediaLibraryAuthorizationStatusNotDetermined:
        default:
            return FWAuthorizeStatusNotDetermined;
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.authorizeStatus);
            });
        }
    }];
}

@end

#endif

#pragma mark - FWAuthorizeNotifications

#import <UserNotifications/UserNotifications.h>

// iOS10+使用UNUserNotificationCenter
@interface FWAuthorizeNotifications : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizeNotifications

- (FWAuthorizeStatus)authorizeStatus
{
    __block FWAuthorizeStatus status = FWAuthorizeStatusNotDetermined;
    // 由于查询授权为异步方法，此处使用信号量阻塞当前线程，同步返回查询结果
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusDenied:
                status = FWAuthorizeStatusDenied;
                break;
            case UNAuthorizationStatusAuthorized:
            case UNAuthorizationStatusProvisional:
                status = FWAuthorizeStatusAuthorized;
                break;
            case UNAuthorizationStatusNotDetermined:
            default:
                status = FWAuthorizeStatusNotDetermined;
                break;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return status;
}

- (void)authorizeStatus:(void (^)(FWAuthorizeStatus))completion
{
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        FWAuthorizeStatus status;
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusDenied:
                status = FWAuthorizeStatusDenied;
                break;
            case UNAuthorizationStatusAuthorized:
            case UNAuthorizationStatusProvisional:
                status = FWAuthorizeStatusAuthorized;
                break;
            case UNAuthorizationStatusNotDetermined:
            default:
                status = FWAuthorizeStatusNotDetermined;
                break;
        }
        
        if (completion) {
            completion(status);
        }
    }];
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
    UNAuthorizationOptions options = (UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert);
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        FWAuthorizeStatus status = granted ? FWAuthorizeStatusAuthorized : FWAuthorizeStatusDenied;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(status);
            });
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

@end

#pragma mark - FWAuthorizeTracking

#if FWCOMPONENT_TRACKING_ENABLED

#import <AdSupport/ASIdentifierManager.h>
#if __IPHONE_14_0
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif

// iOS14+使用AppTrackingTransparency，其它使用AdSupport
@interface FWAuthorizeTracking : NSObject <FWAuthorizeProtocol>

@end

@implementation FWAuthorizeTracking

- (FWAuthorizeStatus)authorizeStatus
{
#if __IPHONE_14_0
    if (@available(iOS 14.0, *)) {
        ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
        switch (status) {
            case ATTrackingManagerAuthorizationStatusRestricted:
                return FWAuthorizeStatusRestricted;
            case ATTrackingManagerAuthorizationStatusDenied:
                return FWAuthorizeStatusDenied;
            case ATTrackingManagerAuthorizationStatusAuthorized:
                return FWAuthorizeStatusAuthorized;
            case ATTrackingManagerAuthorizationStatusNotDetermined:
            default:
                return FWAuthorizeStatusNotDetermined;
        }
    }
#endif
    
    return [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled ? FWAuthorizeStatusAuthorized : FWAuthorizeStatusDenied;
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
#if __IPHONE_14_0
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(self.authorizeStatus);
                });
            }
        }];
        return;
    }
#endif
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self.authorizeStatus);
        });
    }
}

@end

#endif

#pragma mark - FWAuthorizeManager

@interface FWAuthorizeManager ()

@property (nonatomic, readonly) id<FWAuthorizeProtocol> object;

@end

@implementation FWAuthorizeManager

+ (instancetype)managerWithType:(FWAuthorizeType)type
{
    static NSMutableDictionary *managers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managers = [NSMutableDictionary dictionary];
    });
    
    FWAuthorizeManager *manager = [managers objectForKey:@(type)];
    if (!manager) {
        manager = [[FWAuthorizeManager alloc] initWithType:type];
        [managers setObject:manager forKey:@(type)];
    }
    // 内部object对象不存在时返回nil
    return manager.object ? manager : nil;
}

- (instancetype)initWithType:(FWAuthorizeType)type
{
    self = [super init];
    if (self) {
        _object = [self factory:type];
    }
    return self;
}

- (id<FWAuthorizeProtocol>)factory:(FWAuthorizeType)type
{
    id<FWAuthorizeProtocol> object = nil;
    switch (type) {
        case FWAuthorizeTypeLocationWhenInUse:
            object = [[FWAuthorizeLocation alloc] initWithIsAlways:NO];
            break;
        case FWAuthorizeTypeLocationAlways:
            object = [[FWAuthorizeLocation alloc] initWithIsAlways:YES];
            break;
#if FWCOMPONENT_MICROPHONE_ENABLED
        case FWAuthorizeTypeMicrophone:
            object = [[FWAuthorizeMicrophone alloc] init];
            break;
#endif
        case FWAuthorizeTypePhotoLibrary:
            object = [[FWAuthorizePhotoLibrary alloc] init];
            break;
        case FWAuthorizeTypeCamera:
            object = [[FWAuthorizeCamera alloc] init];
            break;
#if FWCOMPONENT_CONTACTS_ENABLED
        case FWAuthorizeTypeContacts:
            object = [[FWAuthorizeContacts alloc] init];
            break;
#endif
#if FWCOMPONENT_CALENDAR_ENABLED
        case FWAuthorizeTypeCalendars:
            object = [[FWAuthorizeEventKit alloc] initWithType:EKEntityTypeEvent];
            break;
        case FWAuthorizeTypeReminders:
            object = [[FWAuthorizeEventKit alloc] initWithType:EKEntityTypeReminder];
            break;
#endif
#if FWCOMPONENT_APPLEMUSIC_ENABLED
        case FWAuthorizeTypeAppleMusic:
            object = [[FWAuthorizeAppleMusic alloc] init];
            break;
#endif
        case FWAuthorizeTypeNotifications:
            object = [[FWAuthorizeNotifications alloc] init];
            break;
#if FWCOMPONENT_TRACKING_ENABLED
        case FWAuthorizeTypeTracking:
            object = [[FWAuthorizeTracking alloc] init];
            break;
#endif
        default:
            break;
    }
    return object;
}

- (FWAuthorizeStatus)authorizeStatus
{
    if (self.object) {
        return [self.object authorizeStatus];
    }
    return FWAuthorizeStatusNotDetermined;
}

- (void)authorizeStatus:(void (^)(FWAuthorizeStatus))completion
{
    if (self.object) {
        if ([self.object respondsToSelector:@selector(authorizeStatus:)]) {
            [self.object authorizeStatus:completion];
        } else {
            if (completion) {
                completion([self.object authorizeStatus]);
            }
        }
    }
}

- (void)authorize:(void (^)(FWAuthorizeStatus status))completion
{
    if (self.object) {
        [self.object authorize:completion];
    }
}

@end
