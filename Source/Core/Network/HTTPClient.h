#ifndef HTTPCLIENT_H
#define HTTPCLIENT_H

#import <Foundation/Foundation.h>

// Definisce il tipo di callback che useremo
typedef void (^HTTPClientCompletion)(NSString* _Nullable content, NSError* _Nullable error);

@interface HTTPClient : NSObject

// Scarica contenuto da URL
// _Nonnull = parametro obbligatorio (non può essere null)
// completion è obbligatoria, URL è obbligatorio
- (void)fetchURL:(NSString* _Nonnull)urlString 
      completion:(HTTPClientCompletion _Nonnull)completion;

@end

#endif
