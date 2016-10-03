import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as Path;
import 'package:mime/mime.dart' as Mime;

String webDir = Platform.script
    .resolve('../web')
    .path;

RegExp ipReg = new RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');

main(List<String> arguments) {
  if (webDir.codeUnitAt(2) == 58 /* for windows path /C:/ */) {
    webDir = webDir.substring(1);
  }
  if (webDir.endsWith('/')) {
    webDir.substring(0, webDir.length - 1);
  }

  // find ip
  String ip = '127.0.0.1';
  try {
    ProcessResult result = Process.runSync('hostname', ['-I']);
    List ips = result.stdout.toString().split(' ').where((str) {
      return ipReg.hasMatch(str);
    }).toList();
    List vbips = ips.where((str) {
      return str.startsWith(
          '192.168.56.'); // find virtual box host only network
    }).toList();

    if (vbips.isNotEmpty) {
      ip = vbips[0];
    } else if (ips.isNotEmpty) {
      ip = ips[0];
    }
  } catch (err) {}


  HttpServer.bind(InternetAddress.ANY_IP_V4, 8424).then((server) {
    print('server starts on http://$ip:8424');
    server.listen(handleRequest);
  });
}

handleRequest(HttpRequest request) async {
  try {
    String path = request.uri.path;
    if (path == '/' || path == '') {
      path = '/index.html';
    }
    if (path.contains('.')) {
      if (path.contains('..')) {
        request.response.statusCode = 404;
        await request.response.close();
      } else {
        await sendFile(request.response, new File(webDir + path));
      }
    } else {

    }
  } catch (err) {
    print(err);
  }
  await request.response.close();

}

sendFile(HttpResponse response, File file) async {
  print('sending file ${file.path}');
  try {
    await file.openRead().listen((data) {
      String mime = Mime.lookupMimeType(file.path);
      response.headers.contentType = ContentType.parse(mime);
      response.add(data);
    }).asFuture();
  } catch (err) {
    response.statusCode = 404;
  }
}