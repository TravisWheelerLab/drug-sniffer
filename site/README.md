# Drug Sniffer Website

To update the site, take a look at the files in `source`, they are in .rst
format, see
<https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html> for
an introduction to this format.

You'll need [Pipenv](https://pipenv.pypa.io/en/latest/), which can be easily
installed in most environments. Once that is installed, from the `site/`
directory, run `pipenv install --dev`. This will allow you to build the site
content. You only have to do this once.

Once you've made your changes to the site content, run `pipenv run ./build.sh`,
which will build the documentation and also move it to the correct location in
the repo. Then, you can commit all changes and push (or submit a pull request).
