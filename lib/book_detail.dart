import 'package:SimpleNoval/net.dart';
import 'package:SimpleNoval/novel/w_book_info.dart';
import 'package:SimpleNoval/waitingDialog.dart' as Waiting;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;

class BookDetailWidget extends StatelessWidget {
  BookInfo info;
  BookDetailWidget(this.info);
  BookDetailView bookDetailView;

  @override
  Widget build(BuildContext context) {
    return new BookDetailView(context, info);
  }
}

class BookDetailView extends StatefulWidget {
  BuildContext _context;
  BookInfo info;
  BookDetailViewState detailState = BookDetailViewState();
  BookDetailView(this._context, this.info);
  @override
  createState() => detailState;
}

class BookDetailViewState extends State<BookDetailView> {
  String state = "状态：";
  String updateTime = "更新时间：";
  @override
  void initState() {
    super.initState();
    Future.delayed(new Duration(milliseconds: 200)).then((result) {
      loadDetail(widget._context, this, widget.info?.url);
    });
  }
  void setBookInfo(String state, String updateTime) {
    this.state = state;
    this.updateTime = updateTime;
    setState(() {});
  }
  void updateState(List<ContentInfo> contentList) {
    gridWidget.setGridData(contentList);
    setState(() {});
  }
  GridContent gridWidget = GridContent();
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(widget._context).pop(),
        ),
        title: new Text(widget.info?.name),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: (){
          }),
        ],
      ),
      body: new ListView(
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.fromLTRB(20, 10.0, 20, 10.0),
            child:
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Text(widget.info.author),
                  flex: 1,
                ),
                new Expanded(
                  child: new Text(state),
                  flex: 1,
                ),
                new Expanded(
                  child: new Text(updateTime),
                  flex: 1,
                ),
              ],
            ),
          ),
          gridWidget,
        ],
      ),
    );
  }

  ContentInfo createDemo(String title) {
    return ContentInfo(title, "");
  }
}

void loadDetail(BuildContext context, BookDetailViewState state, String url) {
  Waiting.WaitingDialog waitingDialog = Waiting.showWaiting(context, "请稍候...");
  waitingDialog.updateContent("正在获取数据");

  if(url == null || url.isEmpty) return;

  Future<String> body = NetUtils.queryGbk(url);

  body.then((bodyStr) {
    waitingDialog.updateContent("数据解析");
    return parseHtml(state, bodyStr);
  }).then((list) {
    state.updateState(list);
    Navigator.pop(context);
  }).catchError((e) {
    Navigator.pop(context);
  });
}

Future<List<ContentInfo>> parseHtml(BookDetailViewState state, String htmlStr) async {
  List<ContentInfo> contentList = new List<ContentInfo>();
  Dom.Document document = parse(htmlStr);
  var infoDom = document.body.querySelectorAll("div.msg").elementAt(0);
  if(infoDom != null) {
    String stateStr = infoDom.getElementsByTagName("em").elementAt(1).text;
    String updateTime = infoDom.getElementsByTagName("em").elementAt(2).text;
    state.setBookInfo(stateStr, updateTime);
  }

  var list = document.body.querySelectorAll("div.mulu>ul>li");
  list.forEach((dl) {
    ContentInfo contentInfo = parseHtmlDl(dl);
    if(contentInfo != null) {
      contentList.add(contentInfo);
    }
  });
  return contentList;
}

ContentInfo parseHtmlDl(Dom.Element div) {
  var domList = div.getElementsByTagName("a");
  if(domList == null || domList.length == 0) return null;

  Dom.Element domInfo = domList.elementAt(0);

  String title = getHtmlText(domInfo);
  String url = domInfo.attributes["href"];

  return new ContentInfo(title, url);
}

String getHtmlText(Dom.Element element) {
  return element?.text
      ?.replaceAll("\n", "")
      ?.replaceAll("\t", "")
      ?.trim();
}

void toastInfo(String info) {
  Fluttertoast.showToast(
    msg: info,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIos: 1,
  );
}

// ignore: must_be_immutable
class GridContent extends StatefulWidget {
  ContentState state = new ContentState();
  @override
  createState() => state;
  void setGridData(List<ContentInfo> contentList) {
    state.updateState(contentList);
  }
}

class ContentState extends State<GridContent> {
  List<ContentInfo> contentList = new List();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      shrinkWrap: true,
      physics:NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        childAspectRatio: 3,//宽高比为value = width / height
      ),
      itemCount: contentList.length,
      itemBuilder: (BuildContext context, int index) {
        ContentInfo info = contentList.elementAt(index);
        return Container(
          child: new Text(
            info.title,
            style: TextStyle(
              color: Colors.blueAccent,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          alignment: Alignment.centerLeft,
        );
      },
    );
  }
  void updateState(List<ContentInfo> contentList) {
    this.contentList = contentList;
    setState(() {
    });
  }
}