// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flame/game.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter/services.dart';

// class PhysicsGame extends StatelessWidget {
//   const PhysicsGame({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return GameWidget(game: FunPhysicsGame());
//   }
// }

// class FunPhysicsGame extends Forge2DGame with ContactCallbacks {
//   FunPhysicsGame() : super(gravity: Vector2(0, 9.8), zoom: 20);
//   final random = math.Random();

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     addWalls();
//     addVariousObjects();
//     accelerometerEventStream().listen((AccelerometerEvent event) {
//       world.gravity = Vector2(-event.x, event.y) * 9.8;
//     });
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawColor(const Color(0xFF14161A), BlendMode.src);
//     super.render(canvas);
//   }

//   void addWalls() {
//     final worldSize = camera.viewport.size;
//     add(Wall(Vector2.zero(), Vector2(worldSize.x, 0)));
//     add(Wall(Vector2(worldSize.x, 0), worldSize));
//     add(Wall(worldSize, Vector2(0, worldSize.y)));
//     add(Wall(Vector2(0, worldSize.y), Vector2.zero()));
//   }

//   void addVariousObjects() {
//     final worldSize = camera.viewport.size;
//     for (int i = 0; i < 15; i++) {
//       final position = Vector2(
//         random.nextDouble() * worldSize.x,
//         random.nextDouble() * worldSize.y / 2,
//       );
//       if (i % 3 == 0) {
//         add(Ball(position, 50 + random.nextDouble() * 30));
//       } else if (i % 3 == 1) {
//         add(RoundedBox(position, 50 + random.nextDouble() * 30,
//             0.4 + random.nextDouble() * 50));
//       } else {
//         add(RoundedTriangle(position, 50 + random.nextDouble() * 30));
//       }
//     }
//   }

//   @override
//   void beginContact(Object other, Contact contact) {
//     final fixtureA = contact.fixtureA;
//     final fixtureB = contact.fixtureB;

//     if (fixtureA.body.userData is RoundedBox ||
//         fixtureB.body.userData is RoundedBox) {
//       HapticFeedback.heavyImpact();
//     } else if (fixtureA.body.userData is Wall ||
//         fixtureB.body.userData is Wall) {
//       HapticFeedback.mediumImpact();
//     } else {
//       HapticFeedback.lightImpact();
//     }
//   }
// }

// class Wall extends BodyComponent {
//   final Vector2 start;
//   final Vector2 end;
//   Wall(this.start, this.end);

//   @override
//   Body createBody() {
//     final shape = EdgeShape()..set(start, end);
//     final fixtureDef = FixtureDef(shape)
//       ..restitution = 0.2
//       ..friction = 0.5;
//     final bodyDef = BodyDef()
//       ..userData = this
//       ..position = Vector2.zero()
//       ..type = BodyType.static;
//     return world.createBody(bodyDef)..createFixture(fixtureDef);
//   }

//   @override
//   void render(Canvas canvas) {}
// }

// class RoundedBox extends BodyComponent {
//   @override
//   final Vector2 position;
//   final double width;
//   final double height;
//   final Color color;

//   RoundedBox(this.position, this.width, this.height)
//       : color =
//             Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

//   @override
//   Body createBody() {
//     final shape = PolygonShape()
//       ..setAsBox(width / 2, height / 2, Vector2.zero(), 0);
//     final fixtureDef = FixtureDef(shape)
//       ..restitution = 0.6
//       ..density = 1.0
//       ..friction = 0.3;
//     final bodyDef = BodyDef()
//       ..userData = this
//       ..position = position
//       ..type = BodyType.dynamic;
//     return world.createBody(bodyDef)..createFixture(fixtureDef);
//   }

//   @override
//   void render(Canvas canvas) {
//     final paint = Paint()..color = color;
//     final rect =
//         Rect.fromCenter(center: Offset.zero, width: width, height: height);
//     final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
//     canvas.drawRRect(rrect, paint);
//   }
// }

// class Ball extends BodyComponent {
//   @override
//   final Vector2 position;
//   final double radius;
//   final Color color;

//   Ball(this.position, this.radius)
//       : color =
//             Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

//   @override
//   Body createBody() {
//     final shape = CircleShape()..radius = radius;
//     final fixtureDef = FixtureDef(shape)
//       ..restitution = 0.8
//       ..density = 1.0
//       ..friction = 0.4;
//     final bodyDef = BodyDef()
//       ..userData = this
//       ..position = position
//       ..type = BodyType.dynamic;
//     return world.createBody(bodyDef)..createFixture(fixtureDef);
//   }

//   @override
//   void render(Canvas canvas) {
//     final paint = Paint()..color = color;
//     canvas.drawCircle(Offset.zero, radius, paint);
//   }
// }

// class RoundedTriangle extends BodyComponent {
//   @override
//   final Vector2 position;
//   final double size;
//   final Color color;

//   RoundedTriangle(this.position, this.size)
//       : color =
//             Colors.primaries[math.Random().nextInt(Colors.primaries.length)];

//   @override
//   Body createBody() {
//     final vertices = [
//       Vector2(0, -size / 2),
//       Vector2(-size / 2, size / 2),
//       Vector2(size / 2, size / 2),
//     ];
//     final shape = PolygonShape()..set(vertices);
//     final fixtureDef = FixtureDef(shape)
//       ..restitution = 0.7
//       ..density = 1.0
//       ..friction = 0.2;
//     final bodyDef = BodyDef()
//       ..userData = this
//       ..position = position
//       ..type = BodyType.dynamic;
//     return world.createBody(bodyDef)..createFixture(fixtureDef);
//   }

//   @override
//   void render(Canvas canvas) {
//     final paint = Paint()..color = color;
//     final path = Path();

//     final p1 = Offset(0, -size / 2);
//     final p2 = Offset(-size / 2, size / 2);
//     final p3 = Offset(size / 2, size / 2);

//     path.moveTo((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
//     path.quadraticBezierTo(
//         p1.dx, p1.dy, (p1.dx + p3.dx) / 2, (p1.dy + p3.dy) / 2);
//     path.quadraticBezierTo(
//         p3.dx, p3.dy, (p2.dx + p3.dx) / 2, (p2.dy + p3.dy) / 2);
//     path.quadraticBezierTo(
//         p2.dx, p2.dy, (p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

//     canvas.drawPath(path, paint);
//   }
// }
