//
//  ViewController.h
//  LocationApp2
//
//  Created by 三井 由登 on 2014/02/05.
//  Copyright (c) 2014年 mitsui yoshito. All rights reserved.
//

#import <UIKit/UIKit.h>





#import <CoreLocation/CoreLocation.h>



@interface ViewController : UIViewController<CLLocationManagerDelegate>{

    
    IBOutlet UIButton *lowLevelButton;

}


//-(IBAction)buttonAction:(id)sender;

@end
