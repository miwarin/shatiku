# coding: utf-8

require './naivebayes'
require './syntactic'
include NLP::Syntactic

def get_words(text)
  words = NLP::Syntactic::analysis(text)
  words.flatten!
  words.map! {|w|
    w.gsub(/[、。\n]/, "")
  }
  return words
end


def build_learning(filepath, cat)
  lines = File.open(filepath).readlines()
  lines.map! {|w|
    w.gsub(/[、。\n]/, "")
  }
  data = [cat, *lines]
  return data
  
end

def classify(nb, text)
  words = get_words(text)
  cat = nb.classify(words)
#  puts nb.score(words, "社畜")
#  puts nb.score(words, "人間")
  return "#{text} => #{cat}"
end


def main(argv)

  shatiku_file = argv[0]
  not_shatiku_file = argv[1]
  shatiku_data = build_learning(shatiku_file, "社畜")
  not_shatiku_data = build_learning(not_shatiku_file, "人間")
  
  nb = NLP::NaiveBayes.new
  nb.train([shatiku_data])
  nb.train([not_shatiku_data])

  text = %w(
    興味ないね
    エアリスはもう喋らない・・・笑わない・・・泣かない、怒らない・・・！
    大切じゃない物なんか無い！
    俺は俺の現実を生きる
    俺は、お前の生きた証だ
    指先がチリチリする。口の中はカラカラだ。目の奥が熱いんだ！
    オレが・・・お前の生きた証・・・
    引きずりすぎて少しすり減ったかな・・・
    お前の分まで生きよう。そう決めたんだけどな…
    もう・・・揺るがないさ・・
    帰るぞ
    俺は幻想の世界の住人だった。でも、もう幻想はいらない……俺は俺の現実を生きる
    ここに女装に必要な何かがある。おれにはわかるんだ。いくぜ！
    星よ・・・降り注げ！！
    罪って…許されるのかな？
    まだ終わりじゃない…終わりじゃないんだ！
    俺はクラウド、ソルジャークラス1st
    厳しくしてもらったおかげで成長できた
    京都大学で超交流会が開かれた
  )
  
  text.each {|t|
    puts classify(nb, t)
  }

end

main(ARGV)

