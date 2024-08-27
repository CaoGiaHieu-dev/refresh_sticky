# RefreshSticky

A Flutter widget that provides a sticky refresh indicator that can be used to refresh the content of a scrollable widget.

## Features

* **Sticky refresh indicator:** The refresh indicator remains visible even when the user scrolls past it, providing a more seamless user experience.
* **Customizable:** You can change the size, color, and loading animation of the refresh indicator.
* **Easy to use:** Simply wrap your scrollable widget with `RefreshSticky` and provide the `onRefresh` callback to handle the refresh logic.

## Usage
```dart
import 'package:flutter/material.dart';
import 'package:refresh_sticky/refresh_sticky.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  final _items = <String>[];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 20; i++) {
      _items.add('Item $i');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh Sticky Example'),
      ),
      body: RefreshSticky(
        axis: Axis.vertical,
        controller: _scrollController,
        onRefresh: () async {
          // Simulate a network request to fetch new data
          await Future.delayed(const Duration(seconds: 1)); 

          // Update the state with new items
          setState(() {
            for (var i = 0; i < 5; i++) {
              _items.add('Item ${_items.length}');
            }
          });
        },
        builder: (context, controller) {
          return ListView.builder(
            // Make sure it always can pull refresh
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            controller: controller,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_items[index]),
              );
            },
          );
        },
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        preLoadingBuilder: (context) => const Center(
          child: Text('Pull to refresh'),
        ),
      ),
    );
  }
}
```
## Properties

| Property                   | Type                                                                 | Description                                                                                                                                 |
| -------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `builder`                  | `Widget Function(BuildContext context, ScrollController controller)` | A builder function that creates the content of the scrollable widget.                                                                       |
| `onRefresh`                | `Future<void> Function()`                                            | A callback function that is called when the user refreshes the content.                                                                     |
| `size`                     | `double`                                                             | The size of the refresh indicator. Defaults to `50`.                                                                                        |
| `loadingBuilder`           | `WidgetBuilder?`                                                     | A builder function that creates the loading animation of the refresh indicator.                                                             |
| `preLoadingBuilder`        | `WidgetBuilder?`                                                     | A builder function that creates the pre-loading animation of the refresh indicator.                                                         |
| `controller`               | `ScrollController?`                                                  | The scroll controller that will be used to manage the scroll position of the scrollable widget.                                             |
| `moveToFirstAfterComplete` | `bool`                                                               | A boolean value that determines whether the scroll position will be moved to the top after the refresh is complete. Defaults to `false`.    |
| `reverse`                  | `bool`                                                               | A boolean value that determines whether the refresh indicator should be placed at the bottom of the scrollable widget. Defaults to `false`. |
| `scaleLoadingIcon`         | `double`                                                             | A double value that determines the scale of the loading icon. Defaults to `1.2`.                                                            |
| `axis`                     | `Axis`                                                               | The axis of the scrollable widget. Defaults to `Axis.vertical`.                                                                             |


## Installation

To use the `RefreshSticky` widget, add the following dependency to your `pubspec.yaml` file:
```yaml
dependencies:
    refresh_sticky: ^0.1.1+1
```
Then run `flutter pub get` to install the dependency.

## Contribution

Contributions are welcome! Feel free to open an issue or submit a pull request.
This README now provides a clear, well-structured explanation of your package, making it easier for users to understand and use it.## Author

Created by **Cao Gia Hieu** (caogiahieu99@gmail.com)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
