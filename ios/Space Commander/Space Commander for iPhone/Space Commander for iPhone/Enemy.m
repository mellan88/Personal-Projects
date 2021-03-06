//
//  Enemy.m
//  Scenes
//
//  Created by Chris Reddy on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"
#import "UserShip.h"
#import "SimpleAudioEngine.h"

@interface Enemy ()
@property (nonatomic, retain) NSMutableArray *lasers;

@end

@implementation Enemy
@synthesize target = _target;
@synthesize rate = _rate;
@synthesize delegate = _delegate;
@synthesize lasers = _lasers;
@synthesize health;
@synthesize maxHealth;
@synthesize healthBar;
@synthesize healthBarOutline;
@synthesize healthNum;
@synthesize enemiesArray;
@synthesize dele;
@synthesize projectile;

#pragma mark - Properties

- (CGFloat)rate {
    if (!_rate) {
        _rate = 60.0f;
    }
    return _rate;
}

- (NSMutableArray *)lasers {
    if (!_lasers) {
        _lasers = [[NSMutableArray alloc] init];
    }
    return _lasers;
}

#pragma mark - Update Methods

- (void)turnEnemyTowardsTarget {
    CGPoint offset = ccpSub(self.target.position, self.position);
    self.rotation = -radToDeg(ccpToAngle(offset));
    
    [self healthy];
}

- (void)moveEnemiesTowardsShip {
    float distance = ccpLength(ccpSub(self.target.position, self.position));
    float time = distance / self.rate;
    [self runAction:[CCMoveTo actionWithDuration:time position:self.target.position]];
    
    [self healthy];
}

- (void)deleteLaser:(CCSprite *)laser {
    // this could be a problem if the action isn't cleaned up in shootTarget
    [self.parent removeChild:laser cleanup:YES];
    [self.lasers removeObject:laser];
}

- (void)shootTarget {
    // make sure the target is close
    if (ccpLength(ccpSub(self.target.position, self.position)) > 300) {
        return;
    }
    
    // add laser onto screen
    projectile = [CCSprite spriteWithFile:@"Green_Laser.png"];
    projectile.position = self.position;
    projectile.rotation = self.rotation;
    projectile.scale = 0.3;
    [self.parent addChild:projectile];
    [self.lasers addObject:projectile];
    
    // distance and theta of shot
    float shotDistance = 300;
    float theta = degToRad(-self.rotation);
    
    // calculate x and y coordinates
    CGPoint realPos;
    
    // a = h * cos(0)
    realPos.x = projectile.position.x + shotDistance * cosf(theta);
    // o = h * sin(0)
    realPos.y = projectile.position.y + shotDistance * sinf(theta);
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"Laser.mp3"];
    
    [projectile runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.2f position:realPos], [CCCallFuncN actionWithTarget:self selector:@selector(deleteLaser:)], nil]];
}

- (void)enemyCollisionDetection {
    NSMutableArray *lasersToRemove = [[NSMutableArray alloc] init];
    for (CCSprite *laser in self.lasers) {
        if (CGRectIntersectsRect(laser.boundingBox, self.target.boundingBox)) {
            [lasersToRemove addObject:laser];
            if ([self.delegate conformsToProtocol:@protocol(EnemyDelegate)]) {
                [self.delegate enemyHitTarget];
            }
        }
    }
    
    for (CCSprite *laser in lasersToRemove) {
        [self deleteLaser:laser];
    }
    
    [lasersToRemove release];
}

- (void)update:(ccTime)dt {
    [self turnEnemyTowardsTarget];
    [self enemyCollisionDetection];
}

- (void)activateScheduler {
    [self schedule:@selector(update:)];
    [self schedule:@selector(moveEnemiesTowardsShip) interval:0.1f];
    [self schedule:@selector(shootTarget) interval:arc4random() % 10 + 1];
    //[self schedule:@selector(shoot:) interval:arc4random() % 10 + 1];
}

- (void)deactivateScheduler {
    [self unschedule:@selector(update:)];
    [self unschedule:@selector(moveEnemiesTowardsShip)];
    [self unschedule:@selector(shootTarget)];
    NSLog(@"\n\n\nDeactivated Scheduled Methods\n\n\n");
}

#pragma mark - Factory Method
+ (Enemy *)enemyWithFile:(NSString *)file target:(UserShip *)targ winSize:(CGSize)winSize {
    Enemy *enemy = [Enemy spriteWithFile:file];
    enemy.scale = 0.8;
    CGPoint range;
    range.x = (winSize.width - enemy.contentSize.width) - enemy.contentSize.width;
    range.y = (winSize.height - enemy.contentSize.height) - enemy.contentSize.height;
    
    CGPoint position;
    position.x = arc4random() % (int)range.x + enemy.contentSize.width;
    position.y = arc4random() % (int)range.y + enemy.contentSize.height;
    enemy.position = position;
    
    enemy.target = targ;
    
    [enemy activateScheduler];
    
    return enemy;
}

