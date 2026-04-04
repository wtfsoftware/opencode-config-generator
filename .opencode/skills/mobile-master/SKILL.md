---
name: mobile-master
description: Build performant mobile applications with React Native. Covers architecture, navigation, native modules, performance optimization, offline support, and app store deployment.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: mobile
  category: frontend
---

# Mobile Master

## What I Do

I help build performant, native-quality mobile applications using React Native. I ensure smooth animations, proper navigation, offline support, and successful app store deployment.

## React Native Architecture

### Bridge vs JSI
```
Old Architecture (Bridge):
┌──────────┐    JSON messages    ┌──────────┐
│   JS     │ ←─────────────────→ │  Native  │
│ Thread   │    (async, batched) │  Thread  │
└──────────┘                     └──────────┘
  Slow for frequent calls

New Architecture (JSI - JavaScript Interface):
┌──────────┐    Direct C++ calls   ┌──────────┐
│   JS     │ ←───────────────────→ │  Native  │
│ Thread   │    (sync, no bridge)  │  Thread  │
└──────────┘                       └──────────┘
  Fast, synchronous calls

Fabric (new rendering):
- Synchronous rendering
- Priority-based updates
- Better concurrency support

TurboModules (new native modules):
- Lazy-loaded (only when needed)
- Type-safe with Codegen
- Better performance
```

### Project Structure
```
src/
├── components/       # Reusable UI components
│   ├── Button/
│   ├── Card/
│   └── Input/
├── screens/          # Screen components
│   ├── HomeScreen/
│   ├── ProfileScreen/
│   └── SettingsScreen/
├── navigation/       # Navigation configuration
│   ├── AppNavigator.tsx
│   └── AuthNavigator.tsx
├── store/            # State management
│   ├── userStore.ts
│   └── appStore.ts
├── services/         # API, storage, analytics
│   ├── api.ts
│   ├── storage.ts
│   └── analytics.ts
├── hooks/            # Custom hooks
│   ├── useAuth.ts
│   └── useDebounce.ts
├── utils/            # Helpers
│   ├── formatting.ts
│   └── validation.ts
├── constants/        # Theme, config
│   ├── theme.ts
│   └── config.ts
└── types/            # TypeScript types
    └── index.ts
```

## Navigation

### React Navigation
```tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function HomeTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="Home" 
          component={HomeTabs} 
          options={{ headerShown: false }}
        />
        <Stack.Screen 
          name="Detail" 
          component={DetailScreen}
          options={({ route }) => ({ title: route.params.title })}
        />
        <Stack.Screen 
          name="Modal" 
          component={ModalScreen}
          options={{ presentation: 'modal' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// Navigation with params
navigation.navigate('Detail', { id: '123', title: 'Product Name' });

// Access params
const { id, title } = route.params;

// Go back
navigation.goBack();

// Replace current screen
navigation.replace('Login');

// Reset navigation stack
navigation.reset({
  index: 0,
  routes: [{ name: 'Home' }],
});
```

### Deep Linking
```tsx
const linking = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Home: 'home',
      Detail: 'product/:id',
      Profile: 'profile/:userId',
    },
  },
};

<NavigationContainer linking={linking}>
  <AppNavigator />
</NavigationContainer>

// Open URL
Linking.openURL('myapp://product/123');
```

## State Management

### Zustand (Recommended for Mobile)
```tsx
import { create } from 'zustand';

interface UserStore {
  user: User | null;
  token: string | null;
  setUser: (user: User, token: string) => void;
  logout: () => void;
}

const useUserStore = create<UserStore>((set) => ({
  user: null,
  token: null,
  setUser: (user, token) => set({ user, token }),
  logout: () => set({ user: null, token: null }),
}));

// Persist to storage
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

const useUserStore = create(
  persist<UserStore>(
    (set) => ({
      user: null,
      token: null,
      setUser: (user, token) => set({ user, token }),
      logout: () => set({ user: null, token: null }),
    }),
    {
      name: 'user-storage',
      storage: createJSONStorage(() => ({
        getItem: (key) => storage.getString(key) ?? null,
        setItem: (key, value) => storage.set(key, value),
        removeItem: (key) => storage.delete(key),
      })),
    }
  )
);
```

