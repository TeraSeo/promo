import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/helper/logger.dart';
import 'package:like_app/pages/pageInPage/search.dart';
import 'package:like_app/widget/searchName.dart';
import 'package:like_app/widget/searchTag.dart';
import 'package:like_app/widget/searchUser.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SearchByTag extends StatefulWidget {

  final String searchText;

  const SearchByTag({super.key, required this.searchText});

  @override
  State<SearchByTag> createState() => _SearchByTagState();
}

class _SearchByTagState extends State<SearchByTag> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  String? uId = "";

  bool isUIdLoading = true;

  int _currentIndex = 2;

  bool isErrorOccurred = false;
  Logging logger = Logging();

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 2,
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

    super.initState();
  }

  void getUId() async{
    try {
      await HelperFunctions.getUserUIdFromSF().then((value) => {
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
    }
    
  }

  @override
  Widget build(BuildContext context) {

    final TextEditingController searchController = new TextEditingController(text: widget.searchText);

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
      ) : isUIdLoading? 
      Center(
        child: CircularProgressIndicator(),
      )
      : 
      Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.07,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: MediaQuery.of(context).size.width * 0.06,),
            onPressed: () => Navigator.of(context).pop()
          ),
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
            bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.post),
                  Tab(text: AppLocalizations.of(context)!.acc),
                  Tab(text: AppLocalizations.of(context)!.tag)
                ]
              )
          ),
        body:
        IndexedStack(
          index: _currentIndex,
          children: _tabContent,
        ),
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