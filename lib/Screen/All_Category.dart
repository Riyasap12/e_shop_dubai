import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Provider/CategoryProvider.dart';
import 'package:eshop/Screen/SubCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'ProductList.dart';



class AllCategory extends StatefulWidget {
  @override
  State<AllCategory> createState() => _AllCategoryState();
}

class _AllCategoryState extends State<AllCategory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    print("press1");
    _scaffoldKey.currentState?.openDrawer();
    print("press");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: drawer(context),
        body: Row(crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              flex: 3,
              child:
              catList.length>0?
              Column(

                children: [
                  Selector<CategoryProvider, int>(
                    builder: (context, data, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8,right: 8,left: 8),
                            child: Row(
                              children: [

                                Expanded(
                                    child: Divider(
                                      thickness: 2,
                                    )),
                                Text(catList[data].name!+" "),
                              ],
                            ),
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(//height: 35,
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.only(right: 12,top: 8,bottom: 8,left: 4),
                                  decoration: BoxDecoration(color: colors.primary_app,borderRadius: BorderRadius.only(topRight: Radius.circular(24),bottomRight: Radius.circular(24))),
                                  child: Column(
                                    children: [
                                      IconButton(padding: EdgeInsets.zero,constraints: BoxConstraints(maxHeight: 25),onPressed:()=> _openDrawer(), icon: Icon(Icons.menu,color: Colors.white,)),
                                    Text("Menu",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12,color: Colors.white),)
                                    ],
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8),
                                child: Text(
                                  getTranslated(context, 'All')! +
                                      " " +
                                      catList[data].name! +
                                      " ",
                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor,
                                ),
                              )),
                            ],
                          )
                        ],
                      );
                    },
                    selector: (_, cat) => cat.curCat,
                  ),
                  Expanded(
                      child: Selector<CategoryProvider, List<Product>>(
                        builder: (context, data, child) {


                          return data.length > 0
                              ? GridView.count(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              childAspectRatio: .6,
                              children: List.generate(
                                data.length,
                                    (index) {
                                  return subCatItem(data, index, context);
                                },
                              ))
                              : Center(child: Text(getTranslated(context, 'noItem')!));
                        },
                        selector: (_, categoryProvider) => categoryProvider.subList,
                      )),
                ],
              ):Container(),
            ),
          ],
        ));
  }

  Widget drawer(context){
    return Container(
      width: 100,
      child: Drawer(elevation: 0,
        child: Container(
            color: Theme.of(context).colorScheme.gray,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding: EdgeInsetsDirectional.only(top: 10.0),
              itemCount: catList.length,
              itemBuilder: (context, index) {
                return catItem(index, context);
              },
            )
        ),
      ),
    );
  }

  Widget catItem(int index, BuildContext context1) {


    return Selector<CategoryProvider, int>(
      builder: (context, data, child) {
        if (index == 0 && (popularList.length > 0)) {
          return GestureDetector(
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index ? Theme.of(context).colorScheme.white : Colors.transparent,
                  border: data == index
                      ? Border(
                    left: BorderSide(width: 5.0, color: colors.primary),
                  )
                      : null
                // borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: SvgPicture.asset(data == index
                            ? imagePath + "popular_sel.svg"
                            : imagePath + "popular.svg")),
                  ),
                  Text(
                    catList[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color:
                        data == index ? colors.primary : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              context1.read<CategoryProvider>().setSubList(popularList);
              Navigator.pop(context);
            },
          );
        } else {

          return GestureDetector(
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index ? Theme.of(context).colorScheme.white : Colors.transparent,
                  border: data == index
                      ? Border(
                    left: BorderSide(width: 5.0, color: colors.primary),
                  )
                      : null
                // borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInImage(
                            image: NetworkImage(catList[index].image!),
                            fadeInDuration: Duration(milliseconds: 150),
                            fit: BoxFit.fill,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(50),
                            placeholder: placeHolder(50),
                          )),
                    ),
                  ),
                  Text(
                    catList[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme
                        .of(context1)
                        .textTheme
                        .caption!
                        .copyWith(
                        color:
                        data == index ? colors.primary : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              print("tap1");
              context1.read<CategoryProvider>().setCurSelected(index);
              if (catList[index].subList == null ||
                  catList[index].subList!.length == 0) {
                context1.read<CategoryProvider>().setSubList([]);
                Navigator.push(
                    context1,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductList(
                            name: catList[index].name,
                            id: catList[index].id,
                            tag: false,
                            fromSeller: false,
                          ),
                    ));
              } else {
                print("tap3");
                context1
                    .read<CategoryProvider>()
                    .setSubList(catList[index].subList);
              }
              Navigator.pop(context);
            },
          );
        }
      },
      selector: (_, cat) => cat.curCat,
    );
  }

  subCatItem(List<Product> subList, int index, BuildContext context) {

    return GestureDetector(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FadeInImage(
                  image: NetworkImage(subList[index].image!),
                  fadeInDuration: Duration(milliseconds: 150),
                  fit: BoxFit.fill,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      erroWidget(50),
                  placeholder: placeHolder(50),
                )),
          ),
          Text(
            subList[index].name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {

        if (context.read<CategoryProvider>().curCat == 0 &&
            popularList.length > 0) {
          if (popularList[index].subList == null ||
              popularList[index].subList!.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: popularList[index].name,
                    id: popularList[index].id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    subList: popularList[index].subList,
                    title: popularList[index].name ?? "",
                  ),
                ));
          }
        } else if (subList[index].subList == null ||
            subList[index].subList!.length == 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: subList[index].name,
                  id: subList[index].id,
                  tag: false,
                  fromSeller: false,
                ),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubCategory(
                  subList: subList[index].subList,
                  title: subList[index].name ?? "",
                ),
              ));
        }
      },
    );
  }
}


