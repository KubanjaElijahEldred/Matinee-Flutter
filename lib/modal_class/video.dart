class VideoList {
  List<Video>? results;

  VideoList({this.results});

  VideoList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Video>[];
      json['results'].forEach((v) {
        results!.add(new Video.fromJson(v));
      });
    }
  }
}

class Video {
  String? id;
  String? key;
  String? name;
  String? site;
  String? type;

  Video({this.id, this.key, this.name, this.site, this.type});

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    key = json['key'];
    name = json['name'];
    site = json['site'];
    type = json['type'];
  }
}
