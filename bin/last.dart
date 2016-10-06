part of neural_style_server;

handleLast(HttpResponse response) {
  if (Task.current != null) {
    Task.current.updateInfo();
    response.write(JSON.encode(Task.current.info));
  } else {
    response.write('{}');
  }
}