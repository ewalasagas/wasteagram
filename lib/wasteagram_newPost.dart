import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'wasteagram_ListScreen.dart';

class UploadPhotoPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {

  File imageFile;
  String _myValue;
  String url;
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Upload Image"),
        centerTitle: true,
      ),

      body: new Center(
        child: imageFile == null ? Text("Select an Image") : enableUpload(),
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: "Add Image",
        child: new Icon(Icons.add_a_photo),
        onPressed: getImage,
      ),
    );
  }


  _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context){
    return showDialog(context: context,builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Make a choice"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Gallery"),
                onTap: () {
                  _openGallery(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                child: Text("Camera"),
                onTap: () {
                  _openCamera(context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _decideImageView() {
    if(imageFile == null) {
      return Text("No image selected!");
    } else {
      return Image.file(imageFile, height: 330.0, width: 630.0,);
    }
  }

  // ignore: missing_return
  bool validateAndSave() {
    final form = formKey.currentState;

    if(form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }


  void backToHomePage() {
    Navigator.push(
      context,
        MaterialPageRoute(builder: (context) {
          return new DetailsPage();
          }
        )
    );
  }

  void uploadStatusImage() async {
    if(validateAndSave()) {
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post Images");

      //store current time - this will be unique?
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(imageFile);

      //store in firebase
      var ImageUrl = await(await uploadTask.onComplete).ref.getDownloadURL();

      url = ImageUrl.toString();
      print("Image Url = " + url);

      //Go back to wasteagram_ListScreen.dart
      backToHomePage();

      saveToDatabase(url);
    }
  }


  Future getImage() async {
      _showChoiceDialog(context);
  }

  //GET CURRENT POSITION
  Position _currentPosition;

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget enableUpload() {
    //get current position/location

    return new Container(
      padding: EdgeInsets.all(10),
      child: new Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Expanded(
              child: Image.file(imageFile, height: 330.0, width: 630.0,),
            ),
            Container(
              padding: EdgeInsets.all(10),

              child: TextFormField(
                //INPUT NUMBER OF ITEMS?
                decoration: new InputDecoration(
                  labelText: 'Items',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],

                validator: (value) {
                  return value.isEmpty ? 'Number of items is required' : null;
                },

                onSaved: (value) {
                  return  _myValue = value;
                },

              ),
            ),
            //SizedBox(height: 5.0,),

            //GET LOCATION
            if (_currentPosition != null)
              Text(
                  "(${_currentPosition.latitude}, ${_currentPosition.longitude})"),
            FlatButton(
              child: Text("Get location"),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
              SizedBox(height: 15.0),
              RaisedButton(
                elevation: 10.0,
                child: Text("Add a new post"),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: uploadStatusImage,
              ),
          ],
        ),
      ),
    );
  }

  void saveToDatabase(url) {
    //to get unique data
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat("MMM d, yyyy, EEEE");
    var formatTime = new DateFormat("EEEE, hh:mm aaa");

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "Image": url,
      "quantity": _myValue,
      "date": date,
      "time": time,
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
    };

    ref.child("Posts").push().set(data);
  }
}
