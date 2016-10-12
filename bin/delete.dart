part of deep_fuse;

handleDelete(HttpRequest request, HttpResponse response) async {
  String id = request.uri.queryParameters['id'];
  if (id.length > 0) {
    if (Task.current != null && Task.current.id == id) {
      Task.current.stop();
      Task.current = null;
    }
    String dirPath = historyDir + '/' + id;
    Directory dir = new Directory(dirPath);
    dir.delete(recursive: true);
  }
}