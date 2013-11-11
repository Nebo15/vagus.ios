#import "SimpleWebViewController.h"
#import "MWFeedItem.h"
#import <MediaPlayer/MediaPlayer.h>

#define documentsDirectory_Statement NSString *documentsDirectory; \
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); \
documentsDirectory = [paths objectAtIndex:0];

@implementation SimpleWebViewController

@synthesize url;


- (void)dealloc
{
    [self clearContent];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.webView setBackgroundColor:[UIColor clearColor]];
        [self.webView setOpaque:NO];
    }
    return self;
}

-(SimpleWebViewController *)initWithUrl: (NSString *)u
{
	self = [super initWithNibName:@"SimpleWebViewController" bundle:nil];
    [self clearContent];
    if (u && [u length]>0) {
        [self setUrl:u];
    }
	return self;
}

- (void)webViewDidStartLoad:(UIWebView *)__webView{
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView{
    [self useZoom];
    [self.webView setHidden:NO];
}

-(void) hideAlert:(id)sender{    
    [progressView removeFromSuperview];   
}

-(void)viewDidLoad 
{
	[super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideo) name:@"ApplicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useZoom) name:@"WebZoomDidChange" object:nil];
    [self loadContent];
    [self createRefreshView];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
}

- (void)setUrl:(NSString *)_url{
    if (url == _url) {
        return;
    }
    if (![_url hasPrefix:@"http://"]) {
        _url = [NSString stringWithFormat:@"http://%@",_url];
    }
    url = _url;
    [self loadContent];
}

- (void)loadData{
    [self loadContentWithItem:_itemData];
}

- (void)loadContent{
    if (!url) {
        return;
    }
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
        [self clearContent];
    }
    NSURLRequest *requestObj;
    requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.webView loadRequest:requestObj];
}

- (void)loadContentIfNeed{
    if (!flgLoad) {
        self.webView.delegate = self;
        [self loadContent];
    }
}

- (void)loadContentByFile:(NSString*)fileName{
    [self.webView stopLoading];
    [self clearContent];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];

    NSURL *mainBundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    if (path) {
        NSError *error = nil;
        NSURL *_url = [NSURL fileURLWithPath:path];
        NSString *_html = [NSString stringWithContentsOfURL:_url 
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
        NSString *htmlData = [NSMutableString stringWithString:_html ];
        [self.webView loadHTMLString:htmlData baseURL:mainBundleURL];
    }
}

- (void)loadContentByHtmlText:(NSString*)html{
    [self loadContentWithItem:self.itemData];
}

- (void)loadContentWithItem:(MWFeedItem*)item{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *lastUpdateStr = (item.updated && ![item.identifier hasPrefix:@"urn:news-bbc-co-uk:ws"])?[NSString stringWithFormat:@"Last updated %@",item.updated]:@"";
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\
                      <html class=\"newsArticle\">\
                      <head>\
                      <title></title>\
                      <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\
                      <meta name=\"viewport\" content=\"minimum-scale=1.0, maximum-scale=1.0\">\
                      <link rel=\"stylesheet\" type=\"text/css\" href=\"ArticleStyles.css\">\
                      <link rel=\"stylesheet\" type=\"text/css\" href=\"ArticleLayout-%@.css\">\
                      %@ <!-- This is only used for the Chinese Font Fix -->\
                      \
                      </head>\
                      <body>\
                      <div id=\"content\">\
                      <h1>%@</h1>\
                      <p class=\"updated\">%@</p>\
                      %@\
                      <footer>%@</footer>\
                      </div>\
                      <script type=\"text/javascript\" src=\"news-article.js\"></script>\
                      <script type=\"text/javascript\">\
                      newsArticle.init();\
                      </script>\
                      </body>\
                      </html>",((IS_IPAD)?@"iPad":@"iPhone"),
                      ([self.title hasPrefix:@"Chinese"])?@"<link rel=\"stylesheet\" type=\"text/css\" href=\"ArticleChinese.css\">":@"",
                      (item.title)?item.title:@"",
                      lastUpdateStr,
                      [self prepareHtmlTextForItem:item],
                      [NSString stringWithFormat:@"VAGUS © %@",[self getCurrentYear]]];
    [self.webView loadHTMLString:html baseURL:baseURL];
}

- (NSString*)getCurrentYear{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];

    return [dateformatter stringFromDate:[NSDate date]];
}

- (void)useZoom{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"zoom"]) {
        return;
    }
    float zoom = [[NSUserDefaults standardUserDefaults] floatForKey:@"zoom"];
    [self changeFontSizeToProcent:[NSNumber numberWithFloat:zoom * 200]];
}

- (void)clearContent{
    [self.webView loadHTMLString:@"" baseURL:nil];
    htmlText = nil;
}

- (void)changeFontSizeToProcent:(NSNumber*)procent{
    NSString *jsString = [[NSString alloc]      initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",procent.integerValue];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)createRefreshView{
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.webView.scrollView addSubview:refreshControl];
}

-(void)handleRefresh:(UIRefreshControl *)refresh {
    [self refresh];
    [refresh endRefreshing];
}

-(void)refresh {
    if (self.url) {
        NSURL *_url = [NSURL URLWithString:self.url];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
        [_webView loadRequest:requestObj];
    }else if (_itemData){
        [self loadContentWithItem:_itemData];
    }
}

