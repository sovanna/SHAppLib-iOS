//
//  SHURLRequest.m
//  SHAppLib
//
//  Created by Sovanna Hing on 26/10/2013.
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

#import "SHURLRequest.h"
#import "SHConstant.h"

@interface SHURLRequest()<NSURLConnectionDelegate>
@property (nonatomic) NSString *url;
@property (nonatomic) NSMutableData *response;
@property (nonatomic) id params;
@property (nonatomic) id headers;
@property (nonatomic, strong) SHURLRequestCompletionHandler block;
@property (nonatomic) int statusCode;

+ (SHURLRequest *)initRequestURL:(NSString *)url
                      withParams:(id)params
                     withHeaders:(id)headers
                   andCompletion:(SHURLRequestCompletionHandler)block;
- (void)getRequest;
- (void)postRequest;
@end

@implementation SHURLRequest

@synthesize url = _url;
@synthesize response = _response;
@synthesize params = _params;
@synthesize headers = _headers;
@synthesize block = _block;
@synthesize statusCode = _statusCode;

#pragma mark -
#pragma mark Public Static Initializer

+ (id)getFromURL:(NSString *)url
   andCompletion:(SHURLRequestCompletionHandler)block
{
    SHURLRequest *urlRequest = [SHURLRequest initRequestURL:url
                                                 withParams:nil
                                                withHeaders:nil
                                              andCompletion:block];
    [urlRequest getRequest];
    return urlRequest;
}

+ (id)postToURL:(NSString *)url
     withParams:(id)params
  andCompletion:(SHURLRequestCompletionHandler)block
{
    SHURLRequest *urlRequest = [SHURLRequest initRequestURL:url
                                                 withParams:params
                                                withHeaders:nil
                                              andCompletion:block];
    [urlRequest postRequest];
    return urlRequest;
}

+ (SHURLRequest *)postToURL:(NSString *)url
                 withParams:(id)params
                withHeaders:(id)headers
              andCompletion:(SHURLRequestCompletionHandler)block
{
    SHURLRequest *urlRequest = [SHURLRequest initRequestURL:url
                                                 withParams:params
                                                withHeaders:headers
                                              andCompletion:block];
    [urlRequest postRequest];
    return urlRequest;
}

#pragma mark -
#pragma mark Private

+ (SHURLRequest *)initRequestURL:(NSString *)url
                      withParams:(id)params
                     withHeaders:(id)headers
                   andCompletion:(SHURLRequestCompletionHandler)block
{
    SHURLRequest *urlRequest = [[[self class] alloc] init];
    [urlRequest setResponse:[[NSMutableData alloc] init]];
    if (url) [urlRequest setUrl:url];
    if (params) [urlRequest setParams:params];
    if (block) [urlRequest setBlock:block];
    if (headers) [urlRequest setHeaders:headers];
  
    return urlRequest;
}

#pragma mark -
#pragma mark Request

- (void)getRequest
{
    if (self.url) {
        Log(@"[url called] ~> %@", self.url);
    
        NSURL *url = [NSURL URLWithString:self.url];
        NSURLRequest *request = [NSURLRequest
                                 requestWithURL:url
                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                 timeoutInterval:kREQUEST_TIMEOUT];
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        if (self.block) self.block(nil, 400);
    }
}

- (void)postRequest
{
    if (self.url) {
        Log(@"[url called] ~> %@", self.url);
        NSURL *url = [NSURL URLWithString:self.url];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                        initWithURL:url
                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:kREQUEST_TIMEOUT];
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error) {
            [NSException raise:[error localizedDescription] format:@"Error Post"];
        }
        
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
        [request setHTTPMethod:@"POST"];
        [request setValue:length forHTTPHeaderField:@"Content-length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        
        if (self.headers) {
            for (NSDictionary *h in self.headers) {
                [request setValue:[h objectForKey:@"value"] forHTTPHeaderField:[h objectForKey:@"name"]];
            }
        }
        
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        if (self.block) self.block(nil, 400);
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    BOOL isStatusCode = [response respondsToSelector:@selector(statusCode)];
    
    if(!isStatusCode) {
        [connection cancel];
        if (self.block) self.block(response, 500);
    }
    
    [self setStatusCode:(int)[(NSHTTPURLResponse *)response statusCode]];
    [self.response setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [self.response appendData:data];
}

- (void)connection:(NSURLConnection *)connection
    didFailWithError:(NSError *)error {
    if (self.block) self.block(error, 400);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.block) {
        int statusCode = self.statusCode ? self.statusCode : 200;
        self.block(self.response, statusCode);
    }
}

@end
