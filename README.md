# bubble_bottom_bar / BubbleBottomBar

BubbleBottomBar is a Flutter widget designed by [cubertodesign](https://www.instagram.com/cubertodesign/) and developed by [westdabestdb](https://www.instagram.com/westdabestdb/).

![](https://media.giphy.com/media/tK9LhfHJ5qT71d7lYa/giphy.gif)
## Getting Started
Add this to your package's `pubspec.yaml` file:
```
...
dependencies:
  bubble_bottom_bar: ^1.0.2
```

Now in your Dart code, you can use:
```
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
```

## Usage
```
bottomNavigationBar: BubbleBottomBar(
        opacity: .2,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 8,
        items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(backgroundColor: Colors.red, icon: Icon(Icons.dashboard, color: Colors.black,), activeIcon: Icon(Icons.dashboard, color: Colors.red,), title: Text("Home")),
            BubbleBottomBarItem(backgroundColor: Colors.deepPurple, icon: Icon(Icons.access_time, color: Colors.black,), activeIcon: Icon(Icons.access_time, color: Colors.deepPurple,), title: Text("Logs")),
            BubbleBottomBarItem(backgroundColor: Colors.indigo, icon: Icon(Icons.folder_open, color: Colors.black,), activeIcon: Icon(Icons.folder_open, color: Colors.indigo,), title: Text("Folders")),
            BubbleBottomBarItem(backgroundColor: Colors.green, icon: Icon(Icons.menu, color: Colors.black,), activeIcon: Icon(Icons.menu, color: Colors.green,), title: Text("Menu"))
        ],
      ),
```
