import 'package:flutter/widgets.dart';

class MySliverChildDelegate extends SliverChildBuilderDelegate {
  Function(int firstIndex, int lastIndex) scrollChange;
  MySliverChildDelegate(
      Widget Function(BuildContext, int) builder, {
        int childCount,
        this.scrollChange,
        Function(Widget widget, int localIndex) indexCallback,
      }) : super(builder,
      childCount: childCount,
      semanticIndexCallback: (Widget widget, int localIndex) {
        if(indexCallback != null) {
          indexCallback(widget, localIndex);
        }
        return localIndex;
      }
      );
  ///监听 在可见的列表中 显示的第一个位置和最后一个位置
  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    if(scrollChange != null) {
      scrollChange(firstIndex, lastIndex);
    }
  }
  ///可不重写 重写不能为null  默认是true  添加进来的实例与之前的实例是否相同 相同返回true 反之false
  ///listView 暂时没有看到应用场景 源码中使用在 SliverFillViewport 中
  @override
  bool shouldRebuild(SliverChildBuilderDelegate oldDelegate) {
    return super.shouldRebuild(oldDelegate);
  }
}