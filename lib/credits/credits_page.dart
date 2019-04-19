import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/credits/company.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';

class CreditsPage extends StatelessWidget {

  CreditsPage();

  @override
  Widget build(BuildContext context) {

    final companies = Company.getPredefinedCompanies();

    return Column(
      children: <Widget>[
        AppBar(
          backgroundColor: AppColors.primary_color,
          title: Text(AppStrings.app_label),
        ),
        Container(
          child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              //itemCount: companies.length,
            children: buildListElements(companies)
          )
        )
      ],
    );
  }

  List<Widget> buildListElements(List<Company> companies){
    return List<Container>.generate(companies.length,
            (int index){
          return Container(
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  FadeInImage(
                      //width: double.infinity,
                      placeholder: MemoryImage(kTransparentImage),//AssetImage("assets/images/plant.png"),
                      image: NetworkImage(companies[index].logo_url)//FileImage(File(companies[index].logo_url))
                  ),

                    //alignment: Alignment.bottomCenter,
                     Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        companies[index].description,
                        style: TextStyle(
                            color: Colors.grey
                        ),
                      ),
                    ),

                ],
              ),
            ),
          );
        }
    );
  }
}