

#define SingleH(name) +(instancetype)share##name;

#if __has_feature(objc_arc) // arc

#define SingleM(name) static id _instance;\
+ (instancetype)share##name{\
    _instance = [[self alloc] init];\
    return _instance;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [super allocWithZone:zone];\
    });\
    return _instance;\
}\
- (id)copyWithZone:(NSZone *)zone{\
    return self;\
}\
- (id)mutableCopyWithZone:(NSZone *)zone{\
    return self;\
}

#else
// mrc
#define SingleM(name) static id _instance;\
+ (instancetype)share##name{\
_instance = [[self alloc] init];\
return _instance;\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
_instance = [super allocWithZone:zone];\
});\
return _instance;\
}\
- (id)copyWithZone:(NSZone *)zone{\
return self;\
}\
- (id)mutableCopyWithZone:(NSZone *)zone{\
return self;\
}\
- (oneway void)release{\
}\
- (instancetype)retain{\
    return _instance;\
}\
- (NSUInteger)retainCount{\
    return MAXFLOAT;\
}
#endif

