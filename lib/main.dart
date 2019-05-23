import 'package:flutter/material.dart';
import 'package:two_zero_four_eight/redux.dart';
import 'package:two_zero_four_eight/ui.dart';
import 'package:two_zero_four_eight/gamecolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new App2048());
}

class App2048 extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new GameRedux(
      child: new MaterialApp(
        title: '2048',
        theme: ThemeData.dark(),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  SharedPreferences sharedPreferences;

  Future<String> getHighScore() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int score = sharedPreferences.getInt('high_score');
    if (score == null) {
      score = 0;
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double gridWidth = (width - 160) / 4;
    double gridHeight = gridWidth;
    double height = 30 + (gridHeight * 4) + 10;

    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '2048',
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(GameColors.gridBackground),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Color(GameColors.gridBackground),
                  ),
                  height: 82.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                        child: Text(
                          'Score',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          '0xe0',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Game(),
                    /*isgameOver
                              ? Container(
                                  height: height,
                                  color: Color(GameColors.transparentWhite),
                                  child: Center(
                                    child: Text(
                                      'Game over!',
                                      style: TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(GameColors.gridBackground)),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          isgameWon
                              ? Container(
                                  height: height,
                                  color: Color(GameColors.transparentWhite),
                                  child: Center(
                                    child: Text(
                                      'You Won!',
                                      style: TextStyle(
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(GameColors.gridBackground)),
                                    ),
                                  ),
                                )
                              : SizedBox(),*/
                  ],
                ),
                color: Color(GameColors.gridBackground),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Color(GameColors.gridBackground),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: IconButton(
                          iconSize: 35.0,
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            GameRedux.dispatch(context, resetTiles());
                          },
                        ),
                      ),
                    ),
                    Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Color(GameColors.gridBackground),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'High Score',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  FutureBuilder<String>(
                                    future: getHighScore(),
                                    builder: (ctx, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        );
                                      } else {
                                        return Text(
                                          '0',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (DragEndDetails d) {
        if (d.primaryVelocity > 0) {
          GameRedux.dispatch(context, moveRight());
        } else {
          GameRedux.dispatch(context, moveLeft());
        }
      },
      onVerticalDragEnd: (DragEndDetails d) {
        if (d.primaryVelocity > 0) {
          GameRedux.dispatch(context, moveDown());
        } else {
          GameRedux.dispatch(context, moveUp());
        }
      },
      child: const GameGrid(),
    );
  }
}
