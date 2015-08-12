#import <UIKit/UIKit.h>
#import "WeiboConnection.h"
#import "WeiBoUser.h"

typedef enum {
    WEIBO_REQUEST_TIMELINE,
    WEIBO_REQUEST_REPLIES,
    WEIBO_REQUEST_MESSAGES,
    WEIBO_REQUEST_SENT,
    WEIBO_REQUEST_FAVORITE,
    WEIBO_REQUEST_DESTROY_FAVORITE,
    WEIBO_REQUEST_CREATE_FRIENDSHIP,
    WEIBO_REQUEST_DESTROY_FRIENDSHIP,
    WEIBO_REQUEST_FRIENDSHIP_EXISTS,
} RequestType;

@protocol WeiboClientDelegate;

@interface WeiboService : WeiboConnection
{
    RequestType request;
    BOOL        hasError;
    NSString*   errorMessage;
    NSString*   errorDetail;
    BOOL        secureConnection;
    id<WeiboClientDelegate> delegate;
}

@property(nonatomic, readonly) RequestType request;
@property(nonatomic, assign) BOOL hasError;
@property(nonatomic, copy) NSString* errorMessage;
@property(nonatomic, copy) NSString* errorDetail;
@property(nonatomic, assign) id<WeiboClientDelegate> delegate;

- (id)initWithOAuthEngine:(WeiBoAuthEngine *)engine;

- (void)getPublicTimeline;

- (void)getTweet:(long long)tweetId;

- (void)getFollowedTimelineMaximumID:(long long)maxID startingAtPage:(int)page count:(int)count;
- (void)getFollowedTimelineSinceID:(long long)sinceID startingAtPage:(int)pageNum count:(int)count; 
- (void)getFollowedTimelineSinceID:(long long)sinceID withMaximumID:(long long)maxID startingAtPage:(int)pageNum count:(int)count; 

- (void)getUserTimelineMaximumID:(long long)userId maxID:(long long)maxID startingAtPage:(int)page count:(int)count;
- (void)getUserTimelineSinceID:(long long)userId sinceID:(long long)sinceID startingAtPage:(int)page count:(int)count;
- (void)getUserTimelineSinceID:(long long)userId sinceID:(long long)sinceID 
                 withMaximumID:(long long)maxID startingAtPage:(int)page count:(int)count;

- (void)getMentionsMaximumID:(long long)maxID startingAtPage:(int)page count:(int)count;
- (void)getMentionsSinceID:(long long)sinceID startingAtPage:(int)page count:(int)count;
- (void)getMentionsSinceID:(long long)sinceID withMaximumID:(long long)maxID startingAtPage:(int)page count:(int)count;

- (void)favorite:(long long)statusId;
- (void)unfavorite:(long long)statusId;

- (void)getCommentCounts:(NSMutableArray *)statuses;

- (void)getComments:(long long)statusId startingAtPage:(int)page count:(int)count;

- (void)getFriends;
- (void)getFriends:(int)userId cursor:(int)cursor count:(int)count;

- (void)getFollowers:(int)userId cursor:(int)cursor count:(int)count;

- (void)getUser:(long long)userId;

- (void)getUserByScreenName:(NSString *)screenName;

- (void)getFriendship:(int)userId;

- (void)getDialyTrends;
- (void)getWeeklyTrends;

- (void)follow:(int)userId;

- (void)unfollow:(int)userId;

- (void)post:(NSString*)tweet;

- (void)upload:(NSData*)jpeg status:(NSString *)status;

- (void)repost:(long long)statusId isComment:(BOOL)isComment tweet:(NSString*)tweet;

- (void)comment:(long long)statusId commentId:(long long)commentId comment:(NSString*)comment;

- (void)sendDirectMessage:(NSString*)text to:(int)recipientedId;

- (NSString *)getURL:(NSString *)path queryParameters:(NSMutableDictionary*)params;

@end

@protocol WeiboClientDelegate
@optional
- (void)didWeiboClientSucceded:(WeiboService*)weiBoService weiBoObject:(NSObject*)weiBoObject;
- (void)didWeiboClientFailed:(WeiboService*)weiBoService errorMessage:(NSString*)errorMessage errorDetail:(NSString*)errorDetail;
@end
