library neural_style_server;


import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:mime/mime.dart' as Mime;
import 'package:http_server/src/http_multipart_form_data.dart' as FormData;

part './task.dart';
part './init.dart';
part './last.dart';
part './upload.dart';

String webDir = Platform.script
    .resolve('../build/web')
    .path;

String nsDir = Platform.script
    .resolve('../neural-style')
    .path;

String historyDir = Platform.script
    .resolve('../history')
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
      path = '/zh.html';
    }
    if (path.contains('.')) {
      if (path.contains('..')) {
        request.response.statusCode = 404;
        await request.response.close();
      } else {
        int pathStartChar = path.codeUnitAt(1);
        if (pathStartChar >= 0x30 && pathStartChar <=0x39) {
          await sendFile(request.response, new File(historyDir + path));
        } else {
          await sendFile(request.response, new File(webDir + path));
        }

      }
    } else {
      if (path == '/init') {
        await handleInit(request.response);
      } else if (path == '/last') {
        await handleLast(request.response);
      } else if (path == '/upload') {
        await handleUpload(request, request.response);
      }
}
  } catch (err) {
    print(err);
  }
  await request.response.close();

}

sendFile(HttpResponse response, File file) async {
  print('sending file ${file.path}');
  try {
    String mime = Mime.lookupMimeType(file.path);
    response.headers.contentType = ContentType.parse(mime);
    await for (List<int> data in await file.openRead()) {
      response.add(data);
    };
  } catch (err) {
    response.statusCode = 404;
    response.write('$err');
  }
}