import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/pages/pageInPage/home.dart';
import 'package:like_app/pages/pageInPage/likes.dart';
import 'package:like_app/pages/pageInPage/postPage/post.dart';
import 'package:like_app/pages/pageInPage/profilePage/profilePage.dart';
import 'package:like_app/pages/pageInPage/search.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:image/image.dart' as img;


class HomePage extends StatefulWidget {

  final int pageIndex;

  const HomePage({super.key, required this.pageIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthServie authServie = AuthServie();

  String userName = "";
  String email = "";

  bool isEmailVerified = false;
  bool isErrorOccurred = false;

  bool isImagesLoading = false;

  static List<File> selectedImages = [];
  final picker = ImagePicker();

  int selectedIndex = 0;

  var logger = Logger();

  @override
  void initState() {
    selectedIndex = widget.pageIndex;

    setState(() {
      if (this.mounted) {
        _widgetOptions[0] =  Home(scrollController: homeScrollController);
        _widgetOptions[1] =  LikesRanking(scrollController: likeScrollController);
        _widgetOptions[3] = ProfilePage(scrollController: profileScrollController);
      }
    });

    super.initState();
    gettingUserData();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      DatabaseService userService = new DatabaseService();
      userService.updateMessagingToken(newToken);
    });

  }

  gettingUserData() async {

    try {
      await HelperFunctions.getUserEmailFromSF().then((value) => {
        setState(() {
          email = value!;
        })
      });

      await HelperFunctions.getUserNameFromSF().then((value) => {
        setState(() {
          userName = value!;
        })
      });

    } catch(e) {
      if (this.mounted) {setState(() {
        isErrorOccurred = true;
      });}
      logger.log(Level.error, "error occurred while getting user data\nerror: " + e.toString());
    }
  }

  final PageController _pageController = PageController();
  final ScrollController homeScrollController = ScrollController();
  final ScrollController profileScrollController = ScrollController();
  final ScrollController likeScrollController = ScrollController();

  @override
  void dispose() {
    _pageController.dispose();
    homeScrollController.dispose();
    super.dispose();
  }

  final _widgetOptions = <Widget>[
    Home(scrollController: ScrollController()),
    LikesRanking(scrollController: ScrollController()),
    Post(images: []),
    ProfilePage(scrollController: ScrollController())
  ];

