//
// Created by Fedor Shubin on 5/20/13.
//

#include "CCSoomlaNdkBridge.h"
#include "CCSoomlaJsonHelper.h"

USING_NS_CC;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    #include "../cocos2dx/platform/android/jni/JniHelper.h"
    #include <jni.h>
    #include <string>
    #include "CCSoomla.h"

    #define CLASS_NAME "com/soomla/cocos2dx/store/SoomlaNDKGlue"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#import "CCSoomlaNdkBridgeIos.h"

#endif

namespace soomla {
    extern "C"
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    // Method for receiving NDK messages
    void Java_com_soomla_cocos2dx_store_SoomlaNDKGlue_cppNativeCallHandler(JNIEnv* env, jobject thiz, jstring json)
    {
        std::string jsonString = JniHelper::jstring2string(json);
        const char *jsonCharArray = jsonString.c_str();

        json_error_t error;
        json_t *root;
        root = json_loads(jsonCharArray, 0, &error);

        if (!root)
        {
            fprintf(stderr, "error: at line #%d: %s\n", error.line, error.text);
            return;
        }

        cocos2d::CCObject *dataToPass = CCSoomlaJsonHelper::getCCObjectFromJson(root);
        soomla::CCSoomla::sharedSoomla()->easyNDKCallBack((cocos2d::CCDictionary *)dataToPass);

        json_decref(root);
    }
#endif

    cocos2d::CCObject *CCSoomlaNdkBridge::callNative(cocos2d::CCDictionary *params, CCSoomlaError **pError) {
        cocos2d::CCDictionary *methodParams = params;

        json_t *toBeSentJson = CCSoomlaJsonHelper::getJsonFromCCObject(methodParams);
        json_t *retJsonParams;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        JniMethodInfo t;

		if (JniHelper::getStaticMethodInfo(t,
                                           CLASS_NAME,
                                           "receiveCppMessage",
                                           "(Ljava/lang/String;)Ljava/lang/String;")) {

            char* jsonStrLocal = json_dumps(toBeSentJson, JSON_COMPACT | JSON_ENSURE_ASCII);
            string jsonStr(jsonStrLocal);
            free(jsonStrLocal);

            jstring stringArg1 = t.env->NewStringUTF(jsonStr.c_str());
            jstring retString = (jstring) t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg1);

            t.env->DeleteLocalRef(stringArg1);
			t.env->DeleteLocalRef(t.classID);

		    const char *nativeString = t.env->GetStringUTFChars(retString, 0);
		    string retParamsStr(nativeString);
		    t.env->ReleaseStringUTFChars(retString, nativeString);


            const char *jsonCharArray = retParamsStr.c_str();

            json_error_t error;
            retJsonParams = json_loads(jsonCharArray, 0, &error);

            if (!retJsonParams) {
                fprintf(stderr, "error: at line #%d: %s\n", error.line, error.text);
                return CCDictionary::create();
            }
		}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        retJsonParams = soomla::CCSoomlaNdkBridgeIos::receiveCppMessage(toBeSentJson);
#endif

        json_decref(toBeSentJson);
        CCObject *retParams = CCSoomlaJsonHelper::getCCObjectFromJson(retJsonParams);

        CCSoomlaError *error = CCSoomlaError::createWithObject(retParams);
        if (error != NULL) {
            *pError = error;
        }

        return retParams;
    }
    }
}
