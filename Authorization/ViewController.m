//
//  ViewController.m
//  Authorization
//
//  Created by 宋晓光 on 25/02/2017.
//  Copyright © 2017 Light. All rights reserved.
//

#import "ViewController.h"

#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>

@interface ViewController () <CLLocationManagerDelegate>

//  Reachability
@property(nonatomic, strong) Reachability *hostReachability;
@property(nonatomic, strong) Reachability *internetReachability;
//  Loction
@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  //  Network
  [self getNetworkStatusByReachability];
  [self getNetworkStatusByStatusBar];
  //  Location
  [self setupLocationAuthorization];
  //  Photo
  [self setupPhotoAuthorization];
  //  Camera
  [self setupCameraAuthorization];
  //  Microphone
  [self setupMicrophoneAuthorization];
  //  Contast
  [self setupContastAuthorization];
  //  Media
  [self setupMediaAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.hostReachability startNotifier];
  [self.internetReachability startNotifier];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.hostReachability stopNotifier];
  [self.internetReachability stopNotifier];
}

- (void)getNetworkStatusByReachability {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reachabilityChanged:)
             name:kReachabilityChangedNotification
           object:nil];
  self.hostReachability =
      [Reachability reachabilityWithHostName:@"www.baidu.com"];
  self.internetReachability = [Reachability reachabilityForInternetConnection];
}

- (void)getNetworkStatusByStatusBar {
  UIApplication *application = [UIApplication sharedApplication];
  NSArray *children = [[[application valueForKeyPath:@"statusBar"]
      valueForKeyPath:@"foregroundView"] subviews];
  NSString *state = nil;
  NSInteger netType = 0;
  for (id child in children) {
    if ([child isKindOfClass:NSClassFromString(
                                 @"UIStatusBarDataNetworkItemView")]) {
      //  获取状态栏
      netType = [[child valueForKeyPath:@"dataNetworkType"] integerValue];
      switch (netType) {
      case 0:
        state = @"无网络";
        break;
      case 1:
        state = @"2G";
        break;
      case 2:
        state = @"3G";
        break;
      case 3:
        state = @"4G";
        break;
      case 5:
        state = @"wifi";
        break;
      default:
        break;
      }
    }
  }
  NSLog(@"网络状态：%@", state);
}

- (void)reachabilityChanged:(NSNotification *)note {
  Reachability *curReach = [note object];
  NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
  [self updateInternetfaceWithReachability:curReach];
  [self getNetworkStatusByStatusBar];
}

- (void)updateInternetfaceWithReachability:(Reachability *)reachability {
  NSString *status = nil;
  NetworkStatus netStatus = [reachability currentReachabilityStatus];
  switch (netStatus) {
  case NotReachable:
    status = @"Not reachable";
    break;
  case ReachableViaWiFi:
    status = @"Reachable via wifi";
    break;
  case ReachableViaWWAN:
    status = @"Reachable via WWAN";
    break;
  default:
    break;
  }
  if (reachability == self.hostReachability) {
    NSLog(@"Host: %@", status);
  }
  if (reachability == self.internetReachability) {
    NSLog(@"Internet: %@", status);
  }
}

- (void)setupLocationAuthorization {
  BOOL isLocation = [CLLocationManager locationServicesEnabled];
  if (!isLocation) {
    NSLog(@"Not turn on the location");
  }
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  [self.locationManager requestAlwaysAuthorization];
  [self.locationManager startUpdatingLocation];
  CLAuthorizationStatus locationAuthorizationStatus =
      [CLLocationManager authorizationStatus];
  switch (locationAuthorizationStatus) {
  case kCLAuthorizationStatusAuthorizedAlways:
    NSLog(@"Location always authorized");
    break;
  case kCLAuthorizationStatusAuthorizedWhenInUse:
    NSLog(@"Location authorized when in use");
    break;
  case kCLAuthorizationStatusDenied:
    NSLog(@"Location denied");
    break;
  case kCLAuthorizationStatusNotDetermined:
    NSLog(@"Location not determined");
    break;
  case kCLAuthorizationStatusRestricted:
    NSLog(@"Location restricted");
    break;
  default:
    break;
  }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
  NSLog(@"%@", locations.lastObject);
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  switch (status) {
  case kCLAuthorizationStatusAuthorizedAlways:
    NSLog(@"Location always authorized");
    break;
  case kCLAuthorizationStatusAuthorizedWhenInUse:
    NSLog(@"Location authorized when in use");
    break;
  case kCLAuthorizationStatusDenied:
    NSLog(@"Location denied");
    break;
  case kCLAuthorizationStatusNotDetermined:
    NSLog(@"Location not determined");
    break;
  case kCLAuthorizationStatusRestricted:
    NSLog(@"Location restricted");
    break;
  default:
    break;
  }
}

