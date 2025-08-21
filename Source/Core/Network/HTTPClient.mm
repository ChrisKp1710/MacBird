#import "HTTPClient.h"
#include <iostream>

@implementation HTTPClient

- (void)fetchURL:(NSString*)urlString completion:(HTTPClientCompletion)completion {
    std::cout << "🌐 HTTP: Starting request to " << [urlString UTF8String] << std::endl;
    
    // Verifica che l'URL sia valido
    NSURL* url = [NSURL URLWithString:urlString];
    if (!url) {
        std::cout << "❌ HTTP: Invalid URL format" << std::endl;
        NSError* error = [NSError errorWithDomain:@"HTTPClientError" 
                                             code:1001 
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL format"}];
        completion(nil, error);
        return;
    }
    
    // Crea la richiesta HTTP
    NSURLRequest* request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:10.0];
    
    // Crea sessione HTTP
    NSURLSession* session = [NSURLSession sharedSession];
    
    // Invia richiesta asincrona
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request 
                                            completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        // Gestisce errore di rete
        if (error) {
            std::cout << "❌ HTTP: Network error - " << [[error localizedDescription] UTF8String] << std::endl;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        // Verifica risposta HTTP
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            std::cout << "📡 HTTP: Response " << [httpResponse statusCode] << std::endl;
            
            if (httpResponse.statusCode >= 400) {
                NSError* httpError = [NSError errorWithDomain:@"HTTPClientError" 
                                                         code:httpResponse.statusCode 
                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Error %ld", httpResponse.statusCode]}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, httpError);
                });
                return;
            }
        }
        
        // Converte data in stringa
        if (data) {
            NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            std::cout << "✅ HTTP: Downloaded " << [data length] << " bytes" << std::endl;
            
            // Torna al main thread per aggiornare UI
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(content, nil);
            });
        } else {
            std::cout << "⚠️ HTTP: Empty response" << std::endl;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@"", nil);
            });
        }
    }];
    
    // Avvia il task
    [task resume];
}

@end
