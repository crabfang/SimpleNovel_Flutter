import 'package:SimpleNoval/novel/w_book_info.dart';
import 'package:flutter/material.dart';

class BookContentWidget extends StatelessWidget {
  BookInfo info;
  BookContentWidget(this.info);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: info?.name,
        theme: new ThemeData(
          primaryColor: Colors.blue,
        ),
        home: new LayoutBody(context),
    );
  }
}

class LayoutBody extends StatefulWidget {
  BuildContext _context;
  LayoutBody(this._context);
  @override
  createState() => new LayoutBodyState();
}

class LayoutBodyState extends State<LayoutBody> {
  bool _isFavorited = true;
  void actionBack() {
    Navigator.of(widget._context).pop();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: actionBack,
        ),
        title: new Text('Flutter Detail'),
      ),
      body: bodyLayout(),
    );
  }

  void onTitleClick(bool newVal) {
    setState(() {
      _isFavorited = newVal;
    });
  }

  Widget bodyLayout() {
    return new ListView(
      children: [
        new Image.asset(
          'assets/images/pic_0.png',
          height: 240.0,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        titleWidget(isFavorited:_isFavorited, onChanged: onTitleClick),
        optionWidget(context),
        contentWidget(),
      ],
    );
  }
}

Widget titleWidget({Key key, isFavorited: true, @required onChanged}) {
  void _actionClick() {
    onChanged(!isFavorited);
  }
  return new Container(
    padding: const EdgeInsets.fromLTRB(32.0, 20.0, 32.0, 10.0),
    child: new Row(
      children: [
        new Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: new Text(
                  'Oeschinen Lake Campground',
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              new Text(
                'Kandersteg, Switzerland',
                style: new TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        new IconButton(
          icon: new Icon(isFavorited ? Icons.star : Icons.star_border),
          color: Colors.red[500],
          onPressed: _actionClick,
        ),
        new Text(isFavorited ? '41' : "40"),
      ],
    ),
  );
}

Widget optionWidget(BuildContext context) {
  return new Container(
    margin: const EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
    child: new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new ClickableColumn(new ColumnItem(Icons.call, 'CALL')),
        new ClickableColumn(new ColumnItem(Icons.share, 'SHARE')),
        new ClickableColumn(new ColumnItem(Icons.near_me, 'ROUTE')),
        new ClickableColumn(new ColumnItem(Icons.access_alarm, 'ALARM')),
      ],
    ),
  );
}

Widget contentWidget() {
  return new Container(
    padding: const EdgeInsets.fromLTRB(32.0, 10.0, 32.0, 20.0),
    child: new Text(
      '''
Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese Alps. Situated 1,578 meters above sea level, it is one of the larger Alpine Lakes. A gondola ride from Kandersteg, followed by a half-hour walk through pastures and pine forest, leads you to the lake, which warms to 20 degrees Celsius in the summer. Activities enjoyed here include rowing, and riding the summer toboggan run.
        ''',
      softWrap: true,
    ),
  );
}

class ClickableColumn extends StatefulWidget {
  final ColumnItem item;
  const ClickableColumn(ColumnItem item): item = item;
  @override
  createState() => new ClickableColumnState();

  void updateColor() {
    int colorVal = item.color.value + 100;
    item.color = new Color(colorVal);
  }
}

class ClickableColumnState extends State<ClickableColumn> {
  void actionClick() {
    setState(() {
      widget.updateColor();
    });
  }
  @override
  Widget build(BuildContext context) {
    return buildButtonColumn(widget.item, actionClick);
  }
}

MaterialButton buildButtonColumn(ColumnItem item, VoidCallback actionClick) {
  MaterialButton button = new MaterialButton(
    onPressed: actionClick,
    child: new Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Icon(item.icon, color: item.color),
        new Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: new Text(
            item.label,
            style: new TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: item.color,
            ),
          ),
        ),
      ],
    ),
  );
  return button;
}

class ColumnItem {
  IconData icon;
  String label;
  Color color = Colors.blue;
  ColumnItem(this.icon, this.label, {color: Colors.blue});
}