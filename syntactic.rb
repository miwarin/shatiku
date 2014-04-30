# coding: utf-8

# Yahoo デベロッパーネットワーク の 日本語係り受け解析API を使う
# http://developer.yahoo.co.jp/webapi/jlp/da/v1/parse.html

require 'uri'
require 'open-uri'
require 'rexml/document'
require 'pp'

module NLP
  module Syntactic

    SENTENCE_LENGTH_MAX = 300

    def parse(xml)
      syntactic ||= []
      
      doc = REXML::Document.new(xml)
      doc.elements.each('ResultSet/Result/ChunkList/Chunk') do |chunk|
        chunks = ""
        chunk.elements.each('MorphemList') do |ml|
          ml.elements.each("Morphem/Surface") do |mo|
            chunks << mo.text
          end
        end
        syntactic << chunks
      end
      
      return syntactic
    end

    def build_sweep(text)
      text.gsub!("\n", "")
      text.rstrip!
      text.lstrip!
      text.gsub!(/\A +/, "")
      text.gsub!(/ /, "")
      text.chomp!
      text.gsub!(/[\r\n]/, "")
      return text
    end

    def build_sentence(text)

      text = build_sweep(text)

      request_sentence ||= []
      
      if text.length < SENTENCE_LENGTH_MAX
        request_sentence << text
      else
        lump = ""
        text.split(/。/).each {|sentence|
          s = sentence + "。"
          if (lump + s).length < SENTENCE_LENGTH_MAX
            lump << s
          else
            request_sentence << lump
            lump = ""
            lump << s
          end
        }
      end
      
      return request_sentence
    end    

    # 文章が長いのは無視
    def _analysis(text)
      apiuri = "http://jlp.yahooapis.jp/DAService/V1/parse"
      appid = "?appid=" + "dj0zaiZpPXhmVjJsWnBXRlZpViZkPVlXazlUVU5IZFhWdE5EUW1jR285TUEtLSZzPWNvbnN1bWVyc2VjcmV0Jng9MmI-"
      sentence = "&sentence=" + URI.encode(text)
      request_uri = apiuri + appid + sentence

      syntactics = ""

      begin
        response = open(request_uri).read()
        syntactics = parse(response)
      rescue => e
      end
      return syntactics
    end


    def analysis(text)
      syntactics ||= []
      sentences = build_sentence(text)
      sentences.each {|s|
        syntactics << _analysis(s)
      }

      return syntactics
    end

  end
end
