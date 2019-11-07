const double kCollapseOffset = 50;
const double kExpandedHeight = 120;
const double kBottomTabBarAppearanceOffset = 80;

enum Flavour { Development, Staging, Production }

class Config {
  static Flavour appFlavour = Flavour.Development;
  static int pageSize = 100;

  static String get baseUrl {
    switch (appFlavour) {
      case Flavour.Production:
        return "https://api.yodelit.co";
      case Flavour.Staging:
        return "https://staging.yodelit.co";
      default:
        return "https://develop.yodelit.co";
    }
  }

  static String inviteUrseUrl = "$baseUrl/Company/User/Invite";

  static String get raygunApiKey {
    switch (appFlavour) {
      case Flavour.Production:
        return "zQiRmYuo5cZHE8alDtLgoA";
      case Flavour.Staging:
        return "rQnxyaa9yM7bm1LZ6AE2A";
      default:
        return "rQnxyaa9yM7bm1LZ6AE2A";
    }
  }

  static String get apiKey {
    switch (appFlavour) {
      case Flavour.Production:
        return "ac7c456d-a270-4077-b9a3-76d361458761";
      case Flavour.Staging:
        return "e5bdafb0-58e2-469d-a5b9-3808fff7d36b";
      default:
        return "e5bdafb0-58e2-469d-a5b9-3808fff7d36b";
    }
  }
}
