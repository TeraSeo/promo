import 'package:flutter/material.dart';
import 'package:like_app/ads/BannerAdPage.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widget/searchName.dart';
import 'package:like_app/widget/searchTag.dart';
import 'package:like_app/widget/searchUser.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Search extends StatefulWidget {

  final String searchName;

  const Search({super.key, required this.searchName});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  TextEditingController? searchController;
  HelperFunctions helperFunctions = HelperFunctions();

  String? uId = "";

  bool isUIdLoading = true;

  bool isErrorOccurred = false;

  int _currentIndex = 0;

  Logging logger = Logging();

  @override
  void initState() {
    try {
      searchController = new TextEditingController(text: widget.searchName);
      _tabController = TabController(
        length: 3,
        vsync: this, 
      );
      getUId();

      _tabController.addListener(() {
        if (this.mounted) {
          setState(() {
            _currentIndex = _tabController.index;
          });
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController!.dispose();
    _tabController.dispose();
  }

  void getUId() async{
    try {
      await helperFunctions.getUserUIdFromSF().then((value) => {
        uId = value,
        if (this.mounted) {
          setState(() {
            isUIdLoading = false;
          })
        }
      });
    } catch(e) {
      if (this.mounted) {
        setState(() {
          isErrorOccurred = true;
        });
      }
      logger.message_warning("Error occurred while getting uId\nerror: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    final _tabContent = <Widget>[
        searchController!.text == "" ? 
              Container() : 
              SearchName(searchedName: searchController!.text, uId: uId!),
        searchController!.text == "" ? 
              Container() :
              SearchUser(searchedName: searchController!.text, uId: uId!),
        searchController!.text == "" ? 
              Container() :
              SearchTag(searchedName: searchController!.text, uId: uId!)
      ];

    try {

      return isErrorOccurred ? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isUIdLoading = true;
                    }
                  );
                }
                Future.delayed(Duration.zero,() async {
                  getUId();
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) : isUIdLoading ? 
      Center(
        child: CircularProgressIndicator(),
      )
      : 
      Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Constants().iconColor),
          toolbarHeight: MediaQuery.of(context).size.height * 0.15,
          backgroundColor: Theme.of(context).primaryColor,
          title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: searchController,
              decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 87, 84, 84),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none
                ),
                hintText: AppLocalizations.of(context)!.search,
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.white
              ),
              onFieldSubmitted: (String _) {
                if (this.mounted) {
                  if (_ != "") {
                    setState(() {
                      nextScreenReplace(context, Search(searchName: _));
                    });
                  }
                }
              },
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.06),
              child: Column(
                children: [
              BannerAdPage(),
                  TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.post),
                  Tab(text: AppLocalizations.of(context)!.acc),
                  Tab(text: AppLocalizations.of(context)!.tag)
                ],
              ),
                ],
              )
            )
          ),
        body:
          IndexedStack(
            index: _currentIndex,
            children: _tabContent,
          )
      );

    } catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                if (this.mounted) {
                  setState(() {
                      isErrorOccurred = false;
                      isUIdLoading = true;
                    }
                  );
                }
                Future.delayed(Duration.zero,() async {
                  getUId();
                });
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text(AppLocalizations.of(context)!.loadFailed, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );
    }
    
  }
}