import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteagram01/wasteagram_newPost.dart';
import 'models/error_message.dart';
import 'wasteagram_newPost.dart';
import 'models/FoodWastePosts.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailsPage extends StatefulWidget
{

  @override
  State<StatefulWidget> createState()
  {
    return _DetailsPageState();
  }
}

class _DetailsPageState extends State<DetailsPage>
{
  List<Posts> postsList = [];

  @override
  void initState() {
    super.initState();

    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("Posts");

    postsRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postsList.clear();

      for(var individiualKey in KEYS) {
        Posts posts = new Posts(
          DATA[individiualKey]['date'],
          DATA[individiualKey]['time'],
          DATA[individiualKey]['Image'],
          DATA[individiualKey]['quantity'],
          DATA[individiualKey]['latitude'],
          DATA[individiualKey]['longitude'],
        );

        postsList.add(posts);
      }
      setState(() {
        print("Length: $postsList.length");   //RETURNS TOTAL NUMBER OF POSTS
      });
    });

  }



  DialogBox dialogBox = new DialogBox();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text("Wasteagram - ${postsList.length}"),    //NOTE - need to get count of posts
        ),
        body: new Container(
          child: postsList.length == 0 ? new Text("No entries") : new ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (_, index) {
                return PostsUI(postsList[index].date, postsList[index].time, postsList[index].quantity, postsList[index].image, postsList[index].latitude, postsList[index].longitude);
              },
          ),
        ),
  //NOTE: REPLACE WITH JUST AN ADD PHOTO
        bottomNavigationBar: new BottomAppBar(
          color: Colors.blue,
          child: new Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Semantics(
                  child: new IconButton(
                    icon: new Icon(Icons.add_a_photo),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context){
                            return new UploadPhotoPage();
                          })
                      );
                    },  //This will go to a new page
                  ),
                  label: "To add a new photo of wasted item",
                  hint: "Add new item",
                ),
              ],
            ),
          ),
        ),
      );
  }
  //CREATE UI OF POSTS
  // ignore: non_constant_identifier_names
  Widget PostsUI(String date, String time, String quantity, String image, String latitude, String longitude) {
    return new Card(
      elevation: 10.0,
      margin: EdgeInsets.all(15.0),
        child: new Container(
            padding: new EdgeInsets.all(14.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                      date,
                      style: Theme.of(context).textTheme.subtitle,
                      textAlign: TextAlign.center,
                    ),

                    new Text(
                      time,
                      style: Theme.of(context).textTheme.subtitle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 10.0),

                new Image.network(image, fit: BoxFit.cover),

                SizedBox(height: 10.0),

                Semantics(
                  child: new Text(
                    "Items: $quantity",
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                  ),
                  label: "Number of items wasted",
                ),

                SizedBox(height: 10.0),
                new Text(
                  "Latitude: $latitude",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),

                new Text(
                  "Longiture: $longitude",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ),
    );
  }
}