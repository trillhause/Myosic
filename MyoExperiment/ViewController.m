//
//  ViewController.m
//  MyoExperiment
//
//  Created by Gab on 2014-10-18.
//  Copyright (c) 2014 Gab Labs. All rights reserved.
//

#import "ViewController.h"
#import <MyoKit/MyoKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

    BOOL state = NO;
    double start, volume;
    BOOL justOnce = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.isLocked = YES;
    [self.syncLabel setHidden:YES];
    [self viewDidAppear:YES];
    
    self.gestureImage.contentMode = UIViewContentModeScaleAspectFit;
    self.gestureImage.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeArm:)
                                                 name:TLMMyoDidReceiveArmRecognizedEventNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoseArm:)
                                                 name:TLMMyoDidReceiveArmLostEventNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoseChange:) name:TLMMyoDidReceivePoseChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveOrientationEvent:) name:TLMMyoDidReceiveOrientationEventNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    
    self.myPlayer = [MPMusicPlayerController systemMusicPlayer];
    [self.myPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];

    // start playing from the beginning of the queue
    
    MPMediaItem *current = self.myPlayer.nowPlayingItem;
    
    MPMediaItemArtwork *artwork = [current valueForProperty:MPMediaItemPropertyArtwork];
    UIImage* artworkImage = [artwork imageWithSize:artwork.bounds.size];
    
    self.backImage.image = artworkImage;
    self.backImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backImage.clipsToBounds = YES;
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(0, 0, 1, 1)];
    // assign a playback queue containing all media items on the device
    [self.view addSubview:volumeView];
    [self.view sendSubviewToBack:volumeView];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)didConnectDevice:(NSNotification *)notification {
    [self.connectButton setHidden:YES];
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    [self.syncLabel setHidden:YES];
    [self.connectButton setHidden:NO];
}


- (void)didRecognizeArm:(NSNotification *)notification {
    [self.syncLabel setHidden:YES];
    [self.connectButton setHidden:YES];
}

- (void)didLoseArm:(NSNotification *)notification {
    [self.syncLabel setHidden:NO];
    [self.connectButton setHidden:YES];
   }

-(void)didReceiveOrientationEvent: (NSNotification*)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    if (self.isFist) {
        if (justOnce) {
            start = angles.roll.radians;
            volume = self.myPlayer.volume;
            justOnce = NO;
        }
        
        self.angle = (angles.roll.radians - start)*0.1;
        if (self.angle >= (1.0 - volume)*0.1) {
            self.angle = (1.0 - volume)*0.1;
        }
        else if(self.angle <= -0.1 * volume) {
            self.angle = -0.1 * volume;
        }
        
        self.myPlayer.volume += self.angle;
        
    }
    

}


- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
    TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    
    // Get the acceleration vector from the accelerometer event.
    GLKVector3 accelerationVector = accelerometerEvent.vector;
    
    // Calculate the magnitude of the acceleration vector.
    float magnitude = GLKVector3Length(accelerationVector);
    
    // Update the progress bar based on the magnitude of the acceleration vector.
     
}

#pragma mark - Helper Methods

-(BOOL) togglePlayPause: (BOOL) state{
    NSLog(@"%i",state);
    if(state)
    {
        [self.myPlayer pause];
        return NO;
    }
    else
    {
        [self.myPlayer play];
        return YES;
    }
    
}

-(void) keepTheState: (BOOL) state {
    if(state)
    {
        [self.myPlayer play];
    }
    else
    {
        [self.myPlayer pause];
    }
}

- (UIImage *)artworkImageForArtwork:(MPMediaItemArtwork *)artwork {
    
    UIImage* artworkImage = [artwork imageWithSize:artwork.bounds.size];
    if (artworkImage == nil) {
        artworkImage = [UIImage imageNamed:@"default.jpg"];
    }
    return artworkImage;
}

- (CGImageRef)blurredImageForArtwork:(UIImage *)artworkImage {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:artworkImage.CGImage];
    
    //setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    //add our blurred image to the scrollview
    return cgImage;
}


-(void)didReceivePoseChange:(NSNotification*)notification {
    //TLMOrientationEvent *orientation = notification.userInfo[kTLMKeyOrientationEvent];
     TLMPose *pose = notification.userInfo[kTLMKeyPose];
    
    self.backImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backImage.clipsToBounds = YES;
    
    
    if (self.isLocked) {
        switch (pose.type) {
            case TLMPoseTypeUnknown:
            case TLMPoseTypeThumbToPinky:
                self.isLocked = NO;
                self.gestureImage.image = [UIImage imageNamed:@"pinky.png"];
                [[[TLMHub sharedHub] myoDevices][0] vibrateWithLength:TLMVibrationLengthShort];
                [[[TLMHub sharedHub] myoDevices][0] vibrateWithLength:TLMVibrationLengthShort];
                break;
            case TLMPoseTypeFingersSpread:
            case TLMPoseTypeFist:
            case TLMPoseTypeWaveIn:
            case TLMPoseTypeWaveOut: self.gestureImage.image = [UIImage imageNamed:@"pinky.png"];
                break;
                case TLMPoseTypeRest: self.gestureImage.image = nil;
                break;
        }
    }

    else{

        switch (pose.type) {
            case TLMPoseTypeUnknown:
            case TLMPoseTypeFingersSpread: self.gestureImage.image = [UIImage imageNamed:@"spread.png"];
                state = [self togglePlayPause:state];
                break;
            case TLMPoseTypeFist: self.gestureImage.image = [UIImage imageNamed:@"fist.png"];
                self.isFist = YES;
                justOnce = YES;
            break;
            case TLMPoseTypeRest: self.gestureImage.image = nil;
                self.isFist = NO;
            break;
        case TLMPoseTypeThumbToPinky: self.gestureImage.image = [UIImage imageNamed:@"pinky.png"];
            self.isLocked = YES;
            [[[TLMHub sharedHub] myoDevices][0] vibrateWithLength:TLMVibrationLengthShort];
            break;
            case TLMPoseTypeWaveIn: {
                self.gestureImage.image = [UIImage imageNamed:@"in.png"];
            [self.myPlayer skipToNextItem];
                 MPMediaItem *current = self.myPlayer.nowPlayingItem;
                UIImage *artworkImage = [self artworkImageForArtwork:[current valueForProperty:MPMediaItemPropertyArtwork]];
                CGImageRef blurredArtworkImage = [self blurredImageForArtwork:artworkImage];
                self.mainImage.image =artworkImage;
                self.backImage.image =[UIImage imageWithCGImage:blurredArtworkImage];
                
                
            [self keepTheState:state];
            break;
            }
            case TLMPoseTypeWaveOut: {
            self.gestureImage.image = [UIImage imageNamed:@"out.png"];
            [self.myPlayer skipToPreviousItem];
                 MPMediaItem *current = self.myPlayer.nowPlayingItem;
                UIImage *artworkImage = [self artworkImageForArtwork:[current valueForProperty:MPMediaItemPropertyArtwork]];
                CGImageRef blurredArtworkImage = [self blurredImageForArtwork:artworkImage];
                self.mainImage.image =artworkImage;
                self.backImage.image =[UIImage imageWithCGImage:blurredArtworkImage];
            [self keepTheState:state];
            break;
            }
    }
 
    }
}

- (IBAction)didTapSettings:(UIButton *)sender {

    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    
    [self presentViewController:controller animated:YES completion:nil];
    
//    [[TLMHub sharedHub] attachToAny];
}
@end
