//
//  ViewController.h
//  MyoExperiment
//
//  Created by Gab on 2014-10-18.
//  Copyright (c) 2014 Gab Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MyoKit/MyoKit.h>


@interface ViewController : UIViewController
@property (strong, nonatomic) MPMusicPlayerController *myPlayer;
@property (strong, nonatomic) TLMMyo *myo;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) double angle;
@property (nonatomic) BOOL isFist;
@property (strong, nonatomic) IBOutlet UIImageView *gestureImage;
@property (strong, nonatomic) IBOutlet UIImageView *backImage;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

@property (strong, nonatomic) IBOutlet UIButton *connectButton;

@property (strong, nonatomic) IBOutlet UILabel *syncLabel;

- (IBAction)didTapSettings:(UIButton *)sender;


@end

