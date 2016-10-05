part of neural_style_client;


class FullImage {
  IFrameElement iframe;

  FullImage(this.iframe) {
    window.onMessage.listen(onWindowMessage);
  }

  show(String src) {
    iframe.src = 'full.html#' + Uri.encodeComponent(src);
    iframe.style.display = '';
  }

  onWindowMessage(MessageEvent e) {
    if (e.data == 'close') {
      iframe.src = '';
      iframe.style.display = 'none';
    }
  }
}