-(void)destroyAll:(NSMutableArray *)enemies {
    //NSMutableArray *enemiesToRemove = [[NSMutableArray alloc] init];
    //enemiesArray = enemies;
    
    //[self.dele removeChild:self cleanup:YES];
    //[enemiesToRemove addObject:self];
    
    for (Enemy *enemy in enemies) {
        /*CCParticleSystem *system = [CCParticleFire node];
        system.position = enemy.position;
        system.scale = 0.3;
        system.life = 0.3;
        system.duration = 0.3;
        system.autoRemoveOnFinish = YES;
        [enemy.dele addChild:system z:999];*/
        //[enemy.dele removeChild:enemy cleanup:YES];
        //[enemiesToRemove addObject:enemy];
        //[self.target goldIncrease];
    }
    /*for (Enemy *enmy in enemiesToRemove) {
        [enemies removeObject:enmy];
    }
    [enemiesToRemove release];*/
}

-(void)destroy:(NSMutableArray *)enemies withEnmy:(Enemy *)enmy {
    NSMutableArray *enemiesToRemove = [[NSMutableArray alloc] init];
    
    CCParticleSystem *system = [CCParticleFire node];
    system.position = enmy.position;
    system.scale = 0.3;
    system.life = 0.3;
    system.duration = 0.3;
    system.autoRemoveOnFinish = YES;
    [enmy.dele addChild:system z:999];
    [enmy.dele removeChild:enmy cleanup:YES];
    [enemiesToRemove addObject:enmy];
    
    /*for (Enemy *enemy in enemies) {
        CCParticleSystem *system = [CCParticleFire node];
        system.position = enemy.position;
        system.scale = 0.3;
        system.life = 0.3;
        system.duration = 0.3;
        system.autoRemoveOnFinish = YES;
        [enemy.dele addChild:system z:999];
        [enemy.dele removeChild:enemy cleanup:YES];
        [enemiesToRemove addObject:enemy];
        //[self.target goldIncrease];
    }*/
    for (Enemy *enmy in enemiesToRemove) {
        [enemies removeObject:enmy];
    }
    [enemiesToRemove release];
}

-(void)damageTaken {
    NSLog(@"\n\n\nEnemy damageTaken method called!!!!!!!!!!\n\n\n");
    if (self.health > 0) {
        self.health -= self.target.projectileDamage;
        NSLog(@"\n\n\nEnemy is taking damage!!!!!!!!!!\n\n\n");
    }
}

/*-(void)healthBar {
    if (!enemyHealthBar) {
        enemyHealthBar = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Health: %f", self.health] fontName:@"Marker Felt" fontSize:35];
        [self.dele addChild:enemyHealthBar];
    }
    enemyHealthBar.string = [NSString stringWithFormat:@"Health: %f", self.health];
    enemyHealthBar.position = ccp(self.position.x, self.position.y + 40);
}*/

-(void)healthy {
    if (!self.healthBar) {
        self.healthBar = [CCProgressTimer progressWithFile:@"Health_Bar.png"];
        self.healthBar.position = ccp(self.position.x, self.position.y + 40);
        self.healthBar.type = kCCProgressTimerTypeHorizontalBarLR;
        self.healthBar.percentage = self.health;
        self.healthBar.scaleX = 0.49;
        self.healthBar.scaleY = 0.4;
        [self.dele addChild:self.healthBar z:3];
        
        self.healthBarOutline = [CCSprite spriteWithFile:@"Health_Bar_Outline.png"];
        self.healthBarOutline.position = self.healthBar.position;
        self.healthBarOutline.scale = 0.5;
        [self.dele addChild:self.healthBarOutline z:2];
        
        self.healthNum = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%2f",self.health] fontName:@"Marker Felt" fontSize:15];
        self.healthNum.position = self.healthBarOutline.position;
        //[self.dele addChild:self.healthNum z:4];
        
    }
    self.healthBar.position = ccp(self.position.x, self.position.y + 40);
    self.healthBar.percentage = (self.health/self.maxHealth) *100;
    self.healthBarOutline.position = self.healthBar.position;
    //self.healthNum.position = self.healthBarOutline.position;
    //self.healthNum.string = [NSString stringWithFormat:@"%2f",self.health];
}

-(id)init {
    if (self = [super init]) {
        //[self setHealth:2];
        //NSLog(@"%f",health);
        //[self setMaxHealth:10];
        //[self performSelector:@selector(deactivateScheduler) withObject:nil afterDelay:15];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
    [_target release]; _target = nil;
    [_lasers release]; _lasers = nil;
    [super dealloc];
}

@end
