import 'package:SimpleNovel/book_contents.dart';
import 'package:SimpleNovel/utils/net.dart';
import 'package:SimpleNovel/novel/w_book_info.dart';
import 'package:SimpleNovel/utils/thread_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;

class BookDetailWidget extends StatelessWidget {
  BookInfo info;
  BookDetailWidget(this.info);

  @override
  Widget build(BuildContext context) {
    return new BookDetailView(context, info);
  }
}

class BookDetailView extends StatefulWidget {
  BuildContext _context;
  BookInfo info;
  BookDetailState detailState = BookDetailState();
  BookDetailView(this._context, this.info);
  @override
  createState() => detailState;
}

class BookDetailState extends State<BookDetailView> {
  String state = "状态：";
  String updateTime = "更新时间：";
  String getBookUrl() {
    return widget.info?.url;
  }
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
    setState(() {
      gridWidget.setGridData(contentList);
    });
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
      body: new Column(
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.fromLTRB(20, 10.0, 20, 0.0),
            alignment: Alignment.center,
            child: new Text(widget.info.author),
          ),
          new Container(
            margin: const EdgeInsets.fromLTRB(20, 0.0, 20, 10.0),
            child:
            new Row(
              children: <Widget>[
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
          Expanded(
            child: gridWidget,
          ),
        ],
      ),
    );
  }

  ContentInfo createDemo(String title) {
    return ContentInfo(title, "");
  }
}

void loadDetail(BuildContext context, BookDetailState state, String url) {
  if(url == null || url.isEmpty) return;

  Future<String> body = NetUtils.queryGbk(url);

  body.then((bodyStr) {
    return parseHtml(state, bodyStr);
  }).then((list) {
    ThreadUtils.doOnMain(() {
      state.updateState(list);
    });
  });
}

Future<List<ContentInfo>> parseHtml(BookDetailState state, String htmlStr) async {
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
      contentInfo.url = state.getBookUrl() + contentInfo.url;
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
    if(contentList == null || contentList.length == 0) {
      return Container(
        child: CupertinoActivityIndicator(),
        alignment: Alignment.center,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
//      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        childAspectRatio: 3,//宽高比为value = width / height
      ),
      itemCount: contentList.length,
      itemBuilder: (BuildContext context, int index) {
        ContentInfo info = contentList.elementAt(index);
        return GestureDetector(
          child: Container(
            child: new Text(
              info.title,
              style: TextStyle(
                color: Colors.blueAccent,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            alignment: Alignment.centerLeft,
          ),
          onTap: () {
            Navigator.of(context).push(
                new MaterialPageRoute(builder: (context) => new BookContentsWidget(contentList, info))
            );
          },
        );
      },
    );
  }
  void updateState(List<ContentInfo> contentList) {
    setState(() {
      this.contentList = contentList;
    });
  }
}