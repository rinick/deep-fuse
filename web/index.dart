library neural_style_client;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

part 'preview.dart';

part 'popup_frame.dart';

Preview contentPreview;
Preview stylePreview;
Frame frame;

FormElement form;
TableElement table;
TableRowElement currentTr;
String currentId;

Map translation;

String translate(String str) {
  if (translation != null && translation.containsKey(str)) {
    return translation[str];
  }
  return str;
}

main() {
  contentPreview = new Preview(document.querySelector('#contentFile'),
      document.querySelector('#contentImg'));
  stylePreview = new Preview(document.querySelector('#styleFile'),
      document.querySelector('#styleImg'));
  frame = new Frame(document.querySelector('#popupFrame'));
  table = document.querySelector('table');
  form = document.querySelector('form');

  Element translationInput = document.querySelector('#translation');
  if (translationInput is InputElement) {
    translation = JSON.decode(translationInput.value);
  }

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
  updateInfoCell(tr.addCell(), row);
  tr.addCell().append(
      new ImageElement(src: row['content'])..onClick.listen(onImageClicked));
  tr.addCell().append(
      new ImageElement(src: row['style'])..onClick.listen(onImageClicked));
  tr.dataset['id'] = row['id'];
  if (row['running'] == true) {
    if (currentTr != null) {
      currentTr.classes.remove('currentRow');
    }
    currentId = row['id'];
    currentTr = tr;
    tr.classes.add('currentRow');
  }
}

void updateInfoCell(TableCellElement cell, Map info) {
  cell.children.clear();
  cell.appendText("${translate('iteration')}: ${info['iter']}\n");

  AnchorElement a0 = new AnchorElement();
  a0.text = translate('detail');
  a0.dataset['info'] = JSON.encode(info);
  a0.onClick.listen(onDetailClicked);
  cell.append(a0);

  cell.appendText("\n${info['date']}\n");
  cell.appendText(info['time'] + '\n');

  AnchorElement a1 = new AnchorElement();
  a1.text = translate('delete');
  a1.onClick.listen(onDeleteClicked);
  cell.append(a1);
}

onImageClicked(MouseEvent e) {
  frame.showImg((e.target as ImageElement).src);
}

onDetailClicked(MouseEvent e) {
  frame.showDetail((e.target as HtmlElement).dataset['info']);
}

onDeleteClicked(MouseEvent e) {
  TableRowElement tr = (e.target as HtmlElement).parent.parent;
  String id = tr.dataset['id'];
  tr.remove();
  HttpRequest.getString("/delete?id=$id");
  if (tr == currentTr) {
    currentTr = null;
    currentId = null;
  }
}

onTimer(Timer t) {
  HttpRequest.getString('/last').then(onUpdateLoad);
}

onUpdateLoad(String str) {
  if (str.length < 5) {
    if (currentTr != null) {
      currentTr.classes.remove('currentRow');
      currentTr = null;
      currentId = null;
    }
    return;
  }
  Map row = JSON.decode(str);
  if (row['id'] == currentId) {
    updateInfoCell(currentTr.cells[1], row);
    (currentTr.cells[0].querySelector('img') as ImageElement).src =
    row['result'];
  } else {
    TableRowElement tr = table.insertRow(1);
    updateRow(row, tr);
  }
}

