part of deep_fuse;


handleUpload(HttpRequest request, HttpResponse response) async {
  String boundary = request.headers.contentType.parameters['boundary'];

  List parts = await request.transform(
      new Mime.MimeMultipartTransformer(boundary))
      .map((part) {
    return FormData.HttpMultipartFormData.parse(
        part, defaultEncoding: UTF8);
  }).toList();

  Map info = {};
  List contentData;
  List styleData;
  String contentType = '';
  String styleType = '';

  for (FormData.HttpMultipartFormData part in parts) {
    String name = part.contentDisposition.parameters['name'];
    if (name == 'contentFile') {
      contentType = part.contentType.toString();
      info['contentName'] = 'content.' + contentType
          .split('/')
          .last;
      contentData = await part.fold([], (b, s) => b..addAll(s));
    } else if (name == 'styleFile') {
      styleType = part.contentType.toString();
      info['styleName'] = 'style.' + styleType
          .split('/')
          .last;
      styleData = await part.fold([], (b, s) => b..addAll(s));
    } else if (part.isText) {
      info[name] = await part.join();
    }
  }

  Task task = new Task(info);

  if (!styleType.startsWith('image/') || !contentType.startsWith('image/')) {
    info['error'] = 'invalid image';
    task.create(); // save the error message;
    return;
  }
  task.create();
  await task.start(contentData, styleData);
}