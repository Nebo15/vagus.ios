
@class MWFeedItem;
@interface SimpleWebViewController : UIViewController < UIWebViewDelegate>
{
	NSString *url;
	NSString *htmlText;
	NSString *baseUrl;
	BOOL	flgLoad;
	BOOL	flgInternalLink;
    
    MPMoviePlayerViewController *streamPlayer;
@private
	UIActivityIndicatorView *progressView;
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) MWFeedItem *itemData;
@property (nonatomic,retain) NSString *url;
@property (readonly) int currentTextSize;
@property (weak) id delegate;

- (SimpleWebViewController *)initWithUrl: (NSString *) u;
- (void)hideAlert:(id)sender;
- (void)loadData;
- (void)clearContent;
- (void)loadContent;
- (void)loadContentByFile:(NSString*)fileName;
- (void)loadContentByHtmlText:(NSString*)html;
- (void)loadContentWithItem:(MWFeedItem*)item;
- (void)changeFontSizeToProcent:(NSNumber*)size;
- (NSString*)prepareHtmlTextForItem:(MWFeedItem*)feedItem;
- (void)refresh;

@end
