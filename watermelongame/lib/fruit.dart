import 'package:flame_forge2d/body_component.dart';

class Weapon extends BodyComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    print('onload');
  }
}