### TanStack Query for Server State
```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

function useProducts() {
  return useQuery({
    queryKey: ['products'],
    queryFn: () => api.getProducts(),
    staleTime: 5 * 60 * 1000,
    retry: 2,
  });
}

function useCreateProduct() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateProductInput) => api.createProduct(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
```

## Performance

### FlatList Optimization
```tsx
<FlatList
  data={items}
  renderItem={({ item }) => <ProductCard item={item} />}
  keyExtractor={(item) => item.id}
  
  // Performance props
  initialNumToRender={10}
  maxToRenderPerBatch={5}
  windowSize={5}
  removeClippedSubviews={true}
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  })}
  
  // Memoized renderItem
  renderItem={useCallback(
    ({ item }) => <ProductCard item={item} />,
    []
  )}
  
  // Pull to refresh
  refreshing={isRefreshing}
  onRefresh={handleRefresh}
  
  // End reached (pagination)
  onEndReached={loadMore}
  onEndReachedThreshold={0.5}
  
  // Empty state
  ListEmptyComponent={<EmptyState />}
  ListFooterComponent={isLoading ? <LoadingSpinner /> : null}
/>
```

### Memoization
```tsx
import React, { memo, useCallback, useMemo } from 'react';

const ProductCard = memo(function ProductCard({ product, onPress }: Props) {
  const formattedPrice = useMemo(() => 
    formatCurrency(product.price), 
    [product.price]
  );
  
  const handlePress = useCallback(() => 
    onPress(product.id), 
    [onPress, product.id]
  );
  
  return <TouchableOpacity onPress={handlePress}>...</TouchableOpacity>;
});

// When to memoize:
// ✅ Component renders frequently with same props
// ✅ Expensive re-renders (complex UI, lists)
// ✅ Passed as prop to memoized components
// ❌ Simple components that rarely render
// ❌ Components with always-changing props
```

### Hermes Engine
```
// Hermes is enabled by default in new RN versions
// Benefits:
// - Faster app startup
// - Smaller APK size
// - Lower memory usage
// - Precompiled bytecode

// Verify Hermes is enabled:
// android/app/build.gradle:
//   project.ext.react = [
//     enableHermes: true,
//   ]
```

### Image Optimization
```tsx
import { Image } from 'react-native';

// Always specify dimensions
<Image
  source={{ uri: 'https://cdn.example.com/photo.webp' }}
  style={{ width: 200, height: 200 }}
  resizeMode="cover"
/>

// Use cached images
import FastImage from 'react-native-fast-image';

<FastImage
  source={{
    uri: 'https://cdn.example.com/photo.webp',
    priority: FastImage.priority.high,
    cache: FastImage.cacheControl.immutable,
  }}
  style={{ width: 200, height: 200 }}
/>
```

## Native Modules

### Bridging (Old)
```objc
// iOS (Objective-C)
// MyModule.h
#import <React/RCTBridgeModule.h>
@interface MyModule : NSObject <RCTBridgeModule>
@end

// MyModule.m
#import "MyModule.h"
@implementation MyModule
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(showNativeAlert:(NSString *)message
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      resolve(@"OK");
    }]];
    [self.rootViewController presentViewController:alert animated:YES completion:nil];
  });
}
@end
```

### TurboModules (New)
```typescript
// TypeScript spec (Codegen)
interface Spec extends TurboModule {
  showNativeAlert(message: string): Promise<string>;
  getDeviceBatteryLevel(): Promise<number>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('MyModule');
```

### Platform-Specific Code
```tsx
import { Platform, StyleSheet } from 'react-native';

// Platform module
if (Platform.OS === 'ios') {
  // iOS-specific code
} else if (Platform.OS === 'android') {
  // Android-specific code
}

// Platform.select
const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.select({
      ios: 50,
      android: 30,
      default: 40,
    }),
  },
});

// Platform-specific files
// Component.ios.tsx
// Component.android.tsx
// import { Component } from './Component'; // Auto-resolves
```

## Storage

