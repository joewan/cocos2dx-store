//
// Created by Fedor Shubin on 6/23/13.
//


#include "CCSoomlaNdkBridgeIos.h"
#include "cocoa/CCObject.h"
#include "CCSoomlaJsonHelper.h"
#include "CCSoomla.h"
#import "SoomlaNDKGlue.h"

namespace soomla {
    json_t *CCSoomlaNdkBridgeIos::receiveCppMessage(json_t *jsonParams) {
        char *pszJsonParams = json_dumps(jsonParams, JSON_COMPACT | JSON_ENSURE_ASCII);
        NSString *jsonParamsStr = [[NSString alloc] initWithUTF8String: pszJsonParams];
        free(pszJsonParams);

        NSData *jsonParamsData = [jsonParamsStr dataUsingEncoding:NSUTF8StringEncoding];

        //parse out the json data
        NSError* error = nil;
        NSDictionary *dictParams = [NSJSONSerialization
                JSONObjectWithData:jsonParamsData
                           options:kNilOptions
                             error:&error];

        [jsonParamsStr release];
        if (error == nil) {
            NSObject *retParamsNs = [SoomlaNDKGlue dispatchNDKCall:dictParams];

            if (retParamsNs != nil) {
                error = nil;
                NSData *retJsonParamsData = [NSJSONSerialization
                        dataWithJSONObject:retParamsNs
                                   options:NSJSONWritingPrettyPrinted
                                     error:&error];

                if (error == nil) {
                    NSString *retJsonParamsStr = [[NSString alloc] initWithData:retJsonParamsData
                                                                     encoding:NSUTF8StringEncoding];

                    json_error_t jerror;
                    json_t *retJsonParams = json_loads([retJsonParamsStr UTF8String], 0, &jerror);

                    if (retJsonParams) {
                        [retJsonParamsStr release];

                        return retJsonParams;
                    } else {
                        fprintf(stderr, "error: at line #%d: %s\n", jerror.line, jerror.text);
                        return nil;
                    }
                } else {
                    return nil;
                }

            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }

    void CCSoomlaNdkBridgeIos::ndkCallback(json_t *jsonParams) {
        cocos2d::CCObject *dataToPass = CCSoomlaJsonHelper::getCCObjectFromJson(jsonParams);
        CCSoomla::sharedSoomla()->easyNDKCallBack((cocos2d::CCDictionary *)dataToPass);
    }
}