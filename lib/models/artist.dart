class Artist {
  String _name;
  String _imageUrl;
  String _id;
  String _info;

  Artist(
    String name,
    String imageUrl,
    {String id,String info}
  ) {
    _name = name;
    _imageUrl = imageUrl;
    _id = id;
    _info = info;
  }

  String get getName => _name;

  String get getImageUrl => _imageUrl;

  String get getId => _id;

  String get getInfo => _info;

  set setName(String value) => _name = value;

  set setImageUrl(String value) => _imageUrl = value;

  set setId(String value) => _id = value;

  set setInfo(String value) => _info = value;

}
