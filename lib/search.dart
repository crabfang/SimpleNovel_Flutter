import 'package:SimpleNovel/utils/thread_utils.dart';
import 'package:flutter/material.dart';
import 'package:SimpleNovel/utils/net.dart';
import 'package:SimpleNovel/novel/w_book_info.dart';
import 'package:SimpleNovel/waitingDialog.dart' as Waiting;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart' show parse;

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchInput(context);
  }
}

class SearchInput extends StatefulWidget {
  BuildContext _context;
  SearchInput(this._context);
  @override
  createState() => new SearchInputState();
}

class SearchInputState extends State<SearchInput> {
  TextEditingController searchInputController = new TextEditingController();
  ListContent listContent = new ListContent();
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('搜索'),
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(widget._context).pop(),
        ),
      ),
      body: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: createEdit(searchInputController),
                flex: 4,
              ),
              new Expanded(
                child: new IconButton(
                    icon: new Icon(Icons.search),
                    onPressed: () => actionSearch(widget._context, listContent, searchInputController.text)
                ),
                flex: 1,
              ),
            ],
          ),
          Expanded(
            child: listContent,
          ),
        ],
      ),
    );
  }
}

Widget createEdit(TextEditingController controller) {
  return new TextField(
    controller: controller,
    maxLines: 1,//最大行数
    autofocus: false,//是否自动对焦
    style: TextStyle(fontSize: 16.0, color: Colors.black),//输入文本的样式
    decoration: new InputDecoration(
      contentPadding: const EdgeInsets.all(10.0),
      hintText: "请输入小说名或者作者",
    ),
    onSubmitted: (text) {
      toastInfo(text);
    },
  );
}

void actionSearch(BuildContext context, ListContent listContent, String inputStr) {
  Waiting.WaitingDialog waitingDialog = Waiting.showWaiting(context, "请稍候...");
  waitingDialog.updateContent("搜索中");

  Map<String, dynamic> params = new Map();
  params["search_field"] = "0";
  params["q"] = inputStr;

  String url = "https://so.88dush.com/search/so.php";
  Future<String> body = NetUtils.query(url, queryParameters: params);

  body.then((bodyStr) {
        waitingDialog.updateContent("解析中");
        return parseHtml(bodyStr);
      })
      .then((list) {
        ThreadUtils.doOnMain(() {
          listContent.setListData(list);
        });
        Navigator.pop(context);
      })
      .catchError((e) {
        Navigator.pop(context);
      });
}

Future<List<BookInfo>> parseHtml(String htmlStr) async {
  List<BookInfo> bookList = new List();
  Dom.Document document = parse(htmlStr);
  var list = document.body.querySelectorAll("div.block");
  list.forEach((dl) {
    BookInfo bookInfo = parseHtmlDl(dl);
    if(bookInfo != null) {
      bookList.add(bookInfo);
    }
  });
  return bookList;
}

BookInfo parseHtmlDl(Dom.Element div) {
  Dom.Element domImg = div.getElementsByTagName("img").elementAt(0);
  Dom.Element domInfo = div.getElementsByClassName("block_txt").elementAt(0);

  String title = getHtmlText(domInfo.getElementsByTagName("h2").elementAt(0));
  String url = domInfo.getElementsByTagName("a").elementAt(0).attributes["href"];
  String pic = domImg.attributes["src"];
  String author = getHtmlText(domInfo.getElementsByTagName("p").elementAt(2));
  String novelType = getHtmlText(domInfo.getElementsByTagName("p").elementAt(3));
  String desc = getHtmlText(domInfo.getElementsByTagName("p").elementAt(4));

  return new BookInfo(pic, title, url, author: author, source: "来源：八八读书网", type: novelType, desc: desc);
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
class ListContent extends StatefulWidget {
  ContentState state = new ContentState();
  @override
  createState() => state;
  void setListData(List<BookInfo> bookList) {
    state.updateState(bookList);
  }
}

class ContentState extends State<ListContent> {
  List<BookInfo> _bookList = new List();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
        itemCount: _bookList.length,
        itemBuilder: (context, index) => WBookInfo(_bookList.elementAt(index)),
    );
  }
  void updateState(List<BookInfo> bookList) {
    _bookList = bookList;
    setState(() {
    });
  }
}