part of deep_fuse;

handleLast(HttpResponse response) {
  if (Task.current != null) {
    Task.current.updateInfo();
    response.write(JSON.encode(Task.current.info));
  } else {
    response.write('{}');
  }
}