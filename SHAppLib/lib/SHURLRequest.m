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
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableData *response;
@property (nonatomic, strong) id params;
@property (nonatomic, strong) SHURLRequestCompletionHandler block;

+ (SHURLRequest *)initRequestURL:(NSString *)url
                      withParams:(id)params
                   andCompletion:(SHURLRequestCompletionHandler)block;
- (void)getRequest;
- (void)postRequest;
@end

@implementation SHURLRequest

@synthesize url = _url;
@synthesize response = _response;
@synthesize params = _params;
@synthesize block = _block;

#pragma mark -
#pragma mark Public Static Initializer

+ (id)getFromURL:(NSString *)url
      withParams:(id)params
   andCompletion:(SHURLRequestCompletionHandler)block
{
  SHURLRequest *urlRequest = [SHURLRequest initRequestURL:url
                                               withParams:params
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
                                            andCompletion:block];
  [urlRequest postRequest];
  return urlRequest;
}

#pragma mark -
#pragma mark Private

+ (SHURLRequest *)initRequestURL:(NSString *)url
                      withParams:(id)params
                   andCompletion:(SHURLRequestCompletionHandler)block
{
  SHURLRequest *urlRequest = [[[self class] alloc] init];
  [urlRequest setUrl:url];
  [urlRequest setResponse:[[NSMutableData alloc] init]];
  [urlRequest setParams:params];
  [urlRequest setBlock:block];
  
  return urlRequest;
}

- (void)getRequest
{
  if (self.url) {
    if (self.params && [self.params isKindOfClass:[NSString class]]) {
      self.url = [NSString stringWithFormat:@"%@?%@", self.url, self.params];
    } else if (self.params) {
      [NSException
       raise:@"Invalid params value"
       format:@"params of %@ is invalid, must be param1=value1&param2=value2",
       self.params];
    }
    
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
  
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  BOOL isStatusCode = [response respondsToSelector:@selector(statusCode)];
  
  if(!isStatusCode || [(NSHTTPURLResponse *)response statusCode] != 200) {
    [connection cancel];
    if (self.block) self.block(response, 500);
  }
  
  [self.response setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.response appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (self.block) self.block(error, 400);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if (self.block) self.block(self.response, 200);
}

@end
