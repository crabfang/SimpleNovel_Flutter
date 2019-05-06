class ThreadUtils {
  static void doOnMain(Function() function) {
    Future.delayed(Duration(milliseconds: 400), () {
      if(function != null) {
        function();
      }
  });
  }
}