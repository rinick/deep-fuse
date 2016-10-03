import 'dart:html';

FileUploadInputElement contentImg = document.querySelector('#contentImg');
FileUploadInputElement filterImg = document.querySelector('#filterImg');
FormElement form = document.querySelector('form');

TableCellElement contentTd = document.querySelector('#contentTd');
TableCellElement filterTd = document.querySelector('#filterTd');

main() {
  form.onSubmit.listen(onFormSubmit);
  contentImg.onChange.listen(onContentChange);
  filterImg.onChange.listen(onFilterChange);
}

onFormSubmit(Event e) {

}

onContentChange(Event e) {

}

onFilterChange(Event e) {

}