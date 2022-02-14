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



class AllCategory extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
          children: [
            Expanded(
                flex: 1,
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
                    ))),
            Expanded(
              flex: 3,
              child:
              catList.length>0?
              Column(

                children: [
                  Selector<CategoryProvider, int>(
                    builder: (context, data, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(catList[data].name!+" "),
                                Expanded(
                                    child: Divider(
                                      thickness: 2,
                                    ))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                getTranslated(context, 'All')! +
                                    " " +
                                    catList[data].name! +
                                    " ",
                                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.fontColor,
                              ),
                            ))
                          ],
                        ),
                      );
                    },
                    selector: (_, cat) => cat.curCat,
                  ),
                  Expanded(
                      child: Selector<CategoryProvider, List<Product>>(
                        builder: (context, data, child) {


                          return data.length > 0
                              ? GridView.count(
                              padding: EdgeInsets.symmetric(horizontal: 20),
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

  Widget catItem(int index, BuildContext context1) {


    return Selector<CategoryProvider, int>(
      builder: (context, data, child) {
        if (index == 0 && (popularList.length > 0)) {
          return GestureDetector(
            child: Container(
              height: 100,
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
                    padding: const EdgeInsets.all(8.0),
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
            },
          );
        } else {

          return GestureDetector(
            child: Container(
              height: 100,
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
                      padding: const EdgeInsets.all(8.0),
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

                context1
                    .read<CategoryProvider>()
                    .setSubList(catList[index].subList);
              }
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