- (void)setupPhotoAuthorization {
  PHAuthorizationStatus photoAuthorizationStatus =
      [PHPhotoLibrary authorizationStatus];
  if (photoAuthorizationStatus != PHAuthorizationStatusAuthorized) {
    [PHPhotoLibrary
        requestAuthorization:^(PHAuthorizationStatus photoAuthorizationStatus) {
          switch (photoAuthorizationStatus) {
          case PHAuthorizationStatusAuthorized:
            NSLog(@"Photo authorized");
            break;
          case PHAuthorizationStatusDenied:
            NSLog(@"Photo denied");
            break;
          case PHAuthorizationStatusRestricted:
            NSLog(@"Photo restricted");
            break;
          case PHAuthorizationStatusNotDetermined:
            NSLog(@"Photo not determined");
            break;
          default:
            break;
          }
        }];
  }
}

- (void)setupCameraAuthorization {
  AVAuthorizationStatus cameraAuthorizationStatus =
      [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if (cameraAuthorizationStatus != AVAuthorizationStatusAuthorized) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                               if (granted) {
                                 NSLog(@"Camera authorized");
                               } else {
                                 NSLog(@"Camera denied or restricted");
                               }
                             }];
  }
}

- (void)setupMicrophoneAuthorization {
  AVAuthorizationStatus microphoneAuthorizationStatus =
      [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
  if (microphoneAuthorizationStatus != AVAuthorizationStatusAuthorized) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                             completionHandler:^(BOOL granted) {
                               if (granted) {
                                 NSLog(@"Microphone authorized");
                               } else {
                                 NSLog(@"Microphone denied or restricted");
                               }
                             }];
  }
}

- (void)setupContastAuthorization {
  CNAuthorizationStatus contactAuthorizationStatus =
      [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
  switch (contactAuthorizationStatus) {
  case CNAuthorizationStatusAuthorized: {
    NSLog(@"Authorized:");
  } break;
  case CNAuthorizationStatusDenied: {
    NSLog(@"Denied");
  } break;
  case CNAuthorizationStatusRestricted: {
    NSLog(@"Restricted");
  } break;
  case CNAuthorizationStatusNotDetermined: {
    NSLog(@"NotDetermined");
  } break;
  }
  CNContactStore *contactStore = [[CNContactStore alloc] init];
  [contactStore
      requestAccessForEntityType:CNEntityTypeContacts
               completionHandler:^(BOOL granted, NSError *_Nullable error) {
                 if (granted) {
                   NSLog(@"Contact authorized");
                 } else {
                   NSLog(@"Contact denied or restricted");
                 }
               }];
}

- (void)setupMediaAuthorization {
  MPMediaLibraryAuthorizationStatus mediaAuthorizationStatus =
      [MPMediaLibrary authorizationStatus];
  if (mediaAuthorizationStatus != MPMediaLibraryAuthorizationStatusAuthorized) {
    [MPMediaLibrary
        requestAuthorization:^(
            MPMediaLibraryAuthorizationStatus mediaAuthorizationStatus) {
          switch (mediaAuthorizationStatus) {
          case MPMediaLibraryAuthorizationStatusAuthorized:
            NSLog(@"Media authorized");
            break;
          case MPMediaLibraryAuthorizationStatusDenied:
            NSLog(@"Media denied");
            break;
          case MPMediaLibraryAuthorizationStatusRestricted:
            NSLog(@"Media restricted");
            break;
          case MPMediaLibraryAuthorizationStatusNotDetermined:
            NSLog(@"Media not determined");
            break;
          default:
            break;
          }
        }];
  }
}

//  跳转至权限设置界面
- (IBAction)askForAuthorization:(id)sender {
  [[UIApplication sharedApplication]
                openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                options:@{}
      completionHandler:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:kReachabilityChangedNotification
              object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
