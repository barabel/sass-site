require "rubygems"

require "rack/conditional"
require "rack/rewrite"
require "rack/ssl"
require "rack/contrib/not_found"
require "rack/contrib/try_static"

# Make sure we don't force SSL on domains that don't have SSL certificates.
use Rack::Conditional, proc {|env| env["SERVER_NAME"] == "sass-lang.com"}, Rack::SSL

use Rack::Rewrite do
  r301 %r{/docs/yardoc/(.*)}, '/documentation/$1'
  r301 '/tutorial.html', '/guide'
  r301 '/download.html', '/install'
  r301 '/try', 'http://sassmeister.com'
  r301 '/try.html', 'http://sassmeister.com'
  r301 '/about', '/'
  r301 '/about.html', '/'

  r301 '/documentation/file.SASS_REFERENCE.html', '/documentation'
  r301 '/documentation/file.SASS_CHANGELOG.html', 'https://github.com/sass/dart-sass/blob/master/CHANGELOG.md'
  r301 '/documentation/file.INDENTED_SYNTAX.html', '/documentation/syntax'
  r301 '/documentation/file.SCSS_FOR_SASS_USERS.html', '/documentation/syntax'
  r301 '/documentation/Sass/Script/Functions.html', '/documentation/modules'
  r301 '/documentation/Sass/Script/Functions', '/documentation/modules'
  r301 %r{/documentation/(Sass.*)}, 'http://www.rubydoc.info/gems/sass/$1'
  r301 '/documentation/functions/css', '/documentation/at-rules/function#plain-css-functions'
  r301 %r{/documentation/functions(.*)}, '/documentation/modules$1'

  r301 %r{/(.+)/$}, '/$1'
  r301 %r{/(.+)/index\.html$}, '/$1'

  # We used to redirect Logdown URLs to the sass.logdown.com, but now we
  # redirect them to the local site's corresponding blog URLs.
  r301 %r{/blog/posts/\d+-(.*)}, '/blog/$1'

  # Some blog posts didn't have slugs in Logdown.
  r301 %r{/blog/posts/560719}, '/blog/dropping-support-for-old-ruby-versions'
  r301 %r{/blog/posts/1305238}, '/blog/dart-sass-is-on-chocolatey'
  r301 %r{/blog/posts/1404451}, '/blog/sass-and-browser-compatibility'
  r301 %r{/blog/posts/1909151}, '/blog/dart-sass-is-in-beta'
  r301 %r{/blog/posts/7081811}, '/blog/ruby-sass-is-deprecated'

  # Provide short links for breaking changes so that they can be tersely
  # referenced from warning and errors.
  r301 %r{/d/(.*)}, '/documentation/breaking-changes/$1'
end

use Rack::Deflater

use Rack::TryStatic,
    urls: ["/"], root: 'build', index: 'index.html',
    try: ['.html', '/index.html']

run Rack::NotFound.new("build/404.html")
