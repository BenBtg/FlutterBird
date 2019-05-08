# flutter_bird
### Flutter Create Entry
### by Ben Buttigieg

Flutter Bird is Ben Buttigieg's entry to Flutter Create. App created in less than 5Kb of Dart code.

Simply tap the screen to start a game and tap to make the bird fly up and try to avoid the obstacles.

## Technical Overview
The game was created in 186 lines and 5061 bytes.

2 animation controller are used, one to control the horizontal movement of the obstacle and a second to control the vertical movement of the bird.

The Flutter gravity simulation is used to make the bird fall naturally.
The Dash bird sprite was created using Flare and a flap animation was added which plays when the bird flys up.

The was not enough space to use RenderBox hit testing so a simple center point hit test is performed in the animation listener.
If a hit is detected the game end and the Start screen is shown.

Score and high score is shown on the top right with a ncie drop shadow.
The score is increased every time the horizontal animation completes and the high score is updated accordingly. The high score is persisted between sessions using shared preferences.
![alt text](https://github.com/BenBtg/FlutterBird/blob/master/FlutterBirdVideo.gif "Flutter Bird Video")
