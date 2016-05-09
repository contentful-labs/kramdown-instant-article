require 'kramdown/parser'
require 'kramdown/converter'
require 'kramdown/utils'

module Kramdown

  module Converter
    class Fbia < Html

      def initialize(root, options)
        super
        @base_url = @options[:base_url]
      end

      def convert_root(el, indent)
        children = el.children
        children.delete_if {|x| x.type == :blank}

        children.size.times do |index|
            if children[index].attr["class"] == "img-caption"
              children[index - 1].options["img-caption"] = inner(children[index], 0)
            end
        end

        children.delete_if {|elem| elem.attr["class"] == "img-caption"}

        el.children = children

        super
      end

      def convert_p(el, indent)
        if el.options[:transparent]
          inner(el, indent)
        else
          content = inner(el, indent)
          isImg = content.start_with?("<img")
          if isImg && el.options.key?("img-caption")
            content = "#{content}<figcaption>#{el.options['img-caption']}</figcaption>"
          end
          format_as_block_html(isImg ? "figure" : el.type, el.attr, content, indent)
        end
      end

      def convert_header(el, indent)
        attr = el.attr.dup
        if @options[:auto_ids] && !attr['id']
          attr['id'] = generate_id(el.options[:raw_text])
        end
        @toc << [el.options[:level], attr['id'], el.children] if attr['id'] && in_toc?(el)
        level = output_header_level(el.options[:level])
        level = 2 if level > 2

        format_as_block_html("h#{level}", attr, inner(el, indent), indent)
      end

      def convert_a(el, indent)
        res = inner(el, indent)
        attr = el.attr.dup
        if attr['href'].start_with?('mailto:')
          mail_addr = attr['href'][7..-1]
          attr['href'] = obfuscate('mailto') << ":" << obfuscate(mail_addr)
          res = obfuscate(res) if res == mail_addr
        elsif attr['href'].start_with?('//')
          attr['href'] = 'https:' + attr['href']
        elsif attr['href'].start_with?('/')
          attr['href'] = @base_url + attr['href']
        end

        if attr['href'].start_with?('#')
          return res
        else
          format_as_span_html(el.type, attr, res)
        end
      end

      def convert_img(el, indent)
        attr = el.attr.dup
        attr['src'] = "https:#{attr['src']}" if attr['src'].start_with?('//')

        "<img#{html_attributes(attr)} />"
      end

      # Format the given element as block HTML.
      def format_as_block_html(name, attr, body, indent)
        attr = attr.dup
        attr.delete("class")
        "#{' '*indent}<#{name}#{html_attributes(attr)}>#{body}</#{name}>\n"
      end

      # Format the given element as block HTML with a newline after the start tag and indentation
      # before the end tag.
      def format_as_indented_block_html(name, attr, body, indent)
        attr.delete("class")
        "#{' '*indent}<#{name}#{html_attributes(attr)}>\n#{body}#{' '*indent}</#{name}>\n"
      end

      def convert_codespan(el, indent)
        format_as_span_html('em', el.attr, el.value)
      end

      def convert_html_element(el, indent)
        result = super
        result.gsub('src="//', 'src="https://')
      end

    end
  end

end
