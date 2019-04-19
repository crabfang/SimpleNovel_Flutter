import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WBookInfo extends StatelessWidget {
  BookInfo bookInfo;
  WBookInfo(BookInfo bookInfo):bookInfo = bookInfo;
  @override
  Widget build(BuildContext context) {
    return _createBook(bookInfo);
  }
}

InkWell _createBook(BookInfo bookInfo) {
  return new InkWell(
    onTap: () {
      //TODO
    },
    child: new Container(
        height: 160.0,
        padding: EdgeInsets.all(16.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      bookInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    new Expanded(
                      flex: 1,
                      child: new Text(
                        bookInfo.author,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    new Row(
                      children: <Widget>[
                        new Text(
                          bookInfo.size,
                        ),
                      ],
                    )
                  ],
                )),
            new Container(
              width: 90,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 10.0),
              child: new CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl: bookInfo.cover,
                errorWidget: new Icon(Icons.error),
              ),
            )
          ],
        ),
        decoration: new BoxDecoration(
            color: Colors.white,
            border: new Border(
                bottom: new BorderSide(width: 0.33, color: Colors.grey)
            )
        )
    ),
  );
}

class BookInfo {
  String cover;
  String name;
  String author;
  String size;
  String state;
  String source;
  String url;
  BookInfo(this.cover, this.name, this.url, { this.author:"", this.size:"", this.state:"", this.source:"" });
}