import 'dart:math' show Point;

import 'package:shared_preferences/shared_preferences.dart';

class BoardState {
  final List<List<int>> tiles;
  final Point lastTileAdded;
  final int dimension;
  final int score;

  BoardState(this.tiles, this.score, {this.lastTileAdded}) : dimension = tiles.length {
    tiles.forEach((row) { assert(row.length == dimension); });
  }

  BoardState moveRight() {
    var newScore = score;
    List<List<int>> result = new List<List<int>>(dimension);
    for (int i = 0; i < dimension; i += 1) {
      List<int> row = tiles[i];
      List<int> newRow = new List<int>.filled(dimension, 0);
      result[i] = newRow;
      int rightMostModifable = dimension - 1;
      for (int j = dimension - 1; j >= 0; j--) {
        if (row[j] == 0)
          continue;

        if (row[j] == newRow[rightMostModifable]) {
          newRow[rightMostModifable] *= 2;
          newScore += newRow[rightMostModifable];
          rightMostModifable--;
          continue;
        }

        if (newRow[rightMostModifable] == 0) {
          newRow[rightMostModifable] = row[j];
          continue;
        }

        rightMostModifable -= 1;
        newRow[rightMostModifable] = row[j];
      }
    }
    print('New Score $newScore');
    return new BoardState(result, newScore);
  }

  BoardState moveUp() {
    return _rotateClockWise()
      .moveRight()
      ._rotateClockWise()
      ._rotateClockWise()
      ._rotateClockWise();
  }

  BoardState moveLeft() {
    return _rotateClockWise()
      ._rotateClockWise()
      .moveRight()
      ._rotateClockWise()
      ._rotateClockWise();
  }

  BoardState moveDown() {
    return _rotateClockWise()
      ._rotateClockWise()
      ._rotateClockWise()
      .moveRight()
      ._rotateClockWise();
  }

  BoardState resetTiles() {
    List<List<int>> result = new List<List<int>>(dimension);
    for (int i = 0; i < dimension; i += 1) {
      List<int> newRow = new List<int>.filled(dimension, 0);
      result[i] = newRow;
    }

    return new BoardState(result, 0);
  }

  BoardState addNewTile(int randomValue, int maxValue) {
    List<Point<int>> emptyCells = new List<Point<int>>();
    List<List<int>> newTiles = new List<List<int>>(dimension);
    for (int i = 0; i < dimension; i++) {
      newTiles[i] = new List<int>(dimension);
      for (int j = 0; j < dimension; j++) {
        if (tiles[i][j] == 0) {
          emptyCells.add(new Point(i, j));
        }
        newTiles[i][j] = tiles[i][j];
      }
    }

    Point selectedPosition = emptyCells[randomValue % emptyCells.length];
    int newValue = maxValue * 0.4 < randomValue ? 4 : 2;
    newTiles[selectedPosition.x][selectedPosition.y] = newValue;
    updateHighScore();
    return new BoardState(newTiles, score, lastTileAdded: selectedPosition);
  }

  BoardState _rotateClockWise() {
    List<List<int>> result = new List<List<int>>(dimension);
    for (int i = 0; i < dimension; i++) {
      result[i] = new List<int>(dimension);
      for (int j = 0; j < dimension; j++) {
        result[i][j] = tiles[dimension - 1 - j][i];
      }
    }
    return new BoardState(result, score);
  }

  Future<void> updateHighScore() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    int highScore = sharedPrefs.getInt('high_score');
    if(highScore == null) {
      sharedPrefs.setInt('high_score', 0);
    } else {
      if(score > highScore) {
        sharedPrefs.setInt('high_score', score);
      }
    }
  }
}
