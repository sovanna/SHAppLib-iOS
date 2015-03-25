//
//  KeychainHandler.m
//  SHAppLib
//
//  Created by Sovanna Hing on 01/05/2014.
//
//  Copyright (c) 2014, Sovanna Hing.
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

#import "KeychainHandler.h"
#import "KeychainItemWrapper.h"

@implementation KeychainHandler

+ (void)storeCredentialsWithPseudo:(NSString *)pseudo andPassword:(NSString *)password
{
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundle
                                                                            accessGroup:nil];
    [keychainItem resetKeychainItem];
    [keychainItem setObject:pseudo forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:password forKey:(__bridge id)(kSecValueData)];
}

+ (void)resetCredentials
{
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundle
                                                                            accessGroup:nil];
    
    [keychainItem resetKeychainItem];
}

+ (NSDictionary *)storedCredentials;
{
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundle
                                                                            accessGroup:nil];
    
    NSString *pseudo = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    
    if ([pseudo isEqualToString:@""] && [password isEqualToString:@""]) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            pseudo, @"pseudo",
            password, @"password", nil];
}

@end