### MMKV (Fastest)
```tsx
import { MMKV } from 'react-native-mmkv';

export const storage = new MMKV();

// Store
storage.set('user', JSON.stringify(user));
storage.set('token', 'abc123');
storage.set('isLoggedIn', true);

// Retrieve
const user = JSON.parse(storage.getString('user') || '{}');
const token = storage.getString('token');

// Delete
storage.delete('token');

// Listen to changes
const subscriber = storage.addOnValueChangedListener((key) => {
  console.log(`${key} changed`);
});
```

### Secure Storage
```tsx
import * as Keychain from 'react-native-keychain';

// Store securely (Keychain iOS / Keystore Android)
await Keychain.setGenericPassword('auth', token, {
  accessible: Keychain.ACCESSIBLE.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
});

// Retrieve
const credentials = await Keychain.getGenericPassword();
if (credentials) {
  const token = credentials.password;
}

// Delete
await Keychain.resetGenericPassword();
```

## Push Notifications

### Setup
```tsx
import messaging from '@react-native-firebase/messaging';

// Request permission
async function requestPermission() {
  const authStatus = await messaging().requestPermission();
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL;
  
  if (enabled) {
    console.log('Permission granted');
  }
}

// Get FCM token
const token = await messaging().getToken();

// Handle foreground messages
messaging().onMessage(async (remoteMessage) => {
  Alert.alert('Notification', remoteMessage.notification?.body);
});

// Handle background/quit state
messaging().setBackgroundMessageHandler(async (remoteMessage) => {
  console.log('Message handled in background', remoteMessage);
});

// Handle notification tap
messaging().onNotificationOpenedApp((remoteMessage) => {
  // Navigate to relevant screen
  navigation.navigate(remoteMessage.data.screen);
});
```

## Offline Support

### Offline-First Pattern
```tsx
// Cache API responses
async function fetchWithCache<T>(key: string, fetchFn: () => Promise<T>, ttl: number = 300000): Promise<T> {
  const cached = storage.getString(`cache:${key}`);
  
  if (cached) {
    const { data, timestamp } = JSON.parse(cached);
    if (Date.now() - timestamp < ttl) {
      return data;
    }
  }
  
  const data = await fetchFn();
  storage.set(`cache:${key}`, JSON.stringify({ data, timestamp: Date.now() }));
  return data;
}

// Queue mutations for offline
interface PendingMutation {
  id: string;
  type: string;
  data: any;
  timestamp: number;
}

const mutationQueue = new MMKV({ id: 'mutation-queue' });

function queueMutation(mutation: PendingMutation) {
  const queue = JSON.parse(mutationQueue.getString('queue') || '[]');
  queue.push(mutation);
  mutationQueue.set('queue', JSON.stringify(queue));
}

// Sync when online
NetInfo.addEventListener(state => {
  if (state.isConnected) {
    syncPendingMutations();
  }
});
```

## App Store Deployment

### iOS
```
1. Xcode: Product > Archive
2. Validate archive
3. Distribute to App Store Connect
4. Fill in metadata (screenshots, description, keywords)
5. Submit for review
6. Review time: 24-48 hours

Requirements:
- App icon (1024x1024)
- Screenshots for all device sizes
- Privacy policy URL
- App privacy details (data collection)
- Version number and build number
```

### Android
```
1. Generate signed bundle: cd android && ./gradlew bundleRelease
2. Upload AAB to Google Play Console
3. Fill in store listing
4. Set up release track (internal, alpha, beta, production)
5. Submit for review
6. Review time: 1-7 days

Requirements:
- App icon (512x512)
- Feature graphic (1024x500)
- Screenshots (phone, tablet)
- Privacy policy
- Content rating questionnaire
```

## When to Use Me

Use this skill when:
- Building React Native applications
- Setting up navigation
- Optimizing FlatList performance
- Implementing offline support
- Creating native modules
- Setting up push notifications
- Managing mobile storage
- Preparing for app store deployment

## Quality Checklist

- [ ] FlatList optimized with proper props
- [ ] Images have explicit dimensions
- [ ] Hermes engine enabled
- [ ] State management split (client vs server)
- [ ] Storage uses MMKV for speed, Keychain for secrets
- [ ] Error boundaries for crash recovery
- [ ] Offline support with queued mutations
- [ ] Push notifications configured
- [ ] Deep linking implemented
- [ ] Platform-specific code handled
- [ ] App icons and screenshots prepared for stores
- [ ] Privacy policy and data collection documented