  @override
  Widget build(BuildContext context) {

    double toolbarHeight = MediaQuery.of(context).size.height * 0.08;
    double sizedBox;
    double iconSize = MediaQuery.of(context).size.height * 0.023;

    bool isTablet;

    if(Device.get().isTablet) {
      isTablet = true;
      sizedBox = MediaQuery.of(context).size.height * 0.00;
    }
    else {
      isTablet = false;
      sizedBox = MediaQuery.of(context).size.height * 0.047;
    }
    
    try {
      
      return isImagesLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) :
        WillPopScope(
        onWillPop: () async {
          // Return false to prevent going back to the previous page
          return Future.value(false);
        },
        child: isErrorOccurred ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
       Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
          iconTheme: IconThemeData(color: Constants().iconColor),
          toolbarHeight: toolbarHeight,
          
          actions: [
            IconButton(onPressed: (){
              try {
                nextScreen(context, Search(searchName: "",));
              } catch(e) {
                if (this.mounted) {
                  setState(() {
                    isErrorOccurred = true;
                  });
                }
              }
              
            },
            icon: IconButton(
              icon: Icon(Icons.search, color: Constants().iconColor,),
              onPressed: () {
                try {
                  nextScreen(context, Search(searchName: "",));
                } catch(e) {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = true;
                    });
                  }
                }
              },
            ),) 
          ],

          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "LikeApp",
            style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize:  MediaQuery.of(context).size.height * 0.0205
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.grey,
              ),
              const SizedBox(height: 15,),
              Text(userName),
              Text(email),
              ElevatedButton(
              child: Text("LOGOUT"),
              onPressed: () {
                authServie.signOut();
                nextScreen(context, const LoginPage());
              },)
            ],
          ),
        ),

        body: 
        isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
        IndexedStack(
                      index: selectedIndex,
                      children: _widgetOptions,
                    ),
        bottomNavigationBar: isTablet?
          SalomonBottomBar(
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home_outlined, size: iconSize,),
              title: Text("home"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border, size: iconSize,),
              title: Text("likes"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.post_add_outlined, size: iconSize,),
              title: Text("post"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.person_2_outlined, size: iconSize,),
              title: Text("profile"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.amber[800],
            onTap: (index) {
            setState(() {
              if (this.mounted) {
                if (index == 2) {
                  _showPicMenu();
                }
                else if (index == 0) {
                  
                  if (selectedIndex == 0) {
                    homeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 1) {
                  
                  if (selectedIndex == 1) {
                    likeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 3) {
                  
                  if (selectedIndex == 3) {
                    profileScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }
                else {
                  selectedIndex = index;
              }
              }
            });
          },
        ) :
        SalomonBottomBar(
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home_outlined),
              title: Text("home"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text("likes"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.post_add_outlined),
              title: Text("post"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.person_2_outlined),
              title: Text("profile"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.amber[800],
            onTap: (index) {
            setState(() {
              if (this.mounted) {
                if (index == 2) {
                  _showPicMenu();
                }
                else if (index == 0) {
                  
                  if (selectedIndex == 0) {
                    homeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 1) {
                  
                  if (selectedIndex == 1) {
                    likeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 3) {
                  
                  if (selectedIndex == 3) {
                    profileScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }
                else {
                  selectedIndex = index;
              }
              }
            });
          },
        ),
      ));

    } catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );

    }
  }

  double getFileSize(XFile file) {
    return File(file.path).lengthSync() / (1024 * 1024);
  }

  Future getImages() async {
    selectedImages = [];
    try {
        final status = await Permission.photos.request();
        if (status.isGranted) {
          final pickedFile = await picker.pickMultipleMedia(
          imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
          List<XFile> xfilePick = pickedFile;
          setState(
            () {
              if (xfilePick.isNotEmpty) {
                if (xfilePick.length > 8) {
                  final snackBar = SnackBar(
                    content: const Text('Until 8 images can be posted!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  for (var i = 0; i < 8; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: const Text('File size is so large!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                    
                  }
                }
                else {
                  for (var i = 0; i < xfilePick.length; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: const Text('File size is so large!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nothing is selected')));
              }
            },
          );
        } 
        else if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        else {
          var result = await Permission.photos.request().then((value) async {
          if (value.isGranted) {

            final pickedFile = await picker.pickMultipleMedia(
            imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
            List<XFile> xfilePick = pickedFile;

            setState(
              () {
                if (xfilePick.isNotEmpty) {
                  if (xfilePick.length > 8) {
                    final snackBar = SnackBar(
                      content: const Text('Until 8 images can be posted!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    for (var i = 0; i < 8; i++) {
                      if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                        if (getFileSize(xfilePick[i]) > 40) {
                          final snackBar = SnackBar(
                            content: const Text('File size is so large!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          selectedImages.add(File(xfilePick[i].path));
                        }
                      }
                      else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                      
                    }
                  }
                  else {
                    for (var i = 0; i < xfilePick.length; i++) {
                      if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                        if (getFileSize(xfilePick[i]) > 40) {
                          final snackBar = SnackBar(
                            content: const Text('File size is so large!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          selectedImages.add(File(xfilePick[i].path));
                        }
                      }
                      else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nothing is selected')));
                }
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission needed')));
          } 
          });

          
        }

    } catch (e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
          selectedIndex = 0;
        });
      }
      logger.log(Level.error, "Error occurred while picking image\nerror: " + e.toString());
    }
  }

  Future<List<dynamic>> cropImages(List<File> medias) async {
    List<dynamic> files = [];

    for (var media in medias) {
      bool isVideo = HelperFunctions().isVideoFile(media);
      if (!isVideo) {

        bool isHorizontal = await isImageHorizontal(media);
        var croppedFile = await ImageCropper().cropImage(
          sourcePath: media.path,
          aspectRatio: isHorizontal? CropAspectRatio(ratioX: 1200, ratioY: 1200) : CropAspectRatio(ratioX: 900, ratioY: 1200),
          // aspectRatioPresets: [
          //   isHorizontal? CropAspectRatioPreset.original :
          //   CropAspectRatioPreset.ratio16x9
          // ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,),
            IOSUiSettings(
              title: 'Cropper',
              aspectRatioLockEnabled: true, 
              resetAspectRatioEnabled: false,
              aspectRatioPickerButtonHidden: true,
              rotateButtonsHidden: true
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        if (croppedFile != null) {
          files.add(croppedFile);
        }
      }
      else {
        files.add(media);
      }
      
    }

    return files;
  }

  void _showPicMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0)
        )
      ),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_in_picture_alt),
                title: Text('No photo'),
                onTap: () {
                  setState(() {
                    _widgetOptions[2] = Post(images: []);
                    selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text('Select photo'),
                onTap: () async{
                  try {
                    // final status = await Permission.photos.request();
                    // if (status.isGranted) {
                    //   print("granted");
                    // }
                    // else {
                    //   print("denied");
                    //   // openAppSettings();
                    // }
                    await getImages();
                    await cropImages(selectedImages).then((value) {
                      Navigator.pop(context);

                      if (this.mounted) {
                        setState(() {
                          print(value);
                          _widgetOptions[2] = Post(images: value);
                            selectedIndex = 2;
                        });
                      }
                    });
                    
                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isErrorOccurred = true;
                      });
                    }
                    logger.log(Level.error, "Error occurred while picking image\nerror: " + e.toString());
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
            ],
          ),
        );
      }
    );
  }

  Future<bool> isImageHorizontal(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    return image!.width > image.height;
  }

  Future<void> requestGalleryPermission() async {
    var status = await Permission.photos.status;

    if (status.isGranted) {
    } else {
      // Request permission
      if (await Permission.photos.request().isGranted) {
        
      } else {
      }
    }
  }
}