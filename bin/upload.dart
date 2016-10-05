part of neural_style_server;


handleUpload(HttpRequest request, HttpResponse response) async {
  String boundary = request.headers.contentType.parameters['boundary'];

  List parts = await request.transform(
      new Mime.MimeMultipartTransformer(boundary))
      .map((part) {
    return FormData.HttpMultipartFormData.parse(
        part, defaultEncoding: UTF8);
  }).toList();

  Map data = {};
  List contentData;
  List filterData;
  String contentType = '';
  String filterType = '';

  for (FormData.HttpMultipartFormData part in parts) {
    String name = part.contentDisposition.parameters['name'];
    if (name == 'contentFile') {
      contentType = part.contentType.toString();
      data['contentName'] = 'content.' + contentType
          .split('/')
          .last;
      contentData = await part.fold([], (b, s) => b..addAll(s));
    } else if (name == 'filterFile') {
      filterType = part.contentType.toString();
      data['filterName'] = 'filter.' + filterType
          .split('/')
          .last;
      filterData = await part.fold([], (b, s) => b..addAll(s));
    } else if (part.isText) {
      data[name] = await part.join();
    }
  }

  Task task = new Task(data);
  task.create();
  if (!filterType.startsWith('image/') || !contentType.startsWith('image/')) {

  }
}