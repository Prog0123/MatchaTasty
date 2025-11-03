module SocialShareHelper
  def twitter_share_url(text:, url:, hashtags: [])
    base_url = "https://twitter.com/intent/tweet"

    # ハッシュタグから#を除去
    clean_hashtags = hashtags.map { |tag| tag.to_s.gsub("#", "").strip }

    params = {
      text: text,
      url: url,
      hashtags: clean_hashtags.join(",")
    }.compact

    "#{base_url}?#{params.to_query}"
  end

  def twitter_share_text_for_product(product, review)
    # シンプルで読みやすいテキスト
    base_text = "#{product.name}をレビュー🍵"

    if review.present?
      scores = [
        review.richness,
        review.sweetness,
        review.bitterness,
        review.aftertaste,
        review.appearance
      ].compact

      if scores.any?
        average_score = (scores.sum.to_f / scores.size).round(1)
        stars = "⭐" * average_score.round

        # 評価を追加（スペースで区切る）
        base_text += " #{stars} #{average_score}/5.0"
      end
    end

    base_text
  end

  def build_share_hashtags(product)
    hashtags = [ "抹茶スイーツ" ]

    # カテゴリをハッシュタグに追加
    category_hashtag = case product.category
    when "ice_cream"
      "抹茶アイス"
    when "chocolate"
      "抹茶チョコ"
    when "cake"
      "抹茶ケーキ"
    when "drink"
      "抹茶ドリンク"
    when "cookie"
      "抹茶クッキー"
    when "wagashi"
      "抹茶和菓子"
    else
      "抹茶"
    end
    hashtags << category_hashtag

    # アプリ名をハッシュタグに
    hashtags << "MatchaTasty"

    hashtags.first(3) # 最大3つまでに制限
  end
end
