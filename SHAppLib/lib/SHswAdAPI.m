//
//  SHswAdAPI.m
//  SHAppLib
//
//  Created by Sovanna Hing on 29/10/2013.
//
//  Copyright (c) 2013, Sovanna Hing.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "SHswAdAPI.h"
#import "SHConstant.h"
#import "SHTools.h"
#import "swAdAPI.h"

@interface SHswAdAPI() <swelenDelegate>
@property (nonatomic) AD_POSITION position;
@end


@implementation SHswAdAPI

@synthesize fixedAdView = _fixedAdView;
@synthesize slotID = _slotID;
@synthesize delegate = _delegate;

@synthesize position = _position;

- (id)initWithBannerSlotID:(NSString *)slotdID
                      onView:(UIView *)view
                  toPosition:(AD_POSITION)position
{
    self = [super init];
    if (self) {
        [self setSlotID:slotdID];
        [self setPosition:position];
        
        if (!self.slotID || !view || self.position == 0) {
            [NSException
             raise:@"Invalid entries"
             format:@"Invalid entries - All param have to be set and valid"];
        }
        
        // CREATE VIEW FOR AD
        NSInteger height = [SHTools isIphone] ? kAd_IPHONE_HEIGHT : kAd_IPAD_HEIGHT;
        
        NSInteger posY = 0;
        if (AD_POSITION_BOTTOM) {
            posY = view.frame.size.height - kAd_IPHONE_HEIGHT;
        }
        
        CGRect frame = CGRectMake(0,
                                  (CGFloat)posY,
                                  [UIScreen mainScreen].bounds.size.width,
                                  (CGFloat)height);
        
        UIView *viewAd = [[UIView alloc] initWithFrame:frame];
        [self setFixedAdView:viewAd];
        [self.fixedAdView setHidden:YES];
        
        // ADD AD VIEW TO THE DESIRED VIEW 
        [view addSubview:self.fixedAdView];
        
        // LAUNCH Swelen SDK
        [[swAdMain sharedSwAd] runWithSlot:self.slotID
                                  delegate:self
                                  attachTo:self.fixedAdView];
    }
    
    return self;
}

- (id)initWithOverlaySlotID:(NSString *)slotID
{
    self = [super init];
    if (self) {
        [self setSlotID:slotID];
        
        if (!self.slotID) {
            [NSException
             raise:@"Invalid entries"
             format:@"Invalid entries - No slot id found"];
        }
        
        [[swAdMain sharedSwAd] runWithSlot:self.slotID delegate:self];
    }
    
    return self;
}

- (void)deleteAd
{
    self.fixedAdView = nil;
}

#pragma mark - Swelen Delegate

- (void)swAdDidFail:(swAdSlot *)slot args:(id)args
{
    NSString *message = @"";
    
	switch([((NSError *)args) code]) {
		case SW_ERR_NOADS:
            message = @"No Ad to display on the current slot";
            break;
		case SW_ERR_CON:
            message = @"Connection error";
            break;
        case SW_ERR_ALREADY_RUNNING:
            message = @"The Ad is already running";
            break;
        case SW_ERR_BLOCKED:
            message = @"The Ad has been blocked (maybe over ad is running)";
            break;
        case SW_ERR_INTERNAL:
            message = @"Internal error";
            break;
        case SW_ERR_SLOT:
            message = @"Slot UID not found";
            break;
		default:
            message = @"An general error as occurred";
            break;
	}
    
    [self deleteAd];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(didAdMessage:)]) {
        [self.delegate didAdMessage:message];
    }
}

- (void)swAdDidClose:(swAdSlot *)slot args:(id)args
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(didAdClosed)]) {
        [self.delegate didAdClosed];
    }
}

- (void)swAdDidDisplay:(swAdSlot *)slot args:(id)args
{
    [self.fixedAdView setHidden:NO];
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(didAdAppears)]) {
        [self.delegate didAdAppears];
    }
}

@end
