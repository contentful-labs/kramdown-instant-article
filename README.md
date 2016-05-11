# Kramdown Facebook Instant Article Converter

Custom converter for [Kramdown][1] to create markup optimized for Facebook's Instant Articles.

## What's different about it?

The following things are handled differently compared to Kramdown's HTML converter. Not that some of these changes are
relatively specific to [Contentful's blog][2]

## How do I use it?

On our Middleman based blog we use it with a small helper function.

``` ruby
require 'kramdown'

module FbiaHelper
  def render_fbia_markdown(text)
    html = Kramdown::Document.new(text.to_s, {:auto_ids => false, :html_to_native => true, :base_url => base_url}).to_fbia

    return html
  end
end
```

Examples on how the layouts invoking the function look like can be found in the [example_layouts][3] directory.

## License

Copyright (c) 2016 Contentful GmbH. Code released under the MIT license. See [LICENSE][4] for further details.

## Disclaimer

This is a project created for demo purposes and not officially supported. Report problems via the issues page but please
don't expect a prompt response.

 [1]: http://kramdown.gettalong.org
 [2]: https://www.contentful.com/blog/
 [3]: example_layouts
 [4]: LICENSE