-(void)back
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)addTitleAndDateForHtml:(NSString*)htmStr withItem:(MWFeedItem*) item{
    NSMutableString *html = [htmStr mutableCopy];
    NSString *insertingStr = [NSString stringWithFormat:@"<p class=\"title\">%@<p class=\"date-created\">Last updated %@</p>",item.title,item.date];
    
    NSRange range = [html rangeOfString:@"\"body\">"];
    if (range.length > 0) {
        [html insertString:insertingStr atIndex:range.location + range.length];
    }
    return html;
}

#pragma mark - Web view delegate method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
	// Intercept the link
    if (navigationType == UIWebViewNavigationTypeOther) {
//        [webView stopLoading];
        
        // Grab the parts of the URL we need
		// <scheme>://<host>#<fragment>
        if ([[[request URL] absoluteString] rangeOfString:@"avod"].length > 0) {
            NSString *urlStr = [NSString stringWithString:[[request URL] absoluteString]];
                urlStr = [urlStr replaceSubStringIn:urlStr withString:@"http://" byRegularExpressionWithPattern:@"bbcvideo://[^/]*/(.*)"];

            NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:nil];
            [self playVideo:str];
        }
        
    }
    
    //  Let other links be handled by the webview.
    return YES;
}


#pragma mark - methods called from web links
- (void)linkIntercept {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)linkInterceptWithArgument:(NSString *)argument {
	// insert code here to make sure argument is something valid for your method
	// and won't cause a crash or load unwanted data (thanks again Mike Ash)
    NSLog(@"%@ %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), argument);
}

- (NSString*)prepareHtmlTextForItem:(MWFeedItem*)feedItem{
    NSString *dirtyHtml = [feedItem.content mutableCopy];
    NSString *overlayImage = @"bbcvideo:";
    
    if ([feedItem.identifier hasPrefix:@"urn:news-bbc-co-uk:ws"]) {
        NSString *imgUrl = [feedItem.media mutableCopy];
        if ([feedItem.identifier hasSuffix:@"newsbulletin"]) {
            imgUrl = @"world_news_summary.jpg";
        }else if ([feedItem.identifier hasSuffix:@"businesssummary"]) {
            imgUrl = @"business_summary.jpg";
        }if ([feedItem.identifier hasSuffix:@"bbcnewssummary"]) {
            imgUrl = @"world_news_bulletin.jpg";
            overlayImage = @"bbcaudio:";
        }if ([feedItem.identifier hasSuffix:@"newshour"]) {
            imgUrl = @"newshour.jpg";
            overlayImage = @"bbcaudio:";
        }if ([feedItem.identifier hasSuffix:@"worldbusinessreport"]) {
            imgUrl = @"world_business_report.jpg";
            overlayImage = @"bbcaudio:";
        }if ([feedItem.identifier hasSuffix:@"businessdaily"]) {
            imgUrl = @"business_daily.jpg";
            overlayImage = @"bbcaudio:";
        }else{
            imgUrl = [imgUrl replaceSubStringIn:imgUrl withString:@"http://" byRegularExpressionWithPattern:@"bbcimage://[^/]*/(.*)"];
            imgUrl = [imgUrl replaceSubStringSeccondIn:imgUrl withString:@"iphone" byRegularExpressionWithPattern:@"%7bdevice%7d"];
            imgUrl = [imgUrl replaceSubStringSeccondIn:imgUrl withString:@"iphone" byRegularExpressionWithPattern:@"%7Bdevice%7D"];
        }
        
        NSString *href = [NSString stringWithFormat:@"%@//www.bbc.co.uk/moira/avod/iphone-retina/av/news/world-us-canada-24272313/news/world/1013000/1013602/wifi",overlayImage];
        
        dirtyHtml = [NSString stringWithFormat:@"<div class=\"fullwidth_img\">\
                     <a href=\"%@\">\
                     <img class=\"fullwidth_640x360\" src=\"%@\" alt=\"Play %@\">\
                     </a>\
                     </div>\
                     <p>%@</p>",href,imgUrl,feedItem.summary,feedItem.summary];
        return dirtyHtml;
    }
    dirtyHtml = [dirtyHtml replaceSubStringIn:dirtyHtml withString:@"http://" byRegularExpressionWithPattern:@"bbcimage://[^/]*/(.*)"];
    dirtyHtml = [dirtyHtml replaceSubStringSeccondIn:dirtyHtml withString:@"iphone" byRegularExpressionWithPattern:@"%7bdevice%7d"];
    dirtyHtml = [dirtyHtml replaceSubStringSeccondIn:dirtyHtml withString:@"iphone" byRegularExpressionWithPattern:@"%7Bdevice%7D"];
    dirtyHtml = [dirtyHtml replaceSubStringSeccondIn:dirtyHtml withString:@"wifi" byRegularExpressionWithPattern:@"%7bbandwidth%7d"];
//    dirtyHtml = [self addTitleAndDateForHtml:dirtyHtml withItem:feedItem];
    return (dirtyHtml)?dirtyHtml:@"";
}

- (void)stopVideo{
    [((UIViewController*)self.delegate) dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)playVideo:(NSString*)videoUrl{
    NSURL *streamURL = [NSURL URLWithString:videoUrl];
    streamPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:streamURL];
    [streamPlayer.view setFrame: self.view.bounds];
    [((UIViewController*)self.delegate) presentMoviePlayerViewControllerAnimated:streamPlayer];
}

@end
