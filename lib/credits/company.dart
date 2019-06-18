class Company{
  final String name;
  final String website_url;
  final String description;
  final String logo_url;


  Company(this.name, this.website_url, this.description, this.logo_url);

  static List<Company> getPredefinedCompanies(){
    return [
      Company("IFCA CSIC - UC", "http://193.146.75.169:8000/", "DEEP API",
          "http://conference4me.psnc.pl/wordpress-static/lifewatch/ifca.png"),
      Company("PSNC", "http://www.man.poznan.pl/online/en/", "Mobile apps development",
          "http://conference4me.psnc.pl/wordpress-static/lifewatch/psnc.png"),
      Company("DEEP DataCloud", "https://deep-hybrid-datacloud.eu/", "Project H2020",
          "http://conference4me.psnc.pl/wordpress-static/lifewatch/logo-deep-r.png")
    ];
  }
}