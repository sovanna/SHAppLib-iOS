//
//  SHUIRefreshBottom.m
//  SHAppLib
//
//  Created by Sovanna Hing on 08/05/2014.
//  Copyright (c) 2014 Sovanna Hing. All rights reserved.
//

#import "SHUIRefreshBottom.h"

float const UI_REFRESH_BOTTOM_HEIGHT = 44.0;

@interface SHUIRefreshBottom()
@property (nonatomic, strong) UIScrollView *tableView;
@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isSendActions;
@end

@implementation SHUIRefreshBottom

@synthesize tableView = _tableView;
@synthesize refreshView = _refreshView;
@synthesize isRefreshing = _isRefreshing;
@synthesize isSendActions = _isSendActions;
@synthesize delegate = _delegate;

#pragma mark - Init

- (id)initWithTableView:(UIScrollView *)tableView andDelegate:(id)delegate
{
    CGRect frame = CGRectMake(0,
                              0,
                              tableView.frame.size.width,
                              UI_REFRESH_BOTTOM_HEIGHT);
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _tableView = tableView;
        _delegate = delegate;
        
        [_tableView addObserver:self
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        
        [_tableView addObserver:self
                     forKeyPath:@"contentSize"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity setCenter:CGPointMake(floor(self.frame.size.width / 2),
                                        floor(self.frame.size.height / 2))];
        [activity setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [activity startAnimating];
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:activity];
        
        [self addTarget:self
                 action:@selector(dropViewBottomDidBeginRefreshing:)
       forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    [self setTableView:nil];
}

- (void)endRefreshing
{
    [self removeBottomView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    CGFloat offset = [[change objectForKey:@"new"] CGPointValue].y;
    
    if((!self.isRefreshing) && [self.tableView isDragging] && (offset > 0.0)) {
        [self onDragging];
    }
    
    if ([self.tableView isDecelerating] && self.isRefreshing && !self.isSendActions) {
        [self setIsRefreshing:NO];
        [self setIsSendActions:YES];
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - Private

- (void)onDragging
{
    NSInteger currentOffset = self.tableView.contentOffset.y;
    NSInteger maximumOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
    
    if (maximumOffset - currentOffset < -50) {
        [self addBottomView];
    }
}

- (void)dropViewBottomDidBeginRefreshing:(UIControlEvents)sender
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(beginRefreshBottom:)]) {
        [self.delegate beginRefreshBottom:self];
    }
}

#pragma mark - PullBottomRefresh

- (void)addBottomView
{
    [self setIsRefreshing:YES];
    
    [self setRefreshView:[[UIView alloc] init]];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50);
    [self.refreshView setFrame:frame];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] init];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activity startAnimating];
    [activity setCenter:self.refreshView.center];
    
    [self.refreshView addSubview:activity];
    activity = nil;
    
    [(UITableView *)self.tableView setTableFooterView:self.refreshView];
}

- (void)removeBottomView
{
    [self setIsRefreshing:NO];
    [self setIsSendActions:NO];
    
    [self.refreshView removeFromSuperview];
    [self setRefreshView:nil];
    
    [(UITableView *)self.tableView setTableFooterView:nil];
}

@end
