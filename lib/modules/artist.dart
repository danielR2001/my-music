class Artist {
  String _name;
  String _imageUrl;

  Artist(
    String name,
    //String imageUrl,
  ) {
    _name = name;
    //_imageUrl = imageUrl;
  }

  String get name => _name;
  String get imageUrl => _imageUrl;

  set name(String value) => _name = value;
  set imageUrl(String value) => _imageUrl = value;
}
