import 'package:flare_flutter/flare_render_box.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/aabb.dart';

import 'tilt_actor.dart';

class FlareTiltWidget extends LeafRenderObjectWidget {
  final BoxFit fit;
  final Alignment alignment;
  final String filename;
  final double pitch;
  final double yaw;
  final double depth;

  const FlareTiltWidget(
    this.filename, {
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.pitch,
    this.yaw,
    this.depth,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return FlareTiltRenderObject()
      ..filename = filename
      ..assetBundle = DefaultAssetBundle.of(context)
      ..fit = fit
      ..alignment = alignment
      ..pitch = pitch
      ..yaw = yaw
	  ..tiltDepth = depth;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant FlareTiltRenderObject renderObject) {
    renderObject
      ..filename = filename
      ..assetBundle = DefaultAssetBundle.of(context)
      ..fit = fit
      ..alignment = alignment
      ..pitch = pitch
      ..yaw = yaw
	  ..tiltDepth = depth;
  }

  @override
  void didUnmountRenderObject(covariant FlareTiltRenderObject renderObject) {
    renderObject.dispose();
  }
}

class FlareTiltRenderObject extends FlareRenderBox {
  TiltArtboard _artboard;
  String _filename;
  double pitch, yaw, tiltDepth;

  String get filename => _filename;
  set filename(String value) {
    if (value == _filename) {
      return;
    }
    _filename = value;

    if (_filename == null) {
      markNeedsPaint();
    }
    // file will change, let's clear out old animations.
    load();
  }

  @override
  bool get isPlaying => true;
  ActorAnimation _idle;
  double _animationTime = 0.0;

  @override
  void advance(double elapsedSeconds) {
    if (_artboard == null) {
      return;
    }
    _animationTime += elapsedSeconds;
    _idle?.apply(_animationTime % _idle.duration, _artboard, 1.0);
    _artboard.setTilt(pitch, yaw, tiltDepth);
    _artboard.advance(elapsedSeconds);
  }

  @override
  AABB get aabb => _artboard?.artboardAABB();

  @override
  void paintFlare(Canvas canvas, Mat2D viewTransform) {
    // Make sure loading is complete.
    if (_artboard == null) {
      return;
    }
    _artboard.draw(canvas);
  }

  @override
  void load() {
    if (_filename == null) {
      return;
    }
    super.load();
    loadFlare(_filename).then((FlutterActor actor) {
      if (actor == null || actor.artboard == null) {
        return;
      }

      TiltArtboard artboard = TiltActor.instanceArtboard(actor);
      artboard.initializeGraphics();
      _artboard = artboard;
      _idle = _artboard.getAnimation("idle");

      _artboard.advance(0.0);
      markNeedsPaint();
    });
  }
}
