class Artist {
  String _name;
  String _imageUrl;

  Artist(
    String name,
    String imageUrl,
  ) {
    _name = name;
    _imageUrl = imageUrl;
  }

  String get getName => _name;
  String get getImageUrl => _imageUrl;

  set setName(String value) => _name = value;

  set setImageUrl(String value) => _imageUrl = value;

  toJson() {
    return {
      'name': _name,
      'imageUrl': _imageUrl,
    };
  }
}
