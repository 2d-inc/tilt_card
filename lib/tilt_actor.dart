import 'dart:ui' as ui;
import 'package:flare_dart/actor_artboard.dart';
import 'package:flare_dart/actor_shape.dart';
import "package:flare_flutter/flare.dart";
import 'package:flutter/material.dart';

// We create a custom Actor in order to override the shape nodes
class TiltActor extends FlutterActor {
  @override
  ActorShape makeShapeNode() {
    return TiltActorShape();
  }

  @override
  ActorArtboard makeArtboard() {
    return TiltArtboard(this);
  }
}

class TiltArtboard extends FlutterActorArtboard {
  TiltArtboard(FlutterActor actor) : super(actor);

  void setTilt(double pitch, double roll) {
    Matrix4 transform = Matrix4.identity();
    Matrix4 perspective = Matrix4.identity()..setEntry(3, 2, 0.001);
	transform.multiply(Matrix4.diagonal3Values(0.55, -0.55, 1.0));
    transform.multiply(perspective);
    transform.multiply(Matrix4.rotationY(roll));
    transform.multiply(Matrix4.rotationX(pitch));

    var rootChildren = root.children;
    for (final drawable in drawableNodes) {
      if (drawable is TiltDrawable) {
        ActorNode topComponent = drawable;
        int index = 0;
        // safety check for climbing the hierarchy
        while (topComponent != null) {
          // check if we found the root
          if (topComponent.parent == root) {
            // This component is right under the root,
            // which we use to determine z depth.
            index = rootChildren.length - rootChildren.indexOf(topComponent);
            break;
          }
          topComponent = topComponent.parent;
        }

        Matrix4 tiltTransform = Matrix4.copy(transform);
        tiltTransform
            .multiply(Matrix4.translationValues(0, 0, 250.0 + index * 25.0));
        (drawable as TiltDrawable).tiltTransform = tiltTransform;
      }
    }
  }
}

class TiltDrawable {
  Matrix4 tiltTransform;
}

// This is the custom actor shape we create which
// will override the default draw to introduce the tilt.
class TiltActorShape extends FlutterActorShape implements TiltDrawable {
  @override
  Matrix4 tiltTransform;

  @override
  void draw(ui.Canvas canvas) {
    if (!doesDraw) {
      return;
    }

    canvas.save();
    canvas.transform(tiltTransform.storage);
    super.draw(canvas);
    canvas.restore();
  }
}