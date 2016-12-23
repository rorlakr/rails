module RailsGuides
  class Markdown
    class Renderer < Redcarpet::Render::HTML
      def initialize(options = {})
        super
      end

      def block_code(code, language)
        <<-HTML
<div class="code_container">
<pre class="brush: #{brush_for(language)}; gutter: false; toolbar: false">
#{ERB::Util.h(code)}
</pre>
</div>
HTML
      end

      def header(text, header_level)
        # Always increase the heading level by 1, so we can use h1, h2 heading in the document
        header_level += 1

        # added by Lucius from RORLAB
        if text =~ /^\[.*\]\s(.*)$/
          convert_header_original(text, header_level)
        else
          %(<h#{header_level}>#{text}</h#{header_level}>)
        end
      end

      def paragraph(text)
        if text =~ /^(TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO)[.:]/
          convert_notes(text)
        elsif text.include?("DO NOT READ THIS FILE ON GITHUB")
        elsif text =~ /^\[<sup>(\d+)\]:<\/sup> (.+)$/
          linkback = %(<a href="#footnote-#{$1}-ref"><sup>#{$1}</sup></a>)
          %(<p class="footnote" id="footnote-#{$1}">#{linkback} #{$2}</p>)
        # added by Lucius from RORLAB
        elsif text =~ /^(.+?)\s*\[{3}(.+?)\]{3}$/
          convert_original(text)
        else
          text = convert_footnotes(text)
          "<p>#{text}</p>"
        end
      end

      private

        # added by Lucius
        def convert_header_original(text, header_level)
          text.gsub(/^\[(.*)\]\s(.*)$/) do
            linkback = %(<a href="#" class="original-link" onclick="$(this).parent().prev().toggle();return false;">{원문</a><a href="#" class="original-link">·</a><a href='#' class="original-link" onclick="$('.original-text, .original-text-h').toggle();return false;">전체}</a>)
            %(<h#{header_level}>#{$2}<span class="original-text-h">(#{$1})</span> <sup>#{linkback}</sup></h#{header_level}>)
          end
        end

        # added by Lucius
        def convert_original(text)
          text = text.gsub(/\n/, " ")
          text.gsub(/^(.+?)\s*\[{3}(.+?)\]{3}$/) do
            linkback = %(<a href="#" class="original-link" onclick="$(this).parent().parent().next().toggle();return false;">{원문</a><a href="#" class="original-link">·</a><a href='#' class="original-link" onclick="$('.original-text').toggle();return false;">전체}</a>)
            %(<p>#{$1} <sup>#{linkback}</sup></p><p class="original-text">#{$2}</p>)
          end
        end

        def convert_footnotes(text)
          text.gsub(/\[<sup>(\d+)\]<\/sup>/i) do
            %(<sup class="footnote" id="footnote-#{$1}-ref">) +
              %(<a href="#footnote-#{$1}">#{$1}</a></sup>)
          end
        end

        def brush_for(code_type)
          case code_type
          when "ruby", "sql", "plain"
            code_type
          when "erb", "html+erb"
            "ruby; html-script: true"
          when "html"
            "xml" # HTML is understood, but there are .xml rules in the CSS
          else
            "plain"
          end
        end

        def convert_notes(body)
          # The following regexp detects special labels followed by a
          # paragraph, perhaps at the end of the document.
          #
          # It is important that we do not eat more than one newline
          # because formatting may be wrong otherwise. For example,
          # if a bulleted list follows the first item is not rendered
          # as a list item, but as a paragraph starting with a plain
          # asterisk.
          body.gsub(/^(TIP|IMPORTANT|CAUTION|WARNING|NOTE|INFO|TODO)[.:](.*?)(\n(?=\n)|\Z)/m) do
            css_class = \
              case $1
              when "CAUTION", "IMPORTANT"
                "warning"
              when "TIP"
                "info"
              else
                $1.downcase
              end
            # added by Lucius
            original_text = $2
            if original_text =~ /\n*(.+?)\s*\[{3}(.+?)\]{3}\s*/
              original_text = convert_original(original_text)
            else
              original_text = "<p>#{original_text}</p>"
            end
            %(<div class="#{css_class}">#{original_text}</div>)
          end
        end
    end
  end
end
