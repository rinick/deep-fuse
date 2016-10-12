part of deep_fuse_web;


class Frame {
  IFrameElement iframe;

  Frame(this.iframe) {
    window.onMessage.listen(onWindowMessage);
  }

  showImg(String src) {
    iframe.src = 'full.html#' + Uri.encodeComponent(src);
    iframe.style.display = '';
  }

  showDetail(String json) {
    iframe.src = 'detail.html#' + Uri.encodeComponent(json);
    iframe.style.display = '';
  }

  onWindowMessage(MessageEvent e) {
    if (e.data == 'close') {
      iframe.src = '';
      iframe.style.display = 'none';
    }
  }
}