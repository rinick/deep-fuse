part of neural_style_server;

RegExp spliter = new RegExp(r'[\\/]');

handleInit(HttpResponse response) async {
  Directory d = new Directory(webDir);
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
      Map row = {};

      Directory taskd = new Directory(webDir + '/' + id);
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
            int it = int.parse(fileName.substring(6, fileName.length - 4));
            if (it > iter) {
              iter = it;
            }
          }
        }
      }
      if (iter > 0) {
        if (iter == 1000) {
          row['result'] = '$id/output.png';
        } else {
          row['result'] = '$id/output$iter.png';
        }

      }
      File infoFile = new File(webDir + '/' + id + '/info.json');
      Map info = JSON.decode(infoFile.readAsStringSync());
      row['id'] = id;
      row['info'] = info['date'] + '\n' + info['time'] + '\n+ $iter';
      row['content'] = "$id/${info['contentName']}";
      row['filter'] = "$id/${info['filterName']}";
      initResult.add(row);
    }
  }
  response.write(JSON.encode(initResult));
}
