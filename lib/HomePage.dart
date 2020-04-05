import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:location/location.dart";
import "package:http/http.dart" as http;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location location=new Location();
  bool _serviceEnabled;
  bool gotData=false;
  PermissionStatus _permissionStatus;
  LocationData _locationData;
  final String urlInitial="https://api.openweathermap.org/data/2.5/weather?";
  final String latitude="lat=";
  final String longnitude="&lon=";
  final String apiKey="&appid=1b71f31054b246914d5c6e5220a26940";
  final String forCity="q=";
  bool isInTextMode=false;
  TextEditingController textEditingController;
  var data;
  bool onCoordinate=false;

  @override
  void initState() {
    super.initState();
    textEditingController=new TextEditingController();
    setupLocation();
  }

  Future setupLocation() async {
    _serviceEnabled= await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled=await location.requestService();
      if(!_serviceEnabled){
        return;
      }
    }

    _permissionStatus = await location.hasPermission();
    if(_permissionStatus==PermissionStatus.DENIED){
      _permissionStatus=await location.requestPermission();
      if(_permissionStatus==PermissionStatus.GRANTED){
        return;
      }
    }

    grabeLocationData();
  }

  Future grabeLocationData() async{
    _locationData=await location.getLocation();
    if(_locationData.toString()!=""){
      viaCoordinate(_locationData.latitude.toString(),_locationData.longitude.toString());
    }
  }

  void viaCoordinate(String lat,String lon){
    String url=urlInitial+latitude+lat+longnitude+lon+apiKey;
    getApiData(url);
  } 

  void viaCityName(String city){
    onCoordinate=true;
    String url=urlInitial+forCity+city+apiKey;
    getApiData(url);
  }

  Future getApiData(String url) async{
    var responce=await  http.get(Uri.encodeFull(url));
    data=jsonDecode(responce.body); 
    setState(() {
      gotData=true;
    });
  }

  int kelvinToCelcus(double value){
    return (value-273.15).toInt();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Row(
          children: <Widget>[
            Icon(Icons.wb_cloudy,color: Colors.white,),
            SizedBox(width: 10.0,),
            Text("Weather",style:TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body:Center(
        child:!gotData?CircularProgressIndicator()
        :SingleChildScrollView(
          child: Container(
            width:MediaQuery.of(context).size.width,
            height:MediaQuery.of(context).size.height,
            child: Column(
              children:<Widget>[
                Card(
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              isInTextMode=true;
                            });
                          },
                          child: !isInTextMode?Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(data["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize:25.0),),
                                  !onCoordinate?Icon(Icons.location_on,color:Colors.grey):Container(),
                                  SizedBox(width: 3.0,),
                                  Icon(Icons.edit_location,color: Colors.blueAccent,)
                                ],
                              ),
                              onCoordinate?IconButton(
                                icon: Icon(Icons.location_searching,color: Colors.red,),
                                onPressed: (){
                                  setState(() {
                                    onCoordinate=false;
                                    gotData=false;
                                    grabeLocationData();
                                  });
                                },
                              ):Container(),
                            ],
                          )
                          :Row(children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  labelText: "City...",
                                ),
                              ),
                            ),
                            RaisedButton(
                              color:Colors.blueAccent,
                              onPressed: (){
                                setState(() {
                                  viaCityName(textEditingController.text);
                                  textEditingController.text="";
                                  gotData=false;
                                  isInTextMode=false;
                                });
                              },
                              child: Text("Check",style:TextStyle(color:Colors.white)),
                            ),
                          ],),
                        ),
                        SizedBox(height: 8.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:<Widget>[
                            // SizedBox(width: 1.0,),
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(kelvinToCelcus(data["main"]["temp"].toDouble()).toString()+"℃",style: TextStyle(fontSize:70.0,fontWeight: FontWeight.w500),)
                              ],
                            ),
                            Text(data["weather"][0]["main"],style: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.w800,fontSize: 23.0),),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Text("Max:",style: TextStyle(color:Colors.red),),
                            Text(kelvinToCelcus(data["main"]["temp_max"].toDouble()).toString()+"℃"),
                            SizedBox(width:5.0),
                            Text("Min:",style: TextStyle(color:Colors.lightGreen),),
                            Text(kelvinToCelcus(data["main"]["temp_min"].toDouble()).toString()+"℃"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget>[
                        Column(
                          children: <Widget>[
                            Text("Wind",style:TextStyle(fontWeight: FontWeight.w500,fontSize: 20.0)),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 20.0,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                     Row(
                                       children: <Widget>[
                                         Text("Speed:",style:TextStyle(fontWeight: FontWeight.w200,)),
                                         Text(data["wind"]["speed"].toString()),
                                       ],
                                     ),
                                     Row(
                                       children: <Widget>[
                                         Text("Deg:",style:TextStyle(fontWeight: FontWeight.w200,)),
                                         Text(data["wind"]["deg"].toString()),
                                       ],
                                     ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              child: Image(
                                image: AssetImage("Assets/wind.png"),
                              )                     
                            ),
                            SizedBox(width:5.0),
                          ],
                        ),
                      ]
                    ),
                  ),
                ),
                Card(
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children:<Widget>[
                        Row(
                          children: <Widget>[
                            Text("Pressure   :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["main"]["pressure"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        Row(
                          children: <Widget>[
                            Text("Humidity   :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["main"]["humidity"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        Row(
                          children: <Widget>[
                            Text("Visibility     :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["visibility"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        Row(
                          children: <Widget>[
                            Text("Sunrise      :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["sys"]["sunrise"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        Row(
                          children: <Widget>[
                            Text("Sunset       :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["sys"]["sunset"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        //THERE WAS A MISTAKE(long <-> lati)
                        Row(
                          children: <Widget>[
                            Text("Longitude :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["coord"]["lat"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        Row(
                          children: <Widget>[
                            Text("Latitude    :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["coord"]["lon"].toString()),
                          ],
                        ),
                        SizedBox(height:5.0),
                        Row(
                          children: <Widget>[
                            Text("Country    :",style:TextStyle(fontWeight: FontWeight.w200,)),
                            Text(data["sys"]["country"].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
