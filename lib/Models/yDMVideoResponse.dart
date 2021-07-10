class VideoDetails {
  VideoDetails(this.url, this.title, this.thumbnails, this.videoFormat,
      this.status, this.message);

  String url;
  String title;
  String thumbnails;
  List<VideoFormat> videoFormat;
  // List<AudioFormat> audioFormat;
  bool status;
  String message;
}

class VideoFormat {
  VideoFormat(this.id, this.size, this.quality, this.ext, this.url);

  String id;
  int size;
  String quality;
  String ext;
  String url;
}

class AudioFormat {
  AudioFormat(this.id, this.size, this.quality, this.ext, this.url);

  String id;
  int size;
  String quality;
  String ext;
  String url;
}
