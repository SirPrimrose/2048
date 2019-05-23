import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:two_zero_four_eight/animation_spec.dart';
import 'package:two_zero_four_eight/redux.dart';
import 'package:two_zero_four_eight/state.dart';
import 'package:two_zero_four_eight/store_state.dart';
import 'package:two_zero_four_eight/gamecolors.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({Key key}) : super(key: key);

  @override
  State createState() => new GameGridState();
}

class GameGridState extends State<GameGrid> with TickerProviderStateMixin {

  AnimationController _slideController;
  AnimationController _fadeController;

  @override
  Widget build(BuildContext context) {
    _recycleAnimationControllers();

    StoreUpdate<BoardState, Action> update = GameRedux.stateOf(context);

    List<TileMotionSpec> motionSpec =
      buildMotionSpec(update.previousState, update.lastAction, update.state);

    var tiles = _animatedTilesForSpec(motionSpec, update);

    return new AspectRatio(
      aspectRatio: 1.0,
      child: new Stack(
        children: tiles
      )
    );
  }

  List<AnimatedTile> _animatedTilesForSpec(List<TileMotionSpec> motionSpec, StoreUpdate<BoardState, Action> update) {
    List<AnimatedTile> tiles = new List<AnimatedTile>();
    var prevTiles = update?.previousState?.tiles ?? update.state.tiles;
    for (int i = 0; i < motionSpec.length; i += 1) { 
      TileMotionSpec spec = motionSpec[i];
      int value;
      if (spec.fadeIn)
        value = update.state.tiles[spec.toI][spec.toJ];
      else
        value = prevTiles[spec.fromI][spec.fromJ];
      tiles.add(new AnimatedTile(
          spec.fromI,
          spec.fromJ,
          spec.toI,
          spec.toJ,
          value,
          update.state.dimension,
          slideController: _slideController,
          fadeController: _fadeController,
          fadeIn: spec.fadeIn,
      ));
    }
    if (update.state.lastTileAdded != null) {
      tiles.add(new AnimatedTile(
          update.state.lastTileAdded.x,
          update.state.lastTileAdded.y,
          update.state.lastTileAdded.x,
          update.state.lastTileAdded.y,
          update.state.tiles[update.state.lastTileAdded.x][update.state.lastTileAdded.y],
          update.state.dimension,
          slideController: _slideController,
          fadeController: _fadeController,
          fadeIn: true
      ));
    }
    return tiles;
  }

  void _recycleAnimationControllers() {
    _slideController?.dispose();
    _fadeController?.dispose();

    _slideController = new AnimationController(
        duration: new Duration(milliseconds: 150),
        vsync: this,
    );
    _fadeController = new AnimationController(
        duration: new Duration(milliseconds: 300),
        vsync: this,
    );
  }

  @override
  void dispose() {
    _slideController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

}

class AnimatedTile extends StatelessWidget {
  final int prevI;
  final int prevJ;
  final int i;
  final int j;
  final int value;
  final int boardDimension;
  final bool fadeIn;
  final AnimationController slideController;
  final AnimationController fadeController;

  AnimatedTile(this.prevI, this.prevJ, this.i, this.j, this.value, this.boardDimension, {
    this.fadeIn = false,
    this.slideController,
    this.fadeController,
  });

  @override
  Widget build(BuildContext context) {
    double sizeFraction = 1.0 / boardDimension.toDouble();

    double maxTileIndex = (boardDimension -1 ).toDouble();
    double toXPosition = lerpDouble(-1.0, 1.0, j.toDouble() / maxTileIndex);
    double fromXPosition = lerpDouble(-1.0, 1.0, prevJ.toDouble() / maxTileIndex);
    double toYPosition = lerpDouble(-1.0, 1.0, i.toDouble() / maxTileIndex);
    double fromYPosition = lerpDouble(-1.0, 1.0, prevI.toDouble() / maxTileIndex);

    Animation<Alignment> alignment = new AlignmentTween(
      begin: new Alignment(fromXPosition, fromYPosition),
      end: new Alignment(toXPosition, toYPosition)
    ).animate(new CurvedAnimation(
      curve: Curves.easeOut,
      parent: slideController,
    ));
    slideController.forward();


    Animation<double> fadeAnimation;
    if (fadeIn) {
      fadeAnimation =
        new CurvedAnimation(parent: fadeController, curve: Curves.easeOut);
      fadeController.forward();
    } else {
      fadeAnimation = new AlwaysStoppedAnimation(1.0);
    }
    return new AlignTransition(
      child: new FractionallySizedBox(
        widthFactor: sizeFraction,
        heightFactor: sizeFraction,
        child: new FadeTransition(
          opacity: fadeAnimation,
          child: new Tile(value),
        ),
      ),
      alignment: alignment
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new DiagnosticsProperty<int>('value', value));
    description.add(new DiagnosticsProperty<int>('prevI', prevI));
    description.add(new DiagnosticsProperty<int>('prevJ', prevJ));
    description.add(new DiagnosticsProperty<int>('i', i));
    description.add(new DiagnosticsProperty<int>('j', j));
  }

}

Map<int, Color> _tileColors = {
  2: Color(GameColors.gridColor2),
  4: const Color(0xFF4E99E3),
  8: const Color(0xFF4E4FE3),
  16: const Color(0xFF4E4FE3),
  32: const Color(0xFF984EE3),
  64: const Color(0xFF984EE3),
  128: const Color(0xFFE24EE3),
  256: const Color(0xFFE24EE3),
  512: const Color(0xFFE34E99),
  1024: const Color(0xFFE34E99),
  2048: const Color(0xFFE34E4E),
};

class Tile extends StatefulWidget {
  final int value;

  Tile(this.value) : super(key: new Key(value.toString()));

  @override
  State<StatefulWidget> createState() {
    return _TileState();
  }
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.all(4.0),
      child: new Container(
        child: new Center(
          child: new Text(
            widget.value.toString(),
            style: TextStyle(
              fontSize: widget.value.toString().length <= 2 ? 40.0 : widget.value.toString().length <= 4 ? 30.0 : 20.0,
              color: Color(GameColors.tileFontColor),
            ),
          ),
        ),
        decoration: new ShapeDecoration(
          color: _tileColors[widget.value] ?? Colors.black,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }
}
