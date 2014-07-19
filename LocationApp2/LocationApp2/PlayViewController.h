//
//  PlayViewController.h
//  LocationApp2
//
//  Created by 三井 由登 on 2014/05/08.
//  Copyright (c) 2014年 mitsui yoshito. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMDatabase.h"

#import <CoreLocation/CoreLocation.h>

#import <AVFoundation/AVFoundation.h>

//画面遷移のためにResultViewController,GoalViewControllerのヘッダーファイルを読み込む
#import "ResultViewController.h"
#import "GoalViewController.h"

@interface PlayViewController : UIViewController<CLLocationManagerDelegate>{
    CLLocationManager *lm;
    IBOutlet UILabel *latLabel;
    IBOutlet UILabel *lngLabel;
    IBOutlet UILabel *speedLabel;
    IBOutlet UILabel *averageLabel;
    IBOutlet UILabel *statusLabel;
    IBOutlet UILabel *targetSpeedLabel;
    
    NSTimer *updateTimer;
    NSTimer *courseTimer;
    FMResultSet *queryResult;
    int nextRunCourseId;
    double runCourseSpeed;
    AVAudioPlayer *audioPlayer;
    int level;
    int gameId;
    int storyId;
    IBOutlet UILabel *levelLabel;

    IBOutlet UIButton *endButton;

}


@end
