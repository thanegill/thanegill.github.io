{ buildPythonPackage
, fetchFromGitHub
, poetry-core
, pelican
}:

buildPythonPackage rec {
  pname = "pelican-jinja2content";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pelican-plugins";
    repo = "jinja2content";
    rev = version;
    sha256 = "1wvibz5w61x0q02p0j86p446n3gxwivl55ajzs60fqym930ybpak";
  };

  build-system = [ poetry-core ];

  dependencies = [ pelican ];
}
