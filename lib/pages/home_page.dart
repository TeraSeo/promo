import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/pages/pageInPage/home.dart';
import 'package:like_app/pages/pageInPage/likes.dart';
import 'package:like_app/pages/pageInPage/postPage/post.dart';
import 'package:like_app/pages/pageInPage/profilePage/profilePage.dart';
import 'package:like_app/pages/pageInPage/search.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomePage extends StatefulWidget {

  final int pageIndex;

  const HomePage({super.key, required this.pageIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  AuthServie authServie = AuthServie();
  final picker = ImagePicker();
  Logging logger = Logging();
  HelperFunctions helperFunctions = HelperFunctions();

  String userName = "";
  String email = "";

  bool isErrorOccurred = false;
  bool isAudioSessionLoading = true;

  bool isImagesLoading = false;

  List<File> selectedImages = [];

  int selectedIndex = 0;

  @override
  void initState() {

    super.initState();

    selectedIndex = widget.pageIndex;

    if (this.mounted) {
      setState(() {
          _widgetOptions[0] =  Home(scrollController: homeScrollController);
          _widgetOptions[1] =  LikesRanking(scrollController: likeScrollController);
          _widgetOptions[3] = ProfilePage(scrollController: profileScrollController);
      });
    }

    gettingUserData();

  }

  gettingUserData() async {

    try {
      await helperFunctions.getUserEmailFromSF().then((value) => {
        setState(() {
          email = value!;
        })
      });

      await helperFunctions.getUserNameFromSF().then((value) => {
        setState(() {
          userName = value!;
        })
      });

    } catch(e) {
      if (this.mounted) {setState(() {
        isErrorOccurred = true;
      });}
      logger.message_warning("error occurred while getting user data\nerror: " + e.toString());
    }
  }

  // listenMsgToken(String uId) {
  //   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  //     DatabaseService userService = DatabaseService.instance;
  //     userService.updateMessagingToken(newToken, uId);
  //   });
  // }

  final PageController _pageController = PageController();
  final ScrollController homeScrollController = ScrollController();
  final ScrollController profileScrollController = ScrollController();
  final ScrollController likeScrollController = ScrollController();

  final _widgetOptions = <Widget>[
    Home(scrollController: ScrollController()),
    LikesRanking(scrollController: ScrollController()),
    Post(images: []),
    ProfilePage(scrollController: ScrollController())
  ];

  @override
  void dispose() {
    if (this.mounted) {
      _pageController.dispose();
      homeScrollController.dispose();
      profileScrollController.dispose();
      likeScrollController.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {

    double toolbarHeight = MediaQuery.of(context).size.height * 0.08;
    double iconSize = MediaQuery.of(context).size.height * 0.023;

    bool isTablet;

    if(Device.get().isTablet) {
      isTablet = true;
    }
    else {
      isTablet = false;
    }
    
    try {
      return AbsorbPointer(
      absorbing: isImagesLoading,
      child:
        WillPopScope(
        onWillPop: () async => false,
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
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
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
            "Promo",
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
                helperFunctions.saveVerifiedSF(false);
                nextScreen(context, const LoginPage());
              },)
            ],
          ),
        ),
        body: 
        isErrorOccurred? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
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
                    try {
                      homeScrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } catch(e) {
                    }
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
      )));
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
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
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
        if (await Permission.photos.request().isGranted) {
          final pickedFile = await picker.pickMultiImage(
          imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
          List<XFile> xfilePick = pickedFile;
          setState(
            () {
              if (xfilePick.isNotEmpty) {
                if (xfilePick.length > 8) {
                  for (var i = 0; i < 8; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
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
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
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
                  SnackBar(content: Text(AppLocalizations.of(context)!.nothingSelected)));
              }
            },
          );
        } 
        else if (await Permission.storage.request().isGranted) {
          final pickedFile = await picker.pickMultiImage(
          imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
          List<XFile> xfilePick = pickedFile;
          setState(
            () {
              if (xfilePick.isNotEmpty) {
                if (xfilePick.length > 8) {
                  for (var i = 0; i < 8; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
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
                          content: Text(AppLocalizations.of(context)!.fileSizeLarge),
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
                  SnackBar(content: Text(AppLocalizations.of(context)!.nothingSelected)));
              }
            },
          );
        }
        else {
          openAppSettings();
        }
    } catch (e) {
      if (this.mounted) {
        setState(() {
          isImagesLoading = false;
          isErrorOccurred = true;
          selectedIndex = 0;
        });
      }
      logger.message_warning("Error occurred while picking image\nerror: " + e.toString());
    }
  }

  Future<List<dynamic>> cropImages(List<File> medias) async {
    try {
      List<dynamic> files = [];

      for (var media in medias) {
        bool isVideo = HelperFunctions().isVideoFile(media);
        if (!isVideo) {
          bool isHorizontal = await isImageHorizontal(media);
          var croppedFile = await ImageCropper().cropImage(
            sourcePath: media.path,
            uiSettings: [
              AndroidUiSettings(
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,),
              IOSUiSettings(
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

    } catch(e) {

      setState(() {
        if (this.mounted) {
          isImagesLoading = false;
        }
      });

      return [];

    }
    
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
                title: Text(AppLocalizations.of(context)!.noPhoto),
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
                title: Text(AppLocalizations.of(context)!.selectPhoto),
                onTap: () async{
                  try {
                    setState(() {
                      if (this.mounted) {
                        isImagesLoading = true;
                      }
                    });
                    await getImages();
                    setState(() {
                      if (this.mounted) {
                        isImagesLoading = false;
                      }
                    });
                    await cropImages(selectedImages).then((value) {

                      if (this.mounted) {
                        setState(() {
                          _widgetOptions[2] = Post(images: value);
                          selectedIndex = 2;
                        });
                      }
                    });
                    
                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isImagesLoading = false;
                        isErrorOccurred = true;
                      });
                    }
                    logger.message_warning("Error occurred while picking image\nerror: " + e.toString());
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

}