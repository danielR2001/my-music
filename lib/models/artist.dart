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

  String get name => _name;

  String get imageUrl => _imageUrl;

  set setName(String value) => _name = value;

  set setImageUrl(String value) => _imageUrl = value;

}
