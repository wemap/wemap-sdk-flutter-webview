# flutter_wemap_sdk

A Flutter plugin to display wemap's livemap.

## Getting Started

#### installation

- Create new flutter application
```
flutter create sample_flutter_wemap_sdk && cd sample_flutter_wemap_sdk
```

- Add flutter_wemap_sdk plugin to your pubspec.yaml `dependencies`:
```
flutter_wemap_sdk:
    git:
    url: https://github.com/wemap/flutter_wemap_sdk.git
    ref: master
```

#### iOS

- update `Podfile`
```
  use_frameworks! :linkage => :static
  use_modular_headers!

  pod 'livemap-ios-sdk', :git => 'git@github.com:wemap/livemap-ios-sdk.git', :branch => 'master'
  platform :ios, '11.0'
```

- install 
`cd ios/ && pod install`


#### android

not currently supported


#### using


- instanciate && return `Livemap` from `emmid` & `token`

```
class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{
      "token": "GUHTU6TYAWWQHUSR5Z5JZNMXX",
      "emmid": 21262
    };

    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Container(
            constraints: const BoxConstraints.expand(),
            child: const Livemap(options: creationParams)));
  }
}
```

- use controller & subscribes to event:

see [example/](example/lib/map_view.dart)

  - events:
    - `onMapReady`
    - `onPinpointOpen`
    - `onPinpointClose`
    - `onContentUpdated`

  - methods:
    - `openPinpoint`
    - `closePinpoint`
    - `setCenter`
    - `centerTo`


![Simulator Screen Shot](https://user-images.githubusercontent.com/9257198/220157247-e55a1889-9470-4f6a-8afb-f58d94fe565d.png)
