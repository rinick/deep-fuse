part of neural_style_server;

RegExp spliter = new RegExp(r'[\\/]');

handleInit(HttpResponse response) async {
  Directory d = new Directory(historyDir);
  List<FileSystemEntity> files = d.listSync(followLinks: false);
  List ids = [];
  for (FileSystemEntity file in files) {
    String fileName = file.path
        .split(spliter)
        .last;
    if (fileName.length == 23) {
      ids.add(fileName);
    }
  }
  ids.sort();
  ids = ids.reversed.toList();
  List initResult = [];
  for (String id in ids) {
    if (Task.current != null && Task.current.id == id) {
      Task.current.updateInfo();
      initResult.add(Task.current.info);
    } else {
      String rslt;
      Directory taskd = new Directory(historyDir + '/' + id);
      taskd.listSync(followLinks: false);
      List<FileSystemEntity> files = taskd.listSync(followLinks: false);
      int iter = 0;
      for (FileSystemEntity file in files) {
        String fileName = file.path
            .split(spliter)
            .last;
        if (fileName.startsWith('output') && fileName.endsWith('.png')) {
          if (fileName == 'output.png') {
            iter = 1000;
            break;
          } else {
            int it = int.parse(fileName.substring(7, fileName.length - 4));
            if (it > iter) {
              iter = it;
            }
          }
        }
      }
      if (iter > 0) {
        if (iter == 1000) {
          rslt = '$id/output.png';
        } else {
          rslt = '$id/output_$iter.png';
        }
      }
      File infoFile = new File(historyDir + '/' + id + '/info.json');
      Map info = JSON.decode(infoFile.readAsStringSync());
      info['result'] = rslt;
      info['iter'] = iter;
      info['content'] = "$id/${info['contentName']}";
      info['style'] = "$id/${info['styleName']}";
      initResult.add(info);
    }
  }
  response.write(JSON.encode(initResult));
}
