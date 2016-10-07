part of neural_style_server;

class Task {

  static Task current;

  static RegExp iterReg = new RegExp(r'Iteration (\d+)');

  String id;
  Map info;

  int startTs;

  String dirPath;

  bool running = false;

  int iter = 0;
  int outputStep = 5;

  Process process;

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
    dirPath = historyDir + '/' + id;
  }

  updateInfo() {
    info['running'] = running;
    info['content'] = "$id/${info['contentName']}";
    info['style'] = "$id/${info['styleName']}";
    info['info'] = info['date'] + '\n' + info['time'] + '\niteration: $iter';
    if (iter < outputStep) {
      info['result'] = 'asserts/waiting.gif';
    } else if (iter == 1000) {
      info['result'] = '$id/output.png';
    } else {
      info['result'] = '$id/output_$currentOutIter.png';
    }
  }

  create() {
    Directory dir = new Directory(dirPath);
    dir.createSync(recursive: true);
    File infoFile = new File(dirPath + '/info.json');
    infoFile.writeAsStringSync(JSON.encode(info));
  }

  start(List<int> contentData, List<int> styleData) async {
    File contentFile = new File(dirPath + '/' + info['contentName']);
    contentFile.writeAsBytesSync(contentData, flush: true);

    File styleFile = new File(dirPath + '/' + info['styleName']);
    styleFile.writeAsBytesSync(styleData, flush: true);

    running = true;

    List args = ['./neural_style.lua'];
    args.addAll(['-save_iter', '$outputStep']);
    args.addAll(['-content_image', '../history/$id/${info["contentName"]}']);
    args.addAll(['-style_image', '../history/$id/${info["styleName"]}']);
    args.addAll(['-output_image', '../history/$id/output.png']);
    args.addAll(['-style_scale', info['style_scale']]);
    args.addAll(['-image_size', info['image_size']]);
    args.addAll(['-style_weight', info['style_weight']]);
    args.addAll(['-init', info['initial_state']]);
    if (info['original_colors'] == 'on') {
      args.addAll(['-original_colors', '1']);
    }
    if (info['normalize_gradients'] == 'on') {
      args.add('-normalize_gradients');
    }

    print(args.join(' '));
    print(nsDir);
    process = await Process.start('th', args, workingDirectory: nsDir);
    process.stdout.listen(onStdOut);
    process.stderr.listen(onStdError);
  }

  int currentOutIter = 0;

  onStdOut(List<int> data) {
    String str = UTF8.decode(data);
    print(str.trim());
    List<Match> matchs = iterReg.allMatches(str).toList();
    if (matchs.isNotEmpty) {
      iter = int.parse(matchs.last.group(1));

      int outIter = (iter ~/ outputStep) * outputStep;
      if (outIter > currentOutIter) {
        if (currentOutIter % 50 != 0) {
          (new File('$historyDir/$id/output_$currentOutIter.png')).delete();
        }
        currentOutIter = outIter;
      }
    }
  }

  onStdError(List<int> data) {
    String str = UTF8.decode(data);
    print('Error: ${str.trim()}');
  }

  stop() {
    if (process != null) {
      process.kill();
    }
    stopped();
  }

  stopped() {
    running = false;
  }
}
