# coding: utf-8

#
# ナイーブベイズを用いたテキスト分類 - 人工知能に関する断創録
# http://aidiary.hatenablog.com/entry/20100613/1276389337
#


def maxint()
  return 2 ** ((1.size) * 8 -1 ) -1
end

def sum(data)
  return data.inject(0) {|s, i| s + i}
end

include Math
require 'pp'
require 'json'
require 'yaml'

module NLP

  # Multinomial Naive Bayes
  class NaiveBayes


    def initialize()
      # カテゴリの集合
      @categories = []

      # ボキャブラリの集合
      @vocabularies = []
      
      # wordcount[cat][word] カテゴリでの単語の出現回数
      @wordcount = {}

      # catcount[cat] カテゴリの出現回数
      @catcount = {}
      
      # denominator[cat] P(word|cat)の分母の値
      @denominator = {}
    end
    
    # ナイーブベイズ分類器の訓練
    def train(data)
      data.each {|d|
        cat = d[0]
        @categories << cat
      }
      
      @categories.each {|cat|
        @wordcount[cat] ||= {}
        @wordcount[cat].default = 0
        @catcount[cat] ||= 0
#        @catcount[cat] = 0
      }
      
      # 文書集合からカテゴリと単語をカウント
      data.each {|d|
        cat, doc = d[0], d[1, d.length-1]

        @catcount[cat] += 1
        doc.each {|word|
          @vocabularies << word
          @wordcount[cat][word] += 1
        }
      }
      
      @vocabularies.uniq!
      
      # 単語の条件付き確率の分母の値をあらかじめ一括計算しておく（高速化のため）
      @categories.each {|cat|
        s = sum(@wordcount[cat].values)
        @denominator[cat] =  s + @vocabularies.length
      }

    end
    
    
    # 事後確率の対数 log(P(cat|doc)) がもっとも大きなカテゴリを返す
    def classify(doc)
      best = nil
      max = -maxint()
      @catcount.each_key {|cat|
        _p = score(doc, cat)
        if _p > max
          max = _p
          best = cat
        end
      }
      
      return best
    end
    
    # 単語の条件付き確率 P(word|cat) を求める
    def wordProb(word, cat)
      return (@wordcount[cat][word] + 1).to_f / (@denominator[cat]).to_f
    end
    
    # 文書が与えられたときのカテゴリの事後確率の対数 log(P(cat|doc)) を求める
    def score(doc, cat)
      # 総文書数
      total = sum(@catcount.values)
      
      # log P(cat)
      sc = Math.log((@catcount[cat]) / total.to_f)
      doc.each {|word|
        # log P(word|cat
        sc += Math.log(wordProb(word, cat))
      }
      return sc
    end
    
    def dump
      pp @catcount
      pp @denominator
      pp @wordcount
    end
    
    # 総文書数
#    def to_s()
#      total = sum(@catcount.values) 
#      return "documents: #{total}, vocabularies: #{@vocabularies.length}, categories: #{@categories.length}"
#    end

  end


end # end of module


if __FILE__ == $0

  # Introduction to Information Retrieval 13.2の例題
  data = [
    ["yes", "Chinese", "Beijing", "Chinese"],
    ["yes", "Chinese", "Chinese", "Shanghai"],
    ["yes", "Chinese", "Macao"],
    ["no", "Tokyo", "Japan", "Chinese"]
  ]
  
  # ナイーブベイズ分類器を訓練
  nb = NLP::NaiveBayes.new
  nb.train(data)

  puts "P(Chinese|yes) = #{nb.wordProb('Chinese', 'yes')}"
  puts "P(Tokyo|yes) = #{nb.wordProb('Tokyo', 'yes')}"
  puts "P(Japan|yes) = #{nb.wordProb('Japan', 'yes')}"
  puts "P(Chinese|no) = #{nb.wordProb('Chinese', 'no')}"
  puts "P(Tokyo|no) = #{nb.wordProb('Tokyo', 'no')}"
  puts "P(Japan|no) = #{nb.wordProb('Japan', 'no')}"
  
  # テストデータのカテゴリを予測
  test = ['Chinese', 'Chinese', 'Chinese', 'Tokyo', 'Japan']
  puts "log P(yes|test) = #{nb.score(test, 'yes')}"
  puts "log P(no|test) = #{nb.score(test, 'no')}"
  puts nb.classify(test)


  test = ['Macao', 'Shanghai', 'Chinese', 'Tokyo', 'Japan']
  puts "log P(yes|test) = #{nb.score(test, 'yes')}"
  puts "log P(no|test) = #{nb.score(test, 'no')}"
  puts nb.classify(test)
end

