//
//  HelloWorldLayer.h
//  Space Commander
//
//  Created by Adam Mellan on 8/6/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "cocos2d.h"
#import <Foundation/Foundation.h>

@interface MainMenu : CCLayer {
    CCSprite *ccLaunchImage;
    BOOL isCCLaunchImageBeingDisplayedForTheFirstTime;
}
+(CCScene *)mainMenuScene:(BOOL)isCCLaunchImageBeingDisplayedForTheFirstTime;

@end
