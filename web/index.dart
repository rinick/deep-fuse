library neural_style_client;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

part 'preview.dart';

part 'full_img.dart';

Preview contentPreview;
Preview stylePreview;
FullImage fullImage;

FormElement form;
TableElement table;
TableRowElement currentTr;
String currentId;


main() {
  contentPreview = new Preview(document.querySelector('#contentFile'),
      document.querySelector('#contentImg'));
  stylePreview = new Preview(document.querySelector('#styleFile'),
      document.querySelector('#styleImg'));
  fullImage = new FullImage(document.querySelector('#fullImg'));
  table = document.querySelector('table');
  form = document.querySelector('form');

  form.onSubmit.listen(onFormSubmit);

  HttpRequest.getString('/init').then(onInitLoad);
  new Timer.periodic(new Duration(seconds: 5), onTimer);

}

onFormSubmit(Event e) {
  e.preventDefault();
  if (contentPreview.isEmpty() || stylePreview.isEmpty()) {
    return;
  }
  FormData formData = new FormData(form);

  HttpRequest.request('/upload', method: 'POST', sendData: formData).then((
      req) {
    // load update;
    onTimer(null);
  });
}

onInitLoad(String str) {
  List list = JSON.decode(str);
  for (Map row in list) {
    TableRowElement tr = table.addRow();
    updateRow(row, tr);
  }
}

updateRow(Map row, TableRowElement tr) {
  tr.addCell().append(
      new ImageElement(src: row['result'])..onClick.listen(onImageClicked));
  tr.addCell().appendText(row['info']);
  tr.addCell().append(
      new ImageElement(src: row['content'])..onClick.listen(onImageClicked));
  tr.addCell().append(
      new ImageElement(src: row['style'])..onClick.listen(onImageClicked));
  tr.dataset['id'] = row['id'];
  if (row['running'] == true) {
    currentId = row['id'];
    currentTr = tr;
  }
}

onImageClicked(MouseEvent e) {
  fullImage.show((e.target as ImageElement).src);
}

onTimer(Timer t) {
  HttpRequest.getString('/last').then(onUpdateLoad);
}

onUpdateLoad(String str) {
  if (str.length < 5) return;
  Map row = JSON.decode(str);
  if (row['id'] == currentId) {
    currentTr.cells[1].text = row['info'];
    (currentTr.cells[0].querySelector('img') as ImageElement).src =
    row['result'];
  } else {
    TableRowElement tr = table.insertRow(1);
    updateRow(row, tr);
  }
}

