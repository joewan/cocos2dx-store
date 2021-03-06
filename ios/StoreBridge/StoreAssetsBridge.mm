//
// Created by Fedor Shubin on 5/21/13.
//


#import "StoreAssetsBridge.h"
#import "StoreUtils.h"
#import "JSONConsts.h"
#import "VirtualCurrency.h"
#import "VirtualCurrencyPack.h"
#import "SingleUseVG.h"
#import "LifetimeVG.h"
#import "EquippableVG.h"
#import "UpgradeVG.h"
#import "SingleUsePackVG.h"
#import "VirtualCategory.h"
#import "NonConsumableItem.h"


@implementation StoreAssetsBridge

static NSString* TAG = @"SOOMLA StoreAssets";

- (id)initWithStoreAssetsDict:(NSDictionary*)storeAssetsDict andVersion:(int)oVersion{
    self = [super init];
    if(self){
        version = oVersion;
        [self createFromDict:storeAssetsDict];
    }
    return self;
}

- (BOOL)createFromDict:(NSDictionary*)storeAssetsDict {
    LogDebug(TAG, ([NSString stringWithFormat:@"the storeAssets dit is %@", storeAssetsDict]));

    @try {
        NSDictionary* storeInfo = storeAssetsDict;

        NSMutableArray* currencies = [[NSMutableArray alloc] init];
        NSArray* currenciesDicts = [storeInfo objectForKey:JSON_STORE_CURRENCIES];
        for(NSDictionary* currencyDict in currenciesDicts){
            VirtualCurrency* o = [[VirtualCurrency alloc] initWithDictionary: currencyDict];
            [currencies addObject:o];
        }
        virtualCurrenciesArray = currencies;

        NSMutableArray* currencyPacks = [[NSMutableArray alloc] init];
        NSArray* currencyPacksDicts = [storeInfo objectForKey:JSON_STORE_CURRENCYPACKS];
        for(NSDictionary* currencyPackDict in currencyPacksDicts){
            VirtualCurrencyPack* o = [[VirtualCurrencyPack alloc] initWithDictionary: currencyPackDict];
            [currencyPacks addObject:o];
        }
        virtualCurrencyPacksArray = currencyPacks;


        NSDictionary* goodsDict = [storeInfo objectForKey:JSON_STORE_GOODS];
        NSArray* suGoods = [goodsDict objectForKey:JSON_STORE_GOODS_SU];
        NSArray* ltGoods = [goodsDict objectForKey:JSON_STORE_GOODS_LT];
        NSArray* eqGoods = [goodsDict objectForKey:JSON_STORE_GOODS_EQ];
        NSArray* upGoods = [goodsDict objectForKey:JSON_STORE_GOODS_UP];
        NSArray* paGoods = [goodsDict objectForKey:JSON_STORE_GOODS_PA];
        NSMutableArray* goods = [[NSMutableArray alloc] init];
        for(NSDictionary* gDict in suGoods){
            SingleUseVG* g = [[SingleUseVG alloc] initWithDictionary: gDict];
            [goods addObject:g];
        }
        for(NSDictionary* gDict in ltGoods){
            LifetimeVG* g = [[LifetimeVG alloc] initWithDictionary: gDict];
            [goods addObject:g];
        }
        for(NSDictionary* gDict in eqGoods){
            EquippableVG* g = [[EquippableVG alloc] initWithDictionary: gDict];
            [goods addObject:g];
        }
        for(NSDictionary* gDict in upGoods){
            UpgradeVG* g = [[UpgradeVG alloc] initWithDictionary: gDict];
            [goods addObject:g];
        }
        for(NSDictionary* gDict in paGoods){
            SingleUsePackVG* g = [[SingleUsePackVG alloc] initWithDictionary: gDict];
            [goods addObject:g];
        }
        virtualGoodsArray = goods;

        NSMutableArray* categories = [[NSMutableArray alloc] init];
        NSArray* categoriesDicts = [storeInfo objectForKey:JSON_STORE_CATEGORIES];
        for(NSDictionary* categoryDict in categoriesDicts){
            VirtualCategory* c = [[VirtualCategory alloc] initWithDictionary: categoryDict];
            [categories addObject:c];
        }
        virtualCategoriesArray = categories;

        NSMutableArray* nonConsumables = [[NSMutableArray alloc] init];
        NSArray* nonConsumableItemsDict = [storeInfo objectForKey:JSON_STORE_NONCONSUMABLES];
        for(NSDictionary* nonConsumableItemDict in nonConsumableItemsDict){
            NonConsumableItem* non = [[NonConsumableItem alloc] initWithDictionary:nonConsumableItemDict];
            [nonConsumables addObject:non];
        }
        nonConsumablesArray = nonConsumables;

        return YES;
    } @catch (NSException* ex) {
        LogError(TAG, @"An error occured while trying to parse store assets JSON.");
    }

    return NO;
}

- (int)getVersion{
    return version;
}

- (NSArray*)virtualCurrencies{
    return virtualCurrenciesArray;
}

- (NSArray*)virtualGoods{
    return virtualGoodsArray;
}

- (NSArray*)virtualCurrencyPacks{
    return virtualCurrencyPacksArray;
}

- (NSArray*)virtualCategories{
    return virtualCategoriesArray;
}

- (NSArray*)nonConsumableItems {
    return nonConsumablesArray;
}

- (void)dealloc {
    [virtualCurrenciesArray release];
    [virtualGoodsArray release];
    [virtualCurrencyPacksArray release];
    [virtualCategoriesArray release];
    [nonConsumablesArray release];
    [super dealloc];
}
@end