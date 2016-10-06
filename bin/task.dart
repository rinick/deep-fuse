part of neural_style_server;

class Task {

  static Task current;

  String id;
  Map info;

  int startTs;

  String dirPath;

  bool running = false;

  int iter = 0;
  int outputStep = 5;
  Task(this.info) {
    if (current != null) {
      current.stop();
    }
    current = this;
    DateTime dt = new DateTime.now();
    startTs = dt.millisecondsSinceEpoch;

    String ts = dt.toIso8601String();
    info['date'] = ts.substring(0, 10);
    info['time'] = ts.substring(11, 19);
    id = ts.substring(0, 23).replaceAll(':', '-').replaceAll('.', '-');
    info['id'] = id;
    dirPath = webDir + '/' + id;
  }

  updateInfo(){
    info['running'] = running;
    info['content'] = "$id/${info['contentName']}";
    info['filter'] = "$id/${info['filterName']}";
    info['info'] = info['date'] + '\n' + info['time'] + '\n+ $iter';
    if (iter < outputStep) {
      info['result'] = 'asserts/waiting.gif';
    }
  }

  create() {
    Directory dir = new Directory(dirPath);
    dir.createSync();
    File infoFile = new File(dirPath + '/info.json');
    infoFile.writeAsStringSync(JSON.encode(info));
  }

  start(List<int> contentData, List<int> filterData) {
    File contentFile = new File(dirPath + '/' + info['contentName']);
    contentFile.writeAsBytesSync(contentData, flush: true);

    File filterFile = new File(dirPath + '/' + info['filterName']);
    filterFile.writeAsBytesSync(filterData, flush: true);

    running = true;
  }

  stop() {
    stopped();
  }

  stopped() {
    running = false;
  }
}
