import 'package:flutter/material.dart';
import 'package:deep_app/utils/constants.dart';
import 'package:deep_app/credits/company.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {

  CreditsPage();

  @override
  Widget build(BuildContext context) {

    final companies = Company.getPredefinedCompanies();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary_color,
        title: Text(AppStrings.app_label),
      ),
      body: Container(
          child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: buildListElements(companies)
          )
      )
    );
  }

  List<Widget> buildListElements(List<Company> companies){
    return List<Container>.generate(companies.length,
            (int index){
          return Container(
            padding: EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () {_launchURL(companies[index].website_url);},
              child: Column(
                children: <Widget>[
                  FadeInImage(
                      height: 150.0,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(companies[index].logo_url)
                  ),
                  Container(
                      width: double.infinity,
                      alignment: Alignment.center,
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

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      final msg = AppStrings.launch_exception;
      throw "$msg $url";
    }
  }

}