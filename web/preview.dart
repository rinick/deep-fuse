part of neural_style_server;

class Preview {
  FileUploadInputElement uploader;
  ImageElement preview;

  Preview(this.uploader, this.preview) {
    print(this.uploader);
    uploader.onChange.listen(onContentChange);
  }

  clear() {
    if (preview.src != '') {
      Url.revokeObjectUrl(preview.src);
      preview.src = '';
    }
  }

  bool isEmpty() {
    return uploader.files.length != 1;
  }

  onContentChange(Event e) {
    clear();
    if (uploader.files.length != 1) {
      return;
    }

    FileReader fr = new FileReader();

    void onLoadEnded(Event event) {
      preview.src = fr.result;
    }

    fr.onLoadEnd.listen(onLoadEnded);
    fr.readAsDataUrl(uploader.files[0]);
  }
}
