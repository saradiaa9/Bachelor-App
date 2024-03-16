class Model {
  final int id;
  final String imagePath;
  final String name;

  Model({
    required this.id,
    required this.imagePath,
    required this.name,
  });
}

List<Model> navBtn = [
  Model(id: 0, imagePath: 'assets/icon/user.png', name: 'Profile'),
  Model(id: 1, imagePath: 'assets/icon/camera.png', name: 'Camera'),
  
];